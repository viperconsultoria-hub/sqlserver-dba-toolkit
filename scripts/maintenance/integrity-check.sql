/*
Name: Database Integrity Check
Description: Previews or runs DBCC CHECKDB for the current database with configurable physical-only mode.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: Membership in sysadmin or db_owner for full DBCC CHECKDB coverage
Usage: Run in the target database. @Execute defaults to 0.
Notes: Schedule full checks based on risk and restore-test design. Do not use repair options without current backups and expert review.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @PhysicalOnly bit = 0;
DECLARE @Execute bit = 0;
DECLARE @command nvarchar(max);
SET @command = N'DBCC CHECKDB (' + QUOTENAME(DB_NAME(), '''') + N') WITH NO_INFOMSGS'
    + CASE WHEN @PhysicalOnly = 1 THEN N', PHYSICAL_ONLY' ELSE N'' END + N';';

SELECT @command AS preview_command;

IF @Execute = 1
    EXEC sys.sp_executesql @command;
