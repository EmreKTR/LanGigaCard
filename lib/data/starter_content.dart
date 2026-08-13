import 'package:flutter/material.dart';
import '../models/app_models.dart';

/// One concept expressed in every language the app offers.
///
/// Holding the vocabulary this way — rather than as a fixed list of French
/// cards — means any pair of languages can be built from the same table. A
/// Turkish speaker learning English gets "Hello / Merhaba"; an English
/// speaker learning Japanese gets "こんにちは / Hello".
class _Word {
  const _Word(this.byLanguage);

  /// Keyed by the two-letter code used in [MockData.languages].
  final Map<String, String> byLanguage;

  String? of(String code) => byLanguage[code.toUpperCase()];
}

/// Greetings and courtesy — the first deck.
const _basics = <_Word>[
  _Word({
    'GB': 'Hello', 'ES': 'Hola', 'FR': 'Bonjour', 'DE': 'Hallo', 'IT': 'Ciao',
    'PT': 'Olá', 'JP': 'こんにちは', 'KR': '안녕하세요', 'CN': '你好', 'TR': 'Merhaba',
  }),
  _Word({
    'GB': 'Thank you', 'ES': 'Gracias', 'FR': 'Merci', 'DE': 'Danke', 'IT': 'Grazie',
    'PT': 'Obrigado', 'JP': 'ありがとう', 'KR': '감사합니다', 'CN': '谢谢', 'TR': 'Teşekkürler',
  }),
  _Word({
    'GB': 'Please', 'ES': 'Por favor', 'FR': "S'il vous plaît", 'DE': 'Bitte', 'IT': 'Per favore',
    'PT': 'Por favor', 'JP': 'お願いします', 'KR': '부탁합니다', 'CN': '请', 'TR': 'Lütfen',
  }),
  _Word({
    'GB': 'Goodbye', 'ES': 'Adiós', 'FR': 'Au revoir', 'DE': 'Auf Wiedersehen', 'IT': 'Arrivederci',
    'PT': 'Adeus', 'JP': 'さようなら', 'KR': '안녕히 가세요', 'CN': '再见', 'TR': 'Hoşça kal',
  }),
  _Word({
    'GB': 'Excuse me', 'ES': 'Perdón', 'FR': 'Pardon', 'DE': 'Entschuldigung', 'IT': 'Scusi',
    'PT': 'Desculpe', 'JP': 'すみません', 'KR': '실례합니다', 'CN': '对不起', 'TR': 'Affedersiniz',
  }),
  _Word({
    'GB': 'Yes', 'ES': 'Sí', 'FR': 'Oui', 'DE': 'Ja', 'IT': 'Sì',
    'PT': 'Sim', 'JP': 'はい', 'KR': '네', 'CN': '是', 'TR': 'Evet',
  }),
  _Word({
    'GB': 'No', 'ES': 'No', 'FR': 'Non', 'DE': 'Nein', 'IT': 'No',
    'PT': 'Não', 'JP': 'いいえ', 'KR': '아니요', 'CN': '不', 'TR': 'Hayır',
  }),
];

/// Concrete nouns — the second deck.
const _everyday = <_Word>[
  _Word({
    'GB': 'Water', 'ES': 'Agua', 'FR': 'Eau', 'DE': 'Wasser', 'IT': 'Acqua',
    'PT': 'Água', 'JP': '水', 'KR': '물', 'CN': '水', 'TR': 'Su',
  }),
  _Word({
    'GB': 'Bread', 'ES': 'Pan', 'FR': 'Pain', 'DE': 'Brot', 'IT': 'Pane',
    'PT': 'Pão', 'JP': 'パン', 'KR': '빵', 'CN': '面包', 'TR': 'Ekmek',
  }),
  _Word({
    'GB': 'Friend', 'ES': 'Amigo', 'FR': 'Ami', 'DE': 'Freund', 'IT': 'Amico',
    'PT': 'Amigo', 'JP': '友達', 'KR': '친구', 'CN': '朋友', 'TR': 'Arkadaş',
  }),
  _Word({
    'GB': 'Book', 'ES': 'Libro', 'FR': 'Livre', 'DE': 'Buch', 'IT': 'Libro',
    'PT': 'Livro', 'JP': '本', 'KR': '책', 'CN': '书', 'TR': 'Kitap',
  }),
  _Word({
    'GB': 'House', 'ES': 'Casa', 'FR': 'Maison', 'DE': 'Haus', 'IT': 'Casa',
    'PT': 'Casa', 'JP': '家', 'KR': '집', 'CN': '房子', 'TR': 'Ev',
  }),
];

/// The sample decks a learner starts with, built for their own language pair.
class StarterContent {
  StarterContent._();

  /// Ids are prefixed so the app can tell "content we shipped" from "decks the
  /// learner made", which is what makes it safe to swap them when the target
  /// language changes.
  static const idPrefix = 'starter_';

  /// Deck ids from the original French-only sample, still sitting in databases
  /// created before starter content became language-aware.
  static const legacyIds = {'french_basics', 'business_french', 'travel_french'};

  static bool isStarterDeck(String deckId) =>
      deckId.startsWith(idPrefix) || legacyIds.contains(deckId);

  /// True when nothing in [decks] was made by the learner, so replacing the
  /// sample content costs them nothing.
  static bool isUntouchedLibrary(List<Deck> decks) =>
      decks.isNotEmpty && decks.every((d) => isStarterDeck(d.id));

  /// Builds the starter decks and cards for a learner whose native language is
  /// [nativeCode] and who is learning [targetCode].
  ///
  /// Cards whose two sides come out identical — "No" in English and Spanish —
  /// are dropped rather than shipped as a card that teaches nothing.
  static ({List<Deck> decks, List<FlashCard> cards}) buildFor({
    required String targetCode,
    required String targetName,
    required String nativeCode,
  }) {
    final decks = <Deck>[];
    final cards = <FlashCard>[];

    void addDeck({
      required String slug,
      required String name,
      required String description,
      required String emoji,
      required Color color,
      required List<_Word> words,
    }) {
      final deckId = '$idPrefix${slug}_${targetCode.toUpperCase()}';
      final deckCards = <FlashCard>[];

      for (var i = 0; i < words.length; i++) {
        final term = words[i].of(targetCode);
        final translation = words[i].of(nativeCode);
        if (term == null || translation == null) continue;
        if (term.toLowerCase() == translation.toLowerCase()) continue;

        deckCards.add(FlashCard(
          id: '${deckId}_$i',
          deckId: deckId,
          term: term,
          translation: translation,
          exampleSentence: '',
          strength: MemoryStrength.reviewDue,
        ));
      }

      if (deckCards.isEmpty) return;

      decks.add(Deck(
        id: deckId,
        name: name,
        description: description,
        cardCount: deckCards.length,
        dueCount: deckCards.length,
        reviewCount: 0,
        masteryPercent: 0,
        emoji: emoji,
        accentColor: color,
      ));
      cards.addAll(deckCards);
    }

    addDeck(
      slug: 'basics',
      name: '$targetName Basics',
      description: 'Greetings and everyday courtesy',
      emoji: '👋',
      color: const Color(0xFF6C5CE7),
      words: _basics,
    );
    addDeck(
      slug: 'everyday',
      name: 'Everyday $targetName',
      description: 'Words you will meet on your first day',
      emoji: '☕',
      color: const Color(0xFF3B82F6),
      words: _everyday,
    );

    return (decks: decks, cards: cards);
  }
}
