import 'package:flutter/material.dart';
import '../data/api/vocabgrid_user_api.dart';
import '../data/deck_store.dart';
import '../data/downloaded_decks.dart';
import '../data/language_store.dart';
import '../data/onboarding_store.dart';
import '../data/pronunciation_service.dart';
import '../l10n/app_localizations.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_buttons.dart';
import '../widgets/language_setup_sheet.dart';
import 'decks/deck_dashboard_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'stats/statistics_screen.dart';
import 'study/quiz_decks_screen.dart';
import 'study/study_session_screen.dart';

/// Root shell hosting the 4 persistent tabs (Home, Decks, Stats, Profile)
/// behind [AppBottomNav]. The 5th nav item ("Quiz") is an action that
/// pushes [QuizDecksScreen] on top instead of switching tabs.
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
    DeckStore.onSyncDropped = _showSyncDroppedNotice;
    _restoreAndFlushPendingWrites();
    if (widget.profile != null) {
      _profile = widget.profile;
      _applyProfile(widget.profile!);
    } else {
      _loadProfileAfterLogin();
    }
  }

  /// `DeckStore.writeQueue` only holds what's been enqueued in memory this
  /// session — anything queued in a *previous* session (app closed with
  /// pending offline writes never flushed) only exists on disk until
  /// something calls `restore()`. This is that call: once, here, before the
  /// first flush attempt each session, so a queue from a prior session
  /// isn't silently orphaned.
  Future<void> _restoreAndFlushPendingWrites() async {
    // Which decks were downloaded is device state too, and lives on disk
    // between sessions for the same reason the queue does.
    await DownloadedDecks.restore();
    await DeckStore.writeQueue.restore();
    await DeckStore.flushPendingWrites();
  }

  void _showSyncDroppedNotice(int count) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(count == 1 ? l10n.shellSyncDroppedOne : l10n.shellSyncDroppedMany(count))),
    );
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

    final UserProfile profile;
    try {
      final myCategoryIds = await categoryIdsFuture;
      final myPurposeIds = await purposeIdsFuture;
      final allCategories = await allCategoriesFuture;
      final allPurposes = await allPurposesFuture;
      if (!mounted) return;

      profile = profileFromApiData(
        result.profile!,
        categoryNames: allCategories.where((c) => myCategoryIds.contains(c.id)).map((c) => c.name).toList(),
        purposeNames: allPurposes.where((p) => myPurposeIds.contains(p.id)).map((p) => p.name).toList(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _profileLoadFailed = true);
      return;
    }

    setState(() => _profile = profile);
    _applyProfile(profile);
  }

  /// Brings everything that depends on the language pair in line with
  /// [profile]: the speaking voice, the per-language learning profile, and
  /// the starter decks.
  ///
  /// Deliberately does *not* touch the interface language — that's a
  /// separate setting (Profile > App Preferences > App Language / the
  /// pre-login [AppLanguageSelectScreen]) and must not be overridden just
  /// because the learner changed their native language.
  ///
  /// [languageChanged] separates the two ways this runs. On sign-in the
  /// target language is whatever it already was, so the profile is merely
  /// loaded; when the learner picks a different language it has to be made
  /// active server-side, which is a write and must not happen on every
  /// launch.
  Future<void> _applyProfile(UserProfile profile, {bool languageChanged = false}) async {
    // Cards are written in the language being learned, so that's the voice
    // the speaker buttons should use.
    PronunciationService.useLanguageCode(profile.targetLanguageCode);

    if (profile.targetLanguageCode.isEmpty) {
      // No language pair yet — the account hasn't finished onboarding. Home
      // already handles this by prompting rather than showing a library.
      return;
    }

    final result = languageChanged
        ? await LanguageStore.activate(profile.targetLanguageCode, languageName: profile.targetLanguage)
        : await LanguageStore.load(profile.targetLanguageCode, languageName: profile.targetLanguage);
    if (!mounted) return;

    // A language the learner has never answered the level/interest questions
    // for has no library worth building yet, and building one from stale
    // answers would be worse than asking. The sheet writes the answers and
    // the server builds the decks in the same call.
    if (result.isSuccess && !result.profile!.isSetupCompleted) {
      final completed = await promptLanguageSetup(
        context,
        languageCode: result.profile!.languageCode,
        languageName: result.profile!.languageName.isEmpty
            ? profile.targetLanguage
            : result.profile!.languageName,
        initialLevel: profile.targetLevel,
      );
      if (!mounted) return;
      if (!completed) {
        // Backed out. Show whatever that language already has rather than
        // leaving the previous language's library on screen.
        await DeckStore.refresh();
        if (mounted) setState(() {});
        return;
      }
    }

    // The library is whatever the server built from the learner's chosen
    // topics — nothing is seeded from the device any more.
    //
    // This used to create five "universal" decks (basics, everyday words,
    // numbers, colours, time) for every new account. They belonged to no
    // topic, so a learner who picked only "Technology" still ended up with
    // six decks and no way to get rid of the other five. The server now owns
    // deck creation end to end (CategoryDeckSynchronizer), which is also the
    // only way "my library matches my topics" can hold across devices.
    await DeckStore.refresh();
    if (mounted) setState(() {});
  }

  /// Profile edits can change the language pair, so re-apply when they do.
  void _onProfileChanged(UserProfile updated) {
    final languageChanged = updated.targetLanguageCode != _profile?.targetLanguageCode ||
        updated.nativeLanguageCode != _profile?.nativeLanguageCode;

    // Saving a category selection also builds and retires that category's
    // decks on the server, so this device's library is stale the moment the
    // picker closes -- the new deck exists but nothing has fetched it yet.
    // A language change needs the same refresh, but _applyProfile already
    // does one on its way through, so only the category-only case is handled
    // here.
    final previousCategories = _profile?.categories.toSet() ?? const <String>{};
    final currentCategories = updated.categories.toSet();
    final categoriesChanged = previousCategories.length != currentCategories.length ||
        !previousCategories.containsAll(currentCategories);

    setState(() => _profile = updated);

    if (languageChanged) {
      _applyProfile(updated, languageChanged: true);
    } else if (categoriesChanged) {
      _refreshAfterCategoryChange();
    }
  }

  Future<void> _refreshAfterCategoryChange() async {
    await DeckStore.refresh();
    await LanguageStore.refreshCurrent();
    if (mounted) setState(() {});
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
      HomeScreen(
        profile: profile,
        onStudyTap: _startStudySession,
        onProfileTap: () => setState(() => _tabIndex = 3),
        onProfileChanged: _onProfileChanged,
      ),
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
        onQuizTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizDecksScreen())),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 56, color: colors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.shellProfileLoadFailed, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.shellCheckConnection,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(width: double.infinity, child: PrimaryButton(label: l10n.commonTryAgain, onPressed: onRetry)),
            ],
          ),
        ),
      ),
    );
  }
}
