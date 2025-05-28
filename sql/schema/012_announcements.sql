-- +goose Up
CREATE TABLE announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT NOT NULL,
    published_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date TIMESTAMP,
    created_by UUID NOT NULL,
    CONSTRAINT fk_employee FOREIGN KEY (created_by) REFERENCES employees(id),
    CONSTRAINT check_type CHECK (type IN ('Introduction', 'Promotion', 'Notice', 'News'))
);
CREATE INDEX idx_announcement_type ON announcements(type);

-- +goose Down
DROP TABLE announcements;
