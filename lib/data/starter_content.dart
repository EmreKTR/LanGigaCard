import 'package:flutter/material.dart';
import '../models/app_models.dart';

/// [MockData.languages] keys its codes by country/flag (English is 'GB',
/// Japanese is 'JP') rather than by ISO 639-1 language code. The backend
/// defaults a never-onboarded account's language fields to ISO-style codes
/// ("en"), which don't otherwise match anything in this table — silently
/// producing zero starter content instead of an error. Normalizing the
/// handful of codes where the two schemes actually diverge means starter
/// content still builds correctly for those accounts too, not just ones
/// that explicitly picked a language through this app's own pickers (which
/// always send a code already in [MockData.languages], so this is a no-op
/// for them).
const _isoToFlagCode = {'EN': 'GB', 'JA': 'JP', 'KO': 'KR', 'ZH': 'CN'};

String _normalizeLanguageCode(String code) {
  final upper = code.toUpperCase();
  return _isoToFlagCode[upper] ?? upper;
}

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

  String? of(String code) => byLanguage[_normalizeLanguageCode(code)];
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

/// Counting to ten.
const _numbers = <_Word>[
  _Word({
    'GB': 'One', 'ES': 'Uno', 'FR': 'Un', 'DE': 'Eins', 'IT': 'Uno',
    'PT': 'Um', 'JP': '一', 'KR': '하나', 'CN': '一', 'TR': 'Bir',
  }),
  _Word({
    'GB': 'Two', 'ES': 'Dos', 'FR': 'Deux', 'DE': 'Zwei', 'IT': 'Due',
    'PT': 'Dois', 'JP': '二', 'KR': '둘', 'CN': '二', 'TR': 'İki',
  }),
  _Word({
    'GB': 'Three', 'ES': 'Tres', 'FR': 'Trois', 'DE': 'Drei', 'IT': 'Tre',
    'PT': 'Três', 'JP': '三', 'KR': '셋', 'CN': '三', 'TR': 'Üç',
  }),
  _Word({
    'GB': 'Four', 'ES': 'Cuatro', 'FR': 'Quatre', 'DE': 'Vier', 'IT': 'Quattro',
    'PT': 'Quatro', 'JP': '四', 'KR': '넷', 'CN': '四', 'TR': 'Dört',
  }),
  _Word({
    'GB': 'Five', 'ES': 'Cinco', 'FR': 'Cinq', 'DE': 'Fünf', 'IT': 'Cinque',
    'PT': 'Cinco', 'JP': '五', 'KR': '다섯', 'CN': '五', 'TR': 'Beş',
  }),
  _Word({
    'GB': 'Six', 'ES': 'Seis', 'FR': 'Six', 'DE': 'Sechs', 'IT': 'Sei',
    'PT': 'Seis', 'JP': '六', 'KR': '여섯', 'CN': '六', 'TR': 'Altı',
  }),
  _Word({
    'GB': 'Seven', 'ES': 'Siete', 'FR': 'Sept', 'DE': 'Sieben', 'IT': 'Sette',
    'PT': 'Sete', 'JP': '七', 'KR': '일곱', 'CN': '七', 'TR': 'Yedi',
  }),
  _Word({
    'GB': 'Eight', 'ES': 'Ocho', 'FR': 'Huit', 'DE': 'Acht', 'IT': 'Otto',
    'PT': 'Oito', 'JP': '八', 'KR': '여덟', 'CN': '八', 'TR': 'Sekiz',
  }),
  _Word({
    'GB': 'Nine', 'ES': 'Nueve', 'FR': 'Neuf', 'DE': 'Neun', 'IT': 'Nove',
    'PT': 'Nove', 'JP': '九', 'KR': '아홉', 'CN': '九', 'TR': 'Dokuz',
  }),
  _Word({
    'GB': 'Ten', 'ES': 'Diez', 'FR': 'Dix', 'DE': 'Zehn', 'IT': 'Dieci',
    'PT': 'Dez', 'JP': '十', 'KR': '열', 'CN': '十', 'TR': 'On',
  }),
];

/// What you order, buy and cook.
const _food = <_Word>[
  _Word({
    'GB': 'Milk', 'ES': 'Leche', 'FR': 'Lait', 'DE': 'Milch', 'IT': 'Latte',
    'PT': 'Leite', 'JP': '牛乳', 'KR': '우유', 'CN': '牛奶', 'TR': 'Süt',
  }),
  _Word({
    'GB': 'Coffee', 'ES': 'Café', 'FR': 'Café', 'DE': 'Kaffee', 'IT': 'Caffè',
    'PT': 'Café', 'JP': 'コーヒー', 'KR': '커피', 'CN': '咖啡', 'TR': 'Kahve',
  }),
  _Word({
    'GB': 'Tea', 'ES': 'Té', 'FR': 'Thé', 'DE': 'Tee', 'IT': 'Tè',
    'PT': 'Chá', 'JP': 'お茶', 'KR': '차', 'CN': '茶', 'TR': 'Çay',
  }),
  _Word({
    'GB': 'Apple', 'ES': 'Manzana', 'FR': 'Pomme', 'DE': 'Apfel', 'IT': 'Mela',
    'PT': 'Maçã', 'JP': 'りんご', 'KR': '사과', 'CN': '苹果', 'TR': 'Elma',
  }),
  _Word({
    'GB': 'Cheese', 'ES': 'Queso', 'FR': 'Fromage', 'DE': 'Käse', 'IT': 'Formaggio',
    'PT': 'Queijo', 'JP': 'チーズ', 'KR': '치즈', 'CN': '奶酪', 'TR': 'Peynir',
  }),
  _Word({
    'GB': 'Egg', 'ES': 'Huevo', 'FR': 'Œuf', 'DE': 'Ei', 'IT': 'Uovo',
    'PT': 'Ovo', 'JP': '卵', 'KR': '계란', 'CN': '鸡蛋', 'TR': 'Yumurta',
  }),
  _Word({
    'GB': 'Fish', 'ES': 'Pescado', 'FR': 'Poisson', 'DE': 'Fisch', 'IT': 'Pesce',
    'PT': 'Peixe', 'JP': '魚', 'KR': '생선', 'CN': '鱼', 'TR': 'Balık',
  }),
  _Word({
    'GB': 'Meat', 'ES': 'Carne', 'FR': 'Viande', 'DE': 'Fleisch', 'IT': 'Carne',
    'PT': 'Carne', 'JP': '肉', 'KR': '고기', 'CN': '肉', 'TR': 'Et',
  }),
  _Word({
    'GB': 'Rice', 'ES': 'Arroz', 'FR': 'Riz', 'DE': 'Reis', 'IT': 'Riso',
    'PT': 'Arroz', 'JP': 'ご飯', 'KR': '밥', 'CN': '米饭', 'TR': 'Pirinç',
  }),
  _Word({
    'GB': 'Salt', 'ES': 'Sal', 'FR': 'Sel', 'DE': 'Salz', 'IT': 'Sale',
    'PT': 'Sal', 'JP': '塩', 'KR': '소금', 'CN': '盐', 'TR': 'Tuz',
  }),
];

/// Getting around a city you don't know yet.
const _travel = <_Word>[
  _Word({
    'GB': 'Airport', 'ES': 'Aeropuerto', 'FR': 'Aéroport', 'DE': 'Flughafen', 'IT': 'Aeroporto',
    'PT': 'Aeroporto', 'JP': '空港', 'KR': '공항', 'CN': '机场', 'TR': 'Havalimanı',
  }),
  _Word({
    'GB': 'Station', 'ES': 'Estación', 'FR': 'Gare', 'DE': 'Bahnhof', 'IT': 'Stazione',
    'PT': 'Estação', 'JP': '駅', 'KR': '역', 'CN': '车站', 'TR': 'İstasyon',
  }),
  _Word({
    'GB': 'Ticket', 'ES': 'Billete', 'FR': 'Billet', 'DE': 'Fahrkarte', 'IT': 'Biglietto',
    'PT': 'Bilhete', 'JP': '切符', 'KR': '표', 'CN': '票', 'TR': 'Bilet',
  }),
  _Word({
    'GB': 'Hotel', 'ES': 'Hotel', 'FR': 'Hôtel', 'DE': 'Hotel', 'IT': 'Hotel',
    'PT': 'Hotel', 'JP': 'ホテル', 'KR': '호텔', 'CN': '酒店', 'TR': 'Otel',
  }),
  _Word({
    'GB': 'Map', 'ES': 'Mapa', 'FR': 'Carte', 'DE': 'Karte', 'IT': 'Mappa',
    'PT': 'Mapa', 'JP': '地図', 'KR': '지도', 'CN': '地图', 'TR': 'Harita',
  }),
  _Word({
    'GB': 'Left', 'ES': 'Izquierda', 'FR': 'Gauche', 'DE': 'Links', 'IT': 'Sinistra',
    'PT': 'Esquerda', 'JP': '左', 'KR': '왼쪽', 'CN': '左', 'TR': 'Sol',
  }),
  _Word({
    'GB': 'Right', 'ES': 'Derecha', 'FR': 'Droite', 'DE': 'Rechts', 'IT': 'Destra',
    'PT': 'Direita', 'JP': '右', 'KR': '오른쪽', 'CN': '右', 'TR': 'Sağ',
  }),
  _Word({
    'GB': 'Passport', 'ES': 'Pasaporte', 'FR': 'Passeport', 'DE': 'Reisepass', 'IT': 'Passaporto',
    'PT': 'Passaporte', 'JP': 'パスポート', 'KR': '여권', 'CN': '护照', 'TR': 'Pasaport',
  }),
  _Word({
    'GB': 'Car', 'ES': 'Coche', 'FR': 'Voiture', 'DE': 'Auto', 'IT': 'Auto',
    'PT': 'Carro', 'JP': '車', 'KR': '자동차', 'CN': '汽车', 'TR': 'Araba',
  }),
  _Word({
    'GB': 'Road', 'ES': 'Camino', 'FR': 'Route', 'DE': 'Straße', 'IT': 'Strada',
    'PT': 'Estrada', 'JP': '道', 'KR': '길', 'CN': '路', 'TR': 'Yol',
  }),
];

/// Colours.
const _colours = <_Word>[
  _Word({
    'GB': 'Red', 'ES': 'Rojo', 'FR': 'Rouge', 'DE': 'Rot', 'IT': 'Rosso',
    'PT': 'Vermelho', 'JP': '赤', 'KR': '빨강', 'CN': '红色', 'TR': 'Kırmızı',
  }),
  _Word({
    'GB': 'Blue', 'ES': 'Azul', 'FR': 'Bleu', 'DE': 'Blau', 'IT': 'Blu',
    'PT': 'Azul', 'JP': '青', 'KR': '파랑', 'CN': '蓝色', 'TR': 'Mavi',
  }),
  _Word({
    'GB': 'Green', 'ES': 'Verde', 'FR': 'Vert', 'DE': 'Grün', 'IT': 'Verde',
    'PT': 'Verde', 'JP': '緑', 'KR': '초록', 'CN': '绿色', 'TR': 'Yeşil',
  }),
  _Word({
    'GB': 'Yellow', 'ES': 'Amarillo', 'FR': 'Jaune', 'DE': 'Gelb', 'IT': 'Giallo',
    'PT': 'Amarelo', 'JP': '黄色', 'KR': '노랑', 'CN': '黄色', 'TR': 'Sarı',
  }),
  _Word({
    'GB': 'Black', 'ES': 'Negro', 'FR': 'Noir', 'DE': 'Schwarz', 'IT': 'Nero',
    'PT': 'Preto', 'JP': '黒', 'KR': '검정', 'CN': '黑色', 'TR': 'Siyah',
  }),
  _Word({
    'GB': 'White', 'ES': 'Blanco', 'FR': 'Blanc', 'DE': 'Weiß', 'IT': 'Bianco',
    'PT': 'Branco', 'JP': '白', 'KR': '하양', 'CN': '白色', 'TR': 'Beyaz',
  }),
  _Word({
    'GB': 'Orange', 'ES': 'Naranja', 'FR': 'Orange', 'DE': 'Orange', 'IT': 'Arancione',
    'PT': 'Laranja', 'JP': 'オレンジ', 'KR': '주황', 'CN': '橙色', 'TR': 'Turuncu',
  }),
  _Word({
    'GB': 'Purple', 'ES': 'Morado', 'FR': 'Violet', 'DE': 'Lila', 'IT': 'Viola',
    'PT': 'Roxo', 'JP': '紫', 'KR': '보라', 'CN': '紫色', 'TR': 'Mor',
  }),
  _Word({
    'GB': 'Brown', 'ES': 'Marrón', 'FR': 'Marron', 'DE': 'Braun', 'IT': 'Marrone',
    'PT': 'Castanho', 'JP': '茶色', 'KR': '갈색', 'CN': '棕色', 'TR': 'Kahverengi',
  }),
  _Word({
    'GB': 'Grey', 'ES': 'Gris', 'FR': 'Gris', 'DE': 'Grau', 'IT': 'Grigio',
    'PT': 'Cinzento', 'JP': '灰色', 'KR': '회색', 'CN': '灰色', 'TR': 'Gri',
  }),
];

/// The people around you.
const _family = <_Word>[
  _Word({
    'GB': 'Mother', 'ES': 'Madre', 'FR': 'Mère', 'DE': 'Mutter', 'IT': 'Madre',
    'PT': 'Mãe', 'JP': '母', 'KR': '어머니', 'CN': '母亲', 'TR': 'Anne',
  }),
  _Word({
    'GB': 'Father', 'ES': 'Padre', 'FR': 'Père', 'DE': 'Vater', 'IT': 'Padre',
    'PT': 'Pai', 'JP': '父', 'KR': '아버지', 'CN': '父亲', 'TR': 'Baba',
  }),
  _Word({
    'GB': 'Sister', 'ES': 'Hermana', 'FR': 'Sœur', 'DE': 'Schwester', 'IT': 'Sorella',
    'PT': 'Irmã', 'JP': '姉妹', 'KR': '자매', 'CN': '姐妹', 'TR': 'Kız kardeş',
  }),
  _Word({
    'GB': 'Brother', 'ES': 'Hermano', 'FR': 'Frère', 'DE': 'Bruder', 'IT': 'Fratello',
    'PT': 'Irmão', 'JP': '兄弟', 'KR': '형제', 'CN': '兄弟', 'TR': 'Erkek kardeş',
  }),
  _Word({
    'GB': 'Child', 'ES': 'Niño', 'FR': 'Enfant', 'DE': 'Kind', 'IT': 'Bambino',
    'PT': 'Criança', 'JP': '子供', 'KR': '아이', 'CN': '孩子', 'TR': 'Çocuk',
  }),
  _Word({
    'GB': 'Family', 'ES': 'Familia', 'FR': 'Famille', 'DE': 'Familie', 'IT': 'Famiglia',
    'PT': 'Família', 'JP': '家族', 'KR': '가족', 'CN': '家庭', 'TR': 'Aile',
  }),
  _Word({
    'GB': 'Grandmother', 'ES': 'Abuela', 'FR': 'Grand-mère', 'DE': 'Großmutter', 'IT': 'Nonna',
    'PT': 'Avó', 'JP': '祖母', 'KR': '할머니', 'CN': '祖母', 'TR': 'Büyükanne',
  }),
  _Word({
    'GB': 'Grandfather', 'ES': 'Abuelo', 'FR': 'Grand-père', 'DE': 'Großvater', 'IT': 'Nonno',
    'PT': 'Avô', 'JP': '祖父', 'KR': '할아버지', 'CN': '祖父', 'TR': 'Büyükbaba',
  }),
  _Word({
    'GB': 'Man', 'ES': 'Hombre', 'FR': 'Homme', 'DE': 'Mann', 'IT': 'Uomo',
    'PT': 'Homem', 'JP': '男', 'KR': '남자', 'CN': '男人', 'TR': 'Adam',
  }),
  _Word({
    'GB': 'Woman', 'ES': 'Mujer', 'FR': 'Femme', 'DE': 'Frau', 'IT': 'Donna',
    'PT': 'Mulher', 'JP': '女', 'KR': '여자', 'CN': '女人', 'TR': 'Kadın',
  }),
];

/// Saying when something happens.
const _timeAndDays = <_Word>[
  _Word({
    'GB': 'Today', 'ES': 'Hoy', 'FR': "Aujourd'hui", 'DE': 'Heute', 'IT': 'Oggi',
    'PT': 'Hoje', 'JP': '今日', 'KR': '오늘', 'CN': '今天', 'TR': 'Bugün',
  }),
  _Word({
    'GB': 'Tomorrow', 'ES': 'Mañana', 'FR': 'Demain', 'DE': 'Morgen', 'IT': 'Domani',
    'PT': 'Amanhã', 'JP': '明日', 'KR': '내일', 'CN': '明天', 'TR': 'Yarın',
  }),
  _Word({
    'GB': 'Yesterday', 'ES': 'Ayer', 'FR': 'Hier', 'DE': 'Gestern', 'IT': 'Ieri',
    'PT': 'Ontem', 'JP': '昨日', 'KR': '어제', 'CN': '昨天', 'TR': 'Dün',
  }),
  _Word({
    'GB': 'Monday', 'ES': 'Lunes', 'FR': 'Lundi', 'DE': 'Montag', 'IT': 'Lunedì',
    'PT': 'Segunda-feira', 'JP': '月曜日', 'KR': '월요일', 'CN': '星期一', 'TR': 'Pazartesi',
  }),
  _Word({
    'GB': 'Friday', 'ES': 'Viernes', 'FR': 'Vendredi', 'DE': 'Freitag', 'IT': 'Venerdì',
    'PT': 'Sexta-feira', 'JP': '金曜日', 'KR': '금요일', 'CN': '星期五', 'TR': 'Cuma',
  }),
  _Word({
    'GB': 'Week', 'ES': 'Semana', 'FR': 'Semaine', 'DE': 'Woche', 'IT': 'Settimana',
    'PT': 'Semana', 'JP': '週', 'KR': '주', 'CN': '星期', 'TR': 'Hafta',
  }),
  _Word({
    'GB': 'Month', 'ES': 'Mes', 'FR': 'Mois', 'DE': 'Monat', 'IT': 'Mese',
    'PT': 'Mês', 'JP': '月', 'KR': '달', 'CN': '月', 'TR': 'Ay',
  }),
  _Word({
    'GB': 'Year', 'ES': 'Año', 'FR': 'Année', 'DE': 'Jahr', 'IT': 'Anno',
    'PT': 'Ano', 'JP': '年', 'KR': '년', 'CN': '年', 'TR': 'Yıl',
  }),
  _Word({
    'GB': 'Morning', 'ES': 'Mañana', 'FR': 'Matin', 'DE': 'Morgen', 'IT': 'Mattina',
    'PT': 'Manhã', 'JP': '朝', 'KR': '아침', 'CN': '早上', 'TR': 'Sabah',
  }),
  _Word({
    'GB': 'Night', 'ES': 'Noche', 'FR': 'Nuit', 'DE': 'Nacht', 'IT': 'Notte',
    'PT': 'Noite', 'JP': '夜', 'KR': '밤', 'CN': '晚上', 'TR': 'Gece',
  }),
];

/// A deck's name and description in every language the app offers.
///
/// These follow the *target* language, not the learner's own: someone learning
/// German sees "Grundlagen · Begrüßungen und alltägliche Höflichkeit". The deck
/// is a piece of the language being learned, and reading its name is the first
/// small exposure to it.
///
/// Falls back to English for a language with no entry, so adding a language to
/// the picker can never produce a nameless deck.
class _DeckLabel {
  const _DeckLabel(this.titles, this.descriptions);

  final Map<String, String> titles;
  final Map<String, String> descriptions;

  String titleFor(String code) =>
      titles[_normalizeLanguageCode(code)] ?? titles['GB']!;

  String descriptionFor(String code) =>
      descriptions[_normalizeLanguageCode(code)] ?? descriptions['GB']!;
}

const _deckLabels = <String, _DeckLabel>{
  'basics': _DeckLabel(
    {
      'GB': 'Basics', 'ES': 'Fundamentos', 'FR': 'Les bases', 'DE': 'Grundlagen',
      'IT': 'Le basi', 'PT': 'Fundamentos', 'JP': '基礎', 'KR': '기초',
      'CN': '基础', 'TR': 'Temeller',
    },
    {
      'GB': 'Greetings and everyday courtesy',
      'ES': 'Saludos y cortesía diaria',
      'FR': 'Salutations et politesse au quotidien',
      'DE': 'Begrüßungen und alltägliche Höflichkeit',
      'IT': 'Saluti e cortesia quotidiana',
      'PT': 'Saudações e cortesia do dia a dia',
      'JP': 'あいさつと日常の礼儀',
      'KR': '인사와 일상 예절',
      'CN': '问候与日常礼貌',
      'TR': 'Selamlaşma ve günlük nezaket',
    },
  ),
  'everyday': _DeckLabel(
    {
      'GB': 'Everyday Words', 'ES': 'Palabras cotidianas', 'FR': 'Mots du quotidien',
      'DE': 'Alltagswörter', 'IT': 'Parole di ogni giorno', 'PT': 'Palavras do dia a dia',
      'JP': '日常の言葉', 'KR': '일상 단어', 'CN': '日常词汇', 'TR': 'Günlük Kelimeler',
    },
    {
      'GB': 'Words you will meet on your first day',
      'ES': 'Palabras que verás el primer día',
      'FR': 'Les mots de votre première journée',
      'DE': 'Wörter für den ersten Tag',
      'IT': 'Le parole del primo giorno',
      'PT': 'Palavras que verá no primeiro dia',
      'JP': '初日に出会う言葉',
      'KR': '첫날 만나는 단어',
      'CN': '第一天就会遇到的词',
      'TR': 'İlk gün karşılaşacağın kelimeler',
    },
  ),
  'numbers': _DeckLabel(
    {
      'GB': 'Numbers', 'ES': 'Números', 'FR': 'Les nombres', 'DE': 'Zahlen',
      'IT': 'I numeri', 'PT': 'Números', 'JP': '数字', 'KR': '숫자',
      'CN': '数字', 'TR': 'Sayılar',
    },
    {
      'GB': 'Counting from one to ten',
      'ES': 'Contar del uno al diez',
      'FR': 'Compter de un à dix',
      'DE': 'Von eins bis zehn zählen',
      'IT': 'Contare da uno a dieci',
      'PT': 'Contar de um a dez',
      'JP': '1から10まで数える',
      'KR': '하나부터 열까지 세기',
      'CN': '从一数到十',
      'TR': 'Birden ona kadar saymak',
    },
  ),
  'food': _DeckLabel(
    {
      'GB': 'Food & Drink', 'ES': 'Comida y bebida', 'FR': 'Manger et boire',
      'DE': 'Essen & Trinken', 'IT': 'Cibo e bevande', 'PT': 'Comida e bebida',
      'JP': '食べ物と飲み物', 'KR': '음식과 음료', 'CN': '食物与饮品', 'TR': 'Yiyecek ve İçecek',
    },
    {
      'GB': 'What you order, buy and cook',
      'ES': 'Lo que pides, compras y cocinas',
      'FR': 'Ce que vous commandez, achetez et cuisinez',
      'DE': 'Was man bestellt, kauft und kocht',
      'IT': 'Ciò che ordini, compri e cucini',
      'PT': 'O que você pede, compra e cozinha',
      'JP': '注文し、買い、料理するもの',
      'KR': '주문하고 사고 요리하는 것',
      'CN': '你点的、买的和做的',
      'TR': 'Sipariş ettiğin, aldığın ve pişirdiğin şeyler',
    },
  ),
  'travel': _DeckLabel(
    {
      'GB': 'Travel & Directions', 'ES': 'Viajes y direcciones', 'FR': 'Voyage et directions',
      'DE': 'Reisen & Wegbeschreibung', 'IT': 'Viaggi e indicazioni', 'PT': 'Viagem e direções',
      'JP': '旅行と道案内', 'KR': '여행과 길 찾기', 'CN': '旅行与问路', 'TR': 'Seyahat ve Yön Tarifi',
    },
    {
      'GB': 'Getting around a city you do not know yet',
      'ES': 'Moverse por una ciudad que aún no conoces',
      'FR': 'Se repérer dans une ville encore inconnue',
      'DE': 'Sich in einer fremden Stadt zurechtfinden',
      'IT': 'Muoversi in una città che non conosci ancora',
      'PT': 'Circular por uma cidade que ainda não conhece',
      'JP': 'まだ知らない街を歩く',
      'KR': '아직 낯선 도시를 다니기',
      'CN': '在陌生的城市里找路',
      'TR': 'Henüz tanımadığın bir şehirde yol bulmak',
    },
  ),
  'colours': _DeckLabel(
    {
      'GB': 'Colours', 'ES': 'Colores', 'FR': 'Les couleurs', 'DE': 'Farben',
      'IT': 'I colori', 'PT': 'Cores', 'JP': '色', 'KR': '색깔',
      'CN': '颜色', 'TR': 'Renkler',
    },
    {
      'GB': 'The colours you need every day',
      'ES': 'Los colores que necesitas cada día',
      'FR': 'Les couleurs dont vous avez besoin chaque jour',
      'DE': 'Die Farben für jeden Tag',
      'IT': 'I colori che servono ogni giorno',
      'PT': 'As cores que precisa todos os dias',
      'JP': '毎日使う色',
      'KR': '매일 쓰는 색',
      'CN': '每天都用得上的颜色',
      'TR': 'Her gün ihtiyaç duyduğun renkler',
    },
  ),
  'family': _DeckLabel(
    {
      'GB': 'Family & People', 'ES': 'Familia y personas', 'FR': 'Famille et personnes',
      'DE': 'Familie & Menschen', 'IT': 'Famiglia e persone', 'PT': 'Família e pessoas',
      'JP': '家族と人々', 'KR': '가족과 사람들', 'CN': '家人与他人', 'TR': 'Aile ve İnsanlar',
    },
    {
      'GB': 'The people around you',
      'ES': 'Las personas que te rodean',
      'FR': 'Les gens qui vous entourent',
      'DE': 'Die Menschen um dich herum',
      'IT': 'Le persone intorno a te',
      'PT': 'As pessoas à sua volta',
      'JP': 'あなたのまわりの人たち',
      'KR': '당신 주변의 사람들',
      'CN': '你身边的人',
      'TR': 'Etrafındaki insanlar',
    },
  ),
  'time': _DeckLabel(
    {
      'GB': 'Time & Days', 'ES': 'Tiempo y días', 'FR': 'Temps et jours',
      'DE': 'Zeit & Tage', 'IT': 'Tempo e giorni', 'PT': 'Tempo e dias',
      'JP': '時間と曜日', 'KR': '시간과 요일', 'CN': '时间与星期', 'TR': 'Zaman ve Günler',
    },
    {
      'GB': 'Saying when something happens',
      'ES': 'Decir cuándo pasa algo',
      'FR': 'Dire quand quelque chose se passe',
      'DE': 'Sagen, wann etwas passiert',
      'IT': 'Dire quando succede qualcosa',
      'PT': 'Dizer quando algo acontece',
      'JP': 'いつ起こるかを言う',
      'KR': '언제 일어나는지 말하기',
      'CN': '说明事情发生的时间',
      'TR': 'Bir şeyin ne zaman olduğunu söylemek',
    },
  ),
};

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

  /// Every title this deck has been shipped under: the current one first, then
  /// the names earlier versions of the app wrote.
  ///
  /// The swap logic uses this to tell "untouched" from "renamed by the
  /// learner". Without the older names, every deck created before the titles
  /// were translated would look renamed and never be cleaned up — so the app
  /// would keep decks for a language the learner had already left behind.
  ///
  /// Returns an empty list for a key that names a deck or language the app no
  /// longer offers, which the caller reads as "don't touch it".
  static List<String> knownTitlesFor(String starterKey, String targetName) {
    if (!starterKey.startsWith(idPrefix)) return const [];

    final body = starterKey.substring(idPrefix.length);
    final cut = body.lastIndexOf('_');
    if (cut <= 0) return const [];

    final slug = body.substring(0, cut);
    final label = _deckLabels[slug];
    if (label == null) return const [];

    return [label.titleFor(body.substring(cut + 1)), ..._legacyTitles(slug, targetName)];
  }

  /// Titles from before the deck names followed the target language. The first
  /// two embedded the language's English name, which is why [targetName] is
  /// still needed here.
  static List<String> _legacyTitles(String slug, String targetName) => switch (slug) {
        'basics' => ['$targetName Basics'],
        'everyday' => ['Everyday $targetName'],
        'numbers' => const ['Numbers'],
        'food' => const ['Food & Drink'],
        'travel' => const ['Travel & Directions'],
        'colours' => const ['Colours'],
        'family' => const ['Family & People'],
        'time' => const ['Time & Days'],
        _ => const [],
      };

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
      required String emoji,
      required Color color,
      required List<_Word> words,
    }) {
      final label = _deckLabels[slug]!;
      final name = label.titleFor(targetCode);
      final description = label.descriptionFor(targetCode);
      final deckId = '$idPrefix${slug}_${_normalizeLanguageCode(targetCode)}';
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

    addDeck(slug: 'basics',   emoji: '👋',   color: const Color(0xFF6C5CE7), words: _basics);
    addDeck(slug: 'everyday', emoji: '☕',   color: const Color(0xFF3B82F6), words: _everyday);
    addDeck(slug: 'numbers',  emoji: '🔢',   color: const Color(0xFF10B981), words: _numbers);
    addDeck(slug: 'food',     emoji: '🍎',   color: const Color(0xFFF97316), words: _food);
    addDeck(slug: 'travel',   emoji: '✈️',   color: const Color(0xFF0EA5E9), words: _travel);
    addDeck(slug: 'colours',  emoji: '🎨',   color: const Color(0xFFEC4899), words: _colours);
    addDeck(slug: 'family',   emoji: '👨‍👩‍👧', color: const Color(0xFF8B5CF6), words: _family);
    addDeck(slug: 'time',     emoji: '🗓️',   color: const Color(0xFFF59E0B), words: _timeAndDays);

    return (decks: decks, cards: cards);
  }
}
