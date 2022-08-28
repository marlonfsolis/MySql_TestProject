--
-- Created on: 8/27/2022 
-- Description: Get one record.
--
-- CALL sp_groups_read('Value', @Out_Param);
-- SELECT @Out_Param;
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
  DECLARE p_count int DEFAULT 0;



  --
  -- Error handling declarations
  --
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN

    CALL sp_handle_error(procedure_name, result);
    SELECT result;
  END;



  --
  -- Temp tables
  --
  DROP TABLE IF EXISTS log_message CASCADE;
  CREATE TEMPORARY TABLE log_message (
    log_msg varchar(5000),
    log_date datetime
  );

  DROP TABLE IF EXISTS response;
  CREATE TEMPORARY TABLE response 
    SELECT * FROM groups_roles gr LIMIT 0;



  --
  -- Log the parameter values passed
  --
	INSERT INTO log_message VALUES ('ParameterList:', NOW());
	INSERT INTO log_message VALUES (CONCAT('group_name: ', IFNULL(CAST(group_name AS CHAR), 'NULL')), NOW());


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
    SELECT 1 FROM groups_roles gr WHERE gr.name = group_name
  ) THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The groups_roles gr was not found.';
          
  END IF;
  

  INSERT INTO log_message VALUES ('validate input values done', NOW());
  


  -- 
  -- get final result
  --
  INSERT INTO response (name, description)
  SELECT
    gr.name,
    gr.description
  FROM groups_roles gr
  WHERE gr.name = group_name;
 
  INSERT INTO log_message VALUES ('get final result done', NOW());

  
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
