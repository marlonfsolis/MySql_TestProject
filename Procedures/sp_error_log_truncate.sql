
DROP PROCEDURE IF EXISTS sp_error_log_truncate;

DELIMITER $$

CREATE PROCEDURE sp_error_log_truncate()
CONTAINS SQL
BEGIN
  
  --
  -- Truncate traces
  --
  TRUNCATE error_log_trace;


  --
  -- Drop foreign key
  --
  ALTER TABLE error_log_trace
    DROP CONSTRAINT FK_error_log_trace_IndexName_IndexColName;


  --
  -- Truncate errors
  --
  TRUNCATE error_log;
  
  

  --
  -- Create foreign key
  --
  ALTER TABLE error_log_trace
  ADD CONSTRAINT FK_ErrorLogTrace_ErrorLog_ErrorLogid FOREIGN KEY (error_logid)
  REFERENCES error_log (error_logid) ON DELETE RESTRICT ON UPDATE RESTRICT;



END
$$

DELIMITER ;
