-- Unique the combination of manufacturer and manufacturer_pn
CREATE UNIQUE INDEX unique_manufacturer_and_pn ON cells_meta(manufacturer, manufacturer_pn);