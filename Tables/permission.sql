--
-- Create table `permission`
--
CREATE TABLE permission (
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) DEFAULT NULL,
  
  PRIMARY KEY (name)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;