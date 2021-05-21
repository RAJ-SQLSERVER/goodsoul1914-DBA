SELECT TOP 100 
cast(replace(cast([URL] as nvarchar(max)),'http://10.34.52.29/jivexweb2/start.jsp?login=Ezis&password=Ezis&mode=load&accessionNumber=', 'http://10.34.52.72/jivexmobilePrototyp/?mode=load&username=qa&password=qa&accessionNumber=') as ntext),
* FROM UITSLAG5_PA_OND 
WHERE [URL] LIKE 'http://10.34.52.29/jivexweb2/start.jsp?login=Ezis&password=Ezis&mode=load&accessionNumber=%'

UPDATE 
	UITSLAG5_PA_OND 
SET 
	[URL] = cast(replace(cast([URL] as nvarchar(max)),'http://10.34.52.29/jivexweb2/start.jsp?login=Ezis&password=Ezis&mode=load&accessionNumber=', 'http://10.34.52.72/jivexmobilePrototyp/?mode=load&username=qa&password=qa&accessionNumber=') as ntext)