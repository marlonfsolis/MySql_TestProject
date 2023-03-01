--
-- Created on: 8/24/2022 
-- Description: Delete one permission by name.
--
-- CALL sp_permission_delete('Permission1');
-- 

DROP PROCEDURE IF EXISTS sp_permission_delete;
DELIMITER $$
CREATE PROCEDURE sp_permission_delete
(
  IN name varchar(100)
) 
BEGIN

  --
  -- Temp tables
  --
  DROP TEMPORARY TABLE IF EXISTS permission_temp;
  CREATE TEMPORARY TABLE permission_temp 
    SELECT * FROM permission LIMIT 0;



  --
  -- Validate input value
  --
  IF IFNULL(name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field name is required.';
  END IF;

  

  -- 
  -- Get record to be deleted
  --
  INSERT INTO permission_temp (name, description)
  SELECT
    name,
    description
  FROM permission p
  WHERE p.name = name;



  --
  -- Delete permission association to groups first
  --
  DELETE
    FROM permission_role pg
  WHERE pg.permission_name = name;


  -- 
  -- Then delete permission
  --
  DELETE
    FROM permission p
    WHERE p.name = name;



  
  --  
  -- Send the response
  --
  SELECT
    p.name,
    p.description
  FROM permission_temp p;

END
$$

DELIMITER ;
