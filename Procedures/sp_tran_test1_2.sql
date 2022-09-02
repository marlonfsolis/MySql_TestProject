--
-- sp_tran_test1_2
-- ---------------------------------------------------------------------------------------------------------------------------------
--
DROP PROCEDURE IF EXISTS sp_tran_test1_2;
DELIMITER $$
CREATE PROCEDURE sp_tran_test1_2
(
  IN auto_commit bool,
  OUT error_code int 
)
CONTAINS SQL
BEGIN

  DECLARE throwerror int DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    GET CURRENT DIAGNOSTICS CONDITION 1
      @sqlstate = RETURNED_SQLSTATE, 
      @errno = MYSQL_ERRNO,
      @text = MESSAGE_TEXT;
    SELECT @sqlstate, @errno, @text;    


    SET error_code = 1;
    
--     IF auto_commit THEN
--       ROLLBACK;
--       SET AUTOCOMMIT = 1;
--     END IF;

  END;

  --
  -- Default values
  --
--   SET AUTOCOMMIT = 0;
  SET auto_commit = IFNULL(auto_commit,TRUE);


  --
  -- Do stuff
  --
  INSERT INTO permissions
    SET name = 'Permission6',
        description = 'Permission 6';  

  -- Error
  SET throwerror = 1/0;

  -- Commit
--   IF auto_commit THEN
--     COMMIT;
--     SET AUTOCOMMIT = 1;
--   END IF;

  -- Send success
  SET error_code = 0;

END
$$
DELIMITER ;

