# Modeling the Learner

Research memo — spaced-repetition review scheduling and onboarding personalization for LanGigaCard/VocabGrid.

**Published artifact (formatted):** https://claude.ai/code/artifact/60133e32-2fd3-46ff-8ffc-cd510b9dc4d1

---

## Part I — The review algorithm

### 1. Where this lives today

Every review flows through `StudyEngine.CalculateReviewSchedule` in the VocabGrid backend, called from `ProgressController.SubmitReview`. State lives on `UserWordProgress` (one row per learner per word): `EaseFactor` (1.3–3.0, starts at 2.5), `IntervalDays`, `MasteryLevel` (0–5), `ReviewCount`, `LastRating`, `NextReviewDate`.

Current update rule:

```
Again  → interval = 0,                    ease -= 0.20,  next review in 10 min,  mastery -1
Hard   → interval = ceil(interval*1.2),   ease -= 0.15,  next = +interval days,  mastery +0
Medium → interval = round(interval*ease), ease unchanged, next = +interval days, mastery +1
Easy   → interval = round(interval*(ease+0.15)) [or 4 if first review],
                                           ease += 0.15,  next = +interval days,  mastery +2
ease always clamped to [1.3, 3.0]
```

This is a simplified **SM-2** (SuperMemo, 1987) — the algorithm Anki ran on for 30+ years. Same ease-factor concept and interval-growth shape, condensed from SM-2's original 0–5 quality scale to four buttons, with hand-picked deltas standing in for SM-2's formula.

### 2. Four families of review algorithm

| Algorithm | Core model | Calibration data needed | Predicts recall probability? |
|---|---|---|---|
| Leitner (1972) | Boxes; correct → next box, wrong → box 1 | None | No |
| SM-2 (1987) — *current* | Single ease factor per card | None (hand-tuned constants) | No |
| Half-Life Regression (2016) | Log-linear model over lexeme + history features | Large labeled dataset + ML pipeline | Yes |
| FSRS (2022–present) | Difficulty / Stability / Retrievability (DSR) | None to start — ships with trained defaults | Yes |

**Leitner System** — Sebastian Leitner's 1972 box method. No notion of *how* hard, no per-card growth curve. A step back from what LanGigaCard already has. Worth knowing as the family's origin, not worth adopting.

**SM-2** — `EF' = EF + (0.1 − (5−q)·(0.08 + (5−q)·0.02))`, `I(1)=1, I(2)=6, I(n)=I(n−1)·EF` for n≥3. Known weaknesses: a single ease factor conflates item difficulty with personal recall ability; no way to ask "what's the probability I remember this today," only "is it due"; can enter "ease hell" — an ease factor ratcheted down near its floor that never recovers.

**Half-Life Regression** — Duolingo's 2016 model (*A Trainable Spaced Repetition Model for Language Learning*, Settles & Meeder, ACL 2016). Fits a log-linear regression estimating a word's memory half-life from features. Reported +12% daily engagement, 45%+ error reduction vs. baselines. Needs a real ML pipeline, feature engineering, and a large historical dataset — a fit for Duolingo's scale, not where LanGigaCard is today.

**FSRS** — models memory with three numbers per card: Difficulty (D, 1–10), Stability (S, days until recall probability decays to 90%), Retrievability (R, probability of recall right now).

```
R(t, S) = (1 + F·t/S)^C          // F = 19/81, C = −0.5 (FSRS-4.5)
I(r, S) = (S/F) · (r^(1/C) − 1)  // interval for a target recall probability r
```

~19–21 trained weights, mean-reversion built into the difficulty update (avoids SM-2's ease-hell problem). Ratings are literally named **Again, Hard, Good, Easy** — matching LanGigaCard's existing buttons exactly ("Medium" → "Good"). Ships with a **default parameter set** trained on millions of public reviews that works with zero per-user data; per-user optimization isn't recommended until ~400–1,000 reviews are logged. Anki's own default scheduler since 2023; the most actively benchmarked open scheduler in current use.

### 3. Recommendation: adopt FSRS with the published default weights

Not Half-Life Regression, not a custom model. Reasons:
1. **Zero learner-facing change** — the rating vocabulary already matches exactly.
2. **No cold-start problem** — default weights work from the first review, unlike HLR.
3. **A genuinely new capability** — retrievability is an actual probability, usable beyond scheduling (e.g. a "cards at risk" view, or weighting quiz-question selection).
4. **Lowest risk, most mature option** available today.

### 4. Implementation plan

1. **Schema** — add `Stability`, `Difficulty` (double) to `UserWordProgress`. Keep `NextReviewDate`/`LastRating`. Retire `EaseFactor`/`IntervalDays`, or keep `IntervalDays` as a cached display value to avoid touching every consumer.
2. **Backend service** — new `FsrsEngine`, parallel to `StudyEngine`, implementing the D/S/R formulas. Hardcode the published default weight array.
3. **Wire `DifficultyMode` to a real parameter** — `AppController.DifficultyMode` (`easy`/`adaptive`/`hard`) exists today and does nothing observable. Map it to FSRS's target-retention parameter: `easy→0.85, adaptive→0.90, hard→0.95`. Turns an inert setting into one that visibly changes review frequency.
4. **Keep the response contract stable** — `SubmitReview` continues to expose a derived `MasteryLevel` computed from D/S/R, so `deriveMemoryStrength` on the Flutter side needs no change.
5. **Rollout** — direct cutover with a one-time conversion seeding initial Stability/Difficulty from existing EaseFactor/MasteryLevel (lower effort, reasonable given current low user count), or a shadow-mode period logging predicted-vs-actual recall before cutover (more cautious).
6. **Per-user optimization** — later: once learners have a few hundred reviews each, a periodic job can refit personalized weights from their `StudyActivity` history. Not needed for launch.

---

## Part II — The onboarding algorithm

### 1. What onboarding collects, and what happens to it

Onboarding gathers: native/target language (name + code), self-reported `TargetProficiencyLevel`, learning purposes, topic categories, age range, daily goal. All persisted (`UserCategory`/`UserLearningPurpose` join tables, profile fields on `User`).

**The actual gap:** a search across the entire backend finds `UserCategory`/`UserLearningPurpose` referenced in exactly one place — `UserController`'s own get/set endpoints. No Lesson, Deck, or Vocabulary entity carries a Category or LearningPurpose link at all. `TargetProficiencyLevel` is collected, displayed, never used to pick content. Today, onboarding preferences drive exactly one thing: `StarterContent.buildFor()`'s two fixed sample decks, chosen by language pair alone.

The real problem isn't which sophisticated model to reach for — it's that the data already collected doesn't drive anything yet.

### 2. The cold-start landscape

A brand-new learner is the textbook cold-start problem: no interaction history to learn from.

- **Explicit preference elicitation** — ask directly. This is what onboarding already is (same pattern as Spotify's artist/genre picker). LanGigaCard does the collection half right; the *use* half is missing.
- **Content-based filtering** — score content against declared tags. No other users needed, works from session one. Needs content to be tagged the same way — the schema gap above.
- **Collaborative filtering** — recommend based on similar users' behavior. Explicitly wrong for onboarding: CF degrades worst exactly when there's no interaction history, describing both a new user and, right now, this app's entire user base. Better suited to a later "what to study next" once there's real usage.
- **Adaptive placement testing (IRT/BKT)** — a short computerized adaptive test (commonly 2PL item-response, Fisher-information-driven item selection) estimates ability from a handful of responses. CEFR-anchored adaptive tests are well-studied in language assessment. Bayesian Knowledge Tracing is the related model for tracking mastery over time rather than a one-time placement.

### 3. Recommendation: three phases, cheapest and most certain first

**Phase 1 — tag-overlap content scoring (now, no ML).** Add a `LessonCategory` join table (same shape as existing `UserCategory`). Score:

```
score(lesson, user) =
    weight_category · overlap(lesson.categories, user.categories)
  + weight_purpose  · overlap(lesson.purposes,   user.purposes)
  − weight_level    · |levelToNumber(lesson.Level) − levelToNumber(user.TargetProficiencyLevel)|
```

Use it to order a future Lessons list, and to widen `StarterContent` beyond language pair — a learner who picked "Travel" gets a travel-flavored starter deck. No training data needed.

**Phase 2 — a short placement quiz, replacing the self-reported dropdown (medium effort).** The `QuizApi` session flow built this session (`startSession`→`submitAnswer`) is exactly the transport this needs — a placement quiz is just a specially-flagged `Lesson` taken through the same flow. Start with a fixed 8–12 question quiz spanning A1–C2, scored by a staircase rule ("highest level with ≥70% correct") — already more evidence-based than a dropdown, no statistical model required. Real 2PL IRT with Fisher-information item selection is the natural upgrade once enough completed quizzes exist to calibrate against.

**Phase 3 — collaborative + knowledge-tracing sequencing (later, needs real usage data).** Once there's a meaningful active user base: collaborative filtering for cross-content recommendations, and knowledge tracing aggregating FSRS's per-word Stability/Difficulty (Part I) up to category level for a live per-topic mastery estimate. Deliberately not attempted now — no data to support it yet.

---

## Sources

- [The Algorithm — open-spaced-repetition/awesome-fsrs wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)
- [Implementing FSRS in 100 Lines — Fernando Borretti](https://borretti.me/article/implementing-fsrs-in-100-lines)
- [A technical explanation of FSRS — Expertium's Blog](https://expertium.github.io/Algorithm.html)
- [free-spaced-repetition-scheduler — open-spaced-repetition (GitHub)](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler)
- [FSRS4Anki tutorial — optimizer requirements and defaults](https://github.com/open-spaced-repetition/fsrs4anki/blob/main/docs/tutorial.md)
- [SuperMemo 2: Algorithm — SuperMemo](https://super-memory.com/english/ol/sm2.htm)
- [Leitner system — Wikipedia](https://en.wikipedia.org/wiki/Leitner_system)
- [A Trainable Spaced Repetition Model for Language Learning — Settles & Meeder, ACL 2016](https://research.duolingo.com/papers/settles.acl16.pdf)
- [halflife-regression — Duolingo (GitHub)](https://github.com/duolingo/halflife-regression)
- [The Cold-Start Problem in Recommender Systems — IRJMETS 2024](https://www.irjmets.com/uploadedfiles/paper/issue_5_may_2024/55701/final/fin_irjmets1715656884.pdf)
- [A CEFR-based Computerized Adaptive Testing System — ERIC](https://files.eric.ed.gov/fulltext/EJ989251.pdf)
- [Bayesian Knowledge Tracing — Emergent Mind](https://www.emergentmind.com/topics/bayesian-knowledge-tracing)
