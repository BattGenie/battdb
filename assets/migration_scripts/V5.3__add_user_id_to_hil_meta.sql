ALTER TABLE hil_meta
ADD COLUMN user_id text;

UPDATE hil_meta
SET user_id = 'unknown'
WHERE user_id IS NULL;

ALTER TABLE hil_meta
ALTER COLUMN user_id SET NOT NULL;