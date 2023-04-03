-- Remove the old tables
DROP TABLE arbin_profiles;
DROP TABLE arbin_schedules;
DROP TABLE maccor_profiles;
DROP TABLE maccor_schedules;
DROP TABLE swell_measurements;

-- Modify the cells table
ALTER TABLE cells DROP COLUMN bg_sn;
ALTER TABLE cells
    RENAME COLUMN voltage_mv TO first_received_at_voltage_mv;

-- Modify the test_meta table
ALTER TABLE test_meta DROP COLUMN data_file;
ALTER TABLE test_meta
    RENAME COLUMN thermocouple TO thermocouples;
ALTER TABLE test_meta
    RENAME thermocouple_channel TO thermocouple_channels;

-- Modify the schedules_meta table
ALTER TABLE schedules_meta
    RENAME TO schedule_meta;
ALTER TABLE schedule_meta DROP COLUMN last_modified;
ALTER TABLE schedule_meta DROP COLUMN modified_by;
ALTER TABLE schedule_meta DROP COLUMN profile_id;
ALTER TABLE schedule_meta DROP COLUMN charge_steps;
ALTER TABLE schedule_meta DROP COLUMN discharge_steps;
ALTER TABLE schedule_meta DROP COLUMN rpt_charge_steps;
ALTER TABLE schedule_meta DROP COLUMN rpt_discharge_steps;
ALTER TABLE schedule_meta DROP COLUMN impedance_steps;
ALTER TABLE schedule_meta
    RENAME COLUMN schedule_file TO schedule_files;

-- Create tables to support hil data
CREATE TABLE public.hil_meta (
    hil_id SERIAL PRIMARY KEY,
    launched_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    status TEXT,
    test_name TEXT,
    procedure_name TEXT,
    configs JSONB,
    other_details JSONB
);
CREATE TABLE public.hil_data (
    hil_data_id serial primary key,
    hil_id INTEGER REFERENCES hil_meta (hil_id),
    cycle SMALLINT,
    step SMALLINT,
    step_time_s NUMERIC,
    test_time_s NUMERIC,
    measured_voltage_mv SMALLINT,
    modeled_voltage_mv SMALLINT,
    voltage_delta_mv SMALLINT,
    measured_current_ma SMALLINT,
    optimal_current_ma SMALLINT,
    datetime timestamp with time zone,
    unixtime_s NUMERIC,
    state TEXT,
    overpotential_mv SMALLINT,
    solution_time_ms SMALLINT,
    model_states NUMERIC [],
    insert_time TIMESTAMPTZ DEFAULT now() NOT NULL
);