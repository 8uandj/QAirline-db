# QAirline Database Schema README

## Run up migration

### 1. Install Goose
Make sure you installed Go.
Goose is just a command line tool that happens to be written in Go. I recommend installing it using go install:

```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
```

Run `goose -version` to make sure it's installed correctly.

### 2. DB connection string
Get your connection string. A connection string is just a URL with all of the information needed to connect to a database. The format is:

`protocol://username:password@host:port/database`

Here are examples:
- macOS (no password, your username): `postgres://wagslane:@localhost:5432/qairline`
- Linux (the password you set, postgres user): `postgres://postgres:postgres@localhost:5432/qairline`

Test your connection string by running psql, for example:
```bash
psql "postgres://wagslane:@localhost:5432/qairline"
```

### 3. Run the up migration
```bash
goose postgres <connection_string> up
```

Run your migration! Make sure it works by using psql to find your newly created schema:
```bash
psql chirpy
\dt
```

## Overview
This PostgreSQL database schema supports the QAirline ticketing system for a single airline (QAirline). Key features:
- **Customer**: View announcements, search/book/cancel/track tickets without login, receive QR code via email.
- **Admin**: Manage announcements, aircraft, flights, booking statistics, and flight delays.
- **Design**: Normalized (3NF), scalable, uses simulated payments, optimized with indexes.

## Schema (PostgreSQL)

### 1. `airlines`
Stores QAirline info (scalable for more airlines).
- **Fields**: `airline_id` (SERIAL, PK), `airline_name` (VARCHAR, DEFAULT 'QAirline'), `code` (VARCHAR, UNIQUE, DEFAULT 'QA'), `logo_url`, `contact_info`.
- **Constraints**: `CHECK (LENGTH(code) >= 2)`.
- **Relationships**: 1-N with `aircrafts`, `flights`.

### 2. `airports`
Stores airport info.
- **Fields**: `airport_id` (SERIAL, PK), `airport_code` (VARCHAR, UNIQUE), `airport_name` (VARCHAR), `city`, `country`.
- **Constraints**: `CHECK (LENGTH(airport_code) = 3)`.
- **Relationships**: 1-N with `routes`.

### 3. `routes`
Stores flight routes.
- **Fields**: `route_id` (SERIAL, PK), `departure_airport_id` (INT, FK), `arrival_airport_id` (INT, FK), `distance` (DECIMAL), `base_price` (DECIMAL).
- **Constraints**: `FK` to `airports`, `CHECK (departure != arrival)`.
- **Relationships**: 1-N with `flights`.

### 4. `aircrafts`
Stores aircraft details.
- **Fields**: `aircraft_id` (SERIAL, PK), `airline_id` (INT, FK), `aircraft_code` (VARCHAR, UNIQUE), `manufacturer` (VARCHAR), `aircraft_type` (VARCHAR), `total_first_class_seats` (INT), `total_business_class_seats` (INT), `total_economy_class_seats` (INT), `status` (VARCHAR, DEFAULT 'Active').
- **Constraints**: `FK` to `airlines`, `CHECK (status IN ('Active', 'Maintenance', 'Retired'))`, `CHECK (seats >= 0)`.
- **Relationships**: 1-N with `flights`.

### 5. `flights`
Stores flight schedules.
- **Fields**: `flight_id` (SERIAL, PK), `airline_id` (INT, FK), `flight_number` (VARCHAR, UNIQUE), `route_id` (INT, FK), `aircraft_id` (INT, FK), `departure_time` (TIMESTAMP), `arrival_time` (TIMESTAMP), `flight_status` (VARCHAR, DEFAULT 'Scheduled'), `base_first_class_price` (DECIMAL), `base_business_class_price` (DECIMAL), `base_economy_class_price` (DECIMAL).
- **Constraints**: `FK` to `airlines`, `routes`, `aircrafts`, `CHECK (status IN (...))`, `CHECK (departure_time < arrival_time)`.
- **Indexes**: `departure_time`, `route_id`.
- **Relationships**: 1-N with `tickets`.

### 6. `ticket_classes`
Stores ticket classes.
- **Fields**: `ticket_class_id` (SERIAL, PK), `class_name` (VARCHAR), `coefficient` (DECIMAL).
- **Constraints**: `CHECK (coefficient >= 1.0)`.
- **Relationships**: 1-N with `tickets`.

### 7. `customers`
Stores customer info (no login).
- **Fields**: `customer_id` (SERIAL, PK), `first_name` (VARCHAR), `last_name` (VARCHAR), `birth_date` (DATE), `gender` (VARCHAR), `identity_number` (VARCHAR, UNIQUE), `phone_number` (VARCHAR), `email` (VARCHAR, UNIQUE), `address` (VARCHAR), `country` (VARCHAR), `created_at` (TIMESTAMP).
- **Constraints**: `CHECK (gender IN ('Male', 'Female', 'Other'))`.
- **Index**: `email`.
- **Relationships**: 1-N with `tickets`.

### 8. `tickets`
Stores ticket info.
- **Fields**: `ticket_id` (SERIAL, PK), `flight_id` (INT, FK), `customer_id` (INT, FK), `ticket_class_id` (INT, FK), `seat_number` (VARCHAR), `price` (DECIMAL), `booking_date` (TIMESTAMP), `ticket_status` (VARCHAR, DEFAULT 'PendingPayment'), `ticket_code` (UUID, UNIQUE), `cancellation_deadline` (TIMESTAMP).
- **Constraints**: `FK` to `flights`, `customers`, `ticket_classes`, `CHECK (status IN (...))`, `UNIQUE (flight_id, seat_number)`.
- **Indexes**: `flight_id`, `ticket_code`.
- **Relationships**: 1-N with `payment_simulations`.

### 9. `payment_simulations`
Simulates payments.
- **Fields**: `simulation_id` (SERIAL, PK), `ticket_id` (INT, FK), `amount` (DECIMAL), `simulation_date` (TIMESTAMP), `simulation_status` (VARCHAR, DEFAULT 'Pending'), `notes` (VARCHAR).
- **Constraints**: `FK` to `tickets`, `CHECK (status IN ('Pending', 'Completed', 'Failed'))`.
- **Relationships**: Linked to `tickets`.

### 10. `employees`
Stores admin/staff info.
- **Fields**: `employee_id` (SERIAL, PK), `first_name` (VARCHAR), `last_name` (VARCHAR), `email` (VARCHAR, UNIQUE), `password_hash` (VARCHAR), `role` (VARCHAR), `created_at` (TIMESTAMP).
- **Constraints**: `CHECK (role IN ('Admin', 'Staff', 'Manager'))`.
- **Relationships**: 1-N with `activity_logs`, `announcements`.

### 11. `announcements`
Stores airline announcements.
- **Fields**: `announcement_id` (SERIAL, PK), `title` (VARCHAR), `content` (TEXT), `type` (VARCHAR), `published_date` (TIMESTAMP), `expiry_date` (TIMESTAMP), `created_by` (INT, FK).
- **Constraints**: `FK` to `employees`, `CHECK (type IN ('Introduction', 'Promotion', 'Notice', 'News'))`.
- **Index**: `type`.

### 12. `reports`
Stores booking/revenue reports.
- **Fields**: `report_id` (SERIAL, PK), `report_type` (VARCHAR), `generated_date` (TIMESTAMP), `data` (JSONB).
- **Constraints**: `CHECK (report_type IN ('Revenue', 'TicketSales', 'FlightStatus'))`.

### 13. `activity_logs`
Tracks admin actions.
- **Fields**: `log_id` (SERIAL, PK), `employee_id` (INT, FK), `action` (VARCHAR), `details` (JSONB), `created_at` (TIMESTAMP).
- **Constraints**: `FK` to `employees`.

## ERD
- `airlines` 1-N `aircrafts`, `flights`.
- `routes` 1-N `flights`.
- `aircrafts` 1-N `flights`.
- `ticket_classes` 1-N `tickets`.
- `customers` 1-N `tickets`.
- `flights` 1-N `tickets`.
- `tickets` 1-N `payment_simulations`.
- `employees` 1-N `activity_logs`, `announcements`.
- `airports` 1-N `routes` (departure, arrival).

## Setup
1. Install PostgreSQL (15+).
2. Create database: `CREATE DATABASE qairline;`
3. Run schema SQL (provided separately).
4. Insert initial data: `airlines` (QAirline), `ticket_classes` (First, Business, Economy).
5. Configure APIs (e.g., Node.js/Express) and SMTP (e.g., SendGrid).

## Notes
- **Security**: Use bcrypt for `employees.password_hash`, HTTPS for APIs, TLS for emails.
- **Performance**: Indexes on `flights(departure_time)`, `tickets(flight_id, ticket_code)`, `customers(email)`, `announcements(type)`.
- **Scalability**: Supports real payments, customer login, multiple airlines.
- **Frontend**: Customer UI for search/booking/tracking; admin UI for management.

## Contact
For support, contact [phucfix7@proton.me].
