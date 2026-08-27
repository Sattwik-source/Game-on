CREATE TABLE backups (
    id              UUID PRIMARY KEY,
    game_id         UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    -- ... your other columns
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);