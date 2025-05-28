-- +goose Up
CREATE TABLE airlines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL DEFAULT 'QAirline',
    code TEXT UNIQUE NOT NULL DEFAULT 'QA',
    CONSTRAINT check_code_length CHECK (LENGTH(code) >= 2)
);

INSERT INTO airlines (name, code) VALUES ('QAirline', 'QA');

-- +goose Down
DROP TABLE airlines;
