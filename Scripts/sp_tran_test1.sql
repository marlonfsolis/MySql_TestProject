DROP PROCEDURE IF EXISTS sp_tran_test1;
DELIMITER $$
CREATE PROCEDURE sp_tran_test1
(
  IN auto_commit bool,
  OUT error_code int 
)
CONTAINS SQL
Proc_Exit:
BEGIN

  DECLARE throwerror int DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    GET DIAGNOSTICS @cno = NUMBER;
    GET CURRENT DIAGNOSTICS CONDITION @cno
      @sqlstate = RETURNED_SQLSTATE, 
      @errno = MYSQL_ERRNO,
      @text = MESSAGE_TEXT;
    SELECT @sqlstate, @errno, @text;    


    SET error_code = 1;
    ROLLBACK TO SAVEPOINT sp_tran_test1;
    
--     IF auto_commit THEN
--       ROLLBACK;
--       SET AUTOCOMMIT = 1;
--     END IF;

  END;

  --
  -- default values
  --
--   SET AUTOCOMMIT = 0;
--   SET auto_commit = IFNULL(auto_commit,TRUE);
  SAVEPOINT sp_tran_test1;


  --
  -- Call to proc
  --
  CALL sp_tran_test1_2(FALSE, error_code);

  -- Here we do not rolled bac yet. We should have values
--   CALL sp_permissions_readlist(0, 0, NULL, NULL, @result);
  

  -- Handle error
  IF error_code > 0 THEN
    SELECT 'ERROR: sp_tran_test1_2';
    
    SIGNAL SQLSTATE '12345' 
      SET MESSAGE_TEXT = 'ERROR: sp_tran_test1_2';    


--     IF auto_commit THEN
--       ROLLBACK;
--       SET AUTOCOMMIT = 1;
--     END IF;
--     LEAVE Proc_Exit;
  END IF;

  -- Error
--   SET throwerror = 1/0;

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


