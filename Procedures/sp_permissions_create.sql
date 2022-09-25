--
-- Created on: 8/23/2022 
-- Description: Create one permission.
--
-- CALL sp_permissions_create('{"name":"Permission1", "description":"Permission 1"}', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_create;
DELIMITER $$
CREATE PROCEDURE sp_permissions_create
(
  IN p_json json,
  OUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_create';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE v_count int DEFAULT 0;
  DECLARE log_msgs json DEFAULT JSON_ARRAY();
	DECLARE	within_tran	bool DEFAULT FALSE;
	DECLARE	tran_started bool	DEFAULT	TRUE;

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

		IF tran_started	THEN
			ROLLBACK;
		ELSE
			 ROLLBACK	TO SAVEPOINT sp_permissions_create;	
		END	IF;

		CALL sp_handle_error_diagnostic(@sqlstate, @errno, @text,	log_msgs,	procedure_name,	result);

  END;
   
  --
  -- Temp tables
  --
  DROP TEMPORARY TABLE IF EXISTS response___sp_permissions_create;
  CREATE TEMPORARY TABLE response___sp_permissions_create 
    SELECT * FROM permissions p LIMIT 0;



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
		SAVEPOINT	sp_permissions_create;
	ELSE 
		START	TRANSACTION;
		SET	tran_started = TRUE;
	END	IF;


  --
  -- Validate json input
  --
  IF JSON_VALID(p_json) = 0 THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = '400|The json input is not valid.';
     
  END IF;



  --
  -- Get json values
  --
  SELECT
    JSON_VALUE (p_json, '$.name'),
    JSON_VALUE (p_json, '$.description') 
  INTO name, 
      description;
  
  SELECT fn_add_log_message(log_msgs, 'Get json values done') INTO log_msgs;



  --
  -- Validate json values
  --
  IF IFNULL(name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = '400|The field name is required.';
     
  END IF;

  IF EXISTS (
    SELECT 1 
    FROM permissions p 
    WHERE p.name = name
  ) 
  THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = '400|The permission name already exist.';
     
  END IF;
  
  SELECT fn_add_log_message(log_msgs, 'Validate json values done') INTO log_msgs;



  -- 
  -- Create permissions
  --
  INSERT INTO permissions
    SET name = name,
        description = description;



  -- 
  -- Get final result
  --
  INSERT INTO response___sp_permissions_create (name, description)
  SELECT
    name,
    description
  FROM permissions p
  WHERE p.name = name;

  SELECT fn_add_log_message(log_msgs, 'Get final result done') INTO log_msgs;


  
  SELECT COUNT(*) FROM response___sp_permissions_create r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;



  --  
  -- Send the response
  --
  SELECT
    r.name,
    r.description
  FROM response___sp_permissions_create r;



	-- Commit
	IF tran_started	THEN
		COMMIT;
	END	IF;	
 
END
$$

DELIMITER ;
