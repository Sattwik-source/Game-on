-- ═══════════════════════════════════════════════════════════════════════
-- GameOn schema — H2 variant (zero-install local dev)
--
-- Same shape as db/migration/V1__init.sql, but without Postgres-only
-- features (pgcrypto, gen_random_uuid()). Hibernate generates UUIDs
-- application-side for both profiles, so DB-side defaults aren't needed.
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE users (
    id                UUID PRIMARY KEY,
    email             VARCHAR(255) UNIQUE NOT NULL,
    display_name      VARCHAR(255),
    google_sub        VARCHAR(255) UNIQUE NOT NULL,
    picture_url        TEXT,
    google_access_token  TEXT,
    google_refresh_token TEXT,
    drive_folder_id   VARCHAR(255),
    storage_used_mb   INTEGER DEFAULT 0,
    plan              VARCHAR(20) DEFAULT 'free',
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE games (
    id                UUID PRIMARY KEY,
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name              VARCHAR(255) NOT NULL,
    slug              VARCHAR(255) NOT NULL,
    exe_path          TEXT,
    save_paths        ARCHAR(2000),
    drive_folder_id   VARCHAR(255),
    platform          VARCHAR(20) DEFAULT 'pc',
    is_active         BOOLEAN DEFAULT TRUE,
    last_synced_at    TIMESTAMP,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE backups (
    id                 UUID PRIMARY KEY,
    game_id            UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    user_id            UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    drive_file_id      VARCHAR(255) NOT NULL,
    drive_rev_id       VARCHAR(255),
    file_name          VARCHAR(255) NOT NULL,
    file_path          TEXT NOT NULL,
    size_bytes         BIGINT DEFAULT 0,
    compressed_bytes   BIGINT DEFAULT 0,
    checksum           VARCHAR(64),
    label              VARCHAR(255),
    trigger_type       VARCHAR(20) DEFAULT 'auto',
    status             VARCHAR(20) DEFAULT 'pending',
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE devices (
    id            UUID PRIMARY KEY,
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_name   VARCHAR(255) NOT NULL,
    platform      VARCHAR(20),
    last_seen_at  TIMESTAMP,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_games_user_id     ON games(user_id);
CREATE INDEX idx_backups_game_id   ON backups(game_id);
CREATE INDEX idx_backups_user_id   ON backups(user_id);
CREATE INDEX idx_backups_created   ON backups(created_at DESC);
CREATE INDEX idx_devices_user_id   ON devices(user_id);
