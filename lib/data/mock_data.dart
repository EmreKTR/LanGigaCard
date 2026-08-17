import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'deck_store.dart';
import 'library_storage.dart';
import 'starter_content.dart';

/// Starter-content generation, plus the fixed reference lists (languages,
/// categories, achievements) the app is built around.
///
/// The learner's actual decks and cards live in [DeckStore] — this class only
/// builds/seeds content for it.
class MockData {
  MockData._();

  /// Persists [DeckStore]'s current decks/cards. `DeckStore._persist` isn't
  /// reachable from here (private to its own library), so starter-content
  /// writers use this equivalent, deliberately-swallowing-failures helper.
  static Future<void> _persistDeckStore() async {
    try {
      await DeckStore.storage.save(
        LibrarySnapshot(decks: List.of(DeckStore.decks), cards: List.of(DeckStore.cards)),
      );
    } catch (_) {
      // Storage unavailable — the edit still applies in memory.
    }
  }

  /// Installs the fixed French sample used by the test suite.
  ///
  /// Deliberately not shipped to learners: the app instead builds starter
  /// content in the language they actually chose via [buildStarterContent]
  /// and creates it for real through `DeckStore.addDeck`/`addCard` (see
  /// `MainShell._syncStarterContent`). This method exists so tests
  /// have a known, stable library to assert against.
  @visibleForTesting
  static Future<void> seedSampleLibrary() async {
    DeckStore.decks
      ..clear()
      ..addAll(_sampleDecks);
    DeckStore.cards
      ..clear()
      ..addAll(_sampleCards);
    DeckStore.revision.value++;
    await _persistDeckStore();
  }

  /// Builds the starter decks/cards for a learner's language pair, or
  /// returns null if starter content doesn't apply (blank codes, or nothing
  /// to build for this pair). Does not persist anything — the caller
  /// decides how (see [MainShell._syncStarterContent]).
  static ({List<Deck> decks, List<FlashCard> cards})? buildStarterContent({
    required String targetCode,
    required String targetName,
    required String nativeCode,
  }) {
    if (targetCode.isEmpty || nativeCode.isEmpty) return null;
    final starter = StarterContent.buildFor(targetCode: targetCode, targetName: targetName, nativeCode: nativeCode);
    if (starter.decks.isEmpty) return null;
    return starter;
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

  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30];

  /// Fixed French sample used only by the test suite — see
  /// [seedSampleLibrary].
  static const List<Deck> _sampleDecks = [
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

  static const List<FlashCard> _sampleCards = [
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

  static const List<Achievement> achievements = [
    Achievement(
      emoji: '⚡',
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
