--
-- Created on: 8/23/2022 
-- Description: Create one permission.
--
-- CALL sp_permission_create('{"name":"Permission1", "description":"Permission 1"}', @result);
-- SELECT @result;
-- 

DROP PROCEDURE IF EXISTS sp_permission_create;
DELIMITER $$
CREATE PROCEDURE sp_permission_create
(
  IN name varchar(100),
  IN description varchar(1000)
) 
BEGIN

  --
  -- Variables
  --



  IF EXISTS (
    SELECT 1 
    FROM permission p 
    WHERE p.name = name
  ) 
  THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = '400|The permission name already exist.';
     
  END IF;



  -- 
  -- Create permission
  --
  INSERT INTO permission
    SET name = name,
        description = description;



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
