-- +migrate Up
-- Create extension for UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create game_types enum
CREATE TYPE game_type AS ENUM ('mega_6_45', 'power_6_55');

-- Create drawings table
CREATE TABLE drawings (
    id SERIAL PRIMARY KEY,
    game_type game_type NOT NULL,
    numbers INTEGER[] NOT NULL,
    bonus_number INTEGER,
    draw_time TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT drawings_numbers_length CHECK (
        (game_type = 'mega_6_45' AND array_length(numbers, 1) = 6) OR
        (game_type = 'power_6_55' AND array_length(numbers, 1) = 6)
    ),
    CONSTRAINT drawings_bonus_number_check CHECK (
        (game_type = 'mega_6_45' AND bonus_number IS NULL) OR
        (game_type = 'power_6_55')
    )
);

-- Create prize_categories table
CREATE TABLE prize_categories (
    id SERIAL PRIMARY KEY,
    game_type game_type NOT NULL,
    name VARCHAR(50) NOT NULL,
    match_count INTEGER NOT NULL,
    include_bonus BOOLEAN NOT NULL DEFAULT FALSE,
    prize_amount DECIMAL(15, 2),
    prize_percentage DECIMAL(5, 2),
    CONSTRAINT prize_categories_match_count_check CHECK (
        (game_type = 'mega_6_45' AND match_count BETWEEN 3 AND 6) OR
        (game_type = 'power_6_55' AND match_count BETWEEN 3 AND 6)
    )
);

-- Create tickets table
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    game_type game_type NOT NULL,
    numbers INTEGER[] NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tickets_numbers_length CHECK (
        (game_type = 'mega_6_45' AND array_length(numbers, 1) = 6) OR
        (game_type = 'power_6_55' AND array_length(numbers, 1) = 6)
    ),
    CONSTRAINT tickets_numbers_range CHECK (
        (game_type = 'mega_6_45' AND (
            SELECT bool_and(n BETWEEN 1 AND 45) FROM unnest(numbers) AS n
        )) OR
        (game_type = 'power_6_55' AND (
            SELECT bool_and(n BETWEEN 1 AND 55) FROM unnest(numbers) AS n
        ))
    )
);

-- Create drawing_results table
CREATE TABLE drawing_results (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER REFERENCES tickets(id),
    drawing_id INTEGER REFERENCES drawings(id),
    matched_numbers INTEGER[] NOT NULL,
    matched_bonus BOOLEAN NOT NULL DEFAULT FALSE,
    prize_category_id INTEGER REFERENCES prize_categories(id),
    prize_amount DECIMAL(15, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(ticket_id, drawing_id)
);

-- Insert initial prize categories for Mega 6/45
INSERT INTO prize_categories (game_type, name, match_count, include_bonus, prize_percentage)
VALUES
    ('mega_6_45', 'Jackpot', 6, FALSE, 65.0),
    ('mega_6_45', 'First Prize', 5, FALSE, 20.0),
    ('mega_6_45', 'Second Prize', 4, FALSE, 10.0),
    ('mega_6_45', 'Third Prize', 3, FALSE, 5.0);

-- Insert initial prize categories for Power 6/55
INSERT INTO prize_categories (game_type, name, match_count, include_bonus, prize_percentage)
VALUES
    ('power_6_55', 'Jackpot 1', 6, FALSE, 60.0),
    ('power_6_55', 'Jackpot 2', 5, TRUE, 20.0),
    ('power_6_55', 'First Prize', 5, FALSE, 10.0),
    ('power_6_55', 'Second Prize', 4, FALSE, 7.0),
    ('power_6_55', 'Third Prize', 3, FALSE, 3.0);

-- Create indexes for performance
CREATE INDEX idx_tickets_user_id ON tickets(user_id);
CREATE INDEX idx_tickets_game_type ON tickets(game_type);
CREATE INDEX idx_drawings_game_type ON drawings(game_type);
CREATE INDEX idx_drawings_draw_time ON drawings(draw_time);
CREATE INDEX idx_drawing_results_ticket_id ON drawing_results(ticket_id);
CREATE INDEX idx_drawing_results_drawing_id ON drawing_results(drawing_id);

-- Create a view for active drawings
CREATE VIEW active_drawings AS
SELECT *
FROM drawings
WHERE draw_time > CURRENT_TIMESTAMP
ORDER BY draw_time ASC;

-- Create a function to check if ticket numbers are valid
CREATE OR REPLACE FUNCTION validate_ticket_numbers()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there are duplicate numbers
    IF (SELECT COUNT(DISTINCT n) FROM unnest(NEW.numbers) AS n) != array_length(NEW.numbers, 1) THEN
        RAISE EXCEPTION 'Ticket contains duplicate numbers';
    END IF;

    -- Check number range based on game type
    IF NEW.game_type = 'mega_6_45' THEN
        IF NOT (SELECT bool_and(n BETWEEN 1 AND 45) FROM unnest(NEW.numbers) AS n) THEN
            RAISE EXCEPTION 'Mega 6/45 ticket numbers must be between 1 and 45';
        END IF;
    ELSIF NEW.game_type = 'power_6_55' THEN
        IF NOT (SELECT bool_and(n BETWEEN 1 AND 55) FROM unnest(NEW.numbers) AS n) THEN
            RAISE EXCEPTION 'Power 6/55 ticket numbers must be between 1 and 55';
        END IF;
    END IF;

    -- Check number count based on game type
    IF (NEW.game_type = 'mega_6_45' OR NEW.game_type = 'power_6_55') AND array_length(NEW.numbers, 1) != 6 THEN
        RAISE EXCEPTION 'Ticket must contain exactly 6 numbers';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for ticket validation
CREATE TRIGGER validate_ticket_before_insert
BEFORE INSERT ON tickets
FOR EACH ROW
EXECUTE FUNCTION validate_ticket_numbers();

-- Sample user for development
INSERT INTO users (username, email)
VALUES ('testuser', 'test@example.com');

-- +migrate Down
DROP TRIGGER IF EXISTS validate_ticket_before_insert ON tickets;
DROP FUNCTION IF EXISTS validate_ticket_numbers();
DROP VIEW IF EXISTS active_drawings;
DROP TABLE IF EXISTS drawing_results;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS prize_categories;
DROP TABLE IF EXISTS drawings;
DROP TYPE IF EXISTS game_type;
DROP TABLE IF EXISTS users;
DROP EXTENSION IF EXISTS "uuid-ossp";
