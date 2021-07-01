CREATE PROCEDURE [dbo].[httpGET] (
	@url NVARCHAR(4000)
	,@ResponseText NVARCHAR(MAX) OUTPUT
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @Object AS INT;

		EXEC sp_OACreate 'MSXML2.XMLHTTP'
			,@Object OUTPUT;

		EXEC sp_OAMethod @Object
			,'open'
			,NULL
			,'GET'
			,@url
			,'false';

		EXEC sp_OAMethod @Object
			,'send'
			,NULL;

		DECLARE @TABLEVAR TABLE (responseXml VARCHAR(MAX))

		INSERT INTO @TABLEVAR
		EXEC sp_OAGetProperty @Object
			,'responseText';

		SET @ResponseText = '';

		SELECT @ResponseText = responseXml
		FROM @TABLEVAR
	END TRY

	BEGIN CATCH
		PRINT 'Exception in httpGET';
	END CATCH

	EXEC sp_OADestroy @Object;
END
GO

CREATE PROCEDURE [dbo].[LatestBlogPosts] (@url NVARCHAR(4000))
AS
BEGIN
	BEGIN TRY
		DECLARE @ResponseText AS NVARCHAR(MAX) = '';

		EXEC [dbo].[httpGET] @url = @url
			,@ResponseText = @ResponseText OUTPUT;

		DECLARE @xml XML = cast(REPLACE(@ResponseText, 'encoding="UTF-8"', '') AS XML);

		SELECT x.xmlNode.value('(title)[1]', 'varchar(400)') AS BlogTitle
			,x.xmlNode.value('(link)[1]', 'varchar(400)') AS BlogUrl
			,x.xmlNode.value('(pubDate)[1]', 'varchar(400)') AS BlogDate
			,x.xmlNode.value('(description)[1]', 'varchar(400)') AS BlogDescription
		FROM @xml.nodes('/rss/channel/item') x(xmlNode)
	END TRY

	BEGIN CATCH
		PRINT 'Exception';
	END CATCH
END
GO

EXEC [dbo].[LatestBlogPosts] @url = 'https://stevestedman.com/feed/';

