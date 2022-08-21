--
-- Create table `error_log_trace`
--
CREATE TABLE error_log_trace (
  error_log_traceid INT NOT NULL AUTO_INCREMENT,
  error_logid int NOT NULL,
  trace_message longtext NULL,
  trace_date datetime NOT NULL,
  
  PRIMARY KEY (error_log_traceid)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;


ALTER TABLE error_log_trace
  ADD CONSTRAINT FK_ErrorLogTrace_ErrorLog_ErrorLogid FOREIGN KEY (error_logid)
    REFERENCES error_log(error_logid) ON DELETE CASCADE ON UPDATE CASCADE;


