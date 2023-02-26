--
-- Determine if there is a transaction open.
--
DROP PROCEDURE IF EXISTS sp_within_transaction;
DELIMITER $$
CREATE PROCEDURE sp_within_transaction (OUT within_transaction bool)
BEGIN

  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION # 1305
  BEGIN
    SET within_transaction = FALSE; # on error realize we are NOT in a transaction
  END;

  SET within_transaction = TRUE;
  SAVEPOINT savepoint_sp_within_transaction;
  ROLLBACK TO SAVEPOINT savepoint_sp_within_transaction;



END$$
DELIMITER ;