/*
Name: Verify Backup Template
Description: Generates or optionally runs RESTORE VERIFYONLY with CHECKSUM for one backup file.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: CREATE DATABASE permission may be required by RESTORE VERIFYONLY; access to backup media
Usage: Set @BackupPath. Leave @Execute = 0 to preview.
Notes: VERIFYONLY is not a restore test and does not validate application consistency or every restore scenario.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @BackupPath nvarchar(4000) = N'C:\Backups\ReplaceMe.bak';
DECLARE @Execute bit = 0;
DECLARE @command nvarchar(max);

IF @BackupPath LIKE N'%ReplaceMe%'
    THROW 50000, 'Set @BackupPath to an approved backup file.', 1;

SET @command = N'RESTORE VERIFYONLY FROM DISK = @Path WITH CHECKSUM;';
SELECT N'RESTORE VERIFYONLY FROM DISK = N'''
    + REPLACE(@BackupPath, '''', '''''') + N''' WITH CHECKSUM;' AS preview_command;

IF @Execute = 1
    EXEC sys.sp_executesql @command, N'@Path nvarchar(4000)', @Path = @BackupPath;
