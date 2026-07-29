/*
Name: Azure SQL Database Size
Description: Reports allocated, used, free-inside-file, and configured maximum storage for the current database.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: Azure SQL Database, Azure SQL Managed Instance, SQL Server 2016+
Permissions: VIEW DATABASE STATE
Usage: Run in the target database and retain snapshots for growth forecasting.
Notes: Allocated database files and billed or service-tier storage are related but not identical concepts.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME() AS database_name,
    SUM(CASE WHEN df.type_desc = N'ROWS' THEN df.size ELSE 0 END) * 8.0 / 1024 AS allocated_data_mb,
    SUM(CASE WHEN df.type_desc = N'ROWS' THEN FILEPROPERTY(df.name, 'SpaceUsed') ELSE 0 END)
        * 8.0 / 1024 AS used_data_mb,
    SUM(CASE WHEN df.type_desc = N'ROWS' THEN df.size - FILEPROPERTY(df.name, 'SpaceUsed') ELSE 0 END)
        * 8.0 / 1024 AS free_inside_data_files_mb,
    SUM(CASE WHEN df.type_desc = N'LOG' THEN df.size ELSE 0 END) * 8.0 / 1024 AS allocated_log_mb,
    CONVERT(decimal(19, 2), DATABASEPROPERTYEX(DB_NAME(), 'MaxSizeInBytes')) / 1024 / 1024 AS maximum_size_mb
FROM sys.database_files AS df;
