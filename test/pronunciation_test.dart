import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/data/pronunciation_service.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:langigacards/widgets/status_indicators.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: AppTheme.dark(AccentColor.purple),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUp(PronunciationService.resetForTest);

  group('locale mapping', () {
    test('every language offered in the app maps to a real locale', () {
      for (final language in MockData.languages) {
        final locale = PronunciationService.localeForCode(language.$2);

        expect(locale, matches(RegExp(r'^[a-z]{2}-[A-Z]{2}$')),
            reason: '${language.$1} (${language.$2}) produced "$locale"');
      }
    });

    test('the app\'s country-ish codes become the locales a TTS engine wants', () {
      // The app stores "GB"/"CN"/"JP", which setLanguage would reject.
      expect(PronunciationService.localeForCode('GB'), 'en-GB');
      expect(PronunciationService.localeForCode('FR'), 'fr-FR');
      expect(PronunciationService.localeForCode('TR'), 'tr-TR');
      expect(PronunciationService.localeForCode('JP'), 'ja-JP');
      expect(PronunciationService.localeForCode('KR'), 'ko-KR');
      expect(PronunciationService.localeForCode('CN'), 'zh-CN');
    });

    test('the code is matched case-insensitively', () {
      expect(PronunciationService.localeForCode('fr'), 'fr-FR');
      expect(PronunciationService.localeForCode('Tr'), 'tr-TR');
    });

    test('an unknown code falls back to English rather than crashing', () {
      expect(PronunciationService.localeForCode('ZZ'), 'en-US');
      expect(PronunciationService.localeForCode(''), 'en-US');
    });

    test('no two supported languages collide on one locale', () {
      final locales = MockData.languages.map((l) => PronunciationService.localeForCode(l.$2)).toList();

      expect(locales.toSet().length, locales.length,
          reason: 'two languages sharing a locale would read words in the wrong voice');
    });
  });

  group('language selection', () {
    test('defaults to English until a target language is known', () {
      expect(PronunciationService.fallbackLocale, 'en-US');
    });

    test('the learner\'s target language becomes the speaking voice', () {
      PronunciationService.useLanguageCode('FR');
      expect(PronunciationService.fallbackLocale, 'fr-FR');

      PronunciationService.useLanguageCode('DE');
      expect(PronunciationService.fallbackLocale, 'de-DE');
    });
  });

  group('speaking without a TTS engine', () {
    test('reports unavailable instead of throwing', () async {
      // No platform channel exists in a unit test, which is the same shape of
      // failure as a device with no engine installed.
      final result = await PronunciationService.speak('Bonjour');

      expect(result.outcome, PronunciationOutcome.unavailable);
    });
  });

  group('SpeakerButton', () {
    testWidgets('is disabled when there is nothing to pronounce', (tester) async {
      await tester.pumpWidget(_wrap(const SpeakerButton()));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
      expect(find.byTooltip('Nothing to pronounce'), findsOneWidget);
    });

    testWidgets('is tappable and announced when given a word', (tester) async {
      await tester.pumpWidget(_wrap(const SpeakerButton(text: 'Bonjour')));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNotNull);
      expect(find.byTooltip('Play pronunciation'), findsOneWidget);
      expect(find.bySemanticsLabel('Play pronunciation of Bonjour'), findsOneWidget);
    });

    /// Taps the button and lets the engine timeout elapse. There is no speech
    /// engine behind a widget test, so the call hangs exactly like a wedged
    /// one on a real device.
    Future<void> tapAndWaitOut(WidgetTester tester) async {
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    }

    testWidgets('explains itself when the device cannot speak', (tester) async {
      await tester.pumpWidget(_wrap(const SpeakerButton(text: 'Bonjour')));

      await tapAndWaitOut(tester);

      // Silence would look like a broken button, so the contract is that it
      // always says what happened.
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('a stuck engine cannot leave the button spinning forever', (tester) async {
      await tester.pumpWidget(_wrap(const SpeakerButton(text: 'Bonjour')));

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget, reason: 'shows it is working');

      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      // Back to idle rather than stuck mid-"speaking".
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.graphic_eq_rounded), findsNothing);
    });
  });
}
