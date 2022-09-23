--
-- Created on: 9/17/2022 
-- Description: Create a user record.
--
-- CALL sp_users_write('{"user_id":1}', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_users_write;
DELIMITER $$
CREATE PROCEDURE sp_users_write
(
  IN p_json json,
  OUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_users_write';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE v_count int DEFAULT 0;
  DECLARE log_msgs json DEFAULT JSON_ARRAY();
  DECLARE within_tran bool DEFAULT FALSE;
  DECLARE tran_started bool	DEFAULT	TRUE;  

  -- Fields
  DECLARE user_id int;
  


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

	IF tran_started	THEN
		ROLLBACK;
	ELSE
		 ROLLBACK TO SAVEPOINT sp_users_write;	
	END	IF;

	CALL sp_handle_error_diagnostic(@sqlstate, @errno, @text,	log_msgs,	procedure_name,	result);

  END;


  --
  -- Temp tables
  --
  DROP TEMPORARY TABLE IF EXISTS response___sp_users_write;
  CREATE TEMPORARY TABLE response___sp_users_write 
    SELECT * FROM users u LIMIT 0;



  --
  -- Log the parameter values passed
  --
  SELECT fn_add_log_message(log_msgs, 'ParameterList:') INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('p_json: ', IFNULL(p_json, 'NULL'))) INTO log_msgs;
	


  --
  -- Default values
  --
  CALL sp_within_transaction(within_tran);
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
   


  --
  -- Start Tran	or Savepoint
  --
  IF within_tran THEN
	SAVEPOINT sp_users_write;
  ELSE 
	START TRANSACTION;
	SET	tran_started = TRUE;
  END IF;



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
    JSON_VALUE (p_json, '$.user_id')
  INTO user_id;
  
  SELECT fn_add_log_message(log_msgs, 'Get json values done') INTO log_msgs;



  --
  -- Validate json values
  --
  IF IFNULL(user_id,0)=0 THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field user_id is required.'; 

  END IF;
  
  IF EXISTS (
    SELECT 1 
    FROM users u 
    WHERE u.user_id = user_id
  ) 
  THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The users u user_id already exist.';
     
  END IF;  
  

  SELECT fn_add_log_message(log_msgs, 'Validate json values done') INTO log_msgs;


  -- 
  -- Create users u
  --
  INSERT INTO users
    SET user_id = user_id;

  -- 
  -- Get final result
  --
  INSERT INTO response___sp_users_write (user_id, description)
  SELECT
    user_id
  FROM users u
  WHERE u.user_id = user_id;

 
  SELECT fn_add_log_message(log_msgs, 'Get final result done') INTO log_msgs;


  
  SELECT COUNT(*) FROM response___sp_users_write r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;


  --  
  -- Send the response
  --
  SELECT
    r.*
  FROM response___sp_users_write r;
  


  -- Commit
  IF tran_started THEN
    COMMIT;
  END IF;

END
$$

DELIMITER ;
