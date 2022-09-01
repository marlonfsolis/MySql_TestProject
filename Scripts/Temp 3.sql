--
-- Transactions with SavePoint
-- ---------------------------------------------------------------------------------------------------------------------------------
--


DROP PROCEDURE IF EXISTS sp_tran_test2;
DELIMITER $$
CREATE PROCEDURE sp_tran_test2
(

)
CONTAINS SQL
BEGIN

  DECLARE procedure_name varchar(100) DEFAULT 'sp_tran_test2';
  DECLARE error_code int DEFAULT 0;
  DECLARE within_tran bool;
  DECLARE throwerror int DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    GET DIAGNOSTICS @cno = NUMBER;
    GET CURRENT DIAGNOSTICS CONDITION @cno
      @sqlstate = RETURNED_SQLSTATE, 
      @errno = MYSQL_ERRNO,
      @text = MESSAGE_TEXT;
    SELECT @sqlstate, @errno, @text;    

    
    IF within_tran THEN
      ROLLBACK TO sp_tran_test2;
    ELSE
      ROLLBACK;
    END IF;

  END;


  --
  -- Check if transaction exist
  --
  CALL sp_is_in_transaction(within_tran);


  --
  -- Create transaction or savepoint
  --
  IF within_tran THEN
    SAVEPOINT sp_tran_test2;
    SELECT 'Save point added - sp_tran_test2';
  ELSE
    START TRANSACTION;
    SELECT 'Transacton started - sp_tran_test2';
  END IF;


  CALL sp_tran_test3(error_code);
        
--   SET throwerror = 1/0;

  CALL sp_permissions_readlist(0,0,NULL,NULL,@result);


  IF NOT within_tran THEN
    COMMIT;
    SELECT 'Commited - sp_tran_test3';
  END IF;

END
$$
DELIMITER ;



--
-- sp_tran_test3
-- ---------------------------------------------------------------------------------------------------------------------------------
--



DROP PROCEDURE IF EXISTS sp_tran_test3;
DELIMITER $$
CREATE PROCEDURE sp_tran_test3
(
  OUT error_code int
)
CONTAINS SQL
BEGIN

  DECLARE procedure_name varchar(100) DEFAULT 'sp_tran_test3';
  DECLARE result json DEFAULT JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0, 'recordCount', 0);
  DECLARE within_tran bool;
  DECLARE throwerror int DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    GET DIAGNOSTICS @cno = NUMBER;
    GET CURRENT DIAGNOSTICS CONDITION @cno
      @sqlstate = RETURNED_SQLSTATE, 
      @errno = MYSQL_ERRNO,
      @text = MESSAGE_TEXT;
    SELECT @sqlstate, @errno, @text;    

    SET error_code = 10;

    IF within_tran THEN
      ROLLBACK TO sp_tran_test3;
    ELSE
      ROLLBACK;
    END IF;

  END;


  --
  -- Check if transaction exist
  --
  CALL sp_is_in_transaction(within_tran);


  --
  -- Create transaction or savepoint
  --
  IF within_tran THEN
    SAVEPOINT sp_tran_test3;
    SELECT 'Save point added - sp_tran_test3';
  ELSE
    START TRANSACTION;
    SELECT 'Transacton started - sp_tran_test3';
  END IF;

  


  INSERT INTO permissions
    SET name = 'Permission6',
        description = 'Permission 6';



--   INSERT INTO groups_roles
--     SET name = 'Group4',
--         description = 'Group 4';

    
    
--   SET throwerror = 1/0;

  
  IF NOT within_tran THEN
    COMMIT;
    SELECT 'Commited - sp_tran_test3';
  END IF;

  SET error_code = 0;


END
$$
DELIMITER ;