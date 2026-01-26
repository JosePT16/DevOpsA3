-- Create table
CREATE TABLE IF NOT EXISTS dishes (
    id INTEGER PRIMARY KEY,
    dish TEXT NOT NULL,
    country TEXT NOT NULL
);

-- Seed initial data
INSERT OR IGNORE INTO dishes (id, dish, country) VALUES
(1, 'Ceviche', 'Peru'),
(2, 'Tacos', 'Mexico'),
(3, 'BBQ', 'USA');