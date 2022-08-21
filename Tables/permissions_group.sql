CREATE TABLE permissions_groups(
  permission_name varchar(100),
  group_name varchar(100),
  PRIMARY KEY (permission_name, group_name)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;

ALTER TABLE permissions_groups
  ADD CONSTRAINT FK_permissions_groups_permissions_name FOREIGN KEY (permission_name)
    REFERENCES permissions(name) ON DELETE RESTRICT ON UPDATE RESTRICT;


ALTER TABLE permissions_groups
  ADD CONSTRAINT FK_permissions_groups_groups_name FOREIGN KEY (group_name)
    REFERENCES groups_roles(name) ON DELETE RESTRICT ON UPDATE RESTRICT;
