DECLARE @log_shipping_secondary_id UNIQUEIDENTIFIER;

SET @log_shipping_secondary_id = (
    SELECT sec.secondary_id
    FROM msdb.dbo.log_shipping_secondary_databases AS secdb
    INNER JOIN msdb.dbo.log_shipping_secondary AS sec
        ON secdb.secondary_id = sec.secondary_id
    WHERE secdb.secondary_database = DB_NAME ()
);

SELECT session_id,
       session_status,
       log_time_utc,
       message
FROM msdb.dbo.log_shipping_monitor_history_detail AS d
WHERE agent_id = @log_shipping_secondary_id
      AND agent_type = 2
      AND session_id IN (
              SELECT session_id
              FROM msdb.dbo.log_shipping_monitor_history_detail AS d
              WHERE session_status IN ( 3, 4 )
          )
ORDER BY log_time_utc DESC,
         session_status DESC;