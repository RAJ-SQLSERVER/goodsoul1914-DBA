using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using Microsoft.SqlServer.XEvent.Linq;
using System.Threading;

namespace ExtendedEventsAPI
{
    public static class ReadingFiles
    {
        public static void ReadEventFile()
        {
            //SQLWorker w = new SQLWorker(@"c:\Pluralsight\system_health_0_130084612051920000.xel");
            
            //SQLWorker w = new SQLWorker(@"c:\Pluralsight\system_health*xel");
            SQLWorker w = new SQLWorker(new string[] { @"c:\Pluralsight\system_health_0_130084611231280000.xel", @"c:\Pluralsight\system_health_0_130084554100160000.xel" });
            
            Console.ReadKey();
            w.RequestStop();
            w.Thread.Join();
        }

        internal class SQLWorker
        {
            QueryableXEventData filedata;
            Thread t;
            private volatile bool workerCanceled = false;

            public SQLWorker(string filename)
            {
                filedata = new QueryableXEventData(filename);
                    
                t = new Thread(ReadEventData);
                t.Start();
            }

            public SQLWorker(string[] filelist)
            {
                filedata = new QueryableXEventData(filelist);

                t = new Thread(ReadEventData);
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

            public void ReadEventData()
            {
                int numberofevents = filedata.EventProvider.Count();
                foreach (PublishedEvent pe in filedata.EventProvider)
                {
                    ProcessEvent(pe);
                    if (workerCanceled)
                        break;
                }
                Console.WriteLine("Processed {0} events from the file.", numberofevents);
            }

            public void ProcessEvent(object sender)
            {
                PublishedEvent pe = (PublishedEvent)sender;
                Console.WriteLine(string.Format("Timestamp: {0}\nEvent Name:{1}\nNumber of Fields:{2}\n\n", pe.Timestamp.ToString("G"), pe.Name, pe.Fields.Count));
            }
        }

    }
}
