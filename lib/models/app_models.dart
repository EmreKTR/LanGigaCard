import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// SRS (spaced-repetition) confidence rating, shown as 4 buttons under
/// every card: Again / Hard / Medium / Easy.
enum SrsRating { again, hard, medium, easy }

extension SrsRatingX on SrsRating {
  String get label => switch (this) {
        SrsRating.again => 'Again',
        SrsRating.hard => 'Hard',
        SrsRating.medium => 'Medium',
        SrsRating.easy => 'Easy',
      };

  String get interval => switch (this) {
        SrsRating.again => '<1d',
        SrsRating.hard => '+1 day',
        SrsRating.medium => '+3 days',
        SrsRating.easy => '+7 days',
      };

  IconData get icon => switch (this) {
        SrsRating.again => Icons.replay_rounded,
        SrsRating.hard => Icons.bolt_rounded,
        SrsRating.medium => Icons.check_rounded,
        SrsRating.easy => Icons.star_rounded,
      };

  Color color(AppColorsExt colors) => switch (this) {
        SrsRating.again => colors.srsAgain,
        SrsRating.hard => colors.srsHard,
        SrsRating.medium => colors.srsMedium,
        SrsRating.easy => colors.srsEasy,
      };
}

/// How well a card is currently memorized; shown as a colored pill.
enum MemoryStrength { mastered, learning, reviewDue }

extension MemoryStrengthX on MemoryStrength {
  String get label => switch (this) {
        MemoryStrength.mastered => 'Mastered',
        MemoryStrength.learning => 'Learning',
        MemoryStrength.reviewDue => 'Review Due',
      };

  Color color(AppColorsExt colors) => switch (this) {
        MemoryStrength.mastered => colors.mastered,
        MemoryStrength.learning => colors.learning,
        MemoryStrength.reviewDue => colors.reviewDue,
      };
}

/// A learner's profile + learning preferences, collected during signup
/// and editable afterward from Profile > Study Preferences.
class UserProfile {
  UserProfile({
    required this.name,
    required this.email,
    required this.nativeLanguage,
    required this.nativeLanguageCode,
    required this.targetLanguage,
    required this.targetLanguageCode,
    this.targetLevel = 'Beginner',
    this.learningPurposes = const [],
    this.categories = const [],
    this.dailyGoalMinutes = 10,
    this.streakDays = 0,
    this.level = 1,
    this.wordsLearned = 0,
    this.accuracyPercent = 0,
    this.studyHours = 0,
  });

  final String name;
  final String email;
  final String nativeLanguage;
  final String nativeLanguageCode;
  final String targetLanguage;
  final String targetLanguageCode;
  final String targetLevel;
  final List<String> learningPurposes;
  final List<String> categories;
  final int dailyGoalMinutes;
  final int streakDays;
  final int level;
  final int wordsLearned;
  final int accuracyPercent;
  final double studyHours;

  UserProfile copyWith({
    String? name,
    String? email,
    String? nativeLanguage,
    String? nativeLanguageCode,
    String? targetLanguage,
    String? targetLanguageCode,
    String? targetLevel,
    List<String>? learningPurposes,
    List<String>? categories,
    int? dailyGoalMinutes,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      nativeLanguageCode: nativeLanguageCode ?? this.nativeLanguageCode,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      targetLevel: targetLevel ?? this.targetLevel,
      learningPurposes: learningPurposes ?? this.learningPurposes,
      categories: categories ?? this.categories,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      streakDays: streakDays,
      level: level,
      wordsLearned: wordsLearned,
      accuracyPercent: accuracyPercent,
      studyHours: studyHours,
    );
  }
}

class Deck {
  const Deck({
    required this.id,
    required this.name,
    required this.description,
    required this.cardCount,
    required this.dueCount,
    required this.reviewCount,
    required this.masteryPercent,
    required this.emoji,
    required this.accentColor,
  });

  final String id;
  final String name;
  final String description;
  final int cardCount;
  final int dueCount;
  final int reviewCount;
  final int masteryPercent;
  final String emoji;
  final Color accentColor;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cardCount': cardCount,
        'dueCount': dueCount,
        'reviewCount': reviewCount,
        'masteryPercent': masteryPercent,
        'emoji': emoji,
        // Colors don't survive JSON, so the ARGB value is stored instead.
        'accentColor': accentColor.toARGB32(),
      };

  static Deck? fromJson(Map<String, dynamic> json) {
    try {
      return Deck(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        cardCount: json['cardCount'] as int? ?? 0,
        dueCount: json['dueCount'] as int? ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        masteryPercent: json['masteryPercent'] as int? ?? 0,
        emoji: json['emoji'] as String? ?? '📘',
        accentColor: Color(json['accentColor'] as int? ?? 0xFF6C5CE7),
      );
    } catch (_) {
      // A single unreadable deck shouldn't cost the learner the whole library.
      return null;
    }
  }

  Deck copyWith({
    String? name,
    String? description,
    int? cardCount,
    int? dueCount,
    int? reviewCount,
    int? masteryPercent,
    String? emoji,
    Color? accentColor,
  }) {
    return Deck(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      cardCount: cardCount ?? this.cardCount,
      dueCount: dueCount ?? this.dueCount,
      reviewCount: reviewCount ?? this.reviewCount,
      masteryPercent: masteryPercent ?? this.masteryPercent,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class FlashCard {
  const FlashCard({
    required this.id,
    required this.deckId,
    required this.term,
    required this.translation,
    required this.exampleSentence,
    required this.strength,
    this.reviewCount = 0,
    this.imageUrl,
  });

  final String id;
  final String deckId;
  final String term;
  final String translation;
  final String exampleSentence;
  final MemoryStrength strength;
  final int reviewCount;

  /// Optional picture shown on the answer side. Collected by "Add New Card"
  /// — the field used to exist in the form but was thrown away on save.
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'deckId': deckId,
        'term': term,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'strength': strength.name,
        'reviewCount': reviewCount,
        'imageUrl': imageUrl,
      };

  static FlashCard? fromJson(Map<String, dynamic> json) {
    try {
      return FlashCard(
        id: json['id'] as String,
        deckId: json['deckId'] as String,
        term: json['term'] as String,
        translation: json['translation'] as String,
        exampleSentence: json['exampleSentence'] as String? ?? '',
        strength: MemoryStrength.values.byName(json['strength'] as String),
        reviewCount: json['reviewCount'] as int? ?? 0,
        imageUrl: json['imageUrl'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  FlashCard copyWith({
    String? deckId,
    String? term,
    String? translation,
    String? exampleSentence,
    MemoryStrength? strength,
    int? reviewCount,
    String? imageUrl,
  }) {
    return FlashCard(
      id: id,
      deckId: deckId ?? this.deckId,
      term: term ?? this.term,
      translation: translation ?? this.translation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      strength: strength ?? this.strength,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// A deck plus the cards that were inside it, captured so a deletion can be
/// undone in one step.
class RemovedDeck {
  const RemovedDeck({required this.index, required this.deck, required this.cards});

  /// Position the deck occupied, so undo restores the original ordering.
  final int index;
  final Deck deck;
  final List<FlashCard> cards;
}

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}

class Achievement {
  const Achievement({
    required this.emoji,
    required this.title,
    required this.description,
    required this.earned,
  });

  final String emoji;
  final String title;
  final String description;
  final bool earned;
}
