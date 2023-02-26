--
-- Create table `error_log_trace`
--
CREATE TABLE error_log (
  error_log_id int NOT NULL AUTO_INCREMENT,
  message mediumtext NOT NULL,
  detail longtext NULL,
  stack_trace longtext NULL,
  error_date datetime,
  
  PRIMARY KEY (error_log_id)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;
