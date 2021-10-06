using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ExtendedEventsAPI
{
    class Program
    {
        static void Main(string[] args)
        {
            //ObjectModel om = new ObjectModel();
            //om.ShowPackages();
            //om.Show_sqlos_Events();
            //om.CreateEventSession();

            //ReadingFiles.ReadEventFile();
            EventStream.ReadEventStream();
        }
    }
}
