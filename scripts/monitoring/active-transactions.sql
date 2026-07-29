/*
Name: Active Transactions
Description: Correlates active transactions, sessions, requests, log use, and transaction start time.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run during blocking, log growth, or version-store investigations.
Notes: Long transactions can be idle. Coordinate with application owners before intervention.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    at.transaction_id,
    at.name AS transaction_name,
    at.transaction_begin_time,
    DATEDIFF(SECOND, at.transaction_begin_time, SYSDATETIME()) AS transaction_age_seconds,
    at.transaction_type,
    at.transaction_state,
    st.session_id,
    s.login_name,
    s.host_name,
    s.status AS session_status,
    DB_NAME(dt.database_id) AS database_name,
    dt.database_transaction_log_bytes_used,
    dt.database_transaction_log_bytes_reserved,
    r.status AS request_status,
    r.command,
    r.wait_type,
    r.blocking_session_id
FROM sys.dm_tran_active_transactions AS at
INNER JOIN sys.dm_tran_session_transactions AS st ON st.transaction_id = at.transaction_id
INNER JOIN sys.dm_exec_sessions AS s ON s.session_id = st.session_id
LEFT JOIN sys.dm_tran_database_transactions AS dt ON dt.transaction_id = at.transaction_id
LEFT JOIN sys.dm_exec_requests AS r ON r.session_id = st.session_id
WHERE s.is_user_process = 1
ORDER BY at.transaction_begin_time;
