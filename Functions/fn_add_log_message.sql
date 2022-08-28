--
-- Add new object/record to the json array pased.
-- This is intended to work with log messages only that are used in procedures.
--

DROP FUNCTION IF EXISTS fn_add_log_message;
DELIMITER $$
CREATE FUNCTION fn_add_log_message 
(
  log_array json,
  msg text
)
RETURNS json
DETERMINISTIC
BEGIN
  IF JSON_VALID(log_array) = 0 THEN
    SET log_array = JSON_ARRAY();
  END IF;

  SELECT
    JSON_MERGE_PRESERVE(
      log_array, 
      JSON_OBJECT('msg', msg, 'date', NOW())
    ) 
    INTO log_array;

  RETURN log_array;
END
$$
DELIMITER ;