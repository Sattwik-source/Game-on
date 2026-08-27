# GameOn 🎮

> Automatic cloud backup for local game saves — Flutter desktop app + Spring Boot backend.

---

## Stack

| Layer | Tech |
|---|---|
| Desktop app | Flutter (Windows / macOS / Linux) |
| Backend API | Java 21 + Spring Boot 3.3 |
| Database | PostgreSQL + Flyway migrations |
| Cloud storage | User's own Google Drive (`drive.file` scope) |
| Auth | Google OAuth 2.0 (desktop loopback flow) + JWT |
| Encryption | AES-256-GCM, client-side, before upload |

---

## Folder structure

```
gameon-flutter/
├── app/                       Flutter desktop app
│   ├── lib/
│   │   ├── main.dart          Entry point, window setup
│   │   ├── app.dart           Root widget, provider tree
│   │   ├── core/
│   │   │   ├── constants/     Colors, routes, API endpoints
│   │   │   ├── theme/         App-wide ThemeData
│   │   │   ├── models/        User, Game, Backup
│   │   │   └── services/      API client, auth, crypto, drive, watcher, detector
│   │   ├── state/              Provider (ChangeNotifier) state
│   │   ├── screens/            Login, Home, Library, Backups, Settings
│   │   └── widgets/            layout/, common/, games/, backups/, dashboard/
│   ├── windows/, macos/, linux/  (generate with `flutter create`)
│   └── pubspec.yaml
│
└── backend/                   Spring Boot API
    ├── src/main/java/com/gameon/
    │   ├── GameOnApplication.java
    │   ├── config/             Security, CORS, Google OAuth beans
    │   ├── controller/         REST endpoints
    │   ├── service/            Business logic
    │   ├── model/               JPA entities
    │   ├── repository/          Spring Data JPA
    │   ├── dto/                 Request/response records
    │   ├── security/            JWT service + filter
    │   └── exception/           Global error handler
    ├── src/main/resources/
    │   ├── application.yml
    │   └── db/migration/V1__init.sql
    └── pom.xml
```

---

## Prerequisites

- **Flutter SDK** 3.22+ (`flutter --version`) — [install guide](https://docs.flutter.dev/get-started/install)
- **Java 21** (`java -version`)
- **Maven** 3.9+ (or use the included `mvnw` wrapper if you add one)
- **PostgreSQL** 15+
- A **Google Cloud project** with the Drive API enabled (see below)

---

## 1. Google Cloud setup

1. Go to [console.cloud.google.com](https://console.cloud.google.com) → new project `GameOn`
2. Enable **Google Drive API**
3. **OAuth consent screen** → External → add scope `drive.file`
4. **Credentials** → Create OAuth client ID → **Desktop app**
5. Copy the **Client ID** and **Client Secret**

> Note: unlike a typical web OAuth flow, GameOn uses the **desktop loopback**
> pattern (RFC 8252) — the redirect URI is `http://127.0.0.1:<random-port>`,
> built dynamically per login. You don't need to pre-register a fixed
> redirect URI in Google Cloud Console for this flow with a Desktop app
> client type.

---

## 2. Backend setup

You don't need Docker or a PostgreSQL install to get started. Pick whichever fits where you are right now:

### Option A — H2 (zero install, recommended for first run)

An embedded database that ships inside the JAR — nothing to install, nothing to run separately. Data is saved to a local file (`backend/data/gameon.mv.db`) and survives restarts.

```bash
cd backend

# Windows PowerShell
$env:JWT_SECRET="dev_secret_change_this_later_32_chars_min"
$env:GOOGLE_CLIENT_ID="your_client_id"
$env:GOOGLE_CLIENT_SECRET="your_client_secret"

.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=h2"
```

```bash
# macOS / Linux
export JWT_SECRET="dev_secret_change_this_later_32_chars_min"
export GOOGLE_CLIENT_ID="your_client_id"
export GOOGLE_CLIENT_SECRET="your_client_secret"

./mvnw spring-boot:run -Dspring-boot.run.profiles=h2
```

Browse your data anytime at **http://localhost:8080/h2-console**
(JDBC URL: `jdbc:h2:file:./data/gameon;MODE=PostgreSQL`).

To reset all data, stop the app and delete `backend/data/`.

### Option B — PostgreSQL installed natively (no Docker)

1. Download from [postgresql.org/download](https://www.postgresql.org/download/) and install
2. Set a password for the `postgres` user during setup
3. Create the database:
   ```bash
   psql -U postgres
   CREATE DATABASE gameon;
   \q
   ```
4. Run without the `h2` profile — this uses the Postgres settings in `application.yml`:
   ```bash
   export DB_PASSWORD="whatever_you_set"
   export JWT_SECRET="dev_secret_change_this_later_32_chars_min"
   export GOOGLE_CLIENT_ID="your_client_id"
   export GOOGLE_CLIENT_SECRET="your_client_secret"
   ./mvnw spring-boot:run
   ```

### Option C — Docker (if you already use it)

```bash
docker run -d --name gameon-pg \
  -e POSTGRES_DB=gameon \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 postgres:16

export DB_PASSWORD="password"
# ...same JWT_SECRET / GOOGLE_* vars as above
./mvnw spring-boot:run
```

---

Whichever option you pick, the API starts on **http://localhost:8080**
and Flyway applies the schema automatically on first run. Switching
between H2 and Postgres later is just a flag — no code changes needed.

---

## 3. Flutter app setup

```bash
cd app

# Generate the platform runner projects (one-time)
flutter create --platforms=windows,macos,linux .

# Install dependencies
flutter pub get

# Run on your current desktop platform
flutter run -d windows   # or macos / linux
```

By default the app points at `http://localhost:8080`. To point at a
different backend:

```bash
flutter run -d windows --dart-define=API_BASE_URL=https://api.gameon.app
```

---

## How auth works (desktop loopback flow)

```
User clicks "Sign in with Google"
  → Flutter: HttpServer.bind(loopback, port: 0)   [random free port]
  → GET /api/auth/google/url?redirect_port=<port>
  → Backend builds consent URL with redirect_uri = http://127.0.0.1:<port>
  → Flutter opens that URL in the system browser
  → User logs in and consents
  → Google redirects to http://127.0.0.1:<port>?code=...
  → Flutter's loopback server catches the code, closes itself
  → POST /api/auth/google/exchange { code, redirectPort }
  → Backend exchanges code with Google → fetches profile → upserts User
  → Backend issues its own JWT (access + refresh) + returns Google tokens
  → Flutter stores everything in flutter_secure_storage (OS keychain)
  → App shows the Dashboard
```

---

## How backup/restore works

```
Save file changes on disk
  → FileWatcherService (package:watcher) detects change, debounces 3s
  → BackupProvider.backupNow():
      1. Read file bytes
      2. Compress (zstd — Phase 2 integration point)
      3. Encrypt (AES-256-GCM, key derived via PBKDF2 on-device)
      4. DriveService.uploadFile() → user's own Google Drive
      5. POST /api/backups → backend records metadata only
  → UI updates: "Backed up just now ✓"

Restore:
  → GET /api/backups/:id → Drive file ID
  → DriveService.downloadFile()
  → Decrypt → decompress
  → Write to the original save path
```

**Security note:** the Spring Boot backend never sees save-file
contents — only metadata (Drive file ID, checksum, size). All
encryption happens on-device in the Flutter app before any upload.

---

## API Reference

```
Auth
  GET  /api/auth/google/url?redirect_port=      Get Google consent URL
  POST /api/auth/google/exchange                 Exchange code for JWT + tokens
  POST /api/auth/refresh                          Refresh access token

Games                                             (all require Bearer JWT)
  GET    /api/games                               List user's games
  POST   /api/games                                Register a game
  GET    /api/games/:id                            Single game
  PUT    /api/games/:id                            Update name/paths
  DELETE /api/games/:id                            Unregister

Backups                                           (all require Bearer JWT)
  GET    /api/backups?game_id=&limit=              History for a game
  POST   /api/backups                              Record a completed upload
  GET    /api/backups/:id                          Single backup
  DELETE /api/backups/:id                          Delete record
  POST   /api/backups/:id/label                    Set a label

Users                                             (all require Bearer JWT)
  GET    /api/users/me                             Profile
```

---

## Build for release

### Flutter (Windows example)
```bash
cd app
flutter build windows --release
# Output: build/windows/x64/runner/Release/gameon.exe
```

### Backend (executable JAR)
```bash
cd backend
./mvnw clean package
java -jar target/gameon-api-0.1.0.jar
```

---

## Roadmap

| Phase | Focus | Status |
|---|---|---|
| 0 | Monorepo scaffold, auth flow, JPA entities, REST API | ✅ Done |
| 1 | Full UI (Home, Library, Backups, Settings) | ✅ Done |
| 2 | Real zstd compression, Steam VDF parsing, system tray | 🔜 Next |
| 3 | Installer (MSIX/DMG/AppImage), auto-updater, Stripe billing | Planned |
