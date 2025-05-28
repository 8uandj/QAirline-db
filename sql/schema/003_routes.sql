-- +goose Up
CREATE TABLE routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    departure_airport_id UUID NOT NULL,
    arrival_airport_id UUID NOT NULL,
    distance DECIMAL(10, 2),
    base_price DECIMAL(10, 2),
    CONSTRAINT fk_departure_airport FOREIGN KEY (departure_airport_id) REFERENCES airports(id),
    CONSTRAINT fk_arrival_airport FOREIGN KEY (arrival_airport_id) REFERENCES airports(id),
    CONSTRAINT check_different_airports CHECK (departure_airport_id != arrival_airport_id)
);


-- +goose Down
DROP TABLE routes;
