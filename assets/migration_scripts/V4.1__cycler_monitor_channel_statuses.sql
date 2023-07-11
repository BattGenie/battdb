CREATE TABLE public.cycler_monitor_channel_statuses (
    id SERIAL PRIMARY KEY,
    cycler_id INTEGER NOT NULL,
    channel SMALLINT NOT NULL,
    status TEXT NOT NULL,
    cycle SMALLINT,
    step SMALLINT,
    test_time_s NUMERIC,
    step_time_s NUMERIC,
    voltage_mv INTEGER,
    current_ma INTEGER,
    charge_capacity_mah INTEGER,
    discharge_capacity_mah INTEGER,
    charge_energy_mwh INTEGER,
    discharge_energy_mwh INTEGER,
    timestamp_s float NOT NULL,
    insert_time timestamp with time zone DEFAULT now() NOT NULL,
    other_details JSONB
);

ALTER TABLE cycler_monitor_channel_statuses 
ADD CONSTRAINT status_vals 
CHECK (status IN ('idle', 'rest', 'charge', 'discharge', 'problem', 'other'));

ALTER TABLE ONLY public.cycler_monitor_channel_statuses
ADD CONSTRAINT cycler_id_fkey 
FOREIGN KEY (cycler_id) 
REFERENCES public.cyclers(cycler_id);