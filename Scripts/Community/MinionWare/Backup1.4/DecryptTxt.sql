
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'DecryptTxt' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
DROP FUNCTION Minion.DecryptTxt
END
GO  
CREATE FUNCTION [Minion].[DecryptTxt] (@EncryptedTxt VARBINARY(MAX))
RETURNS VARCHAR(4000)
WITH EXECUTE AS CALLER
AS

BEGIN
DECLARE @DecryptedTxt VARCHAR(4000);

SET @DecryptedTxt = (SELECT CONVERT(VARCHAR(4000), DECRYPTBYCERT(CERT_ID('MinionEncrypt'), @EncryptedTxt)))

RETURN @DecryptedTxt
END
GO