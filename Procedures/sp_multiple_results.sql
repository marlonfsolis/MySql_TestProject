USE AppTemplateDb;

DROP PROCEDURE IF EXISTS sp_multiple_results;

DELIMITER $$

CREATE
DEFINER = 'marlonfsolis'@'%'
PROCEDURE sp_multiple_results ()
BEGIN
  -- First result set
  SELECT
    'Marlon' AS FirstName,
    'Fernandez' AS LasName;

-- Second result set
  SELECT
    '123 Main St' AS Address1,
    'Sarasota' AS City,
    'FL' AS State,
    '34243' AS ZipCode;
END
$$

DELIMITER ;

