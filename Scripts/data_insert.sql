USE AppTemplateDb;

/* Create permissions */
INSERT LOW_PRIORITY IGNORE INTO permissions (name, description)
  VALUES ('Permission1', 'Permission 1'),
         ('Permission2', 'Permission 2'),
         ('Permission3', 'Permission 3')
;


/* Crete groups */
INSERT INTO groups_roles (name, DESCRIPTION)
  VALUES ('Group1', 'Group 1'),
         ('Group2', 'Group 2')
;


/* Create permissions groups */
INSERT INTO permissions_groups (permission_name, group_name)
  VALUES ('Permission1', 'Group1'),
         ('Permission2', 'Group2'),
         ('Permission3', 'Group2')
;
