/*
Name: Open Transactions by Database
Description: Summarizes active database transactions and log bytes by session and database.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run when investigating log reuse waits, long transactions, or blocking.
Notes: An open transaction can be sleeping. Confirm ownership and rollback impact before action.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    st.session_id,
    DB_NAME(dt.database_id) AS database_name,
    at.transaction_id,
    at.transaction_begin_time,
    DATEDIFF(SECOND, at.transaction_begin_time, SYSDATETIME()) AS age_seconds,
    at.transaction_state,
    dt.database_transaction_type,
    dt.database_transaction_log_record_count,
    dt.database_transaction_log_bytes_used,
    dt.database_transaction_log_bytes_reserved,
    s.login_name,
    s.host_name,
    s.program_name,
    s.status
FROM sys.dm_tran_session_transactions AS st
INNER JOIN sys.dm_tran_active_transactions AS at ON at.transaction_id = st.transaction_id
INNER JOIN sys.dm_tran_database_transactions AS dt ON dt.transaction_id = at.transaction_id
INNER JOIN sys.dm_exec_sessions AS s ON s.session_id = st.session_id
WHERE s.is_user_process = 1
ORDER BY at.transaction_begin_time;
