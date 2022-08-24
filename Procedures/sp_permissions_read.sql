--
-- Get one permission by its ID
--
-- CALL sp_Permission_Read(1, @Out_Param);
-- SELECT @Out_Param;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_read;
DELIMITER $$
CREATE PROCEDURE sp_permissions_read 
(
  IN permission_name varchar(100),
  OUT result json
) 
BEGIN

  --
  -- variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_read';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;


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
    SELECT * FROM permissions p LIMIT 0;



  --
  -- log the parameter values passed
  --
	INSERT INTO log_message VALUES ('ParameterList:', NOW());
	INSERT INTO log_message VALUES (CONCAT('permission_name: ', IFNULL(CAST(permission_name AS CHAR), 'NULL')), NOW());



  --
  -- default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);




  -- 
  -- get final result
  --
  INSERT INTO response (name, description)
  SELECT
    p.name,
    p.description
  FROM permissions p
  WHERE p.name = permission_name;


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


END;
