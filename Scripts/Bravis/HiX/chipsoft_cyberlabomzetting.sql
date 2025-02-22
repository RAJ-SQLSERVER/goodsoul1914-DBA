SELECT count(*)
 FROM [HIX_ACCEPTATIE].[dbo].[LAB_HUIDIGE_UITSLAG]
  WHERE LINK LIKE '%CYBERLAB%'

SELECT count(*)
  FROM [HIX_ACCEPTATIE].[dbo].[LAB_LUITSLAG]
  WHERE LINK LIKE '%cyberlab%'


-- 26 sec - 115 rows
UPDATE [HIX_ACCEPTATIE].[dbo].[LAB_LUITSLAG]
SET LINK = cast(replace(cast([LINK] as nvarchar(max)), '\\FZR-CYBERLAB-01\Attachments\','\\zkh.local\zkh\KCHLT\FZR\') as ntext)
WHERE LINK LIKE '%CYBERLAB%'


-- 73 sec - 2194 rows
UPDATE [HIX_ACCEPTATIE].[dbo].[LAB_HUIDIGE_UITSLAG]
SET LINK = cast(replace(cast([LINK] as nvarchar(max)), '\\FZR-CYBERLAB-01\Attachments\','\\zkh.local\zkh\KCHLT\FZR\') as ntext)
WHERE LINK LIKE '%CYBERLAB%'

de locatie van de pdf-bestanden wordt opgeslagen in de tabel 
LAB_HUIDGE_UITSLAG, betreft het veld LINK. 
Evt. historie staat in de tabel LAB_LUITSLAG, ook het veld LINK. 