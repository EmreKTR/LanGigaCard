import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/decks/deck_detail_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

const _deck = Deck(
  id: 'detail_deck',
  name: 'Detail Deck',
  description: 'fixture deck',
  cardCount: 0,
  dueCount: 0,
  reviewCount: 17,
  masteryPercent: 99, // server-computed figure the mastery ring should trust
  emoji: '📗',
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

/// DeckDetailScreen reads DeckStore.decks/.cards synchronously and never
/// calls the API itself, so fixtures are seeded straight into those lists
/// rather than through DeckStore's now-async, API-backed
/// addDeck/addCard/updateDeck/removeDeck. That also preserves the
/// deliberately non-default reviewCount/masteryPercent on [_deck] above --
/// distinctive, server-supplied figures that the screen is expected to
/// display verbatim (see the "mastery ring" test below) -- which only a
/// hand-built Deck (not one round-tripped through a FakeDeckApi, which
/// always starts a deck at 0) can carry.
void _addDeckLocally(Deck deck) {
  DeckStore.decks.add(deck);
  DeckStore.revision.value++;
}

void _addCardLocally(FlashCard card) {
  DeckStore.cards.add(card);
  DeckStore.revision.value++;
}

void _removeDeckLocally(String id) {
  DeckStore.decks.removeWhere((d) => d.id == id);
  DeckStore.cards.removeWhere((c) => c.deckId == id);
  DeckStore.revision.value++;
}

void _renameDeckLocally(String id, String name) {
  final index = DeckStore.decks.indexWhere((d) => d.id == id);
  DeckStore.decks[index] = DeckStore.decks[index].copyWith(name: name);
  DeckStore.revision.value++;
}

void _cleanUp() {
  DeckStore.cards.removeWhere((c) => c.deckId == _deck.id);
  DeckStore.decks.removeWhere((d) => d.id == _deck.id);
  DeckStore.revision.value++;
}

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: AppTheme.dark(AccentColor.purple),
      home: const DeckDetailScreen(deckId: 'detail_deck'),
    ),
  );
}

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() => DeckStore.storage = InMemoryLibraryStorage());

  setUp(() {
    _cleanUp();
    _addDeckLocally(_deck);
  });

  tearDown(_cleanUp);

  testWidgets('the mastery ring shows the server-computed percentage, not one recomputed from local card strength', (tester) async {
    _addCardLocally(_card('a', MemoryStrength.mastered));
    _addCardLocally(_card('b', MemoryStrength.learning));
    _addCardLocally(_card('c', MemoryStrength.reviewDue));
    _addCardLocally(_card('d', MemoryStrength.mastered));

    await _pump(tester);

    // 2 of 4 locally-cached cards are mastered (50%), but the ring must show
    // the deck's server-computed masteryPercent (99%) instead — recomputing
    // locally is exactly the bug that made every deck look "0% mastered"
    // right after a fresh login, before any card had been re-rated this
    // session (a freshly-fetched card always starts at MemoryStrength.reviewDue
    // locally, since review-progress isn't part of the flashcard-list response).
    expect(find.text('99%'), findsOneWidget);
    expect(find.text('50%'), findsNothing);
  });

  testWidgets('the strength breakdown counts each bucket', (tester) async {
    _addCardLocally(_card('a', MemoryStrength.mastered));
    _addCardLocally(_card('b', MemoryStrength.learning));
    _addCardLocally(_card('c', MemoryStrength.learning));
    _addCardLocally(_card('d', MemoryStrength.reviewDue));

    await _pump(tester);

    /// The count rendered at the end of one breakdown bar.
    String countIn(String key) => tester
        .widgetList<Text>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(Text)))
        .last
        .data!;

    expect(countIn('strength-mastered'), '1');
    expect(countIn('strength-learning'), '2');
    expect(countIn('strength-due'), '1');
    // Header "Cards / Mastered / Reviews" stats.
    expect(find.text('17'), findsOneWidget);
  });

  testWidgets('the study button counts only cards that still need work', (tester) async {
    _addCardLocally(_card('a', MemoryStrength.mastered));
    _addCardLocally(_card('b', MemoryStrength.learning));
    _addCardLocally(_card('c', MemoryStrength.reviewDue));

    await _pump(tester);

    expect(find.text('Study 2 cards'), findsOneWidget);
  });

  testWidgets('a fully mastered deck disables studying', (tester) async {
    _addCardLocally(_card('a', MemoryStrength.mastered));
    _addCardLocally(_card('b', MemoryStrength.mastered));

    await _pump(tester);

    expect(find.text('All caught up'), findsOneWidget);
    expect(find.text('Study 2 cards'), findsNothing);
  });

  testWidgets('an empty deck invites you to add a card and hides the action bar', (tester) async {
    await _pump(tester);

    expect(find.text('This deck is empty'), findsOneWidget);
    expect(find.text('Add a card'), findsOneWidget);
    expect(find.text('Quiz'), findsNothing);
  });

  testWidgets('the screen survives its deck being deleted underneath it', (tester) async {
    _addCardLocally(_card('a', MemoryStrength.learning));
    await _pump(tester);

    expect(find.text('Detail Deck'), findsNothing, reason: 'name renders with its emoji prefix');

    _removeDeckLocally(_deck.id);
    await tester.pumpAndSettle();

    expect(find.text('This deck no longer exists'), findsOneWidget);
  });

  testWidgets('renaming the deck elsewhere updates the open detail screen', (tester) async {
    _addCardLocally(_card('a', MemoryStrength.learning));
    await _pump(tester);

    expect(find.text('📗  Detail Deck'), findsOneWidget);

    _renameDeckLocally(_deck.id, 'Renamed Deck');
    await tester.pumpAndSettle();

    expect(find.text('📗  Renamed Deck'), findsOneWidget);
  });
}
