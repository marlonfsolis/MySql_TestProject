--
-- Proc 1 that have temp_table
--
DROP PROCEDURE IF EXISTS sp_temptable_test_1;
DELIMITER $$
CREATE PROCEDURE sp_temptable_test_1
(

)
CONTAINS SQL
BEGIN

  DECLARE throwerror int DEFAULT 0;


  DROP TABLE IF EXISTS temp_table CASCADE;
  CREATE TEMPORARY TABLE temp_table(
    message text,
    date datetime
  );
  
  INSERT INTO temp_table (message, date) VALUES ('Message 1 on 1', NOW());


  CALL sp_temptable_test_2();
    

  INSERT INTO temp_table (message, date) VALUES ('Message 2 on 1', NOW());
    
--  SET throwerror = 1/0;

  SELECT * FROM temp_table;

END
$$
DELIMITER ;


--
-- Proc 2 that have temp_table too
--
DROP PROCEDURE IF EXISTS sp_temptable_test_2;
DELIMITER $$
CREATE PROCEDURE sp_temptable_test_2
(

)
CONTAINS SQL
BEGIN

  DECLARE throwerror int DEFAULT 0;


  DROP TABLE IF EXISTS temp_table CASCADE;
  CREATE TEMPORARY TABLE temp_table(
    message text,
    date datetime
  );
  
  INSERT INTO temp_table (message, date) VALUES ('Message 1 on 2', NOW());
      
--  SET throwerror = 1/0;

  INSERT INTO temp_table (message, date) VALUES ('Message 2 on 2', NOW());


END
$$
DELIMITER ;


