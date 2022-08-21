--
-- Create table `permissions`
--
CREATE TABLE permissions (
  name VARCHAR(100) NOT NULL,
  description VARCHAR(1000) DEFAULT NULL,
  PRIMARY KEY (name)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;