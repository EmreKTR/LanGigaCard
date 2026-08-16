import 'package:flutter/material.dart';
import '../../data/deck_store.dart';
import '../../models/app_models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/refreshable.dart';
import '../study/quiz_screen.dart';
import '../study/study_session_screen.dart';
import 'card_library_screen.dart';
import 'deck_detail_screen.dart';

/// "My Decks": due-today banner, search, and a list of deck cards each with
/// a mastery bar, Study/Browse actions and a rename/delete menu.
class DeckDashboardScreen extends StatefulWidget {
  const DeckDashboardScreen({super.key});

  @override
  State<DeckDashboardScreen> createState() => _DeckDashboardScreenState();
}

class _DeckDashboardScreenState extends State<DeckDashboardScreen> {
  String _query = '';

  Future<void> _createDeck() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DeckEditorSheet(),
    );
  }

  Future<void> _renameDeck(Deck deck) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeckEditorSheet(editing: deck),
    );
  }

  Future<void> _deleteDeck(Deck deck) async {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final cardCount = DeckStore.cards.where((c) => c.deckId == deck.id).length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.decksDeleteConfirm(deck.name)),
        content: Text(
          cardCount == 0
              ? l10n.decksDeleteEmpty
              : l10n.decksDeleteWithCards(cardCount),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete, style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await DeckStore.removeDeck(deck.id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.decksDeleteFailed)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.decksDeleted(deck.name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.decksTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: TextButton.icon(
              onPressed: _createDeck,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.decksNewDeck),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<int>(
          valueListenable: DeckStore.revision,
          builder: (context, _, __) => Refreshable(child: _buildDeckList(context)),
        ),
      ),
    );
  }

  Widget _buildDeckList(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final decks = DeckStore.decks.where((d) => d.name.toLowerCase().contains(_query.toLowerCase())).toList();
    final totalDue = DeckStore.decks.fold<int>(0, (sum, d) => sum + d.dueCount);

    return ListView(
      // Keeps pull-to-refresh usable even when the list is short.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.decksSummary(DeckStore.decks.length, totalDue), style: TextStyle(color: colors.textMuted, fontSize: 13)),
        const SizedBox(height: AppSpacing.lg),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudySessionScreen())),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colors.primaryDark, colors.primary]),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.decksDueForReview(totalDue), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      Text(l10n.decksSortedByUrgency, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          decoration: InputDecoration(hintText: l10n.decksSearchHint, prefixIcon: const Icon(Icons.search_rounded)),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (decks.isEmpty)
          _EmptyDecks(query: _query, onCreate: _createDeck)
        else
          for (final deck in decks)
            _DeckCard(
              deck: deck,
              onRename: () => _renameDeck(deck),
              onDelete: () => _deleteDeck(deck),
            ),
      ],
    );
  }
}

/// Shown when there are no decks at all, or when a search matches nothing.
class _EmptyDecks extends StatelessWidget {
  const _EmptyDecks({required this.query, required this.onCreate});

  final String query;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final searching = query.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            searching ? Icons.search_off_rounded : Icons.library_books_outlined,
            size: 56,
            color: colors.textMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            searching ? l10n.decksNoMatch(query) : l10n.decksNoneYet,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            searching
                ? l10n.decksTryDifferentSearch
                : l10n.decksEmptyHelp,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 220,
            child: PrimaryButton(label: l10n.decksCreateADeck, icon: Icons.add_rounded, onPressed: onCreate),
          ),
        ],
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck, required this.onRename, required this.onDelete});

  final Deck deck;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    // cardCount is counted from the cards themselves — trivially accurate
    // after any real refresh. studyable has no server-side equivalent, so it
    // stays a local best-effort approximation. dueCount and mastery, though,
    // ARE already correctly fetched from the server onto the Deck object
    // (Deck.dueCount/masteryPercent) — reading them here instead of
    // recomputing from locally-cached card strength avoids showing "0%
    // mastered, everything due" right after a fresh login, before any card
    // has been re-rated in this session.
    final cardCount = DeckStore.cardCountOf(deck.id);
    final dueCount = deck.dueCount;
    final studyable = DeckStore.studyableCountOf(deck.id);
    final mastery = deck.masteryPercent;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: colors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The title block is the tap target for the deck's detail page —
              // the whole card can't be one, since it holds its own buttons.
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DeckDetailScreen(deckId: deck.id)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deck.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(deck.description, style: TextStyle(color: colors.textMuted, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              if (dueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(color: colors.danger.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text('$dueCount due', style: TextStyle(color: colors.danger, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              PopupMenuButton<String>(
                tooltip: l10n.decksOptions,
                icon: Icon(Icons.more_vert_rounded, size: 20, color: colors.textMuted),
                onSelected: (value) => switch (value) {
                  'quiz' => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => QuizScreen(deck: deck)),
                    ),
                  'rename' => onRename(),
                  _ => onDelete(),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'quiz',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.quiz_outlined, size: 20),
                      title: Text(l10n.decksQuizThis),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined, size: 20),
                      title: Text(l10n.decksRename),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline_rounded, size: 20, color: colors.danger),
                      title: Text(l10n.decksDelete, style: TextStyle(color: colors.danger)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _tag(colors, l10n.decksCardCount(cardCount), colors.surfaceElevated, colors.textSecondary),
              if (dueCount > 0) _tag(colors, l10n.decksReviewDue, colors.danger.withValues(alpha: 0.14), colors.danger),
              _tag(colors, l10n.decksReviewCount(deck.reviewCount), colors.surfaceElevated, colors.textSecondary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.decksMastery, style: TextStyle(color: colors.textMuted, fontSize: 12)),
              Text('$mastery%', style: TextStyle(color: deck.accentColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: mastery / 100,
              minHeight: 6,
              backgroundColor: colors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation(deck.accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: studyable > 0 ? l10n.decksStudyCards(studyable) : l10n.decksAllCaughtUp,
                  onPressed: studyable == 0
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudySessionScreen(deck: deck))),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CardLibraryScreen(deck: deck))),
                  child: Text(l10n.decksBrowse),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(AppColorsExt colors, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

/// Create-or-rename sheet. Pass [editing] to prefill it and save over that
/// deck instead of appending a new one.
class _DeckEditorSheet extends StatefulWidget {
  const _DeckEditorSheet({this.editing});

  final Deck? editing;

  @override
  State<_DeckEditorSheet> createState() => _DeckEditorSheetState();
}

/// The description placeholder is localized and resolved at render time now,
/// so it can never be persisted. This is the English string it used to be,
/// kept only so a deck that stored it before the change still opens with an
/// empty description field rather than the literal placeholder.
const _legacyNoDescription = 'No description yet';

class _DeckEditorSheetState extends State<_DeckEditorSheet> {
  late final _titleController = TextEditingController(text: widget.editing?.name);
  late final _descController = TextEditingController(
    // The placeholder used for decks created without a description shouldn't
    // come back as literal text to edit.
    text: widget.editing?.description == _legacyNoDescription ? '' : widget.editing?.description,
  );

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    final ok = _isEditing
        ? await DeckStore.updateDeck(widget.editing!.id, title: title, description: description)
        : await DeckStore.addDeck(title: title, description: description);

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? l10n.decksSaveFailed : l10n.decksCreateFailed)),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_isEditing ? l10n.decksRenameTitle : l10n.decksCreateTitle, style: Theme.of(context).textTheme.titleLarge),
                ),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedBuilder(
              animation: _titleController,
              builder: (context, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.decksTitleLabel, style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11)),
                  Text('${_titleController.text.length} / 50', style: TextStyle(color: colors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _titleController,
              maxLength: 50,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              decoration: InputDecoration(hintText: l10n.decksTitleHint),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.decksDescriptionLabel, style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.decksDescriptionHint),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedBuilder(
              animation: _titleController,
              builder: (context, _) => PrimaryButton(
                label: _isEditing ? l10n.decksSaveChanges : l10n.decksCreateDeck,
                onPressed: _titleController.text.trim().isEmpty ? null : _save,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
