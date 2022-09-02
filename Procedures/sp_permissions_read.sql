--
-- Get one permission by its ID
--
-- CALL sp_Permission_Read(1, @result);
-- SELECT @result;
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
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_read';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE v_count int DEFAULT 0;
  DECLARE log_msgs json DEFAULT JSON_ARRAY();


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
  DROP TEMPORARY TABLE IF EXISTS response___sp_permissions_read;
  CREATE TEMPORARY TABLE response___sp_permissions_read 
    SELECT * FROM permissions p LIMIT 0;



  --
  -- Log the parameter values passed
  --

  SELECT fn_add_log_message(log_msgs, 'ParameterList:') INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('permission_name: ', IFNULL(CAST(permission_name AS CHAR), 'NULL'))) INTO log_msgs;



  --
  -- Default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);



  --
  -- Validate input value
  --
  IF IFNULL(permission_name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field permission_name is required.';

  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM permissions p WHERE p.name = permission_name
  ) THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The permission was not found.';
     
  END IF;
  
  SELECT fn_add_log_message(log_msgs, 'Validate input values done') INTO log_msgs;



  -- 
  -- Get final result
  --
  INSERT INTO response___sp_permissions_read (name, description)
  SELECT
    p.name,
    p.description
  FROM permissions p
  WHERE p.name = permission_name;


  SELECT fn_add_log_message(log_msgs, 'Get final result done') INTO log_msgs;

  
  SELECT COUNT(*) FROM response___sp_permissions_read r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;


  SELECT fn_add_log_message(log_msgs, 'Record count done') INTO log_msgs;



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