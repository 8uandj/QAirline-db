-- +goose Up
CREATE TABLE airports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    city TEXT,
    country TEXT,
    CONSTRAINT check_airport_code CHECK (LENGTH(code) = 3)
);


-- +goose Down
DROP TABLE airports;
