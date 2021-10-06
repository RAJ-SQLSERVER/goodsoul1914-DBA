using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using Microsoft.SqlServer.XEvent.Linq;
using System.Threading;

namespace ExtendedEventsAPI
{
    public static class EventStream
    {
        public static void ReadEventStream()
        {
            SQLWorker w = new SQLWorker();

            Console.ReadKey();
            w.RequestStop();
            w.Thread.Join();
        }

        internal class SQLWorker
        {
            QueryableXEventData stream;
            Thread t;
            private volatile bool workerCanceled = false;

            public SQLWorker()
            {
                SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
                scsb.ApplicationName = "PluralsightDemo";
                scsb.DataSource = "PS-SQL2K12";
                scsb.InitialCatalog = "master";
                scsb.IntegratedSecurity = true;

                SqlConnection conn = new SqlConnection(scsb.ConnectionString);
                conn.Open();

                SqlCommand cmd = conn.CreateCommand();
                cmd.CommandText = @"IF NOT EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'PS_StreamDemo')
    BEGIN
        -- Session does not exist, so create it.
        CREATE EVENT SESSION PS_StreamDemo
        ON SERVER
        ADD EVENT sqlserver.rpc_completed(
	        ACTION (sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id,
			        sqlserver.nt_username, sqlserver.server_principal_name, sqlserver.session_id)),
        ADD EVENT sqlserver.sp_statement_completed(
	        ACTION (sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id,
			        sqlserver.nt_username, sqlserver.server_principal_name, sqlserver.session_id)),
        ADD EVENT sqlserver.sql_batch_completed(
	        ACTION (sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id,
			        sqlserver.nt_username, sqlserver.server_principal_name, sqlserver.session_id)),
        ADD EVENT sqlserver.sql_statement_completed(
	        ACTION (sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id,
			        sqlserver.nt_username, sqlserver.server_principal_name, sqlserver.session_id))
        
        -- Now start the session
        ALTER EVENT SESSION PS_StreamDemo
        ON SERVER
        STATE=START;
    END
ELSE
    BEGIN
        -- Session exists, is it running?
        IF NOT EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name = 'PS_StreamDemo')
            BEGIN
                -- Session is not running so start it.
                ALTER EVENT SESSION PS_StreamDemo
                ON SERVER
                STATE=START;
            END
    END";
                cmd.ExecuteNonQuery();

                stream = new QueryableXEventData(
                            scsb.ConnectionString,
                            "PS_StreamDemo",
                            EventStreamSourceOptions.EventStream,
                            EventStreamCacheOptions.DoNotCache);

                t = new Thread(ReadEventStream);
                t.Start();
            }

            public Thread Thread
            {
                get
                {
                    return t;
                }
            }


            public void RequestStop()
            {
                workerCanceled = true;
            }

            public void ReadEventStream()
            {
                foreach (PublishedEvent pe in stream.EventProvider)
                {
                    ThreadPool.QueueUserWorkItem(new WaitCallback(ProcessEvent), pe);
                    if (workerCanceled)
                        break;
                }
            }

            public void ProcessEvent(object sender)
            {
                PublishedEvent pe = (PublishedEvent)sender;
                Console.WriteLine(string.Format("Timestamp: {0}\nEvent Name:{1}\nNumber of Fields:{2}\n\n", pe.Timestamp.ToString("G"), pe.Name, pe.Fields.Count));
            }


        }

    }
}
