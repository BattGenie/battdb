-- Create other_detail (type = JSONB) columns in sil_data and hil_data tables
ALTER TABLE sil_data
ADD COLUMN other_detail JSONB;
ALTER TABLE hil_data
ADD COLUMN other_detail JSONB;
-- Within sil_meta table rename column batterytype_id to cell_type_id
ALTER TABLE sil_meta
    RENAME COLUMN batterytype_id TO cell_type_id;