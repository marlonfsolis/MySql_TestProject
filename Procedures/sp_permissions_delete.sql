--
-- Created on: 8/24/2022 
-- Description: Delete one permission by name.
--
-- CALL sp_permissions_delete('{"name":"Permission1", "description":"Permission 1"}', TRUE, @Out_Param);
-- SELECT @Out_Param;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_delete;
DELIMITER $$
CREATE PROCEDURE sp_permissions_delete
(
  IN name varchar(100),
  IN auto_commit bool,
  OUT result json
)
Proc_Exit: 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_delete';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE p_count int DEFAULT 0;
  DECLARE log_msg json DEFAULT JSON_ARRAY();


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

  END;
  SET AUTOCOMMIT = 0;



  --
  -- Temp tables
  --
  DROP TABLE IF EXISTS response___sp_permissions_delete;
  CREATE TEMPORARY TABLE response___sp_permissions_delete 
    SELECT * FROM permissions LIMIT 0;



  --
  -- Log the parameter values passed
  --
  SELECT fn_add_log_message(log_msg, 'ParameterList:') INTO log_msg;
  SELECT fn_add_log_message(log_msg, CONCAT('name: ', IFNULL(name, 'NULL'))) INTO log_msg;



  --
  -- Default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
   


  --
  -- Validate input value
  --
  IF IFNULL(name,'')='' THEN
    CALL sp_handle_error_proc('The field name is required.', log_msg, procedure_name, result);
    LEAVE Proc_Exit;

  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM permissions p WHERE p.name = name
  ) THEN
    CALL sp_handle_error_proc('The permission was not found.', log_msg, procedure_name, result);
    LEAVE Proc_Exit;
          
  END IF;
  

  SELECT fn_add_log_message(log_msg, 'Validate input values done') INTO log_msg;



  -- 
  -- Get record to be deleted
  --
  INSERT INTO response___sp_permissions_delete (name, description)
  SELECT
    name,
    description
  FROM permissions p
  WHERE p.name = name;

  SELECT fn_add_log_message(log_msg, 'Old values save done') INTO log_msg;



  --
  -- Delete permission association to groups first
  --
  DELETE
    FROM permissions_groups pg
  WHERE pg.permission_name = name;


  -- 
  -- Then delete permission
  --
  DELETE
    FROM permissions p
    WHERE p.name = name;

  SELECT fn_add_log_message(log_msg, 'Delete record done') INTO log_msg;


  
  SELECT COUNT(*) FROM response___sp_permissions_delete r INTO p_count;
  SELECT JSON_SET(result, '$.recordCount', p_count) INTO result;


  --  
  -- Send the response
  --
  SELECT
    r.name,
    r.description
  FROM response___sp_permissions_delete r;


END
$$

DELIMITER ;
