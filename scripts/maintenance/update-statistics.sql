/*
Name: Update Statistics
Description: Generates and optionally executes targeted UPDATE STATISTICS commands based on modification count and age.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: ALTER on target tables and metadata visibility
Usage: Run in a target database. Tune thresholds and keep @Execute = 0 until reviewed.
Notes: Statistics updates compile plans and consume CPU/I/O. Sampling strategy should reflect table size and workload.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumModifications bigint = 1000;
DECLARE @MinimumAgeHours int = 24;
DECLARE @FullScan bit = 0;
DECLARE @Execute bit = 0;

DECLARE @commands TABLE (command_id int IDENTITY (1, 1), command_text nvarchar(max));
INSERT @commands (command_text)
SELECT
    N'UPDATE STATISTICS ' + QUOTENAME(OBJECT_SCHEMA_NAME(s.object_id)) + N'.'
    + QUOTENAME(OBJECT_NAME(s.object_id)) + N' ' + QUOTENAME(s.name)
    + CASE WHEN @FullScan = 1 THEN N' WITH FULLSCAN;' ELSE N';' END
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
WHERE sp.modification_counter >= @MinimumModifications
  AND (sp.last_updated IS NULL OR sp.last_updated < DATEADD(HOUR, -@MinimumAgeHours, SYSDATETIME()));

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
