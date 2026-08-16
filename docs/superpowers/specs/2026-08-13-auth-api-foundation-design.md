# Auth + API Foundation — Design

## Context

LanGigaCard is currently fully local: decks/cards live in SQLite, accounts live in a
SharedPreferences-backed SHA256 hash store (`AuthStore`), and everything else (stats,
achievements, quiz) is computed client-side from local data.

A separate team built a real backend, **VocabGrid** (ASP.NET Core / .NET 8, JWT auth,
SQL Server), covering Auth, Categories, User profile/settings, lesson Progress, Quiz
sessions, Statistics, and Achievements. It does **not** expose deck/flashcard CRUD —
that stays local (see "Decision" below).

This spec covers the **first slice**: Auth (register/login/token handling) plus the
shared HTTP client infrastructure every later feature (Categories, Profile, Quiz, ...)
will reuse. Those later features are out of scope here and will get their own specs.

## Decision: what stays local vs. goes to the API

- **Stays local, untouched**: deck and flashcard creation/editing (`LibraryStorage`,
  `SqliteLibraryStorage`) — VocabGrid has a `Deck` entity in its schema but no
  controller exposing create/update/delete, so there's nothing to connect to yet.
- **Moves to the API (this spec)**: account registration, login, session token
  handling.
- `AuthStore.rememberEmail` / `loadRememberedEmail` (the "remember me" email prefill)
  are untouched — purely local UI convenience, unrelated to authentication itself.

## Verified API contract

Confirmed live against a running local instance (`dotnet run`, LocalDB), not just
read from source:

**`POST /api/Auth/register`**
Request: `{ firstName, lastName, email, password, confirmPassword }`
Response `200`: `{ message, token, refreshToken, refreshTokenExpiryTime, user: { id, firstName, lastName, username, email } }`
Response `400`: duplicate email → plain string body `"User with this email already exists."`; validation errors → `{ errors: { Field: [messages] } }`

**`POST /api/Auth/login`**
Request: `{ email, password }`
Response `200`: same shape as register's response (minus the `message` differing: `"Login successful."`)
Response `401`: wrong credentials → plain string body `"Invalid credentials."`

**`POST /api/Auth/refresh`**
Request: `{ refreshToken }`
Response `200`: `{ token, refreshToken, refreshTokenExpiryTime }`
Response `401`: expired/invalid refresh token

All JSON is **camelCase** on the wire (verified — ASP.NET Core's default policy
converts the C# PascalCase properties), which conveniently matches Dart naming, so
no key-mapping layer is needed.

Token lifetime: 1 hour. Refresh token lifetime: 7 days.

**Base URLs** (from the backend README, plus Windows desktop which their notes didn't
cover but follows the same logic — it runs natively on the same machine as the API
during development, so it's the same as the browser case):
- Web (Chrome/Edge): `http://localhost:5068`
- Android emulator: `http://10.0.2.2:5068` (the emulator's alias for the host machine)
- Windows desktop: `http://localhost:5068`

## Architecture

New `lib/data/api/` folder, following the existing `LibraryStorage`
interface-plus-implementation(s) pattern already used in this codebase:

- **`ApiClient`** — one shared `dio.Dio` instance, created once. `baseUrl` resolved
  per-platform at construction (`kIsWeb`, `Platform.isAndroid`, else desktop). A
  `QueuedInterceptor`:
  - attaches `Authorization: Bearer <token>` to every outgoing request once a token
    is stored (skips silently if none — e.g. before login).
  - on a `401` response from an *authenticated* request (not login/register
    themselves), attempts one silent `POST /api/Auth/refresh` using the stored
    refresh token, retries the original request once with the new token. If the
    refresh also fails, clears stored tokens and rethrows so the caller can force a
    sign-out.
- **`AuthApi`** (abstract interface) — `register(...)`, `login(...)`, `logout()`.
  - **`VocabGridAuthApi`** — real implementation, calls `ApiClient`, persists
    `token` / `refreshToken` / `refreshTokenExpiryTime` to `SharedPreferences` under
    new keys (`api_token_v1`, `api_refresh_token_v1`, `api_refresh_expiry_v1`) —
    deliberately separate from the old `AuthStore` keys rather than reusing them.
  - **`FakeAuthApi`** (test-only) — in-memory, mirrors `InMemoryLibraryStorage`.
- `AuthStore.register` / `AuthStore.login` (the local SHA256 path) are **deleted**,
  not kept as an offline fallback — this app now requires network connectivity to
  register or log in, matching Option B.
- No migration for existing local accounts (the `registered_accounts_v2`
  SharedPreferences key) — the app hasn't shipped, so any locally-registered test
  accounts are simply orphaned/unused going forward. Not worth a migration path.

## Data flow

1. `RegisterScreen._createAccount` calls `AuthApi.register(...)` instead of
   `AuthStore.register`. On success, tokens are already persisted by the time the
   call returns; screen proceeds to `EmailVerificationScreen` exactly as today.
2. `LoginScreen._login` calls `AuthApi.login(...)` instead of `AuthStore.login`. On
   success, proceeds to `MainShell` exactly as today.
3. Every future authenticated API call (Categories, Profile, Quiz, ...) goes through
   the same `ApiClient` instance and automatically carries the Bearer header — no
   per-feature auth plumbing needed.

## Error handling

| Situation | Behavior |
|---|---|
| Server unreachable (`DioException` connection error/timeout) | "Can't reach the server. Check your connection and try again." |
| Register: duplicate email / validation errors | Surface the server's actual message(s) in the existing error-banner UI |
| Login: wrong credentials (`401`) | Existing "Incorrect email or password..." message, now sourced from the API |
| Token expires mid-session, refresh also fails | Interceptor clears tokens; next authenticated call surfaces an error that forces navigation back to `LoginScreen` |

## Testing

- `login_flow_test.dart` / `register_flow_test.dart` get updated to inject
  `FakeAuthApi` instead of relying on the old local-hash `AuthStore` — no real
  server needed to run the suite.
- New unit tests for `ApiClient`'s interceptor (header attachment, refresh-on-401,
  refresh failure clears tokens) using `dio`'s test/mock adapter, no real network
  calls.
- Manual smoke test against the real local VocabGrid instance before calling this
  done: register a new account, log in with it, confirm token persists across an
  app restart (or at least across a hot restart within one run).

## Out of scope (future specs)

Categories, User profile/settings, lesson Progress + reviews, Quiz sessions,
Statistics, Achievements — each gets connected one at a time on top of this
foundation, each as its own spec.
