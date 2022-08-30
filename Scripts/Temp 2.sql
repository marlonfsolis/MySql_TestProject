DROP PROCEDURE IF EXISTS sp_tran_test;
DELIMITER $$
CREATE PROCEDURE sp_tran_test
(
  IN auto_commit bool 
)
CONTAINS SQL
BEGIN

  DECLARE result json DEFAULT JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);

  DECLARE throwerror int DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    GET DIAGNOSTICS @cno = NUMBER;
    GET CURRENT DIAGNOSTICS CONDITION @cno
      @sqlstate = RETURNED_SQLSTATE, 
      @errno = MYSQL_ERRNO,
      @text = MESSAGE_TEXT;
    SELECT @sqlstate, @errno, @text;    

    IF auto_commit THEN
      ROLLBACK;
    END IF;

  END;




  --
  -- default values
  --
  SET auto_commit = IFNULL(auto_commit,TRUE);



--   CALL sp_permissions_write('{"name":"Permission4", "description":"Permission 4"}', TRUE, result);
  CALL sp_permissions_write('{"name":"Permission4", "description":"Permission 4"}', FALSE, result);

--   INSERT INTO permissions
--     SET name = 'Permission4',
--         description = 'Permission 4';



  INSERT INTO groups_roles
    SET name = 'Group4',
        description = 'Group 4';

    
    
  SET throwerror = 1/0;



  IF auto_commit THEN
    COMMIT;
  END IF;

END
$$
DELIMITER ;



--
-- ---------------------------------------------------------------------------------------------------------------------------------
--



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


