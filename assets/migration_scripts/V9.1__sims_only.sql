-- Scripts to store simulation data 
CREATE TABLE IF NOT EXISTS public.sim_meta (
    sim_id SERIAL NOT NULL PRIMARY KEY,
    launched_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id text NOT NULL,
    status text,
    cell_type_id integer,
    test_id integer,
    configs jsonb,
    other_details jsonb,
    CONSTRAINT sim_meta_cell_type_id_fkey FOREIGN KEY (cell_type_id)
        REFERENCES public.cells_meta (cell_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT sim_meta_test_id_fkey FOREIGN KEY (test_id)
        REFERENCES public.test_meta (test_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


CREATE TABLE IF NOT EXISTS public.sim_data
(
    sim_data_id SERIAL NOT NULL,
    sim_id integer,
    test_data_id integer,
    cycle smallint,
    test_time_s numeric,
    measured_voltage_mv smallint,
    modeled_voltage_mv smallint,
    voltage_delta_mv smallint,
    measured_current_ma smallint,
    overpotential_mv smallint,
    solution_time_ms smallint,
    insert_time timestamp with time zone NOT NULL DEFAULT now(),
    modeled_current_ma smallint,
    model_states numeric[],
    other_details jsonb,
    recorded_datetime timestamp with time zone,
    CONSTRAINT sim_data_sim_id_fkey FOREIGN KEY (sim_id)
        REFERENCES public.sim_meta (sim_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

SELECT create_hypertable('sim_data', 'insert_time',  chunk_time_interval => INTERVAL '1 day', migrate_data => TRUE, if_not_exists => TRUE);

CREATE MATERIALIZED VIEW sim_data_summary_10min
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('10 minutes', insert_time) AS tenmin, 
    avg(measured_voltage_mv) as tenmin_measured_voltage_mv, 
    avg(modeled_voltage_mv) as tenmin_modeled_voltage_mv,
    avg(overpotential_mv) as tenmin_overpotential_mv, 
    avg(solution_time_ms) as tenmin_solution_time_ms, 
    avg(voltage_delta_mv) as tenmin_voltage_delta_mv,   
    avg(modeled_current_ma) as tenmin_modeled_current_ma, 
    avg(measured_current_ma) as tenmin_measured_current_ma
    FROM sim_data
    GROUP BY tenmin
    WITH NO DATA;
	
CREATE MATERIALIZED VIEW sim_data_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', insert_time) AS thirtysec, 
    avg(measured_voltage_mv) as thirtysec_measured_voltage_mv, 
    avg(modeled_voltage_mv) as thirtysec_modeled_voltage_mv,
    avg(overpotential_mv) as thirtysecn_overpotential_mv, 
    avg(solution_time_ms) as thirtysec_solution_time_ms, 
    avg(voltage_delta_mv) as thirtysec_voltage_delta_mv,   
    avg(modeled_current_ma) as thirtysec_modeled_current_ma, 
    avg(measured_current_ma) as thirtysec_measured_current_ma
    FROM sim_data
    GROUP BY thirtysec
	    WITH NO DATA;
	
CREATE MATERIALIZED VIEW sim_data_summary_hourly
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 hour', insert_time) AS hour, 
    avg(measured_voltage_mv) as hour_measured_voltage_mv, 
    avg(modeled_voltage_mv) as hour_modeled_voltage_mv,
    avg(overpotential_mv) as hour_overpotential_mv, 
    avg(solution_time_ms) as hour_solution_time_ms, 
    avg(voltage_delta_mv) as hour_voltage_delta_mv,   
    avg(modeled_current_ma) as hour_modeled_current_ma, 
    avg(measured_current_ma) as hour_measured_current_ma
    FROM sim_data
    GROUP BY hour
    WITH NO DATA;

CREATE MATERIALIZED VIEW sim_data_summary_daily
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('1 day', insert_time) AS day, 
    avg(measured_voltage_mv) as day_measured_voltage_mv, 
    avg(modeled_voltage_mv) as day_modeled_voltage_mv,
    avg(overpotential_mv) as day_overpotential_mv, 
    avg(solution_time_ms) as day_solution_time_ms, 
    avg(voltage_delta_mv) as day_voltage_delta_mv,   
    avg(modeled_current_ma) as day_modeled_current_ma, 
    avg(measured_current_ma) as day_measured_current_ma
    FROM sim_data
    GROUP BY day
    WITH NO DATA;