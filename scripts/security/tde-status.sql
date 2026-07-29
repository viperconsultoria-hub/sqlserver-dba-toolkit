/*
Name: Transparent Data Encryption Status
Description: Reports TDE state, progress, algorithm, key length, and encryptor thumbprint.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run from master and confirm certificate backup procedures for encrypted databases.
Notes: Azure SQL encryption management differs by platform. Never expose private keys in diagnostic output.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    d.name AS database_name,
    d.state_desc,
    dek.encryption_state,
    CASE dek.encryption_state
        WHEN 0 THEN N'NO DATABASE ENCRYPTION KEY'
        WHEN 1 THEN N'UNENCRYPTED'
        WHEN 2 THEN N'ENCRYPTION IN PROGRESS'
        WHEN 3 THEN N'ENCRYPTED'
        WHEN 4 THEN N'KEY CHANGE IN PROGRESS'
        WHEN 5 THEN N'DECRYPTION IN PROGRESS'
        WHEN 6 THEN N'PROTECTION CHANGE IN PROGRESS'
    END AS encryption_state_desc,
    dek.percent_complete,
    dek.key_algorithm,
    dek.key_length,
    dek.encryptor_type,
    dek.encryptor_thumbprint
FROM sys.databases AS d
LEFT JOIN sys.dm_database_encryption_keys AS dek ON dek.database_id = d.database_id
ORDER BY d.name;
