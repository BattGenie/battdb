-- Update the datatype of current, voltage from SMALLINT to NUMERIC
-- Since we cant modify the tables that have views, we need to drop and recreate 
-- the views as per https://stackoverflow.com/a/62793792

-- 1. Drop the views
DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_30s;
DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_10min;
DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_hourly;
DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_daily;

DROP MATERIALIZED VIEW IF EXISTS sil_data_summary_30s;
DROP MATERIALIZED VIEW IF EXISTS sil_data_summary_10min;
DROP MATERIALIZED VIEW IF EXISTS sil_data_summary_hourly;
DROP MATERIALIZED VIEW IF EXISTS sil_data_summary_daily;

DROP MATERIALIZED VIEW IF EXISTS sim_data_summary_30s;
DROP MATERIALIZED VIEW IF EXISTS sim_data_summary_10min;
DROP MATERIALIZED VIEW IF EXISTS sim_data_summary_hourly;
DROP MATERIALIZED VIEW IF EXISTS sim_data_summary_daily;

-- 2. Alter the tables
-- hil_data
ALTER TABLE hil_data 
ALTER COLUMN measured_voltage_mv TYPE NUMERIC,
ALTER COLUMN modeled_voltage_mv TYPE NUMERIC,
ALTER COLUMN voltage_delta_mv TYPE NUMERIC,
ALTER COLUMN measured_current_ma TYPE NUMERIC,
ALTER COLUMN modeled_current_ma TYPE NUMERIC,
ALTER COLUMN overpotential_mv TYPE NUMERIC,
ALTER COLUMN solution_time_ms TYPE NUMERIC,
ALTER COLUMN reported_charge_capacity_mah TYPE NUMERIC,
ALTER COLUMN reported_discharge_capacity_mah TYPE NUMERIC,
ALTER COLUMN reported_charge_energy_mwh TYPE NUMERIC,
ALTER COLUMN reported_discharge_energy_mwh TYPE NUMERIC;

-- sil_data
ALTER TABLE sil_data 
ALTER COLUMN measured_voltage_mv TYPE NUMERIC,
ALTER COLUMN modeled_voltage_mv TYPE NUMERIC,
ALTER COLUMN voltage_delta_mv TYPE NUMERIC,
ALTER COLUMN measured_current_ma TYPE NUMERIC,
ALTER COLUMN modeled_current_ma TYPE NUMERIC,
ALTER COLUMN overpotential_mv TYPE NUMERIC,
ALTER COLUMN solution_time_ms TYPE NUMERIC;

-- sim_data
ALTER TABLE sim_data 
ALTER COLUMN measured_voltage_mv TYPE NUMERIC,
ALTER COLUMN modeled_voltage_mv TYPE NUMERIC,
ALTER COLUMN voltage_delta_mv TYPE NUMERIC,
ALTER COLUMN measured_current_ma TYPE NUMERIC,
ALTER COLUMN modeled_current_ma TYPE NUMERIC,
ALTER COLUMN overpotential_mv TYPE NUMERIC,
ALTER COLUMN solution_time_ms TYPE NUMERIC;

-- 3. Recreate the views
-- hil_data
CREATE MATERIALIZED VIEW hil_data_summary_30s WITH (timescaledb.continuous) AS
SELECT time_bucket('30 seconds', insert_time) AS thirtysec,
    hil_id,
    avg(solution_time_ms) as thirtysec_solution_time_ms,
    avg(state_of_charge) as thirtysec_state_of_charge,
    avg(measured_voltage_mv) as thirtysec_measured_voltage_mv,
    avg(modeled_voltage_mv) as thirtysec_modeled_voltage_mv,
    avg(measured_current_ma) as thirtysec_measured_current_ma,
    avg(modeled_current_ma) as thirtysec_modeled_current_ma,
    avg(overpotential_mv) as thirtysec_overpotential_mv,
    avg(voltage_delta_mv) as thirtysec_voltage_delta_mv,
    avg(reported_charge_capacity_mah) as thirtysec_reported_charge_capacity_mah,
    avg(reported_discharge_capacity_mah) as thirtysec_reported_discharge_capacity_mah,
    avg(reported_charge_energy_mwh) as thirtysec_reported_charge_energy_mwh,
    avg(reported_discharge_energy_mwh) as thirtysec_reported_discharge_energy_mwh
FROM hil_data
GROUP BY thirtysec,
    hil_id WITH NO DATA;

CREATE MATERIALIZED VIEW hil_data_summary_10min WITH (timescaledb.continuous) AS
SELECT time_bucket('10 minutes', insert_time) AS tenmin,
    hil_id,
    avg(solution_time_ms) as tenmin_solution_time_ms,
    avg(state_of_charge) as tenmin_state_of_charge,
    avg(measured_voltage_mv) as tenmin_measured_voltage_mv,
    avg(modeled_voltage_mv) as tenmin_modeled_voltage_mv,
    avg(measured_current_ma) as tenmin_measured_current_ma,
    avg(modeled_current_ma) as tenmin_modeled_current_ma,
    avg(overpotential_mv) as tenmin_overpotential_mv,
    avg(voltage_delta_mv) as tenmin_voltage_delta_mv,
    avg(reported_charge_capacity_mah) as tenmin_reported_charge_capacity_mah,
    avg(reported_discharge_capacity_mah) as tenmin_reported_discharge_capacity_mah,
    avg(reported_charge_energy_mwh) as tenmin_reported_charge_energy_mwh,
    avg(reported_discharge_energy_mwh) as tenmin_reported_discharge_energy_mwh
FROM hil_data
GROUP BY tenmin,
    hil_id WITH NO DATA;

CREATE MATERIALIZED VIEW hil_data_summary_hourly WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', insert_time) AS hour,
    hil_id,
    avg(solution_time_ms) as hour_solution_time_ms,
    avg(state_of_charge) as hour_state_of_charge,
    avg(measured_voltage_mv) as hour_measured_voltage_mv,
    avg(modeled_voltage_mv) as hour_modeled_voltage_mv,
    avg(measured_current_ma) as hour_measured_current_ma,
    avg(modeled_current_ma) as hour_modeled_current_ma,
    avg(overpotential_mv) as hour_overpotential_mv,
    avg(voltage_delta_mv) as hour_voltage_delta_mv,
    avg(reported_charge_capacity_mah) as hour_reported_charge_capacity_mah,
    avg(reported_discharge_capacity_mah) as hour_reported_discharge_capacity_mah,
    avg(reported_charge_energy_mwh) as hour_reported_charge_energy_mwh,
    avg(reported_discharge_energy_mwh) as hour_reported_discharge_energy_mwh
FROM hil_data
GROUP BY hour,
    hil_id WITH NO DATA;

CREATE MATERIALIZED VIEW hil_data_summary_daily WITH (timescaledb.continuous) AS
SELECT time_bucket('1 day', insert_time) AS day,
    hil_id,
    avg(solution_time_ms) as day_solution_time_ms,
    avg(state_of_charge) as day_state_of_charge,
    avg(measured_voltage_mv) as day_measured_voltage_mv,
    avg(modeled_voltage_mv) as day_modeled_voltage_mv,
    avg(measured_current_ma) as day_measured_current_ma,
    avg(modeled_current_ma) as day_modeled_current_ma,
    avg(overpotential_mv) as day_overpotential_mv,
    avg(voltage_delta_mv) as day_voltage_delta_mv,
    avg(reported_charge_capacity_mah) as day_reported_charge_capacity_mah,
    avg(reported_discharge_capacity_mah) as day_reported_discharge_capacity_mah,
    avg(reported_charge_energy_mwh) as day_reported_charge_energy_mwh,
    avg(reported_discharge_energy_mwh) as day_reported_discharge_energy_mwh
FROM hil_data
GROUP BY day,
    hil_id WITH NO DATA;

-- sil_data
CREATE MATERIALIZED VIEW sil_data_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', insert_time) AS thirtysec, 
    sil_id,
    avg(measured_voltage_mv) as thirtysec_measured_voltage_mv, 
    avg(modeled_voltage_mv) as thirtysec_modeled_voltage_mv,
    avg(overpotential_mv) as thirtysec_overpotential_mv, 
    avg(solution_time_ms) as thirtysec_solution_time_ms, 
    avg(voltage_delta_mv) as thirtysec_voltage_delta_mv,   
    avg(modeled_current_ma) as thirtysec_modeled_current_ma, 
    avg(measured_current_ma) as thirtysec_measured_current_ma
    FROM sil_data
    GROUP BY thirtysec, sil_id
	    WITH NO DATA;

CREATE MATERIALIZED VIEW sil_data_summary_10min
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('10 minutes', insert_time) AS tenmin, 
    sil_id,
    avg(measured_voltage_mv) as tenmin_measured_voltage_mv, 
    avg(modeled_voltage_mv) as tenmin_modeled_voltage_mv,
    avg(overpotential_mv) as tenmin_overpotential_mv, 
    avg(solution_time_ms) as tenmin_solution_time_ms, 
    avg(voltage_delta_mv) as tenmin_voltage_delta_mv,   
    avg(modeled_current_ma) as tenmin_modeled_current_ma, 
    avg(measured_current_ma) as tenmin_measured_current_ma
    FROM sil_data
    GROUP BY tenmin, sil_id
    WITH NO DATA;

CREATE MATERIALIZED VIEW sil_data_summary_hourly
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 hour', insert_time) AS hour, 
    sil_id,
    avg(measured_voltage_mv) as hour_measured_voltage_mv, 
    avg(modeled_voltage_mv) as hour_modeled_voltage_mv,
    avg(overpotential_mv) as hour_overpotential_mv, 
    avg(solution_time_ms) as hour_solution_time_ms, 
    avg(voltage_delta_mv) as hour_voltage_delta_mv,   
    avg(modeled_current_ma) as hour_modeled_current_ma, 
    avg(measured_current_ma) as hour_measured_current_ma
    FROM sil_data
    GROUP BY hour, sil_id
    WITH NO DATA;

CREATE MATERIALIZED VIEW sil_data_summary_daily
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 day', insert_time) AS day, 
    sil_id,
    avg(measured_voltage_mv) as day_measured_voltage_mv, 
    avg(modeled_voltage_mv) as day_modeled_voltage_mv,
    avg(overpotential_mv) as day_overpotential_mv, 
    avg(solution_time_ms) as day_solution_time_ms, 
    avg(voltage_delta_mv) as day_voltage_delta_mv,   
    avg(modeled_current_ma) as day_modeled_current_ma, 
    avg(measured_current_ma) as day_measured_current_ma
    FROM sil_data
    GROUP BY day, sil_id
    WITH NO DATA;

-- sim_data
CREATE MATERIALIZED VIEW sim_data_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', insert_time) AS thirtysec, 
    sim_id,
    avg(measured_voltage_mv) as thirtysec_measured_voltage_mv, 
    avg(modeled_voltage_mv) as thirtysec_modeled_voltage_mv,
    avg(overpotential_mv) as thirtysec_overpotential_mv, 
    avg(solution_time_ms) as thirtysec_solution_time_ms, 
    avg(voltage_delta_mv) as thirtysec_voltage_delta_mv,   
    avg(modeled_current_ma) as thirtysec_modeled_current_ma, 
    avg(measured_current_ma) as thirtysec_measured_current_ma
    FROM sim_data
    GROUP BY thirtysec, sim_id
	    WITH NO DATA;

CREATE MATERIALIZED VIEW sim_data_summary_10min
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('10 minutes', insert_time) AS tenmin, 
    sim_id,
    avg(measured_voltage_mv) as tenmin_measured_voltage_mv, 
    avg(modeled_voltage_mv) as tenmin_modeled_voltage_mv,
    avg(overpotential_mv) as tenmin_overpotential_mv, 
    avg(solution_time_ms) as tenmin_solution_time_ms, 
    avg(voltage_delta_mv) as tenmin_voltage_delta_mv,   
    avg(modeled_current_ma) as tenmin_modeled_current_ma, 
    avg(measured_current_ma) as tenmin_measured_current_ma
    FROM sim_data
    GROUP BY tenmin, sim_id
    WITH NO DATA;

CREATE MATERIALIZED VIEW sim_data_summary_hourly
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 hour', insert_time) AS hour, 
    sim_id,
    avg(measured_voltage_mv) as hour_measured_voltage_mv, 
    avg(modeled_voltage_mv) as hour_modeled_voltage_mv,
    avg(overpotential_mv) as hour_overpotential_mv, 
    avg(solution_time_ms) as hour_solution_time_ms, 
    avg(voltage_delta_mv) as hour_voltage_delta_mv,   
    avg(modeled_current_ma) as hour_modeled_current_ma, 
    avg(measured_current_ma) as hour_measured_current_ma
    FROM sim_data
    GROUP BY hour, sim_id
    WITH NO DATA;

CREATE MATERIALIZED VIEW sim_data_summary_daily
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 day', insert_time) AS day, 
    sim_id,
    avg(measured_voltage_mv) as day_measured_voltage_mv, 
    avg(modeled_voltage_mv) as day_modeled_voltage_mv,
    avg(overpotential_mv) as day_overpotential_mv, 
    avg(solution_time_ms) as day_solution_time_ms, 
    avg(voltage_delta_mv) as day_voltage_delta_mv,   
    avg(modeled_current_ma) as day_modeled_current_ma, 
    avg(measured_current_ma) as day_measured_current_ma
    FROM sim_data
    GROUP BY day, sim_id
    WITH NO DATA;