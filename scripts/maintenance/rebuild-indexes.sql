/*
Name: Rebuild Indexes
Description: Generates and optionally executes index rebuild commands above configurable fragmentation and size thresholds.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: ALTER on target tables; VIEW DATABASE STATE
Usage: Run in a target database. Review output with @Execute = 0; set to 1 only in an approved window.
Notes: Rebuilds can consume log, TempDB, CPU, I/O, and blocking time. ONLINE support depends on edition, version, and index type.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumPages bigint = 1000;
DECLARE @MinimumFragmentation decimal(5, 2) = 30.0;
DECLARE @Online bit = 0;
DECLARE @Execute bit = 0;

DECLARE @commands TABLE (command_id int IDENTITY (1, 1), command_text nvarchar(max));
INSERT @commands (command_text)
SELECT
    N'ALTER INDEX ' + QUOTENAME(i.name)
    + N' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + N'.' + QUOTENAME(OBJECT_NAME(i.object_id))
    + N' REBUILD WITH (ONLINE = ' + CASE WHEN @Online = 1 THEN N'ON' ELSE N'OFF' END + N');'
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.index_level = 0
  AND ips.alloc_unit_type_desc = N'IN_ROW_DATA'
  AND ips.page_count >= @MinimumPages
  AND ips.avg_fragmentation_in_percent >= @MinimumFragmentation
  AND i.index_id > 0
  AND i.is_disabled = 0;

SELECT command_id, command_text AS preview_command FROM @commands ORDER BY command_id;

IF @Execute = 1
BEGIN
    DECLARE @id int = 1;
    DECLARE @max_id int = (SELECT MAX(command_id) FROM @commands);
    DECLARE @command nvarchar(max);
    WHILE @id <= COALESCE(@max_id, 0)
    BEGIN
        SELECT @command = command_text FROM @commands WHERE command_id = @id;
        EXEC sys.sp_executesql @command;
        SET @id += 1;
    END;
END;
