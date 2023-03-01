--
-- Created on: 8/23/2022 
-- Description: Update one permission.
--
-- CALL sp_permission_update('{"name":"Permission1", "description":"Permission 1"}');
-- 

DROP PROCEDURE IF EXISTS sp_permission_update;
DELIMITER $$
CREATE PROCEDURE sp_permission_update
(
  IN p_name varchar(100),
  IN name varchar(100),
  IN description varchar(1000)
) 
BEGIN

  --
  -- Validate input
  --
  IF IFNULL(p_name,'') = '' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The old permission name is required.';
  END IF;



  -- 
  -- Update permission
  -- 
  UPDATE permission p
    SET p.name = name,
        p.description = description
  WHERE p.name = p_name;



  -- 
  -- Get final result
  --
  SELECT
    name,
    description
  FROM permission p
  WHERE p.name = name;

 
END
$$

DELIMITER ;
