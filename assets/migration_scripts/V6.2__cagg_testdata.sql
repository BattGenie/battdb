
CREATE MATERIALIZED VIEW test_data_summary_10min
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('10 minutes', recorded_datetime) AS tenmin, 
    test_id,
    max(cycle) as tenmin_cycle,
    max(test_time_s) as tenmin_test_time_s,
    max(unixtime_s) as tenmin_unixtime_s,
    avg(voltage_mv) as tenmin_voltage_mv, 
    avg(current_ma) as tenmin_current_ma
    FROM test_data
    GROUP BY tenmin, test_id
    WITH NO DATA;
	
CREATE MATERIALIZED VIEW test_data_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', recorded_datetime) AS thirtysec, 
    test_id,
    max(cycle) as thirtysec_cycle,
    max(test_time_s) as thirtysec_test_time_s,
    max(unixtime_s) as thirtysec_unixtime_s,
    avg(voltage_mv) as thirtysec_voltage_mv, 
    avg(current_ma) as thirtysec_current_ma
    FROM test_data
    GROUP BY thirtysec, test_id
    WITH NO DATA;
	
CREATE MATERIALIZED VIEW test_data_summary_hourly
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 hour', recorded_datetime) AS hour, 
    test_id,
    max(cycle) as hour_cycle,
    max(test_time_s) as hour_test_time_s,
    max(unixtime_s) as hour_unixtime_s,
    avg(voltage_mv) as hour_voltage_mv, 
    avg(current_ma) as hour_current_ma
    FROM test_data
    GROUP BY hour, test_id
    WITH NO DATA;

CREATE MATERIALIZED VIEW test_data_summary_daily
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 day', recorded_datetime) AS day, 
    test_id,
    max(cycle) as day_cycle,
    max(test_time_s) as day_test_time_s,
    max(unixtime_s) as day_unixtime_s,
    avg(voltage_mv) as day_voltage_mv, 
    avg(current_ma) as day_current_ma
    FROM test_data
    GROUP BY day, test_id
    WITH NO DATA;