/*
Path: EXAM FOLDER + IMAGE FOLDER + IMAGE FILE

file://		means the exam is in Online Storage
cfile://	means the exam has been archived

One exam can have both locations. When autofiler runs and the online exam is ready to be purged, you will only have the cfile
*/

SELECT WEXAM_ID, WEXAM_CODE, WEF_ARCHIVE_STATE, WEXAM_ID_STRING, WEXAM_DATE, WEF_LOC, WIF_LOC, WIFI_LOC, WEF_LOC + '/' + WIF_LOC + '/' + WIFI_LOC as [Location]
FROM W_EXAM
INNER JOIN W_EXAM_FOLDER ON WEF_EXAM_ID = WEXAM_ID
INNER JOIN W_IMAGE_FOLDER ON WIF_EF_ID = WEF_ID
INNER JOIN W_IMAGE_FILE ON WIFI_IF_ID = WIF_ID
WHERE 
	--WEXAM_DATE BETWEEN '2018-10-23 00:00:00.000' AND '2018-11-10 00:00:00.000' AND
	WEF_ARCHIVE_STATE IN (6, 99) AND
	WEXAM_ID_STRING = '4001475047'
	--AND WIFI_LOC LIKE '%doc%' --OR WIF_LOC LIKE '%10341996'
