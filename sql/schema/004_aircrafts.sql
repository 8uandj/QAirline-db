-- +goose Up
CREATE TABLE aircrafts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id UUID NOT NULL,
    aircraft_type TEXT NOT NULL,
    total_first_class_seats INT NOT NULL,
    total_business_class_seats INT NOT NULL,
    total_economy_class_seats INT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_airline FOREIGN KEY (airline_id) REFERENCES airlines(id),
    CONSTRAINT check_status CHECK (status IN ('Active', 'Maintenance', 'Retired')),
    CONSTRAINT check_seats_positive CHECK (total_first_class_seats >= 0 AND total_business_class_seats >= 0 AND total_economy_class_seats >= 0)
);

-- +goose Down
DROP TABLE aircrafts;
