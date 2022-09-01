
--
-- Proc to run the test
--
DROP PROCEDURE IF EXISTS run_test;
DELIMITER $$
CREATE PROCEDURE run_test()
BEGIN

  DECLARE error_code int DEFAULT 0;

  START TRANSACTION;

  CALL sp_tran_test1(TRUE, error_code);

  CALL sp_permissions_readlist(0, 0, NULL, NULL, @result); -- use TEMPORARY key word to drop temp tables
--   CALL permissions_readlist();

  IF error_code > 0 THEN
    SELECT 'Rolloing back';
    ROLLBACK;
  ELSE
    SELECT 'Committing';
    COMMIT;
  END IF;

  CALL sp_permissions_readlist(0, 0, NULL, NULL, @result);

END
$$
DELIMITER ;




DROP PROCEDURE IF EXISTS permissions_readlist;
DELIMITER $$
CREATE PROCEDURE permissions_readlist()
BEGIN

 SELECT * FROM permissions;

END
$$
DELIMITER ;
