--
-- Create a permission
--

DROP PROCEDURE IF EXISTS sp_permissions_write;

DELIMITER $$

CREATE PROCEDURE sp_permissions_write(
  IN name VARCHAR(100), 
  IN description VARCHAR(100), 
  OUT result varchar(5000) -- Json format { msg: "Hello" }
)
BEGIN

  SET result = '{errorId: 123, msg: "success"}';

  DROP TABLE IF EXISTS my_temp_tbl;
  CREATE TEMPORARY TABLE my_temp_tbl(
    name varchar(100)
  );
  
  INSERT INTO my_temp_tbl (name)
  VALUES ('Marlon');

  SELECT * FROM my_temp_tbl mtt;

  set @x = 1;
  SELECT @x;
END
$$

DELIMITER ;
