import 'package:flutter/material.dart';
import 'data/app_language.dart';
import 'data/onboarding_store.dart';
import 'models/text_size_option.dart';
import 'theme/app_theme.dart';

/// App-wide, non-learning settings: theme mode, brand accent, sound,
/// notifications, text size and difficulty. Lives above [MaterialApp] via
/// [AppControllerScope] so any screen — most importantly Profile — can
/// read and update it without prop-drilling through the whole navigation
/// stack (Splash → Onboarding → Login → ... → Profile).
///
/// This is intentionally a small hand-rolled ChangeNotifier rather than a
/// state-management package: it keeps the starter project dependency-free.
/// For a production app with real auth/sync, swap this for
/// Riverpod/Bloc — see the accompanying notes for why.
class AppController extends ChangeNotifier {
  AppController({
    ThemeMode themeMode = ThemeMode.dark,
    AccentColor accent = AccentColor.purple,
    Locale locale = AppLanguage.fallback,
  })  : _themeMode = themeMode,
        _accent = accent,
        _locale = locale;

  ThemeMode _themeMode;
  AccentColor _accent;
  Locale _locale;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  TextSizeOption _textSize = TextSizeOption.medium;
  DifficultyMode _difficulty = DifficultyMode.b1;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AccentColor get accent => _accent;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  TextSizeOption get textSize => _textSize;
  DifficultyMode get difficulty => _difficulty;

  void setDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Points the interface at the language named by [code], which may be a
  /// picker code (`GB`, `JP`) or an ISO one (`en`) — see [AppLanguage].
  ///
  /// This is how "the app follows your native language" is enforced: the
  /// profile's native language is the only thing that calls it after
  /// onboarding, so the two can't drift apart.
  void setLanguageCode(String? code) {
    final next = AppLanguage.localeFor(code);
    if (next == _locale) return;
    _locale = next;
    notifyListeners();
    // Stores the code exactly as it arrived rather than the resolved locale:
    // the picker's `TR` is what the rest of the app already expects to read
    // back, and [AppLanguage.localeFor] copes with either shape anyway.
    if (code != null && code.isNotEmpty) {
      // Fire-and-forget, matching the rest of this codebase's best-effort
      // persistence: the choice already applies to this run either way.
      OnboardingStore.saveAppLanguage(code);
    }
  }

  void setAccent(AccentColor value) {
    _accent = value;
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setTextSize(TextSizeOption value) {
    _textSize = value;
    notifyListeners();
  }

  void setDifficulty(DifficultyMode value) {
    _difficulty = value;
    notifyListeners();
  }
}

/// Exposes an [AppController] to the widget tree via [InheritedNotifier],
/// so descendants rebuild automatically when settings change.
class AppControllerScope extends InheritedNotifier<AppController> {
  const AppControllerScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppControllerScope>();
    assert(scope != null, 'AppControllerScope.of() called with no AppControllerScope ancestor');
    return scope!.notifier!;
  }

  /// Reads the controller *without* subscribing to it.
  ///
  /// [of] is illegal during `initState` — `dependOnInheritedWidgetOfExactType`
  /// registers a dependency and asserts there. Callers that only want to push
  /// a value into the controller (rather than rebuild when it changes) can use
  /// this from anywhere, including `initState`. Returns null when there is no
  /// scope, so widgets pumped bare in tests don't crash.
  static AppController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppControllerScope>()?.notifier;
}

extension AppControllerContext on BuildContext {
  AppController get appController => AppControllerScope.of(this);
}
