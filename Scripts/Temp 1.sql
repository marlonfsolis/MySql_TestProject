-- USE AppTemplateDb;
-- 
-- 
-- SELECT * FROM permissions p;
-- SELECT * FROM groups_roles gr;
-- SELECT * FROM permissions_groups pg;


--
-- FOUND_ROWS() - Row Number returned by last select statement
-- Do not use it. Wil be deprecated
-- https://dev.mysql.com/doc/refman/8.0/en/information-functions.html#function_found-rows
-- Use temp table and then count the rows on it.
--
-- SELECT * FROM permissions p;
-- SELECT
--   FOUND_ROWS();

--
-- ROW_COUNT() - Row number affected by the last update
--
-- UPDATE permissions p SET p.description = CONCAT(p.description, '_');
-- UPDATE permissions p SET p.description = REPLACE(p.description,'_','');
-- SELECT 
--   ROW_COUNT();



-- 
-- DELETE 
--   FROM permissions
-- WHERE permission_id = -1
-- ;
-- 


-- 
-- INSERT LOW_PRIORITY IGNORE INTO permissions (name, description)
--   SELECT
--     'Permission1' AS name,
--     'Permission 1' AS description
-- 
--   UNION
-- 
--   SELECT
--     'Permission2' AS name,
--     'Permission 2' AS description
-- 
-- ;
-- 
-- 
-- INSERT INTO permissions (name, description)
--   VALUES ('Permission3', 'Permission 3')
-- ;

-- INSERT DELAYED INTO permissions
--   SET name = 'String1',
--       description = 'description';
-- SELECT * FROM permissions p;
-- DELETE FROM permissions WHERE name = 'String1';



-- 
-- 
-- -- Updating
--
-- UPDATE permissions p 
-- SET name = 'Edit Permissions',
--     description = 'Can edit permissions.'
-- WHERE permission_id = 6
-- ;
-- SELECT * FROM permissions p;
-- 
-- 
-- 
-- Throw error
-- 
-- SIGNAL SQLSTATE '22000' 
--   SET MESSAGE_TEXT = 'This is an error now!'
-- ; 
-- 


-- 
-- Creating Temp Tables
--
-- DROP TABLE IF EXISTS my_temp_tbl CASCADE;
-- CREATE TEMPORARY TABLE my_temp_tbl(name varchar(100));
-- CREATE TEMPORARY TABLE my_temp_tbl SELECT * FROM permissions p LIMIT 0;
-- DESCRIBE my_temp_tbl;
-- SELECT * FROM my_temp_tbl mtt;
-- SELECT * FROM permissions p;
-- SELECT * FROM permissions_groups pg;
-- 
-- 
-- 
-- INSERT INTO permissions_groups (permission_name, group_name)
--   VALUES ('Permission1', 'Group1')
-- ;
-- 
-- DELETE
--   FROM permissions_groups
-- WHERE permission_name = 'Permission1'
--   AND group_name = 'Group1'
-- LIMIT 1
-- ;


/* Rank */
-- 
-- SELECT *
--   FROM permissions_groups pg
-- WHERE pg.permission_name = 'Permission1'
--   AND pg.group_name = 'Group1'
-- ;
-- 
-- SELECT
--   pg.permission_name,
--   pg.group_name,
--   RANK() OVER (PARTITION BY
--     pg.permission_name,
--     pg.group_name) AS rank_num
-- 
-- FROM permissions_groups pg
-- ;

-- SELECT
--   pg.permission_name,
--   pg.group_name,
--   RANK() OVER (ORDER BY pg.permission_name) AS rank_num
-- FROM permissions_groups pg
-- ;



--
-- Stored procedure call
--
-- CALL sp_permissions_write('Permission4','Permission 4', @result);
-- SELECT @result;
-- SELECT * FROM my_temp_tbl mtt;



--
-- JSON playing
--

-- set @myjson = NULL;
-- -- Assing a json to a var. What var get is a string. Vars cannot be of type json.
-- -- set @myjson = JSON_INSERT('{}', '$.name', TRUE);
-- -- or
-- set @myjson = JSON_OBJECT('success', TRUE, 'msg', '', 'errorLogId', 0);
-- SELECT @myjson;
-- SET @j = '{}';
-- SELECT JSON_VALUE(@j, '$.name');
-- SET @j = '{"name":"Marlon", "age":38}';
-- SELECT JSON_EXTRACT(@j,'$.name', '$.age');
-- SELECT JSON_VALUE(@j,'$.name') AS 'Name', JSON_VALUE(@j,'$.age') AS 'Age';
-- 
-- -- Update or set a properties on json object
-- SELECT JSON_SET(@myjson, '$.msg', 'Message 1', '$.errorLogId', 1) INTO @myjson; 
-- SELECT @myjson;
-- -- or
-- SELECT JSON_REPLACE(@myjson, '$.msg', 'Message 2', '$.errorLogId', 2) INTO @myjson;
-- SELECT @myjson;

-- SELECT JSON_VALID(IFNULL(NULL, ''));
-- set @isjson = JSON_VALID(IFNULL(NULL, ''));


-- SET @log_msg = '[]';
-- SET @log_msg = JSON_ARRAY();
-- SELECT JSON_MERGE_PRESERVE(@log_msg, '{"name":"Marlon"}') INTO @log_msg;
-- SELECT JSON_MERGE_PRESERVE(@log_msg, '{"name":"Yenni"}') INTO @log_msg;
-- -- SELECT @log_msg;
-- -- SELECT JSON_LENGTH(@log_msg);
-- -- -- Can specify the default value ON EMPTY (PATH not found) and ON ERROR (Path parse error)
-- SELECT * 
-- FROM JSON_TABLE(@log_msg, '$[*]' COLUMNS(
--     rowid FOR ORDINALITY,
--     name text PATH '$.name'
--     ) 
--   ) AS jt;

-- SET @j = '{"group":"Group1", "permissions":["Permission1", "Permission2", "Permission3"]}';
-- SET @arr = JSON_VALUE(@j,'$.permissions');
-- SELECT * 
-- FROM JSON_TABLE(@arr, '$[*]' COLUMNS(
--      permission varchar(100) PATH '$'
--     ) 
--   ) AS jt;

-- SELECT *
--      FROM
--        JSON_TABLE(
--          '[ {"a": 1, "b": [11,111]}, {"a": 2, "b": [22,222]}, {"a":3}]',
--          '$[*]' COLUMNS(
--                  a INT PATH '$.a',
--                  NESTED PATH '$.b[*]' COLUMNS (b INT PATH '$')
--                 )
--         ) AS jt;


--
-- IF ELSE
-- Only allowed on procedures and functions
-- IF 1 = 1 THEN SET @isjson = '{}'; END IF;
--
-- set @j = '';
-- set @j = (SELECT '{}' WHERE JSON_VALID(@j) = 0);
-- SELECT @j;
--
-- or just create a temp procedure and then drop it after finish
--
-- DROP PROCEDURE IF EXISTS script;
-- DELIMITER $$
-- CREATE PROCEDURE script()
-- BEGIN
-- 
--   DECLARE j json DEFAULT '{}';
-- 
--   IF JSON_VALID(j) = 0 THEN
--     set j = '{}';
--   ELSE
--     SET j = '{"msg": "Hello world!"}';
--   END IF;
-- 
--   SELECT j;
-- 
-- END$$
-- DELIMITER ;
-- CALL script();



--
-- Procedures calls
--

-- CALL sp_permissions_delete('Permission4', TRUE, @Out_Param);
-- SELECT @Out_Param;


-- CALL sp_permissions_readlist(0, 0, NULL, NULL, @result);
-- SELECT @result;


-- CALL sp_permissions_read('Permission1', @result);
-- SELECT @result;


-- CALL sp_permissions_write('{"name":"Permission5", "description":"Permission 5"}', @result);
-- SELECT @result;


-- CALL sp_error_log_readlist(0, 10, NULL, NULL);
-- CALL sp_error_log_truncate();


CALL sp_groups_readlist(0, 0, NULL, NULL, @result);
SELECT @result;


CALL sp_groups_read('Group1', @result);
SELECT @result;


CALL sp_groups_write('{"name":"Group3", "description":"Group 3"}', @result);
SELECT @result;


CALL sp_groups_delete('Group3', @result);
SELECT @result;


CALL sp_groups_readlist(0, 0, NULL, NULL, @result);
CALL sp_permissions_readlist(0, 0, NULL, NULL, @result);
SELECT pg.group_name,pg.permission_name FROM permissions_groups pg;
DELETE FROM permissions_groups WHERE group_name = 'Group3';

CALL sp_permissions_group_write('{"group":"Group3", "permissions":["Permission3", "Permission4", "Permission5"]}', @result);
SELECT @result;

CALL sp_permissions_group_delete('{"group":"Group3", "permissions":["Permission3", "Permission4"]}', @result);
CALL sp_permissions_group_delete('{"group":"Group3", "permissions":["Permission3", "Permission4", "Permission5"]}', @result);
SELECT @result;

CALL sp_permissions_group_readlist(0, 10, 
   '{"group_name":"Group1", "permission_name":null}', 
   '{"group_name":null, "permission_name":null}', @result);
SELECT @result;




-- SELECT * FROM error_log el ORDER BY el.error_detail DESC;
-- SELECT * FROM error_log_trace elt ORDER BY elt.trace_date DESC;
-- CALL sp_error_log_readlist(0, 1, NULL, NULL);
-- CALL sp_error_log_truncate();


--
-- Transaction testing
--
-- CALL sp_tran_test(TRUE);
-- CALL sp_temptable_test_1();


-- SET AUTOCOMMIT = 1;
-- SET AUTOCOMMIT = 0;
-- SELECT @@autocommit;

-- COMMIT;
-- ROLLBACK;


-- START TRANSACTION;
-- CALL sp_within_transaction(@within_tran);
-- SELECT @within_tran;
-- COMMIT;


-- CALL sp_tran_test1(@error_code);
-- 
-- CALL sp_permissions_readlist(0, 0, NULL, NULL, @result);
-- SELECT @result;
-- 
-- CALL sp_permissions_delete('Permission6', TRUE, @Out_Param);
-- SELECT @Out_Param;
-- 
-- 
-- CALL run_test();


