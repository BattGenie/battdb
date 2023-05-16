-- Drop timezone_based column from cyclers table
ALTER TABLE cyclers
    DROP COLUMN IF EXISTS timezone_based;

-- rename fra_data table to eis_data
ALTER TABLE fra_data
    RENAME TO eis_data;

-- rename z_real column to z_real_ohm in eis_data table
ALTER TABLE eis_data
    RENAME COLUMN z_real TO z_real_ohm;

-- rename z_imaginary column to z_imaginary_ohm in eis_data table
ALTER TABLE eis_data
    RENAME COLUMN z_imaginary TO z_imaginary_ohm;

-- rename phase_angle column to phase_angle_degree in eis_data table
ALTER TABLE eis_data
    RENAME COLUMN phase_angle TO phase_angle_degree;

-- remove inverse_z_imaginary column from eis_data table
ALTER TABLE eis_data
    DROP COLUMN IF EXISTS inverse_z_imaginary;

-- rename fra_meta table to eis_meta
ALTER TABLE fra_meta
    RENAME TO eis_meta;

-- rename fra_set_up_id column to eis_id in eis_meta table
ALTER TABLE eis_meta
    RENAME COLUMN fra_set_up_id TO eis_id;

-- rename vs to dc_vs_open_circuit in eis_meta table
ALTER TABLE eis_meta
    RENAME COLUMN vs TO dc_vs_open_circuit;

-- add datasheet column to cells_meta table
ALTER TABLE cells_meta
ADD COLUMN datasheet bytea;

-- create enum_test_type enum type and change test_type to enum_test_type in schedule_meta table
CREATE TYPE enum_test_type AS ENUM (
    'ICT',
    'Characterization',
    'Baseline life cycling',
    'MBC life cycling',
    'MBC quick test',
    'Pretest',
    'HPPC'
);
ALTER TABLE schedule_meta
ALTER COLUMN test_type TYPE enum_test_type USING test_type::enum_test_type;

-- rename schedule_files to details in schedule_meta table
ALTER TABLE schedule_meta
    RENAME COLUMN schedule_files TO details;

-- remove bg_sn column from modules table in modules_meta
ALTER TABLE modules DROP COLUMN bg_sn;

-- rename moduletype_id to module_type_id in modules table
ALTER TABLE modules
    RENAME COLUMN moduletype_id TO module_type_id;

-- change dimensions type to jsonb in modules_meta table
ALTER TABLE modules_meta
ALTER COLUMN dimensions TYPE JSONB USING dimensions::JSONB;

-- remove *_rpt_* columns from modules_test_data_cycle_stats table
ALTER TABLE modules_test_data_cycle_stats DROP COLUMN IF EXISTS maxtemp_rpt_charge_c;
ALTER TABLE modules_test_data_cycle_stats DROP COLUMN IF EXISTS maxtemp_rpt_discharge_c;
ALTER TABLE modules_test_data_cycle_stats DROP COLUMN IF EXISTS capacity_rpt_charge_mah;
ALTER TABLE modules_test_data_cycle_stats DROP COLUMN IF EXISTS capacity_rpt_discharge_mah;

-- rename potentiostattype_id to potentiostats_type_id in potentiostats_meta table
ALTER TABLE potentiostats_meta
    RENAME COLUMN potentiostattype_id TO potentiostats_type_id;

-- rename batterytype_id to cell_type_id in profiles_meta table
ALTER TABLE profiles_meta
    RENAME COLUMN batterytype_id TO cell_type_id;

-- rename other_detail column to other_details from hil_data table
ALTER TABLE hil_data
    RENAME COLUMN other_detail TO other_details;

-- rename other_detail column to other_details from sil_data table
ALTER TABLE sil_data
    RENAME COLUMN other_detail TO other_details;

-- rename other_detail column to other_details from test_data table
ALTER TABLE test_data
    RENAME COLUMN other_detail TO other_details;

-- rename other_detail column to other_details from test_data_cycle_stats table
ALTER TABLE test_data_cycle_stats
    RENAME COLUMN other_detail TO other_details;