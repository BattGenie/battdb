-- Set schedule_files type to jsonb
ALTER TABLE schedule_meta
ALTER COLUMN schedule_files TYPE jsonb USING schedule_files::jsonb;