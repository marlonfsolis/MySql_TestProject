--
-- Created on: 8/23/2022 
-- Description: Create one permission.
--
-- CALL sp_permissions_write('{"name":"Permission1", "description":"Permission 1"}', @Out_Param);
-- SELECT @Out_Param;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_write;
DELIMITER $$
CREATE PROCEDURE sp_permissions_write
(
  IN p_json json,
  OUT result json
) 
BEGIN

  --
  -- variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_write';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;

  -- fields
  DECLARE name varchar(100);
  DECLARE description varchar(1000);
  


  --
  -- error handling declarations
  --
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    CALL sp_handle_error(procedure_name, result);

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
	INSERT INTO log_message VALUES (CONCAT('p_json: ', IFNULL(p_json, 'NULL')), NOW());



  --
  -- default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
   


  --
  -- validate json input
  --
  IF JSON_VALID(p_json) = 0 THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The json input is not valid.'; 
  END IF;


  --
  -- get json values
  --
  SELECT
    JSON_VALUE (p_json, '$.name'),
    JSON_VALUE (p_json, '$.description') 
  INTO name, description;
  
  INSERT INTO log_message VALUES ('get json values done', NOW());


  --
  -- validate json values
  --
  IF IFNULL(name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field name is required.'; 

  END IF;

  IF EXISTS (
    SELECT 1 
    FROM permissions p 
    WHERE p.name = name
  ) 
  THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The permission name already exist.';
     
  END IF;
  

  INSERT INTO log_message VALUES ('validate json values done', NOW());


  -- 
  -- create permissions
  --
  INSERT INTO permissions
    SET name = name,
        description = description;

  -- 
  -- get final result
  --
  INSERT INTO response (name, description)
  SELECT
    name,
    description
  FROM permissions p
  WHERE p.name = name;

 
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
