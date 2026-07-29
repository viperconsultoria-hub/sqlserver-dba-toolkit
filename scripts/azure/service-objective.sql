/*
Name: Azure SQL Service Objective
Description: Reports database edition, service objective, elastic pool, size, and lifecycle state.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: Azure SQL Database
Permissions: VIEW DATABASE STATE and metadata visibility
Usage: Run in the target database and correlate changes with Azure Activity Log.
Notes: Service objectives and exposed columns evolve; confirm current Azure SQL documentation.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME() AS database_name,
    DATABASEPROPERTYEX(DB_NAME(), 'Edition') AS edition,
    DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS service_objective,
    DATABASEPROPERTYEX(DB_NAME(), 'MaxSizeInBytes') AS maximum_size_bytes,
    DATABASEPROPERTYEX(DB_NAME(), 'Collation') AS collation_name,
    dso.edition AS catalog_edition,
    dso.service_objective,
    dso.elastic_pool_name
FROM sys.database_service_objectives AS dso
WHERE dso.database_id = DB_ID();
