/*
Name: Backup Encryption Coverage
Description: Reports recent backup encryption and checksum coverage by database and backup type.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SELECT on msdb backupset
Usage: Run in msdb; adjust @HistoryDays.
Notes: Protect and test recovery of certificates or asymmetric keys separately from encrypted backups.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
DECLARE @HistoryDays int = 30;

SELECT
    bs.database_name,
    CASE bs.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFFERENTIAL' WHEN 'L' THEN 'LOG' ELSE bs.type END
        AS backup_type,
    COUNT_BIG(*) AS backup_count,
    SUM(CASE WHEN bs.encryptor_thumbprint IS NOT NULL THEN 1 ELSE 0 END) AS encrypted_count,
    SUM(CASE WHEN bs.has_backup_checksums = 1 THEN 1 ELSE 0 END) AS checksum_count,
    MAX(bs.backup_finish_date) AS latest_backup,
    MAX(bs.encryptor_type) AS latest_encryptor_type
FROM dbo.backupset AS bs
WHERE bs.backup_finish_date >= DATEADD(DAY, -@HistoryDays, GETDATE())
GROUP BY bs.database_name, bs.type
ORDER BY bs.database_name, backup_type;
