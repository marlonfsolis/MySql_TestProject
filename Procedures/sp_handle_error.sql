--
-- Handle errors from routins. 
-- Will log the error on error tables.
-- and send the result json back to the routin
--
-- CALL sp_handle_error('My error', 'Details', 'Stack Trace', 'procedure_name', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_handle_error;
DELIMITER $$
CREATE PROCEDURE sp_handle_error 
(
  IN error_msg text,
  IN error_detail text,
  IN stack_trace text,
  IN procedure_name varchar(100),
  INOUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE error_detail longtext DEFAULT NULL;
  DECLARE error_logid int DEFAULT 0;



  --
  -- Default values
  --
  SET error_msg = IFNULL(error_msg, 'N/A');
  SET procedure_name = IFNULL(procedure_name, 'N/A');
  
  IF JSON_VALID(result) = 0 THEN
    SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
  END IF;



  --
  -- Get error info
  --
  SELECT CONCAT(procedure_name, ' - ', error_msg) 
    INTO error_msg;


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
