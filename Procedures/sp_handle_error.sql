--
-- Handle errors from routins. 
-- Will log the error on error tables.
-- and send the result json back to the routin
--
-- CALL sp_handle_error('procedure_name', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_handle_error;
DELIMITER $$
CREATE PROCEDURE sp_handle_error 
(
  IN procedure_name varchar(100),
  OUT result json
) 
BEGIN

  --
  -- variables
  --
  DECLARE error_msg mediumtext DEFAULT '';
  DECLARE error_detail longtext DEFAULT NULL;
  DECLARE error_logid int DEFAULT 0;


  --
  -- get error info
  --
  GET DIAGNOSTICS CONDITION 1 
    @sqlstate = RETURNED_SQLSTATE, 
    @errno = MYSQL_ERRNO,
    @text = MESSAGE_TEXT;

  SELECT 
    CONCAT('STORED PROC ERROR', 
      ' - PROC: ', IFNULL(procedure_name,'N/A'),
      ' - MYSQL_ERRNO: ', @errno, 
      ' - RETURNED_SQLSTATE:', @sqlstate, 
      ' - MESSAGE_TEXT: ', @text)
    INTO error_detail;

  SELECT CONCAT(procedure_name, ' - ', @text) 
    INTO error_msg;


  --
  -- log the error
  --
	INSERT INTO error_log (error_message, error_detail, stack_trace, error_date)
		VALUES (IFNULL(error_msg,''), error_detail, NULL, NOW());

  SELECT LAST_INSERT_ID()
    INTO error_logid;

  CALL sys.table_exists('AppTemplateDb', 'log_message', @table_type);
  IF @table_type != '' THEN
    INSERT INTO error_log_trace (error_logid, trace_message, trace_date)
      SELECT 
        error_logid,
        lm.log_msg,
        lm.log_date
      FROM log_message lm;    
  END IF;

  

  --
  -- send error info back
  --
  SELECT JSON_SET(result, 
      '$.success', FALSE, 
      '$.msg', error_msg, 
      '$.errorLogId', error_logid, 
      '$.recordCount', 0)
    INTO result;

END
$$

DELIMITER ;
