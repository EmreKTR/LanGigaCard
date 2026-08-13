/// Everything SM-2 needs to remember about one card between reviews.
///
/// The old scheduler stored only a due date, which meant a card rated "Easy"
/// five times in a row still came back in exactly seven days. SM-2 grows the
/// gap instead: each success multiplies the previous interval by the card's
/// own ease factor.
class SrsCardState {
  const SrsCardState({
    required this.cardId,
    this.repetitions = 0,
    this.easeFactor = defaultEaseFactor,
    this.intervalDays = 0,
    this.dueDate,
    this.lastReviewed,
  });

  /// SM-2's starting ease. Cards drift below this if they keep being hard.
  static const double defaultEaseFactor = 2.5;

  /// SM-2 never lets a card get harder than this, or intervals would collapse
  /// towards zero and the card would be shown forever.
  static const double minimumEaseFactor = 1.3;

  final String cardId;

  /// Consecutive successful reviews. Reset to 0 by a lapse.
  final int repetitions;

  /// How generously this card's interval grows — SM-2's "EF".
  final double easeFactor;

  /// Current gap in days. Fractional gaps (the relearning step) are held in
  /// [dueDate] rather than here.
  final int intervalDays;

  final DateTime? dueDate;
  final DateTime? lastReviewed;

  bool isDue(DateTime now) => dueDate == null || !dueDate!.isAfter(now);

  SrsCardState copyWith({
    int? repetitions,
    double? easeFactor,
    int? intervalDays,
    DateTime? dueDate,
    DateTime? lastReviewed,
  }) {
    return SrsCardState(
      cardId: cardId,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      dueDate: dueDate ?? this.dueDate,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'repetitions': repetitions,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'dueDate': dueDate?.toIso8601String(),
        'lastReviewed': lastReviewed?.toIso8601String(),
      };

  static SrsCardState? fromJson(Map<String, dynamic> json) {
    try {
      return SrsCardState(
        cardId: json['cardId'] as String,
        repetitions: json['repetitions'] as int? ?? 0,
        easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? defaultEaseFactor,
        intervalDays: json['intervalDays'] as int? ?? 0,
        dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String),
        lastReviewed: json['lastReviewed'] == null ? null : DateTime.parse(json['lastReviewed'] as String),
      );
    } catch (_) {
      // One malformed entry shouldn't take the whole schedule down with it.
      return null;
    }
  }
}
