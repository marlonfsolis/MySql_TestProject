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
Proc_Exit:
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_read';
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
  DROP TABLE IF EXISTS response___sp_permissions_read;
  CREATE TEMPORARY TABLE response___sp_permissions_read 
    SELECT * FROM permissions p LIMIT 0;



  --
  -- Log the parameter values passed
  --

  SELECT fn_add_log_message(log_msg, 'ParameterList:') INTO log_msg;
  SELECT fn_add_log_message(log_msg, CONCAT('permission_name: ', IFNULL(CAST(permission_name AS CHAR), 'NULL'))) INTO log_msg;



  --
  -- Default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);



  --
  -- Validate input value
  --
  IF IFNULL(permission_name,'')='' THEN

      CALL sp_handle_error_proc('The field permission_name is required.', log_msg, procedure_name, result);
      LEAVE Proc_Exit;

  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM permissions p WHERE p.name = permission_name
  ) THEN

    CALL sp_handle_error_proc('The permission was not found.', log_msg, procedure_name, result);
    LEAVE Proc_Exit;
          
  END IF;
  
  SELECT fn_add_log_message(log_msg, 'Validate input values done') INTO log_msg;



  -- 
  -- Get final result
  --
  INSERT INTO response___sp_permissions_read (name, description)
  SELECT
    p.name,
    p.description
  FROM permissions p
  WHERE p.name = permission_name;


  SELECT fn_add_log_message(log_msg, 'Get final result done') INTO log_msg;

  
  SELECT COUNT(*) FROM response___sp_permissions_read r INTO p_count;
  SELECT JSON_SET(result, '$.recordCount', p_count) INTO result;


  SELECT fn_add_log_message(log_msg, 'Record count done') INTO log_msg;



  --  
  -- Send the response
  --
  SELECT
    r.name,
    r.description
  FROM response___sp_permissions_read r;


END
$$

DELIMITER ;