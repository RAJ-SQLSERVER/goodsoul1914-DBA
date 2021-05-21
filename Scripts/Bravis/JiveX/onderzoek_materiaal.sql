select onderznr, materiaal, * 
from uitslag5_pa_ond 
where patientnr = '11183283'


UPDATE UITSLAG5_PA_OND
SET [URL] = REPLACE(URL, '10.34.52.29', '10.206.8.234')
WHERE patientnr = '11183283' AND ONDERZNR = 'FP11362589'
GO