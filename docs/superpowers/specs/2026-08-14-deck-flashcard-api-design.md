# Connect Decks & Flashcards to the API — Design

## Context

Auth (`2026-08-13-auth-api-foundation-design.md`) and Profile (`2026-08-13-profile-api-design.md`)
connected account and profile data to the real VocabGrid backend. Decks and flashcards — the app's
actual study content — are still entirely local: generated on first login from a fixed vocabulary
table based on the learner's language pair (`StarterContent.buildFor`), and mutated in-memory by a
monolithic `MockData` static class that also holds unrelated reference tables (languages, category
icons). Nothing is scoped to an account; a fresh device or a cleared local cache loses everything.

An audit of the backend (every controller checked against what the app actually consumes) found
`DeckController`, `FlashcardController`, and `ProgressController` fully implemented, tested against
no stub/TODO markers, and — unlike some other unintegrated controllers (`QuizController`,
`LessonController`) — a close conceptual match to what the app's local `Deck`/`FlashCard`/
`MemoryStrength` model already does. This spec covers wiring all of it up: deck/flashcard CRUD and
the spaced-repetition study/rating flow.

## Scope

**In scope:** creating, editing, and deleting decks and flashcards through the API; fetching due
reviews and submitting study ratings through the API, adopting the server's real spaced-repetition
scheduler; first-login starter-content creation as real, persisted decks instead of local-only
ones; offline support via a local cache + queued writes.

**Out of scope, deliberately:**
- **Quiz / Lesson integration.** The backend's `QuizController` is lesson-based, curriculum-authored
  content (fixed questions per lesson, tracked sessions) — a fundamentally different feature from
  the app's current "auto-generate questions from a deck's own cards" quiz screen. `LessonController`
  has no corresponding concept in the app's UI at all. Both need their own design work, not a
  same-shape swap like this one.
- **Deck cover images.** The backend's `Deck` has a `CoverImageUrl`; the local model has a cosmetic
  `emoji`. Wiring a real image would mean also integrating `MediaController` (file upload), which
  has no local UI to attach it to yet. `emoji` stays a local-only, purely cosmetic default; the
  server's `CoverImageUrl` is read but not surfaced or editable in this slice.
- **`GET /api/Progress/streak`.** Materially redundant with `currentStreak`/`longestStreak`, already
  returned by `GET /api/User/profile` since the Profile slice.

## Decisions

**Everything moves to the API — CRUD and studying alike.** Not a partial slice (e.g. "studying
only"). Deck/card editing and the rating flow are tightly coupled (a deck's due count depends on its
cards' review state), and splitting them would mean maintaining two sources of truth mid-migration.

**Starter content becomes real, server-created content.** On first login, if `GET /api/Deck` returns
empty, the app builds the same starter decks it does today (`StarterContent.buildFor`, unchanged)
and creates them for real via `DeckApi.createDeck`/`createFlashcard` — so a new learner's first
decks are persisted, editable, and present on any device from day one, not a local-only fixture that
resets.

**The app adopts the server's real spaced-repetition scheduler.** Today `MemoryStrength` (`mastered`
/ `learning` / `reviewDue`) is a value stored directly on each card and set by hand after a rating.
Going forward it becomes a **derived display value**, computed from what `POST
/api/Progress/reviews/{wordId}` actually returns (`masteryLevel` 0–5, `nextReviewDate`):
`reviewDue` if never reviewed or past due, `mastered` at `masteryLevel >= 4`, otherwise `learning`.
The real scheduling (interval days, ease factor) lives entirely server-side; the app never computes
it. The local `SrsRating` enum (`again`/`hard`/`medium`/`easy`) is already an exact match for the
four rating strings `SubmitReviewDto.Rating` accepts — no mapping needed.

**Offline support: cache-and-refresh reads, queued writes — not full conflict resolution.** Reads
show the local cache immediately and refresh in the background; a failed background refresh just
keeps showing the cache, no error (offline reading is an expected, supported state here — unlike
Profile/Auth, where removing the demo-data fallback was the point). Writes go straight to the API
when online; when offline, they apply to the local cache immediately (so the UI reflects the change
right away) and queue for a later flush. Because writes are *queued*, not concurrently *merged*
across devices, there is no conflict-resolution problem to solve — simpler than full offline-first
sync, while still letting a learner study and edit on a plane.

**IDs stay `String` locally, holding the stringified server id once synced.** The backend uses
integer ids (`Deck.Id`, `Vocabulary.WordID`); the local model already uses `String` throughout the
UI (widget keys, comparisons). Rather than a type refactor across every screen, a synced deck/card's
`id` is the server's id as a string (e.g. `"42"`). A deck or card created while offline gets a
temporary local id (`"pending_<uuid>"`) until its create-operation flushes, at which point every
reference to that temporary id — including any already-queued card-creation for that deck — is
rewritten to the real server id before continuing to flush. Standard "outbox" pattern for offline
writes with dependencies between them.

## Known limitations (accepted, not fixed here)

- A validation failure on a *queued* write (e.g. a 400 from a genuinely invalid edit, discovered
  only once back online) is not retried forever — it's dropped from the queue and surfaced as a
  dismissible notice. A *network* failure keeps the operation queued for retry. This distinction
  matters: retrying a permanently-invalid operation forever is a real bug class (the same shape as
  the infinite-refresh-loop bug fixed in the Auth slice), not a resilience feature.
- `Deck.CoverImageUrl` is read from the API (so a value set by some future admin/media tool isn't
  silently lost) but nothing in this slice writes or displays it — see Scope.

## Verified API contract

Read directly from `DeckController.cs`, `FlashcardController.cs`, and `ProgressController.cs`.

**`GET /api/Deck`** → 200, array of:
```json
{ "id": 1, "title": "...", "description": "...", "coverImageUrl": null,
  "createdAt": "...", "updatedAt": null,
  "cardCount": 12, "dueCount": 3, "masteryPercentage": 41.7, "reviewsCount": 8 }
```
Stats are computed server-side per request from the card list and the user's `UserWordProgress`
records — never trust a locally-cached count once cards change.

**`GET /api/Deck/{id}`** → 200, same shape plus `cards: [...]` (see Flashcard shape below).
404 if the deck doesn't exist or isn't owned by the caller.

**`POST /api/Deck`** — body `{ "title": "...", "description": "...", "coverImageUrl": null }`
(`title` required) → 201, the created deck (zeroed stats).

**`PUT /api/Deck/{id}`** — same body shape → 200, updated deck. 404 if not owned.

**`DELETE /api/Deck/{id}`** → 204. Cascades: deletes every flashcard in the deck too.

**`GET /api/Flashcard?deckId={id}`** → 200, array of:
```json
{ "wordId": 1, "deckId": 1, "term": "...", "translation": "...",
  "exampleSentence": null, "imageUrl": null, "audioUrl": null,
  "createdAt": "...", "updatedAt": null }
```

**`POST /api/Flashcard`** — body `{ "deckId": 1, "term": "...", "translation": "...",
"exampleSentence": null, "imageUrl": null, "audioUrl": null }` (`deckId`/`term`/`translation`
required) → 201. 404 if `deckId` isn't owned by the caller.

**`PUT /api/Flashcard/{id}`** / **`DELETE /api/Flashcard/{id}`** — same ownership-checked pattern as
decks. Deleting or updating touches the parent deck's `updatedAt`.

**`GET /api/Progress/reviews/due?deckId={id}&take={n}`** (`deckId` optional — omitted means every
owned deck plus shared curriculum content; `take` 1–100, default 50) → 200, array of:
```json
{ "wordId": 1, "deckId": 1, "term": "...", "translation": "...",
  "exampleSentence": null, "imageUrl": null, "audioUrl": null,
  "masteryLevel": 2, "reviewCount": 4, "intervalDays": 3, "easeFactor": 2.5,
  "lastRating": "Medium", "nextReviewDate": "..." }
```

**`POST /api/Progress/reviews/{wordId}`** — body `{ "rating": "Again"|"Hard"|"Medium"|"Easy",
"durationSeconds": 0 }` → 200:
```json
{ "wordId": 1, "rating": "Medium", "masteryLevel": 2, "reviewCount": 5,
  "intervalDays": 3, "easeFactor": 2.5, "nextReviewDate": "...",
  "newlyUnlockedAchievements": [] }
```
`newlyUnlockedAchievements` is ignored by this slice (Achievements integration is separate, unscoped
work) but the field exists and is harmless to receive.

## Architecture

New `lib/data/api/deck_api.dart`, following the established interface-plus-implementations pattern:

```dart
abstract class DeckApi {
  Future<List<DeckData>> getDecks();
  Future<DeckDetail?> getDeck(String id);
  Future<DeckResult> createDeck({required String title, String? description});
  Future<DeckResult> updateDeck(String id, {required String title, String? description});
  Future<bool> deleteDeck(String id);

  Future<List<FlashcardData>> getFlashcards(String deckId);
  Future<FlashcardResult> createFlashcard({required String deckId, required String term, required String translation, String? exampleSentence});
  Future<FlashcardResult> updateFlashcard(String id, {required String term, required String translation, String? exampleSentence});
  Future<bool> deleteFlashcard(String id);

  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50});
  Future<ReviewResult> submitReview(String wordId, {required SrsRating rating, required int durationSeconds});
}
```

- `DeckData` / `DeckDetail` / `FlashcardData` / `ReviewCardData` — field-for-field mirrors of the
  verified response shapes above, `id`s as `String` per the ID decision.
- `DeckResult` / `FlashcardResult` / `ReviewResult` — same success/network-error/validation-error
  outcome shape as `ProfileResult`/`AuthResult`.
- `VocabGridDeckApi implements DeckApi` — real implementation via `ApiClient.instance.dio`.
- `FakeDeckApi implements DeckApi` — in-memory, for tests, seeded with a small fixed deck/card set.

**`DeckStore`** (new, mirrors `AuthStore`'s role) — owns what `MockData` owns today for decks/cards:
the in-memory `decks`/`cards` lists and the `revision` `ValueNotifier<int>` every screen already
listens to via `ValueListenableBuilder`. Adds:
- The local cache (reusing the existing `LibraryStorage`/`SqliteLibraryStorage` persistence layer —
  no new storage mechanism).
- The pending-writes queue: an ordered, locally-persisted list of not-yet-synced mutations (create/
  update/delete deck, create/update/delete card, submit review), flushed FIFO once connectivity is
  confirmed.

`MockData` keeps only what's genuinely still local-only after this slice: starter-content generation
(`StarterContent`) and the language/theme reference tables. Every screen's import moves from
`MockData.decks`/`MockData.cards` to `DeckStore.decks`/`DeckStore.cards`; the
`ValueListenableBuilder<int>` wiring itself is unchanged.

## Data flow

1. **Reads** (deck dashboard, deck detail, card library): `DeckStore` returns whatever's in the
   local cache immediately, then kicks off `DeckApi.getDecks()`/`getFlashcards()` in the background.
   On success, replaces the cache and bumps `revision`. On failure, leaves the cache as-is.
2. **Writes** (create/rename/delete deck, add/edit/delete card): `DeckStore` calls the matching
   `DeckApi` method. Online success updates the cache directly. Any network failure applies the
   change to the cache optimistically and appends it to the pending-writes queue.
3. **Studying** (`study_session_screen.dart`'s `_rate`): calls `DeckApi.submitReview(wordId, rating,
   durationSeconds)` instead of `MockData.updateCard(card.copyWith(strength: ...))`. On success,
   derives the new `MemoryStrength` from the response's `masteryLevel`/`nextReviewDate` and updates
   the cached card. Offline: same optimistic-apply-plus-queue path as any other write, using a
   locally-computed best-effort `MemoryStrength` guess (the same derivation rule, applied to
   whatever the last-known `masteryLevel` was, nudged by the rating) until the real sync corrects it.
4. **First login, zero decks**: after `MainShell`'s existing post-login profile fetch succeeds, check
   `DeckApi.getDecks()`. If empty, build starter content (`StarterContent.buildFor`, unchanged) and
   create it via `DeckApi.createDeck`/`createFlashcard` — going through the same online/offline path
   as any other write.
5. **Queue flush**: triggered on app foreground and after any successful API call (a cheap signal
   that connectivity is back). Processes entries FIFO; a successful create rewrites any later queued
   entry that referenced its temporary id; a network failure stops the flush and retries next trigger;
   a validation failure drops that entry and raises a dismissible notice, then continues flushing the
   rest.

## Error handling

- Background refresh failure (read path): silent, cache stands. This is a deliberate difference from
  Profile/Auth's "no fallback" rule — that rule exists to stop a *wrong* profile from displaying;
  showing a learner's own last-known deck list while offline is correct, not a masked bug.
- Write failure, network: optimistic local apply + queue, no error shown (expected offline state).
- Write failure, validation (surfaces only once a queued write actually flushes): dismissible notice
  naming what didn't save; entry removed from the queue, not retried.
- Deck/card ownership errors (404 from a stale id, e.g. deleted on another device): treated as a
  successful local delete — remove it from the cache rather than surfacing an error for something
  the user no longer needs to see anyway.

## Testing

`FakeDeckApi` for widget/flow tests — no real network, matching `FakeAuthApi`/`FakeUserApi`. New
coverage: cache-then-refresh (cached decks render instantly, then update after a simulated
background fetch), offline queueing (a network-error mode on the fake confirms a mutation queues,
applies optimistically, and flushes once the fake goes back online), ID remapping (a card created
against a not-yet-synced deck ends up pointing at the deck's real id after flush), and starter-content
creation firing exactly once for a zero-deck account. `VocabGridDeckApi` verified manually against
the live local server, same approach as Auth/Profile: create a deck and cards, rate them through
several intervals, confirm the server's returned schedule against `StudyEngine`'s known formulas,
kill the server mid-session to confirm the offline queue path, restart and confirm it flushes.

Existing SRS tests (`srs_persistence_test.dart`, `swipe_to_rate_test.dart`, `study_session_test.dart`)
need updating for server-derived `MemoryStrength` — flagged here as known migration work, to be
scoped precisely in the implementation plan rather than line-by-line in this design.

## Out of scope (future work)

Quiz/Lesson integration, deck cover images (needs Media upload), Achievements (the review-submission
response already carries `newlyUnlockedAchievements` — ignored here, picked up whenever Achievements
gets its own slice), Statistics dashboard (`overview`/`heatmap` — separate slice, same pattern as
this document).
