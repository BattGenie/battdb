alter table hil_data drop constraint hil_data_pkey;

SELECT create_hypertable('hil_data', 'insert_time',  chunk_time_interval => INTERVAL '1 day', migrate_data => TRUE, if_not_exists => TRUE);

CREATE MATERIALIZED VIEW hil_data_summary_10min
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('10 minutes', insert_time) AS tenmin, 
    avg(measured_voltage_mv) as tenmin_measured_voltage_mv, 
    avg(modeled_voltage_mv) as tenmin_modeled_voltage_mv,
    avg(overpotential_mv) as tenmin_overpotential_mv, 
    avg(solution_time_ms) as tenmin_solution_time_ms, 
    avg(voltage_delta_mv) as tenmin_voltage_delta_mv,   
    avg(optimal_current_ma) as tenmin_modeled_current_ma, 
    avg(measured_current_ma) as tenmin_measured_current_ma
    FROM hil_data
    GROUP BY tenmin
    WITH NO DATA;
	
CREATE MATERIALIZED VIEW hil_data_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', insert_time) AS thirtysec, 
    avg(measured_voltage_mv) as thirtysec_measured_voltage_mv, 
    avg(modeled_voltage_mv) as thirtysec_modeled_voltage_mv,
    avg(overpotential_mv) as thirtysecn_overpotential_mv, 
    avg(solution_time_ms) as thirtysec_solution_time_ms, 
    avg(voltage_delta_mv) as thirtysec_voltage_delta_mv,   
    avg(optimal_current_ma) as thirtysec_modeled_current_ma, 
    avg(measured_current_ma) as thirtysec_measured_current_ma
    FROM hil_data
    GROUP BY thirtysec
	    WITH NO DATA;
	
CREATE MATERIALIZED VIEW hil_data_summary_hourly
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 hour', insert_time) AS hour, 
    avg(measured_voltage_mv) as hour_measured_voltage_mv, 
    avg(modeled_voltage_mv) as hour_modeled_voltage_mv,
    avg(overpotential_mv) as hour_overpotential_mv, 
    avg(solution_time_ms) as hour_solution_time_ms, 
    avg(voltage_delta_mv) as hour_voltage_delta_mv,   
    avg(optimal_current_ma) as hour_modeled_current_ma, 
    avg(measured_current_ma) as hour_measured_current_ma
    FROM hil_data
    GROUP BY hour
    WITH NO DATA;

CREATE MATERIALIZED VIEW hil_data_summary_daily
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 day', insert_time) AS day, 
    avg(measured_voltage_mv) as day_measured_voltage_mv, 
    avg(modeled_voltage_mv) as day_modeled_voltage_mv,
    avg(overpotential_mv) as day_overpotential_mv, 
    avg(solution_time_ms) as day_solution_time_ms, 
    avg(voltage_delta_mv) as day_voltage_delta_mv,   
    avg(optimal_current_ma) as day_modeled_current_ma, 
    avg(measured_current_ma) as day_measured_current_ma
    FROM hil_data
    GROUP BY day
    WITH NO DATA;