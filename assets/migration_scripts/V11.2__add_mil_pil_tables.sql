-- mil tables 
-- mil_meta table

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS mil_meta_mil_id_seq;

-- Table Definition
CREATE TABLE "public"."mil_meta" (
    "mil_id" int4 NOT NULL DEFAULT nextval('mil_meta_mil_id_seq'::regclass),
    "launched_at" timestamptz NOT NULL DEFAULT now(),
    "status" text,
    "test_name" text,
    "schedule_name" text,
    "configs" jsonb,
    "other_details" jsonb,
    "user_id" text NOT NULL,
    "cell_id" int4,
    PRIMARY KEY ("mil_id")
);

-- Column Comments
COMMENT ON COLUMN "public"."mil_meta"."mil_id" IS 'Unique identifier for the MIL test. Auto-incremented upon insertion.';
COMMENT ON COLUMN "public"."mil_meta"."launched_at" IS 'The date and time the MIL test was launched.';
COMMENT ON COLUMN "public"."mil_meta"."status" IS 'The status of the MIL test.';
COMMENT ON COLUMN "public"."mil_meta"."test_name" IS 'The name of the MIL test.';
COMMENT ON COLUMN "public"."mil_meta"."schedule_name" IS 'The name of the schedule file used in cycler software.';
COMMENT ON COLUMN "public"."mil_meta"."configs" IS 'The configuration files used in the test.';
COMMENT ON COLUMN "public"."mil_meta"."other_details" IS 'Other details about the MIL test.';
COMMENT ON COLUMN "public"."mil_meta"."user_id" IS 'The user who launched the MIL test.';
COMMENT ON COLUMN "public"."mil_meta"."cell_id" IS 'The cell used in the MIL test. References the cell_id in the cells table.';

-- Comments
COMMENT ON TABLE "public"."mil_meta" IS 'Stores high-level information (meta-data) about the model-in-the-loop test.';

-- mil_data

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS mil_data_mil_data_id_seq;

-- Table Definition
CREATE TABLE "public"."mil_data" (
    "mil_data_id" int4 NOT NULL DEFAULT nextval('mil_data_mil_data_id_seq'::regclass),
    "mil_id" int4,
    "cycle" int2,
    "step" int2,
    "step_time_s" numeric,
    "test_time_s" numeric,
    "measured_voltage_mv" numeric,
    "modeled_voltage_mv" numeric,
    "voltage_delta_mv" numeric,
    "measured_current_ma" numeric,
    "modeled_current_ma" numeric,
    "datetime" timestamptz,
    "unixtime_s" numeric,
    "status" text,
    "overpotential_mv" numeric,
    "solution_time_ms" numeric,
    "model_states" _numeric,
    "insert_time" timestamptz NOT NULL DEFAULT now(),
    "other_details" jsonb,
    "reported_charge_capacity_mah" numeric,
    "reported_discharge_capacity_mah" numeric,
    "reported_charge_energy_mwh" numeric,
    "reported_discharge_energy_mwh" numeric,
    "state_of_charge" numeric,
    CONSTRAINT "mil_data_mil_id_fkey" FOREIGN KEY ("mil_id") REFERENCES "public"."mil_meta"("mil_id"),
    PRIMARY KEY ("mil_data_id")
);

alter table mil_data drop constraint mil_data_pkey;

SELECT create_hypertable('mil_data', 'insert_time',  chunk_time_interval => INTERVAL '1 day', migrate_data => TRUE, if_not_exists => TRUE);

-- Column Comments
COMMENT ON COLUMN "public"."mil_data"."mil_data_id" IS 'Unique identifier for the MIL data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN "public"."mil_data"."mil_id" IS 'Refers to the MIL test defined in mil_meta table.';
COMMENT ON COLUMN "public"."mil_data"."cycle" IS 'The cycle number of the data point. Tracks number of charge/discharge cycles.';
COMMENT ON COLUMN "public"."mil_data"."step" IS 'The step number of the data point.';
COMMENT ON COLUMN "public"."mil_data"."step_time_s" IS 'The time in seconds since the start of the step, ignoring pauses.';
COMMENT ON COLUMN "public"."mil_data"."test_time_s" IS 'The time in seconds since the start of the test, ignoring pauses.';
COMMENT ON COLUMN "public"."mil_data"."measured_voltage_mv" IS 'The voltage measured by the cycler during the data point.';
COMMENT ON COLUMN "public"."mil_data"."modeled_voltage_mv" IS 'The voltage predicted by the model during the data point.';
COMMENT ON COLUMN "public"."mil_data"."voltage_delta_mv" IS 'The difference between the measured and modeled voltage during the data point.';
COMMENT ON COLUMN "public"."mil_data"."measured_current_ma" IS 'The current measured by the cycler during the data point.';
COMMENT ON COLUMN "public"."mil_data"."modeled_current_ma" IS 'The current predicted by the model during the data point.';
COMMENT ON COLUMN "public"."mil_data"."datetime" IS 'The date and time the data point was recorded by cycler. Matches timezone of cycler.';
COMMENT ON COLUMN "public"."mil_data"."unixtime_s" IS 'The time in seconds since the Unix epoch (January 1, 1970). Calculated from recorded_datetime.';
COMMENT ON COLUMN "public"."mil_data"."status" IS 'The status of the cycler during the data point. Can be idle, rest, charge, discharge, problem, or other.';
COMMENT ON COLUMN "public"."mil_data"."overpotential_mv" IS 'The overpotential of the data point.';
COMMENT ON COLUMN "public"."mil_data"."solution_time_ms" IS 'The solution time of the data point.';
COMMENT ON COLUMN "public"."mil_data"."model_states" IS 'The model states during the data point.';
COMMENT ON COLUMN "public"."mil_data"."insert_time" IS 'Timestamp of insertion into the database.';
COMMENT ON COLUMN "public"."mil_data"."other_details" IS 'Other details about the MIL data point.';
COMMENT ON COLUMN "public"."mil_data"."reported_charge_capacity_mah" IS 'The charge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."mil_data"."reported_discharge_capacity_mah" IS 'The discharge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."mil_data"."reported_charge_energy_mwh" IS 'The charge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."mil_data"."reported_discharge_energy_mwh" IS 'The discharge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."mil_data"."state_of_charge" IS 'The state of charge reported by the cycler at the end of the cycle.';

-- Comments
COMMENT ON TABLE "public"."mil_data" IS 'Stores output data from model-in-the-loop test.';

-- materialized views on mil_data

CREATE MATERIALIZED VIEW mil_data_summary_30s WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('30 seconds', insert_time) AS thirtysec,
    mil_id,
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
    avg(reported_discharge_energy_mwh) as thirtysec_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as thirtysecl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as thirtysecl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as thirtysec_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as thirtysec_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as thirtysec_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as thirtysec_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as thirtysec_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as thirtysecl_faults_active,
    last(other_details -> 'mode_type', insert_time) as thirtysecl_mode_type
FROM mil_data
GROUP BY thirtysec,
    mil_id WITH NO DATA;

CREATE MATERIALIZED VIEW mil_data_summary_10min WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('10 minutes', insert_time) AS tenmin,
    mil_id,
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
    avg(reported_discharge_energy_mwh) as tenmin_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as tenminl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as tenminl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as tenmin_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as tenmin_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as tenmin_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as tenmin_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as tenmin_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as tenminl_faults_active,
    last(other_details -> 'mode_type', insert_time) as tenminl_mode_type
FROM mil_data
GROUP BY tenmin,
    mil_id WITH NO DATA;

CREATE MATERIALIZED VIEW mil_data_summary_hourly WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('1 hour', insert_time) AS hour,
    mil_id,
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
    avg(reported_discharge_energy_mwh) as hour_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as hourl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as hourl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as hour_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as hour_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as hour_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as hour_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as hour_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as hourl_faults_active,
    last(other_details -> 'mode_type', insert_time) as hourl_mode_type
FROM mil_data
GROUP BY hour,
    mil_id WITH NO DATA;

CREATE MATERIALIZED VIEW mil_data_summary_daily WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('1 day', insert_time) AS day,
    mil_id,
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
    avg(reported_discharge_energy_mwh) as day_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as dayl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as dayl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as day_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as day_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as day_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as day_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as day_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as dayl_faults_active,
    last(other_details -> 'mode_type', insert_time) as dayl_mode_type
FROM mil_data
GROUP BY day,
    mil_id WITH NO DATA;

-- comments
-- mil_data_summary_30s;
COMMENT ON VIEW public.mil_data_summary_30s IS 'Materialized view of mil_data table aggregated by 30 second intervals.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec IS 'The datetime rounded to the nearest 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.mil_id IS 'Refers to the MIL test defined in mil_meta table.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_solution_time_ms IS 'The average solution time of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_state_of_charge IS 'The average state of charge of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_measured_voltage_mv IS 'The average measured voltage of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_modeled_voltage_mv IS 'The average modeled voltage of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_measured_current_ma IS 'The average measured current of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_modeled_current_ma IS 'The average modeled current of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_overpotential_mv IS 'The average overpotential of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_voltage_delta_mv IS 'The average voltage delta of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_reported_charge_capacity_mah IS 'The average reported charge capacity of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_reported_charge_energy_mwh IS 'The average reported charge energy of the MIL test for the 30 second interval.';
COMMENT ON COLUMN public.mil_data_summary_30s.thirtysec_reported_discharge_energy_mwh IS 'The average reported discharge energy of the MIL test for the 30 second interval.';

-- mil_data_summary_10min
COMMENT ON VIEW public.mil_data_summary_10min IS 'Materialized view of mil_data table aggregated by 10 minute intervals.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin IS 'The datetime rounded to the nearest 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.mil_id IS 'Refers to the MIL test defined in mil_meta table.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_solution_time_ms IS 'The average solution time of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_state_of_charge IS 'The average state of charge of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_measured_voltage_mv IS 'The average measured voltage of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_modeled_voltage_mv IS 'The average modeled voltage of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_measured_current_ma IS 'The average measured current of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_modeled_current_ma IS 'The average modeled current of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_overpotential_mv IS 'The average overpotential of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_voltage_delta_mv IS 'The average voltage delta of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_reported_charge_capacity_mah IS 'The average reported charge capacity of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_reported_charge_energy_mwh IS 'The average reported charge energy of the MIL test for the 10 minute interval.';
COMMENT ON COLUMN public.mil_data_summary_10min.tenmin_reported_discharge_energy_mwh IS 'The average reported discharge energy of the MIL test for the 10 minute interval.';

-- mil_data_summary_hourly
COMMENT ON VIEW public.mil_data_summary_hourly IS 'Materialized view of mil_data table aggregated by hourly intervals.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour IS 'The datetime rounded to the nearest hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.mil_id IS 'Refers to the MIL test defined in mil_meta table.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_solution_time_ms IS 'The average solution time of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_state_of_charge IS 'The average state of charge of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_measured_voltage_mv IS 'The average measured voltage of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_modeled_voltage_mv IS 'The average modeled voltage of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_measured_current_ma IS 'The average measured current of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_modeled_current_ma IS 'The average modeled current of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_overpotential_mv IS 'The average overpotential of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_voltage_delta_mv IS 'The average voltage delta of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_reported_charge_capacity_mah IS 'The average reported charge capacity of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_reported_charge_energy_mwh IS 'The average reported charge energy of the MIL test for the hour.';
COMMENT ON COLUMN public.mil_data_summary_hourly.hour_reported_discharge_energy_mwh IS 'The average reported discharge energy of the MIL test for the hour.';

-- mil_data_summary_daily
COMMENT ON VIEW public.mil_data_summary_daily IS 'Materialized view of mil_data table aggregated by daily intervals.';
COMMENT ON COLUMN public.mil_data_summary_daily.day IS 'The datetime rounded to the nearest day.';
COMMENT ON COLUMN public.mil_data_summary_daily.mil_id IS 'Refers to the MIL test defined in mil_meta table.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_solution_time_ms IS 'The average solution time of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_state_of_charge IS 'The average state of charge of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_measured_voltage_mv IS 'The average measured voltage of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_modeled_voltage_mv IS 'The average modeled voltage of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_measured_current_ma IS 'The average measured current of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_modeled_current_ma IS 'The average modeled current of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_overpotential_mv IS 'The average overpotential of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_voltage_delta_mv IS 'The average voltage delta of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_reported_charge_capacity_mah IS 'The average reported charge capacity of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_reported_charge_energy_mwh IS 'The average reported charge energy of the MIL test for the day.';
COMMENT ON COLUMN public.mil_data_summary_daily.day_reported_discharge_energy_mwh IS 'The average reported discharge energy of the MIL test for the day.';


-- pil tables 
-- pil_meta table

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS pil_meta_pil_id_seq;

-- Table Definition
CREATE TABLE "public"."pil_meta" (
    "pil_id" int4 NOT NULL DEFAULT nextval('pil_meta_pil_id_seq'::regclass),
    "launched_at" timestamptz NOT NULL DEFAULT now(),
    "status" text,
    "test_name" text,
    "schedule_name" text,
    "configs" jsonb,
    "other_details" jsonb,
    "user_id" text NOT NULL,
    "cell_id" int4,
    PRIMARY KEY ("pil_id")
);

-- Column Comments
COMMENT ON COLUMN "public"."pil_meta"."pil_id" IS 'Unique identifier for the PIL test. Auto-incremented upon insertion.';
COMMENT ON COLUMN "public"."pil_meta"."launched_at" IS 'The date and time the MIL test was launched.';
COMMENT ON COLUMN "public"."pil_meta"."status" IS 'The status of the MIL test.';
COMMENT ON COLUMN "public"."pil_meta"."test_name" IS 'The name of the MIL test.';
COMMENT ON COLUMN "public"."pil_meta"."schedule_name" IS 'The name of the schedule file used in cycler software.';
COMMENT ON COLUMN "public"."pil_meta"."configs" IS 'The configuration files used in the test.';
COMMENT ON COLUMN "public"."pil_meta"."other_details" IS 'Other details about the MIL test.';
COMMENT ON COLUMN "public"."pil_meta"."user_id" IS 'The user who launched the MIL test.';
COMMENT ON COLUMN "public"."pil_meta"."cell_id" IS 'The cell used in the MIL test. References the cell_id in the cells table.';

-- Comments
COMMENT ON TABLE "public"."pil_meta" IS 'Stores high-level information (meta-data) about the processor-in-the-loop test.';

-- pil_data

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS pil_data_pil_data_id_seq;

-- Table Definition
CREATE TABLE "public"."pil_data" (
    "pil_data_id" int4 NOT NULL DEFAULT nextval('pil_data_pil_data_id_seq'::regclass),
    "pil_id" int4,
    "cycle" int2,
    "step" int2,
    "step_time_s" numeric,
    "test_time_s" numeric,
    "measured_voltage_mv" numeric,
    "modeled_voltage_mv" numeric,
    "voltage_delta_mv" numeric,
    "measured_current_ma" numeric,
    "modeled_current_ma" numeric,
    "datetime" timestamptz,
    "unixtime_s" numeric,
    "status" text,
    "overpotential_mv" numeric,
    "solution_time_ms" numeric,
    "model_states" _numeric,
    "insert_time" timestamptz NOT NULL DEFAULT now(),
    "other_details" jsonb,
    "reported_charge_capacity_mah" numeric,
    "reported_discharge_capacity_mah" numeric,
    "reported_charge_energy_mwh" numeric,
    "reported_discharge_energy_mwh" numeric,
    "state_of_charge" numeric,
    CONSTRAINT "pil_data_pil_id_fkey" FOREIGN KEY ("pil_id") REFERENCES "public"."pil_meta"("pil_id"),
    PRIMARY KEY ("pil_data_id")
);

alter table pil_data drop constraint pil_data_pkey;

SELECT create_hypertable('pil_data', 'insert_time',  chunk_time_interval => INTERVAL '1 day', migrate_data => TRUE, if_not_exists => TRUE);

-- Column Comments
COMMENT ON COLUMN "public"."pil_data"."pil_data_id" IS 'Unique identifier for the PIL data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN "public"."pil_data"."pil_id" IS 'Refers to the PIL test defined in mil_meta table.';
COMMENT ON COLUMN "public"."pil_data"."cycle" IS 'The cycle number of the data point. Tracks number of charge/discharge cycles.';
COMMENT ON COLUMN "public"."pil_data"."step" IS 'The step number of the data point.';
COMMENT ON COLUMN "public"."pil_data"."step_time_s" IS 'The time in seconds since the start of the step, ignoring pauses.';
COMMENT ON COLUMN "public"."pil_data"."test_time_s" IS 'The time in seconds since the start of the test, ignoring pauses.';
COMMENT ON COLUMN "public"."pil_data"."measured_voltage_mv" IS 'The voltage measured by the cycler during the data point.';
COMMENT ON COLUMN "public"."pil_data"."modeled_voltage_mv" IS 'The voltage predicted by the model during the data point.';
COMMENT ON COLUMN "public"."pil_data"."voltage_delta_mv" IS 'The difference between the measured and modeled voltage during the data point.';
COMMENT ON COLUMN "public"."pil_data"."measured_current_ma" IS 'The current measured by the cycler during the data point.';
COMMENT ON COLUMN "public"."pil_data"."modeled_current_ma" IS 'The current predicted by the model during the data point.';
COMMENT ON COLUMN "public"."pil_data"."datetime" IS 'The date and time the data point was recorded by cycler. Matches timezone of cycler.';
COMMENT ON COLUMN "public"."pil_data"."unixtime_s" IS 'The time in seconds since the Unix epoch (January 1, 1970). Calculated from recorded_datetime.';
COMMENT ON COLUMN "public"."pil_data"."status" IS 'The status of the cycler during the data point. Can be idle, rest, charge, discharge, problem, or other.';
COMMENT ON COLUMN "public"."pil_data"."overpotential_mv" IS 'The overpotential of the data point.';
COMMENT ON COLUMN "public"."pil_data"."solution_time_ms" IS 'The solution time of the data point.';
COMMENT ON COLUMN "public"."pil_data"."model_states" IS 'The model states during the data point.';
COMMENT ON COLUMN "public"."pil_data"."insert_time" IS 'Timestamp of insertion into the database.';
COMMENT ON COLUMN "public"."pil_data"."other_details" IS 'Other details about the PIL data point.';
COMMENT ON COLUMN "public"."pil_data"."reported_charge_capacity_mah" IS 'The charge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."pil_data"."reported_discharge_capacity_mah" IS 'The discharge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."pil_data"."reported_charge_energy_mwh" IS 'The charge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."pil_data"."reported_discharge_energy_mwh" IS 'The discharge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN "public"."pil_data"."state_of_charge" IS 'The state of charge reported by the cycler at the end of the cycle.';

-- Comments
COMMENT ON TABLE "public"."pil_data" IS 'Stores output data from processor-in-the-loop test.';

-- materialized views on pil_data

CREATE MATERIALIZED VIEW pil_data_summary_30s WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('30 seconds', insert_time) AS thirtysec,
    pil_id,
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
    avg(reported_discharge_energy_mwh) as thirtysec_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as thirtysecl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as thirtysecl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as thirtysec_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as thirtysec_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as thirtysec_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as thirtysec_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as thirtysec_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as thirtysecl_faults_active,
    last(other_details -> 'mode_type', insert_time) as thirtysecl_mode_type
FROM pil_data
GROUP BY thirtysec,
    pil_id WITH NO DATA;

CREATE MATERIALIZED VIEW pil_data_summary_10min WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('10 minutes', insert_time) AS tenmin,
    pil_id,
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
    avg(reported_discharge_energy_mwh) as tenmin_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as tenminl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as tenminl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as tenmin_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as tenmin_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as tenmin_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as tenmin_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as tenmin_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as tenminl_faults_active,
    last(other_details -> 'mode_type', insert_time) as tenminl_mode_type
FROM pil_data
GROUP BY tenmin,
    pil_id WITH NO DATA;

CREATE MATERIALIZED VIEW pil_data_summary_hourly WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('1 hour', insert_time) AS hour,
    pil_id,
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
    avg(reported_discharge_energy_mwh) as hour_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as hourl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as hourl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as hour_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as hour_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as hour_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as hour_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as hour_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as hourl_faults_active,
    last(other_details -> 'mode_type', insert_time) as hourl_mode_type
FROM pil_data
GROUP BY hour,
    pil_id WITH NO DATA;

CREATE MATERIALIZED VIEW pil_data_summary_daily WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
SELECT time_bucket('1 day', insert_time) AS day,
    pil_id,
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
    avg(reported_discharge_energy_mwh) as day_reported_discharge_energy_mwh,
    last(other_details -> 'cell_voltages_mv', insert_time) as dayl_cell_voltages_mv,
    last(other_details -> 'cell_socs_percentage', insert_time) as dayl_cell_socs_percentage,
    avg((other_details -> 'pack_soc_percentage')::numeric) as day_pack_soc_percentage,
    avg((other_details -> 'charger_reported_current_ma')::numeric) as day_charger_reported_current_ma,
    avg((other_details -> 'charger_reported_voltage_mv')::numeric) as day_charger_reported_voltage_mv,
    avg((other_details -> 'load_reported_voltage_mv')::numeric) as day_load_reported_voltage_mv,
    avg((other_details -> 'load_reported_current_ma')::numeric) as day_load_reported_current_ma,
    last(other_details -> 'faults_active', insert_time) as dayl_faults_active,
    last(other_details -> 'mode_type', insert_time) as dayl_mode_type
FROM pil_data
GROUP BY day,
    pil_id WITH NO DATA;

-- pil_data_summary_30s;
COMMENT ON VIEW public.pil_data_summary_30s IS 'Materialized view of pil_data table aggregated by 30 second intervals.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec IS 'The datetime rounded to the nearest 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.pil_id IS 'Refers to the PIL test defined in pil_meta table.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_solution_time_ms IS 'The average solution time of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_state_of_charge IS 'The average state of charge of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_measured_voltage_mv IS 'The average measured voltage of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_modeled_voltage_mv IS 'The average modeled voltage of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_measured_current_ma IS 'The average measured current of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_modeled_current_ma IS 'The average modeled current of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_overpotential_mv IS 'The average overpotential of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_voltage_delta_mv IS 'The average voltage delta of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_reported_charge_capacity_mah IS 'The average reported charge capacity of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_reported_charge_energy_mwh IS 'The average reported charge energy of the PIL test for the 30 second interval.';
COMMENT ON COLUMN public.pil_data_summary_30s.thirtysec_reported_discharge_energy_mwh IS 'The average reported discharge energy of the PIL test for the 30 second interval.';

-- pil_data_summary_10min
COMMENT ON VIEW public.pil_data_summary_10min IS 'Materialized view of pil_data table aggregated by 10 minute intervals.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin IS 'The datetime rounded to the nearest 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.pil_id IS 'Refers to the PIL test defined in pil_meta table.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_solution_time_ms IS 'The average solution time of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_state_of_charge IS 'The average state of charge of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_measured_voltage_mv IS 'The average measured voltage of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_modeled_voltage_mv IS 'The average modeled voltage of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_measured_current_ma IS 'The average measured current of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_modeled_current_ma IS 'The average modeled current of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_overpotential_mv IS 'The average overpotential of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_voltage_delta_mv IS 'The average voltage delta of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_reported_charge_capacity_mah IS 'The average reported charge capacity of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_reported_charge_energy_mwh IS 'The average reported charge energy of the PIL test for the 10 minute interval.';
COMMENT ON COLUMN public.pil_data_summary_10min.tenmin_reported_discharge_energy_mwh IS 'The average reported discharge energy of the PIL test for the 10 minute interval.';

-- pil_data_summary_hourly
COMMENT ON VIEW public.pil_data_summary_hourly IS 'Materialized view of pil_data table aggregated by hourly intervals.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour IS 'The datetime rounded to the nearest hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.pil_id IS 'Refers to the PIL test defined in pil_meta table.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_solution_time_ms IS 'The average solution time of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_state_of_charge IS 'The average state of charge of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_measured_voltage_mv IS 'The average measured voltage of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_modeled_voltage_mv IS 'The average modeled voltage of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_measured_current_ma IS 'The average measured current of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_modeled_current_ma IS 'The average modeled current of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_overpotential_mv IS 'The average overpotential of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_voltage_delta_mv IS 'The average voltage delta of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_reported_charge_capacity_mah IS 'The average reported charge capacity of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_reported_charge_energy_mwh IS 'The average reported charge energy of the PIL test for the hour.';
COMMENT ON COLUMN public.pil_data_summary_hourly.hour_reported_discharge_energy_mwh IS 'The average reported discharge energy of the PIL test for the hour.';

-- pil_data_summary_daily
COMMENT ON VIEW public.pil_data_summary_daily IS 'Materialized view of pil_data table aggregated by daily intervals.';
COMMENT ON COLUMN public.pil_data_summary_daily.day IS 'The datetime rounded to the nearest day.';
COMMENT ON COLUMN public.pil_data_summary_daily.pil_id IS 'Refers to the PIL test defined in pil_meta table.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_solution_time_ms IS 'The average solution time of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_state_of_charge IS 'The average state of charge of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_measured_voltage_mv IS 'The average measured voltage of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_modeled_voltage_mv IS 'The average modeled voltage of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_measured_current_ma IS 'The average measured current of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_modeled_current_ma IS 'The average modeled current of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_overpotential_mv IS 'The average overpotential of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_voltage_delta_mv IS 'The average voltage delta of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_reported_charge_capacity_mah IS 'The average reported charge capacity of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_reported_charge_energy_mwh IS 'The average reported charge energy of the PIL test for the day.';
COMMENT ON COLUMN public.pil_data_summary_daily.day_reported_discharge_energy_mwh IS 'The average reported discharge energy of the PIL test for the day.';
