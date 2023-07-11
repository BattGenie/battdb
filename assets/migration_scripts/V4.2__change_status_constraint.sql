ALTER TABLE cycler_monitor_channel_statuses DROP CONSTRAINT status_vals;

ALTER TABLE cycler_monitor_channel_statuses 
ADD CONSTRAINT status_vals 
CHECK (status IN ('idle', 'rest', 'charge', 'discharge', 'problem', 'finished', 'other'));