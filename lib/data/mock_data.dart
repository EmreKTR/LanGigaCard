import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'library_storage.dart';
import 'sqlite_library_storage.dart';

/// The learner's decks and cards, plus the fixed reference lists (languages,
/// categories, achievements) the app is built around.
///
/// Everything here used to be in-memory only, so a card added on Tuesday was
/// gone by Wednesday. Mutations now write through to [storage], which is an
/// interface precisely so the JSON implementation can be swapped for SQLite —
/// or a remote API — without a single screen changing.
class MockData {
  MockData._();

  /// Where decks and cards are persisted. Replace in tests, or swap the
  /// implementation to change the backing store app-wide — this one line is
  /// the whole cost of moving between JSON, SQLite and a future API.
  static LibraryStorage storage = SqliteLibraryStorage();

  /// Restores the saved library, falling back to the sample content on a
  /// first launch. Call once at startup, before the first screen reads
  /// [decks] or [cards].
  static Future<void> load() async {
    LibrarySnapshot? snapshot;
    try {
      snapshot = await storage.load();
    } catch (_) {
      // Startup awaits this, so a storage failure must never stop the app
      // from opening — fall back to the sample library instead.
      return;
    }

    if (snapshot == null) {
      // First run: keep the seeded sample library and write it down so later
      // edits have something to build on.
      await _persist();
      return;
    }

    decks
      ..clear()
      ..addAll(snapshot.decks);
    cards
      ..clear()
      ..addAll(snapshot.cards);
    revision.value++;
  }

  /// Writes the library out. Deliberately swallows failures: mutations call
  /// this without awaiting, so an unhandled storage error would surface as a
  /// crash far away from the edit that caused it. A failed save costs the
  /// change on next launch, never the session in progress.
  static Future<void> _persist() async {
    try {
      await storage.save(LibrarySnapshot(decks: List.of(decks), cards: List.of(cards)));
    } catch (_) {
      // Storage unavailable — the edit still applies in memory.
    }
  }

  /// Wipes the saved library and restores the sample content. Used by tests
  /// and a future "reset" action.
  static Future<void> resetToSeed() async {
    decks
      ..clear()
      ..addAll(_seedDecks);
    cards
      ..clear()
      ..addAll(_seedCards);
    revision.value++;
    await _persist();
  }

  static const List<(String name, String code)> languages = [
    ('English', 'GB'),
    ('Spanish', 'ES'),
    ('French', 'FR'),
    ('German', 'DE'),
    ('Italian', 'IT'),
    ('Portuguese', 'PT'),
    ('Japanese', 'JP'),
    ('Korean', 'KR'),
    ('Mandarin', 'CN'),
    ('Turkish', 'TR'),
  ];

  static const List<String> learningPurposes = [
    'Travel',
    'Business',
    'Exam Prep',
    'Academic',
    'Culture',
    'Relocation',
    'Family',
    'Just for Fun',
  ];

  static const List<LearningCategory> categories = [
    LearningCategory(Icons.restaurant_rounded, 'Food', Color(0xFFF97316)),
    LearningCategory(Icons.flight_rounded, 'Travel', Color(0xFF3B82F6)),
    LearningCategory(Icons.work_rounded, 'Business', Color(0xFF6366F1)),
    LearningCategory(Icons.laptop_mac_rounded, 'Technology', Color(0xFF06B6D4)),
    LearningCategory(Icons.school_rounded, 'Education', Color(0xFF8B5CF6)),
    LearningCategory(Icons.local_movies_rounded, 'Movies', Color(0xFFEC4899)),
    LearningCategory(Icons.music_note_rounded, 'Music', Color(0xFFF43F5E)),
    LearningCategory(Icons.sports_esports_rounded, 'Gaming', Color(0xFF10B981)),
    LearningCategory(Icons.sports_soccer_rounded, 'Sports', Color(0xFF22C55E)),
    LearningCategory(Icons.favorite_rounded, 'Health', Color(0xFFEF4444)),
    LearningCategory(Icons.shopping_bag_rounded, 'Shopping', Color(0xFFF59E0B)),
    LearningCategory(Icons.family_restroom_rounded, 'Family', Color(0xFF14B8A6)),
    LearningCategory(Icons.park_rounded, 'Nature', Color(0xFF84CC16)),
    LearningCategory(Icons.science_rounded, 'Science', Color(0xFF0EA5E9)),
    LearningCategory(Icons.pets_rounded, 'Animals', Color(0xFFA855F7)),
  ];

  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30];

  /// Sample library shipped with the app, used on a first launch and by
  /// [resetToSeed].
  static const List<Deck> _seedDecks = [
    Deck(
      id: 'french_basics',
      name: 'French Basics',
      description: 'Essential French vocabulary for everyday conversations',
      cardCount: 42,
      dueCount: 8,
      reviewCount: 124,
      masteryPercent: 68,
      emoji: '🇫🇷',
      accentColor: Color(0xFF6C5CE7),
    ),
    Deck(
      id: 'business_french',
      name: 'Business French',
      description: 'Professional vocabulary for the workplace and formal settings',
      cardCount: 28,
      dueCount: 3,
      reviewCount: 56,
      masteryPercent: 52,
      emoji: '💼',
      accentColor: Color(0xFF3B82F6),
    ),
    Deck(
      id: 'travel_french',
      name: 'Travel French',
      description: 'Phrases you\'ll actually need at the airport, hotel and street',
      cardCount: 30,
      dueCount: 0,
      reviewCount: 40,
      masteryPercent: 35,
      emoji: '✈️',
      accentColor: Color(0xFFF59E0B),
    ),
  ];

  static const List<FlashCard> _seedCards = [
    FlashCard(
      id: 'bonjour',
      deckId: 'french_basics',
      term: 'Bonjour',
      translation: 'Hello / Good morning',
      exampleSentence: 'Bonjour, comment allez-vous ?',
      strength: MemoryStrength.mastered,
      reviewCount: 5,
    ),
    FlashCard(
      id: 'merci',
      deckId: 'french_basics',
      term: 'Merci',
      translation: 'Thank you',
      exampleSentence: 'Merci beaucoup pour votre aide.',
      strength: MemoryStrength.mastered,
      reviewCount: 8,
    ),
    FlashCard(
      id: 'au_revoir',
      deckId: 'french_basics',
      term: 'Au revoir',
      translation: 'Goodbye',
      exampleSentence: 'Au revoir, à demain !',
      strength: MemoryStrength.learning,
      reviewCount: 3,
    ),
    FlashCard(
      id: 'bonsoir',
      deckId: 'french_basics',
      term: 'Bonsoir',
      translation: 'Good evening',
      exampleSentence: 'Bonsoir tout le monde.',
      strength: MemoryStrength.reviewDue,
      reviewCount: 4,
    ),
    FlashCard(
      id: 'sil_vous_plait',
      deckId: 'french_basics',
      term: "S'il vous plaît",
      translation: 'Please',
      exampleSentence: "Un café, s'il vous plaît.",
      strength: MemoryStrength.reviewDue,
      reviewCount: 2,
    ),
    FlashCard(
      id: 'liberte',
      deckId: 'french_basics',
      term: 'Liberté',
      translation: 'Freedom / Liberty',
      exampleSentence: 'La liberté est un droit fondamental.',
      strength: MemoryStrength.reviewDue,
      reviewCount: 1,
    ),
    FlashCard(
      id: 'amour',
      deckId: 'french_basics',
      term: 'Amour',
      translation: 'Love',
      exampleSentence: "L'amour est une belle chose.",
      strength: MemoryStrength.learning,
      reviewCount: 6,
    ),
    FlashCard(
      id: 'pardon',
      deckId: 'french_basics',
      term: 'Pardon',
      translation: 'Sorry / Excuse me',
      exampleSentence: 'Pardon, je ne comprends pas.',
      strength: MemoryStrength.mastered,
      reviewCount: 7,
    ),
    FlashCard(
      id: 'reunion',
      deckId: 'business_french',
      term: 'Réunion',
      translation: 'Meeting',
      exampleSentence: 'La réunion commence à neuf heures.',
      strength: MemoryStrength.learning,
      reviewCount: 2,
    ),
    FlashCard(
      id: 'contrat',
      deckId: 'business_french',
      term: 'Contrat',
      translation: 'Contract',
      exampleSentence: 'Veuillez signer le contrat.',
      strength: MemoryStrength.reviewDue,
      reviewCount: 1,
    ),
  ];

  /// The live library. Starts as the sample content and is replaced by
  /// whatever [load] finds in storage.
  static final List<Deck> decks = List.of(_seedDecks);
  static final List<FlashCard> cards = List.of(_seedCards);

  static const List<Achievement> achievements = [
    Achievement(
      emoji: '🔥',
      title: '7-Day Streak',
      description: 'Study 7 days in a row',
      earned: true,
    ),
    Achievement(
      emoji: '💯',
      title: 'Perfect Score',
      description: 'Get 100% on a quiz',
      earned: true,
    ),
    Achievement(
      emoji: '📚',
      title: 'Word Collector',
      description: 'Learn 100 words',
      earned: true,
    ),
    Achievement(
      emoji: '⚡',
      title: 'Speed Learner',
      description: 'Finish 20 cards in 5 min',
      earned: false,
    ),
    Achievement(
      emoji: '🌍',
      title: 'Polyglot',
      description: 'Start a 2nd language',
      earned: false,
    ),
  ];

  /// Bumped on every mutation below so screens can rebuild when the data
  /// changes underneath them.
  ///
  /// Without this, a screen that reads [decks]/[cards] directly keeps showing
  /// whatever it read when it was first built: `MainShell` holds its tabs in
  /// an `IndexedStack` and passes `const DeckDashboardScreen()`, and Flutter
  /// skips rebuilding a child whose widget instance is identical — so adding
  /// a card in the Card Library left the deck's "N cards" tag stale.
  /// Screens showing mock data wrap their body in a [ValueListenableBuilder]
  /// on this notifier.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Adds [deck] to the in-memory deck list (used by "Create New Deck").
  static void addDeck(Deck deck) {
    decks.add(deck);
    revision.value++;
    _persist();
  }

  /// Cards actually filed under [deckId].
  ///
  /// Deck tiles used to print the stored `Deck.cardCount`/`dueCount`, which
  /// drifted from the real library — a deck could advertise "42 cards · Study
  /// 8" while holding 8 cards of which 5 needed review. Everything user-facing
  /// now counts the cards themselves.
  static Iterable<FlashCard> cardsIn(String deckId) => cards.where((c) => c.deckId == deckId);

  static int cardCountOf(String deckId) => cardsIn(deckId).length;

  /// Cards past their review date.
  static int dueCountOf(String deckId) =>
      cardsIn(deckId).where((c) => c.strength == MemoryStrength.reviewDue).length;

  /// Cards a study session would queue up — everything not yet mastered.
  static int studyableCountOf(String deckId) =>
      cardsIn(deckId).where((c) => c.strength != MemoryStrength.mastered).length;

  static int masteryPercentOf(String deckId) {
    final total = cardCountOf(deckId);
    if (total == 0) return 0;
    final mastered = cardsIn(deckId).where((c) => c.strength == MemoryStrength.mastered).length;
    return (mastered / total * 100).round();
  }

  /// Replaces the deck matching [deck.id] in place (used by "Rename deck").
  static void updateDeck(Deck deck) {
    final index = decks.indexWhere((d) => d.id == deck.id);
    if (index == -1) return;
    decks[index] = deck;
    revision.value++;
    _persist();
  }

  /// Deletes a deck *and* the cards inside it, returning everything needed to
  /// put it back so the delete can be undone from a snackbar.
  static RemovedDeck? removeDeck(String deckId) {
    final index = decks.indexWhere((d) => d.id == deckId);
    if (index == -1) return null;

    final deck = decks.removeAt(index);
    final orphaned = cards.where((c) => c.deckId == deckId).toList();
    cards.removeWhere((c) => c.deckId == deckId);
    revision.value++;
    _persist();

    return RemovedDeck(index: index, deck: deck, cards: orphaned);
  }

  /// Reverses [removeDeck], restoring the deck at its old position along with
  /// every card that lived in it.
  static void restoreDeck(RemovedDeck removed) {
    decks.insert(removed.index.clamp(0, decks.length), removed.deck);
    cards.addAll(removed.cards);
    revision.value++;
    _persist();
  }

  /// Adds [card] to the in-memory card list and bumps its deck's card count
  /// (used by "Add New Card").
  static void addCard(FlashCard card) {
    cards.add(card);
    _bumpDeckCardCount(card.deckId, 1);
    revision.value++;
    _persist();
  }

  /// Restores a previously removed [card] at [index] (used by the "Undo"
  /// action on the delete-card snackbar).
  static void restoreCard(int index, FlashCard card) {
    cards.insert(index.clamp(0, cards.length), card);
    _bumpDeckCardCount(card.deckId, 1);
    revision.value++;
    _persist();
  }

  /// Replaces the card matching [card.id] in place (used by "Edit Card").
  static void updateCard(FlashCard card) {
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index == -1) return;
    cards[index] = card;
    revision.value++;
    _persist();
  }

  /// Removes the card with [cardId] and returns its original index so it
  /// can be passed back to [restoreCard] for undo. Returns -1 if not found.
  static int removeCard(String cardId) {
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return -1;
    final deckId = cards[index].deckId;
    cards.removeAt(index);
    _bumpDeckCardCount(deckId, -1);
    revision.value++;
    _persist();
    return index;
  }

  static void _bumpDeckCardCount(String deckId, int delta) {
    final deckIndex = decks.indexWhere((d) => d.id == deckId);
    if (deckIndex == -1) return;
    final deck = decks[deckIndex];
    decks[deckIndex] = deck.copyWith(cardCount: (deck.cardCount + delta).clamp(0, 1 << 30));
  }

  static UserProfile buildDemoProfile() => UserProfile(
        name: 'Sarah Johnson',
        email: 'sarah@example.com',
        nativeLanguage: 'English',
        nativeLanguageCode: 'GB',
        targetLanguage: 'French',
        targetLanguageCode: 'FR',
        targetLevel: 'Intermediate',
        learningPurposes: const ['Travel', 'Culture'],
        categories: const ['Food', 'Travel', 'Business'],
        dailyGoalMinutes: 10,
        streakDays: 14,
        level: 12,
        wordsLearned: 186,
        accuracyPercent: 87,
        studyHours: 4.2,
      );
}
