--
-- Create an entry in error_log table. 
--
-- CALL sp_error_log_create(1, 'My error', 'Details', 'Stack Trace');
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_error_log_create;
DELIMITER $$
CREATE PROCEDURE sp_error_log_create 
(
  IN level int,
  IN message mediumtext,
  IN detail longtext,
  IN stack_trace longtext,
  IN error_date datetime
) 
BEGIN

  --
  -- Variables
  --
  DECLARE error_log_id int DEFAULT 0;



  --
  -- Default values
  --


  --
  -- Log the error
  --
  INSERT INTO error_log
    SET level = level,
        message = message,
        detail = detail,
        stack_trace = stack_trace,
        error_date = error_date;
  

  SELECT LAST_INSERT_ID()
    INTO error_log_id; 


  
  --
  -- Send error info back
  --
  SELECT error_log_id;

END
$$

DELIMITER ;
