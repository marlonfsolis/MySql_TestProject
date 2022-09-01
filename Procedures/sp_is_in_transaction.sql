DROP PROCEDURE IF EXISTS sp_is_in_transaction;
DELIMITER $$
CREATE PROCEDURE sp_is_in_transaction(
OUT is_in_transaction TINYINT
)
BEGIN

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION # 1305
    BEGIN
        SET is_in_transaction = 0 ; # on error realize we are NOT in a transaction
    END;

SET is_in_transaction = 1 ;
SAVEPOINT `savepoint_sp_is_in_transaction`;
ROLLBACK TO SAVEPOINT `savepoint_sp_is_in_transaction`;

END $$
DELIMITER ;