ALTER TABLE 
    test_data 
ALTER COLUMN 
    recorded_datetime 
DROP
    not null;

ALTER TABLE 
    test_data 
ALTER COLUMN 
    unixtime_s 
DROP
    not null;