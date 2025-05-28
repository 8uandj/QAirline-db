-- +goose Up
CREATE TABLE payment_simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    simulation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    simulation_status TEXT NOT NULL DEFAULT 'Pending',
    notes TEXT,
    CONSTRAINT fk_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(id),
    CONSTRAINT check_status CHECK (simulation_status IN ('Pending', 'Completed', 'Failed'))
);

-- +goose Down
DROP TABLE payment_simulations;
