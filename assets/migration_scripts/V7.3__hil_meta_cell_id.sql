ALTER TABLE 
    hil_meta 
DROP COLUMN 
    cell_type_id;

ALTER TABLE 
    hil_meta 
ADD COLUMN 
    cell_id INT;