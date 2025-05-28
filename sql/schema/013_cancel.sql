-- +goose Up
ALTER TABLE tickets ADD COLUMN cancellation_deadline TIMESTAMP;

-- +goose Down
ALTER TABLE tickets DROP COLUMN cancellation_deadline;
