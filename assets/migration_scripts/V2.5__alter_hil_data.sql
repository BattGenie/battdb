-- Changing hil_data to match sil_data
ALTER TABLE hil_data 
RENAME COLUMN optimal_current_ma TO modeled_current_ma;