/*
Name: Disabled Logins
Description: Lists disabled server logins with type, dates, default database, and policy state.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: ALTER ANY LOGIN or sufficient metadata visibility
Usage: Run in master as part of identity lifecycle review.
Notes: A disabled login can still own databases, jobs, credentials, or securables; review dependencies before removal.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    sp.name AS login_name,
    sp.type_desc,
    sp.create_date,
    sp.modify_date,
    sp.default_database_name,
    sp.default_language_name,
    sl.is_policy_checked,
    sl.is_expiration_checked,
    LOGINPROPERTY(sp.name, 'PasswordLastSetTime') AS password_last_set_time
FROM sys.server_principals AS sp
LEFT JOIN sys.sql_logins AS sl ON sl.principal_id = sp.principal_id
WHERE sp.is_disabled = 1
  AND sp.name NOT LIKE N'##%##'
ORDER BY sp.modify_date, sp.name;
