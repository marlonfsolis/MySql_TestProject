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
  IN message varchar(65500),
  IN detail varchar(65500),
  IN stack_trace varchar(65500),
  IN error_date datetime
) 
BEGIN

  --
  -- Variables
  --
  DECLARE error_logid int DEFAULT 0;



  --
  -- Default values
  --


  --
  -- Log the error
  --
	INSERT INTO error_log (error_message, error_detail, stack_trace, error_date)
		VALUES (error_msg, error_detail, stack_trace, NOW());

  SELECT LAST_INSERT_ID()
    INTO error_logid;



  INSERT INTO error_log_trace (error_logid, trace_message, trace_date)
    SELECT 
      error_logid,
      lm.log_msg,
      lm.log_date
    FROM log_message lm;    


  

  --
  -- Send error info back
  --
  SET result = JSON_SET(result, 
      '$.success', FALSE, 
      '$.msg', error_msg, 
      '$.errorLogId', error_logid, 
      '$.recordCount', 0);

END
$$

DELIMITER ;
