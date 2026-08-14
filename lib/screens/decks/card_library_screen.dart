import 'package:flutter/material.dart';
import '../../data/deck_store.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/refreshable.dart';
import '../../widgets/status_indicators.dart';
import '../study/study_session_screen.dart';
import 'add_word_screen.dart';

/// Lists every card, optionally scoped to a [deck], with search + deck
/// filter, edit/delete actions per row, and a "Study This Deck" CTA.
class CardLibraryScreen extends StatefulWidget {
  const CardLibraryScreen({super.key, this.deck});

  final Deck? deck;

  @override
  State<CardLibraryScreen> createState() => _CardLibraryScreenState();
}

class _CardLibraryScreenState extends State<CardLibraryScreen> {
  String _query = '';
  late String? _deckFilter = widget.deck?.id;

  // Add/edit/delete all rebuild via [DeckStore.revision], so these only need
  // to open the right screen — no manual setState.
  void _addCard() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddWordScreen(initialDeckId: _deckFilter)));
  }

  void _editCard(FlashCard card) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddWordScreen(editingCard: card)));
  }

  Future<void> _deleteCard(FlashCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text('"${card.term}" will be permanently removed from your library.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: context.appColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await DeckStore.removeCard(card.id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't delete the card. Please try again.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${card.term}" deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Library'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: TextButton.icon(
              onPressed: _addCard,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Card'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<int>(
          valueListenable: DeckStore.revision,
          builder: (context, _, __) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.appColors;
    final cards = DeckStore.cards.where((c) {
      final matchesDeck = _deckFilter == null || c.deckId == _deckFilter;
      final matchesQuery = _query.isEmpty ||
          c.term.toLowerCase().contains(_query.toLowerCase()) ||
          c.translation.toLowerCase().contains(_query.toLowerCase());
      return matchesDeck && matchesQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'Search front or back...', prefixIcon: Icon(Icons.search_rounded)),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _deckFilter,
                      isExpanded: true,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Decks')),
                        for (final d in DeckStore.decks) DropdownMenuItem(value: d.id, child: Text(d.name, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _deckFilter = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Items: ${cards.length}', style: TextStyle(color: colors.textMuted, fontSize: 12)),
                  Text(_deckFilter == null ? 'Showing all' : 'Filtered by deck', style: TextStyle(color: colors.textMuted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Refreshable(
            child: cards.isEmpty
                // Needs to stay scrollable, otherwise there is nothing for the
                // pull gesture to grab onto on an empty list.
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [_EmptyCards(query: _query, onAddCard: _addCard)],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => _CardRow(card: cards[i], onEdit: () => _editCard(cards[i]), onDelete: () => _deleteCard(cards[i])),
                  ),
          ),
        ),
        if (widget.deck != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cards.isEmpty
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudySessionScreen(deck: widget.deck))),
                icon: const Icon(Icons.style_rounded),
                label: const Text('Study This Deck'),
              ),
            ),
          ),
      ],
    );
  }
}

/// Distinguishes "this deck has no cards yet" from "your search matched
/// nothing" — the screen used to show a bare "No cards found" for both.
class _EmptyCards extends StatelessWidget {
  const _EmptyCards({required this.query, required this.onAddCard});

  final String query;
  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final searching = query.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              searching ? Icons.search_off_rounded : Icons.style_outlined,
              size: 52,
              color: colors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              searching ? 'No cards match "$query"' : 'No cards here yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              searching
                  ? 'Check the spelling, or clear the deck filter to search everywhere.'
                  : 'Add your first word and it will show up in your next study session.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, height: 1.5),
            ),
            if (!searching) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 200,
                child: PrimaryButton(label: 'Add a card', icon: Icons.add_rounded, onPressed: onAddCard),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.card, required this.onEdit, required this.onDelete});

  final FlashCard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // A card can outlive its deck (deck removed while the card list is open),
    // so fall back instead of letting firstWhere throw.
    final deck = DeckStore.decks.where((d) => d.id == card.deckId).firstOrNull;
    final deckName = deck?.name ?? 'Unknown deck';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: colors.border)),
      child: Row(
        children: [
          SpeakerButton(text: card.term),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(card.term, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary))),
                    MemoryStrengthPill(strength: card.strength),
                  ],
                ),
                const SizedBox(height: 2),
                Text(card.translation, style: TextStyle(color: colors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text('$deckName · ${card.reviewCount} reviews', style: TextStyle(color: colors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit card',
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
          ),
          IconButton(
            tooltip: 'Delete card',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, size: 18, color: colors.danger),
          ),
        ],
      ),
    );
  }
}
