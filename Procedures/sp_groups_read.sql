--
-- Created on: 8/27/2022 
-- Description: Get one record.
--
-- CALL sp_groups_read('Group1', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_groups_read;
DELIMITER $$
CREATE PROCEDURE sp_groups_read
(
  IN group_name varchar(100),
  OUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE procedure_name varchar(100) DEFAULT 'sp_groups_read';
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
  DROP TEMPORARY TABLE IF EXISTS response___sp_groups_read;
  CREATE TEMPORARY TABLE response___sp_groups_read 
    SELECT * FROM role gr LIMIT 0;



  --
  -- Log the parameter values passed
  --
  SELECT fn_add_log_message(log_msgs, 'ParameterList:') INTO log_msgs;
  SELECT fn_add_log_message(log_msgs, CONCAT('group_name: ', IFNULL(CAST(group_name AS CHAR), 'NULL'))) INTO log_msgs;



  --
  -- Default values
  --
  SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);



  --
  -- Validate input value
  --
  IF IFNULL(group_name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field group_name is required.'; 

  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM role gr WHERE gr.name = group_name
  ) THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The role gr was not found.';
          
  END IF;
  
  SELECT fn_add_log_message(log_msgs, 'Validate input values done') INTO log_msgs;
  


  -- 
  -- Get final result
  --
  INSERT INTO response___sp_groups_read (name, description)
  SELECT
    gr.name,
    gr.description
  FROM role gr
  WHERE gr.name = group_name;
 
  SELECT fn_add_log_message(log_msgs, 'Get final result done') INTO log_msgs;

  
  SELECT COUNT(*) FROM response___sp_groups_read r INTO v_count;
  SELECT JSON_SET(result, '$.recordCount', v_count) INTO result;

  SELECT fn_add_log_message(log_msgs, 'Record count done') INTO log_msgs;


  --  
  -- Send the response
  --
  SELECT
    r.name,
    r.description
  FROM response___sp_groups_read r;


END
$$

DELIMITER ;
