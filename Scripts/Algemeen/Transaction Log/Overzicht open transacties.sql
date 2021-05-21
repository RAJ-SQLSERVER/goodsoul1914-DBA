-------------------------------------------------------------------------------
-- Deze functie wordt vooral gebruikt bij het vrijmaken van ruimte in de 
-- transactielogs. Het commando geeft de oudste transactie aan die nog open 
-- staat voor verwerking.
--
-- Belangrijk: dit commando geeft alleen informatie over de actief 
-- geselecteerde database waarbinnen deze instructie wordt uitgevoerd
-------------------------------------------------------------------------------

DBCC OPENTRAN;


-------------------------------------------------------------------------------
-- Deze system view (dus geen tabel!) geeft onder andere informatie over het 
-- proces ID waaronder de transactie draait, op welke machine de transactie is 
-- gestart ook met welk account. Deze view is vooral handig om te 
-- identificeren wie, welke transacties open heeft.
--
-- Belangrijk: de informatie wordt serverbreed weergegeven (en dus niet per 
-- databases)
-------------------------------------------------------------------------------

SELECT spid,
       kpid,
       blocked,
       waittype,
       waittime,
       lastwaittype,
       waitresource,
       dbid,
       uid,
       cpu,
       physical_io,
       memusage,
       login_time,
       last_batch,
       ecid,
       open_tran,
       status,
       sid,
       hostname,
       program_name,
       hostprocess,
       cmd,
       nt_domain,
       nt_username,
       net_address,
       net_library,
       loginame,
       context_info,
       sql_handle,
       stmt_start,
       stmt_end,
       request_id
FROM sys.sysprocesses
WHERE open_tran <> 0;
GO


-------------------------------------------------------------------------------
-- Onderstaande handige query is een query op de serverbrede view 
-- (dus geen tabel!) sys.dm_tran_active_transactions. Deze view wordt 
-- voornamelijk gebruikt om de status en voortgang van verschillende open 
-- transacties in kaart te brengen.
--
-- Belangrijk: de informatie wordt serverbreed weergegeven (en dus niet per 
-- database)
-------------------------------------------------------------------------------

SELECT transaction_id,
       name,
       transaction_begin_time,
       CASE transaction_type
           WHEN 1 THEN
               '1 = Read/write transaction'
           WHEN 2 THEN
               '2 = Read-only transaction'
           WHEN 3 THEN
               '3 = System transaction'
           WHEN 4 THEN
               '4 = Distributed transaction'
		   ELSE NULL
       END AS transaction_type,
       CASE transaction_state
           WHEN 0 THEN
               '0 = The transaction has not been completely initialized yet'
           WHEN 1 THEN
               '1 = The transaction has been initialized but has not started'
           WHEN 2 THEN
               '2 = The transaction is active'
           WHEN 3 THEN
               '3 = The transaction has ended. This is used for read-only transactions'
           WHEN 4 THEN
               '4 = The commit process has been initiated on the distributed transaction'
           WHEN 5 THEN
               '5 = The transaction is in a prepared state and waiting resolution'
           WHEN 6 THEN
               '6 = The transaction has been committed'
           WHEN 7 THEN
               '7 = The transaction is being rolled back'
           WHEN 8 THEN
               '8 = The transaction has been rolled back'
		   ELSE NULL
       END AS transaction_state,
       CASE dtc_state
           WHEN 1 THEN
               '1 = ACTIVE'
           WHEN 2 THEN
               '2 = PREPARED'
           WHEN 3 THEN
               '3 = COMMITTED'
           WHEN 4 THEN
               '4 = ABORTED'
           WHEN 5 THEN
               '5 = RECOVERED'
		   ELSE NULL
       END AS dtc_state,
       transaction_status,
       transaction_status2,
       dtc_status,
       dtc_isolation_level,
       filestream_transaction_id
FROM sys.dm_tran_active_transactions;
GO

