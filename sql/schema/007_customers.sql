-- +goose Up
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_date DATE,
    gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
    identity_number TEXT UNIQUE,
    phone_number TEXT,
    email TEXT UNIQUE NOT NULL,
    address TEXT,
    country TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_customer_email ON customers(email);

-- +goose Down
DROP TABLE customers;
