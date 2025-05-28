-- +goose Up
CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flight_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    ticket_class_id UUID NOT NULL,
    seat_number TEXT,
    price DECIMAL(10, 2) NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ticket_status TEXT NOT NULL DEFAULT 'PendingPayment',
    ticket_code UUID NOT NULL UNIQUE,
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES flights(id),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_ticket_class FOREIGN KEY (ticket_class_id) REFERENCES ticket_classes(id),
    CONSTRAINT check_status CHECK (ticket_status IN ('PendingPayment', 'Confirmed', 'Cancelled')),
    CONSTRAINT unique_flight_seat UNIQUE (flight_id, seat_number)
);

-- +goose Down
DROP TABLE tickets;
