/*
Name: Azure SQL Automatic Tuning Options
Description: Reviews desired and actual automatic-tuning configuration with state reasons.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: Azure SQL Database
Permissions: VIEW DATABASE STATE
Usage: Run in the target database. This script performs no configuration changes.
Notes: Evaluate recommendations against governance and workload requirements before enabling options.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    name AS tuning_option,
    desired_state_desc,
    actual_state_desc,
    reason_desc
FROM sys.database_automatic_tuning_options
ORDER BY name;

SELECT
    desired_state_desc,
    actual_state_desc
FROM sys.database_automatic_tuning_mode;
