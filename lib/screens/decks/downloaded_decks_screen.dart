import 'package:flutter/material.dart';

import '../../data/deck_store.dart';
import '../../data/downloaded_decks.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/deck_title.dart';
import '../study/study_session_screen.dart';
import 'deck_detail_screen.dart';

/// The decks kept on this device for offline study.
///
/// A section of its own rather than a badge scattered through the library:
/// "can I study on the train tomorrow" is a question about a specific set of
/// decks, and the answer should be one screen, not an audit of every tile.
///
/// The decks themselves are not duplicated here — this reads the same
/// [DeckStore] the library does, filtered by [DownloadedDecks]. A deck that
/// disappears from the library (deleted, or belonging to another language)
/// disappears from here too, which is the honest answer: there is nothing
/// left to study.
class DownloadedDecksScreen extends StatelessWidget {
  const DownloadedDecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.downloadedDecksTitle)),
      body: SafeArea(
        top: false,
        // Two sources: which decks exist, and which of them are downloaded.
        child: ValueListenableBuilder<int>(
          valueListenable: DeckStore.revision,
          builder: (context, _, __) => ValueListenableBuilder<int>(
            valueListenable: DownloadedDecks.revision,
            builder: (context, _, __) => _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final decks = DeckStore.decks.where((d) => DownloadedDecks.contains(d.id)).toList();

    if (decks.isEmpty) return const _EmptyDownloads();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          l10n.downloadedDecksCount(decks.length),
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final deck in decks) _DownloadedDeckCard(deck: deck),
      ],
    );
  }
}

class _EmptyDownloads extends StatelessWidget {
  const _EmptyDownloads();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_download_outlined, size: 56, color: colors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.downloadedDecksEmpty, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.downloadedDecksEmptyHelp,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadedDeckCard extends StatelessWidget {
  const _DownloadedDeckCard({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final cardCount = DeckStore.cardCountOf(deck.id);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DeckDetailScreen(deckId: deck.id)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeckTitle(
                        deck: deck,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(l10n.decksCardCount(cardCount), style: TextStyle(color: colors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.downloadedDecksRemove,
                onPressed: () async {
                  await DeckStore.removeDownload(deck.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.deckDownloadRemoved)),
                  );
                },
                icon: Icon(Icons.delete_outline_rounded, size: 20, color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.offline_pin_rounded, size: 16, color: colors.success),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.deckDownloaded,
                  style: TextStyle(color: colors.success, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StudySessionScreen(deck: deck)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(l10n.libraryStudyThisDeck),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
