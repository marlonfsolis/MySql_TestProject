--
-- Create table `error_log_tTrace`
--
CREATE TABLE error_log_trace (
  error_lLog_traceId INT NOT NULL,
  error_log_id VARCHAR(200) NOT NULL,
  trace_message VARCHAR(200) NOT NULL,
  trace_date VARCHAR(500) NOT NULL,
  PRIMARY KEY (error_log_id)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;