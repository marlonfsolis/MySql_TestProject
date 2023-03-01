--
-- Create table `permission_role`
--
CREATE TABLE permission_role(
  permission_name varchar(100),
  role_name varchar(100),
  
  PRIMARY KEY (permission_name, role_name)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;

ALTER TABLE permission_role
  ADD CONSTRAINT FK_PermissionRole_Permission_Name FOREIGN KEY (permission_name)
    REFERENCES permission(name) ON DELETE RESTRICT ON UPDATE RESTRICT;


ALTER TABLE permission_role
  ADD CONSTRAINT FK_PermissionRole_Group_Name FOREIGN KEY (role_name)
    REFERENCES role(name) ON DELETE RESTRICT ON UPDATE RESTRICT;
