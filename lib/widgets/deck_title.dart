import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';

/// A deck's name in the language being learned, with its meaning in the
/// learner's own language beside it in smaller type — "Wissenschaft (Bilim)".
///
/// The target-language name stays primary: reading it is the first small
/// contact with the language being learned, and translating the title away
/// would remove that. But a beginner cannot be expected to know what
/// "Wissenschaft" is, and a library of eight decks they can't read is a
/// library they can't navigate. The parenthetical answers that without
/// taking the contact away.
///
/// The native name is omitted entirely when the server has none — a deck the
/// learner created and named themselves, or a template with no label in
/// their language. An empty "()" would be worse than nothing.
class DeckTitle extends StatelessWidget {
  const DeckTitle({
    super.key,
    required this.deck,
    required this.style,
    this.nativeColor,
    this.maxLines = 1,
  });

  final Deck deck;

  /// Style for the target-language name. The native name derives from it:
  /// same family, ~0.78x the size, normal weight.
  final TextStyle style;

  /// Colour for the parenthetical. Defaults to the muted text colour; pass
  /// one explicitly on coloured backgrounds (the gradient header), where the
  /// theme's muted grey would disappear.
  final Color? nativeColor;

  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final native = deck.nativeName;
    final baseSize = style.fontSize ?? 14;

    if (native == null || native.isEmpty) {
      return Text(deck.name, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    // One Text with two spans rather than a Row: the parenthetical has to
    // wrap and ellipsize together with the name, and a Row would let the two
    // halves be truncated independently.
    return Text.rich(
      TextSpan(
        text: deck.name,
        style: style,
        children: [
          TextSpan(
            text: '  ($native)',
            style: style.copyWith(
              fontSize: baseSize * 0.78,
              fontWeight: FontWeight.w500,
              color: nativeColor ?? colors.textMuted,
            ),
          ),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
