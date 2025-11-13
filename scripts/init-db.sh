#!/bin/bash

# Database initialization script
# This is run automatically by the backend container, but can be run manually if needed

set -e

DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-prod_sim}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-postgres}

echo "Initializing database..."

PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << EOF
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_items_created_at ON items(created_at);

-- Insert sample data (optional)
INSERT INTO items (name) VALUES ('Sample Item 1'), ('Sample Item 2')
ON CONFLICT DO NOTHING;
EOF

echo "Database initialized successfully!"

