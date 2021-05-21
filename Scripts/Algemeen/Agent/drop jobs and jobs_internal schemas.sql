SELECT   'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
         + ' DROP CONSTRAINT ' + QUOTENAME(name)
FROM     sys.foreign_keys
WHERE    schema_id IN ( SCHEMA_ID('jobs'), SCHEMA_ID('jobs_internal'))
ORDER BY CASE schema_id
             WHEN SCHEMA_ID('jobs') THEN
                 1
             ELSE
                 2
         END ASC;

SELECT   'DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)
FROM     sys.views
WHERE    schema_id IN ( SCHEMA_ID('jobs'), SCHEMA_ID('jobs_internal'))
ORDER BY CASE schema_id
             WHEN SCHEMA_ID('jobs') THEN
                 1
             ELSE
                 2
         END ASC;

SELECT   'DROP TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)
FROM     sys.tables
WHERE    schema_id IN ( SCHEMA_ID('jobs'), SCHEMA_ID('jobs_internal'))
ORDER BY CASE schema_id
             WHEN SCHEMA_ID('jobs') THEN
                 1
             ELSE
                 2
         END ASC;

SELECT   'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)
FROM     sys.procedures
WHERE    schema_id IN ( SCHEMA_ID('jobs'), SCHEMA_ID('jobs_internal'))
ORDER BY CASE schema_id
             WHEN SCHEMA_ID('jobs') THEN
                 1
             ELSE
                 2
         END ASC;

SELECT     'DROP ' + o.type_desc COLLATE DATABASE_DEFAULT + ' ' + QUOTENAME(SCHEMA_NAME(o.schema_id)) + '.'
           + QUOTENAME(o.name COLLATE DATABASE_DEFAULT)
FROM       sys.sql_modules AS m
INNER JOIN sys.objects AS o
    ON m.object_id = o.object_id
WHERE      o.schema_id IN ( SCHEMA_ID('jobs'), SCHEMA_ID('jobs_internal'))
ORDER BY   CASE o.schema_id
               WHEN SCHEMA_ID('jobs') THEN
                   1
               ELSE
                   2
           END ASC;

SELECT   'DROP TYPE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)
FROM     sys.types
WHERE    schema_id IN ( SCHEMA_ID('jobs'), SCHEMA_ID('jobs_internal'))
ORDER BY CASE schema_id
             WHEN SCHEMA_ID('jobs') THEN
                 1
             ELSE
                 2
         END ASC;

SELECT   'DROP SCHEMA ' + QUOTENAME(name)
FROM     sys.schemas
WHERE    schema_id IN ( SCHEMA_ID('jobs'), SCHEMA_ID('jobs_internal'))
ORDER BY CASE schema_id
             WHEN SCHEMA_ID('jobs') THEN
                 1
             ELSE
                 2
         END ASC;
