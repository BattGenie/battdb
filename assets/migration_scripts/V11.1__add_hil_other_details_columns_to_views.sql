DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_30s;
DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_10min;
DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_hourly;
DROP MATERIALIZED VIEW IF EXISTS hil_data_summary_daily;

CREATE MATERIALIZED VIEW hil_data_summary_30s WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
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
FROM hil_data
GROUP BY thirtysec,
    hil_id WITH NO DATA;

CREATE MATERIALIZED VIEW hil_data_summary_10min WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
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
FROM hil_data
GROUP BY tenmin,
    hil_id WITH NO DATA;

CREATE MATERIALIZED VIEW hil_data_summary_hourly WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
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
FROM hil_data
GROUP BY hour,
    hil_id WITH NO DATA;

CREATE MATERIALIZED VIEW hil_data_summary_daily WITH (timescaledb.continuous, timescaledb.materialized_only=False) AS
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
FROM hil_data
GROUP BY day,
    hil_id WITH NO DATA;
