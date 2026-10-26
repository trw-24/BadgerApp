-- Initial database setup for Badger Delivery Service
-- This script runs automatically when the PostgreSQL container starts

-- Create the main tables
CREATE TABLE IF NOT EXISTS badgers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'available',
    last_seen TIMESTAMP,
    delivery_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255),
    api_key VARCHAR(255),
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    preferences TEXT
);

CREATE TABLE IF NOT EXISTS deliveries (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    badger_id INTEGER REFERENCES badgers(id),
    pickup_location VARCHAR(255),
    delivery_location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    tracking_data TEXT
);

-- Insert some sample data for development
INSERT INTO badgers (name, location, status, delivery_count) VALUES
    ('Honey', 'Central Park, NYC', 'available', 15),
    ('Badger McBadgerface', 'Golden Gate Park, SF', 'busy', 23),
    ('Stripey', 'Hyde Park, London', 'available', 8),
    ('Digger', 'Yellowstone National Park', 'offline', 42),
    ('Snuffy', 'Stanley Park, Vancouver', 'available', 12),
    ('Brock', 'Regent''s Park, London', 'maintenance', 31),
    ('Patches', 'Central Park, NYC', 'available', 7),
    ('Bandit', 'Griffith Park, LA', 'busy', 19);

INSERT INTO users (username, email, api_key, password_hash) VALUES
    ('admin', 'admin@badgerdelivery.com', 'admin_key_12345', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
    ('testuser', 'test@badgerdelivery.com', 'user_key_67890', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5'),
    ('developer', 'dev@badgerdelivery.com', 'debug_key', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
    ('demo', 'demo@badgerdelivery.com', 'test123', 'cc03e747a6afbbcbf8be7668acfebee5');

INSERT INTO deliveries (user_id, badger_id, pickup_location, delivery_location, status) VALUES
    (2, 1, 'Times Square, NYC', '123 Main St, NYC', 'completed'),
    (2, 3, 'Piccadilly Circus, London', '456 Oak Ave, London', 'in_transit'),
    (3, 5, 'Downtown Vancouver', '789 Pine St, Vancouver', 'pending'),
    (4, 2, 'Union Square, SF', '321 Elm St, SF', 'completed');

-- Create indexes for better performance (though we removed parameterized queries for vulnerability demo)
CREATE INDEX idx_badgers_location ON badgers(location);
CREATE INDEX idx_badgers_status ON badgers(status);
CREATE INDEX idx_users_api_key ON users(api_key);
CREATE INDEX idx_deliveries_status ON deliveries(status);
CREATE INDEX idx_deliveries_user_id ON deliveries(user_id);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO badger_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO badger_admin;
