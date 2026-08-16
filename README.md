# LanGigaCards

A Flutter flashcard app for language learning: spaced-repetition study sessions, decks,
quizzes, statistics, and a fully localized interface in 10 languages.

The app is a client for the **VocabGrid API**. It has no offline mode — every screen past
the onboarding slides talks to the backend, so **the API must be running before you start
the app.**

---

## Requirements

* **Flutter SDK** with Dart 3.3 or newer (`flutter --version` to check)
* **The VocabGrid API**, running locally — see
  [LanGigaCards-Backend](https://github.com/suleymandogan-software/LanGigaCards-Backend)
* For Android: Android Studio with an **emulator** (see the note on physical devices below)

No API keys, `google-services.json`, or Firebase setup is needed. Everything the app
depends on comes from pub.dev.

---

## Getting Started

### 1. Start the backend first

Follow the setup steps in the
[backend README](https://github.com/suleymandogan-software/LanGigaCards-Backend). You are
ready when `http://localhost:5068/swagger` opens in a browser.

The API address is resolved in [`lib/data/api/api_client.dart`](lib/data/api/api_client.dart)
and **assumes port 5068** — the default of the backend's `http` launch profile. If you
start the backend with the `https` profile or on another port, change
`resolveApiBaseUrl` to match, or the app will not connect.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run

```bash
flutter run
```

Pick a target when prompted, or pass one: `-d chrome`, `-d windows`, `-d emulator-5554`.

That's the whole setup — the localization sources are generated during the build
(`generate: true` in `pubspec.yaml` with `l10n.yaml`), so there is no code-generation
step to run by hand.

---

## How the app reaches the API

| Where the app runs | Base URL | Works out of the box? |
| --- | --- | --- |
| Android emulator | `http://10.0.2.2:5068` | Yes |
| Chrome / Windows desktop | `http://localhost:5068` | Yes |
| Physical Android device | `http://10.0.2.2:5068` | **No** — see below |

`10.0.2.2` is a special alias the Android **emulator** maps to the host machine.
`localhost` inside the emulator means the emulator itself, which is why the plain address
does not work there.

A physical phone is a different machine on the network, so neither address reaches your
computer. To use one, replace the Android branch of `resolveApiBaseUrl` with your
computer's LAN address (e.g. `http://192.168.1.42:5068`), make sure the backend listens on
that interface rather than loopback only, and allow the port through your firewall.

Cleartext HTTP is enabled in the Android manifest deliberately, for local development
against an API with no TLS certificate. A production build should use HTTPS and drop
`usesCleartextTraffic`.

---

## Using the app

Register a new account from the sign-up screen — the backend creates it and returns a JWT.
Verification codes are part of the flow: if the backend has no SMTP credentials
configured, no email is sent, and you can read the code from the API's console output or
from the `send-verification-code` response in Swagger. Email verification is not a login
gate, so you can also just continue.

After registration, the onboarding wizard asks for your native language, target language,
level, and learning purposes, then creates your first decks with starter content.

---

## Interface language

The app language follows the **native language** in your profile. Tap *Native Language* on
the Profile tab, pick another one, and the entire interface switches immediately — there
is no separate app-language setting to keep in sync.

Ten languages are supported: English, Turkish, Spanish, French, German, Italian,
Portuguese, Japanese, Korean, and Chinese. Translations live in `lib/l10n/app_*.arb`, with
`app_en.arb` as the template.

When you add a string, add the key to **all ten** ARB files. A key missing from one of them
does not break the build — `flutter gen-l10n` only warns and falls back to English at that
spot, which is easy to miss until someone using that language sees it.

---

## Tests

```bash
flutter test
```

Widget tests need the localization delegates, so a test that pumps a screen must build it
with:

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ...,
)
```

Tests use fake API implementations and never make real network calls, so the backend does
not need to be running for `flutter test`.

---

## Troubleshooting

**"Could not reach the server" on the login or register screen** — the backend is not
running, or it is not on port 5068. Open `http://localhost:5068/swagger` to confirm.

**Works in Chrome but not on the Android emulator** — the emulator needs `10.0.2.2`, and
cleartext traffic must be allowed. Both are already configured; if you changed
`resolveApiBaseUrl` to `localhost`, that is the cause.

**A screen shows raw keys instead of text** — the generated localizations are stale. Run
`flutter clean` then `flutter pub get`.

**Registration succeeds but the app shows an empty profile** — the API returned an error
on one of the onboarding calls. Check the backend console for the failing request.
