--
-- Created on: 8/24/2022 
-- Description: Delete one permission by name.
--
-- CALL sp_permissions_delete('{"name":"Permission1", "description":"Permission 1"}', @Out_Param);
-- SELECT @Out_Param;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_delete;
DELIMITER $$
CREATE PROCEDURE sp_permissions_delete
(
  IN name varchar(100),
  OUT result json
) 
BEGIN

  --
  -- variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_delete';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;


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
    SELECT * FROM permissions LIMIT 0;



  --
  -- log the parameter values passed
  --
	INSERT INTO log_message VALUES ('ParameterList:', NOW());
	INSERT INTO log_message VALUES (CONCAT('name: ', IFNULL(name, 'NULL')), NOW());



  --
  -- default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
   


  --
  -- validate input value
  --
  IF IFNULL(name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field name is required.'; 

  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM permissions p WHERE p.name = name
  ) THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The permission was not found.';
          
  END IF;
  

  INSERT INTO log_message VALUES ('validate input values done', NOW());



  -- 
  -- get record to be deleted
  --
  INSERT INTO response (name, description)
  SELECT
    name,
    description
  FROM permissions p
  WHERE p.name = name;

  INSERT INTO log_message VALUES ('Old values save done', NOW());



  --
  -- delete permission association to groups first
  --
  DELETE
    FROM permissions_groups pg
  WHERE pg.permission_name = name;


  -- 
  -- then delete permission
  --
  DELETE
    FROM permissions p
    WHERE p.name = name;

 
  INSERT INTO log_message VALUES ('delete record done', NOW());


  
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
