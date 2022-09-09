--
-- Created on: 9/8/2022 
-- Description: Get a list of permissions assosiated with a group.
--
-- CALL sp_permissions_group_readlist(0, 10, 
--    '{"group_name":"Group1", "permission_name":"Permission1"}', 
--    '{"group_name":"G%", "permission_name":"P%"}', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_group_readlist;
DELIMITER $$
CREATE PROCEDURE sp_permissions_group_readlist
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
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_group_readlist';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE v_count int DEFAULT 0;
  DECLARE log_msgs json DEFAULT JSON_ARRAY();

  -- filters
  DECLARE group_name_filter varchar(100);
  DECLARE permission_name_filter varchar(100);
  -- searchs
  DECLARE group_name_search varchar(100);
  DECLARE permission_name_search varchar(100);


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
  DROP TEMPORARY TABLE IF EXISTS response___sp_permissions_group_readlist;
  CREATE TEMPORARY TABLE response___sp_permissions_group_readlist 
    SELECT * FROM permissions_groups pg LIMIT 0;



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
    FROM permissions_groups pg;
  END IF;  
  IF JSON_VALID(filterJson) = 0 THEN
    SET filterJson = '{}';
  END IF;
  IF JSON_VALID(searchJson) = 0 THEN
    SET searchJson = '{}';
  END IF;



  --
  -- Get filter values
  --
  SELECT JSON_VALUE (filterJson, '$.group_name') INTO group_name_filter;
  SELECT JSON_VALUE (filterJson, '$.permission_name') INTO permission_name_filter;
  
  SELECT fn_add_log_message(log_msgs, 'Get filter values done') INTO log_msgs;


  --
  -- Get search values
  --
  SELECT JSON_VALUE (searchJson, '$.group_name') INTO group_name_search;
  SELECT JSON_VALUE (searchJson, '$.permission_name') INTO permission_name_search;
  
  SELECT fn_add_log_message(log_msgs, 'Get search values done') INTO log_msgs;



  -- 
  -- Get final result
  --
  INSERT INTO response___sp_permissions_group_readlist (group_name, permission_name)
  SELECT
    pg.group_name,
    pg.permission_name
  FROM permissions_groups pg
  
  -- filter
  WHERE (group_name_filter IS NULL OR group_name_filter = pg.group_name)
  AND (permission_name_filter IS NULL OR permission_name_filter = pg.permission_name)

  -- search
  AND (group_name_search IS NULL OR pg.group_name LIKE group_name_search)
  AND (permission_name_search IS NULL OR pg.permission_name LIKE permission_name_search);
 
  SELECT fn_add_log_message(log_msgs, 'Get final result done') INTO log_msgs;

  
  SELECT COUNT(*) FROM response___sp_permissions_group_readlist r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;
  
  SELECT fn_add_log_message(log_msgs, 'Result count done') INTO log_msgs;


  --  
  -- Send the response
  --
  SELECT
    r.group_name,
    r.permission_name
  FROM response___sp_permissions_group_readlist r;


END
$$

DELIMITER ;
