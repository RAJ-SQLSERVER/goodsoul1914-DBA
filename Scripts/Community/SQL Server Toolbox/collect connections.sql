/*

USE [DBA]
GO
DROP TABLE [dbo].[ExecRequests_connections]
GO
CREATE TABLE [dbo].[ExecRequests_connections](
	id int not null IDENTITY(1,1),
	[login_name] [nvarchar](128) NOT NULL,
	[client_interface_name] [nvarchar](32) NULL,
	[host_name] [nvarchar](128) NULL,
	[nt_domain] [nvarchar](128) NULL,
	[nt_user_name] [nvarchar](128) NULL,
	[endpoint_name] [sysname] NULL,
	[program_name] [nvarchar](128) NULL,
	[observed_count] bigint NOT NULL CONSTRAINT DF_ExecRequests_connections_observed_count DEFAULT(0),
CONSTRAINT pk_execrequests_connections_id PRIMARY KEY (ID)
) ON [PRIMARY]
CREATE INDEX idx_execrequests_connections ON execrequests_connections (login_name, client_interface_name, [host_name], nt_domain, nt_user_name, endpoint_name, [program_name])
GO


*/

INSERT INTO dbo.ExecRequests_connections (login_name,
                                          client_interface_name,
                                          host_name,
                                          nt_domain,
                                          nt_user_name,
                                          program_name,
                                          endpoint_name)
SELECT LEFT(s.login_name, 128),
       LEFT(s.client_interface_name, 128),
       LEFT(s.host_name, 128),
       LEFT(s.nt_domain, 128),
       LEFT(s.nt_user_name, 128),
       LEFT(s.program_name, 128),
       E.name
FROM sys.dm_exec_sessions AS s
LEFT OUTER JOIN sys.endpoints AS E
    ON E.endpoint_id = s.endpoint_id
LEFT OUTER JOIN dbo.ExecRequests_connections AS erc
    ON erc.login_name = LEFT(s.login_name, 128)
       AND erc.client_interface_name = LEFT(s.client_interface_name, 128)
       AND erc.host_name = LEFT(s.host_name, 128)
       AND erc.nt_domain = LEFT(s.nt_domain, 128)
       AND erc.nt_user_name = LEFT(s.nt_user_name, 128)
       AND erc.program_name = LEFT(s.program_name, 128)
       AND erc.endpoint_name = E.name
WHERE s.session_id >= 50 --retrieve only user spids
      AND s.session_id <> @@SPID --ignore myself
      AND erc.id IS NULL
GROUP BY LEFT(s.login_name, 128),
         LEFT(s.client_interface_name, 128),
         LEFT(s.host_name, 128),
         LEFT(s.nt_domain, 128),
         LEFT(s.nt_user_name, 128),
         LEFT(s.program_name, 128),
         E.name;


GO

UPDATE erc
SET observed_count = observed_count + s.session_id_count
FROM dbo.ExecRequests_connections AS erc
INNER JOIN (
    SELECT s.login_name,
           s.client_interface_name,
           s.host_name,
           s.nt_domain,
           s.nt_user_name,
           s.program_name,
           s.endpoint_id,
           COUNT (session_id) AS "session_id_count"
    FROM sys.dm_exec_sessions AS s
    WHERE s.session_id >= 50 --retrieve only user spids
          AND s.session_id <> @@SPID --ignore myself
    GROUP BY s.login_name,
             s.client_interface_name,
             s.host_name,
             s.nt_domain,
             s.nt_user_name,
             s.program_name,
             s.endpoint_id
) AS s
    ON erc.login_name = LEFT(s.login_name, 128)
       AND erc.client_interface_name = LEFT(s.client_interface_name, 128)
       AND erc.host_name = LEFT(s.host_name, 128)
       AND erc.nt_domain = LEFT(s.nt_domain, 128)
       AND erc.nt_user_name = LEFT(s.nt_user_name, 128)
       AND erc.program_name = LEFT(s.program_name, 128)
LEFT OUTER JOIN sys.endpoints AS e
    ON e.endpoint_id = s.endpoint_id
       AND erc.endpoint_name = e.name;

--select * from dbo.ExecRequests_connections erc