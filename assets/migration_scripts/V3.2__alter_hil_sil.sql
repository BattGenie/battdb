ALTER TABLE hil_meta ADD COLUMN cell_type_id integer REFERENCES cells_meta (cell_type_id);
