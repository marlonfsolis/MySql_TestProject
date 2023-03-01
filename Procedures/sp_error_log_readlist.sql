--
-- Created on: 8/27/2022 
-- Description: Get a list of errors and the associated log trace records.
--
-- CALL sp_error_log_readlist(0, 10, '{"errorLogId":1}', '{"errorMsg":"%"}');
-- SELECT @Out_Param;
-- 

DROP PROCEDURE IF EXISTS sp_error_log_readlist;
DELIMITER $$
CREATE PROCEDURE sp_error_log_readlist
(
  IN offset_rows int,
  IN fetch_rows int,
  IN filterJson json,
  IN searchJson json
) 
BEGIN

  --
  -- Variables
  --

  -- filters
  DECLARE error_log_id_filter int;
  -- searchs
  DECLARE errormsg_search varchar(1000);


  --
  -- Temp tables
  --
  DROP TABLE IF EXISTS errors__sp_error_log_readlist;
  CREATE TEMPORARY TABLE errors__sp_error_log_readlist(
    error_logid int,
    message text
  );



  --
  -- Default values
  --
  SET offset_rows = IFNULL(offset_rows, 0);
  SET fetch_rows = IFNULL(fetch_rows, 10);
  
  IF fetch_rows = 0 THEN
    SELECT
      COUNT(1) INTO fetch_rows
    FROM error_log el;
  END IF;  
  IF JSON_VALID(filterJson) = 0 THEN
    SET filterJson = '{}';
  END IF;
  IF JSON_VALID(searchJson) = 0 THEN
    SET searchJson = '{}';
  END IF;



  --
  -- Get filter values
  --
  SELECT JSON_VALUE (filterJson, '$.errorLogId') INTO error_log_id_filter;


  --
  -- Get search values
  --
  SELECT JSON_VALUE (searchJson, '$.errorMsg') INTO errormsg_search;



  -- 
  -- Get errors result
  --
  INSERT INTO errors__sp_error_log_readlist (error_logid, message)
  SELECT
    el.error_logid,
    el.message
  FROM error_log el
  
  -- filter
  WHERE (error_log_id_filter IS NULL OR el.error_logid = error_log_id_filter)

  -- search
  AND (errormsg_search IS NULL OR errormsg_search LIKE el.message)
  
  ORDER BY el.error_date DESC
  LIMIT fetch_rows OFFSET offset_rows;



  --
  -- Get error log result
  --
  SELECT
    el.error_logid,
    el.message,
    el.detail,
    el.stack_trace,
    el.error_date
  FROM error_log el
  INNER JOIN errors__sp_error_log_readlist err
    ON el.error_log_id = err.error_logid;


  --
  -- Get error log trace result
  --
  SELECT
    elt.error_log_trace_id,
    elt.error_logid,
    elt.message,
    elt.trace_date
  FROM error_log_trace elt
  WHERE EXISTS (
    SELECT * FROM errors__sp_error_log_readlist errs WHERE errs.error_logid = elt.error_logid
  );


END
$$

DELIMITER ;
