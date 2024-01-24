-- Rename column name id to channel_status_id
ALTER TABLE public.cycler_rt_channel_statuses RENAME COLUMN id TO channel_status_id;

-- Convert the cycler_rt_channel_statuses table to a Timescale hypertable
ALTER TABLE cycler_rt_channel_statuses drop constraint cycler_monitor_channel_statuses_pkey;
SELECT create_hypertable('cycler_rt_channel_statuses', 'insert_time',  chunk_time_interval => INTERVAL '1 day', migrate_data => TRUE, if_not_exists => TRUE);

-- Create materialized views for cycler_rt_channel_statuses
CREATE MATERIALIZED VIEW cycler_rt_channel_statuses_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', insert_time) AS thirtysec,
    cycler_rt_channel_statuses.cycler_id,
    cycler_rt_channel_statuses.channel,
    avg(cycler_rt_channel_statuses.voltage_mv) as thirtysec_voltage_mv,
    avg(cycler_rt_channel_statuses.current_ma) as thirtysec_current_ma,
    avg(cycler_rt_channel_statuses.charge_capacity_mah) as thirtysec_charge_capacity_mah,
    avg(cycler_rt_channel_statuses.discharge_capacity_mah) as thirtysec_discharge_capacity_mah,
    avg(cycler_rt_channel_statuses.charge_energy_mwh) as thirtysec_charge_energy_mwh,
    avg(cycler_rt_channel_statuses.discharge_energy_mwh) as thirtysec_discharge_energy_mwh
    FROM cycler_rt_channel_statuses
    GROUP BY thirtysec, cycler_rt_channel_statuses.cycler_id, cycler_rt_channel_statuses.channel
    WITH NO DATA;

CREATE MATERIALIZED VIEW cycler_rt_channel_statuses_summary_10min
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('10 minutes', insert_time) AS tenmin,
    cycler_rt_channel_statuses.cycler_id,
    cycler_rt_channel_statuses.channel,
    avg(cycler_rt_channel_statuses.voltage_mv) as tenmin_voltage_mv,
    avg(cycler_rt_channel_statuses.current_ma) as tenmin_current_ma,
    avg(cycler_rt_channel_statuses.charge_capacity_mah) as tenmin_charge_capacity_mah,
    avg(cycler_rt_channel_statuses.discharge_capacity_mah) as tenmin_discharge_capacity_mah,
    avg(cycler_rt_channel_statuses.charge_energy_mwh) as tenmin_charge_energy_mwh,
    avg(cycler_rt_channel_statuses.discharge_energy_mwh) as tenmin_discharge_energy_mwh
    FROM cycler_rt_channel_statuses
    GROUP BY tenmin, cycler_rt_channel_statuses.cycler_id, cycler_rt_channel_statuses.channel
    WITH NO DATA;

CREATE MATERIALIZED VIEW cycler_rt_channel_statuses_summary_hourly
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 hour', insert_time) AS hour,
    cycler_rt_channel_statuses.cycler_id,
    cycler_rt_channel_statuses.channel,
    avg(cycler_rt_channel_statuses.voltage_mv) as hour_voltage_mv,
    avg(cycler_rt_channel_statuses.current_ma) as hour_current_ma,
    avg(cycler_rt_channel_statuses.charge_capacity_mah) as hour_charge_capacity_mah,
    avg(cycler_rt_channel_statuses.discharge_capacity_mah) as hour_discharge_capacity_mah,
    avg(cycler_rt_channel_statuses.charge_energy_mwh) as hour_charge_energy_mwh,
    avg(cycler_rt_channel_statuses.discharge_energy_mwh) as hour_discharge_energy_mwh
    FROM cycler_rt_channel_statuses
    GROUP BY hour, cycler_rt_channel_statuses.cycler_id, cycler_rt_channel_statuses.channel
    WITH NO DATA;

CREATE MATERIALIZED VIEW cycler_rt_channel_statuses_summary_daily
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 day', insert_time) AS day,
    cycler_rt_channel_statuses.cycler_id,
    cycler_rt_channel_statuses.channel,
    avg(cycler_rt_channel_statuses.voltage_mv) as day_voltage_mv,
    avg(cycler_rt_channel_statuses.current_ma) as day_current_ma,
    avg(cycler_rt_channel_statuses.charge_capacity_mah) as day_charge_capacity_mah,
    avg(cycler_rt_channel_statuses.discharge_capacity_mah) as day_discharge_capacity_mah,
    avg(cycler_rt_channel_statuses.charge_energy_mwh) as day_charge_energy_mwh,
    avg(cycler_rt_channel_statuses.discharge_energy_mwh) as day_discharge_energy_mwh
    FROM cycler_rt_channel_statuses
    GROUP BY day, cycler_rt_channel_statuses.cycler_id, cycler_rt_channel_statuses.channel
    WITH NO DATA;
