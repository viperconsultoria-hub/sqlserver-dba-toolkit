/*
Name: Reorganize Indexes
Description: Generates and optionally executes index reorganize commands for a bounded fragmentation range.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: ALTER on target tables; VIEW DATABASE STATE
Usage: Run in a target database with @Execute = 0, review, then approve if appropriate.
Notes: Reorganize is online but still consumes resources and log space. It is not automatically preferable to rebuild.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumPages bigint = 1000;
DECLARE @MinimumFragmentation decimal(5, 2) = 10.0;
DECLARE @MaximumFragmentation decimal(5, 2) = 30.0;
DECLARE @Execute bit = 0;

DECLARE @commands TABLE (command_id int IDENTITY (1, 1), command_text nvarchar(max));
INSERT @commands (command_text)
SELECT
    N'ALTER INDEX ' + QUOTENAME(i.name)
    + N' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + N'.' + QUOTENAME(OBJECT_NAME(i.object_id))
    + N' REORGANIZE;'
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.index_level = 0
  AND ips.page_count >= @MinimumPages
  AND ips.avg_fragmentation_in_percent >= @MinimumFragmentation
  AND ips.avg_fragmentation_in_percent < @MaximumFragmentation
  AND i.index_id > 0
  AND i.is_disabled = 0;

SELECT command_id, command_text AS preview_command FROM @commands ORDER BY command_id;

IF @Execute = 1
BEGIN
    DECLARE @id int = 1, @max_id int = (SELECT MAX(command_id) FROM @commands), @command nvarchar(max);
    WHILE @id <= COALESCE(@max_id, 0)
    BEGIN
        SELECT @command = command_text FROM @commands WHERE command_id = @id;
        EXEC sys.sp_executesql @command;
        SET @id += 1;
    END;
END;
