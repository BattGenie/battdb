-- test_meta

CREATE SEQUENCE IF NOT EXISTS testdata_meta_test_id_seq;

CREATE TABLE "public"."test_meta" (
    "test_id" int4 NOT NULL DEFAULT nextval('testdata_meta_test_id_seq'::regclass),
    "cell_id" int2,
    "schedule_id" int2,
    "test_name" text,
    "start_date" date,
    "end_date" date,
    "channel" int2,
    "ev_chamber" int2,
    "ev_chamber_slot" int2,
    "thermocouples" int2,
    "thermocouple_channels" int2,
    "comments" text,
    "project_id" int4,
    "test_capacity_mah" int4,
    "potentiostat_id" _int4,
    "cycler_id" int4,
    PRIMARY KEY ("test_id")
);


-- test_data

CREATE SEQUENCE IF NOT EXISTS testdata_test_data_id_seq;

CREATE TABLE "public"."test_data" (
    "test_data_id" int4 NOT NULL DEFAULT nextval('testdata_test_data_id_seq'::regclass),
    "test_id" int2 NOT NULL,
    "cycle" int2,
    "step" int2,
    "test_time_s" numeric,
    "step_time_s" numeric,
    "current_ma" numeric NOT NULL,
    "voltage_mv" numeric NOT NULL,
    "recorded_datetime" timestamptz NOT NULL,
    "unixtime_s" numeric NOT NULL,
    "thermocouple_temps_c" _numeric,
    "other_details" jsonb,
    CONSTRAINT "testdata_test_id_fkey" FOREIGN KEY ("test_id") REFERENCES "public"."test_meta"("test_id"),
    PRIMARY KEY ("test_data_id")
);


-- test_data_cycle_stats

CREATE SEQUENCE IF NOT EXISTS testdata_cyclestats_cyclestats_id_seq;

CREATE TABLE "public"."test_data_cycle_stats" (
    "cycle_stats_id" int4 NOT NULL DEFAULT nextval('testdata_cyclestats_cyclestats_id_seq'::regclass),
    "test_id" int2 NOT NULL,
    "cycle" int2,
    "test_time_s" int4,
    "reported_charge_capacity_mah" numeric,
    "reported_discharge_capacity_mah" numeric,
    "reported_charge_energy_mwh" numeric,
    "reported_discharge_energy_mwh" numeric,
    "calculated_charge_capacity_mah" numeric,
    "calculated_max_charge_temp_c" numeric,
    "calculated_discharge_capacity_mah" numeric,
    "calculated_max_discharge_temp_c" numeric,
    "calculated_cc_charge_time_s" numeric,
    "calculated_cv_charge_time_s" numeric,
    "calculated_cc_capacity_mah" numeric,
    "calculated_cv_capacity_mah" numeric,
    "calculated_coulombic_efficiency" numeric,
    "reported_coulombic_efficiency" numeric,
    "reported_charge_time_s" numeric,
    "reported_discharge_time_s" numeric,
    "calculated_fifty_percent_charge_time_s" numeric,
    "calculated_eighty_percent_charge_time_s" numeric,
    "calculated_charge_energy_mwh" numeric,
    "calculated_discharge_energy_mwh" numeric,
    "other_details" jsonb,
    CONSTRAINT "testdata_cyclestats_test_id_fkey" FOREIGN KEY ("test_id") REFERENCES "public"."test_meta"("test_id"),
    PRIMARY KEY ("cycle_stats_id")
);
