-- Convert the test_data table to a Timescale hypertable

alter table test_data drop constraint test_data_id;

SELECT create_hypertable('test_data', 'recorded_datetime',  chunk_time_interval => INTERVAL '1 day', migrate_data => TRUE, if_not_exists => TRUE);
