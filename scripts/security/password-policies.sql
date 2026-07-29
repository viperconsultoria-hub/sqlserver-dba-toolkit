/*
Name: SQL Login Password Policies
Description: Reviews SQL authentication logins for policy, expiration, lockout, and password-age signals.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: CONTROL SERVER for complete LOGINPROPERTY results; otherwise metadata may be limited
Usage: Run in master and investigate exceptions with the identity owner.
Notes: Never expose password hashes. Windows and external identity password policy is managed outside SQL Server.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    sl.name AS login_name,
    sl.is_disabled,
    sl.is_policy_checked,
    sl.is_expiration_checked,
    sl.create_date,
    sl.modify_date,
    LOGINPROPERTY(sl.name, 'PasswordLastSetTime') AS password_last_set_time,
    LOGINPROPERTY(sl.name, 'DaysUntilExpiration') AS days_until_expiration,
    LOGINPROPERTY(sl.name, 'IsLocked') AS is_locked,
    LOGINPROPERTY(sl.name, 'BadPasswordCount') AS bad_password_count,
    LOGINPROPERTY(sl.name, 'BadPasswordTime') AS last_bad_password_time
FROM sys.sql_logins AS sl
WHERE sl.name NOT LIKE N'##%##'
ORDER BY sl.is_policy_checked, sl.is_expiration_checked, sl.name;
