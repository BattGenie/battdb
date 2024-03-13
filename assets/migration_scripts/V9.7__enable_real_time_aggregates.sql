-- The real time aggregates are DISABLED by default after timescaledb 2.13

ALTER MATERIALIZED VIEW cycler_rt_channel_statuses_summary_30s set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW cycler_rt_channel_statuses_summary_10min set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW cycler_rt_channel_statuses_summary_hourly set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW cycler_rt_channel_statuses_summary_daily set (timescaledb.materialized_only = false);

ALTER MATERIALIZED VIEW hil_data_summary_30s set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW hil_data_summary_10min set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW hil_data_summary_hourly set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW hil_data_summary_daily set (timescaledb.materialized_only = false);

ALTER MATERIALIZED VIEW sil_data_summary_30s set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW sil_data_summary_10min set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW sil_data_summary_hourly set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW sil_data_summary_daily set (timescaledb.materialized_only = false);

ALTER MATERIALIZED VIEW sim_data_summary_30s set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW sim_data_summary_10min set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW sim_data_summary_hourly set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW sim_data_summary_daily set (timescaledb.materialized_only = false);

ALTER MATERIALIZED VIEW test_data_summary_30s set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW test_data_summary_10min set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW test_data_summary_hourly set (timescaledb.materialized_only = false);
ALTER MATERIALIZED VIEW test_data_summary_daily set (timescaledb.materialized_only = false);
