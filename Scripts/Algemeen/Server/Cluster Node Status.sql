-- Get information about your cluster nodes and their status
--
-- (if your database server is in a failover cluster)
-- Knowing which node owns the cluster resources is critical
-- Especially when you are installing Windows or SQL Server updates
-- You will see no results if your instance is not clustered
--
-- Recommended hotfixes and updates for Windows Server 2012 R2-based failover clusters
-- https://bit.ly/1z5BfCw
---------------------------------------------------------------------------------------------------
SELECT NodeName,
	status_description,
	is_current_owner
FROM sys.dm_os_cluster_nodes WITH (NOLOCK)
OPTION (RECOMPILE);
GO


