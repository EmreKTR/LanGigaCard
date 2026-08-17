import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/app_models.dart';
import 'library_storage.dart';

/// SQLite-backed implementation of [LibraryStorage].
///
/// Replaces the JSON document the library started on. Nothing outside this
/// file changed to switch: the screens talk to `MockData`, which talks to the
/// [LibraryStorage] interface.
///
/// Rows carry an explicit `position` because deck and card order is
/// meaningful — undoing a delete has to put the item back where it was, and
/// SQLite makes no promise about row order without an ORDER BY.
class SqliteLibraryStorage implements LibraryStorage {
  SqliteLibraryStorage({this.databaseName = 'langigacards.db'});

  final String databaseName;

  static const _version = 1;
  Database? _db;

  Future<Database> _open() async {
    final existing = _db;
    if (existing != null) return existing;

    final db = await openDatabase(
      databaseName,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE decks (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            cardCount INTEGER NOT NULL,
            dueCount INTEGER NOT NULL,
            reviewCount INTEGER NOT NULL,
            masteryPercent INTEGER NOT NULL,
            emoji TEXT NOT NULL,
            accentColor INTEGER NOT NULL,
            position INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cards (
            id TEXT PRIMARY KEY,
            deckId TEXT NOT NULL,
            term TEXT NOT NULL,
            translation TEXT NOT NULL,
            exampleSentence TEXT NOT NULL,
            strength TEXT NOT NULL,
            reviewCount INTEGER NOT NULL,
            imageUrl TEXT,
            position INTEGER NOT NULL
          )
        ''');
        // Every study queue and deck tile filters by deck.
        await db.execute('CREATE INDEX idx_cards_deck ON cards (deckId)');
      },
    );

    _db = db;
    return db;
  }

  @override
  Future<LibrarySnapshot?> load() async {
    try {
      final db = await _open();
      final deckRows = await db.query('decks', orderBy: 'position ASC');
      // A brand-new database is empty, which means "first launch", not "the
      // learner deleted everything" — the caller seeds the samples.
      if (deckRows.isEmpty) return null;

      final cardRows = await db.query('cards', orderBy: 'position ASC');

      return LibrarySnapshot(
        decks: deckRows.map(_deckFrom).whereType<Deck>().toList(),
        cards: cardRows.map(_cardFrom).whereType<FlashCard>().toList(),
      );
    } catch (_) {
      // Unreadable database behaves like a first launch rather than wiping
      // the app out.
      return null;
    }
  }

  @override
  Future<void> save(LibrarySnapshot snapshot) async {
    try {
      final db = await _open();
      // One transaction: a half-written library is worse than a stale one.
      await db.transaction((txn) async {
        await txn.delete('decks');
        await txn.delete('cards');

        final batch = txn.batch();
        for (var i = 0; i < snapshot.decks.length; i++) {
          batch.insert('decks', _deckRow(snapshot.decks[i], i));
        }
        for (var i = 0; i < snapshot.cards.length; i++) {
          batch.insert('cards', _cardRow(snapshot.cards[i], i));
        }
        await batch.commit(noResult: true);
      });
    } catch (_) {
      // Best-effort; the edit still applies in memory for this session.
    }
  }

  @override
  Future<void> clear() async {
    try {
      final db = await _open();
      await db.delete('decks');
      await db.delete('cards');
    } catch (_) {
      // Nothing stored, or the database is unavailable.
    }
  }

  /// Releases the handle. Tests open several databases in one run.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Map<String, Object?> _deckRow(Deck deck, int position) => {
        'id': deck.id,
        'name': deck.name,
        'description': deck.description,
        'cardCount': deck.cardCount,
        'dueCount': deck.dueCount,
        'reviewCount': deck.reviewCount,
        'masteryPercent': deck.masteryPercent,
        'emoji': deck.emoji,
        'accentColor': deck.accentColor.toARGB32(),
        'position': position,
      };

  Deck? _deckFrom(Map<String, Object?> row) {
    try {
      return Deck(
        id: row['id']! as String,
        name: row['name']! as String,
        description: row['description'] as String? ?? '',
        cardCount: row['cardCount'] as int? ?? 0,
        dueCount: row['dueCount'] as int? ?? 0,
        reviewCount: row['reviewCount'] as int? ?? 0,
        masteryPercent: row['masteryPercent'] as int? ?? 0,
        emoji: row['emoji'] as String? ?? '📘',
        accentColor: Color(row['accentColor'] as int? ?? 0xFF6C5CE7),
      );
    } catch (_) {
      // Skip the bad row rather than losing the whole library.
      return null;
    }
  }

  Map<String, Object?> _cardRow(FlashCard card, int position) => {
        'id': card.id,
        'deckId': card.deckId,
        'term': card.term,
        'translation': card.translation,
        'exampleSentence': card.exampleSentence,
        'strength': card.strength.name,
        'reviewCount': card.reviewCount,
        'imageUrl': card.imageUrl,
        'position': position,
      };

  FlashCard? _cardFrom(Map<String, Object?> row) {
    try {
      return FlashCard(
        id: row['id']! as String,
        deckId: row['deckId']! as String,
        term: row['term']! as String,
        translation: row['translation']! as String,
        exampleSentence: row['exampleSentence'] as String? ?? '',
        strength: MemoryStrength.values.byName(row['strength']! as String),
        reviewCount: row['reviewCount'] as int? ?? 0,
        imageUrl: row['imageUrl'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
