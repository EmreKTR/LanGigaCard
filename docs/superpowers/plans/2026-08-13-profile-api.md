# Connect Profile to the API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace local, un-account-scoped onboarding/profile storage with the real VocabGrid API, fixing the bug where logging into a real account with no local onboarding data silently shows the hardcoded demo profile.

**Architecture:** A new `lib/data/api/user_api.dart` (interface + types + fake) and `lib/data/api/vocabgrid_user_api.dart` (real implementation) follow the exact pattern established by `AuthApi`/`VocabGridAuthApi`. The onboarding wizard's Topics and Learning Purpose steps switch from local hardcoded lists to the API's reference lists (with real IDs). `OnboardingStore`'s profile-related code is deleted; `MainShell` fetches the real profile from the API after login instead of reading local storage.

**Tech Stack:** Flutter/Dart, `dio` (already added), the existing `ApiClient`/`AuthStore` infrastructure from the Auth slice.

## Global Constraints

- Verified live API contract (from `UserController.cs`/`CategoriesController.cs`/`LearningPurposesController.cs` source and a live request):
  - `GET /api/User/profile` → `{firstName, lastName, email, avatarUrl, nativeLanguage, targetLanguage, nativeLanguageCode, targetLanguageCode, targetProficiencyLevel, dailyGoalMinutes, currentStreak, longestStreak, level, totalXp, isPremium}`
  - `PUT /api/User/profile` — body `{firstName, lastName, avatarUrl, nativeLanguage, targetLanguage, nativeLanguageCode, targetLanguageCode, targetProficiencyLevel, dailyGoalMinutes}`. `firstName`/`lastName` required (400 if blank). Every other field: server keeps its existing value if the field is blank/omitted/zero — this is "unspecified = unchanged," not "unspecified = clear." Response: `{message, profile: <same shape as GET>}`.
  - `GET /api/Categories` → array of `{id, name, description, iconName, colorHex}` (no auth required, but the interceptor attaches the token harmlessly regardless). Verified live: 15 seeded categories, e.g. `{id:9, name:"Sports", iconName:"sports_soccer", colorHex:"#22C55E"}`.
  - `GET /api/User/categories` → same `CategoryDto[]` shape, only the signed-in user's selections.
  - `PUT /api/User/categories` — body `{"categoryIds": [1, 3, 7]}` → 200 returns updated `CategoryDto[]`. 400 if any id doesn't exist.
  - `GET /api/LearningPurposes` → array of `{id, name, description}` (auth required).
  - `GET /api/User/learning-purposes` / `PUT /api/User/learning-purposes` (body `{"purposeIds": [...]}`) — same pattern as Categories.
- All JSON is camelCase (established in the Auth slice, still true).
- No automated test may make a real network call. `VocabGridUserApi` is verified only by the manual smoke test in the final task; everything else uses `FakeUserApi` or pure functions.
- Onboarding data now saves to the API only — no local fallback, matching Auth's precedent.
- Settings (`GET/PUT /api/User/settings`) and age range are explicitly OUT of scope for this plan.

---

### Task 1: `UserApi` interface, data types, and `FakeUserApi`

**Files:**
- Create: `lib/data/api/user_api.dart`
- Test: `test/fake_user_api_test.dart`

**Interfaces:**
- Consumes: nothing (pure data types + in-memory fake, no network code)
- Produces:
  - `enum ProfileOutcome { success, validationError, networkError }`
  - `class ProfileData { firstName, lastName, email, avatarUrl, nativeLanguage, targetLanguage, nativeLanguageCode, targetLanguageCode, targetProficiencyLevel, dailyGoalMinutes, currentStreak, longestStreak, level, totalXp, isPremium }`
  - `class ProfileResult { outcome, message, profile, bool get isSuccess }` with named constructors `.success(profile)`, `.validationError(message)`, `.networkError()`
  - `class CategoryData { id, name, description, iconName, colorHex }`
  - `class LearningPurposeData { id, name, description }`
  - `abstract class UserApi` with `getProfile()`, `updateProfile({...})`, `getCategories()`, `getMyCategoryIds()`, `updateMyCategories(ids)`, `getLearningPurposes()`, `getMyLearningPurposeIds()`, `updateMyLearningPurposes(ids)`
  - `class FakeUserApi implements UserApi` — in-memory, for tests

- [ ] **Step 1: Write the failing tests**

Create `test/fake_user_api_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/user_api.dart';

void main() {
  late FakeUserApi api;

  setUp(() => api = FakeUserApi());

  test('a fresh profile has sensible defaults', () async {
    final result = await api.getProfile();

    expect(result.isSuccess, isTrue);
    expect(result.profile!.currentStreak, 0);
    expect(result.profile!.level, 1);
  });

  test('updateProfile requires firstName and lastName', () async {
    final result = await api.updateProfile(firstName: '', lastName: 'Lovelace');

    expect(result.outcome, ProfileOutcome.validationError);
  });

  test('updateProfile changes only the fields provided', () async {
    await api.updateProfile(firstName: 'Ada', lastName: 'Lovelace', dailyGoalMinutes: 20);

    final afterFirst = await api.getProfile();
    expect(afterFirst.profile!.dailyGoalMinutes, 20);

    // Omitting dailyGoalMinutes on a second update must not reset it to 0 —
    // matches the real API's "unspecified = unchanged" behavior.
    await api.updateProfile(firstName: 'Ada', lastName: 'Lovelace', nativeLanguage: 'Turkish');

    final afterSecond = await api.getProfile();
    expect(afterSecond.profile!.dailyGoalMinutes, 20);
    expect(afterSecond.profile!.nativeLanguage, 'Turkish');
  });

  test('categories start empty and can be replaced', () async {
    expect(await api.getMyCategoryIds(), isEmpty);

    final updated = await api.updateMyCategories([1, 3, 7]);

    expect(updated, [1, 3, 7]);
    expect(await api.getMyCategoryIds(), [1, 3, 7]);
  });

  test('getCategories returns the seeded reference list', () async {
    final categories = await api.getCategories();

    expect(categories, isNotEmpty);
    expect(categories.first.id, isA<int>());
  });

  test('learning purposes start empty and can be replaced', () async {
    expect(await api.getMyLearningPurposeIds(), isEmpty);

    final updated = await api.updateMyLearningPurposes([2, 4]);

    expect(updated, [2, 4]);
    expect(await api.getMyLearningPurposeIds(), [2, 4]);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/fake_user_api_test.dart`
Expected: FAIL — `Error: Not found: 'package:langigacards/data/api/user_api.dart'`

- [ ] **Step 3: Create `lib/data/api/user_api.dart`**

```dart
/// Why a profile fetch/update did or didn't succeed.
enum ProfileOutcome { success, validationError, networkError }

/// A learner's profile as the API knows it. `currentStreak`, `longestStreak`,
/// `level`, and `totalXp` are read-only — set server-side from real study
/// activity, never sent in an update request.
class ProfileData {
  const ProfileData({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.nativeLanguageCode,
    required this.targetLanguageCode,
    required this.targetProficiencyLevel,
    required this.dailyGoalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.totalXp,
    required this.isPremium,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String nativeLanguage;
  final String targetLanguage;
  final String nativeLanguageCode;
  final String targetLanguageCode;
  final String targetProficiencyLevel;
  final int dailyGoalMinutes;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final int totalXp;
  final bool isPremium;

  ProfileData copyWith({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? nativeLanguage,
    String? targetLanguage,
    String? nativeLanguageCode,
    String? targetLanguageCode,
    String? targetProficiencyLevel,
    int? dailyGoalMinutes,
  }) {
    return ProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      nativeLanguageCode: nativeLanguageCode ?? this.nativeLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      targetProficiencyLevel: targetProficiencyLevel ?? this.targetProficiencyLevel,
      dailyGoalMinutes: (dailyGoalMinutes != null && dailyGoalMinutes > 0) ? dailyGoalMinutes : this.dailyGoalMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      level: level,
      totalXp: totalXp,
      isPremium: isPremium,
    );
  }
}

/// The result of a profile fetch or update.
class ProfileResult {
  const ProfileResult._(this.outcome, {this.message, this.profile});

  const ProfileResult.success(ProfileData profile) : this._(ProfileOutcome.success, profile: profile);
  const ProfileResult.validationError(String message) : this._(ProfileOutcome.validationError, message: message);
  const ProfileResult.networkError() : this._(ProfileOutcome.networkError);

  final ProfileOutcome outcome;
  final String? message;
  final ProfileData? profile;

  bool get isSuccess => outcome == ProfileOutcome.success;
}

/// A selectable topic (e.g. "Food", "Travel") from the app's fixed
/// reference list — not a user's selection, the list itself.
class CategoryData {
  const CategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorHex,
  });

  final int id;
  final String name;
  final String description;

  /// e.g. "sports_soccer" — maps to a Flutter icon via
  /// lib/theme/category_icons.dart, not usable directly as an IconData.
  final String iconName;

  /// e.g. "#22C55E".
  final String colorHex;
}

/// A selectable reason for learning (e.g. "Travel", "Business") from the
/// app's fixed reference list.
class LearningPurposeData {
  const LearningPurposeData({required this.id, required this.name, required this.description});

  final int id;
  final String name;
  final String description;
}

/// Reads and writes a learner's profile, categories, and learning
/// purposes. [VocabGridUserApi] is the real implementation; [FakeUserApi]
/// is an in-memory stand-in for tests, the same role [FakeAuthApi] plays
/// for [AuthApi].
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

  /// The fixed reference list of every category that exists — not the
  /// signed-in user's selections.
  Future<List<CategoryData>> getCategories();

  /// The signed-in user's currently selected category ids.
  Future<List<int>> getMyCategoryIds();

  /// Replaces the signed-in user's category selection entirely. Returns
  /// the ids that ended up selected.
  Future<List<int>> updateMyCategories(List<int> categoryIds);

  Future<List<LearningPurposeData>> getLearningPurposes();
  Future<List<int>> getMyLearningPurposeIds();
  Future<List<int>> updateMyLearningPurposes(List<int> purposeIds);
}

/// In-memory [UserApi] for tests: no plugins, no network, no disk.
class FakeUserApi implements UserApi {
  ProfileData _profile = const ProfileData(
    firstName: '',
    lastName: '',
    email: '',
    nativeLanguage: '',
    targetLanguage: '',
    nativeLanguageCode: '',
    targetLanguageCode: '',
    targetProficiencyLevel: '',
    dailyGoalMinutes: 0,
    currentStreak: 0,
    longestStreak: 0,
    level: 1,
    totalXp: 0,
    isPremium: false,
  );

  final List<CategoryData> _allCategories = const [
    CategoryData(id: 1, name: 'Food', description: 'Food & Dining Vocabulary', iconName: 'restaurant', colorHex: '#F97316'),
    CategoryData(id: 2, name: 'Travel', description: 'Travel & Tourism Vocabulary', iconName: 'flight', colorHex: '#3B82F6'),
    CategoryData(id: 3, name: 'Business', description: 'Professional & Work Vocabulary', iconName: 'work', colorHex: '#6366F1'),
  ];
  final List<LearningPurposeData> _allPurposes = const [
    LearningPurposeData(id: 1, name: 'Travel', description: 'Travelling abroad'),
    LearningPurposeData(id: 2, name: 'Business', description: 'Work and career'),
  ];

  List<int> _myCategoryIds = [];
  List<int> _myPurposeIds = [];

  @override
  Future<ProfileResult> getProfile() async => ProfileResult.success(_profile);

  @override
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
  }) async {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return const ProfileResult.validationError('FirstName and LastName are required.');
    }

    _profile = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      nativeLanguageCode: nativeLanguageCode,
      targetLanguageCode: targetLanguageCode,
      targetProficiencyLevel: targetProficiencyLevel,
      dailyGoalMinutes: dailyGoalMinutes,
    );
    return ProfileResult.success(_profile);
  }

  @override
  Future<List<CategoryData>> getCategories() async => _allCategories;

  @override
  Future<List<int>> getMyCategoryIds() async => _myCategoryIds;

  @override
  Future<List<int>> updateMyCategories(List<int> categoryIds) async {
    _myCategoryIds = List.of(categoryIds);
    return _myCategoryIds;
  }

  @override
  Future<List<LearningPurposeData>> getLearningPurposes() async => _allPurposes;

  @override
  Future<List<int>> getMyLearningPurposeIds() async => _myPurposeIds;

  @override
  Future<List<int>> updateMyLearningPurposes(List<int> purposeIds) async {
    _myPurposeIds = List.of(purposeIds);
    return _myPurposeIds;
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/fake_user_api_test.dart`
Expected: `00:0X +6: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/data/api/user_api.dart test/fake_user_api_test.dart
git commit -m "Add UserApi interface, ProfileData/ProfileResult, and FakeUserApi for tests"
```

---

### Task 2: Category icon mapping

**Files:**
- Create: `lib/theme/category_icons.dart`
- Test: `test/category_icons_test.dart`

**Interfaces:**
- Consumes: nothing
- Produces: `IconData iconForCategory(String iconName)` — top-level pure function

- [ ] **Step 1: Write the failing test**

Create `test/category_icons_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/theme/category_icons.dart';

void main() {
  test('known icon names map to the matching Material icon', () {
    expect(iconForCategory('restaurant'), Icons.restaurant_rounded);
    expect(iconForCategory('sports_soccer'), Icons.sports_soccer_rounded);
    expect(iconForCategory('pets'), Icons.pets_rounded);
  });

  test('an unrecognized icon name falls back to a generic icon instead of throwing', () {
    expect(iconForCategory('some_future_category_icon'), Icons.label_outline_rounded);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/category_icons_test.dart`
Expected: FAIL — `Error: Not found: 'package:langigacards/theme/category_icons.dart'`

- [ ] **Step 3: Create `lib/theme/category_icons.dart`**

```dart
import 'package:flutter/material.dart';

/// Maps a category's `iconName` from the API (e.g. "sports_soccer") to the
/// Flutter icon this app renders for it. The API can't send an [IconData]
/// directly — icons are compile-time constants — so this table is the
/// bridge. Every name the API seeds today (verified live) is covered; an
/// unrecognized name (e.g. a category added server-side after this app
/// version shipped) falls back to a generic icon rather than crashing.
const _iconsByName = {
  'restaurant': Icons.restaurant_rounded,
  'flight': Icons.flight_rounded,
  'work': Icons.work_rounded,
  'laptop_mac': Icons.laptop_mac_rounded,
  'school': Icons.school_rounded,
  'local_movies': Icons.local_movies_rounded,
  'music_note': Icons.music_note_rounded,
  'sports_esports': Icons.sports_esports_rounded,
  'sports_soccer': Icons.sports_soccer_rounded,
  'favorite': Icons.favorite_rounded,
  'shopping_bag': Icons.shopping_bag_rounded,
  'family_restroom': Icons.family_restroom_rounded,
  'park': Icons.park_rounded,
  'science': Icons.science_rounded,
  'pets': Icons.pets_rounded,
};

IconData iconForCategory(String iconName) => _iconsByName[iconName] ?? Icons.label_outline_rounded;
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/category_icons_test.dart`
Expected: `00:0X +2: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/theme/category_icons.dart test/category_icons_test.dart
git commit -m "Add category icon-name-to-IconData mapping"
```

---

### Task 3: `VocabGridUserApi` — the real implementation

**Files:**
- Create: `lib/data/api/vocabgrid_user_api.dart`

**Interfaces:**
- Consumes: `ApiClient` (from the Auth slice) — `ApiClient.instance.dio`. `UserApi`/`ProfileResult`/`ProfileData`/`ProfileOutcome`/`CategoryData`/`LearningPurposeData` (Task 1).
- Produces: `class VocabGridUserApi implements UserApi`, constructor `VocabGridUserApi({ApiClient? client})`, top-level mutable `UserApi userApi = VocabGridUserApi();`

No automated test in this task — per the Global Constraints, nothing may make a real network call in the test suite. Verified manually in the final task against the real local server.

- [ ] **Step 1: Create `lib/data/api/vocabgrid_user_api.dart`**

```dart
import 'package:dio/dio.dart';

import '../../data/api/api_client.dart';
import 'user_api.dart';

/// Talks to the real VocabGrid backend for profile, categories, and
/// learning purposes. Every failure that isn't a validation error from the
/// server maps to [ProfileOutcome.networkError] — the same safe-by-default
/// approach `VocabGridAuthApi` uses, so an unexpected response shape
/// resolves to a result the UI can show instead of an uncaught exception.
class VocabGridUserApi implements UserApi {
  VocabGridUserApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<ProfileResult> getProfile() async {
    try {
      final response = await _client.dio.get('/api/User/profile');
      return ProfileResult.success(_profileFromJson(response.data as Map<String, dynamic>));
    } catch (_) {
      return const ProfileResult.networkError();
    }
  }

  @override
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
  }) async {
    try {
      final response = await _client.dio.put('/api/User/profile', data: {
        'firstName': firstName,
        'lastName': lastName,
        'avatarUrl': avatarUrl,
        'nativeLanguage': nativeLanguage,
        'nativeLanguageCode': nativeLanguageCode,
        'targetLanguage': targetLanguage,
        'targetLanguageCode': targetLanguageCode,
        'targetProficiencyLevel': targetProficiencyLevel,
        // The server treats 0/omitted as "leave unchanged," never as
        // "clear the goal" — there's no way to send "no opinion" other
        // than a non-positive number, per the verified contract.
        'dailyGoalMinutes': dailyGoalMinutes ?? 0,
      });
      final body = response.data as Map<String, dynamic>;
      return ProfileResult.success(_profileFromJson(body['profile'] as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final body = e.response?.data;
        if (body is String && body.isNotEmpty) {
          return ProfileResult.validationError(body);
        }
      }
      return const ProfileResult.networkError();
    } catch (_) {
      return const ProfileResult.networkError();
    }
  }

  @override
  Future<List<CategoryData>> getCategories() => _getCategoryList('/api/Categories');

  @override
  Future<List<int>> getMyCategoryIds() async {
    final categories = await _getCategoryList('/api/User/categories');
    return categories.map((c) => c.id).toList();
  }

  @override
  Future<List<int>> updateMyCategories(List<int> categoryIds) async {
    try {
      final response = await _client.dio.put('/api/User/categories', data: {'categoryIds': categoryIds});
      return (response.data as List).map((e) => (e as Map<String, dynamic>)['id'] as int).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<LearningPurposeData>> getLearningPurposes() => _getPurposeList('/api/LearningPurposes');

  @override
  Future<List<int>> getMyLearningPurposeIds() async {
    final purposes = await _getPurposeList('/api/User/learning-purposes');
    return purposes.map((p) => p.id).toList();
  }

  @override
  Future<List<int>> updateMyLearningPurposes(List<int> purposeIds) async {
    try {
      final response = await _client.dio.put('/api/User/learning-purposes', data: {'purposeIds': purposeIds});
      return (response.data as List).map((e) => (e as Map<String, dynamic>)['id'] as int).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<CategoryData>> _getCategoryList(String path) async {
    try {
      final response = await _client.dio.get(path);
      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .map((json) => CategoryData(
                id: json['id'] as int,
                name: json['name'] as String,
                description: json['description'] as String,
                iconName: json['iconName'] as String,
                colorHex: json['colorHex'] as String,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<LearningPurposeData>> _getPurposeList(String path) async {
    try {
      final response = await _client.dio.get(path);
      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .map((json) => LearningPurposeData(
                id: json['id'] as int,
                name: json['name'] as String,
                description: json['description'] as String,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  ProfileData _profileFromJson(Map<String, dynamic> json) => ProfileData(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        nativeLanguage: json['nativeLanguage'] as String,
        targetLanguage: json['targetLanguage'] as String,
        nativeLanguageCode: json['nativeLanguageCode'] as String,
        targetLanguageCode: json['targetLanguageCode'] as String,
        targetProficiencyLevel: json['targetProficiencyLevel'] as String,
        dailyGoalMinutes: json['dailyGoalMinutes'] as int,
        currentStreak: json['currentStreak'] as int,
        longestStreak: json['longestStreak'] as int,
        level: json['level'] as int,
        totalXp: json['totalXp'] as int,
        isPremium: json['isPremium'] as bool,
      );
}

/// Swappable default, the same role `AuthStore.api` plays for [UserApi] —
/// tests reassign this to [FakeUserApi].
UserApi userApi = VocabGridUserApi();
```

- [ ] **Step 2: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/data/api/vocabgrid_user_api.dart
git commit -m "Add VocabGridUserApi: real profile/categories/learning-purposes against the API"
```

---

### Task 4: Rework the onboarding wizard to be API-backed

**Files:**
- Modify: `lib/screens/onboarding_setup/onboarding_steps.dart` (`TopicsStep`, `LearningPurposeStep`)
- Modify: `lib/screens/onboarding_setup/onboarding_setup_screen.dart`
- Modify: `lib/data/onboarding_store.dart`

**Interfaces:**
- Consumes: `userApi`, `UserApi`, `CategoryData`, `LearningPurposeData`, `ProfileResult` (Tasks 1, 3), `iconForCategory` (Task 2)
- Produces: `UserProfile profileFromApiData(ProfileData data, {required List<String> categoryNames, required List<String> purposeNames})` (in `onboarding_store.dart`, replacing the deleted `profileFromOnboarding`)

This task changes all three files together because they only compile as a unit — the screen calls the steps with new signatures, and both need the new converter function.

- [ ] **Step 1: Replace `lib/data/onboarding_store.dart`**

Delete `OnboardingProfileData`, `profileFromOnboarding`, `OnboardingStore.saveProfile`,
`OnboardingStore.loadProfile`, and the now-unused `_profileKey` constant. Keep
`saveAppLanguage`/`loadAppLanguage`/`appLanguageKey` exactly as they are — unrelated, still local.
Add `profileFromApiData`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import 'api/user_api.dart';

/// Turns a profile fetched or just-saved via the API into the [UserProfile]
/// the rest of the app runs on. [categoryNames]/[purposeNames] are the
/// display names resolved from the ids the API returns for
/// getMyCategoryIds()/getMyLearningPurposeIds() — [ProfileData] itself only
/// carries the fields covered by GET/PUT /api/User/profile.
UserProfile profileFromApiData(
  ProfileData data, {
  required List<String> categoryNames,
  required List<String> purposeNames,
}) {
  return UserProfile(
    name: '${data.firstName} ${data.lastName}'.trim(),
    email: data.email,
    nativeLanguage: data.nativeLanguage,
    nativeLanguageCode: data.nativeLanguageCode,
    targetLanguage: data.targetLanguage,
    targetLanguageCode: data.targetLanguageCode,
    targetLevel: data.targetProficiencyLevel,
    learningPurposes: purposeNames,
    categories: categoryNames,
    dailyGoalMinutes: data.dailyGoalMinutes,
    streakDays: data.currentStreak,
    level: data.level,
  );
}

/// Persists the first-launch app interface language choice — the one piece
/// of onboarding-adjacent state that stays local, since it's a device
/// preference, not account data.
class OnboardingStore {
  OnboardingStore._();

  static const appLanguageKey = 'app_language_code_v1';

  static Future<void> saveAppLanguage(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(appLanguageKey, code);
    } catch (_) {
      // Best-effort; worst case the picker shows again next launch.
    }
  }

  static Future<String?> loadAppLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(appLanguageKey);
    } catch (_) {
      return null;
    }
  }
}
```

- [ ] **Step 2: Add a missing icon entry, verified against the live API**

The file already has a `_learningPurposeIcons` map near the top (`const _learningPurposeIcons = {
'Travel': Icons.flight_rounded, ...}`), keyed by purpose name — this stays, `LearningPurposeStep`
below still looks icons up by `purpose.name`. Live `/api/LearningPurposes` was checked directly and
returns `Travel`, `Business`, `Academic`, `Daily Conversation`, `Culture`, `Relocation` — five of
six already have an entry in the map; `Daily Conversation` doesn't, and would silently fall back to
the generic `Icons.star_rounded` already coded below. Add a proper icon for it: insert
`'Daily Conversation': Icons.chat_bubble_outline_rounded,` into the existing `_learningPurposeIcons`
map (any position — it's an unordered map). The `'Exam Prep'`, `'Family'`, and `'Just for Fun'`
entries can stay even though the current API data never sends those names — they're harmless
unused map entries, not worth removing, in case the API adds them later.

- [ ] **Step 3: Update `TopicsStep` and `LearningPurposeStep` in `lib/screens/onboarding_setup/onboarding_steps.dart`**

Replace the `LearningPurposeStep` class:

```dart
/// Step 4: fetched from the API, not a fixed local list — every purpose
/// carries a real id so the wizard can save the selection via
/// UserApi.updateMyLearningPurposes.
class LearningPurposeStep extends StatelessWidget {
  const LearningPurposeStep({super.key, required this.purposes, required this.selected, required this.onToggle});

  final List<LearningPurposeData> purposes;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why are you learning this language?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text('Select all that apply', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.6,
          children: [
            for (final purpose in purposes)
              _OptionCard(
                label: purpose.name,
                icon: _learningPurposeIcons[purpose.name] ?? Icons.star_rounded,
                selected: selected.contains(purpose.id),
                onTap: () => onToggle(purpose.id),
              ),
          ],
        ),
      ],
    );
  }
}
```

Replace the `TopicsStep` class:

```dart
/// Step 6: fetched from the API, not a fixed local list. Icon/color come
/// from the server's iconName/colorHex, translated via
/// lib/theme/category_icons.dart.
class TopicsStep extends StatelessWidget {
  const TopicsStep({super.key, required this.categories, required this.selected, required this.onToggle});

  final List<CategoryData> categories;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What topics would you like to study first?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text('${selected.length} selected · You can change this later', style: TextStyle(color: colors.textMuted, fontSize: 13)),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1,
          children: [
            for (final category in categories)
              _OptionCard(
                label: category.name,
                icon: iconForCategory(category.iconName),
                iconColor: _colorFromHex(category.colorHex),
                selected: selected.contains(category.id),
                onTap: () => onToggle(category.id),
                dense: true,
              ),
          ],
        ),
      ],
    );
  }
}

/// Parses "#RRGGBB" from the API into a [Color]. Falls back to a neutral
/// gray if the server ever sends something unparseable, rather than
/// throwing mid-build.
Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? const Color(0xFF9E9E9E) : Color(0xFF000000 | value);
}
```

Update the imports at the top of the file — remove `import '../../data/mock_data.dart';` (no
longer used by either step) and add:

```dart
import '../../data/api/user_api.dart';
import '../../theme/category_icons.dart';
```

- [ ] **Step 4: Rewrite `lib/screens/onboarding_setup/onboarding_setup_screen.dart`**

```dart
import 'package:flutter/material.dart';
import '../../data/api/user_api.dart';
import '../../data/onboarding_store.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/language_search_list.dart';
import '../main_shell.dart';
import 'onboarding_steps.dart';

const _stepLabels = [
  'NATIVE LANGUAGE',
  'TARGET LANGUAGE',
  'TARGET LANGUAGE LEVEL',
  'LEARNING PURPOSE',
  'YOUR AGE',
  'TOPICS & CATEGORIES',
  'DAILY GOAL',
];

/// 7-step profile wizard, run once right after email verification: native
/// language -> target language -> target level -> learning purpose -> age
/// range -> topics -> daily goal. Answers save straight to the API — there
/// is no local fallback, matching how Auth already requires network.
class OnboardingSetupScreen extends StatefulWidget {
  const OnboardingSetupScreen({super.key, required this.firstName, required this.lastName, required this.email});

  final String firstName;
  final String lastName;
  final String email;

  @override
  State<OnboardingSetupScreen> createState() => _OnboardingSetupScreenState();
}

class _OnboardingSetupScreenState extends State<OnboardingSetupScreen> {
  static const _stepCount = 7;
  int _step = 0;

  /// Null while the reference lists are still loading. The wizard can't
  /// render steps 3/5 (which need real ids to select from) until these
  /// resolve, so the whole wizard waits on both up front rather than
  /// lazy-loading per step.
  List<CategoryData>? _availableCategories;
  List<LearningPurposeData>? _availablePurposes;

  String? _nativeLanguage;
  String? _nativeLanguageCode;
  String? _targetLanguage;
  String? _targetLanguageCode;
  String? _targetLevel;
  final Set<int> _learningPurposeIds = {};
  String? _ageRange;
  final Set<int> _categoryIds = {};
  int? _dailyGoalMinutes;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    final results = await Future.wait([userApi.getCategories(), userApi.getLearningPurposes()]);
    if (!mounted) return;
    setState(() {
      _availableCategories = results[0] as List<CategoryData>;
      _availablePurposes = results[1] as List<LearningPurposeData>;
    });
  }

  bool get _canContinue => switch (_step) {
        0 => _nativeLanguage != null,
        1 => _targetLanguage != null,
        2 => _targetLevel != null,
        3 => _learningPurposeIds.isNotEmpty,
        4 => _ageRange != null,
        5 => _categoryIds.isNotEmpty,
        6 => _dailyGoalMinutes != null,
        _ => false,
      };

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step -= 1);
    }
  }

  void _continue() {
    if (_step == _stepCount - 1) {
      _finish();
    } else {
      setState(() => _step += 1);
    }
  }

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    final profileResult = await userApi.updateProfile(
      firstName: widget.firstName,
      lastName: widget.lastName,
      nativeLanguage: _nativeLanguage,
      nativeLanguageCode: _nativeLanguageCode,
      targetLanguage: _targetLanguage,
      targetLanguageCode: _targetLanguageCode,
      targetProficiencyLevel: _targetLevel,
      dailyGoalMinutes: _dailyGoalMinutes,
    );
    if (!mounted) return;

    if (!profileResult.isSuccess) {
      setState(() {
        _saving = false;
        _errorText = profileResult.outcome == ProfileOutcome.networkError
            ? "Can't reach the server. Check your connection and try again."
            : (profileResult.message ?? 'Something went wrong. Please try again.');
      });
      return;
    }

    await userApi.updateMyCategories(_categoryIds.toList());
    await userApi.updateMyLearningPurposes(_learningPurposeIds.toList());
    if (!mounted) return;

    final categoryNames = _availableCategories!
        .where((c) => _categoryIds.contains(c.id))
        .map((c) => c.name)
        .toList();
    final purposeNames = _availablePurposes!
        .where((p) => _learningPurposeIds.contains(p.id))
        .map((p) => p.name)
        .toList();

    final profile = profileFromApiData(
      profileResult.profile!,
      categoryNames: categoryNames,
      purposeNames: purposeNames,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(profile: profile)),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_availableCategories == null || _availablePurposes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final percent = (((_step + 1) / _stepCount) * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.lg, 0),
              child: Row(
                children: [
                  IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back_rounded)),
                  Expanded(
                    child: Text(
                      'STEP ${_step + 1} OF $_stepCount — ${_stepLabels[_step]}',
                      style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.6),
                    ),
                  ),
                  Text('$percent%', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  for (var i = 0; i < _stepCount; i++)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == _stepCount - 1 ? 0 : 4),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step ? colors.primary : colors.border,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: colors.danger, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(_errorText!, style: TextStyle(color: colors.danger, fontSize: 13))),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                child: _buildStep(colors),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: _step == _stepCount - 1 ? "Let's Start Learning 🚀" : 'Continue',
                onPressed: _canContinue && !_saving ? _continue : null,
                loading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(AppColorsExt colors) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your native language?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            LanguageSearchList(
              selected: _nativeLanguage,
              onSelected: (lang) => setState(() {
                _nativeLanguage = lang.$1;
                _nativeLanguageCode = lang.$2;
              }),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Which language do you want to learn?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            LanguageSearchList(
              selected: _targetLanguage,
              unavailable: _nativeLanguage,
              unavailableNote: 'you speak this',
              header: Row(
                children: [
                  Icon(Icons.language_rounded, size: 16, color: colors.textMuted),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Native: ', style: TextStyle(color: colors.textMuted, fontSize: 13)),
                  Text(_nativeLanguage ?? '', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              onSelected: (lang) => setState(() {
                _targetLanguage = lang.$1;
                _targetLanguageCode = lang.$2;
              }),
            ),
          ],
        );
      case 2:
        return TargetLevelStep(
          targetLanguage: _targetLanguage ?? 'this language',
          selected: _targetLevel,
          onSelected: (v) => setState(() => _targetLevel = v),
        );
      case 3:
        return LearningPurposeStep(
          purposes: _availablePurposes!,
          selected: _learningPurposeIds,
          onToggle: (id) => setState(() => _learningPurposeIds.contains(id) ? _learningPurposeIds.remove(id) : _learningPurposeIds.add(id)),
        );
      case 4:
        return AgeRangeStep(selected: _ageRange, onSelected: (v) => setState(() => _ageRange = v));
      case 5:
        return TopicsStep(
          categories: _availableCategories!,
          selected: _categoryIds,
          onToggle: (id) => setState(() => _categoryIds.contains(id) ? _categoryIds.remove(id) : _categoryIds.add(id)),
        );
      case 6:
      default:
        return DailyGoalStep(
          nativeLanguage: _nativeLanguage ?? '',
          targetLanguage: _targetLanguage ?? '',
          selectedMinutes: _dailyGoalMinutes,
          onSelected: (v) => setState(() => _dailyGoalMinutes = v),
        );
    }
  }
}
```

Note: `_ageRange` is still collected by the wizard (step 4 unchanged) but is never sent anywhere —
per the spec, the API has no field for it. It stays exactly as UI-only state.

- [ ] **Step 5: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: errors only in `lib/screens/main_shell.dart` (still reads the deleted
`OnboardingStore.loadProfile`/`profileFromOnboarding` — fixed in Task 5) and
`lib/screens/profile/profile_screen.dart` (still reads `MockData.categories`/`learningPurposes` in
its own edit sheets — fixed in Task 6) and `test/onboarding_wizard_test.dart` (still references the
deleted types — fixed in Task 7). No errors anywhere else.

- [ ] **Step 6: Commit**

```bash
git add lib/data/onboarding_store.dart lib/screens/onboarding_setup/onboarding_steps.dart lib/screens/onboarding_setup/onboarding_setup_screen.dart
git commit -m "Onboarding wizard: fetch categories/learning purposes from the API, save profile via UserApi"
```

---

### Task 5: Rework `MainShell` to fetch the real profile on login

**Files:**
- Modify: `lib/screens/main_shell.dart`

**Interfaces:**
- Consumes: `userApi`, `profileFromApiData` (Tasks 3, 4)

- [ ] **Step 1: Replace `_restoreSavedProfile` and add profile-fetch-error state**

Replace the whole file:

```dart
import 'package:flutter/material.dart';
import '../data/api/user_api.dart';
import '../data/mock_data.dart';
import '../data/onboarding_store.dart';
import '../data/pronunciation_service.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import 'decks/deck_dashboard_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'stats/statistics_screen.dart';
import 'study/quiz_screen.dart';
import 'study/study_session_screen.dart';

/// Root shell hosting the 4 persistent tabs (Home, Decks, Stats, Profile)
/// behind [AppBottomNav]. The 5th nav item ("Quiz") is an action that
/// pushes [QuizScreen] on top instead of switching tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.profile});

  /// Profile to start with. Registration passes the details the user just
  /// entered. Signing in has no profile handed to it — [MainShell] fetches
  /// the real one from the API itself.
  final UserProfile? profile;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;
  UserProfile? _profile;

  /// Non-null only when a post-login profile fetch failed. There is
  /// deliberately no demo-profile fallback for this path — that fallback
  /// is exactly the bug this rework exists to fix.
  bool _profileLoadFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _profile = widget.profile;
      _applyProfile(widget.profile!);
    } else {
      _loadProfileAfterLogin();
    }
  }

  Future<void> _loadProfileAfterLogin() async {
    setState(() => _profileLoadFailed = false);

    final result = await userApi.getProfile();
    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() => _profileLoadFailed = true);
      return;
    }

    final categoryIdsFuture = userApi.getMyCategoryIds();
    final purposeIdsFuture = userApi.getMyLearningPurposeIds();
    final allCategoriesFuture = userApi.getCategories();
    final allPurposesFuture = userApi.getLearningPurposes();

    final myCategoryIds = await categoryIdsFuture;
    final myPurposeIds = await purposeIdsFuture;
    final allCategories = await allCategoriesFuture;
    final allPurposes = await allPurposesFuture;
    if (!mounted) return;

    final profile = profileFromApiData(
      result.profile!,
      categoryNames: allCategories.where((c) => myCategoryIds.contains(c.id)).map((c) => c.name).toList(),
      purposeNames: allPurposes.where((p) => myPurposeIds.contains(p.id)).map((p) => p.name).toList(),
    );

    setState(() => _profile = profile);
    _applyProfile(profile);
  }

  /// Brings everything that depends on the language pair in line with
  /// [profile]: the speaking voice, and the starter decks.
  void _applyProfile(UserProfile profile) {
    // Cards are written in the language being learned, so that's the voice
    // the speaker buttons should use.
    PronunciationService.useLanguageCode(profile.targetLanguageCode);
    // And the sample decks should be in that language too — they used to be
    // French regardless of what the learner chose.
    MockData.applyStarterContent(
      targetCode: profile.targetLanguageCode,
      targetName: profile.targetLanguage,
      nativeCode: profile.nativeLanguageCode,
    );
  }

  /// Profile edits can change the language pair, so re-apply when they do.
  void _onProfileChanged(UserProfile updated) {
    final languageChanged = updated.targetLanguageCode != _profile?.targetLanguageCode ||
        updated.nativeLanguageCode != _profile?.nativeLanguageCode;
    setState(() => _profile = updated);
    if (languageChanged) _applyProfile(updated);
  }

  void _startStudySession() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudySessionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_profileLoadFailed) {
      return _ProfileLoadErrorView(onRetry: _loadProfileAfterLogin);
    }

    final profile = _profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = [
      HomeScreen(profile: profile, onStudyTap: _startStudySession, onProfileTap: () => setState(() => _tabIndex = 3)),
      const DeckDashboardScreen(),
      StatisticsScreen(profile: profile),
      ProfileScreen(profile: profile, onProfileChanged: _onProfileChanged),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: AppBottomNav(
        // Bottom nav order is Home(0) Decks(1) Quiz(2) Stats(3) Profile(4);
        // "Quiz" has no tab content, so map our 4-tab index back onto the
        // 5-item nav bar index for correct highlighting.
        currentIndex: _tabIndex >= 2 ? _tabIndex + 1 : _tabIndex,
        onQuizTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizScreen())),
        onTabSelected: (i) => setState(() => _tabIndex = i > 2 ? i - 1 : i),
      ),
    );
  }
}

/// Shown when the post-login profile fetch fails — deliberately not a
/// silent fallback to demo data, since that's the exact bug this screen
/// used to have.
class _ProfileLoadErrorView extends StatelessWidget {
  const _ProfileLoadErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 56, color: colors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text("Couldn't load your profile", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Check your connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(width: double.infinity, child: PrimaryButton(label: 'Try Again', onPressed: onRetry)),
            ],
          ),
        ),
      ),
    );
  }
}
```

Note: `OnboardingStore` is still imported by nothing in this file now (it was only used for the
deleted `loadProfile` call) — the `import '../data/onboarding_store.dart';` line is intentionally
absent from the replacement above.

- [ ] **Step 2: Confirm the project analyzes clean**

Run: `flutter analyze lib/screens/main_shell.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/screens/main_shell.dart
git commit -m "MainShell: fetch the real profile from the API after login instead of local storage"
```

---

### Task 6: Rework Profile screen's category/learning-purpose editors

**Files:**
- Modify: `lib/widgets/category_picker_sheet.dart` (a separate, standalone widget file — not
  inline in `profile_screen.dart`; it uses an `onSave` callback, not a `Navigator.pop` return
  value)
- Modify: `lib/screens/profile/profile_screen.dart` (`_editCategories`, `_editPurposes`, and the
  inline `_PurposesSheet` widget near the bottom of the file — this one *does* use a
  `Navigator.pop` return value)

**Interfaces:**
- Consumes: `userApi`, `CategoryData`, `LearningPurposeData` (Tasks 1, 3), `iconForCategory` (Task 2)

- [ ] **Step 1: Replace `lib/widgets/category_picker_sheet.dart`**

```dart
import 'package:flutter/material.dart';
import '../data/api/user_api.dart';
import '../theme/app_theme.dart';
import '../theme/category_icons.dart';
import 'app_buttons.dart';

/// "Edit Categories" bottom sheet: header with a live selected-count and
/// close button, a search box, a 3-column icon grid (selected = accent
/// border), and a gradient "Save Changes" CTA.
class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet({super.key, required this.allCategories, required this.initial, required this.onSave});

  final List<CategoryData> allCategories;
  final Set<int> initial;
  final ValueChanged<Set<int>> onSave;

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late final Set<int> _selected = Set.of(widget.initial);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final results = widget.allCategories.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Edit Categories', style: Theme.of(context).textTheme.titleLarge)),
                    Text('${_selected.length} selected', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Search categories...', prefixIcon: Icon(Icons.search_rounded)),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final category = results[i];
                      final isSelected = _selected.contains(category.id);
                      return InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: () => setState(() => isSelected ? _selected.remove(category.id) : _selected.add(category.id)),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? colors.primary.withValues(alpha: 0.16) : colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: isSelected ? colors.primary : colors.border, width: isSelected ? 1.5 : 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(iconForCategory(category.iconName), color: _colorFromHex(category.colorHex), size: 22),
                              const SizedBox(height: 4),
                              Text(category.name, style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Save Changes',
                  onPressed: () {
                    widget.onSave(_selected);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Parses "#RRGGBB" from the API into a [Color]. Falls back to a neutral
/// gray if the server ever sends something unparseable, rather than
/// throwing mid-build. Duplicated from `onboarding_steps.dart` deliberately
/// — both are small, private, and pulling it into a shared file for two
/// call sites isn't worth the indirection (YAGNI).
Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? const Color(0xFF9E9E9E) : Color(0xFF000000 | value);
}
```

- [ ] **Step 2: Update `_editCategories` in `lib/screens/profile/profile_screen.dart`**

Replace:

```dart
  void _editCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(
        initial: profile.categories.toSet(),
        onSave: (categories) => onProfileChanged(profile.copyWith(categories: categories.toList())),
      ),
    );
  }
```

with:

```dart
  void _editCategories(BuildContext context) async {
    final allCategories = await userApi.getCategories();
    if (!context.mounted) return;
    final myIds = await userApi.getMyCategoryIds();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(
        allCategories: allCategories,
        initial: myIds.toSet(),
        onSave: (categoryIds) async {
          await userApi.updateMyCategories(categoryIds.toList());
          final categoryNames = allCategories.where((c) => categoryIds.contains(c.id)).map((c) => c.name).toList();
          onProfileChanged(profile.copyWith(categories: categoryNames));
        },
      ),
    );
  }
```

- [ ] **Step 3: Update `_editPurposes` and the inline `_PurposesSheet`**

Replace `_editPurposes`:

```dart
  Future<void> _editPurposes(BuildContext context) async {
    final picked = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurposesSheet(initial: profile.learningPurposes.toSet()),
    );
    if (picked == null) return;
    onProfileChanged(profile.copyWith(learningPurposes: picked.toList()));
  }
```

with:

```dart
  Future<void> _editPurposes(BuildContext context) async {
    final allPurposes = await userApi.getLearningPurposes();
    if (!context.mounted) return;
    final myIds = await userApi.getMyLearningPurposeIds();
    if (!context.mounted) return;

    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurposesSheet(allPurposes: allPurposes, initial: myIds.toSet()),
    );
    if (picked == null) return;

    await userApi.updateMyLearningPurposes(picked.toList());
    final purposeNames = allPurposes.where((p) => picked.contains(p.id)).map((p) => p.name).toList();
    onProfileChanged(profile.copyWith(learningPurposes: purposeNames));
  }
```

Find `class _PurposesSheet` (currently reads `const _PurposesSheet({required this.initial});` with
`final Set<String> initial;`, and its `_PurposesSheetState.build` maps `MockData.learningPurposes`
into `ChoiceChipButton`s keyed by the purpose string). Replace the whole class and its state class:

```dart
/// Multi-select for "Learning Purpose", backed by the API's reference list.
class _PurposesSheet extends StatefulWidget {
  const _PurposesSheet({required this.allPurposes, required this.initial});

  final List<LearningPurposeData> allPurposes;
  final Set<int> initial;

  @override
  State<_PurposesSheet> createState() => _PurposesSheetState();
}

class _PurposesSheetState extends State<_PurposesSheet> {
  late final Set<int> _selected = Set.of(widget.initial);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _SheetScaffold(
      title: 'Learning Purpose',
      trailing: Text(
        '${_selected.length} selected',
        style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why are you learning? Pick as many as apply.', style: TextStyle(color: colors.textMuted, fontSize: 13)),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: widget.allPurposes
                  .map((purpose) => ChoiceChipButton(
                        label: purpose.name,
                        selected: _selected.contains(purpose.id),
                        onTap: () => setState(() =>
                            _selected.contains(purpose.id) ? _selected.remove(purpose.id) : _selected.add(purpose.id)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Save', onPressed: () => Navigator.of(context).pop(_selected)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Update imports in `lib/screens/profile/profile_screen.dart`**

Remove `import '../../data/mock_data.dart';` if nothing else in this file still uses `MockData`
(check with `grep -n "MockData" lib/screens/profile/profile_screen.dart` first — if any other
usage remains, leave the import). Add:

```dart
import '../../data/api/user_api.dart';
```

(`category_picker_sheet.dart`'s own new import of `iconForCategory`/`app_theme.dart` is handled in
Step 1 — `profile_screen.dart` itself doesn't need `theme/category_icons.dart` directly, since it
never renders a category icon itself, only passes data through.)

- [ ] **Step 5: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: errors only in `test/onboarding_wizard_test.dart` (fixed in Task 7). No errors in any
`lib/` file.

- [ ] **Step 6: Commit**

```bash
git add lib/widgets/category_picker_sheet.dart lib/screens/profile/profile_screen.dart
git commit -m "Profile screen: edit categories/learning purposes through the API"
```

---

### Task 7: Update `test/onboarding_wizard_test.dart`

**Files:**
- Modify: `test/onboarding_wizard_test.dart`

**Interfaces:**
- Consumes: `userApi`, `FakeUserApi` (Task 1), `profileFromApiData` (Task 4)

- [ ] **Step 1: Replace the file**

The `app language picker` group is untouched. The `onboarding wizard` group's first two tests
(step navigation) are untouched in behavior but now need `userApi` faked in `setUp` so
`OnboardingSetupScreen`'s `initState` fetch doesn't hit real network. The three tests calling the
now-deleted `profileFromOnboarding`/`OnboardingProfileData` are replaced with equivalent coverage
of `profileFromApiData`. The `OnboardingStore` group (testing the deleted `saveProfile`/
`loadProfile`) is deleted outright — nothing to test, that code no longer exists. One new test
covers the full wizard-finish flow against `FakeUserApi`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/user_api.dart';
import 'package:langigacards/data/api/vocabgrid_user_api.dart';
import 'package:langigacards/data/onboarding_store.dart';
import 'package:langigacards/screens/main_shell.dart';
import 'package:langigacards/screens/onboarding/app_language_select_screen.dart';
import 'package:langigacards/screens/onboarding_setup/onboarding_setup_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => AppControllerScope(
      controller: AppController(),
      child: MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child),
    );

Future<void> _pumpWizard(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 2600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(
    const OnboardingSetupScreen(firstName: 'Ada', lastName: 'Lovelace', email: 'ada@example.com'),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    userApi = FakeUserApi();
  });

  group('app language picker', () {
    testWidgets('Continue stays disabled until a language is chosen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wrap(const AppLanguageSelectScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Your App Language'), findsOneWidget);
      expect(await OnboardingStore.loadAppLanguage(), isNull);
    });

    testWidgets('choosing a language persists the code', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wrap(const AppLanguageSelectScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Turkish'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(await OnboardingStore.loadAppLanguage(), 'TR');
    });
  });

  group('onboarding wizard', () {
    testWidgets('starts on the native language step', (tester) async {
      await _pumpWizard(tester);

      expect(find.text('What is your native language?'), findsOneWidget);
      expect(find.textContaining('STEP 1 OF'), findsOneWidget);
    });

    testWidgets('the language you speak cannot also be the one you learn', (tester) async {
      await _pumpWizard(tester);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Which language do you want to learn?'), findsOneWidget);
      // English is now shown as unavailable on the target step.
      expect(find.text('you speak this'), findsOneWidget);

      final blocked = find.ancestor(of: find.text('you speak this'), matching: find.byType(InkWell));
      expect(tester.widget<InkWell>(blocked.first).onTap, isNull,
          reason: '"English -> English" must not be selectable');
    });

    testWidgets('finishing the wizard saves to the API and reaches MainShell', (tester) async {
      await _pumpWizard(tester);

      // Native language.
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Target language.
      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Target level.
      await tester.tap(find.text('Beginner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Learning purpose — pick whatever FakeUserApi's first seeded purpose is.
      final firstPurpose = await userApi.getLearningPurposes();
      await tester.tap(find.text(firstPurpose.first.name));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Age range.
      await tester.tap(find.text('25-34'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Topics — pick whatever FakeUserApi's first seeded category is.
      final firstCategory = await userApi.getCategories();
      await tester.tap(find.text(firstCategory.first.name));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Daily goal.
      await tester.tap(find.text('Regular'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Let's Start Learning 🚀"));
      await tester.pumpAndSettle();

      expect(find.byType(MainShell), findsOneWidget);

      final saved = await userApi.getProfile();
      expect(saved.profile!.firstName, 'Ada');
      expect(saved.profile!.nativeLanguage, 'English');
      expect(saved.profile!.targetLanguage, 'French');
      expect(await userApi.getMyCategoryIds(), [firstCategory.first.id]);
      expect(await userApi.getMyLearningPurposeIds(), [firstPurpose.first.id]);
    });
  });

  group('profileFromApiData', () {
    test('builds a UserProfile from the API response plus resolved names', () {
      const data = ProfileData(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        nativeLanguage: 'Turkish',
        targetLanguage: 'German',
        nativeLanguageCode: 'tr',
        targetLanguageCode: 'de',
        targetProficiencyLevel: 'Beginner',
        dailyGoalMinutes: 20,
        currentStreak: 3,
        longestStreak: 5,
        level: 2,
        totalXp: 40,
        isPremium: false,
      );

      final profile = profileFromApiData(data, categoryNames: ['Food'], purposeNames: ['Travel']);

      expect(profile.name, 'Ada Lovelace');
      expect(profile.email, 'ada@example.com');
      expect(profile.nativeLanguage, 'Turkish');
      expect(profile.targetLanguage, 'German');
      expect(profile.targetLanguageCode, 'de');
      expect(profile.dailyGoalMinutes, 20);
      expect(profile.categories, ['Food']);
      expect(profile.learningPurposes, ['Travel']);
      expect(profile.streakDays, 3);
      expect(profile.level, 2);
    });
  });
}
```

Note the unused-import risk: `package:langigacards/data/api/vocabgrid_user_api.dart` is imported
only for the `userApi` top-level variable reassignment in `setUp` — this is required, not
decorative, since `userApi` is declared in that file (Task 3).

- [ ] **Step 2: Run the test**

Run: `flutter test test/onboarding_wizard_test.dart`
Expected: `00:0X +6: All tests passed!` (2 app-language tests, 3 wizard tests, 1
profileFromApiData test)

- [ ] **Step 3: Confirm the whole project analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!` — this confirms Tasks 4–7 are fully wired together with no stray
references to the deleted `OnboardingStore.saveProfile`/`loadProfile`/`profileFromOnboarding`/
`OnboardingProfileData`/`MockData.categories`/`MockData.learningPurposes` left anywhere.

- [ ] **Step 4: Commit**

```bash
git add test/onboarding_wizard_test.dart
git commit -m "Update onboarding wizard tests for the API-backed flow"
```

---

### Task 8: Full suite, manual smoke test against the real server, final commit

**Files:** none (verification only)

- [ ] **Step 1: Run the full automated test suite**

Run: `flutter test`
Expected: every test passes. This confirms nothing outside Profile/Onboarding broke.

- [ ] **Step 2: Run full analyze one more time**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Confirm the VocabGrid backend is running**

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5068/api/Categories
```
Expected: `200`. If not, start it:
```bash
cd C:/dev/VocabGrid/VocabGrid/VocabGrid
dotnet run --project VocabGrid.csproj --launch-profile http
```

- [ ] **Step 4: Manual smoke test — register and complete onboarding with real selections**

Run the app (`flutter run -d windows` or `-d chrome`), register a brand-new account, go through
email verification, then the full onboarding wizard — pick real categories and a real learning
purpose on the Topics/Purpose steps (not placeholder text — confirm the icons/colors actually
render, since that's the category_icons.dart mapping in action). Finish the wizard.
Expected: reaches Home showing the name/languages/topics you actually picked — not "Sarah
Johnson."

- [ ] **Step 5: Manual smoke test — the selections actually saved server-side**

With that same account, open `http://localhost:5068/swagger` (or use `curl` with the account's
token from Step 4's `flutter run` console/network logs) to call `GET /api/User/profile` and `GET
/api/User/categories` directly.
Expected: the response matches what was picked in Step 4 — proves the wizard actually persisted to
the server, not just to in-memory app state.

- [ ] **Step 6: Manual smoke test — log out and back in shows the real profile**

From Profile, sign out. Log back in with the same account.
Expected: Home/Profile show the real name, languages, and topics again — not the demo profile.
This is the actual bug this plan exists to fix; confirm it directly.

- [ ] **Step 7: Manual smoke test — editing categories from Profile persists**

From Profile > Study Categories > Edit, change the selection, save. Sign out, log back in.
Expected: the new selection is still there after logging back in — proves the edit flow (Task 6)
round-trips through the server, not just local state for the current session.

- [ ] **Step 8: Manual smoke test — server unreachable during login shows the error state, not demo data**

Stop the backend (Ctrl+C in its terminal), then log in with the account from Step 4.
Expected: the "Couldn't load your profile" screen with a "Try Again" button — not a stuck spinner,
not the demo profile, not a crash.

- [ ] **Step 9: Restart the server for future work**

```bash
cd C:/dev/VocabGrid/VocabGrid/VocabGrid
dotnet run --project VocabGrid.csproj --launch-profile http
```

- [ ] **Step 10: Final commit if any manual testing step required a fix**

If Steps 4–8 all worked exactly as expected, there's nothing to commit here. If any manual test
step revealed a bug, fix it, re-run the relevant automated tests, re-run `flutter analyze`, and
commit the fix with a message describing what the manual test caught.
