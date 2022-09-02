--
-- Created on: 8/26/2022 
-- Description: Get group list
--
-- CALL sp_groups_readlist(0, 10, '{"name":"Value"}', '{"description":"%"}', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_groups_readlist;
DELIMITER $$
CREATE PROCEDURE sp_groups_readlist
(
  IN offsetRows int,
  IN fetchRows int,
  IN filterJson json,
  IN searchJson json,
  OUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_groups_readlist';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE v_count int DEFAULT 0;
  DECLARE log_msgs json DEFAULT JSON_ARRAY();

  -- filters
  DECLARE name_filter varchar(100);
  DECLARE description_filter varchar(1000);

  -- searchs
  DECLARE name_search varchar(100);
  DECLARE description_search varchar(1200);


  --
  -- Error handling declarations
  --
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    -- Get error info
    GET CURRENT DIAGNOSTICS CONDITION 1
      @sqlstate = RETURNED_SQLSTATE, 
      @errno = MYSQL_ERRNO,
      @text = MESSAGE_TEXT;

    CALL sp_handle_error_diagnostic(@sqlstate, @errno, @text, log_msgs, procedure_name, result);

  END;

  --
  -- Temp tables
  --
  DROP TEMPORARY TABLE IF EXISTS response___sp_permissions_readlist;
  CREATE TEMPORARY TABLE response___sp_permissions_readlist 
    SELECT * FROM groups_roles gr LIMIT 0;



  --
  -- Log the parameter values passed
  --
	SELECT fn_add_log_message(log_msgs, 'ParameterList:') INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('offsetRows: ', IFNULL(CAST(offsetRows AS CHAR), 'NULL'))) INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('fetchRows: ', IFNULL(CAST(fetchRows AS char(20)), 'NULL'))) INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('filterJson: ', IFNULL(filterJson, 'NULL'))) INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('searchJson: ', IFNULL(CAST(searchJson AS char), 'NULL'))) INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('ProfileId: ', IFNULL(CAST(0 AS char), 'NULL'))) INTO log_msgs;



  --
  -- Default values
  --
  SET offsetRows = IFNULL(offsetRows, 0);
  SET fetchRows = IFNULL(fetchRows, 10);
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
  
  IF fetchRows = 0 THEN
  SELECT
    COUNT(1) INTO fetchRows
  FROM groups_roles gr;
  END IF;  
  IF JSON_VALID(filterJson) = 0 THEN
    SET filterJson = '{}';
  END IF;
  IF JSON_VALID(searchJson) = 0 THEN
    SET searchJson = '{}';
  END IF;

  SELECT fn_add_log_message(log_msgs, 'Default values done') INTO log_msgs;



  --
  -- Get filter values
  --
  SELECT JSON_VALUE (filterJson, '$.name') INTO name_filter;
  SELECT JSON_VALUE (filterJson, '$.description') INTO description_filter;
  
  SELECT fn_add_log_message(log_msgs, 'Get filter values done') INTO log_msgs;


  --
  -- Get search values
  --
  SELECT JSON_VALUE (searchJson, '$.name') INTO name_search;
  SELECT JSON_VALUE (searchJson, '$.description') INTO description_search;
  
  SELECT fn_add_log_message(log_msgs, 'Get search values done') INTO log_msgs;



  -- 
  -- Get final result
  --
  INSERT INTO response___sp_permissions_readlist (name, description)
  SELECT
    name,
    description
  FROM groups_roles gr
  
  -- filter
  WHERE (name_filter IS NULL OR name_filter = name)
  AND (description_filter IS NULL OR description_filter = gr.description)

  -- search
  AND (name_search IS NULL OR name_search LIKE gr.name)
  AND (description_search IS NULL OR description_search LIKE gr.description);
 
  SELECT fn_add_log_message(log_msgs, 'Get final result done') INTO log_msgs;

  
  SELECT COUNT(*) FROM response___sp_permissions_readlist r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;

  SELECT fn_add_log_message(log_msgs, 'Result count done') INTO log_msgs;


  --  
  -- Send the response
  --
  SELECT
    r.name,
    r.description
  FROM response___sp_permissions_readlist r;


END
$$

DELIMITER ;
