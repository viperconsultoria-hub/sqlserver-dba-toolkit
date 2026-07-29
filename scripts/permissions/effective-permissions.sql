/*
Name: Effective Database Permissions
Description: Returns effective database permissions for the current execution context or an impersonated database principal.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: IMPERSONATE on the target principal when @PrincipalName is set
Usage: Set @PrincipalName or leave NULL for the current context.
Notes: Impersonation is database-scoped here. Ownership chains, external groups, and application execution context can change results.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @PrincipalName sysname = NULL;
DECLARE @sql nvarchar(max);

IF @PrincipalName IS NULL
BEGIN
    SELECT
        USER_NAME() AS evaluated_principal,
        permission_name,
        subentity_name
    FROM sys.fn_my_permissions(NULL, 'DATABASE')
    ORDER BY permission_name;
END
ELSE
BEGIN
    SET @sql = N'EXECUTE AS USER = ' + QUOTENAME(@PrincipalName, '''') + N';
        SELECT USER_NAME() AS evaluated_principal, permission_name, subentity_name
        FROM sys.fn_my_permissions(NULL, ''DATABASE'')
        ORDER BY permission_name;
        REVERT;';
    EXEC sys.sp_executesql @sql;
END;
