-- +goose Up
CREATE TABLE ticket_classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_name TEXT NOT NULL,
    coefficient DECIMAL(4, 2) NOT NULL,
    CONSTRAINT check_coefficient CHECK (coefficient >= 1.0)
);
INSERT INTO ticket_classes (class_name, coefficient) VALUES 
    ('First Class', 2.0),
    ('Business Class', 1.5),
    ('Economy Class', 1.0);


-- +goose Down
DROP TABLE ticket_classes;
