-- flyway_schema_history table
COMMENT ON TABLE public.flyway_schema_history IS 'Schema history table';
COMMENT ON COLUMN public.flyway_schema_history.installed_rank IS 'The version of the flyway schema.';
COMMENT ON COLUMN public.flyway_schema_history.version IS 'The version of the BattDB schema.';
COMMENT ON COLUMN public.flyway_schema_history.description IS 'The description of the BattDB schema.';
COMMENT ON COLUMN public.flyway_schema_history.type IS 'The type of migration.';
COMMENT ON COLUMN public.flyway_schema_history.script IS 'The name of the migration script.';
COMMENT ON COLUMN public.flyway_schema_history.checksum IS 'The checksum of the migration script.';
COMMENT ON COLUMN public.flyway_schema_history.installed_by IS 'The user who installed the migration script.';
COMMENT ON COLUMN public.flyway_schema_history.installed_on IS 'The date the migration script was installed.';
COMMENT ON COLUMN public.flyway_schema_history.execution_time IS 'The time it took to execute the migration script.';
COMMENT ON COLUMN public.flyway_schema_history.success IS 'Whether or not the migration script was successful.';


--
-- Table
--

-- cells
COMMENT ON TABLE public.cells IS 'Stores information for cell instances.';
COMMENT ON COLUMN public.cells.cell_id IS 'Unique identifier for the cell instance. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.cells.cell_type_id IS 'Refers to the make of the cell defined in cells_meta table.';
COMMENT ON COLUMN public.cells.batch_number IS 'Batch number of the cells from manufacturer.';
COMMENT ON COLUMN public.cells.label IS 'The label written on the cell for internal use.';
COMMENT ON COLUMN public.cells.date_received IS 'Date the cell was received by the lab.';
COMMENT ON COLUMN public.cells.comments IS 'Any comments about the cell.';
COMMENT ON COLUMN public.cells.date_manufactured IS 'Date the cell was created by the manufacturer.';
COMMENT ON COLUMN public.cells.manufacturer_sn IS 'Manufacturer''s serial number of the cell printed on the cell.';
COMMENT ON COLUMN public.cells.dimensions IS 'Dimensions of the cell instance. For pouch cells, H x W x L in mm. For cyclindrical cells, r x H in mm. For example, ''{"x_mm":54.25, "y_mm":106.96, "z_mm":3.19}'' for a pouch cell and ''{"x_mm":54.25, "y_mm":106.96, "z_mm":3.19}'' for a cyclindrical cell.';
COMMENT ON COLUMN public.cells.weight_g IS 'Weight in grams.';
COMMENT ON COLUMN public.cells.first_received_at_voltage_mv IS 'Voltage of the cell prior to testing.';

-- cells_meta
COMMENT ON TABLE public.cells_meta IS 'Stores information for types of cells.';
COMMENT ON COLUMN public.cells_meta.cell_type_id IS 'Unique identifier for the cell type. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.cells_meta.manufacturer IS 'Manufacturer of the cell.';
COMMENT ON COLUMN public.cells_meta.manufacturer_pn IS 'Part number of the cell from the manufacturer.';
COMMENT ON COLUMN public.cells_meta.form_factor IS 'Geometry of the cell, e.g. cylindrical, pouch, prismatic, coin.';
COMMENT ON COLUMN public.cells_meta.capacity_mah IS 'Rated capacity of the cell in mAh.';
COMMENT ON COLUMN public.cells_meta.chemistry IS 'Electrode and electrolyte material.';
COMMENT ON COLUMN public.cells_meta.dimensions IS 'Dimensions of the cell type. For pouch cells, H x W x L in mm. For cyclindrical cells, r x H in mm. For example, ''{"x_mm":54.25, "y_mm":106.96, "z_mm":3.19}'' for a pouch cell and ''{"x_mm":54.25, "y_mm":106.96, "z_mm":3.19}'' for a cyclindrical cell.';
COMMENT ON COLUMN public.cells_meta.datasheet IS 'Datasheet for the cell type. BattETL will convert the pdf file to binary data and store it in the database.';

-- customers
COMMENT ON TABLE public.customers IS 'Tracks customers.';
COMMENT ON COLUMN public.customers.customer_id IS 'Unique identifier for the customer. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.customers.customer_name IS 'Name of the customer.';

-- cycler_rt_channel_statuses
COMMENT ON TABLE public.cycler_rt_channel_statuses IS 'Stores real-time information for cycler channels.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.id IS 'Unique identifier for the cycler channel status. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.cycler_id IS 'Refers to the cycler instance defined in cyclers table.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.channel IS 'Channel number of the cycler.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.status IS 'Status of the cycler channel. Can be idle, rest, charge, discharge, problem, or other.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.cycle IS 'Cycle number of the cycler channel.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.step IS 'Step number of the cycler channel.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.test_time_s IS 'Test time in seconds.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.step_time_s IS 'Step time in seconds.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.voltage_mv IS 'Voltage in mV.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.current_ma IS 'Current in mA.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.charge_capacity_mah IS 'Charge capacity in mAh.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.discharge_capacity_mah IS 'Discharge capacity in mAh.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.charge_energy_mwh IS 'Charge energy in mWh.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.discharge_energy_mwh IS 'Discharge energy in mWh.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.timestamp_s IS 'Timestamp in seconds.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.insert_time IS 'Timestamp of insertion into the database.';
COMMENT ON COLUMN public.cycler_rt_channel_statuses.other_details IS 'Other details about the cycler channel status.';

-- cyclers
COMMENT ON TABLE public.cyclers IS 'Stores information for cycler instances.';
COMMENT ON COLUMN public.cyclers.cycler_id IS 'Unique identifier for the cycler instance. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.cyclers.cycler_type_id IS 'Refers to the make of the cycler defined in cyclers_meta table.';
COMMENT ON COLUMN public.cyclers.sn IS 'Serial number of the cycler from the manufacturer.';
COMMENT ON COLUMN public.cyclers.calibration_date IS 'Date of last calibration.';
COMMENT ON COLUMN public.cyclers.calibration_due_date IS 'Date of next calibration.';
COMMENT ON COLUMN public.cyclers.location IS 'Lab where cycler is located.';

-- cyclers_meta
COMMENT ON TABLE public.cyclers_meta IS 'Stores information for types of cycler.';
COMMENT ON COLUMN public.cyclers_meta.cycler_type_id IS 'Unique identifier for the cycler type. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.cyclers_meta.manufacturer IS 'Manufacturer of the cycler.';
COMMENT ON COLUMN public.cyclers_meta.model IS 'Model of the cycler.';
COMMENT ON COLUMN public.cyclers_meta.datasheet IS 'Datasheet for the cycler.';
COMMENT ON COLUMN public.cyclers_meta.num_channels IS 'Number of channels in the cycler.';
COMMENT ON COLUMN public.cyclers_meta.lower_current_limit_a IS 'Lower current limit in A.';
COMMENT ON COLUMN public.cyclers_meta.upper_current_limit_a IS 'Upper current limit in A.';
COMMENT ON COLUMN public.cyclers_meta.lower_voltage_limit_v IS 'Lower voltage limit in V.';
COMMENT ON COLUMN public.cyclers_meta.upper_voltage_limit_v IS 'Upper voltage limit in V.';

-- eis_data
COMMENT ON TABLE public.eis_data IS 'Stores potentiostat test data.';
COMMENT ON COLUMN public.eis_data.potentiostat_id IS 'Unique identifier for the potentiostat data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.eis_data.test_id IS 'Refers to the potentiostat test defined in test_meta table.';
COMMENT ON COLUMN public.eis_data.cycle IS 'The test cycle the EIS measurement was made at.';
COMMENT ON COLUMN public.eis_data.step IS 'The test step the EIS masurement was made at.';
COMMENT ON COLUMN public.eis_data.soc IS 'The state of charge (SoC) the EIS measurement was made at.';
COMMENT ON COLUMN public.eis_data.freq_hz IS 'The frequency of the EIS pulse.';
COMMENT ON COLUMN public.eis_data.time_s IS 'The test time the EIS measurement was made at.';
COMMENT ON COLUMN public.eis_data.z_real_ohm IS 'The real part of the measured EIS impedance.';
COMMENT ON COLUMN public.eis_data.z_imaginary_ohm IS 'The imaginary part of the measured EIS impedance.';
COMMENT ON COLUMN public.eis_data.phase_angle_degree IS 'The phase angle of the measured EIS impedance.';
COMMENT ON COLUMN public.eis_data.c IS 'The capacitance of the EIS measurement.';
COMMENT ON COLUMN public.eis_data.voltage_magnitude_mv IS 'The magnitude of the voltage of the EIS measurement.';
COMMENT ON COLUMN public.eis_data.current_magnitude_ma IS 'The magnitude of the current of the EIS measurement.';

-- eis_meta
COMMENT ON TABLE public.eis_meta IS 'Stores high-level information about the potentiostat test.';
COMMENT ON COLUMN public.eis_meta.eis_id IS 'Unique identifier for the EIS test. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.eis_meta.file_name IS 'file name that defines the EIS setup.';
COMMENT ON COLUMN public.eis_meta.mode IS 'The mode of the EIS measurement can be galvanostatic and potentiostatic.';
COMMENT ON COLUMN public.eis_meta.amplitude_mv IS 'The voltage amplitude of the EIS pulse.';
COMMENT ON COLUMN public.eis_meta.amplitude_ma IS 'The current amplitude of the EIS pulse.';
COMMENT ON COLUMN public.eis_meta.initial_frequency_hz IS 'The starting frequency of the EIS sweep.';
COMMENT ON COLUMN public.eis_meta.final_frequency_hz IS 'The ending frequency of the EIS sweep.';
COMMENT ON COLUMN public.eis_meta.steps_per_decade IS 'How many EIS measurements to make per decade of the current sweep.';
COMMENT ON COLUMN public.eis_meta.current_range IS 'The current range of the EIS measurements.';
COMMENT ON COLUMN public.eis_meta.current_limit_a IS 'The upper current limit of the EIS measurements.';
COMMENT ON COLUMN public.eis_meta.data_quality IS 'The data quality measurment setting for the Gamry potentiostat.';
COMMENT ON COLUMN public.eis_meta.measurement_delay_s IS 'The delay between EIS measurements.';
COMMENT ON COLUMN public.eis_meta.bandwidth IS 'The bandwidth of the EIS measurements.';
COMMENT ON COLUMN public.eis_meta.dc_voltage_v IS 'The DC voltage of the EIS measurements.';
COMMENT ON COLUMN public.eis_meta.dc_vs_open_circuit IS 'The DC vs open circuit value for the EIS measurements.';

-- hil_data
COMMENT ON TABLE public.hil_data IS 'Stores test data from hardware-in-the-loop test.';
COMMENT ON COLUMN public.hil_data.hil_data_id IS 'Unique identifier for the HIL data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.hil_data.hil_id IS 'Refers to the HIL test defined in hil_meta table.';
COMMENT ON COLUMN public.hil_data.cycle IS 'The cycle number of the data point. Tracks number of charge/discharge cycles.';
COMMENT ON COLUMN public.hil_data.step IS 'The step number of the data point.';
COMMENT ON COLUMN public.hil_data.step_time_s IS 'The time in seconds since the start of the step, ignoring pauses.';
COMMENT ON COLUMN public.hil_data.test_time_s IS 'The time in seconds since the start of the test, ignoring pauses.';
COMMENT ON COLUMN public.hil_data.measured_voltage_mv IS 'The voltage measured by the cycler during the data point.';
COMMENT ON COLUMN public.hil_data.modeled_voltage_mv IS 'The voltage predicted by the model during the data point.';
COMMENT ON COLUMN public.hil_data.voltage_delta_mv IS 'The difference between the measured and modeled voltage during the data point.';
COMMENT ON COLUMN public.hil_data.measured_current_ma IS 'The current measured by the cycler during the data point.';
COMMENT ON COLUMN public.hil_data.modeled_current_ma IS 'The current predicted by the model during the data point.';
COMMENT ON COLUMN public.hil_data.datetime IS 'The date and time the data point was recorded by cycler. Matches timezone of cycler.';
COMMENT ON COLUMN public.hil_data.unixtime_s IS 'The time in seconds since the Unix epoch (January 1, 1970). Calculated from recorded_datetime.';
COMMENT ON COLUMN public.hil_data.status IS 'The status of the cycler during the data point. Can be idle, rest, charge, discharge, problem, or other.';
COMMENT ON COLUMN public.hil_data.overpotential_mv IS 'The overpotential of the data point.';
COMMENT ON COLUMN public.hil_data.solution_time_ms IS 'The solution time of the data point.';
COMMENT ON COLUMN public.hil_data.model_states IS 'The model states during the data point.';
COMMENT ON COLUMN public.hil_data.insert_time IS 'Timestamp of insertion into the database.';
COMMENT ON COLUMN public.hil_data.other_details IS 'Other details about the HIL data point.';
COMMENT ON COLUMN public.hil_data.reported_charge_capacity_mah IS 'The charge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.hil_data.reported_discharge_capacity_mah IS 'The discharge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.hil_data.reported_charge_energy_mwh IS 'The charge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.hil_data.reported_discharge_energy_mwh IS 'The discharge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.hil_data.state_of_charge IS 'The state of charge reported by the cycler at the end of the cycle.';

-- hil_meta
COMMENT ON TABLE public.hil_meta IS 'Stores high-level information about the hardware-in-the-loop test.';
COMMENT ON COLUMN public.hil_meta.hil_id IS 'Unique identifier for the HIL test. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.hil_meta.launched_at IS 'The date and time the HIL test was launched.';
COMMENT ON COLUMN public.hil_meta.status IS 'The status of the HIL test.';
COMMENT ON COLUMN public.hil_meta.test_name IS 'The name of the HIL test.';
COMMENT ON COLUMN public.hil_meta.schedule_name IS 'The name of the schedule file used in cycler software.';
COMMENT ON COLUMN public.hil_meta.configs IS 'The configuration files used in the test.';
COMMENT ON COLUMN public.hil_meta.other_details IS 'Other details about the HIL test.';
COMMENT ON COLUMN public.hil_meta.user_id IS 'The user who launched the HIL test.';
COMMENT ON COLUMN public.hil_meta.cell_id IS 'The cell used in the HIL test. References the cell_id in the cells table.';

-- models
COMMENT ON TABLE public.models IS 'Stores information for model instances.';
COMMENT ON COLUMN public.models.model_id IS 'Unique identifier for the model instance. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.models.model_name IS 'The name of the model.';
COMMENT ON COLUMN public.models.model_type_id IS 'Refers to the make of the model defined in models_meta table.';
COMMENT ON COLUMN public.models.model_physical_params IS 'Physical parameters of the model.';
COMMENT ON COLUMN public.models.model_mathematical_params IS 'Mathematical parameters of the model.';
COMMENT ON COLUMN public.models.model_computational_params IS 'Computational parameters of the model.';
COMMENT ON COLUMN public.models.model_version IS 'The version of the model.';
COMMENT ON COLUMN public.models.model_stage IS 'The stage of the model. Can be dev, stag, or prod.';
COMMENT ON COLUMN public.models.other_details IS 'Other details about the model.';

-- models_meta
COMMENT ON TABLE public.models_meta IS 'Stores information for types of models.';
COMMENT ON COLUMN public.models_meta.model_type_id IS 'Unique identifier for the model type. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.models_meta.model_type IS 'The type of model. Can be lookup_table, ecm, spm, tank, p2d, or other.';
COMMENT ON COLUMN public.models_meta.cell_type_id IS 'The type of battery the model is for. References the cell_type_id in the cells_meta table.';
COMMENT ON COLUMN public.models_meta.model_type_name IS 'The name of the model type.';
COMMENT ON COLUMN public.models_meta.model_type_parameters IS 'The parameters of the model type.';
COMMENT ON COLUMN public.models_meta.other_details IS 'Other details about the model type.';

-- modules
COMMENT ON TABLE public.modules IS 'Stores information for module instances.';
COMMENT ON COLUMN public.modules.module_id IS 'Unique identifier for the module instance. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.modules.module_type_id IS 'Refers to the make of the module defined in modules_meta table.';
COMMENT ON COLUMN public.modules.manufacturer_sn IS 'Serial number of the module from the manufacturer.';
COMMENT ON COLUMN public.modules.batch_number IS 'The manufacturing batch number for the cell (if available).';
COMMENT ON COLUMN public.modules.label IS 'Label of the module.';
COMMENT ON COLUMN public.modules.date_received IS 'Date the module was received by lab.';
COMMENT ON COLUMN public.modules.data_manufactured IS 'Date the module was created by the manufacturer.';

-- modules_meta
COMMENT ON TABLE public.modules_meta IS 'Stores information about types of module.';
COMMENT ON COLUMN public.modules_meta.moduletype_id IS 'Unique identifier for the module type. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.modules_meta.manufacturer IS 'Manufacturer of the module.';
COMMENT ON COLUMN public.modules_meta.manufacturer_pn IS 'Part number of the module from the manufacturer.';
COMMENT ON COLUMN public.modules_meta.capacity_mah IS 'Rated capacity of the module in mAh.';
COMMENT ON COLUMN public.modules_meta.cells_in_series IS 'Number of cells in series.';
COMMENT ON COLUMN public.modules_meta.cells_in_parallel IS 'Number of cells in parallel.';
COMMENT ON COLUMN public.modules_meta.batterytype_id IS 'Cells that make up the module. Refers to the cell type defined in cells_meta table.';
COMMENT ON COLUMN public.modules_meta.dimensions IS 'Physical dimensions of the module. Stored in hstore data type that allows for dictionary like behavior. Example for a cylindrical cell: "height"=>"65.00 ± 0.2 mm", "diameter"=>"18.3 +0.2 / -0.3 mm"';

-- modules_test_data
COMMENT ON TABLE public.modules_test_data IS 'Stores test data for tests performed using modules.';
COMMENT ON COLUMN public.modules_test_data.modules_testdata_id IS 'Unique identifier for the module test data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.modules_test_data.module_test_id IS 'Refers to the module test defined in modules_test_meta table.';
COMMENT ON COLUMN public.modules_test_data.datetime IS 'Date and time (relative to the timezone set on the cycler computer) at the specific sample time.';
COMMENT ON COLUMN public.modules_test_data.unixtime_s IS 'Date and time converted to unix time (also called ''epoch time'') for the specific sample time.';
COMMENT ON COLUMN public.modules_test_data.cycle IS 'Total number of charge/discharge step pairs the schedule file has completed. Can vary depending on the schedule file.';
COMMENT ON COLUMN public.modules_test_data.tc_counter1 IS 'Counter for loops in loops.';
COMMENT ON COLUMN public.modules_test_data.tc_counter2 IS 'Counter for loops in loops.';
COMMENT ON COLUMN public.modules_test_data.tc_counter3 IS 'Counter for loops in loops.';
COMMENT ON COLUMN public.modules_test_data.tc_counter4 IS 'Counter for loops in loops.';
COMMENT ON COLUMN public.modules_test_data.max_cellvoltage_mv IS 'Cell in module with the highest voltage.';
COMMENT ON COLUMN public.modules_test_data.min_cellvoltage_mv IS 'Cell in module with the lowest voltage.';
COMMENT ON COLUMN public.modules_test_data.max_cellvoltage_index IS 'Index of cell in module with the highest voltage.';
COMMENT ON COLUMN public.modules_test_data.min_cellvoltage_index IS 'Index of cell in module with the lowest voltage.';
COMMENT ON COLUMN public.modules_test_data.cell_voltage_delta_mv IS 'Change in voltage from last sample.';
COMMENT ON COLUMN public.modules_test_data.step IS 'The cycle schedule step for the data point.';
COMMENT ON COLUMN public.modules_test_data.step_time_s IS 'Time ellapsed since the start of the step, not counting pauses.';
COMMENT ON COLUMN public.modules_test_data.test_time_s IS 'Time ellapsed since the start of the test, not counting pauses.';
COMMENT ON COLUMN public.modules_test_data.temps_c IS 'Temperature of each cell in the module.';
COMMENT ON COLUMN public.modules_test_data.module_voltage_mv IS 'Voltage of the module. Nominally this is the battery voltage.';
COMMENT ON COLUMN public.modules_test_data.cell_voltages_mv IS 'Voltage of each cell in the module.';
COMMENT ON COLUMN public.modules_test_data.current_ma IS 'The current sourced (or sunk for discharge) by the cycler at the specific sample time.';
COMMENT ON COLUMN public.modules_test_data.charge_capacity_mah IS 'The cumulative charge put out by the cycler during charge for the current step.';
COMMENT ON COLUMN public.modules_test_data.discharge_capacity_mah IS 'The cumulative charge taken in by the cycler during discharge charge for the current step.';
COMMENT ON COLUMN public.modules_test_data.charge_energy_mwh IS 'The cumulative energy used by the charger during the current step at the sample time.';
COMMENT ON COLUMN public.modules_test_data.discharge_energy_mwh IS 'The cumulative energy used by the charger during the current step at the sample time.';

-- modules_test_data_cycle_stats
COMMENT ON TABLE public.modules_test_data_cycle_stats IS 'Stores summary statistics for each cycle of a test performed using modules.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.modules_cyclestats_id IS 'Unique identifier for the module cycle stats data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.module_test_id IS 'Test data that stats are being calculated from. Refers to the module_test_id in modules_test_meta table.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.datetime IS 'Date and time (relative to the timezone set on the cycler computer) at the specific sample time.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.unixtime_s IS 'Date and time converted to unix time (also called ''epoch time'') for the specific sample time.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycle IS 'Total number of charge/discharge step pairs the schedule file has completed. Can vary depending on the schedule file.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.test_time_s IS 'Time elapsed since the start of the test, not counting pauses.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.capacity_charge_mah IS 'The cumulative charge put out by the cycler during charge for the current step.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.capacity_discharge_mah IS 'The cumulative charge taken in by the cycler during discharge charge for the current step.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.coulombic_efficiency IS 'Calculated ratio of discharge capacity to charge capacity for the current step.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.total_cycle_chargetime_s IS 'Total time spent charging during the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cc_cycle_chargetime_s IS 'Time (in seconds) spent charging during the constant current portion of the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cv_cycle_chargetime_s IS 'Time (in seconds) spent charging during the constant voltage portion of the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.max_temp_charge_c IS 'Maximum temperature (in Celsius) of the module during charge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.max_temp_discharge_c IS 'Maximum temperature (in Celsius) of the module during discharge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycler_charge_capacity_mah IS 'The cumulative charge (reported by cycler) put out during charge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycler_discharge_capacity_mah IS 'The cumulative charge (reported by cycler) taken in during discharge charge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycler_coulombic_efficiency IS 'The coulombic efficiency (reported by cycler) for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycler_charge_time_s IS 'The total time in seconds (reported by cycler) spent charging during the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycler_discharge_time_s IS 'The total time in seconds (reported by cycler) spent discharging during the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycler_charge_energy_mwh IS 'The cumulative energy (reported by cycler) used during charge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cycler_discharge_energy_mwh IS 'The cumulative energy (reported by cycler) used during discharge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cc_capacity_mah IS 'The cumulative charge put out by the cycler during the constant current position of charge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.cv_capacity_mah IS 'The cumulative charge put out by the cycler during the constant voltage position of charge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.max_charge_cellvoltage_delta_mv IS 'The maximum change in voltage of any cell in the module during charge for the current cycle.';
COMMENT ON COLUMN public.modules_test_data_cycle_stats.min_charge_cellvoltage_mv IS 'The minimum voltage of any cell in the module during charge for the current cycle.';

-- modules_test_meta
COMMENT ON TABLE public.modules_test_meta IS 'Stores high-level information about tests performed using modules.';
COMMENT ON COLUMN public.modules_test_meta.module_test_id IS 'Unique identifier for the module test. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.modules_test_meta.module_id IS 'The specific module being tested. References the module_id in the modules table.';
COMMENT ON COLUMN public.modules_test_meta.schedule_id IS 'The schedule file used for the test. References the schedule_id in the schedule_meta table.';
COMMENT ON COLUMN public.modules_test_meta.test_name IS 'The name of the specific test used in cycler software. Typically BG_Customer_CellType_TestType_CellLabel_Take#.';
COMMENT ON COLUMN public.modules_test_meta.start_date IS 'The date the test was started.';
COMMENT ON COLUMN public.modules_test_meta.end_date IS 'The date the test finished.';
COMMENT ON COLUMN public.modules_test_meta.channel IS 'The cycler channel the test was ran on.';
COMMENT ON COLUMN public.modules_test_meta.column_decoder IS 'The column decoder used for the test.';
COMMENT ON COLUMN public.modules_test_meta.project_id IS 'The project the test is associated with. References the project_id in the projects table.';
COMMENT ON COLUMN public.modules_test_meta.temp_sensor_meta IS 'The temperature sensor meta data used for the test.';
COMMENT ON COLUMN public.modules_test_meta.cycler_id IS 'The cycler the test was ran on. References the cycler_id in the cyclers table.';

-- potentiostats
COMMENT ON TABLE public.potentiostats IS 'Stores information about potentiostat instance.';
COMMENT ON COLUMN public.potentiostats.potentiostat_id IS 'Unique identifier for the potentiostat instance. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.potentiostats.potentiostattype_id IS 'Refers to the make of the potentiostat defined in potentiostats_meta table.';
COMMENT ON COLUMN public.potentiostats.sn IS 'The serial number of the potentiostat.';
COMMENT ON COLUMN public.potentiostats.calibration_date IS 'The date the potentiostat was last calibrated.';
COMMENT ON COLUMN public.potentiostats.calibration_due_date IS 'The date the potentiostat is due to be calibrated.';

-- potentiostats_meta
COMMENT ON TABLE public.potentiostats_meta IS 'Stores information about type of potentiostat.';
COMMENT ON COLUMN public.potentiostats_meta.potentiostats_type_id IS 'Unique identifier for potentiostat type. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.potentiostats_meta.manufacturer IS 'The manufacturer of the potentiostat.';
COMMENT ON COLUMN public.potentiostats_meta.model IS 'The model of the potentiostat.';
COMMENT ON COLUMN public.potentiostats_meta.datasheet IS 'Datasheet for the potentiostat.';

-- profiles_meta
COMMENT ON TABLE public.profiles_meta IS 'Stores information about charge profiles used in schedules.';
COMMENT ON COLUMN public.profiles_meta.profile_id IS 'Unique identifier for the profile. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.profiles_meta.cell_type_id IS 'The type of battery the profile is for. References the cell_type_id in the cells_meta table.';
COMMENT ON COLUMN public.profiles_meta.author IS 'The person who created the profile.';
COMMENT ON COLUMN public.profiles_meta.date_created IS 'The date the profile was created.';
COMMENT ON COLUMN public.profiles_meta.profile_name IS 'The name of the profile.';

-- projects
COMMENT ON TABLE public.projects IS 'Tracks projects associated with a customer.';
COMMENT ON COLUMN public.projects.project_id IS 'Unique identifier for the project. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.projects.project_name IS 'The name of the project.';
COMMENT ON COLUMN public.projects.customer_id IS 'The customer the project is associated with. References the customer_id in the customers table.';

-- schedule_meta
COMMENT ON TABLE public.schedule_meta IS 'Stores high-level information about schedule files.';
COMMENT ON COLUMN public.schedule_meta.schedule_id IS 'Unique identifier for the schedule file. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.schedule_meta.schedule_name IS 'The name of the schedule file used in cycler software.';
COMMENT ON COLUMN public.schedule_meta.test_type IS 'The type of test performed, e.g. ICT, Characterization, Baseline, Profile Testing.';
COMMENT ON COLUMN public.schedule_meta.cycler_make IS 'The make of the cycler schedule is written for, e.g. Arbin or Maccor.';
COMMENT ON COLUMN public.schedule_meta.date_created IS 'Date schedule file was created. Not necessarily the date the test was ran.';
COMMENT ON COLUMN public.schedule_meta.created_by IS 'The person who created the schedule file.';
COMMENT ON COLUMN public.schedule_meta.comments IS 'Any comments regarding the schedule file.';
COMMENT ON COLUMN public.schedule_meta.cv_voltage_threshold_mv IS 'The voltage threshold (in mV) used to determine when to switch from constant current to constant voltage during charge.';
COMMENT ON COLUMN public.schedule_meta.details IS 'Other details about the schedule file.';

-- sil_data
COMMENT ON TABLE public.sil_data IS 'Stores model outputs and test data from software-in-the-loop testing.';
COMMENT ON COLUMN public.sil_data.sil_data_id IS 'Unique identifier for the SIL data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.sil_data.sil_id IS 'Refers to the SIL test defined in sil_meta table.';
COMMENT ON COLUMN public.sil_data.test_data_id IS 'Refers to the test data defined in test_data table.';
COMMENT ON COLUMN public.sil_data.cycle IS 'The cycle number of the data point. Tracks number of charge/discharge cycles.';
COMMENT ON COLUMN public.sil_data.test_time_s IS 'The time in seconds since the start of the test, ignoring pauses.';
COMMENT ON COLUMN public.sil_data.measured_voltage_mv IS 'The voltage measured by the cycler during the data point.';
COMMENT ON COLUMN public.sil_data.modeled_voltage_mv IS 'The voltage predicted by the model during the data point.';
COMMENT ON COLUMN public.sil_data.voltage_delta_mv IS 'The difference between the measured and modeled voltage during the data point.';
COMMENT ON COLUMN public.sil_data.measured_current_ma IS 'The current measured by the cycler during the data point.';
COMMENT ON COLUMN public.sil_data.overpotential_mv IS 'The overpotential of the data point.';
COMMENT ON COLUMN public.sil_data.solution_time_ms IS 'The solution time of the data point.';
COMMENT ON COLUMN public.sil_data.insert_time IS 'Timestamp of insertion into the database.';
COMMENT ON COLUMN public.sil_data.modeled_current_ma IS 'The current predicted by the model during the data point.';
COMMENT ON COLUMN public.sil_data.model_states IS 'The model states during the data point.';
COMMENT ON COLUMN public.sil_data.other_details IS 'Other details about the SIL data point.';
COMMENT ON COLUMN public.sil_data.recorded_datetime IS 'The date and time the data point was recorded.';

-- sil_meta
COMMENT ON TABLE public.sil_meta IS 'Stores high-level information about software-in-the-loop tests.';
COMMENT ON COLUMN public.sil_meta.sil_id IS 'Unique identifier for the SIL test. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.sil_meta.launched_at IS 'The date and time the SIL test was launched.';
COMMENT ON COLUMN public.sil_meta.user_id IS 'The user who launched the SIL test.';
COMMENT ON COLUMN public.sil_meta.status IS 'The status of the SIL test. Can be idle, rest, charge, discharge, problem, or other.';
COMMENT ON COLUMN public.sil_meta.cell_type_id IS 'The cell used in the SIL test. References the cell_type_id in the cells_meta table.';
COMMENT ON COLUMN public.sil_meta.test_id IS 'The test the SIL test is associated with. References the test_id in the test_meta table.';
COMMENT ON COLUMN public.sil_meta.configs IS 'The configuration files used in the test.';
COMMENT ON COLUMN public.sil_meta.other_details IS 'Other details about the SIL test.';

-- sim_data
COMMENT ON TABLE public.sim_data IS 'Stores model outputs and test data from simulation testing.';
COMMENT ON COLUMN public.sim_data.sim_data_id IS 'Unique identifier for the simulation data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.sim_data.sim_id IS 'Refers to the simulation test defined in sim_meta table.';
COMMENT ON COLUMN public.sim_data.test_data_id IS 'Refers to the test data defined in test_data table.';
COMMENT ON COLUMN public.sim_data.cycle IS 'The cycle number of the data point. Tracks number of charge/discharge cycles.';
COMMENT ON COLUMN public.sim_data.test_time_s IS 'The time in seconds since the start of the test, ignoring pauses.';
COMMENT ON COLUMN public.sim_data.measured_voltage_mv IS 'The voltage measured by the cycler during the data point.';
COMMENT ON COLUMN public.sim_data.modeled_voltage_mv IS 'The voltage predicted by the model during the data point.';
COMMENT ON COLUMN public.sim_data.voltage_delta_mv IS 'The difference between the measured and modeled voltage during the data point.';
COMMENT ON COLUMN public.sim_data.measured_current_ma IS 'The current measured by the cycler during the data point.';
COMMENT ON COLUMN public.sim_data.overpotential_mv IS 'The overpotential of the data point.';
COMMENT ON COLUMN public.sim_data.solution_time_ms IS 'The solution time of the data point.';
COMMENT ON COLUMN public.sim_data.insert_time IS 'Timestamp of insertion into the database.';
COMMENT ON COLUMN public.sim_data.modeled_current_ma IS 'The current predicted by the model during the data point.';
COMMENT ON COLUMN public.sim_data.model_states IS 'The model states during the data point.';
COMMENT ON COLUMN public.sim_data.other_details IS 'Other details about the simulation data point.';
COMMENT ON COLUMN public.sim_data.recorded_datetime IS 'The date and time the data point was recorded.';

-- sim_meta
COMMENT ON TABLE public.sim_meta IS 'Stores high-level information about simulation tests.';
COMMENT ON COLUMN public.sim_meta.sim_id IS 'Unique identifier for the simulation test. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.sim_meta.launched_at IS 'The date and time the simulation test was launched.';
COMMENT ON COLUMN public.sim_meta.user_id IS 'The user who launched the simulation test.';
COMMENT ON COLUMN public.sim_meta.status IS 'The status of the simulation test. Can be idle, rest, charge, discharge, problem, or other.';
COMMENT ON COLUMN public.sim_meta.cell_type_id IS 'The cell used in the simulation test. References the cell_type_id in the cells_meta table.';
COMMENT ON COLUMN public.sim_meta.test_id IS 'The test the simulation test is associated with. References the test_id in the test_meta table.';
COMMENT ON COLUMN public.sim_meta.configs IS 'The configuration files used in the test.';
COMMENT ON COLUMN public.sim_meta.other_details IS 'Other details about the simulation test.';

-- test_data
COMMENT ON TABLE public.test_data IS 'Stores test data for tests performed on single cells.';
COMMENT ON COLUMN public.test_data.test_data_id IS 'Unique identifier for the test data point. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.test_data.test_id IS 'The specific test the data point is associated with. References the test_id in the test_meta table.';
COMMENT ON COLUMN public.test_data.cycle IS 'The cycle number of the data point. Tracks number of charge/discharge cycles.';
COMMENT ON COLUMN public.test_data.step IS 'Schedule step associated with the data point.';
COMMENT ON COLUMN public.test_data.test_time_s IS 'The time in seconds since the start of the test, ignoring pauses.';
COMMENT ON COLUMN public.test_data.step_time_s IS 'The time in seconds since the start of the step, ignoring pauses.';
COMMENT ON COLUMN public.test_data.current_ma IS 'The current sourced (or sunk) by the cycler at the specific sample time. Positive for charge, negative for discharge.';
COMMENT ON COLUMN public.test_data.voltage_mv IS 'The voltage measured by the cycler at the specific sample time.';
COMMENT ON COLUMN public.test_data.recorded_datetime IS 'The date and time the data point was recorded by cycler. Matches timezone of cycler.';
COMMENT ON COLUMN public.test_data.unixtime_s IS 'The time in seconds since the Unix epoch (January 1, 1970). Calculated from recorded_datetime.';
COMMENT ON COLUMN public.test_data.thermocouple_temps_c IS 'The temperature (in Celsius) of each thermocouple. Usually T1 is chamber temperature and T2 is cell temperature.';
COMMENT ON COLUMN public.test_data.other_details IS 'Contains data for auxillary measurements.';

-- test_data_cycle_stats
COMMENT ON TABLE public.test_data_cycle_stats IS 'Stores summary statistics for each cycle for tests performed on single cells.';
COMMENT ON COLUMN public.test_data_cycle_stats.cycle_stats_id IS 'Unique identifier for the test data cycle stats. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.test_data_cycle_stats.test_id IS 'The specific test the data point is associated with. References the test_id in the test_meta table.';
COMMENT ON COLUMN public.test_data_cycle_stats.cycle IS 'The cycle number of the data point. Tracks number of charge/discharge cycles.';
COMMENT ON COLUMN public.test_data_cycle_stats.test_time_s IS 'The time in seconds since the start of the test, ignoring pauses.';
COMMENT ON COLUMN public.test_data_cycle_stats.reported_charge_capacity_mah IS 'The charge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.test_data_cycle_stats.reported_discharge_capacity_mah IS 'The discharge capacity reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.test_data_cycle_stats.reported_charge_energy_mwh IS 'The charge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.test_data_cycle_stats.reported_discharge_energy_mwh IS 'The discharge energy reported by the cycler at the end of the cycle.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_charge_capacity_mah IS 'The charge capacity at the end of the cycle. Calculated from test_data Table values by battetl. Should be the same as reported_charge_capacity_mah.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_max_charge_temp_c IS 'The maximum temperature during the charge step of the cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_discharge_capacity_mah IS 'The discharge capacity at the end of the cycle. Calculated from test_data table values by battetl. Should be the same as reported_discharge_capacity_mah.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_max_discharge_temp_c IS 'The maximum temperature during the discharge step of the cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_cc_charge_time_s IS 'The time in seconds spent in the constant current charge step of the cycle. Calculated from test_data table values by battetl.'; 
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_cv_charge_time_s IS 'The time in seconds spent in the constant voltage charge step of the cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_cc_capacity_mah IS 'The capacity in mAh delivered during the constant current charge step of the cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_cv_capacity_mah IS 'The capacity in mAh delivered during the constant voltage charge step of the cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_coulombic_efficiency IS 'Ratio of discharge capacity to charge capacity for cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.reported_coulombic_efficiency IS 'Ratio of discharge capacity to charge capacity for cycle. Reported by cycler.';
COMMENT ON COLUMN public.test_data_cycle_stats.reported_charge_time_s IS 'The time in seconds spent in the charge step of the cycle. Reported by cycler.';
COMMENT ON COLUMN public.test_data_cycle_stats.reported_discharge_time_s IS 'The time in seconds spent in the discharge step of the cycle. Reported by cycler.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_fifty_percent_charge_time_s IS 'The time in seconds to reach 50% of the final charge capacity for cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_eighty_percent_charge_time_s IS 'The time in seconds to reach 80% of the final charge capacity for cycle. Calculated from test_data table values by battetl.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_charge_energy_mwh IS 'The charge energy at the end of the cycle. Calculated from test_data table values by battetl. Should be the same as reported_charge_energy_mwh.';
COMMENT ON COLUMN public.test_data_cycle_stats.calculated_discharge_energy_mwh IS 'The discharge energy at the end of the cycle. Calculated from test_data table values by battetl. Should be the same as reported_discharge_energy_mwh.';
COMMENT ON COLUMN public.test_data_cycle_stats.other_details IS 'Other details about the test data cycle stats. Contains data for auxillary measurements.';

-- test_meta
COMMENT ON TABLE public.test_meta IS 'Contains high-level information about tests on single cells.';
COMMENT ON COLUMN public.test_meta.test_id IS 'Unique identifier for the test. Auto-incremented upon insertion.';
COMMENT ON COLUMN public.test_meta.cell_id IS 'Specific cell being tested. References the cell_id in the cells table.';
COMMENT ON COLUMN public.test_meta.schedule_id IS 'Schedule file used in the test. References the schedule_id in the schedule_meta table.';
COMMENT ON COLUMN public.test_meta.test_name IS 'Name of the test in cycling software.';
COMMENT ON COLUMN public.test_meta.start_date IS 'Date the test was started. Populated manually in config file.';
COMMENT ON COLUMN public.test_meta.end_date IS 'Date the test was ended. Populated manually in config file.';
COMMENT ON COLUMN public.test_meta.channel IS 'Cycler channel the test was run on.';
COMMENT ON COLUMN public.test_meta.ev_chamber IS 'The environmental chamber the test was run in.';
COMMENT ON COLUMN public.test_meta.ev_chamber_slot IS 'The slot in the environmental chamber the test was run in.';
COMMENT ON COLUMN public.test_meta.thermocouples IS 'Specific thermocouple attached to the cell being tested.';
COMMENT ON COLUMN public.test_meta.thermocouple_channels IS 'Channel the thermocouple is attached to.';
COMMENT ON COLUMN public.test_meta.comments IS 'Additional info about the test.';
COMMENT ON COLUMN public.test_meta.project_id IS 'Project the test is associated with. References the project_id in the projects table.';
COMMENT ON COLUMN public.test_meta.test_capacity_mah IS 'Rated capacity of the cell being tested.';
COMMENT ON COLUMN public.test_meta.potentiostat_id IS 'Potentiostat the test was run on. References the potentiostat_id in the potentiostats table.';
COMMENT ON COLUMN public.test_meta.cycler_id IS 'Cycler the test was run on. References the cycler_id in the cyclers table.';


--
-- View
--

-- Fix sil and sim 30s views typo
-- thirtysecn_overpotential_mv -> thirtysec_overpotential_mv

DROP MATERIALIZED VIEW hil_data_summary_30s;
DROP MATERIALIZED VIEW sil_data_summary_30s;
DROP MATERIALIZED VIEW sim_data_summary_30s;

CREATE MATERIALIZED VIEW hil_data_summary_30s WITH (timescaledb.continuous) AS
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
    avg(reported_discharge_energy_mwh) as thirtysec_reported_discharge_energy_mwh
FROM hil_data
GROUP BY thirtysec,
    hil_id WITH NO DATA;

CREATE MATERIALIZED VIEW sil_data_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', insert_time) AS thirtysec, 
    sil_id,
    avg(measured_voltage_mv) as thirtysec_measured_voltage_mv, 
    avg(modeled_voltage_mv) as thirtysec_modeled_voltage_mv,
    avg(overpotential_mv) as thirtysec_overpotential_mv, 
    avg(solution_time_ms) as thirtysec_solution_time_ms, 
    avg(voltage_delta_mv) as thirtysec_voltage_delta_mv,   
    avg(modeled_current_ma) as thirtysec_modeled_current_ma, 
    avg(measured_current_ma) as thirtysec_measured_current_ma
    FROM sil_data
    GROUP BY thirtysec, sil_id
	    WITH NO DATA;

CREATE MATERIALIZED VIEW sim_data_summary_30s
WITH (timescaledb.continuous)
AS
    SELECT time_bucket('30 seconds', insert_time) AS thirtysec, 
    sim_id,
    avg(measured_voltage_mv) as thirtysec_measured_voltage_mv, 
    avg(modeled_voltage_mv) as thirtysec_modeled_voltage_mv,
    avg(overpotential_mv) as thirtysec_overpotential_mv, 
    avg(solution_time_ms) as thirtysec_solution_time_ms, 
    avg(voltage_delta_mv) as thirtysec_voltage_delta_mv,   
    avg(modeled_current_ma) as thirtysec_modeled_current_ma, 
    avg(measured_current_ma) as thirtysec_measured_current_ma
    FROM sim_data
    GROUP BY thirtysec, sim_id
	    WITH NO DATA;

-- hil_data_summary_30s;
COMMENT ON VIEW public.hil_data_summary_30s IS 'Materialized view of hil_data table aggregated by 30 second intervals.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec IS 'The datetime rounded to the nearest 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.hil_id IS 'Refers to the HIL test defined in hil_meta table.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_solution_time_ms IS 'The average solution time of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_state_of_charge IS 'The average state of charge of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_measured_voltage_mv IS 'The average measured voltage of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_modeled_voltage_mv IS 'The average modeled voltage of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_measured_current_ma IS 'The average measured current of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_modeled_current_ma IS 'The average modeled current of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_overpotential_mv IS 'The average overpotential of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_voltage_delta_mv IS 'The average voltage delta of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_reported_charge_capacity_mah IS 'The average reported charge capacity of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_reported_charge_energy_mwh IS 'The average reported charge energy of the HIL test for the 30 second interval.';
COMMENT ON COLUMN public.hil_data_summary_30s.thirtysec_reported_discharge_energy_mwh IS 'The average reported discharge energy of the HIL test for the 30 second interval.';

-- hil_data_summary_10min
COMMENT ON VIEW public.hil_data_summary_10min IS 'Materialized view of hil_data table aggregated by 10 minute intervals.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin IS 'The datetime rounded to the nearest 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.hil_id IS 'Refers to the HIL test defined in hil_meta table.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_solution_time_ms IS 'The average solution time of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_state_of_charge IS 'The average state of charge of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_measured_voltage_mv IS 'The average measured voltage of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_modeled_voltage_mv IS 'The average modeled voltage of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_measured_current_ma IS 'The average measured current of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_modeled_current_ma IS 'The average modeled current of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_overpotential_mv IS 'The average overpotential of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_voltage_delta_mv IS 'The average voltage delta of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_reported_charge_capacity_mah IS 'The average reported charge capacity of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_reported_charge_energy_mwh IS 'The average reported charge energy of the HIL test for the 10 minute interval.';
COMMENT ON COLUMN public.hil_data_summary_10min.tenmin_reported_discharge_energy_mwh IS 'The average reported discharge energy of the HIL test for the 10 minute interval.';

-- hil_data_summary_hourly
COMMENT ON VIEW public.hil_data_summary_hourly IS 'Materialized view of hil_data table aggregated by hourly intervals.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour IS 'The datetime rounded to the nearest hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hil_id IS 'Refers to the HIL test defined in hil_meta table.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_solution_time_ms IS 'The average solution time of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_state_of_charge IS 'The average state of charge of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_measured_voltage_mv IS 'The average measured voltage of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_modeled_voltage_mv IS 'The average modeled voltage of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_measured_current_ma IS 'The average measured current of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_modeled_current_ma IS 'The average modeled current of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_overpotential_mv IS 'The average overpotential of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_voltage_delta_mv IS 'The average voltage delta of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_reported_charge_capacity_mah IS 'The average reported charge capacity of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_reported_charge_energy_mwh IS 'The average reported charge energy of the HIL test for the hour.';
COMMENT ON COLUMN public.hil_data_summary_hourly.hour_reported_discharge_energy_mwh IS 'The average reported discharge energy of the HIL test for the hour.';

-- hil_data_summary_daily
COMMENT ON VIEW public.hil_data_summary_daily IS 'Materialized view of hil_data table aggregated by daily intervals.';
COMMENT ON COLUMN public.hil_data_summary_daily.day IS 'The datetime rounded to the nearest day.';
COMMENT ON COLUMN public.hil_data_summary_daily.hil_id IS 'Refers to the HIL test defined in hil_meta table.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_solution_time_ms IS 'The average solution time of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_state_of_charge IS 'The average state of charge of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_measured_voltage_mv IS 'The average measured voltage of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_modeled_voltage_mv IS 'The average modeled voltage of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_measured_current_ma IS 'The average measured current of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_modeled_current_ma IS 'The average modeled current of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_overpotential_mv IS 'The average overpotential of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_voltage_delta_mv IS 'The average voltage delta of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_reported_charge_capacity_mah IS 'The average reported charge capacity of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_reported_discharge_capacity_mah IS 'The average reported discharge capacity of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_reported_charge_energy_mwh IS 'The average reported charge energy of the HIL test for the day.';
COMMENT ON COLUMN public.hil_data_summary_daily.day_reported_discharge_energy_mwh IS 'The average reported discharge energy of the HIL test for the day.';

-- sil_data_summary_30s
COMMENT ON VIEW public.sil_data_summary_30s IS 'Materialized view of sil_data table aggregated by 30 second intervals.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec IS 'The datetime rounded to the nearest 30 second interval.';
COMMENT ON COLUMN public.sil_data_summary_30s.sil_id IS 'Refers to the SIL test defined in sil_meta table.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec_measured_voltage_mv IS 'The average measured voltage of the SIL test for the 30 second interval.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec_modeled_voltage_mv IS 'The average modeled voltage of the SIL test for the 30 second interval.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec_overpotential_mv IS 'The average overpotential of the SIL test for the 30 second interval.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec_solution_time_ms IS 'The average solution time of the SIL test for the 30 second interval.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec_voltage_delta_mv IS 'The average voltage delta of the SIL test for the 30 second interval.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec_modeled_current_ma IS 'The average modeled current of the SIL test for the 30 second interval.';
COMMENT ON COLUMN public.sil_data_summary_30s.thirtysec_measured_current_ma IS 'The average measured current of the SIL test for the 30 second interval.';

-- sil_data_summary_10min
COMMENT ON VIEW public.sil_data_summary_10min IS 'Materialized view of sil_data table aggregated by 10 minute intervals.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin IS 'The datetime rounded to the nearest 10 minute interval.';
COMMENT ON COLUMN public.sil_data_summary_10min.sil_id IS 'Refers to the SIL test defined in sil_meta table.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin_measured_voltage_mv IS 'The average measured voltage of the SIL test for the 10 minute interval.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin_modeled_voltage_mv IS 'The average modeled voltage of the SIL test for the 10 minute interval.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin_overpotential_mv IS 'The average overpotential of the SIL test for the 10 minute interval.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin_solution_time_ms IS 'The average solution time of the SIL test for the 10 minute interval.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin_voltage_delta_mv IS 'The average voltage delta of the SIL test for the 10 minute interval.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin_modeled_current_ma IS 'The average modeled current of the SIL test for the 10 minute interval.';
COMMENT ON COLUMN public.sil_data_summary_10min.tenmin_measured_current_ma IS 'The average measured current of the SIL test for the 10 minute interval.';

-- sil_data_summary_hourly
COMMENT ON VIEW public.sil_data_summary_hourly IS 'Materialized view of sil_data table aggregated by hourly intervals.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour IS 'The datetime rounded to the nearest hour.';
COMMENT ON COLUMN public.sil_data_summary_hourly.sil_id IS 'Refers to the SIL test defined in sil_meta table.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour_measured_voltage_mv IS 'The average measured voltage of the SIL test for the hour.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour_modeled_voltage_mv IS 'The average modeled voltage of the SIL test for the hour.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour_overpotential_mv IS 'The average overpotential of the SIL test for the hour.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour_solution_time_ms IS 'The average solution time of the SIL test for the hour.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour_voltage_delta_mv IS 'The average voltage delta of the SIL test for the hour.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour_modeled_current_ma IS 'The average modeled current of the SIL test for the hour.';
COMMENT ON COLUMN public.sil_data_summary_hourly.hour_measured_current_ma IS 'The average measured current of the SIL test for the hour.';

-- sil_data_summary_daily
COMMENT ON VIEW public.sil_data_summary_daily IS 'Materialized view of sil_data table aggregated by daily intervals.';
COMMENT ON COLUMN public.sil_data_summary_daily.day IS 'The datetime rounded to the nearest day.';
COMMENT ON COLUMN public.sil_data_summary_daily.sil_id IS 'Refers to the SIL test defined in sil_meta table.';
COMMENT ON COLUMN public.sil_data_summary_daily.day_measured_voltage_mv IS 'The average measured voltage of the SIL test for the day.';
COMMENT ON COLUMN public.sil_data_summary_daily.day_modeled_voltage_mv IS 'The average modeled voltage of the SIL test for the day.';
COMMENT ON COLUMN public.sil_data_summary_daily.day_overpotential_mv IS 'The average overpotential of the SIL test for the day.';
COMMENT ON COLUMN public.sil_data_summary_daily.day_solution_time_ms IS 'The average solution time of the SIL test for the day.';
COMMENT ON COLUMN public.sil_data_summary_daily.day_voltage_delta_mv IS 'The average voltage delta of the SIL test for the day.';
COMMENT ON COLUMN public.sil_data_summary_daily.day_modeled_current_ma IS 'The average modeled current of the SIL test for the day.';
COMMENT ON COLUMN public.sil_data_summary_daily.day_measured_current_ma IS 'The average measured current of the SIL test for the day.';

-- sim_data_summary_30s
COMMENT ON VIEW public.sim_data_summary_30s IS 'Materialized view of sim_data table aggregated by 30 second intervals.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec IS 'The datetime rounded to the nearest 30 second interval.';
COMMENT ON COLUMN public.sim_data_summary_30s.sim_id IS 'Refers to the simulation test defined in sim_meta table.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec_measured_voltage_mv IS 'The average measured voltage of the simulation test for the 30 second interval.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec_modeled_voltage_mv IS 'The average modeled voltage of the simulation test for the 30 second interval.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec_overpotential_mv IS 'The average overpotential of the simulation test for the 30 second interval.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec_solution_time_ms IS 'The average solution time of the simulation test for the 30 second interval.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec_voltage_delta_mv IS 'The average voltage delta of the simulation test for the 30 second interval.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec_modeled_current_ma IS 'The average modeled current of the simulation test for the 30 second interval.';
COMMENT ON COLUMN public.sim_data_summary_30s.thirtysec_measured_current_ma IS 'The average measured current of the simulation test for the 30 second interval.';

-- sim_data_summary_10min
COMMENT ON VIEW public.sim_data_summary_10min IS 'Materialized view of sim_data table aggregated by 10 minute intervals.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin IS 'The datetime rounded to the nearest 10 minute interval.';
COMMENT ON COLUMN public.sim_data_summary_10min.sim_id IS 'Refers to the simulation test defined in sim_meta table.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin_measured_voltage_mv IS 'The average measured voltage of the simulation test for the 10 minute interval.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin_modeled_voltage_mv IS 'The average modeled voltage of the simulation test for the 10 minute interval.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin_overpotential_mv IS 'The average overpotential of the simulation test for the 10 minute interval.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin_solution_time_ms IS 'The average solution time of the simulation test for the 10 minute interval.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin_voltage_delta_mv IS 'The average voltage delta of the simulation test for the 10 minute interval.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin_modeled_current_ma IS 'The average modeled current of the simulation test for the 10 minute interval.';
COMMENT ON COLUMN public.sim_data_summary_10min.tenmin_measured_current_ma IS 'The average measured current of the simulation test for the 10 minute interval.';

-- sim_data_summary_hourly
COMMENT ON VIEW public.sim_data_summary_hourly IS 'Materialized view of sim_data table aggregated by hourly intervals.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour IS 'The datetime rounded to the nearest hour.';
COMMENT ON COLUMN public.sim_data_summary_hourly.sim_id IS 'Refers to the simulation test defined in sim_meta table.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour_measured_voltage_mv IS 'The average measured voltage of the simulation test for the hour.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour_modeled_voltage_mv IS 'The average modeled voltage of the simulation test for the hour.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour_overpotential_mv IS 'The average overpotential of the simulation test for the hour.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour_solution_time_ms IS 'The average solution time of the simulation test for the hour.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour_voltage_delta_mv IS 'The average voltage delta of the simulation test for the hour.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour_modeled_current_ma IS 'The average modeled current of the simulation test for the hour.';
COMMENT ON COLUMN public.sim_data_summary_hourly.hour_measured_current_ma IS 'The average measured current of the simulation test for the hour.';

-- sim_data_summary_daily
COMMENT ON VIEW public.sim_data_summary_daily IS 'Materialized view of sim_data table aggregated by daily intervals.';
COMMENT ON COLUMN public.sim_data_summary_daily.day IS 'The datetime rounded to the nearest day.';
COMMENT ON COLUMN public.sim_data_summary_daily.sim_id IS 'Refers to the simulation test defined in sim_meta table.';
COMMENT ON COLUMN public.sim_data_summary_daily.day_measured_voltage_mv IS 'The average measured voltage of the simulation test for the day.';
COMMENT ON COLUMN public.sim_data_summary_daily.day_modeled_voltage_mv IS 'The average modeled voltage of the simulation test for the day.';
COMMENT ON COLUMN public.sim_data_summary_daily.day_overpotential_mv IS 'The average overpotential of the simulation test for the day.';
COMMENT ON COLUMN public.sim_data_summary_daily.day_solution_time_ms IS 'The average solution time of the simulation test for the day.';
COMMENT ON COLUMN public.sim_data_summary_daily.day_voltage_delta_mv IS 'The average voltage delta of the simulation test for the day.';
COMMENT ON COLUMN public.sim_data_summary_daily.day_modeled_current_ma IS 'The average modeled current of the simulation test for the day.';
COMMENT ON COLUMN public.sim_data_summary_daily.day_measured_current_ma IS 'The average measured current of the simulation test for the day.';

-- test_data_summary_30s
COMMENT ON VIEW public.test_data_summary_30s IS 'Materialized view of test_data table aggregated by 30 second intervals.';
COMMENT ON COLUMN public.test_data_summary_30s.thirtysec IS 'The datetime rounded to the nearest 30 second interval.';
COMMENT ON COLUMN public.test_data_summary_30s.test_id IS 'Refers to the test defined in test_meta table.';
COMMENT ON COLUMN public.test_data_summary_30s.thirtysec_cycle IS 'The cycle number of the test for the 30 second interval.';
COMMENT ON COLUMN public.test_data_summary_30s.thirtysec_test_time_s IS 'The total test time in seconds for the 30 second interval.';
COMMENT ON COLUMN public.test_data_summary_30s.thirtysec_unixtime_s IS 'The Unix timestamp for the 30 second interval.';
COMMENT ON COLUMN public.test_data_summary_30s.thirtysec_voltage_mv IS 'The average voltage of the test for the 30 second interval.';
COMMENT ON COLUMN public.test_data_summary_30s.thirtysec_current_ma IS 'The average current of the test for the 30 second interval.';

-- test_data_summary_10min
COMMENT ON VIEW public.test_data_summary_10min IS 'Materialized view of test_data table aggregated by 10 minute intervals.';
COMMENT ON COLUMN public.test_data_summary_10min.tenmin IS 'The datetime rounded to the nearest 10 minute interval.';
COMMENT ON COLUMN public.test_data_summary_10min.test_id IS 'Refers to the test defined in test_meta table.';
COMMENT ON COLUMN public.test_data_summary_10min.tenmin_cycle IS 'The cycle number of the test for the 10 minute interval.';
COMMENT ON COLUMN public.test_data_summary_10min.tenmin_test_time_s IS 'The total test time in seconds for the 10 minute interval.';
COMMENT ON COLUMN public.test_data_summary_10min.tenmin_unixtime_s IS 'The Unix timestamp for the 10 minute interval.';
COMMENT ON COLUMN public.test_data_summary_10min.tenmin_voltage_mv IS 'The average voltage of the test for the 10 minute interval.';
COMMENT ON COLUMN public.test_data_summary_10min.tenmin_current_ma IS 'The average current of the test for the 10 minute interval.';

-- test_data_summary_hourly
COMMENT ON VIEW public.test_data_summary_hourly IS 'Materialized view of test_data table aggregated by hourly intervals.';
COMMENT ON COLUMN public.test_data_summary_hourly.hour IS 'The datetime rounded to the nearest hour.';
COMMENT ON COLUMN public.test_data_summary_hourly.test_id IS 'Refers to the test defined in test_meta table.';
COMMENT ON COLUMN public.test_data_summary_hourly.hour_cycle IS 'The cycle number of the test for the hour.';
COMMENT ON COLUMN public.test_data_summary_hourly.hour_test_time_s IS 'The total test time in seconds for the hour.';
COMMENT ON COLUMN public.test_data_summary_hourly.hour_unixtime_s IS 'The Unix timestamp for the hour.';
COMMENT ON COLUMN public.test_data_summary_hourly.hour_voltage_mv IS 'The average voltage of the test for the hour.';
COMMENT ON COLUMN public.test_data_summary_hourly.hour_current_ma IS 'The average current of the test for the hour.';

-- test_data_summary_daily
COMMENT ON VIEW public.test_data_summary_daily IS 'Materialized view of test_data table aggregated by daily intervals.';
COMMENT ON COLUMN public.test_data_summary_daily.day IS 'The datetime rounded to the nearest day.';
COMMENT ON COLUMN public.test_data_summary_daily.test_id IS 'Refers to the test defined in test_meta table.';
COMMENT ON COLUMN public.test_data_summary_daily.day_cycle IS 'The cycle number of the test for the day.';
COMMENT ON COLUMN public.test_data_summary_daily.day_test_time_s IS 'The total test time in seconds for the day.';
COMMENT ON COLUMN public.test_data_summary_daily.day_unixtime_s IS 'The Unix timestamp for the day.';
COMMENT ON COLUMN public.test_data_summary_daily.day_voltage_mv IS 'The average voltage of the test for the day.';
COMMENT ON COLUMN public.test_data_summary_daily.day_current_ma IS 'The average current of the test for the day.';
