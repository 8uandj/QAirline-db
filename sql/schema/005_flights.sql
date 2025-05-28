-- +goose Up
CREATE TABLE flights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id UUID NOT NULL,
    flight_number TEXT UNIQUE NOT NULL,
    route_id UUID NOT NULL,
    aircraft_id UUID NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    flight_status TEXT NOT NULL DEFAULT 'Scheduled',
    base_first_class_price DECIMAL(10, 2),
    base_business_class_price DECIMAL(10, 2),
    base_economy_class_price DECIMAL(10, 2),
    CONSTRAINT fk_airline FOREIGN KEY (airline_id) REFERENCES airlines(id),
    CONSTRAINT fk_route FOREIGN KEY (route_id) REFERENCES routes(id),
    CONSTRAINT fk_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircrafts(id),
    CONSTRAINT check_status CHECK (flight_status IN ('Scheduled', 'Departed', 'Arrived', 'Cancelled', 'Delayed')),
    CONSTRAINT check_time CHECK (departure_time < arrival_time)
);
CREATE INDEX idx_flight_departure ON flights(departure_time);
CREATE INDEX idx_flight_route ON flights(route_id);

-- +goose Down
DROP TABLE flights;
