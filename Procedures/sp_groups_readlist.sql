--
-- Created on: 8/26/2022 
-- Description: Get group list
--
-- CALL sp_groups_readlist(0, 10, '{"name":"Value"}', '{"description":"%"}', @Out_Param);
-- SELECT @Out_Param;
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
  -- variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_groups_readlist';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;

  -- filters
  DECLARE name_filter varchar(100);
  DECLARE description_filter varchar(1000);

  -- searchs
  DECLARE name_search varchar(100);
  DECLARE description_search varchar(1200);


  --
  -- error handling declarations
  --
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN

    CALL sp_handle_error(procedure_name, result);
    SELECT result;
  END;


  --
  -- temp tables
  --
  DROP TABLE IF EXISTS log_message CASCADE;
  CREATE TEMPORARY TABLE log_message (
    log_msg varchar(5000),
    log_date datetime
  );

  DROP TABLE IF EXISTS response;
  CREATE TEMPORARY TABLE response 
    SELECT * FROM groups_roles gr LIMIT 0;



  --
  -- log the parameter values passed
  --
	INSERT INTO log_message VALUES ('ParameterList:', NOW());
	INSERT INTO log_message VALUES (CONCAT('offsetRows: ', IFNULL(CAST(offsetRows AS CHAR), 'NULL')), NOW());
	INSERT INTO log_message VALUES (CONCAT('fetchRows: ', IFNULL(CAST(fetchRows AS char(20)), 'NULL')), NOW());
	INSERT INTO log_message VALUES (CONCAT('filterJson: ', IFNULL(filterJson, 'NULL')), NOW());
	INSERT INTO log_message VALUES (CONCAT('searchJson: ', IFNULL(CAST(searchJson AS char), 'NULL')), NOW());


  --
  -- default values
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



  --
  -- get filter values
  --
  SELECT JSON_VALUE (filterJson, '$.name') INTO name_filter;
  SELECT JSON_VALUE (filterJson, '$.description') INTO description_filter;
  
  INSERT INTO log_message VALUES ('get filter values done', NOW());


  --
  -- get search values
  --
  SELECT JSON_VALUE (searchJson, '$.name') INTO name_search;
  SELECT JSON_VALUE (searchJson, '$.description') INTO description_search;
  
  INSERT INTO log_message VALUES ('get search values done', NOW());



  -- 
  -- get final result
  --
  INSERT INTO response (name, description)
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
 
  INSERT INTO log_message VALUES ('get final result done', NOW());

  
  SELECT COUNT(*) FROM response r INTO p_count;
  SELECT JSON_SET(result, '$.recordCount', p_count) INTO result;


  --  
  -- send the response
  --
  SELECT
    r.name,
    r.description
  FROM response r;


END
$$

DELIMITER ;
