/*
Name: Database Certificates
Description: Inventories database certificates, validity, private-key encryption, and last private-key backup date.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DEFINITION
Usage: Run in master and databases that contain operational certificates.
Notes: Metadata does not prove that certificate and private-key backups are accessible or restorable; test the documented process.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME() AS database_name,
    c.name AS certificate_name,
    c.subject,
    c.issuer_name,
    c.start_date,
    c.expiry_date,
    DATEDIFF(DAY, CAST(GETDATE() AS date), c.expiry_date) AS days_until_expiry,
    c.pvt_key_encryption_type_desc,
    c.last_backup_date,
    c.thumbprint
FROM sys.certificates AS c
WHERE c.name NOT LIKE N'##%##'
ORDER BY c.expiry_date, c.name;
