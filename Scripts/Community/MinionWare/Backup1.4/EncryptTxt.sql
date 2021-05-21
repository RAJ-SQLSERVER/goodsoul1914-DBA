
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'EncryptTxt' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
DROP FUNCTION Minion.EncryptTxt
END
GO
CREATE FUNCTION [Minion].[EncryptTxt] (@PlainTxt VARCHAR(4000))
RETURNS VARBINARY(MAX)
WITH EXECUTE AS CALLER
AS

BEGIN
DECLARE @EncryptedTxt VARBINARY(MAX);

SET @EncryptedTxt = ENCRYPTBYCERT(CERT_ID('MinionEncrypt'), @PlainTxt)

RETURN @EncryptedTxt
END
GO
