select name, 
	   is_encrypted
from master.sys.databases;

create master key encryption by password = 'uAXUqD48hLAt92fzDdC3w32675k9dK##';

select *
from sys.symmetric_keys;

select *
from sys.asymmetric_keys;

select *
from sys.certificates;

create certificate MyServerCert with subject = 'My DEK Certificate';

backup certificate MyServerCert to file = 'D:\MSSQL\Backup\Certificates\MyServerCert';

use AdventureWorks;
go

create database encryption key with algorithm = aes_128 encryption by server certificate MyServerCert;

alter database adventureworks set encryption on;
go