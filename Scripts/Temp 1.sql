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

-- CALL sp_permissions_delete('Permission3', @Out_Param);
-- SELECT @Out_Param;


-- CALL sp_permissions_readlist(0, 0, NULL, NULL, @result);
-- SELECT @result;


-- CALL sp_permissions_read('Permission1', @result);
-- SELECT @result;

-- CALL sp_permissions_write('{"name":"Permission4", "description":"Permission 4"}', @Out_Param);
-- SELECT @Out_Param;


-- CALL sp_groups_readlist(0, 0, NULL, NULL, @result);
-- SELECT @result;


CALL sp_groups_read('Group11', @result);
SELECT @result;




-- SELECT * FROM error_log el ORDER BY el.error_detail DESC;
-- SELECT * FROM error_log_trace elt ORDER BY elt.trace_date DESC;
CALL sp_error_log_readlist(0, 10, NULL, NULL);

-- TRUNCATE error_log_trace;
-- DELETE FROM error_log;
CALL sp_error_log_truncate();
