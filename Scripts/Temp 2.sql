
--
-- Proc to run the test
--
DROP PROCEDURE IF EXISTS run_test;
DELIMITER $$
CREATE PROCEDURE run_test()
BEGIN

  DECLARE error_code int DEFAULT 0;

  START TRANSACTION;

  CALL sp_tran_test1(error_code);

  -- because we use SAVEPOINT. At this point we have BEEN ROLLED BACK already inside the proc
  -- This have the advantage that we can rollback only the proc with error and continue doint stuff
  CALL sp_permission_readlist(0, 0, NULL, NULL, @result); -- use TEMPORARY key word to drop temp tables

  IF error_code > 0 THEN
    SELECT 'Rolloing back';
    ROLLBACK;
  ELSE
    SELECT 'Committing';
    COMMIT;
  END IF;

  CALL sp_permission_readlist(0, 0, NULL, NULL, @result);

END
$$
DELIMITER ;




DROP PROCEDURE IF EXISTS permissions_readlist;
DELIMITER $$
CREATE PROCEDURE permissions_readlist()
BEGIN

 SELECT * FROM permission;

END
$$
DELIMITER ;
