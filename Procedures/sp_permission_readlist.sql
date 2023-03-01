--
-- Get permissions list.
-- The list can be filteres and paginated.
--
-- CALL sp_permission_readlist(0, 10, 'Permission1', null, null);
-- CALL sp_permission_readlist(0, 10, null, 'Permi%', null);
-- 

DROP PROCEDURE IF EXISTS sp_permission_readlist;
DELIMITER $$
CREATE PROCEDURE sp_permission_readlist 
(
  IN offset_rows int,
  IN fetchRows int,
  IN name varchar(100),
  IN name_s varchar(200),
  IN description_s varchar(1100)
) 
BEGIN

  --
  -- Variables
  --
  DECLARE _count int DEFAULT 0;
  DECLARE _total_count int DEFAULT 0;

--   SET _count = 1/0;


  --
  -- Temp tables
  --
  # This is a comment
  DROP TEMPORARY TABLE IF EXISTS permissions_temp;
  CREATE TEMPORARY TABLE permissions_temp 
    SELECT * FROM permission p LIMIT 0;



  --
  -- Default values
  --
  SET offset_rows = IFNULL(offset_rows, 0);
  SET fetchRows = IFNULL(fetchRows, 10);
  SET name = IFNULL(name,'');
  SET name_s = IFNULL(name_s,'');
  SET description_s = IFNULL(description_s,'');
  
  IF fetchRows = 0 THEN
    SELECT
      COUNT(1) INTO fetchRows
    FROM permission p;
  END IF;  



  -- 
  -- Get final result
  --
  INSERT INTO permissions_temp (name, description)
  SELECT
    p.name,
    p.description
  FROM permission p
  
  -- filter
  WHERE (name = '' OR p.name = name)

  -- search
  AND (name_s = '' OR p.name LIKE name_s)
  AND (description_s = '' OR p.description LIKE description_s);
  

  
  SELECT COUNT(*) FROM permission p INTO _total_count;
  SELECT COUNT(*) FROM permissions_temp p INTO _count;

  
  -- send metadata
  SELECT _count AS result_count, _total_count AS total_count;


  --  
  -- Send the response
  --
  SELECT
    p.name,
    p.description
  FROM permissions_temp p;


END
$$
DELIMITER ;
