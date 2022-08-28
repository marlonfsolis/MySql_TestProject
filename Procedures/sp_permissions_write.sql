--
-- Created on: 8/23/2022 
-- Description: Create one permission.
--
-- CALL sp_permissions_write('{"name":"Permission1", "description":"Permission 1"}', TRUE, @Out_Param);
-- SELECT @Out_Param;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_write;
DELIMITER $$
CREATE PROCEDURE sp_permissions_write
(
  IN p_json json,
  IN auto_commit bool,
  OUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_write';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;

  -- Fields
  DECLARE name varchar(100);
  DECLARE description varchar(1000);
  


  --
  -- Error handling declarations
  --
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    CALL sp_handle_error(procedure_name, result);
    
    IF auto_commit THEN
      ROLLBACK;
    END IF;

  END;


  --
  -- Temp tables
  --
  DROP TABLE IF EXISTS log_message CASCADE;
  CREATE TEMPORARY TABLE log_message (
    log_msg varchar(5000),
    log_date datetime
  );

  DROP TABLE IF EXISTS response___sp_permissions_write;
  CREATE TEMPORARY TABLE response___sp_permissions_write 
    SELECT * FROM permissions p LIMIT 0;



  --
  -- Log the parameter values passed
  --
	INSERT INTO log_message VALUES ('ParameterList:', NOW());
	INSERT INTO log_message VALUES (CONCAT('p_json: ', IFNULL(p_json, 'NULL')), NOW());



  --
  -- Default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
  SET auto_commit = IFNULL(auto_commit,TRUE);
   


  --
  -- Validate json input
  --
  IF JSON_VALID(p_json) = 0 THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The json input is not valid.'; 
  END IF;


  --
  -- Get json values
  --
  SELECT
    JSON_VALUE (p_json, '$.name'),
    JSON_VALUE (p_json, '$.description') 
  INTO name, description;
  
  INSERT INTO log_message VALUES ('get json values done', NOW());


  --
  -- Validate json values
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
  -- Create permissions
  --
  INSERT INTO permissions
    SET name = name,
        description = description;

  -- 
  -- Get final result
  --
  INSERT INTO response___sp_permissions_write (name, description)
  SELECT
    name,
    description
  FROM permissions p
  WHERE p.name = name;

 
  INSERT INTO log_message VALUES ('get final result done', NOW());


  
  SELECT COUNT(*) FROM response___sp_permissions_write r INTO p_count;
  SELECT JSON_SET(result, '$.recordCount', p_count) INTO result;



  --  
  -- Send the response
  --
  SELECT
    r.name,
    r.description
  FROM response___sp_permissions_write r;



  IF auto_commit THEN
    COMMIT;
  END IF;
 
END
$$

DELIMITER ;
