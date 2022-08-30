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
Proc_Exit:
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_write';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;
  DECLARE log_msg json DEFAULT JSON_ARRAY();

  -- Fields
  DECLARE name varchar(100);
  DECLARE description varchar(1000);
  


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

    CALL sp_handle_error_diagnostic(@sqlstate, @errno, @text, log_msg, procedure_name, result);
    
    IF auto_commit THEN
      ROLLBACK;
    END IF;

  END;
  SET AUTOCOMMIT = 0;


   
  --
  -- Temp tables
  --
  DROP TABLE IF EXISTS response___sp_permissions_write;
  CREATE TEMPORARY TABLE response___sp_permissions_write 
    SELECT * FROM permissions p LIMIT 0;



  --
  -- Log the parameter values passed
  --
  SELECT fn_add_log_message(log_msg, 'ParameterList:') INTO log_msg;
  SELECT fn_add_log_message(log_msg, CONCAT('p_json: ', IFNULL(p_json, 'NULL'))) INTO log_msg;



  --
  -- Default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
  SET auto_commit = IFNULL(auto_commit,TRUE);
   


  --
  -- Validate json input
  --
  IF JSON_VALID(p_json) = 0 THEN
    CALL sp_handle_error_proc('The json input is not valid.', log_msg, procedure_name, result);
    LEAVE Proc_Exit;
  END IF;



  --
  -- Get json values
  --
  SELECT
    JSON_VALUE (p_json, '$.name'),
    JSON_VALUE (p_json, '$.description') 
  INTO name, 
      description;
  
  SELECT fn_add_log_message(log_msg, 'Get json values done') INTO log_msg;



  --
  -- Validate json values
  --
  IF IFNULL(name,'')='' THEN
    CALL sp_handle_error_proc('The field name is required.', log_msg, procedure_name, result);
    LEAVE Proc_Exit;

  END IF;

  IF EXISTS (
    SELECT 1 
    FROM permissions p 
    WHERE p.name = name
  ) 
  THEN
    CALL sp_handle_error_proc('The permission name already exist.', log_msg, procedure_name, result);
    LEAVE Proc_Exit;

  END IF;
  
  SELECT fn_add_log_message(log_msg, 'Validate json values done') INTO log_msg;



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

  SELECT fn_add_log_message(log_msg, 'Get final result done') INTO log_msg;


  
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
