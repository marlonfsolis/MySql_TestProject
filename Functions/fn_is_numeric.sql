﻿CREATE FUNCTION fn_is_numeric (
  input VARCHAR(255)
)
RETURNS INT DETERMINISTIC
RETURN input REGEXP '^[0-9]+\\.?[0-9]*$';