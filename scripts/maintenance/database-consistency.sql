/*
Name: Database Consistency Status
Description: Inventories database state, page verification, suspect pages, and last known clean CHECKDB time.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW ANY DATABASE, metadata visibility, and SELECT on msdb suspect_pages
Usage: Run from master for fleet-level consistency posture.
Notes: Last known clean time is metadata, not proof that a current check would succeed.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    d.name AS database_name,
    d.state_desc,
    d.user_access_desc,
    d.page_verify_option_desc,
    d.is_read_only,
    DATABASEPROPERTYEX(d.name, 'LastGoodCheckDbTime') AS last_good_checkdb_time,
    DATEDIFF(DAY, CONVERT(datetime, DATABASEPROPERTYEX(d.name, 'LastGoodCheckDbTime')), GETDATE())
        AS days_since_clean_check,
    COALESCE(sp.suspect_page_count, 0) AS suspect_page_count
FROM sys.databases AS d
LEFT JOIN (
    SELECT database_id, COUNT_BIG(*) AS suspect_page_count
    FROM msdb.dbo.suspect_pages
    WHERE event_type IN (1, 2, 3)
    GROUP BY database_id
) AS sp ON sp.database_id = d.database_id
WHERE d.source_database_id IS NULL
ORDER BY CASE d.state_desc WHEN N'ONLINE' THEN 1 ELSE 0 END, days_since_clean_check DESC;
