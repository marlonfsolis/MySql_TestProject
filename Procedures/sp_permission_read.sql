--
-- Get permissions list
--
-- CALL sp_Permission_Read(1, @Out_Param);
-- SELECT @Out_Param;
-- 

DROP PROCEDURE IF EXISTS sp_Permission_Read;

CREATE PROCEDURE sp_Permission_Read 
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
  DECLARE procedure_name varchar(100) DEFAULT 'sp_Permission_Read';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;

  -- filters
  DECLARE name_filter varchar(100);
  DECLARE description_filter varchar(1000);
  -- searchs
  DECLARE name_search varchar(100);
  DECLARE description_search varchar(1000);


  DROP TABLE IF EXISTS log_message CASCADE;
  CREATE TEMPORARY TABLE log_message (
    log_msg varchar(5000),
    log_date datetime
  );

  DROP TABLE IF EXISTS response;
  CREATE TEMPORARY TABLE response 
    SELECT * FROM permissions p LIMIT 0;


  --
  -- log the parameter values passed
  --
	INSERT INTO log_message VALUES ('ParameterList:', NOW());
	INSERT INTO log_message VALUES (CONCAT('offsetRows: ', IFNULL(CAST(offsetRows AS CHAR), 'NULL')), NOW());
	INSERT INTO log_message VALUES (CONCAT('fetchRows: ', IFNULL(CAST(fetchRows AS char(20)), 'NULL')), NOW());
	INSERT INTO log_message VALUES (CONCAT('filterJson: ', IFNULL(filterJson, 'NULL')), NOW());
	INSERT INTO log_message VALUES (CONCAT('searchJson: ', IFNULL(CAST(searchJson AS char), 'NULL')), NOW());
	INSERT INTO log_message VALUES (CONCAT('ProfileId: ', IFNULL(CAST(0 AS char), 'NULL')), NOW());


  --
  -- default values
  --
  SET offsetRows = IFNULL(offsetRows, 0);
  SET fetchRows = IFNULL(fetchRows, 10);
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
  
  IF fetchRows = 0 THEN
  SELECT
    COUNT(1) INTO fetchRows
  FROM permissions p;
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
  SELECT
    JSON_VALUE (filterJson, '$.name'),
    JSON_VALUE (filterJson, '$.description') 
  INTO name_filter,
    description_filter
  ;


  --
  -- get search values
  --
  SELECT
    JSON_VALUE (searchJson, '$.name'),
    JSON_VALUE (searchJson, '$.description') 
  INTO name_filter,
    description_filter
  ;



  -- 
  -- get final result
  --
  INSERT INTO response (name, description)
  SELECT
    p.name,
    p.description
  FROM permissions p
  
  -- filter
  WHERE (name_filter IS NULL OR name_filter = p.name)
  AND (description_filter IS NULL OR description_filter = p.description)

  -- search
  AND (name_search IS NULL OR name_search LIKE p.description)
  AND (description_search IS NULL OR description_search LIKE p.description)
  ;

  
  SELECT FOUND_ROWS() INTO p_count;
  SELECT JSON_SET(result, '$.recordCount', p_count) INTO result;


  --  
  -- send the response
  --
  SELECT
    r.name,
    r.description
  FROM response r;


END;
