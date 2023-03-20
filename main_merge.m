clear
clc

DB1 = ADatabase();
DB1.Read("MyMan.dat");

DB2 = ADatabase();
DB2.Read("master.dat");

DB3 = ADatabase.Merge(DB1, DB2);

DB3.Write("finalshit.dat");

