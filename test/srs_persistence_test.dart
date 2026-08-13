import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/data/srs_store.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/models/srs_state.dart';
import 'package:langigacards/screens/study/study_session_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deck = Deck(
  id: 'srs_deck',
  name: 'SRS Deck',
  description: 'fixture',
  cardCount: 0,
  dueCount: 0,
  reviewCount: 0,
  masteryPercent: 0,
  emoji: '📘',
  accentColor: Color(0xFF6C5CE7),
);

FlashCard _card(String id, MemoryStrength strength) => FlashCard(
      id: id,
      deckId: _deck.id,
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: '',
      strength: strength,
    );

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child);

void _cleanUp() {
  MockData.cards.removeWhere((c) => c.deckId == _deck.id);
  MockData.decks.removeWhere((d) => d.id == _deck.id);
  MockData.revision.value++;
}

/// A stored schedule due [days] from now, as the app would write it.
String _scheduleJson(String cardId, int days) {
  final due = DateTime.now().add(Duration(days: days));
  return '{"$cardId":{"cardId":"$cardId","repetitions":2,"easeFactor":2.5,'
      '"intervalDays":6,"dueDate":"${due.toIso8601String()}","lastReviewed":null}}';
}

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() => MockData.storage = InMemoryLibraryStorage());

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _cleanUp();
    MockData.addDeck(_deck);
  });

  tearDown(_cleanUp);

  group('SrsStore', () {
    test('a review is stored and reloads with its schedule intact', () async {
      final saved = await SrsStore.recordReview('card_a', SrsRating.medium, DateTime.now());

      final loaded = await SrsStore.loadSchedules();
      expect(loaded['card_a'], isNotNull);
      expect(loaded['card_a']!.repetitions, saved.repetitions);
      expect(loaded['card_a']!.intervalDays, saved.intervalDays);
      expect(loaded['card_a']!.easeFactor, saved.easeFactor);
    });

    test('successive reviews build on the stored state rather than restarting', () async {
      final now = DateTime.now();
      await SrsStore.recordReview('card_a', SrsRating.medium, now);
      final second = await SrsStore.recordReview('card_a', SrsRating.medium, now);
      final third = await SrsStore.recordReview('card_a', SrsRating.medium, now);

      expect(second.repetitions, 2);
      expect(third.repetitions, 3);
      expect(third.intervalDays, greaterThan(second.intervalDays));
    });

    test('a card with no stored schedule falls back to its seeded strength', () {
      final now = DateTime.now();

      expect(SrsStore.isDue(_card('x', MemoryStrength.reviewDue), const {}, now), isTrue);
      expect(SrsStore.isDue(_card('x', MemoryStrength.learning), const {}, now), isTrue);
      expect(SrsStore.isDue(_card('x', MemoryStrength.mastered), const {}, now), isFalse);
    });

    test('a stored future date overrides the seeded strength', () {
      final now = DateTime.now();
      final schedules = {
        'y': SrsCardState(cardId: 'y', dueDate: now.add(const Duration(days: 7))),
        'z': SrsCardState(cardId: 'z', dueDate: now.subtract(const Duration(days: 1))),
      };

      expect(SrsStore.isDue(_card('y', MemoryStrength.reviewDue), schedules, now), isFalse);
      // Past its date, so it returns even though it was seeded as mastered.
      expect(SrsStore.isDue(_card('z', MemoryStrength.mastered), schedules, now), isTrue);
    });

    test('corrupted storage degrades to "nothing rated yet"', () async {
      SharedPreferences.setMockInitialValues({'srs_schedules_v2': 'not json at all'});

      expect(await SrsStore.loadSchedules(), isEmpty);
    });

    test('schedules saved by the old due-date-only format are carried over', () async {
      final due = DateTime.now().add(const Duration(days: 3));
      SharedPreferences.setMockInitialValues({
        'srs_due_dates_v1': '{"legacy_card":"${due.toIso8601String()}"}',
      });

      final loaded = await SrsStore.loadSchedules();

      expect(loaded['legacy_card'], isNotNull);
      expect(loaded['legacy_card']!.dueDate, due);
    });
  });

  group('study session', () {
    testWidgets('rating a card writes its next review date', (tester) async {
      MockData.addCard(_card('persist_me', MemoryStrength.reviewDue));

      await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _deck)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('term-persist_me'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();

      final stored = await SrsStore.loadSchedules();
      expect(stored.containsKey('persist_me'), isTrue,
          reason: 'the rating must outlive the session, not just this run');
      expect(stored['persist_me']!.dueDate!.isAfter(DateTime.now()), isTrue);
      expect(stored['persist_me']!.repetitions, 1);
    });

    testWidgets('a card rated into the future is not queued again', (tester) async {
      MockData.addCard(_card('done_for_now', MemoryStrength.reviewDue));
      SharedPreferences.setMockInitialValues({'srs_schedules_v2': _scheduleJson('done_for_now', 5)});

      await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _deck)));
      await tester.pumpAndSettle();

      expect(find.text('Nothing due right now'), findsOneWidget);
    });

    testWidgets('a card past its stored date comes back even if seeded as mastered', (tester) async {
      MockData.addCard(_card('lapsed', MemoryStrength.mastered));
      SharedPreferences.setMockInitialValues({'srs_schedules_v2': _scheduleJson('lapsed', -2)});

      await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _deck)));
      await tester.pumpAndSettle();

      expect(find.text('term-lapsed'), findsOneWidget);
      expect(find.text('1 left'), findsOneWidget);
    });

    testWidgets('the rating buttons advertise the real next interval', (tester) async {
      MockData.addCard(_card('preview_me', MemoryStrength.reviewDue));

      await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _deck)));
      await tester.pumpAndSettle();

      // A never-reviewed card: "Again" relearns in minutes, the rest start
      // the ladder at a day. The old bar showed a fixed "+7 days" for Easy.
      expect(find.text('10m'), findsOneWidget);
      expect(find.text('1d'), findsNWidgets(3));
      expect(find.text('+7 days'), findsNothing);
    });
  });
}
