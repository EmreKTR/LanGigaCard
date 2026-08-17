import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_controller.dart';
import 'data/app_language.dart';
import 'data/deck_store.dart';
import 'data/language_store.dart';
import 'data/onboarding_store.dart';
import 'data/review_log.dart';
import 'l10n/app_localizations.dart';
import 'models/text_size_option.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restores the saved decks and cards before the first screen reads them.
  // The splash screen's delay covers this comfortably.
  await DeckStore.load();
  // Same idea for today's review log, so Home's progress ring shows real
  // minutes studied instead of a placeholder on the very first frame.
  await ReviewLog.hydrate();
  // Read the stored language before the first frame so the app never flashes
  // English on its way to the user's actual language.
  final savedLanguage = await OnboardingStore.loadAppLanguage();
  // Not awaited: the language pickers already render the built-in list and
  // rebuild when this lands, so blocking the first frame on a network call
  // would only make a cold start slower — and an unreachable server would
  // hold the app on a blank screen instead of degrading quietly.
  LanguageStore.refresh();
  runApp(LanGigaCardsApp(
    controller: AppController(locale: AppLanguage.localeFor(savedLanguage)),
  ));
}

class LanGigaCardsApp extends StatelessWidget {
  const LanGigaCardsApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppControllerScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'LanGigaCards',
            debugShowCheckedModeBanner: false,
            locale: controller.locale,
            supportedLocales: AppLanguage.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: controller.themeMode,
            theme: AppTheme.light(controller.accent),
            darkTheme: AppTheme.dark(controller.accent),
            builder: (context, child) {
              // Applies the user's Dynamic Text Size preference app-wide.
              // "Automatic" deliberately leaves the platform scaler alone so
              // the OS accessibility text-size setting still takes effect —
              // forcing linear(1.0) here used to silently cancel it.
              final mediaQuery = MediaQuery.of(context);
              final option = controller.textSize;
              return MediaQuery(
                data: option == TextSizeOption.automatic
                    ? mediaQuery
                    : mediaQuery.copyWith(textScaler: TextScaler.linear(option.scaleFactor)),
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
