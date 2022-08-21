--
-- Create table `error_log_trace`
--
CREATE TABLE error_log (
  error_logid int NOT NULL AUTO_INCREMENT,
  error_message mediumtext NOT NULL,
  error_detail longtext NULL,
  stack_trace longtext NULL,
  error_date datetime,
  
  PRIMARY KEY (error_logid)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;
