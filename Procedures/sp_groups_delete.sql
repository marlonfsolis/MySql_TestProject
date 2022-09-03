--
-- Created on: 8/24/2022 
-- Description: Delete one group by name.
--
-- CALL sp_groups_delete('Group1', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_groups_delete;
DELIMITER $$
CREATE PROCEDURE sp_groups_delete
(
  IN name varchar(100),
  OUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_groups_delete';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE v_count int DEFAULT 0;
  DECLARE log_msgs json DEFAULT JSON_ARRAY();
  DECLARE within_tran bool DEFAULT FALSE;
  DECLARE tran_started bool DEFAULT TRUE;


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
    
    IF tran_started THEN
      ROLLBACK;
    ELSE
       ROLLBACK TO SAVEPOINT sp_groups_delete; 
    END IF;

    CALL sp_handle_error_diagnostic(@sqlstate, @errno, @text, log_msgs, procedure_name, result);

  END;

  --
  -- Temp tables
  --
  DROP TEMPORARY TABLE IF EXISTS response___sp_groups_delete;
  CREATE TEMPORARY TABLE response___sp_groups_delete 
    SELECT * FROM groups_roles gr LIMIT 0;



  --
  -- Log the parameter values passed
  --
  SELECT fn_add_log_message(log_msgs, 'ParameterList:') INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('name: ', IFNULL(name, 'NULL'))) INTO log_msgs;



  --
  -- Default values
  --
  CALL sp_within_transaction(within_tran);
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
   


  --
  -- Start Tran or Savepoint
  --
  IF within_tran THEN
    SAVEPOINT sp_groups_delete;
  ELSE 
    START TRANSACTION;
    SET tran_started = TRUE;
  END IF;



  --
  -- Validate input value
  --
  IF IFNULL(name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field name is required.';
     
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM groups_roles gr WHERE gr.name = name
  ) THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The group was not found.';
     
  END IF;
  

  SELECT fn_add_log_message(log_msgs, 'Validate input values done') INTO log_msgs;



  -- 
  -- Get record to be deleted
  --
  INSERT INTO response___sp_groups_delete (name, description)
  SELECT
    name,
    description
  FROM groups_roles gr
  WHERE gr.name = name;

  SELECT fn_add_log_message(log_msgs, 'Save old values done') INTO log_msgs;



  --
  -- Delete permission associations to this group first
  --
  DELETE
    FROM permissions_groups pg
  WHERE pg.group_name = name;


  -- 
  -- Then delete group
  --
  DELETE
    FROM groups_roles gr
    WHERE gr.name = name;

  SELECT fn_add_log_message(log_msgs, 'Delete record done') INTO log_msgs;


  
  SELECT COUNT(*) FROM response___sp_groups_delete r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;


  --  
  -- Send the response
  --
  SELECT
    r.name,
    r.description
  FROM response___sp_groups_delete r;



  -- Commit
  IF tran_started THEN
    COMMIT;
  END IF;

END
$$

DELIMITER ;
