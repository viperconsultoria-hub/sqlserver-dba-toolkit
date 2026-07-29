/*
Name: Windows Server Failover Cluster Status
Description: Reports the local cluster, members, networks, and availability-group cluster state visible to SQL Server.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+ on Windows Server Failover Clustering
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run on each Availability Group replica.
Notes: SQL DMVs are not a replacement for cluster logs, quorum validation, network monitoring, or platform tooling.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    cluster_name,
    quorum_type_desc,
    quorum_state_desc
FROM sys.dm_hadr_cluster;

SELECT
    member_name,
    member_type_desc,
    member_state_desc,
    number_of_quorum_votes
FROM sys.dm_hadr_cluster_members
ORDER BY member_type_desc, member_name;

SELECT
    member_name,
    network_subnet_ip,
    network_subnet_prefix_length,
    is_public,
    is_ipv4
FROM sys.dm_hadr_cluster_networks
ORDER BY member_name, network_subnet_ip;
