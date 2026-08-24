import 'package:flutter/material.dart';
import '../data/api/vocabgrid_user_api.dart';
import '../data/deck_store.dart';
import '../data/language_store.dart';
import '../l10n/app_localizations.dart';
import '../models/app_models.dart';
import 'language_setup_sheet.dart';

/// Opens the study-topics editor for [profile] and reports the updated
/// profile via [onProfileChanged]. Shared by Profile's "Study Categories"
/// row and Home's "Your Topics" edit action so both stay in sync.
///
/// This used to be its own picker writing to `PUT /api/User/categories`.
/// It now reuses [promptLanguageSetup] — the same sheet a newly chosen
/// language opens with — for one reason: the library is built from the
/// topic selection, and the endpoint that saves the selection is the one
/// that rebuilds it. Two paths meant a selection could be saved while the
/// decks stayed as they were, which is exactly the drift the learner sees
/// as "I unpicked Food but the Food deck is still here".
///
/// A failed load is reported with a retry action rather than a dead-end
/// message: the fetch fails for ordinary reasons (the server restarting, a
/// dropped connection) and the old flow left no way forward but backing out
/// of the screen.
Future<void> editCategories(
  BuildContext context, {
  required UserProfile profile,
  required ValueChanged<UserProfile> onProfileChanged,
}) async {
  final l10n = AppLocalizations.of(context);
  final languageCode = LanguageStore.code ?? profile.targetLanguageCode;

  if (languageCode.isEmpty) {
    // No target language yet, so there is no library to shape and nowhere
    // to save the topics against.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileLoadCategoriesFailed)));
    return;
  }

  final allCategories = await userApi.getCategories();
  if (!context.mounted) return;

  // An empty list is indistinguishable from "the fetch failed" (the API
  // never throws), so don't open a picker with nothing in it — opening it
  // anyway would let Save silently wipe the real server-side selection.
  if (allCategories.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.profileLoadCategoriesFailed),
        action: SnackBarAction(
          label: l10n.commonTryAgain,
          onPressed: () => editCategories(context, profile: profile, onProfileChanged: onProfileChanged),
        ),
        duration: const Duration(seconds: 6),
      ),
    );
    return;
  }

  // Preselect from the language profile rather than a second network call:
  // LanguageStore already holds this language's saved topics, and one less
  // request is one less way to open an empty-looking picker.
  final selected = LanguageStore.current?.categoryIds.toSet() ??
      allCategories.where((c) => profile.categories.contains(c.name)).map((c) => c.id).toSet();

  final saved = await promptLanguageSetup(
    context,
    languageCode: languageCode,
    languageName: profile.targetLanguage,
    initialLevel: profile.targetLevel,
    initialCategoryIds: selected,
    categories: allCategories,
  );
  if (!context.mounted || !saved) return;

  final savedIds = LanguageStore.current?.categoryIds.toSet() ?? selected;
  final categoryNames = allCategories.where((c) => savedIds.contains(c.id)).map((c) => c.name).toList();
  onProfileChanged(profile.copyWith(categories: categoryNames));

  // The server rebuilt the library to match the new selection, so the local
  // copy is stale the moment the sheet closes.
  await DeckStore.refresh();
}
