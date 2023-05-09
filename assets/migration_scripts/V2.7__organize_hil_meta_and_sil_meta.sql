--hil_meta
ALTER TABLE hil_meta
    RENAME COLUMN procedure_name TO schedule_name;
--sil_meta
ALTER TABLE sil_meta DROP COLUMN silstreamer_config;
ALTER TABLE sil_meta DROP COLUMN model_config;
ALTER TABLE sil_meta
ADD COLUMN configs jsonb;
ALTER TABLE sil_meta
ADD COLUMN other_details jsonb;