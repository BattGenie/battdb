--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA audit;


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: audit_table(regclass); Type: FUNCTION; Schema: audit; Owner: -
--

CREATE FUNCTION audit.audit_table(target_table regclass) RETURNS void
    LANGUAGE sql
    AS $_$
SELECT audit.audit_table($1, BOOLEAN 't', BOOLEAN 't');
$_$;


--
-- Name: audit_table(regclass, boolean, boolean); Type: FUNCTION; Schema: audit; Owner: -
--

CREATE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean) RETURNS void
    LANGUAGE sql
    AS $_$
SELECT audit.audit_table($1, $2, $3, ARRAY[]::text[]);
$_$;


--
-- Name: audit_table(regclass, boolean, boolean, text[]); Type: FUNCTION; Schema: audit; Owner: -
--

CREATE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  stm_targets text = 'INSERT OR UPDATE OR DELETE OR TRUNCATE';
  _q_txt text;
  _ignored_cols_snip text = '';
BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_row ON ' || target_table;
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_stm ON ' || target_table;

    IF audit_rows THEN
        IF array_length(ignored_cols,1) > 0 THEN
            _ignored_cols_snip = ', ' || quote_literal(ignored_cols);
        END IF;
        _q_txt = 'CREATE TRIGGER audit_trigger_row AFTER INSERT OR UPDATE OR DELETE ON ' || 
                 target_table || 
                 ' FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func(' ||
                 quote_literal(audit_query_text) || _ignored_cols_snip || ');';
        RAISE NOTICE '%',_q_txt;
        EXECUTE _q_txt;
        stm_targets = 'TRUNCATE';
    ELSE
    END IF;

    _q_txt = 'CREATE TRIGGER audit_trigger_stm AFTER ' || stm_targets || ' ON ' ||
             target_table ||
             ' FOR EACH STATEMENT EXECUTE PROCEDURE audit.if_modified_func('||
             quote_literal(audit_query_text) || ');';
    RAISE NOTICE '%',_q_txt;
    EXECUTE _q_txt;

END;
$$;


--
-- Name: if_modified_func(); Type: FUNCTION; Schema: audit; Owner: -
--

CREATE FUNCTION audit.if_modified_func() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
DECLARE
    audit_row audit.logged_actions;
    include_values boolean;
    log_diffs boolean;
    h_old hstore;
    h_new hstore;
    excluded_cols text[] = ARRAY[]::text[];
BEGIN
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as an AFTER trigger';
    END IF;

    audit_row = ROW(
        nextval('audit.logged_actions_event_id_seq'), -- event_id
        TG_TABLE_SCHEMA::text,                        -- schema_name
        TG_TABLE_NAME::text,                          -- table_name
        TG_RELID,                                     -- relation OID for much quicker searches
        session_user::text,                           -- session_user_name
        current_timestamp,                            -- action_tstamp_tx
        statement_timestamp(),                        -- action_tstamp_stm
        clock_timestamp(),                            -- action_tstamp_clk
        txid_current(),                               -- transaction ID
        current_setting('application_name'),          -- client application
        inet_client_addr(),                           -- client_addr
        inet_client_port(),                           -- client_port
        current_query(),                              -- top-level query or queries (if multistatement) from client
        substring(TG_OP,1,1),                         -- action
        NULL, NULL,                                   -- row_data, changed_fields
        'f'                                           -- statement_only
        );

    IF NOT TG_ARGV[0]::boolean IS DISTINCT FROM 'f'::boolean THEN
        audit_row.client_query = NULL;
    END IF;

    IF TG_ARGV[1] IS NOT NULL THEN
        excluded_cols = TG_ARGV[1]::text[];
    END IF;
    
    IF (TG_OP = 'UPDATE' AND TG_LEVEL = 'ROW') THEN
        audit_row.row_data = hstore(OLD.*) - excluded_cols;
        audit_row.changed_fields =  (hstore(NEW.*) - audit_row.row_data) - excluded_cols;
        IF audit_row.changed_fields = hstore('') THEN
            -- All changed fields are ignored. Skip this update.
            RETURN NULL;
        END IF;
    ELSIF (TG_OP = 'DELETE' AND TG_LEVEL = 'ROW') THEN
        audit_row.row_data = hstore(OLD.*) - excluded_cols;
    ELSIF (TG_OP = 'INSERT' AND TG_LEVEL = 'ROW') THEN
        audit_row.row_data = hstore(NEW.*) - excluded_cols;
    ELSIF (TG_LEVEL = 'STATEMENT' AND TG_OP IN ('INSERT','UPDATE','DELETE','TRUNCATE')) THEN
        audit_row.statement_only = 't';
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
    INSERT INTO audit.logged_actions VALUES (audit_row.*);
    RETURN NULL;
END;
$$;


--
-- Name: get_pg_stat_activity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_pg_stat_activity() RETURNS SETOF pg_stat_activity
    LANGUAGE sql SECURITY DEFINER
    AS $$ SELECT * FROM pg_catalog.pg_stat_activity; $$;


--
-- Name: get_pg_stat_replication(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_pg_stat_replication() RETURNS SETOF pg_stat_replication
    LANGUAGE sql SECURITY DEFINER
    AS $$ SELECT * FROM pg_catalog.pg_stat_replication; $$;


SET default_table_access_method = heap;

--
-- Name: logged_actions; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.logged_actions (
    event_id bigint NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    relid oid NOT NULL,
    session_user_name text,
    action_tstamp_tx timestamp with time zone NOT NULL,
    action_tstamp_stm timestamp with time zone NOT NULL,
    action_tstamp_clk timestamp with time zone NOT NULL,
    transaction_id bigint,
    application_name text,
    client_addr inet,
    client_port integer,
    client_query text,
    action text NOT NULL,
    row_data public.hstore,
    changed_fields public.hstore,
    statement_only boolean NOT NULL,
    CONSTRAINT logged_actions_action_check CHECK ((action = ANY (ARRAY['I'::text, 'D'::text, 'U'::text, 'T'::text])))
);


--
-- Name: logged_actions_event_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.logged_actions_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logged_actions_event_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.logged_actions_event_id_seq OWNED BY audit.logged_actions.event_id;


--
-- Name: profile_pipeline_log; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.profile_pipeline_log (
    profile_log_id integer NOT NULL,
    profile_id smallint,
    file_name text,
    "timestamp" timestamp without time zone,
    db_user text,
    user_ip text,
    fail_step text
);


--
-- Name: profile_pipeline_log_profile_log_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.profile_pipeline_log_profile_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_pipeline_log_profile_log_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.profile_pipeline_log_profile_log_id_seq OWNED BY audit.profile_pipeline_log.profile_log_id;


--
-- Name: schedule_pipeline_log; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.schedule_pipeline_log (
    schedule_log_id integer NOT NULL,
    schedule_id smallint,
    file_name text,
    "timestamp" timestamp without time zone,
    db_user text,
    user_ip text,
    fail_step text
);


--
-- Name: schedule_pipeline_log_schedule_log_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.schedule_pipeline_log_schedule_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedule_pipeline_log_schedule_log_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.schedule_pipeline_log_schedule_log_id_seq OWNED BY audit.schedule_pipeline_log.schedule_log_id;


--
-- Name: tableslist; Type: VIEW; Schema: audit; Owner: -
--

CREATE VIEW audit.tableslist AS
 SELECT DISTINCT triggers.trigger_schema AS schema,
    triggers.event_object_table AS auditedtable
   FROM information_schema.triggers
  WHERE ((triggers.trigger_name)::text = ANY (ARRAY['audit_trigger_row'::text, 'audit_trigger_stm'::text]))
  ORDER BY triggers.trigger_schema, triggers.event_object_table;


--
-- Name: testdata_manual_log; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.testdata_manual_log (
    testdata_log_id integer NOT NULL,
    test_id smallint,
    schedule_id smallint,
    data_name text,
    "timestamp" timestamp without time zone,
    db_user text,
    user_ip text,
    fail_step text,
    comments text,
    data_type text
);


--
-- Name: testdata_manual_log_testdata_log_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.testdata_manual_log_testdata_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: testdata_manual_log_testdata_log_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.testdata_manual_log_testdata_log_id_seq OWNED BY audit.testdata_manual_log.testdata_log_id;


--
-- Name: testdata_pipeline_log; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.testdata_pipeline_log (
    testdata_log_id integer NOT NULL,
    test_id smallint,
    schedule_id smallint,
    data_name text,
    "timestamp" timestamp without time zone,
    db_user text,
    user_ip text,
    fail_step text,
    data_type text
);


--
-- Name: testdata_pipeline_log_testdata_log_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.testdata_pipeline_log_testdata_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: testdata_pipeline_log_testdata_log_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.testdata_pipeline_log_testdata_log_id_seq OWNED BY audit.testdata_pipeline_log.testdata_log_id;


--
-- Name: validation; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.validation (
    validation_id integer NOT NULL,
    validation_instance_id integer NOT NULL,
    cycle integer,
    step integer,
    "row" integer,
    error text,
    error_criticality text
);


--
-- Name: validation_meta; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.validation_meta (
    validation_instance_id integer NOT NULL,
    cell_id integer NOT NULL,
    test_id integer NOT NULL,
    schedule_id integer NOT NULL,
    "timestamp" timestamp without time zone,
    validation_code_version text,
    db_user text,
    validation_success boolean,
    num_errors integer,
    num_unique_errors integer,
    user_ip inet,
    run_time_s numeric,
    criticality_flag text
);


--
-- Name: validation_meta_validation_instance_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.validation_meta_validation_instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: validation_meta_validation_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.validation_meta_validation_instance_id_seq OWNED BY audit.validation_meta.validation_instance_id;


--
-- Name: validation_validation_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.validation_validation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: validation_validation_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.validation_validation_id_seq OWNED BY audit.validation.validation_id;


--
-- Name: arbin_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbin_profiles (
    arbin_profile_id integer NOT NULL,
    profile_id integer NOT NULL,
    time_s numeric NOT NULL,
    current numeric NOT NULL
);


--
-- Name: arbin_profiles_arbin_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.arbin_profiles_arbin_profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: arbin_profiles_arbin_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.arbin_profiles_arbin_profile_id_seq OWNED BY public.arbin_profiles.arbin_profile_id;


--
-- Name: arbin_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbin_schedules (
    step_id integer NOT NULL,
    schedule_id integer NOT NULL,
    section_name text,
    section_type text,
    setting_name text,
    setting_value text,
    setting_type text,
    description text
);


--
-- Name: arbin_schedules_step_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.arbin_schedules_step_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: arbin_schedules_step_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.arbin_schedules_step_id_seq OWNED BY public.arbin_schedules.step_id;


--
-- Name: cells; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cells (
    cell_id integer NOT NULL,
    cell_type_id integer,
    bg_sn text,
    batch_number text,
    label text,
    date_received date,
    comments text,
    date_manufactured date,
    manufacturer_sn text,
    dimensions jsonb,
    weight_g real,
    voltage_mv real
);


--
-- Name: batteries_cell_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.batteries_cell_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: batteries_cell_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.batteries_cell_id_seq OWNED BY public.cells.cell_id;


--
-- Name: cells_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cells_meta (
    cell_type_id integer NOT NULL,
    manufacturer text,
    manufacturer_pn text,
    form_factor text,
    capacity_mah integer,
    chemistry text,
    dimensions jsonb
);


--
-- Name: batteries_meta_batterytype_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.batteries_meta_batterytype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: batteries_meta_batterytype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.batteries_meta_batterytype_id_seq OWNED BY public.cells_meta.cell_type_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    customer_name text
);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- Name: cyclers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cyclers (
    cycler_id integer NOT NULL,
    cycler_type_id integer NOT NULL,
    sn text,
    calibration_date date,
    calibration_due_date date,
    location text,
    timezone_based text
);


--
-- Name: cyclers_cycler_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cyclers_cycler_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cyclers_cycler_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cyclers_cycler_id_seq OWNED BY public.cyclers.cycler_id;


--
-- Name: cyclers_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cyclers_meta (
    cycler_type_id integer NOT NULL,
    manufacturer text,
    model text,
    datasheet text,
    num_channels smallint,
    lower_current_limit_a numeric,
    upper_current_limit_a numeric,
    lower_voltage_limit_v numeric,
    upper_voltage_limit_v numeric
);


--
-- Name: cyclers_meta_cyclertype_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cyclers_meta_cyclertype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cyclers_meta_cyclertype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cyclers_meta_cyclertype_id_seq OWNED BY public.cyclers_meta.cycler_type_id;


--
-- Name: fra_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fra_data (
    potentiostat_id integer NOT NULL,
    test_id integer,
    cycle integer,
    step integer,
    soc numeric,
    freq_hz numeric,
    time_s numeric,
    z_real numeric,
    z_imaginary numeric,
    inverse_z_imaginary numeric,
    phase_angle numeric,
    c numeric,
    voltage_magnitude_mv numeric,
    current_magnitude_ma numeric
);


--
-- Name: fra_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fra_meta (
    fra_set_up_id integer NOT NULL,
    file_name text,
    mode text,
    amplitude_mv numeric,
    amplitude_ma numeric,
    initial_frequency_hz numeric,
    final_frequency_hz numeric,
    steps_per_decade integer,
    current_range text,
    current_limit_a text,
    data_quality integer,
    measurement_delay_s numeric,
    bandwidth text,
    dc_voltage_v text,
    vs text
);


--
-- Name: maccor_fra_data_potentiostat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maccor_fra_data_potentiostat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maccor_fra_data_potentiostat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maccor_fra_data_potentiostat_id_seq OWNED BY public.fra_data.potentiostat_id;


--
-- Name: maccor_fra_set_up_fra_set_up_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maccor_fra_set_up_fra_set_up_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maccor_fra_set_up_fra_set_up_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maccor_fra_set_up_fra_set_up_id_seq OWNED BY public.fra_meta.fra_set_up_id;


--
-- Name: maccor_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maccor_profiles (
    maccor_profile_id integer NOT NULL,
    profile_id integer NOT NULL,
    type character(1) NOT NULL,
    mode character(1) NOT NULL,
    mode_value numeric NOT NULL,
    "limit" character(1) NOT NULL,
    limit_value numeric NOT NULL,
    duration_s numeric NOT NULL,
    end_condition character(1) NOT NULL,
    end_oper character(2) NOT NULL,
    end_value numeric NOT NULL,
    report character(1) NOT NULL,
    report_value numeric NOT NULL,
    range character(1) NOT NULL,
    CONSTRAINT maccor_profiles_end_condition_check CHECK (((end_condition = 'V'::bpchar) OR (end_condition = 'I'::bpchar))),
    CONSTRAINT maccor_profiles_end_oper_check CHECK (((end_oper = '>='::bpchar) OR (end_oper = '<='::bpchar))),
    CONSTRAINT maccor_profiles_mode_check CHECK (((mode = 'I'::bpchar) OR (mode = 'P'::bpchar) OR (mode = 'V'::bpchar))),
    CONSTRAINT maccor_profiles_mode_limit_check CHECK ((("limit" = 'I'::bpchar) OR ("limit" = 'P'::bpchar) OR ("limit" = 'V'::bpchar))),
    CONSTRAINT maccor_profiles_range_check CHECK (((range = '4'::bpchar) OR (range = '3'::bpchar) OR (range = '2'::bpchar) OR (range = '1'::bpchar) OR (range = 'A'::bpchar))),
    CONSTRAINT maccor_profiles_report_check CHECK (((report = 'V'::bpchar) OR (report = 'I'::bpchar) OR (report = 'T'::bpchar) OR (report = 'N'::bpchar))),
    CONSTRAINT maccor_profiles_type_check CHECK (((type = 'C'::bpchar) OR (type = 'D'::bpchar)))
);


--
-- Name: maccor_profiles_maccor_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maccor_profiles_maccor_profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maccor_profiles_maccor_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maccor_profiles_maccor_profile_id_seq OWNED BY public.maccor_profiles.maccor_profile_id;


--
-- Name: maccor_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maccor_schedules (
    step_id integer NOT NULL,
    schedule_id integer,
    step smallint NOT NULL,
    step_type text NOT NULL,
    step_mode text,
    step_mode_value text,
    step_limit text,
    step_limit_value numeric,
    step_end_type text[],
    step_end_type_op text[],
    step_end_type_value text[],
    goto_step numeric[],
    report_type text[],
    report_type_value text[],
    options text,
    step_note text
);


--
-- Name: maccor_schedules_step_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maccor_schedules_step_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maccor_schedules_step_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maccor_schedules_step_id_seq OWNED BY public.maccor_schedules.step_id;


--
-- Name: modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modules (
    module_id integer NOT NULL,
    moduletype_id integer NOT NULL,
    bg_sn text,
    manufacturer_sn text,
    batch_number text,
    label text,
    date_received date,
    data_manufactured date
);


--
-- Name: modules_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modules_meta (
    moduletype_id integer NOT NULL,
    manufacturer text,
    manufacturer_pn text,
    capacity_mah integer,
    cells_in_series integer,
    cells_in_parallel integer,
    batterytype_id integer,
    dimensions public.hstore
);


--
-- Name: modules_meta_moduletype_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modules_meta_moduletype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modules_meta_moduletype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modules_meta_moduletype_id_seq OWNED BY public.modules_meta.moduletype_id;


--
-- Name: modules_module_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modules_module_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modules_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modules_module_id_seq OWNED BY public.modules.module_id;


--
-- Name: modules_test_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modules_test_data (
    modules_testdata_id integer NOT NULL,
    module_test_id integer NOT NULL,
    datetime timestamp with time zone,
    unixtime_s numeric,
    cycle smallint,
    tc_counter1 smallint,
    tc_counter2 smallint,
    tc_counter3 smallint,
    tc_counter4 smallint,
    max_cellvoltage_mv numeric,
    min_cellvoltage_mv numeric,
    max_cellvoltage_index smallint,
    min_cellvoltage_index smallint,
    cell_voltage_delta_mv numeric,
    step smallint,
    step_time_s numeric,
    test_time_s numeric,
    temps_c numeric[],
    module_voltage_mv numeric,
    cell_voltages_mv numeric[],
    current_ma numeric,
    charge_capacity_mah numeric,
    discharge_capacity_mah numeric,
    charge_energy_mwh numeric,
    discharge_energy_mwh numeric
);


--
-- Name: modules_test_data_cycle_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modules_test_data_cycle_stats (
    modules_cyclestats_id integer NOT NULL,
    module_test_id integer NOT NULL,
    datetime timestamp with time zone,
    unixtime_s numeric,
    cycle smallint,
    test_time_s numeric,
    capacity_charge_mah numeric,
    capacity_discharge_mah numeric,
    coulombic_efficiency numeric,
    total_cycle_chargetime_s numeric,
    cc_cycle_chargetime_s numeric,
    cv_cycle_chargetime_s numeric,
    max_temp_charge_c numeric,
    max_temp_discharge_c numeric,
    cycler_charge_capacity_mah numeric,
    cycler_discharge_capacity_mah numeric,
    cycler_coulombic_efficiency numeric,
    cycler_charge_time_s numeric,
    cycler_discharge_time_s numeric,
    cycler_charge_energy_mwh numeric,
    cycler_discharge_energy_mwh numeric,
    maxtemp_rpt_charge_c numeric,
    maxtemp_rpt_discharge_c numeric,
    capacity_rpt_charge_mah numeric,
    capacity_rpt_discharge_mah numeric,
    cc_capacity_mah numeric,
    cv_capacity_mah numeric,
    max_charge_cellvoltage_delta_mv numeric,
    min_charge_cellvoltage_mv numeric
);


--
-- Name: modules_test_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modules_test_meta (
    module_test_id integer NOT NULL,
    module_id integer NOT NULL,
    schedule_id integer NOT NULL,
    test_name text NOT NULL,
    start_date date,
    end_date date,
    channel integer,
    column_decoder public.hstore,
    project_id integer,
    temp_sensor_meta text[],
    cycler_id integer[]
);


--
-- Name: modules_testdata_cyclestats_modules_cyclestats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modules_testdata_cyclestats_modules_cyclestats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modules_testdata_cyclestats_modules_cyclestats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modules_testdata_cyclestats_modules_cyclestats_id_seq OWNED BY public.modules_test_data_cycle_stats.modules_cyclestats_id;


--
-- Name: modules_testdata_meta_module_test_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modules_testdata_meta_module_test_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modules_testdata_meta_module_test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modules_testdata_meta_module_test_id_seq OWNED BY public.modules_test_meta.module_test_id;


--
-- Name: modules_testdata_modules_testdata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modules_testdata_modules_testdata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modules_testdata_modules_testdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modules_testdata_modules_testdata_id_seq OWNED BY public.modules_test_data.modules_testdata_id;


--
-- Name: potentiostats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.potentiostats (
    potentiostat_id integer NOT NULL,
    potentiostattype_id integer,
    sn text,
    calibration_date date,
    calibration_due_date date
);


--
-- Name: potentiostats_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.potentiostats_meta (
    potentiostattype_id integer NOT NULL,
    manufacturer text,
    model text,
    datasheet text
);


--
-- Name: potentiostats_meta_potentiostattype_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.potentiostats_meta_potentiostattype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: potentiostats_meta_potentiostattype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.potentiostats_meta_potentiostattype_id_seq OWNED BY public.potentiostats_meta.potentiostattype_id;


--
-- Name: potentiostats_potentiostat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.potentiostats_potentiostat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: potentiostats_potentiostat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.potentiostats_potentiostat_id_seq OWNED BY public.potentiostats.potentiostat_id;


--
-- Name: profiles_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles_meta (
    profile_id integer NOT NULL,
    batterytype_id integer NOT NULL,
    author text,
    date_created date,
    profile_name text
);


--
-- Name: profiles_meta_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profiles_meta_profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_meta_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profiles_meta_profile_id_seq OWNED BY public.profiles_meta.profile_id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    project_id integer NOT NULL,
    project_name text,
    customer_id integer
);


--
-- Name: projects_project_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_project_id_seq OWNED BY public.projects.project_id;


--
-- Name: schedules_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules_meta (
    schedule_id integer NOT NULL,
    schedule_name text,
    test_type text,
    cycler_make text,
    date_created date,
    created_by text,
    last_modified date,
    modified_by text,
    comments text,
    profile_id integer,
    cv_voltage_threshold_mv integer,
    charge_steps integer[],
    discharge_steps integer[],
    rpt_charge_steps integer[],
    rpt_discharge_steps integer[],
    impedance_steps integer[],
    schedule_file text
);


--
-- Name: schedules_meta_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schedules_meta_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_meta_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schedules_meta_schedule_id_seq OWNED BY public.schedules_meta.schedule_id;


--
-- Name: sil_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sil_data (
    sil_data_id integer NOT NULL,
    sil_id integer,
    test_data_id integer,
    cycle smallint,
    test_time_s numeric,
    measured_voltage_mv smallint,
    modeled_voltage_mv smallint,
    voltage_delta_mv smallint,
    measured_current_ma smallint,
    overpotential_mv smallint,
    solution_time_ms smallint,
    insert_time timestamp with time zone DEFAULT now() NOT NULL,
    modeled_current_ma smallint,
    model_states numeric[]
);


--
-- Name: sil_data_sil_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sil_data_sil_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sil_data_sil_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sil_data_sil_data_id_seq OWNED BY public.sil_data.sil_data_id;


--
-- Name: sil_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sil_meta (
    sil_id integer NOT NULL,
    launched_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id text NOT NULL,
    status text,
    batterytype_id integer,
    test_id integer,
    silstreamer_config jsonb,
    model_config jsonb
);


--
-- Name: sil_meta_sil_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sil_meta_sil_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sil_meta_sil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sil_meta_sil_id_seq OWNED BY public.sil_meta.sil_id;


--
-- Name: swell_measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.swell_measurements (
    swell_id integer NOT NULL,
    cell_id integer NOT NULL,
    test_id integer NOT NULL,
    cycle integer,
    date_measured date,
    state_of_charge numeric,
    z_mm numeric,
    refblock_mm numeric
);


--
-- Name: swell_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.swell_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: swell_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.swell_id_seq OWNED BY public.swell_measurements.swell_id;


--
-- Name: test_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_data (
    test_data_id integer NOT NULL,
    test_id smallint NOT NULL,
    cycle smallint,
    step smallint,
    test_time_s numeric,
    step_time_s numeric,
    current_ma numeric NOT NULL,
    voltage_mv numeric NOT NULL,
    recorded_datetime timestamp with time zone NOT NULL,
    unixtime_s numeric NOT NULL,
    thermocouple_temps_c numeric[],
    other_detail jsonb
);


--
-- Name: test_data_cycle_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_data_cycle_stats (
    cycle_stats_id integer NOT NULL,
    test_id smallint NOT NULL,
    cycle smallint,
    test_time_s integer,
    reported_charge_capacity_mah numeric,
    reported_discharge_capacity_mah numeric,
    reported_charge_energy_mwh numeric,
    reported_discharge_energy_mwh numeric,
    calculated_charge_capacity_mah numeric,
    calculated_max_charge_temp_c numeric,
    calculated_discharge_capacity_mah numeric,
    calculated_max_discharge_temp_c numeric,
    calculated_cc_charge_time_s numeric,
    calculated_cv_charge_time_s numeric,
    calculated_cc_capacity_mah numeric,
    calculated_cv_capacity_mah numeric,
    calculated_coulombic_efficiency numeric,
    reported_coulombic_efficiency numeric,
    reported_charge_time_s numeric,
    reported_discharge_time_s numeric,
    calculated_fifty_percent_charge_time_s numeric,
    calculated_eighty_percent_charge_time_s numeric,
    calculated_charge_energy_mwh numeric,
    calculated_discharge_energy_mwh numeric,
    other_detail jsonb
);


--
-- Name: test_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_meta (
    test_id integer NOT NULL,
    cell_id smallint,
    schedule_id smallint,
    test_name text,
    data_file text,
    start_date date,
    end_date date,
    channel smallint,
    ev_chamber smallint,
    ev_chamber_slot smallint,
    thermocouple smallint,
    thermocouple_channel smallint,
    comments text,
    project_id integer,
    test_capacity_mah integer,
    potentiostat_id integer[],
    cycler_id integer
);


--
-- Name: testdata_cyclestats_cyclestats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.testdata_cyclestats_cyclestats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: testdata_cyclestats_cyclestats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.testdata_cyclestats_cyclestats_id_seq OWNED BY public.test_data_cycle_stats.cycle_stats_id;


--
-- Name: testdata_meta_test_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.testdata_meta_test_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: testdata_meta_test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.testdata_meta_test_id_seq OWNED BY public.test_meta.test_id;


--
-- Name: testdata_test_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.testdata_test_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: testdata_test_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.testdata_test_data_id_seq OWNED BY public.test_data.test_data_id;


--
-- Name: logged_actions event_id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.logged_actions ALTER COLUMN event_id SET DEFAULT nextval('audit.logged_actions_event_id_seq'::regclass);


--
-- Name: profile_pipeline_log profile_log_id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.profile_pipeline_log ALTER COLUMN profile_log_id SET DEFAULT nextval('audit.profile_pipeline_log_profile_log_id_seq'::regclass);


--
-- Name: schedule_pipeline_log schedule_log_id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.schedule_pipeline_log ALTER COLUMN schedule_log_id SET DEFAULT nextval('audit.schedule_pipeline_log_schedule_log_id_seq'::regclass);


--
-- Name: testdata_manual_log testdata_log_id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.testdata_manual_log ALTER COLUMN testdata_log_id SET DEFAULT nextval('audit.testdata_manual_log_testdata_log_id_seq'::regclass);


--
-- Name: testdata_pipeline_log testdata_log_id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.testdata_pipeline_log ALTER COLUMN testdata_log_id SET DEFAULT nextval('audit.testdata_pipeline_log_testdata_log_id_seq'::regclass);


--
-- Name: validation validation_id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation ALTER COLUMN validation_id SET DEFAULT nextval('audit.validation_validation_id_seq'::regclass);


--
-- Name: validation_meta validation_instance_id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation_meta ALTER COLUMN validation_instance_id SET DEFAULT nextval('audit.validation_meta_validation_instance_id_seq'::regclass);


--
-- Name: arbin_profiles arbin_profile_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbin_profiles ALTER COLUMN arbin_profile_id SET DEFAULT nextval('public.arbin_profiles_arbin_profile_id_seq'::regclass);


--
-- Name: arbin_schedules step_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbin_schedules ALTER COLUMN step_id SET DEFAULT nextval('public.arbin_schedules_step_id_seq'::regclass);


--
-- Name: cells cell_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells ALTER COLUMN cell_id SET DEFAULT nextval('public.batteries_cell_id_seq'::regclass);


--
-- Name: cells_meta cell_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells_meta ALTER COLUMN cell_type_id SET DEFAULT nextval('public.batteries_meta_batterytype_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- Name: cyclers cycler_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cyclers ALTER COLUMN cycler_id SET DEFAULT nextval('public.cyclers_cycler_id_seq'::regclass);


--
-- Name: cyclers_meta cycler_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cyclers_meta ALTER COLUMN cycler_type_id SET DEFAULT nextval('public.cyclers_meta_cyclertype_id_seq'::regclass);


--
-- Name: fra_data potentiostat_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fra_data ALTER COLUMN potentiostat_id SET DEFAULT nextval('public.maccor_fra_data_potentiostat_id_seq'::regclass);


--
-- Name: fra_meta fra_set_up_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fra_meta ALTER COLUMN fra_set_up_id SET DEFAULT nextval('public.maccor_fra_set_up_fra_set_up_id_seq'::regclass);


--
-- Name: maccor_profiles maccor_profile_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maccor_profiles ALTER COLUMN maccor_profile_id SET DEFAULT nextval('public.maccor_profiles_maccor_profile_id_seq'::regclass);


--
-- Name: maccor_schedules step_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maccor_schedules ALTER COLUMN step_id SET DEFAULT nextval('public.maccor_schedules_step_id_seq'::regclass);


--
-- Name: modules module_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules ALTER COLUMN module_id SET DEFAULT nextval('public.modules_module_id_seq'::regclass);


--
-- Name: modules_meta moduletype_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_meta ALTER COLUMN moduletype_id SET DEFAULT nextval('public.modules_meta_moduletype_id_seq'::regclass);


--
-- Name: modules_test_data modules_testdata_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_data ALTER COLUMN modules_testdata_id SET DEFAULT nextval('public.modules_testdata_modules_testdata_id_seq'::regclass);


--
-- Name: modules_test_data_cycle_stats modules_cyclestats_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_data_cycle_stats ALTER COLUMN modules_cyclestats_id SET DEFAULT nextval('public.modules_testdata_cyclestats_modules_cyclestats_id_seq'::regclass);


--
-- Name: modules_test_meta module_test_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_meta ALTER COLUMN module_test_id SET DEFAULT nextval('public.modules_testdata_meta_module_test_id_seq'::regclass);


--
-- Name: potentiostats potentiostat_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.potentiostats ALTER COLUMN potentiostat_id SET DEFAULT nextval('public.potentiostats_potentiostat_id_seq'::regclass);


--
-- Name: potentiostats_meta potentiostattype_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.potentiostats_meta ALTER COLUMN potentiostattype_id SET DEFAULT nextval('public.potentiostats_meta_potentiostattype_id_seq'::regclass);


--
-- Name: profiles_meta profile_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles_meta ALTER COLUMN profile_id SET DEFAULT nextval('public.profiles_meta_profile_id_seq'::regclass);


--
-- Name: projects project_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN project_id SET DEFAULT nextval('public.projects_project_id_seq'::regclass);


--
-- Name: schedules_meta schedule_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules_meta ALTER COLUMN schedule_id SET DEFAULT nextval('public.schedules_meta_schedule_id_seq'::regclass);


--
-- Name: sil_data sil_data_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sil_data ALTER COLUMN sil_data_id SET DEFAULT nextval('public.sil_data_sil_data_id_seq'::regclass);


--
-- Name: sil_meta sil_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sil_meta ALTER COLUMN sil_id SET DEFAULT nextval('public.sil_meta_sil_id_seq'::regclass);


--
-- Name: swell_measurements swell_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swell_measurements ALTER COLUMN swell_id SET DEFAULT nextval('public.swell_id_seq'::regclass);


--
-- Name: test_data test_data_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data ALTER COLUMN test_data_id SET DEFAULT nextval('public.testdata_test_data_id_seq'::regclass);


--
-- Name: test_data_cycle_stats cycle_stats_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data_cycle_stats ALTER COLUMN cycle_stats_id SET DEFAULT nextval('public.testdata_cyclestats_cyclestats_id_seq'::regclass);


--
-- Name: test_meta test_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_meta ALTER COLUMN test_id SET DEFAULT nextval('public.testdata_meta_test_id_seq'::regclass);


--
-- Name: logged_actions logged_actions_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.logged_actions
    ADD CONSTRAINT logged_actions_pkey PRIMARY KEY (event_id);


--
-- Name: profile_pipeline_log profile_pipeline_log_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.profile_pipeline_log
    ADD CONSTRAINT profile_pipeline_log_pkey PRIMARY KEY (profile_log_id);


--
-- Name: schedule_pipeline_log schedule_pipeline_log_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.schedule_pipeline_log
    ADD CONSTRAINT schedule_pipeline_log_pkey PRIMARY KEY (schedule_log_id);


--
-- Name: testdata_manual_log testdata_manual_log_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.testdata_manual_log
    ADD CONSTRAINT testdata_manual_log_pkey PRIMARY KEY (testdata_log_id);


--
-- Name: testdata_pipeline_log testdata_pipeline_log_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.testdata_pipeline_log
    ADD CONSTRAINT testdata_pipeline_log_pkey PRIMARY KEY (testdata_log_id);


--
-- Name: validation_meta validation_meta_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation_meta
    ADD CONSTRAINT validation_meta_pkey PRIMARY KEY (validation_instance_id);


--
-- Name: validation validation_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation
    ADD CONSTRAINT validation_pkey PRIMARY KEY (validation_id);


--
-- Name: arbin_profiles arbin_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbin_profiles
    ADD CONSTRAINT arbin_profiles_pkey PRIMARY KEY (arbin_profile_id);


--
-- Name: arbin_schedules arbin_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbin_schedules
    ADD CONSTRAINT arbin_schedules_pkey PRIMARY KEY (step_id);


--
-- Name: cells_meta batterytype_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells_meta
    ADD CONSTRAINT batterytype_id PRIMARY KEY (cell_type_id);


--
-- Name: cells batterytype_label_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT batterytype_label_id UNIQUE (cell_type_id, label);


--
-- Name: cells cell_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT cell_id PRIMARY KEY (cell_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: cyclers_meta cyclers_meta_manufacturer_model_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cyclers_meta
    ADD CONSTRAINT cyclers_meta_manufacturer_model_key UNIQUE (manufacturer, model);


--
-- Name: cyclers_meta cyclers_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cyclers_meta
    ADD CONSTRAINT cyclers_meta_pkey PRIMARY KEY (cycler_type_id);


--
-- Name: cyclers cyclers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cyclers
    ADD CONSTRAINT cyclers_pkey PRIMARY KEY (cycler_id);


--
-- Name: test_data_cycle_stats cyclestats_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data_cycle_stats
    ADD CONSTRAINT cyclestats_id PRIMARY KEY (cycle_stats_id);


--
-- Name: test_meta data_file_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_meta
    ADD CONSTRAINT data_file_constraint UNIQUE (data_file);


--
-- Name: fra_data maccor_fra_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fra_data
    ADD CONSTRAINT maccor_fra_data_pkey PRIMARY KEY (potentiostat_id);


--
-- Name: fra_meta maccor_fra_set_up_file_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fra_meta
    ADD CONSTRAINT maccor_fra_set_up_file_name_key UNIQUE (file_name);


--
-- Name: fra_meta maccor_fra_set_up_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fra_meta
    ADD CONSTRAINT maccor_fra_set_up_pkey PRIMARY KEY (fra_set_up_id);


--
-- Name: maccor_profiles maccor_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maccor_profiles
    ADD CONSTRAINT maccor_profiles_pkey PRIMARY KEY (maccor_profile_id);


--
-- Name: modules_meta modules_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_meta
    ADD CONSTRAINT modules_meta_pkey PRIMARY KEY (moduletype_id);


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (module_id);


--
-- Name: modules_test_data_cycle_stats modules_testdata_cyclestats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_data_cycle_stats
    ADD CONSTRAINT modules_testdata_cyclestats_pkey PRIMARY KEY (modules_cyclestats_id);


--
-- Name: modules_test_meta modules_testdata_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_meta
    ADD CONSTRAINT modules_testdata_meta_pkey PRIMARY KEY (module_test_id);


--
-- Name: modules_test_data modules_testdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_data
    ADD CONSTRAINT modules_testdata_pkey PRIMARY KEY (modules_testdata_id);


--
-- Name: potentiostats_meta potentiostats_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.potentiostats_meta
    ADD CONSTRAINT potentiostats_meta_pkey PRIMARY KEY (potentiostattype_id);


--
-- Name: potentiostats potentiostats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.potentiostats
    ADD CONSTRAINT potentiostats_pkey PRIMARY KEY (potentiostat_id);


--
-- Name: profiles_meta profiles_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles_meta
    ADD CONSTRAINT profiles_meta_pkey PRIMARY KEY (profile_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (project_id);


--
-- Name: schedules_meta schedule_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules_meta
    ADD CONSTRAINT schedule_id PRIMARY KEY (schedule_id);


--
-- Name: schedules_meta schedules_meta_file_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules_meta
    ADD CONSTRAINT schedules_meta_file_name_key UNIQUE (schedule_name);


--
-- Name: sil_data sil_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sil_data
    ADD CONSTRAINT sil_data_pkey PRIMARY KEY (sil_data_id);


--
-- Name: sil_meta sil_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sil_meta
    ADD CONSTRAINT sil_meta_pkey PRIMARY KEY (sil_id);


--
-- Name: maccor_schedules step_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maccor_schedules
    ADD CONSTRAINT step_id PRIMARY KEY (step_id);


--
-- Name: swell_measurements swell_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swell_measurements
    ADD CONSTRAINT swell_id PRIMARY KEY (swell_id);


--
-- Name: test_data test_data_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data
    ADD CONSTRAINT test_data_id PRIMARY KEY (test_data_id);


--
-- Name: test_meta test_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_meta
    ADD CONSTRAINT test_id PRIMARY KEY (test_id);


--
-- Name: logged_actions_action_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX logged_actions_action_idx ON audit.logged_actions USING btree (action);


--
-- Name: logged_actions_action_tstamp_tx_stm_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX logged_actions_action_tstamp_tx_stm_idx ON audit.logged_actions USING btree (action_tstamp_stm);


--
-- Name: logged_actions_relid_idx; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX logged_actions_relid_idx ON audit.logged_actions USING btree (relid);


--
-- Name: maccor_profiles_profile_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX maccor_profiles_profile_id_idx ON public.maccor_profiles USING btree (profile_id);


--
-- Name: maccor_schedules_schedule_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX maccor_schedules_schedule_id_idx ON public.maccor_schedules USING btree (schedule_id);


--
-- Name: testdata_cyclestats_test_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX testdata_cyclestats_test_id_idx ON public.test_data_cycle_stats USING btree (test_id);


--
-- Name: testdata_test_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX testdata_test_id_idx ON public.test_data USING btree (test_id);


--
-- Name: sil_meta audit_trigger_row; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_trigger_row AFTER INSERT OR DELETE OR UPDATE ON public.sil_meta FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func('true');


--
-- Name: sil_meta audit_trigger_stm; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_trigger_stm AFTER TRUNCATE ON public.sil_meta FOR EACH STATEMENT EXECUTE FUNCTION audit.if_modified_func('true');


--
-- Name: cells batteries_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER batteries_audit AFTER INSERT OR DELETE OR UPDATE ON public.cells FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();


--
-- Name: cells_meta batteries_meta_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER batteries_meta_audit AFTER INSERT OR DELETE OR UPDATE ON public.cells_meta FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();


--
-- Name: customers customers_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER customers_audit AFTER INSERT OR DELETE OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();


--
-- Name: projects projects_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER projects_audit AFTER INSERT OR DELETE OR UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();


--
-- Name: schedules_meta schedules_meta_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER schedules_meta_audit AFTER INSERT OR DELETE OR UPDATE ON public.schedules_meta FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();


--
-- Name: swell_measurements swell_measurements_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER swell_measurements_audit AFTER INSERT OR DELETE OR UPDATE ON public.swell_measurements FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();


--
-- Name: test_meta testdata_meta_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER testdata_meta_audit AFTER INSERT OR DELETE OR UPDATE ON public.test_meta FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();


--
-- Name: validation_meta audit_validation_meta_cell_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation_meta
    ADD CONSTRAINT audit_validation_meta_cell_id_fkey FOREIGN KEY (cell_id) REFERENCES public.cells(cell_id);


--
-- Name: validation_meta audit_validation_meta_schedule_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation_meta
    ADD CONSTRAINT audit_validation_meta_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules_meta(schedule_id);


--
-- Name: validation_meta audit_validation_meta_test_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation_meta
    ADD CONSTRAINT audit_validation_meta_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_meta(test_id);


--
-- Name: validation audit_validation_validation_instance_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.validation
    ADD CONSTRAINT audit_validation_validation_instance_id_fkey FOREIGN KEY (validation_instance_id) REFERENCES audit.validation_meta(validation_instance_id);


--
-- Name: arbin_profiles arbin_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbin_profiles
    ADD CONSTRAINT arbin_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles_meta(profile_id);


--
-- Name: test_meta arbin_schedules_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_meta
    ADD CONSTRAINT arbin_schedules_project_id_fk FOREIGN KEY (project_id) REFERENCES public.projects(project_id);


--
-- Name: cells batteries_batterytype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cells
    ADD CONSTRAINT batteries_batterytype_id_fkey FOREIGN KEY (cell_type_id) REFERENCES public.cells_meta(cell_type_id);


--
-- Name: test_meta cycler_id_testdata_meta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_meta
    ADD CONSTRAINT cycler_id_testdata_meta FOREIGN KEY (cycler_id) REFERENCES public.cyclers(cycler_id);


--
-- Name: cyclers cycles_to_cyclers_meta_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cyclers
    ADD CONSTRAINT cycles_to_cyclers_meta_fk FOREIGN KEY (cycler_type_id) REFERENCES public.cyclers_meta(cycler_type_id);


--
-- Name: fra_data maccor_fra_data_test_id_to_testdata_meta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fra_data
    ADD CONSTRAINT maccor_fra_data_test_id_to_testdata_meta FOREIGN KEY (test_id) REFERENCES public.test_meta(test_id);


--
-- Name: maccor_profiles maccor_profile_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maccor_profiles
    ADD CONSTRAINT maccor_profile_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles_meta(profile_id);


--
-- Name: maccor_schedules maccor_schedules_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maccor_schedules
    ADD CONSTRAINT maccor_schedules_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules_meta(schedule_id);


--
-- Name: modules_test_data_cycle_stats modules_cyclestats_modules_module_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_data_cycle_stats
    ADD CONSTRAINT modules_cyclestats_modules_module_test_id_fkey FOREIGN KEY (module_test_id) REFERENCES public.modules_test_meta(module_test_id);


--
-- Name: modules_meta modules_meta_batterytype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_meta
    ADD CONSTRAINT modules_meta_batterytype_id_fkey FOREIGN KEY (batterytype_id) REFERENCES public.cells_meta(cell_type_id);


--
-- Name: modules modules_moduletype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_moduletype_id_fkey FOREIGN KEY (moduletype_id) REFERENCES public.modules_meta(moduletype_id);


--
-- Name: modules_test_meta modules_testdata_meta_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_meta
    ADD CONSTRAINT modules_testdata_meta_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(module_id);


--
-- Name: modules_test_meta modules_testdata_meta_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_meta
    ADD CONSTRAINT modules_testdata_meta_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(project_id);


--
-- Name: modules_test_meta modules_testdata_meta_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_meta
    ADD CONSTRAINT modules_testdata_meta_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules_meta(schedule_id);


--
-- Name: modules_test_data modules_testdata_modules_module_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules_test_data
    ADD CONSTRAINT modules_testdata_modules_module_test_id_fkey FOREIGN KEY (module_test_id) REFERENCES public.modules_test_meta(module_test_id);


--
-- Name: potentiostats potentiostats_to_potentiostats_meta_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.potentiostats
    ADD CONSTRAINT potentiostats_to_potentiostats_meta_fk FOREIGN KEY (potentiostattype_id) REFERENCES public.potentiostats_meta(potentiostattype_id);


--
-- Name: profiles_meta profiles_meta_batterytype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles_meta
    ADD CONSTRAINT profiles_meta_batterytype_id_fkey FOREIGN KEY (batterytype_id) REFERENCES public.cells_meta(cell_type_id);


--
-- Name: projects projects_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: schedules_meta schedules_meta_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules_meta
    ADD CONSTRAINT schedules_meta_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles_meta(profile_id);


--
-- Name: sil_data sil_data_sil_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sil_data
    ADD CONSTRAINT sil_data_sil_id_fkey FOREIGN KEY (sil_id) REFERENCES public.sil_meta(sil_id);


--
-- Name: sil_meta sil_meta_batterytype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sil_meta
    ADD CONSTRAINT sil_meta_batterytype_id_fkey FOREIGN KEY (batterytype_id) REFERENCES public.cells_meta(cell_type_id);


--
-- Name: sil_meta sil_meta_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sil_meta
    ADD CONSTRAINT sil_meta_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_meta(test_id);


--
-- Name: swell_measurements swell_measurements_cell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swell_measurements
    ADD CONSTRAINT swell_measurements_cell_id_fkey FOREIGN KEY (cell_id) REFERENCES public.cells(cell_id);


--
-- Name: swell_measurements swell_measurements_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swell_measurements
    ADD CONSTRAINT swell_measurements_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_meta(test_id);


--
-- Name: test_data_cycle_stats testdata_cyclestats_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data_cycle_stats
    ADD CONSTRAINT testdata_cyclestats_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_meta(test_id);


--
-- Name: test_meta testdata_meta_cell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_meta
    ADD CONSTRAINT testdata_meta_cell_id_fkey FOREIGN KEY (cell_id) REFERENCES public.cells(cell_id);


--
-- Name: test_meta testdata_meta_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_meta
    ADD CONSTRAINT testdata_meta_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules_meta(schedule_id);


--
-- Name: test_data testdata_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data
    ADD CONSTRAINT testdata_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_meta(test_id);


--
-- PostgreSQL database dump complete
--

