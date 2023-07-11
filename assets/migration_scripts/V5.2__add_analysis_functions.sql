-- Get the charge data for given test names
CREATE OR REPLACE FUNCTION public.get_charge_data(test_names text[]) RETURNS TABLE (
	test_id integer, cycle integer,
	reported_charge_capacity_mah numeric,
	reported_discharge_capacity_mah numeric,
	calculated_cc_charge_time_s numeric,
	calculated_cv_charge_time_s numeric,
	calculated_eighty_percent_charge_time_s numeric,
	calculated_fifty_percent_charge_time_s numeric,
	calculated_coulombic_efficiency numeric
) AS $$
DECLARE
    v_test_id integer;
BEGIN
    FOR v_test_id IN SELECT test_meta.test_id FROM test_meta WHERE test_name = ANY(test_names) LOOP
        RETURN QUERY
        SELECT
        	v_test_id as test_id,
            ROW_NUMBER() OVER (ORDER BY test_data_cycle_stats.cycle)::integer AS cycle,
            MAX(CASE WHEN test_data_cycle_stats.test_id = v_test_id THEN test_data_cycle_stats.reported_charge_capacity_mah ELSE NULL END) AS reported_charge_capacity_mah,
            MAX(CASE WHEN test_data_cycle_stats.test_id = v_test_id THEN test_data_cycle_stats.reported_discharge_capacity_mah ELSE NULL END) AS reported_discharge_capacity_mah,
            MAX(CASE WHEN test_data_cycle_stats.test_id = v_test_id THEN test_data_cycle_stats.calculated_cc_charge_time_s ELSE NULL END) AS calculated_cc_charge_time_s,
            MAX(CASE WHEN test_data_cycle_stats.test_id = v_test_id THEN test_data_cycle_stats.calculated_cv_charge_time_s ELSE NULL END) AS calculated_cv_charge_time_s,
            MAX(CASE WHEN test_data_cycle_stats.test_id = v_test_id THEN test_data_cycle_stats.calculated_eighty_percent_charge_time_s ELSE NULL END) AS calculated_eighty_percent_charge_time_s,
            MAX(CASE WHEN test_data_cycle_stats.test_id = v_test_id THEN test_data_cycle_stats.calculated_fifty_percent_charge_time_s ELSE NULL END) AS calculated_fifty_percent_charge_time_s,
            MAX(CASE WHEN test_data_cycle_stats.test_id = v_test_id THEN test_data_cycle_stats.calculated_coulombic_efficiency ELSE NULL END) AS calculated_coulombic_efficiency
        FROM test_data_cycle_stats
        WHERE test_data_cycle_stats.test_id = v_test_id
        GROUP BY test_data_cycle_stats.cycle;
    END LOOP;
END;
$$ LANGUAGE PLpgSQL;

-- Example usage:
/*
SELECT t.test_name, g.test_id, g.cycle, g.reported_charge_capacity_mah, g.reported_discharge_capacity_mah
FROM public.get_charge_data(ARRAY['test_name_1', 'test_name_2']) g
JOIN test_meta t ON g.test_id = t.test_id
*/
