--
-- Get one permission by its ID
--
-- CALL sp_Permission_Read('Permission1');
-- 

DROP PROCEDURE IF EXISTS sp_permission_read;
DELIMITER $$
CREATE PROCEDURE sp_permission_read 
(
  IN name varchar(100)
) 
BEGIN

  --
  -- Validate input value
  --
  IF IFNULL(name,'')='' THEN
    SIGNAL SQLSTATE '12345'
      SET MESSAGE_TEXT = 'The field name is required.';
  END IF;



  -- 
  -- Get final result
  --
  SELECT
    p.name,
    p.description
  FROM permission p
  WHERE p.name = name;


END
$$

DELIMITER ;