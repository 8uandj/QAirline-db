-- +goose Up
ALTER TABLE aircrafts 
ADD COLUMN aircraft_code TEXT UNIQUE NOT NULL,
ADD COLUMN manufacturer TEXT;

-- +goose Down
ALTER TABLE aircrafts
DROP COLUMN aircraft_code,
DROP COLUMN manufacturer;
