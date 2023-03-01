DROP PROCEDURE IF EXISTS sp_tran_test1;
DELIMITER $$
CREATE PROCEDURE sp_tran_test1
(
  OUT error_code int 
)
CONTAINS SQL
BEGIN

  DECLARE throwerror int DEFAULT 0;
  DECLARE within_tran bool DEFAULT FALSE;
  DECLARE procedure_name text DEFAULT 'sp_tran_test1';

  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    GET DIAGNOSTICS @cno = NUMBER;
    GET CURRENT DIAGNOSTICS CONDITION @cno
      @sqlstate = RETURNED_SQLSTATE, 
      @errno = MYSQL_ERRNO,
      @text = MESSAGE_TEXT;
    SELECT @sqlstate, @errno, @text;    


    SET error_code = 1;
   
    IF within_tran THEN
      ROLLBACK TO SAVEPOINT sp_tran_test1;
    ELSE
       ROLLBACK; 
    END IF;

  END;

  --
  -- default values
  --
  CALL sp_within_transaction(within_tran);
  SELECT within_tran;
  

  --
  -- Start Tran or Savepoint
  --
  IF within_tran THEN
    SAVEPOINT sp_tran_test1;
    SELECT 'SAVEPOINT sp_tran_test1';
  ELSE 
    START TRANSACTION;
    SELECT 'START TRANSACTION';
  END IF;
  


  --
  -- Call to proc
  --
  CALL sp_tran_test1_2(FALSE, error_code);

  -- Here we do not rolled bac yet. We should have values
--   CALL sp_permission_readlist(0, 0, NULL, NULL, @result);
  

  -- Handle error
  IF error_code > 0 THEN
    SELECT 'ERROR: sp_tran_test1_2';
    
    SIGNAL SQLSTATE '12345' 
      SET MESSAGE_TEXT = 'ERROR: sp_tran_test1_2';    

  END IF;

  -- Error
--   SET throwerror = 1/0;

  -- Commit
  IF within_tran THEN
    COMMIT;
  END IF;

  -- Send success
  SET error_code = 0;

END
$$
DELIMITER ;


