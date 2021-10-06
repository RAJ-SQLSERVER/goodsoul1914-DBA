using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.Management.XEvent;
using Microsoft.SqlServer.Management.Sdk.Sfc;
using System.Data.SqlClient;

namespace ExtendedEventsAPI
{
    class ObjectModel
    {
        XEStore xe;

        public ObjectModel()
        {
            SqlConnectionStringBuilder conBuild = new SqlConnectionStringBuilder();
            conBuild.DataSource = "(local)";
            conBuild.InitialCatalog = "master";
            conBuild.IntegratedSecurity = true;
            SqlStoreConnection server = new SqlStoreConnection(new SqlConnection(conBuild.ConnectionString.ToString()));
            xe = new XEStore(server);
        }

        public void CreateEventSession()
        {
            // Drop the session if it exists
            try
            {
                xe.Sessions["PS_DemoAPI"].Drop();
            }
            catch (Exception ex)
            {
                // Session didn't exist so no issue
            }

            Session ses = xe.CreateSession("PS_DemoAPI");
            
            // Create an array of event names to add to the session
            string[] events = {"sqlserver.rpc_completed",
                               "sqlserver.sp_statement_completed",
                               "sqlserver.sql_batch_completed",
                               "sqlserver.sql_statement_completed"};

            // Create an array of action names to add to the events
            string[] actions = {"sqlserver.client_app_name", 
                                "sqlserver.client_hostname", 
                                "sqlserver.database_id",
			                    "sqlserver.nt_username", 
                                "sqlserver.server_principal_name", 
                                "sqlserver.session_id"};

            // Add the events to to the session
            foreach (string event_name in events)
            {
                Event evnt = ses.AddEvent(event_name);
            
                // Add the actions to this event
                foreach (string action in actions)
                    evnt.AddAction(action);

                // Add a predicate to the event
                evnt.PredicateExpression = @"sqlserver.session_id > 50";
            }

            // Add the ring_buffer target to the event session
            Target target = ses.AddTarget("package0.ring_buffer");

            // Generate a DDL Script to output
            ISfcScript scr = ses.ScriptCreate();
            string ses_DDL = scr.ToString();

            Console.Write(ses_DDL);
            Console.WriteLine();
            Console.WriteLine("Event Session created, press any key to exit!\n");
            Console.ReadKey();
        }

        public void ShowPackages()
        {
            foreach (Package p in xe.Packages)
               Console.Write(string.Format("Package: {0}\nGuid: {1}\nDescription: {2}\n\n", p.Name, p.ID, p.Description));
            Console.WriteLine();
            Console.WriteLine("Packages listed, press any key to show events!\n");
            Console.ReadKey();
        }

        public void ShowSQLServerEvents()
        {
            foreach (EventInfo e in xe.Packages["sqlos"].EventInfoSet)
                Console.Write(string.Format("Package: {0}\nEvent: {1}\nDescription: {2}\nColumn Count: {3}\n\n", e.Parent.Name, e.Name, e.Description, e.DataEventColumnInfoSet.Count));
            Console.WriteLine();
            Console.WriteLine("Events listed, press any key to create an event session!\n");
            Console.ReadKey();
        }
    }
}
