-- Set cell_type_id to not null
ALTER TABLE cells
ALTER COLUMN cell_type_id
SET NOT NULL;