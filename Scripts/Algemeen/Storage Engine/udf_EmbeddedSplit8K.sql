-- Author: Carlo.Romagnano
-- Date  : 20181123
-- Starting from DelimitedSplit8K of Jeff Moden
-- [udf_EmbeddedSplit8K] returns all token delimited from @pDelimiterStart and @pDelimiterEnd
-- @pDelimiterStart and @pDelimiterEnd may be the same character
-- e.g SELECT * FROM [dbo].[udf_EmbeddedSplit8K]('ddd ddd [12345]  ee [abcde] ee ','[',']') --returns 12345 and abcde
-- e.g SELECT * FROM [dbo].[udf_EmbeddedSplit8K]('ddd ddd #12345#  ee #abcde# ee ','#','#') --returns 12345 and abcde
-- N.B. if the delimiters doesn't match the token is not returned.
-- e.g SELECT * FROM [dbo].[udf_EmbeddedSplit8K]('ddd ddd (12345)  ee abcde( ee ','(',')') --returns 12345

create or alter function dbo.udf_EmbeddedSplit8K(
	@pString         varchar(8000), 
	@pDelimiterStart char(1), 
	@pDelimiterEnd   char(1)) returns table with schemabinding as

return

with E1(N)
	 as (select a
		 from(values(
			 null), (
			 null), (
			 null), (
			 null), (
			 null), (
			 null), (
			 null), (
			 null), (
			 null), (
			 null)) as V(a)),
	 E2(N)
	 as (select 1
		 from E1 as a, E1 as b),
	 E4(N)
	 as (select 1
		 from E2 as a, E2 as b),
	 cteTally(N)
	 as (select top (ISNULL(DATALENGTH(@pString), 0)) ROW_NUMBER() over(
													  order by (select null) )
		 from E4),
	 cteStart(N1, 
			  idx)
	 as (select 0, 
				0
		 union all
		 select t.N + 1, 
				ROW_NUMBER() over(
				order by t.N)
		 from cteTally as t
		 where SUBSTRING(@pString, t.N, 1) in (@pDelimiterStart, @pDelimiterEnd) ),
	 cteLen(lStart, 
			lEnd, 
			idx)
	 as (select ds.lStart + 1, 
				de.lEnd, 
				s.idx
		 from cteStart as s
			  cross apply (select NULLIF(CHARINDEX(@pDelimiterStart, @pString, s.N1), 0)) as ds(lStart)
			  cross apply (select NULLIF(CHARINDEX(@pDelimiterEnd, @pString, ds.lStart + 1), 0)) as de(lEnd)
		 where ds.lStart > 0
			   and de.lEnd > 0)
	 select ItemNumber = ROW_NUMBER() over(
			order by l.idx), 
			Item = SUBSTRING(@pString, l.lStart, l.lEnd - l.lStart), 
			OffsetStart = l.lStart, 
			OffsetEnd = l.lEnd
	 from cteLen as l
	 where l.idx & 1 = 0;