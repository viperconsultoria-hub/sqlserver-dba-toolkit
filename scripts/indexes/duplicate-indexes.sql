/*
Name: Duplicate Indexes
Description: Finds indexes whose ordered key and included-column definitions are identical.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2017+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DATABASE STATE and metadata visibility
Usage: Run in the target user database.
Notes: Identical definitions can still differ by filter, uniqueness, constraints, options, or workload value. Review before removal.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH index_definitions AS (
    SELECT
        i.object_id,
        i.index_id,
        i.name AS index_name,
        i.is_unique,
        i.has_filter,
        i.filter_definition,
        STRING_AGG(CASE WHEN ic.is_included_column = 0
            THEN QUOTENAME(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END END, ',')
            WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_columns,
        STRING_AGG(CASE WHEN ic.is_included_column = 1 THEN QUOTENAME(c.name) END, ',')
            WITHIN GROUP (ORDER BY c.column_id) AS included_columns
    FROM sys.indexes AS i
    INNER JOIN sys.index_columns AS ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    INNER JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE i.index_id > 0
      AND i.is_hypothetical = 0
    GROUP BY i.object_id, i.index_id, i.name, i.is_unique, i.has_filter, i.filter_definition
)
SELECT
    OBJECT_SCHEMA_NAME(a.object_id) AS schema_name,
    OBJECT_NAME(a.object_id) AS table_name,
    a.index_name AS index_name_1,
    b.index_name AS index_name_2,
    a.key_columns,
    a.included_columns,
    a.is_unique,
    a.filter_definition
FROM index_definitions AS a
INNER JOIN index_definitions AS b
    ON b.object_id = a.object_id
    AND b.index_id > a.index_id
    AND ISNULL(b.key_columns, '') = ISNULL(a.key_columns, '')
    AND ISNULL(b.included_columns, '') = ISNULL(a.included_columns, '')
    AND b.is_unique = a.is_unique
    AND b.has_filter = a.has_filter
    AND ISNULL(b.filter_definition, '') = ISNULL(a.filter_definition, '')
ORDER BY schema_name, table_name, index_name_1;
