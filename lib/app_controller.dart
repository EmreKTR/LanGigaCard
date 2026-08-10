import 'package:flutter/material.dart';
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
  })  : _themeMode = themeMode,
        _accent = accent;

  ThemeMode _themeMode;
  AccentColor _accent;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  TextSizeOption _textSize = TextSizeOption.medium;
  DifficultyMode _difficulty = DifficultyMode.adaptive;

  ThemeMode get themeMode => _themeMode;
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
}

extension AppControllerContext on BuildContext {
  AppController get appController => AppControllerScope.of(this);
}
