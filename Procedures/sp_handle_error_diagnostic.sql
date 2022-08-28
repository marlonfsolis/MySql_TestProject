--
-- Handle errors from routins. 
-- Will log the error on error tables.
-- and send the result json back to the routin
--
-- CALL sp_handle_error_diagnostic(@sqlstate, @errno, @text, '[]', procedure_name, @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_handle_error_diagnostic;
DELIMITER $$
CREATE PROCEDURE sp_handle_error_diagnostic 
(
  IN sql_state text,
  IN errno int,
  IN error_msg text,
  IN log_msg json,
  IN procedure_name varchar(100),
  INOUT result json
) 
BEGIN

  --
  -- Variables
  --
  DECLARE error_detail text DEFAULT NULL;
  DECLARE error_logid int DEFAULT 0;



  --
  -- Default values
  --
  SET sql_state = IFNULL(sql_state, 'N/A');
  SET errno = IFNULL(errno, 'N/A');
  SET error_msg = IFNULL(error_msg, 'N/A');
  SET procedure_name = IFNULL(procedure_name, 'N/A');
  
  IF JSON_VALID(result) = 0 THEN
    SET result = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
  END IF;



  --
  -- Get error info
  --
  SELECT 
    CONCAT('STORED PROC ERROR', 
      ' - PROC: ', procedure_name,
      ' - MYSQL_ERRNO: ', errno, 
      ' - RETURNED_SQLSTATE:', sql_state, 
      ' - MESSAGE_TEXT: ', error_msg)
    INTO error_detail;

  SELECT CONCAT(procedure_name, ' - ', error_msg) 
    INTO error_msg;


  --
  -- Log the error
  --
	INSERT INTO error_log (error_message, error_detail, stack_trace, error_date)
		VALUES (error_msg, error_detail, NULL, NOW());

  SELECT LAST_INSERT_ID()
    INTO error_logid;


  INSERT INTO error_log_trace (error_logid, trace_message, trace_date)
  SELECT 
    error_logid AS 'error_logid',
    jt.msg AS 'trace_message',
    IFNULL(jt.date,NOW()) AS 'trace_date'
  FROM JSON_TABLE(log_msg, '$[*]' COLUMNS(
    msg text PATH '$.msg',
    date datetime PATH '$.date'
  )) jt;  


  
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
