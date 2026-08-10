import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';

/// "Add New Card" / "Edit Card": deck picker, front/back fields, optional
/// example sentence and image URL. Pass [editingCard] to pre-fill the form
/// and update that card in place instead of creating a new one.
class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key, this.initialDeckId, this.editingCard});

  final String? initialDeckId;
  final FlashCard? editingCard;

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  late final _frontController = TextEditingController(text: widget.editingCard?.term);
  late final _backController = TextEditingController(text: widget.editingCard?.translation);
  late final _exampleController = TextEditingController(text: widget.editingCard?.exampleSentence);
  late final _imageUrlController = TextEditingController(text: widget.editingCard?.imageUrl);
  late String _deckId = widget.editingCard?.deckId ?? widget.initialDeckId ?? MockData.decks.first.id;

  bool get _isEditing => widget.editingCard != null;

  /// Only accept an absolute http(s) URL; anything else would silently fail
  /// to load later on the answer card.
  String? get _imageUrlError {
    final raw = _imageUrlController.text.trim();
    if (raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Enter a full image URL starting with http:// or https://';
    }
    return null;
  }

  String? get _imageUrlValue {
    final raw = _imageUrlController.text.trim();
    return raw.isEmpty ? null : raw;
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _exampleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isEditing) {
      MockData.updateCard(
        FlashCard(
          id: widget.editingCard!.id,
          deckId: _deckId,
          term: _frontController.text.trim(),
          translation: _backController.text.trim(),
          exampleSentence: _exampleController.text.trim(),
          strength: widget.editingCard!.strength,
          reviewCount: widget.editingCard!.reviewCount,
          imageUrl: _imageUrlValue,
        ),
      );
    } else {
      MockData.addCard(
        FlashCard(
          id: 'card_${DateTime.now().microsecondsSinceEpoch}',
          deckId: _deckId,
          term: _frontController.text.trim(),
          translation: _backController.text.trim(),
          exampleSentence: _exampleController.text.trim(),
          strength: MemoryStrength.learning,
          imageUrl: _imageUrlValue,
        ),
      );
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add New Card'),
        actions: [IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.close_rounded))],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DECK *', style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11)),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _deckId,
                items: [for (final d in MockData.decks) DropdownMenuItem(value: d.id, child: Text(d.name))],
                onChanged: (v) => setState(() => _deckId = v ?? _deckId),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _label(colors, 'FRONT (TARGET WORD) *')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _label(colors, 'BACK (TRANSLATION) *')),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(controller: _frontController, decoration: const InputDecoration(hintText: 'e.g. Bonjour')),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(controller: _backController, decoration: const InputDecoration(hintText: 'e.g. Hello')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _label(colors, 'EXAMPLE SENTENCE'),
              const SizedBox(height: AppSpacing.sm),
              TextField(controller: _exampleController, maxLines: 3, decoration: const InputDecoration(hintText: 'Write an example sentence...')),
              const SizedBox(height: AppSpacing.lg),
              _label(colors, 'IMAGE URL'),
              const SizedBox(height: AppSpacing.sm),
              AnimatedBuilder(
                animation: _imageUrlController,
                builder: (context, _) => TextField(
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(hintText: 'https://...', errorText: _imageUrlError),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AnimatedBuilder(
                animation: Listenable.merge([_frontController, _backController, _imageUrlController]),
                builder: (context, _) {
                  final incomplete = _frontController.text.trim().isEmpty || _backController.text.trim().isEmpty;
                  return PrimaryButton(
                    label: _isEditing ? 'Save Changes' : 'Add Card',
                    onPressed: incomplete || _imageUrlError != null ? null : _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(AppColorsExt colors, String text) =>
      Text(text, style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11));
}
