-- Returns information about the connections established to this instance of 
-- SQL Server and the details of each connection. Returns server wide connection 
-- information for SQL Server. Returns current database connection information 
-- for SQL Database.
--
--session_id				The session which started this connection. 
--							This maps to the session_id in sys.dm_exec_sessions
--most_recent_session_id	The session id used for most recent request for this connection.
--connection_id				The id of the connection. This is used to map connection 
--							to request in sys.dm_exec_requests.
--connect_time				Timestamp when the connection is made.
--net_transport				The physical transport protocol used to connect.
--protocol_type				This is the protocol of the payload on this connection. 
--							Currently shows TSQL (TDS) and SOAP protocols.
--encrypt_type				Specifies if the connection is encrypted. TRUE or FALSE.
--auth_scheme				The authentication mode used for this connection. 
--							Windows (KERBEROS/NTLM) or Mixed Mode (SQL).
--node_affinity				The Memory node to which this connection has affinity. 
--							Refer my SQL OS presentation to understand Memory Nodes and affinity.
--num_reads					Number of packet reads made on this connection.
--num_write					Number of data packets that are written on this connection.
--last_read					Timestamp when the last read occurred on this connection. 
--							Maps with the request from most_recent_session_id
--last_write				Timestamp when the connection has last written the 
--							data packets on the target.
--net_packet_size			The network packet size of the data and information 
--							transfer on this connection.
--client_net_address		Host IP address of the connection.
--client_tcp_port			Port number associated with this connection on the client.
--most_recent_sql_handle	SQL Handle associated with the recent request. 
--							This is always in sync with the most_recent_session_id.
-------------------------------------------------------------------------------
SELECT session_id,
       most_recent_session_id,
       connection_id,
       connect_time,
       net_transport,
       protocol_type,
       encrypt_option,
       auth_scheme,
       node_affinity,
       num_reads,
       num_writes,
       last_read,
       last_write,
       net_packet_size,
       client_net_address,
       client_tcp_port,
       most_recent_sql_handle
FROM sys.dm_exec_connections;
GO
