# Connect Profile to the API — Design

## Context

The Auth foundation (spec: `2026-08-13-auth-api-foundation-design.md`) connected register/login to
the real VocabGrid backend, but Profile data — name, languages, categories, learning purposes,
daily goal, streak/level/XP — still comes entirely from local, un-account-scoped storage
(`OnboardingStore`). This causes a real, reproduced bug: logging into a real, valid account on a
device/session with no locally-saved onboarding data silently shows the hardcoded demo profile
("Sarah Johnson", Level 12, 14-day streak) with no indication it's fake and no way to fix it from
inside the app — because the local onboarding data was never tied to *which* account is signed in
in the first place.

Since the Auth work landed, the API team shipped a substantial update (confirmed live against the
running server) that makes fixing this properly possible: `GET/PUT /api/User/profile`,
`GET/PUT /api/User/categories`, `GET/PUT /api/User/learning-purposes`, plus global reference lists
`GET /api/Categories` and `GET /api/LearningPurposes` — the latter two now include `iconName` and
`colorHex` fields that weren't there when Auth was built.

This spec covers connecting Profile (not Settings — see Scope) to the API as the second slice
built on the Auth foundation.

## Decision: onboarding data goes to the API, not local storage

Per Auth's own precedent (no offline fallback — the app already requires network to register or
log in), onboarding answers now save directly to the API. `OnboardingStore.saveProfile` /
`loadProfile` are **deleted**, the same treatment the old local SHA256 auth got.
`OnboardingStore.saveAppLanguage` / `loadAppLanguage` (interface language selection — unrelated to
account data) are untouched.

## Scope

**In scope:** Profile (name, avatar, native/target language + codes, target proficiency level,
daily goal, streak/level/XP — the last three are read-only, set server-side), Categories
(global list + per-user selection), Learning Purposes (global list + per-user selection).

**Out of scope, deliberately:** Settings (`GET/PUT /api/User/settings` — dark mode, sound, text
size, difficulty, theme color). This is a separate, smaller local mechanism (`AppController`,
which today isn't persisted at all — resets every app launch) — a real but distinct problem,
planned as its own quick follow-up slice after this one.

## Known limitation (accepted, not fixed here)

Onboarding's **age range** step (`AgeRangeStep`) collects an answer that has no home on the
server — `UpdateUserProfileDto` has no age field at all. It stays a wizard-UI-only step with no
persistence anywhere, same as effectively happens today. Worth reporting to the API team
separately if age range turns out to matter for anything; not blocking this slice.

## Verified API contract

Confirmed by reading the live `UserController.cs`/`CategoriesController.cs`/
`LearningPurposesController.cs` source and a live request against the running server — not
guessed.

**`GET /api/User/profile`** → 200:
```json
{
  "firstName": "...", "lastName": "...", "email": "...", "avatarUrl": null,
  "nativeLanguage": "...", "targetLanguage": "...",
  "nativeLanguageCode": "...", "targetLanguageCode": "...",
  "targetProficiencyLevel": "...", "dailyGoalMinutes": 10,
  "currentStreak": 0, "longestStreak": 0, "level": 1, "totalXp": 0, "isPremium": false
}
```

**`PUT /api/User/profile`** — request body (`UpdateUserProfileDto`):
```json
{
  "firstName": "...", "lastName": "...", "avatarUrl": null,
  "nativeLanguage": "...", "targetLanguage": "...",
  "nativeLanguageCode": "...", "targetLanguageCode": "...",
  "targetProficiencyLevel": "...", "dailyGoalMinutes": 10
}
```
`firstName`/`lastName` are required (400 if blank). Language/level fields are nullable in the DTO
— sending null leaves the existing server value unchanged (`UpdateProfile` only overwrites a field
when the incoming value is non-blank). `nativeLanguageCode`/`targetLanguageCode` are lowercased
server-side before storage. Response: `{ "message": "...", "profile": <same shape as GET> }`.

**`GET /api/Categories`** (no per-user auth needed, but the interceptor attaches the token
harmlessly anyway) → 200, array of:
```json
{ "id": 1, "name": "Food", "description": "Food & Dining Vocabulary", "iconName": "restaurant", "colorHex": "#F97316" }
```
Verified live — all 15 seeded categories confirmed, e.g. `id:9 Sports sports_soccer #22C55E`,
`id:10 Health favorite #EF4444`. `iconName` values map directly to this app's existing
`Icons.xxx_rounded` constants (minus the `_rounded` suffix) for every seeded category, and
`colorHex` values are near-identical to what's already hardcoded in `MockData.categories` today.

**`GET /api/User/categories`** → 200, array of the same `CategoryDto` shape, but only the ones the
signed-in user selected.
**`PUT /api/User/categories`** — body `{ "categoryIds": [1, 3, 7] }` → 200, returns the updated
selection (same `CategoryDto[]` shape). 400 if any id doesn't exist.

**`GET /api/LearningPurposes`** → 200, array of `{ "id": 1, "name": "...", "description": "..." }`
(no icon/color — this list doesn't need one, the app doesn't render icons for learning purposes
today).
**`GET /api/User/learning-purposes`** / **`PUT /api/User/learning-purposes`** (body
`{ "purposeIds": [...] }`) — same pattern as Categories.

## Architecture

New `lib/data/api/user_api.dart`, following the established interface-plus-implementations
pattern (`AuthApi`/`VocabGridAuthApi`/`FakeAuthApi`):

```dart
abstract class UserApi {
  Future<ProfileResult> getProfile();
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? avatarUrl,
    String? nativeLanguage,
    String? nativeLanguageCode,
    String? targetLanguage,
    String? targetLanguageCode,
    String? targetProficiencyLevel,
    int? dailyGoalMinutes,
  });
  Future<List<CategoryData>> getCategories();
  Future<List<int>> getMyCategoryIds();
  Future<List<int>> updateMyCategories(List<int> categoryIds);
  Future<List<LearningPurposeData>> getLearningPurposes();
  Future<List<int>> getMyLearningPurposeIds();
  Future<List<int>> updateMyLearningPurposes(List<int> purposeIds);
}
```

- `ProfileResult` — same success/network-error/validation-error shape as `AuthResult` (an
  `outcome` enum + optional `message` + optional payload), carrying a `ProfileData` on success:
  `{firstName, lastName, email, avatarUrl, nativeLanguage, targetLanguage, nativeLanguageCode,
  targetLanguageCode, targetProficiencyLevel, dailyGoalMinutes, currentStreak, longestStreak,
  level, totalXp, isPremium}` — a direct field-for-field mirror of the verified `GET/PUT
  /api/User/profile` response shape above.
- `CategoryData` — `{id, name, description, iconName, colorHex}`.
- `LearningPurposeData` — `{id, name, description}`.
- A static `Map<String, IconData>` (in a new small file, e.g. `lib/theme/category_icons.dart`)
  translates `iconName` → `IconData`, covering the 15 known seeded names, with a fallback generic
  icon (`Icons.label_outline_rounded` or similar) for any name it doesn't recognize — so a future
  server-side category addition degrades gracefully instead of crashing.
- `VocabGridUserApi implements UserApi` — real implementation via `ApiClient.instance.dio`.
- `FakeUserApi implements UserApi` — in-memory, for tests.

## Data flow

1. **Onboarding wizard** (`OnboardingSetupScreen`): the "Topics & Categories" step
   (`TopicsStep`) and "Learning Purpose" step (`LearningPurposeStep`) fetch from
   `UserApi.getCategories()` / `getLearningPurposes()` instead of `MockData.categories` /
   `MockData.learningPurposes`, so selections carry real server IDs, not display strings.
2. **`_finish()`**: instead of `OnboardingStore.saveProfile(data)`, calls
   `UserApi.updateProfile(...)`, then `UserApi.updateMyCategories(selectedCategoryIds)`, then
   `UserApi.updateMyLearningPurposes(selectedPurposeIds)`. Builds the app's `UserProfile` from the
   responses and navigates to `MainShell(profile: profile)` — same as today, just sourced from the
   API instead of local storage.
3. **Login** (`MainShell`, no profile passed): instead of `OnboardingStore.loadProfile()`, calls
   `UserApi.getProfile()` + `getMyCategoryIds()`/`getMyLearningPurposeIds()` (resolved against
   `getCategories()`/`getLearningPurposes()` to get display names) to build the real profile. This
   is the actual fix for the Sarah Johnson bug: the profile now always reflects the account that
   was actually authenticated, not a local slot any login happens to read.
4. **Editing categories from Profile screen** ("Study Categories" > Edit): calls
   `updateMyCategories` instead of mutating local state.

## Error handling

- Onboarding `_finish()` network/validation failure: same error-banner pattern as
  Register/Login — show the message, let the user retry, don't silently proceed to `MainShell`
  with incomplete data.
- **Login's profile fetch failing is more serious than a login failure**: if `getProfile()` fails
  right after a successful login, the correct behavior is an error state with a retry action — not
  silently falling back to the demo profile, which is the exact bug this slice exists to fix. No
  demo-profile fallback survives this slice for the post-login path.

## Testing

`FakeUserApi` for widget/flow tests — no real network, consistent with `FakeAuthApi`.
`VocabGridUserApi` verified manually against the live local server (same approach as
`VocabGridAuthApi` in the Auth slice): fetch categories/learning-purposes, complete onboarding
with a fresh test account, confirm `GET /api/User/profile` reflects what was sent, log back in and
confirm the real profile loads instead of the demo one.

## Out of scope (future work)

Settings (dark mode, sound, text size, difficulty, theme color) — separate slice, same pattern.
Age range — no server field exists yet, not actionable here.
