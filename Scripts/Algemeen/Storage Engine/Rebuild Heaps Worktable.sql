SELECT o.name,
	fh.object_id,
	fh.page_count,
	fh.record_count,
	fh.forwarded_record_count,
	fh.forwarded_record_percent
FROM FragmentedHeaps AS fh
LEFT JOIN HIX_PRODUCTIE.sys.objects AS o ON o.object_id = fh.object_id
ORDER BY fh.forwarded_record_percent DESC;
GO


