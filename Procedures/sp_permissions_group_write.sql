--
-- Created on: 9/5/2022 
-- Description: Assing one or more permissions to a group.
--
-- CALL sp_permissions_group_create('{"group":"Group1", "permissions":["Permission1"]}', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_permissions_group_create;
DELIMITER $$
CREATE PROCEDURE sp_permissions_group_create
(
  IN p_json json,
  OUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_permissions_group_create';
  DECLARE error_msg varchar(1000) DEFAULT '';
  DECLARE error_log_id int DEFAULT 0;
  DECLARE v_count int DEFAULT 0;
  DECLARE log_msgs json DEFAULT JSON_ARRAY();
  DECLARE within_tran bool DEFAULT FALSE;
  DECLARE tran_started bool	DEFAULT	TRUE;  

  -- Fields
  DECLARE group_name varchar(1000);
  DECLARE permission_names_json json;
  


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
  		 ROLLBACK TO SAVEPOINT sp_permissions_group_create;	
  	END	IF;
  
  	CALL sp_handle_error_diagnostic(@sqlstate, @errno, @text,	log_msgs,	procedure_name,	result);

  END;


  --
  -- Temp tables
  --
  DROP TEMPORARY TABLE IF EXISTS response___sp_permissions_group_create;
  CREATE TEMPORARY TABLE response___sp_permissions_group_create 
    SELECT 
      gr.name AS group_name, 
      p.name AS permission_name 
    FROM permissions p
    INNER JOIN permissions_groups pg ON p.name = pg.permission_name
    INNER JOIN groups_roles gr ON p.name = gr.name
    LIMIT 0;

  DROP TEMPORARY TABLE IF EXISTS permission_names;
  CREATE TEMPORARY TABLE permission_names
  (
    p_name varchar(100)
  );



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
	SAVEPOINT sp_permissions_group_create;
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
    JSON_VALUE(p_json, '$.group'),
    JSON_VALUE(p_json, '$.permissions')
  INTO group_name, permission_names_json;


  INSERT INTO permission_names (p_name)
  SELECT permission 
  FROM JSON_TABLE(permission_names_json, '$[*]' COLUMNS(
       permission varchar(100) PATH '$'
      ) 
    ) AS jt;
  
  SELECT fn_add_log_message(log_msgs, 'Get json values done') INTO log_msgs;



  --
  -- Validate json values
  --
  IF IFNULL(group_name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The group name is required.'; 

  END IF;
  
  IF NOT EXISTS (
    SELECT 1 
    FROM groups_roles gr 
    WHERE gr.name = group_name
  ) 
  THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The group was not found.';
     
  END IF; 
  
  IF EXISTS (
    SELECT
      1
    FROM permission_names pn
    LEFT JOIN permissions p ON p.name = pn.p_name
    WHERE p.name IS NULL 
  ) THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'One or more permission(s) was not found.';

  END IF;

  -- Do not stop just...
  -- Remove permissions from permission_names that are assigned to group already
  DELETE pn
  FROM permission_names pn
  WHERE EXISTS(
    SELECT
      1
    FROM permissions_groups pg
    WHERE pg.group_name = group_name
    AND pg.permission_name = pn.p_name
  );
  

  SELECT fn_add_log_message(log_msgs, 'Validate json values done') INTO log_msgs;


  -- 
  -- Asign permissions to group
  --
  INSERT INTO permissions_groups (permission_name, group_name)
    SELECT
      pn.p_name,
      group_name
    FROM permission_names pn;

  -- 
  -- Get final result
  --
  INSERT INTO response___sp_permissions_group_create (group_name, permission_name)
  SELECT
    group_name,
    permission_name
  FROM permissions_groups pg
  WHERE pg.group_name = group_name;

 
  SELECT fn_add_log_message(log_msgs, 'Get final result done') INTO log_msgs;


  
  SELECT COUNT(*) FROM response___sp_permissions_group_create r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;


  --  
  -- Send the response
  --
  SELECT
    r.group_name,
    r.permission_name
  FROM response___sp_permissions_group_create r;
  

  IF tran_started THEN
    COMMIT;
  END IF;

END
$$

DELIMITER ;
