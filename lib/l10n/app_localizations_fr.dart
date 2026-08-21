// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appLanguageTitle => 'Choisissez la langue de l\'application';

  @override
  String get appLanguageSubtitle =>
      'Choisissez la langue dans laquelle utiliser LanGigaCards.';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonSignIn => 'Se connecter';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonGetStarted => 'Commencer';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonRequiredField => 'Ce champ est obligatoire';

  @override
  String get commonSomethingWrong =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get commonNetworkError =>
      'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';

  @override
  String get onboardingSlide1Title => 'Apprenez avec des cartes';

  @override
  String get onboardingSlide1Body =>
      'Maîtrisez le vocabulaire grâce à notre système de répétition espacée. Révisez chaque carte au bon moment pour mieux mémoriser.';

  @override
  String get onboardingSlide2Title => 'Suivez vos progrès';

  @override
  String get onboardingSlide2Body =>
      'Visualisez votre parcours avec des statistiques claires. Regardez votre vocabulaire grandir jour après jour, avec séries et récompenses.';

  @override
  String get onboardingSlide3Title => 'Atteignez vos objectifs';

  @override
  String get onboardingSlide3Body =>
      'Fixez des objectifs quotidiens personnalisés et restez motivé. Notre algorithme s\'adapte à votre rythme pour un apprentissage sans effort.';

  @override
  String get onboardingHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle =>
      'Connectez-vous pour poursuivre votre apprentissage';

  @override
  String get loginEmailLabel => 'Adresse e-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginRememberMe => 'Se souvenir de moi';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginOrContinueWith => 'ou continuer avec';

  @override
  String get loginNoAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get loginInvalidCredentials =>
      'E-mail ou mot de passe incorrect. Créez un compte si vous n\'en avez pas encore.';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerBackToSignIn => 'Retour à la connexion';

  @override
  String get registerSubtitle =>
      'Vos informations — les langues et préférences viennent ensuite.';

  @override
  String get registerFirstName => 'Prénom';

  @override
  String get registerLastName => 'Nom';

  @override
  String get registerEmail => 'Adresse e-mail';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerPasswordHint => '8 caractères minimum';

  @override
  String get registerConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerConfirmHint => 'Saisissez à nouveau votre mot de passe';

  @override
  String get registerInvalidEmail =>
      'Veuillez saisir une adresse e-mail valide';

  @override
  String get registerPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get registerPasswordsDontMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get registerEmailTaken => 'Un compte existe déjà avec cet e-mail.';

  @override
  String get verifyTitle => 'Vérifiez votre e-mail';

  @override
  String verifySubtitle(String email) {
    return 'Nous avons envoyé un code à 6 chiffres à $email. Saisissez-le ci-dessous pour confirmer votre compte.';
  }

  @override
  String get verifyNoCode => 'Vous n\'avez pas reçu de code ?';

  @override
  String get verifyResend => 'Renvoyer le code';

  @override
  String get verifySending => 'Envoi…';

  @override
  String get verifyAction => 'Vérifier';

  @override
  String get verifySkip => 'Ignorer pour l\'instant';

  @override
  String verifyEnterAllDigits(int count) {
    return 'Saisissez les $count chiffres';
  }

  @override
  String get verifyIncorrect => 'Code incorrect, veuillez réessayer';

  @override
  String get verifyTooManyAttempts =>
      'Trop de tentatives. Touchez « Renvoyer le code » pour en obtenir un nouveau.';

  @override
  String get verifyResent => 'Un nouveau code a été envoyé à votre e-mail';

  @override
  String get forgotTitle => 'Réinitialiser votre mot de passe';

  @override
  String get forgotSubtitle =>
      'Saisissez l\'adresse e-mail utilisée à l\'inscription et nous vous enverrons un lien pour choisir un nouveau mot de passe.';

  @override
  String get forgotEmailLabel => 'Adresse e-mail';

  @override
  String get forgotInvalidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get forgotSend => 'Envoyer le lien';

  @override
  String get forgotCheckInbox => 'Consultez votre boîte de réception';

  @override
  String forgotSentTo(String email) {
    return 'Si un compte existe pour $email, le lien de réinitialisation est en route.';
  }

  @override
  String get forgotNoMailServer =>
      'Cette version n\'a pas de serveur de messagerie connecté, aucun e-mail n\'est donc réellement envoyé.';

  @override
  String get forgotUseDifferent => 'Utiliser une autre adresse';

  @override
  String get navHome => 'Accueil';

  @override
  String get navDecks => 'Paquets';

  @override
  String get navQuiz => 'Quiz';

  @override
  String get navStats => 'Statistiques';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeGreetingMorning => 'Bonjour,';

  @override
  String get homeGreetingAfternoon => 'Bon après-midi,';

  @override
  String get homeGreetingEvening => 'Bonsoir,';

  @override
  String get homeContinueLearning => 'CONTINUER L\'APPRENTISSAGE';

  @override
  String homeCardsDue(int count) {
    return '$count cartes à revoir';
  }

  @override
  String homeMinGoal(int minutes) {
    return 'objectif $minutes min';
  }

  @override
  String get homeFinishSetup =>
      'Terminez la configuration de votre profil pour recevoir votre premier paquet.';

  @override
  String get homeWords => 'Mots';

  @override
  String get homeAccuracy => 'Précision';

  @override
  String get homeStreak => 'Série';

  @override
  String get homeContinueQuizLabel => 'QUIZ';

  @override
  String get homeContinueQuizTitle => 'Continuer le Quiz';

  @override
  String homeContinueQuizSubtitle(String deck, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$deck · $_temp0';
  }

  @override
  String homeReviewDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à revoir',
      one: '1 à revoir',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewDoneBadge => 'Terminé';

  @override
  String get homeYourTopics => 'Vos thèmes';

  @override
  String get homeRecentlyLearned => 'Appris récemment';

  @override
  String get homeSeeAll => 'Tout voir';

  @override
  String get shellProfileLoadFailed => 'Impossible de charger votre profil';

  @override
  String get shellCheckConnection => 'Vérifiez votre connexion et réessayez.';

  @override
  String get shellSyncDroppedOne =>
      '1 modification n\'a pas pu être enregistrée et a été abandonnée.';

  @override
  String shellSyncDroppedMany(int count) {
    return '$count modifications n\'ont pas pu être enregistrées et ont été abandonnées.';
  }

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get decksTitle => 'Mes paquets';

  @override
  String get decksNewDeck => 'Nouveau paquet';

  @override
  String decksSummary(int decks, int due) {
    return '$decks paquets · $due cartes à revoir aujourd\'hui';
  }

  @override
  String decksDueForReview(int count) {
    return '$count cartes à revoir';
  }

  @override
  String get decksSortedByUrgency =>
      'Triées par urgence · Touchez pour commencer';

  @override
  String get decksSearchHint => 'Rechercher des paquets...';

  @override
  String decksNoMatch(String query) {
    return 'Aucun paquet ne correspond à « $query »';
  }

  @override
  String get decksNoneYet => 'Aucun paquet pour l\'instant';

  @override
  String get decksTryDifferentSearch =>
      'Essayez une autre recherche ou créez un paquet portant ce nom.';

  @override
  String get decksEmptyHelp =>
      'Les paquets regroupent les mots que vous voulez apprendre. Créez le premier pour commencer.';

  @override
  String get decksCreateADeck => 'Créer un paquet';

  @override
  String get decksOptions => 'Options du paquet';

  @override
  String get decksQuizThis => 'Tester ce paquet';

  @override
  String get decksRename => 'Renommer le paquet';

  @override
  String get decksDelete => 'Supprimer le paquet';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => 'À revoir';

  @override
  String decksReviewCount(int count) {
    return '$count révisions';
  }

  @override
  String get decksMastery => 'Maîtrise';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Étudier $count cartes',
      one: 'Étudier 1 carte',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'Tout est à jour';

  @override
  String get decksBrowse => 'Parcourir';

  @override
  String get decksRenameTitle => 'Renommer le paquet';

  @override
  String get decksCreateTitle => 'Créer un paquet';

  @override
  String get decksTitleLabel => 'TITRE *';

  @override
  String get decksTitleHint => 'ex. Bases du français';

  @override
  String get decksDescriptionLabel => 'DESCRIPTION (FACULTATIF)';

  @override
  String get decksDescriptionHint => 'Décrivez le contenu de ce paquet...';

  @override
  String get decksSaveChanges => 'Enregistrer';

  @override
  String get decksCreateDeck => 'Créer le paquet';

  @override
  String get decksNoDescription => 'Pas encore de description';

  @override
  String decksDeleteConfirm(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get decksDeleteEmpty => 'Ce paquet est vide et sera supprimé.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Le paquet et ses $count cartes seront supprimés.',
      one: 'Le paquet et sa carte seront supprimés.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '« $name » supprimé';
  }

  @override
  String get decksCreateFailed =>
      'Impossible de créer le paquet. Veuillez réessayer.';

  @override
  String get decksDeleteFailed =>
      'Impossible de supprimer le paquet. Veuillez réessayer.';

  @override
  String get decksSaveFailed =>
      'Impossible d\'enregistrer les modifications. Veuillez réessayer.';

  @override
  String get quizDecksTitle => 'Decks de Quiz';

  @override
  String get quizDecksStartQuiz => 'Démarrer le Quiz';

  @override
  String get quizDecksEmpty => 'Aucun deck pour l\'instant';

  @override
  String get quizDecksEmptyHelp =>
      'Créez un deck depuis l\'onglet Decks, puis revenez ici pour vous tester dessus.';

  @override
  String quizDecksNotEnoughCards(int min) {
    return 'Ajoutez au moins $min cartes pour débloquer le quiz';
  }

  @override
  String get detailNotFound => 'Ce paquet n\'existe plus';

  @override
  String get detailBackToDecks => 'Retour aux paquets';

  @override
  String get detailProgress => 'PROGRESSION';

  @override
  String get detailMastered => 'Maîtrisées';

  @override
  String get detailLearning => 'En cours';

  @override
  String get detailCards => 'Cartes';

  @override
  String get detailReviews => 'Révisions';

  @override
  String get detailBrowseAll => 'Tout parcourir';

  @override
  String detailMore(int count) {
    return '+ $count de plus';
  }

  @override
  String get detailBack => 'Retour';

  @override
  String get detailAddCardTooltip => 'Ajouter une carte à ce paquet';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label : $count sur $total cartes';
  }

  @override
  String get detailEmpty => 'Ce paquet est vide';

  @override
  String get detailEmptyHelp =>
      'Ajoutez quelques mots et vous pourrez commencer tout de suite.';

  @override
  String get detailAddCard => 'Ajouter une carte';

  @override
  String get cardEditTitle => 'Modifier la carte';

  @override
  String get cardAddTitle => 'Nouvelle carte';

  @override
  String get cardDeckLabel => 'PAQUET *';

  @override
  String get cardFrontLabel => 'RECTO (MOT CIBLE) *';

  @override
  String get cardBackLabel => 'VERSO (TRADUCTION) *';

  @override
  String get cardFrontHint => 'ex. Bonjour';

  @override
  String get cardBackHint => 'ex. Hello';

  @override
  String get cardExampleLabel => 'PHRASE D\'EXEMPLE';

  @override
  String get cardExampleHint => 'Écrivez une phrase d\'exemple...';

  @override
  String get cardImageLabel => 'URL DE L\'IMAGE';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError =>
      'Saisissez une URL d\'image complète commençant par http:// ou https://';

  @override
  String get cardAdd => 'Ajouter la carte';

  @override
  String get cardAddFailed =>
      'Impossible d\'ajouter la carte. Veuillez réessayer.';

  @override
  String get libraryTitle => 'Bibliothèque de cartes';

  @override
  String get librarySearchHint => 'Rechercher recto ou verso...';

  @override
  String get libraryAllDecks => 'Tous les paquets';

  @override
  String libraryTotalItems(int count) {
    return 'Total : $count';
  }

  @override
  String get libraryShowingAll => 'Tout afficher';

  @override
  String get libraryFilteredByDeck => 'Filtré par paquet';

  @override
  String get libraryStudyThisDeck => 'Étudier ce paquet';

  @override
  String libraryNoMatch(String query) {
    return 'Aucune carte ne correspond à « $query »';
  }

  @override
  String get libraryNoneYet => 'Aucune carte ici pour l\'instant';

  @override
  String get libraryCheckSpelling =>
      'Vérifiez l\'orthographe ou retirez le filtre de paquet pour chercher partout.';

  @override
  String get libraryAddFirst =>
      'Ajoutez votre premier mot et il apparaîtra à votre prochaine session.';

  @override
  String get libraryUnknownDeck => 'Paquet inconnu';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · $count révisions';
  }

  @override
  String get libraryEditCard => 'Modifier la carte';

  @override
  String get libraryDeleteCard => 'Supprimer la carte';

  @override
  String get libraryDeleteConfirmTitle => 'Supprimer la carte ?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '« $term » sera définitivement retirée de votre bibliothèque.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '« $term » supprimée';
  }

  @override
  String get libraryDeleteFailed =>
      'Impossible de supprimer la carte. Veuillez réessayer.';

  @override
  String get studyAllDecks => 'Tous les paquets';

  @override
  String studyDailyReview(String deck) {
    return 'Révision du jour · $deck';
  }

  @override
  String studyWordHint(String term) {
    return 'Mot : $term. Touchez pour afficher la traduction.';
  }

  @override
  String studyAnswerHint(String translation) {
    return 'Réponse : $translation. Touchez pour revoir le mot. Balayez pour passer ou notez ci-dessous.';
  }

  @override
  String get studyRateBelow =>
      'Notez ci-dessous, ou balayez pour passer sans noter';

  @override
  String get studyRecallHint =>
      'Rappelez-vous la traduction, puis retournez pour vérifier';

  @override
  String get studyNothingDue => 'Rien à réviser pour le moment';

  @override
  String get studyBackToDecks => 'Retour aux paquets';

  @override
  String get studyQueueFailed => 'Impossible de charger votre file de révision';

  @override
  String get studyTapToSeeExample => '[ touchez pour voir l\'exemple ]';

  @override
  String get studyShowExample => 'Afficher la phrase d\'exemple';

  @override
  String get studyTapToReveal => 'Touchez pour afficher la traduction';

  @override
  String studyHearPronounced(String term) {
    return 'Écouter la prononciation de $term';
  }

  @override
  String get studyHearIt => 'Écouter';

  @override
  String get studyTranslationLabel => 'TRADUCTION';

  @override
  String get studyExampleLabel => 'EXEMPLE';

  @override
  String get studyImageFailed => 'L\'image n\'a pas pu être chargée';

  @override
  String get studyAllCaughtUp => 'Tout est à jour !';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous avez révisé les $count cartes du jour',
      one: 'Vous avez révisé la carte du jour',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => 'confiance';

  @override
  String get studyViewStats => 'Voir les stats';

  @override
  String get quizTimeUp => '⏰ Temps écoulé ! Voici la bonne réponse.';

  @override
  String quizProgress(int index, int total) {
    return 'Q$index sur $total';
  }

  @override
  String get quizFinish => 'Terminer';

  @override
  String get quizNextQuestion => 'Question suivante →';

  @override
  String get quizNotEnough => 'Pas assez de cartes pour un quiz';

  @override
  String quizNotEnoughAll(int min) {
    return 'Ajoutez au moins $min cartes aux traductions différentes et le quiz se construira tout seul.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck a besoin d\'au moins $min cartes aux traductions différentes pour être testé.';
  }

  @override
  String get quizBack => 'Retour';

  @override
  String get quizPerfect => 'Score parfait !';

  @override
  String get quizGreat => 'Beau travail !';

  @override
  String get quizNice => 'Bonne progression';

  @override
  String get quizKeepPractising => 'Continuez à pratiquer';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return 'Vous avez répondu correctement à $score sur $total';
  }

  @override
  String get quizScore => 'score';

  @override
  String get quizDone => 'Terminé';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsSubtitle => 'Votre apprentissage en chiffres';

  @override
  String get statsStreak => 'Série';

  @override
  String get statsReviews => 'Révisions';

  @override
  String get statsRecall => 'Mémorisation';

  @override
  String statsTodayDelta(int count) {
    return '+$count aujourd\'hui';
  }

  @override
  String get statsNoData => 'aucune donnée';

  @override
  String get statsHeatmap => 'Carte d\'apprentissage';

  @override
  String statsStreakSummary(int days, int total) {
    return 'série de $days jours · $total révisions enregistrées';
  }

  @override
  String statsReviewsLogged(int total) {
    return '$total révisions enregistrées';
  }

  @override
  String get statsLess => 'Moins';

  @override
  String get statsMore => 'Plus';

  @override
  String get statsNoActivity => 'Aucune activité pour l\'instant';

  @override
  String get statsLibraryBreakdown => 'Répartition de la bibliothèque';

  @override
  String get statsAchievements => 'Récompenses';

  @override
  String statsEarned(int earned, int total) {
    return '$earned / $total obtenues';
  }

  @override
  String get statsAddCards => 'Ajoutez des cartes pour voir votre progression';

  @override
  String get statsDaily => 'Jour';

  @override
  String get statsWeekly => 'Semaine';

  @override
  String get statsMonthly => 'Mois';

  @override
  String get statsChartDaily => 'Révisions, 7 derniers jours';

  @override
  String get statsChartWeekly => 'Révisions, 4 dernières semaines';

  @override
  String get statsChartMonthly => 'Révisions, 6 derniers mois';

  @override
  String statsChartTotal(int count) {
    return '$count au total';
  }

  @override
  String get profileStudyPreferences => 'Préférences d\'étude';

  @override
  String get profileNativeLanguage => 'Langue maternelle';

  @override
  String get profileTargetLanguage => 'Langue cible';

  @override
  String get profileLearningPurpose => 'Objectif d\'apprentissage';

  @override
  String get profileStudyCategories => 'Thèmes d\'étude';

  @override
  String get profileDailyGoal => 'Objectif quotidien';

  @override
  String get profileAppPreferences => 'Préférences de l\'application';

  @override
  String get profileDarkMode => 'Mode sombre';

  @override
  String get profileAppLanguage => 'Langue de l\'application';

  @override
  String get profileSoundEffects => 'Effets sonores';

  @override
  String get profileDailyReminder => 'Rappel quotidien';

  @override
  String get profileThemeColor => 'Couleur du thème';

  @override
  String get profileTextSize => 'Taille du texte';

  @override
  String get profileDifficultyMode => 'Mode de difficulté';

  @override
  String get profileEmailVerification => 'Vérification de l\'e-mail';

  @override
  String get profileVerified => 'Vérifié';

  @override
  String get profileNotVerified => 'Non vérifié';

  @override
  String get profileAccount => 'Compte';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profilePrivacySecurity => 'Confidentialité et sécurité';

  @override
  String get profileUpgradePremium => 'Passer à Premium';

  @override
  String get profileHelpSupport => 'Aide et assistance';

  @override
  String get profileLogOut => 'Se déconnecter';

  @override
  String get profileLogOutConfirm => 'Se déconnecter ?';

  @override
  String get profileLogOutBody =>
      'Vous devrez vous reconnecter pour continuer à apprendre.';

  @override
  String get profileNoneYet => 'Aucun pour l\'instant';

  @override
  String profileSelectedCount(int count) {
    return '$count sélectionnés';
  }

  @override
  String profileTopicsCount(int count) {
    return '$count thèmes';
  }

  @override
  String profileMinutes(int min) {
    return '$min min';
  }

  @override
  String get profileNative => 'Maternelle';

  @override
  String get profileEdit => 'Modifier';

  @override
  String get profileFullName => 'Nom complet';

  @override
  String get profileEmailAddress => 'Adresse e-mail';

  @override
  String get profileNameRequired => 'Le nom est obligatoire';

  @override
  String get profileEmailRequired => 'L\'e-mail est obligatoire';

  @override
  String get profileClose => 'Fermer';

  @override
  String get profileWhyLearning =>
      'Pourquoi apprenez-vous ? Choisissez tout ce qui s\'applique.';

  @override
  String get profileDecreaseGoal => 'Réduire l\'objectif quotidien';

  @override
  String get profileIncreaseGoal => 'Augmenter l\'objectif quotidien';

  @override
  String get profileYouSpeakThis => 'vous parlez cette langue';

  @override
  String get profileLearningThis => 'vous apprenez cette langue';

  @override
  String profileLevelBadge(int level) {
    return '⭐ Niveau $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ série de $days jours';
  }

  @override
  String get profileServerUnreachable =>
      'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';

  @override
  String get profileSaveNameFailed =>
      'Impossible d\'enregistrer votre nom. Veuillez réessayer.';

  @override
  String get profileSaveLanguageFailed =>
      'Impossible d\'enregistrer votre langue. Veuillez réessayer.';

  @override
  String get profileSaveGoalFailed =>
      'Impossible d\'enregistrer votre objectif quotidien. Veuillez réessayer.';

  @override
  String get profileSaveCategoriesFailed =>
      'Impossible d\'enregistrer vos thèmes. Veuillez réessayer.';

  @override
  String get profileSavePurposesFailed =>
      'Impossible d\'enregistrer vos objectifs. Veuillez réessayer.';

  @override
  String get profileLoadCategoriesFailed =>
      'Impossible de charger les thèmes. Vérifiez votre connexion et réessayez.';

  @override
  String get profileLoadPurposesFailed =>
      'Impossible de charger les objectifs. Vérifiez votre connexion et réessayez.';

  @override
  String wizardStep(int current, int total, String label) {
    return 'ÉTAPE $current SUR $total — $label';
  }

  @override
  String get wizardNativeLanguage => 'LANGUE MATERNELLE';

  @override
  String get wizardTargetLanguage => 'LANGUE CIBLE';

  @override
  String get wizardTargetLevel => 'NIVEAU DANS LA LANGUE CIBLE';

  @override
  String get wizardLearningPurpose => 'OBJECTIF D\'APPRENTISSAGE';

  @override
  String get wizardTopics => 'THÈMES ET CATÉGORIES';

  @override
  String get wizardAge => 'VOTRE ÂGE';

  @override
  String get wizardDailyGoal => 'OBJECTIF QUOTIDIEN';

  @override
  String get wizardNativeQuestion => 'Quelle est votre langue maternelle ?';

  @override
  String get wizardTargetQuestion => 'Quelle langue voulez-vous apprendre ?';

  @override
  String wizardLevelQuestion(String language) {
    return 'Quel est votre niveau actuel en $language ?';
  }

  @override
  String get wizardLevelHint =>
      'Choisissez ce qui vous semble juste — modifiable à tout moment.';

  @override
  String get wizardGoalQuestion =>
      'Combien de temps pouvez-vous consacrer par jour ?';

  @override
  String wizardSelectedHint(int count) {
    return '$count sélectionnés · Vous pourrez changer plus tard';
  }

  @override
  String get wizardNativePrefix => 'Maternelle : ';

  @override
  String get wizardStart => 'Commençons à apprendre 🚀';

  @override
  String get wizardLoadFailed =>
      'Impossible de charger vos options de configuration';

  @override
  String get wizardSaveFailed =>
      'Impossible d\'enregistrer vos thèmes ou votre objectif. Veuillez réessayer.';

  @override
  String get levelJustStarting => 'Je débute';

  @override
  String get levelJustStartingDesc => 'J\'apprends les bases';

  @override
  String get levelBeginner => 'Débutant';

  @override
  String get levelBeginnerDesc => 'Je connais quelques mots et expressions';

  @override
  String get levelIntermediate => 'Intermédiaire';

  @override
  String get levelIntermediateDesc => 'Je peux tenir une conversation simple';

  @override
  String get levelAdvanced => 'Avancé';

  @override
  String get levelAdvancedDesc => 'À l\'aise dans la plupart des situations';

  @override
  String get levelFluent => 'Courant';

  @override
  String get levelFluentDesc => 'Presque comme un natif';

  @override
  String get goalCasual => 'Tranquille';

  @override
  String get goalRegular => 'Régulier';

  @override
  String get goalIntense => 'Intensif';

  @override
  String goalWordsPerDay(int count) {
    return '~$count mots/jour';
  }

  @override
  String get helpSearchHint => 'Rechercher dans l\'aide...';

  @override
  String get helpFrequentlyAsked => 'QUESTIONS FRÉQUENTES';

  @override
  String helpNoMatch(String query) {
    return 'Aucun article ne correspond à « $query »';
  }

  @override
  String get helpStillStuck => 'TOUJOURS BLOQUÉ ?';

  @override
  String get helpEmailSupport => 'Assistance par e-mail';

  @override
  String get helpCommunityForum => 'Forum communautaire';

  @override
  String get helpReportProblem => 'Signaler un problème';

  @override
  String get helpTheCommunityForum => 'Le forum communautaire';

  @override
  String get helpProblemReporting => 'Le signalement de problèmes';

  @override
  String get helpReportHint => 'Décrivez ce qui s’est passé...';

  @override
  String get helpReportSend => 'Envoyer le rapport';

  @override
  String get helpReportEmpty => 'Veuillez d’abord décrire le problème';

  @override
  String get helpReportSent => 'Merci, votre rapport a été envoyé';

  @override
  String helpComingSoon(String what) {
    return '$what n\'est pas encore disponible dans cette version.';
  }

  @override
  String get faqSpacedQ => 'Comment fonctionne la répétition espacée ?';

  @override
  String get faqSpacedA =>
      'Après avoir retourné une carte, vous évaluez à quel point vous la connaissiez. Les cartes difficiles reviennent plus tôt ; celles notées Facile sont repoussées, pour que votre temps aille aux mots qui posent vraiment problème.';

  @override
  String get faqRatingsQ =>
      'Que signifient Encore, Difficile, Moyen et Facile ?';

  @override
  String get faqRatingsA =>
      'Ils déterminent le retour de la carte. Encore la ramène dans cette session, Difficile en environ un jour, Moyen en quelques jours et Facile en une semaine environ.';

  @override
  String get faqReviewDueQ => 'Que signifie « À revoir » sur une carte ?';

  @override
  String get faqReviewDueA =>
      'Cette carte a dépassé sa date de révision prévue. Les cartes à revoir passent en tête de votre prochaine session.';

  @override
  String get faqCreateDeckQ => 'Comment créer un paquet ?';

  @override
  String get faqCreateDeckA =>
      'Ouvrez l\'onglet Paquets et touchez « Nouveau paquet » en haut à droite. Donnez-lui un titre, puis utilisez « Ajouter une carte » depuis le paquet pour le remplir.';

  @override
  String get faqPictureQ => 'Puis-je ajouter une image à une carte ?';

  @override
  String get faqPictureA =>
      'Oui. En ajoutant ou modifiant une carte, collez une URL d\'image dans le champ URL de l\'image ; elle apparaîtra côté réponse.';

  @override
  String get faqGoalQ => 'Comment mon objectif quotidien est-il calculé ?';

  @override
  String get faqGoalA =>
      'L\'anneau de l\'écran d\'accueil compare les minutes étudiées aujourd\'hui à l\'objectif quotidien défini dans Profil → Préférences d\'étude.';

  @override
  String get faqStreakQ => 'Pourquoi ma série a-t-elle été réinitialisée ?';

  @override
  String get faqStreakA =>
      'Une série compte les jours consécutifs avec au moins une révision terminée. Manquer une journée entière y met fin.';

  @override
  String get privacyIntro =>
      'Contrôlez ce que LanGigaCards conserve sur vous et l\'usage fait de vos données d\'apprentissage.';

  @override
  String get privacySectionPrivacy => 'Confidentialité';

  @override
  String get privacyUsageAnalytics => 'Statistiques d\'utilisation';

  @override
  String get privacyPersonalisedReview => 'Ordre de révision personnalisé';

  @override
  String get privacyPublicProfile => 'Profil public';

  @override
  String get privacyAnalyticsOn =>
      'Les données d\'usage anonymes aident à améliorer l\'algorithme de révision.';

  @override
  String get privacyAnalyticsOff =>
      'Les statistiques sont désactivées. Rien n\'est collecté sur votre usage de l\'application.';

  @override
  String get privacySectionSecurity => 'Sécurité';

  @override
  String get privacyBiometric => 'Exiger le déverrouillage biométrique';

  @override
  String get privacyChangePassword => 'Changer le mot de passe';

  @override
  String get privacyActiveSessions => 'Sessions actives';

  @override
  String get privacySectionYourData => 'Vos données';

  @override
  String get privacyExportDecks => 'Exporter mes paquets';

  @override
  String get privacyDeleteAccount => 'Supprimer le compte';

  @override
  String get privacyDeleteConfirm => 'Supprimer le compte ?';

  @override
  String get privacyDeleteBody =>
      'Cela supprimerait définitivement vos paquets, vos cartes et votre historique de révision. C\'est irréversible.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what nécessite un compte connecté, ce que cette version n\'a pas encore.';
  }

  @override
  String get privacyChangingPassword => 'Changer votre mot de passe';

  @override
  String get privacySessionManagement => 'La gestion des sessions';

  @override
  String privacyExportSaved(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String get changePasswordCurrentLabel => 'Mot de passe actuel';

  @override
  String get changePasswordNewLabel => 'Nouveau mot de passe';

  @override
  String get changePasswordSuccess => 'Mot de passe mis à jour';

  @override
  String get changePasswordIncorrectCurrent =>
      'Le mot de passe actuel est incorrect';

  @override
  String get privacyAccountDeletion => 'La suppression du compte';

  @override
  String get categoriesEditTitle => 'Modifier les thèmes';

  @override
  String get categoriesSearchHint => 'Rechercher des thèmes...';

  @override
  String get languagesSearchHint => 'Rechercher des langues...';

  @override
  String get languagesPopular => 'POPULAIRES';

  @override
  String get reminderPermissionNeeded =>
      'Les rappels nécessitent l\'autorisation de notification. Activez-la dans les réglages du système.';

  @override
  String reminderSetFor(String time) {
    return 'Rappel quotidien réglé sur $time';
  }

  @override
  String get reminderPickTime => 'Me rappeler à';

  @override
  String get wizardPurposeQuestion => 'Pourquoi apprenez-vous cette langue ?';

  @override
  String get wizardSelectAllThatApply => 'Choisissez tout ce qui s\'applique';

  @override
  String get wizardAgeQuestion => 'Quelle est votre tranche d\'âge ?';

  @override
  String get wizardTopicsQuestion =>
      'Quels thèmes voulez-vous étudier en premier ?';

  @override
  String get wizardAgeNote =>
      'Nous utilisons votre âge pour ajuster l\'accessibilité et l\'expérience d\'apprentissage.';

  @override
  String get studyAllUpToDate =>
      'Toutes vos cartes sont à jour. Ajoutez de nouveaux mots ou revenez quand des révisions seront dues.';

  @override
  String studyDeckMastered(String deck) {
    return 'Vous maîtrisez tout dans $deck. Ajoutez de nouveaux mots pour continuer.';
  }

  @override
  String get ttsVoiceMissingUnknown =>
      'La voix de cette langue n\'est pas encore installée sur votre appareil.';

  @override
  String ttsVoiceMissing(String language) {
    return 'La voix $language n\'est pas encore installée. Ajoutez-la dans les réglages de synthèse vocale du système.';
  }

  @override
  String get ttsUnavailable =>
      'Cet appareil ne dispose pas de moteur de synthèse vocale.';

  @override
  String get ttsPlay => 'Écouter la prononciation';

  @override
  String get ttsNothing => 'Rien à prononcer';

  @override
  String ttsPlayOf(String text) {
    return 'Écouter la prononciation de $text';
  }

  @override
  String get reminderNotificationTitle => 'C\'est l\'heure de réviser';

  @override
  String get reminderNotificationBody =>
      'Vos cartes vous attendent — quelques minutes suffisent pour garder la série.';

  @override
  String get splashTagline => 'APPRENEZ TOUTE LANGUE';

  @override
  String get profileLearningLabel => 'apprend';
}
