
UPDATE Minion.BackupSettingsPath
SET BackupPath = BackupPath + '%SoSL%\%Instance%\%DBName%\',
[FileName] = '%Ordinal%of%NumFiles%%DBName%%BackupType%%Date%%Hour%%Minute%%Second%',
FileExtension = '%BackupTypeExtension%'
WHERE FileName NOT LIKE '%\%%' ESCAPE '\';

