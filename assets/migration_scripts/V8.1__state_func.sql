-- This function takes the hil_id, time_from and time_to as arguments and returns the state values for the given time range.
-- The function is used to generate the state columns for visualization in BattMon
-- This only works for a maximum of 17 states. If more states are needed, the function needs to be extended.
-- This function only works for a time range of 3 hours. If a longer time range is needed, the function needs to be extended.

CREATE OR REPLACE FUNCTION public.generate_tank_model_17_state_cols_sql(IN hil_id_arg integer,IN time_from_arg text,IN time_to_arg text)
    RETURNS TABLE(insert_time timestamp with time zone, state_1 numeric, state_2 numeric, state_3 numeric, state_4 numeric, state_5 numeric, state_6 numeric, state_7 numeric, state_8 numeric, state_9 numeric, state_10 numeric, state_11 numeric, state_12 numeric, state_13 numeric, state_14 numeric, state_15 numeric, state_16 numeric, state_17 numeric)
    LANGUAGE 'plpgsql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100    ROWS 1000 
    
AS $BODY$
DECLARE
    max_length int;
    sql text;
BEGIN
    -- Find the maximum array length
    SELECT MAX(array_length(model_states, 1)) INTO max_length FROM hil_data 
    WHERE hil_id = hil_id_arg limit 1;

    -- Initialize SQL query
    sql := 'SELECT insert_time';

    -- Generate the crosstab query
    FOR i IN 1..max_length LOOP
        sql := sql || ', model_states[' || i || '] AS state_' || i;
    END LOOP;
    
    sql := sql || ' FROM hil_data WHERE $2 - $1 <= ''3 hours''::interval AND  insert_time BETWEEN $1 AND $2 AND hil_id = $3 order by insert_time';

    RETURN QUERY EXECUTE sql USING time_from_arg::timestamp, time_to_arg::timestamp, hil_id_arg;
END;
$BODY$;