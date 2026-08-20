import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart' show SrsRating;
import 'api/deck_api.dart';

enum PendingWriteKind { createDeck, updateDeck, deleteDeck, createCard, updateCard, deleteCard, submitReview }

/// One not-yet-synced mutation. `localId` is the id this operation's
/// *subject* was known by before syncing — for a `createDeck`/`createCard`
/// this is the temporary `"pending_<uuid>"` id the UI is already showing;
/// for every other kind it's the real, already-synced id being acted on.
class PendingWrite {
  const PendingWrite._({
    required this.kind,
    required this.localId,
    this.deckId,
    this.title,
    this.description,
    this.term,
    this.translation,
    this.exampleSentence,
    this.imageUrl,
    this.rating,
    this.durationSeconds,
    this.difficultyMode,
  });

  factory PendingWrite.createDeck({required String localId, required String title, String? description}) =>
      PendingWrite._(kind: PendingWriteKind.createDeck, localId: localId, title: title, description: description);

  factory PendingWrite.updateDeck({required String localId, required String title, String? description}) =>
      PendingWrite._(kind: PendingWriteKind.updateDeck, localId: localId, title: title, description: description);

  factory PendingWrite.deleteDeck({required String localId}) =>
      PendingWrite._(kind: PendingWriteKind.deleteDeck, localId: localId);

  factory PendingWrite.createCard({
    required String localId,
    required String deckId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) =>
      PendingWrite._(
        kind: PendingWriteKind.createCard,
        localId: localId,
        deckId: deckId,
        term: term,
        translation: translation,
        exampleSentence: exampleSentence,
        imageUrl: imageUrl,
      );

  factory PendingWrite.updateCard({
    required String localId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) =>
      PendingWrite._(
        kind: PendingWriteKind.updateCard,
        localId: localId,
        term: term,
        translation: translation,
        exampleSentence: exampleSentence,
        imageUrl: imageUrl,
      );

  factory PendingWrite.deleteCard({required String localId}) =>
      PendingWrite._(kind: PendingWriteKind.deleteCard, localId: localId);

  factory PendingWrite.submitReview({
    required String localId,
    required SrsRating rating,
    required int durationSeconds,
    String? difficultyMode,
  }) =>
      PendingWrite._(
        kind: PendingWriteKind.submitReview,
        localId: localId,
        rating: rating,
        durationSeconds: durationSeconds,
        difficultyMode: difficultyMode,
      );

  final PendingWriteKind kind;
  final String localId;
  final String? deckId;
  final String? title;
  final String? description;
  final String? term;
  final String? translation;
  final String? exampleSentence;
  final String? imageUrl;
  final SrsRating? rating;
  final int? durationSeconds;
  final String? difficultyMode;

  /// Returns a copy with every id reference (`localId` and, for a card
  /// write, `deckId`) rewritten from [from] to [to] — used when an earlier
  /// queued create flushes and this entry pointed at its temporary id.
  PendingWrite remapped(String from, String to) {
    return PendingWrite._(
      kind: kind,
      localId: localId == from ? to : localId,
      deckId: deckId == from ? to : deckId,
      title: title,
      description: description,
      term: term,
      translation: translation,
      exampleSentence: exampleSentence,
      imageUrl: imageUrl,
      rating: rating,
      durationSeconds: durationSeconds,
      difficultyMode: difficultyMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'localId': localId,
        'deckId': deckId,
        'title': title,
        'description': description,
        'term': term,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'imageUrl': imageUrl,
        'rating': rating?.name,
        'durationSeconds': durationSeconds,
        'difficultyMode': difficultyMode,
      };

  static PendingWrite? fromJson(Map<String, dynamic> json) {
    try {
      return PendingWrite._(
        kind: PendingWriteKind.values.byName(json['kind'] as String),
        localId: json['localId'] as String,
        deckId: json['deckId'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        term: json['term'] as String?,
        translation: json['translation'] as String?,
        exampleSentence: json['exampleSentence'] as String?,
        imageUrl: json['imageUrl'] as String?,
        rating: json['rating'] == null ? null : SrsRating.values.byName(json['rating'] as String),
        durationSeconds: json['durationSeconds'] as int?,
        difficultyMode: json['difficultyMode'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// What happened during one [DeckWriteQueue.flush] call.
class FlushReport {
  const FlushReport({required this.idRemap, required this.droppedForValidation});

  /// Temporary local id -> real server id, for every create that flushed
  /// successfully this round.
  final Map<String, String> idRemap;

  /// Entries removed because the server rejected them outright (not a
  /// network failure) — the caller should tell the user these didn't save.
  final List<PendingWrite> droppedForValidation;
}

/// An ordered, locally-persisted outbox of not-yet-synced deck/flashcard/
/// review mutations. Pure logic — takes a [DeckApi] as a parameter rather
/// than reaching for a global one, so it's testable in isolation from
/// [DeckStore].
class DeckWriteQueue {
  static const _prefsKey = 'deck_write_queue_v1';

  final List<PendingWrite> pending = [];

  void enqueue(PendingWrite write) => pending.add(write);

  /// Empties the queue and persists the empty state — used on logout so the
  /// next account on this device doesn't inherit the previous user's
  /// not-yet-synced writes.
  Future<void> clear() async {
    pending.clear();
    await persist();
  }

  Future<void> persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(pending.map((w) => w.toJson()).toList()));
    } catch (_) {
      // Best-effort; the queue still applies for this session.
    }
  }

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      pending
        ..clear()
        ..addAll((jsonDecode(raw) as List).map((e) => PendingWrite.fromJson(e as Map<String, dynamic>)).whereType<PendingWrite>());
    } catch (_) {
      // Corrupted/unavailable storage behaves like an empty queue.
    }
  }

  /// Processes [pending] FIFO against [api]. Stops at the first network
  /// failure (leaving it and everything after it queued for next time); a
  /// validation failure drops just that entry and continues.
  Future<FlushReport> flush(DeckApi api) async {
    final idRemap = <String, String>{};
    final dropped = <PendingWrite>[];
    final remaining = <PendingWrite>[];

    var i = 0;
    var stopped = false;
    while (i < pending.length) {
      var write = pending[i];
      // Remapping happens before the stop-check as well as before applying:
      // once an earlier entry in *this* flush created something under a
      // temporary id, every later entry referencing it — including ones
      // requeued after a subsequent network failure — must carry the real
      // id forward, or the next flush attempt will try to sync against an
      // id the server never heard of.
      for (final entry in idRemap.entries) {
        write = write.remapped(entry.key, entry.value);
      }

      if (stopped) {
        remaining.add(write);
        i++;
        continue;
      }

      final outcome = await _apply(api, write);
      switch (outcome) {
        case _Applied(:final realId):
          if (realId != null) idRemap[write.localId] = realId;
        case _ValidationFailed():
          dropped.add(write);
        case _NetworkFailed():
          stopped = true;
          remaining.add(write);
      }
      i++;
    }

    pending
      ..clear()
      ..addAll(remaining);
    await persist();

    return FlushReport(idRemap: idRemap, droppedForValidation: dropped);
  }

  Future<_ApplyOutcome> _apply(DeckApi api, PendingWrite write) async {
    switch (write.kind) {
      case PendingWriteKind.createDeck:
        final result = await api.createDeck(title: write.title!, description: write.description);
        if (result.isSuccess) return _Applied(result.deck!.id);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.updateDeck:
        if (write.localId.startsWith('pending_')) return const _ValidationFailed();
        final result = await api.updateDeck(write.localId, title: write.title!, description: write.description);
        if (result.isSuccess) return const _Applied(null);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.deleteDeck:
        if (write.localId.startsWith('pending_')) return const _ValidationFailed();
        final ok = await api.deleteDeck(write.localId);
        return ok ? const _Applied(null) : const _NetworkFailed();

      case PendingWriteKind.createCard:
        if (write.deckId!.startsWith('pending_')) return const _ValidationFailed();
        final result = await api.createFlashcard(
          deckId: write.deckId!,
          term: write.term!,
          translation: write.translation!,
          exampleSentence: write.exampleSentence,
          imageUrl: write.imageUrl,
        );
        if (result.isSuccess) return _Applied(result.card!.wordId);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.updateCard:
        if (write.localId.startsWith('pending_')) return const _ValidationFailed();
        final result = await api.updateFlashcard(
          write.localId,
          term: write.term!,
          translation: write.translation!,
          exampleSentence: write.exampleSentence,
          imageUrl: write.imageUrl,
        );
        if (result.isSuccess) return const _Applied(null);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.deleteCard:
        if (write.localId.startsWith('pending_')) return const _ValidationFailed();
        final ok = await api.deleteFlashcard(write.localId);
        return ok ? const _Applied(null) : const _NetworkFailed();

      case PendingWriteKind.submitReview:
        if (write.localId.startsWith('pending_')) return const _ValidationFailed();
        final result = await api.submitReview(
          write.localId,
          rating: write.rating!,
          durationSeconds: write.durationSeconds ?? 0,
          difficultyMode: write.difficultyMode,
        );
        if (result.isSuccess) return const _Applied(null);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();
    }
  }
}

sealed class _ApplyOutcome {
  const _ApplyOutcome();
}

class _Applied extends _ApplyOutcome {
  const _Applied(this.realId);
  final String? realId;
}

class _ValidationFailed extends _ApplyOutcome {
  const _ValidationFailed();
}

class _NetworkFailed extends _ApplyOutcome {
  const _NetworkFailed();
}
