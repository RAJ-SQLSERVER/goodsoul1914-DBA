use SpeechReport
select top 10 EventDate, MessageText, MessageHistoryEventType
from [SOL].[MessageHistory]
where MessageText like '%|AE|%' and EventDate >= '2019-02-01'
order by [MessageHistoryId] DESC

