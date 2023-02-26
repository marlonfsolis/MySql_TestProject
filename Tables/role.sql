--
-- Create table `role`
--
CREATE TABLE role(
  name varchar(100) NOT NULL,
  description varchar(1000),
  
  PRIMARY KEY (name)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;
