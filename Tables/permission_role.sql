--
-- Create table `permission_group`
--
CREATE TABLE permission_group(
  permission_name varchar(100),
  group_name varchar(100),
  
  PRIMARY KEY (permission_name, group_name)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;

ALTER TABLE permission_group
  ADD CONSTRAINT FK_PermissionGroup_Permission_Name FOREIGN KEY (permission_name)
    REFERENCES permission(name) ON DELETE RESTRICT ON UPDATE RESTRICT;


ALTER TABLE permission_group
  ADD CONSTRAINT FK_PermissionGroup_Group_Name FOREIGN KEY (group_name)
    REFERENCES role(name) ON DELETE RESTRICT ON UPDATE RESTRICT;
