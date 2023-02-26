--
-- Create table `error_log_trace`
--
CREATE TABLE error_log_trace (
  error_log_trace_id INT NOT NULL AUTO_INCREMENT,
  error_log_id int NOT NULL,
  message longtext NULL,
  trace_date datetime NOT NULL,
  
  PRIMARY KEY (error_log_trace_id)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;


ALTER TABLE error_log_trace
  ADD CONSTRAINT FK_ErrorLogTrace_ErrorLog_ErrorLogId FOREIGN KEY (error_log_id)
    REFERENCES error_log(error_log_id) ON DELETE CASCADE ON UPDATE CASCADE;


