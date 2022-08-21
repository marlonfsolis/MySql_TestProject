--
-- Create table `Users`
--
CREATE TABLE users (
  user_id INT NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(200) NOT NULL,
  last_nName VARCHAR(200) NOT NULL,
  email VARCHAR(500) NOT NULL,
  user_password VARCHAR(1000) DEFAULT NULL,

  PRIMARY KEY (user_id)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;