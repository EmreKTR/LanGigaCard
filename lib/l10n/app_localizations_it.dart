// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appLanguageTitle => 'Scegli la lingua dell\'app';

  @override
  String get appLanguageSubtitle =>
      'Scegli la lingua in cui vuoi usare LanGigaCards.';

  @override
  String get commonContinue => 'Continua';

  @override
  String get commonSignIn => 'Accedi';

  @override
  String get commonSkip => 'Salta';

  @override
  String get commonGetStarted => 'Inizia';

  @override
  String get commonTryAgain => 'Riprova';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonRequiredField => 'Questo campo è obbligatorio';

  @override
  String get commonSomethingWrong => 'Qualcosa è andato storto. Riprova.';

  @override
  String get commonNetworkError =>
      'Impossibile raggiungere il server. Controlla la connessione e riprova.';

  @override
  String get onboardingSlide1Title => 'Impara con le flashcard';

  @override
  String get onboardingSlide1Body =>
      'Padroneggia il vocabolario con il nostro sistema di ripetizione dilazionata. Ripassa le carte al momento giusto per ricordare più a lungo.';

  @override
  String get onboardingSlide2Title => 'Segui i tuoi progressi';

  @override
  String get onboardingSlide2Body =>
      'Visualizza il tuo percorso con statistiche chiare. Guarda il tuo vocabolario crescere giorno dopo giorno, tra serie e traguardi.';

  @override
  String get onboardingSlide3Title => 'Raggiungi i tuoi obiettivi';

  @override
  String get onboardingSlide3Body =>
      'Imposta obiettivi giornalieri personalizzati e resta motivato. Il nostro algoritmo si adatta al tuo ritmo e rende lo studio semplice.';

  @override
  String get onboardingHaveAccount => 'Hai già un account?';

  @override
  String get loginTitle => 'Bentornato';

  @override
  String get loginSubtitle => 'Accedi per continuare il tuo percorso';

  @override
  String get loginEmailLabel => 'Indirizzo email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginRememberMe => 'Ricordami';

  @override
  String get loginForgotPassword => 'Password dimenticata?';

  @override
  String get loginOrContinueWith => 'oppure continua con';

  @override
  String get loginNoAccount => 'Non hai un account?';

  @override
  String get loginInvalidCredentials =>
      'Email o password errati. Crea un account se non ne hai ancora uno.';

  @override
  String get registerTitle => 'Crea account';

  @override
  String get registerBackToSignIn => 'Torna all\'accesso';

  @override
  String get registerSubtitle =>
      'I tuoi dati — lingue e preferenze di studio arrivano dopo.';

  @override
  String get registerFirstName => 'Nome';

  @override
  String get registerLastName => 'Cognome';

  @override
  String get registerEmail => 'Indirizzo email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerPasswordHint => 'Min. 8 caratteri';

  @override
  String get registerConfirmPassword => 'Conferma password';

  @override
  String get registerConfirmHint => 'Reinserisci la password';

  @override
  String get registerInvalidEmail => 'Inserisci un indirizzo email valido';

  @override
  String get registerPasswordTooShort =>
      'La password deve avere almeno 8 caratteri';

  @override
  String get registerPasswordsDontMatch => 'Le password non coincidono';

  @override
  String get registerEmailTaken => 'Esiste già un account con questa email.';

  @override
  String get verifyTitle => 'Verifica la tua email';

  @override
  String verifySubtitle(String email) {
    return 'Abbiamo inviato un codice di 6 cifre a $email. Inseriscilo qui sotto per confermare il tuo account.';
  }

  @override
  String get verifyNoCode => 'Non hai ricevuto il codice?';

  @override
  String get verifyResend => 'Invia di nuovo';

  @override
  String get verifySending => 'Invio in corso…';

  @override
  String get verifyAction => 'Verifica';

  @override
  String verifyEnterAllDigits(int count) {
    return 'Inserisci tutte le $count cifre';
  }

  @override
  String get verifyIncorrect => 'Codice errato, riprova';

  @override
  String get verifyTooManyAttempts =>
      'Troppi tentativi. Tocca «Invia di nuovo» per riceverne uno nuovo.';

  @override
  String get verifyResent => 'Un nuovo codice è stato inviato alla tua email';

  @override
  String get forgotTitle => 'Reimposta la password';

  @override
  String get forgotSubtitle =>
      'Inserisci l\'email con cui ti sei registrato e ti invieremo un link per scegliere una nuova password.';

  @override
  String get forgotEmailLabel => 'Indirizzo email';

  @override
  String get forgotInvalidEmail => 'Inserisci un indirizzo email valido';

  @override
  String get forgotSend => 'Invia il link';

  @override
  String get forgotCheckInbox => 'Controlla la posta in arrivo';

  @override
  String forgotSentTo(String email) {
    return 'Se esiste un account per $email, il link per reimpostare è in arrivo.';
  }

  @override
  String get forgotNoMailServer =>
      'Questa build non ha un server di posta collegato, quindi non viene inviata alcuna email.';

  @override
  String get forgotUseDifferent => 'Usa un\'altra email';

  @override
  String get navHome => 'Home';

  @override
  String get navDecks => 'Mazzi';

  @override
  String get navQuiz => 'Quiz';

  @override
  String get navStats => 'Statistiche';

  @override
  String get navProfile => 'Profilo';

  @override
  String get homeGreetingMorning => 'Buongiorno,';

  @override
  String get homeGreetingAfternoon => 'Buon pomeriggio,';

  @override
  String get homeGreetingEvening => 'Buonasera,';

  @override
  String get homeContinueLearning => 'CONTINUA A IMPARARE';

  @override
  String homeCardsDue(int count) {
    return '$count carte da ripassare';
  }

  @override
  String homeMinGoal(int minutes) {
    return 'obiettivo $minutes min';
  }

  @override
  String get homeFinishSetup =>
      'Completa il tuo profilo per ricevere il primo mazzo.';

  @override
  String get homeWords => 'Parole';

  @override
  String get homeAccuracy => 'Precisione';

  @override
  String get homeStreak => 'Serie';

  @override
  String get homeContinueQuizLabel => 'QUIZ';

  @override
  String get homeContinueQuizTitle => 'Continua il Quiz';

  @override
  String homeContinueQuizSubtitle(String deck, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count domande',
      one: '1 domanda',
    );
    return '$deck · $_temp0';
  }

  @override
  String homeReviewDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count da ripassare',
      one: '1 da ripassare',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewDoneBadge => 'Completato';

  @override
  String get homeYourTopics => 'I tuoi temi';

  @override
  String get homeRecentlyLearned => 'Imparato di recente';

  @override
  String get homeSeeAll => 'Vedi tutto';

  @override
  String get shellProfileLoadFailed => 'Impossibile caricare il tuo profilo';

  @override
  String get shellCheckConnection => 'Controlla la connessione e riprova.';

  @override
  String get shellSyncDroppedOne =>
      '1 modifica non è stata salvata ed è stata scartata.';

  @override
  String shellSyncDroppedMany(int count) {
    return '$count modifiche non sono state salvate e sono state scartate.';
  }

  @override
  String get commonDelete => 'Elimina';

  @override
  String get decksTitle => 'I miei mazzi';

  @override
  String get decksNewDeck => 'Nuovo mazzo';

  @override
  String decksSummary(int decks, int due) {
    return '$decks mazzi · $due carte da ripassare oggi';
  }

  @override
  String decksDueForReview(int count) {
    return '$count carte da ripassare';
  }

  @override
  String get decksSortedByUrgency =>
      'Ordinate per urgenza · Tocca per iniziare';

  @override
  String get decksSearchHint => 'Cerca mazzi...';

  @override
  String decksNoMatch(String query) {
    return 'Nessun mazzo corrisponde a «$query»';
  }

  @override
  String get decksNoneYet => 'Ancora nessun mazzo';

  @override
  String get decksTryDifferentSearch =>
      'Prova un\'altra ricerca o crea un mazzo con questo nome.';

  @override
  String get decksEmptyHelp =>
      'I mazzi raggruppano le parole che vuoi imparare. Crea il primo per iniziare.';

  @override
  String get decksCreateADeck => 'Crea un mazzo';

  @override
  String get decksOptions => 'Opzioni del mazzo';

  @override
  String get decksQuizThis => 'Fai il quiz di questo mazzo';

  @override
  String get decksRename => 'Rinomina mazzo';

  @override
  String get decksDelete => 'Elimina mazzo';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte',
      one: '1 carta',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => 'Da ripassare';

  @override
  String decksReviewCount(int count) {
    return '$count ripassi';
  }

  @override
  String get decksMastery => 'Padronanza';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Studia $count carte',
      one: 'Studia 1 carta',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'Tutto in pari';

  @override
  String get decksBrowse => 'Sfoglia';

  @override
  String get decksRenameTitle => 'Rinomina mazzo';

  @override
  String get decksCreateTitle => 'Crea nuovo mazzo';

  @override
  String get decksTitleLabel => 'TITOLO *';

  @override
  String get decksTitleHint => 'es. Francese base';

  @override
  String get decksDescriptionLabel => 'DESCRIZIONE (FACOLTATIVA)';

  @override
  String get decksDescriptionHint => 'Descrivi cosa contiene questo mazzo...';

  @override
  String get decksSaveChanges => 'Salva modifiche';

  @override
  String get decksCreateDeck => 'Crea mazzo';

  @override
  String get decksNoDescription => 'Nessuna descrizione';

  @override
  String decksDeleteConfirm(String name) {
    return 'Eliminare «$name»?';
  }

  @override
  String get decksDeleteEmpty => 'Questo mazzo è vuoto e verrà rimosso.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il mazzo e le sue $count carte verranno rimossi.',
      one: 'Il mazzo e la sua carta verranno rimossi.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '«$name» eliminato';
  }

  @override
  String get decksCreateFailed => 'Impossibile creare il mazzo. Riprova.';

  @override
  String get decksDeleteFailed => 'Impossibile eliminare il mazzo. Riprova.';

  @override
  String get decksSaveFailed => 'Impossibile salvare le modifiche. Riprova.';

  @override
  String get quizDecksTitle => 'Mazzi Quiz';

  @override
  String get quizDecksStartQuiz => 'Avvia Quiz';

  @override
  String get quizDecksEmpty => 'Ancora nessun mazzo';

  @override
  String get quizDecksEmptyHelp =>
      'Crea un mazzo dalla scheda Mazzi, poi torna qui per metterti alla prova.';

  @override
  String quizDecksNotEnoughCards(int min) {
    return 'Aggiungi almeno $min carte per sbloccare il quiz';
  }

  @override
  String get detailNotFound => 'Questo mazzo non esiste più';

  @override
  String get detailBackToDecks => 'Torna ai mazzi';

  @override
  String get detailProgress => 'PROGRESSO';

  @override
  String get detailMastered => 'Padroneggiate';

  @override
  String get detailLearning => 'In apprendimento';

  @override
  String get detailCards => 'Carte';

  @override
  String get detailReviews => 'Ripassi';

  @override
  String get detailBrowseAll => 'Sfoglia tutte';

  @override
  String detailMore(int count) {
    return '+ altre $count';
  }

  @override
  String get detailBack => 'Indietro';

  @override
  String get detailAddCardTooltip => 'Aggiungi una carta a questo mazzo';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label: $count di $total carte';
  }

  @override
  String get detailEmpty => 'Questo mazzo è vuoto';

  @override
  String get detailEmptyHelp =>
      'Aggiungi qualche parola e potrai iniziare subito.';

  @override
  String get detailAddCard => 'Aggiungi carta';

  @override
  String get cardEditTitle => 'Modifica carta';

  @override
  String get cardAddTitle => 'Nuova carta';

  @override
  String get cardDeckLabel => 'MAZZO *';

  @override
  String get cardFrontLabel => 'FRONTE (PAROLA TARGET) *';

  @override
  String get cardBackLabel => 'RETRO (TRADUZIONE) *';

  @override
  String get cardFrontHint => 'es. Bonjour';

  @override
  String get cardBackHint => 'es. Ciao';

  @override
  String get cardExampleLabel => 'FRASE DI ESEMPIO';

  @override
  String get cardExampleHint => 'Scrivi una frase di esempio...';

  @override
  String get cardImageLabel => 'URL IMMAGINE';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError =>
      'Inserisci un URL immagine completo che inizi con http:// o https://';

  @override
  String get cardAdd => 'Aggiungi carta';

  @override
  String get cardAddFailed => 'Impossibile aggiungere la carta. Riprova.';

  @override
  String get libraryTitle => 'Libreria carte';

  @override
  String get librarySearchHint => 'Cerca fronte o retro...';

  @override
  String get libraryAllDecks => 'Tutti i mazzi';

  @override
  String libraryTotalItems(int count) {
    return 'Totale: $count';
  }

  @override
  String get libraryShowingAll => 'Mostrando tutto';

  @override
  String get libraryFilteredByDeck => 'Filtrato per mazzo';

  @override
  String get libraryStudyThisDeck => 'Studia questo mazzo';

  @override
  String libraryNoMatch(String query) {
    return 'Nessuna carta corrisponde a «$query»';
  }

  @override
  String get libraryNoneYet => 'Qui non ci sono ancora carte';

  @override
  String get libraryCheckSpelling =>
      'Controlla l\'ortografia o rimuovi il filtro mazzo per cercare ovunque.';

  @override
  String get libraryAddFirst =>
      'Aggiungi la tua prima parola: comparirà nella prossima sessione.';

  @override
  String get libraryUnknownDeck => 'Mazzo sconosciuto';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · $count ripassi';
  }

  @override
  String get libraryEditCard => 'Modifica carta';

  @override
  String get libraryDeleteCard => 'Elimina carta';

  @override
  String get libraryDeleteConfirmTitle => 'Eliminare la carta?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '«$term» sarà rimossa definitivamente dalla tua libreria.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '«$term» eliminata';
  }

  @override
  String get libraryDeleteFailed => 'Impossibile eliminare la carta. Riprova.';

  @override
  String get studyAllDecks => 'Tutti i mazzi';

  @override
  String studyDailyReview(String deck) {
    return 'Ripasso giornaliero · $deck';
  }

  @override
  String studyWordHint(String term) {
    return 'Parola: $term. Tocca per vedere la traduzione.';
  }

  @override
  String studyAnswerHint(String translation) {
    return 'Risposta: $translation. Tocca per rivedere la parola. Scorri per saltare o valuta qui sotto.';
  }

  @override
  String get studyRateBelow =>
      'Valuta qui sotto, o scorri per saltare senza valutare';

  @override
  String get studyRecallHint =>
      'Ricorda la traduzione, poi gira per controllare';

  @override
  String get studyNothingDue => 'Nulla da ripassare adesso';

  @override
  String get studyBackToDecks => 'Torna ai mazzi';

  @override
  String get studyQueueFailed => 'Impossibile caricare la tua coda di ripasso';

  @override
  String get studyTapToSeeExample => '[ tocca per vedere l\'esempio ]';

  @override
  String get studyShowExample => 'Mostra frase di esempio';

  @override
  String get studyTapToReveal => 'Tocca per vedere la traduzione';

  @override
  String studyHearPronounced(String term) {
    return 'Ascolta la pronuncia di $term';
  }

  @override
  String get studyHearIt => 'Ascolta';

  @override
  String get studyTranslationLabel => 'TRADUZIONE';

  @override
  String get studyExampleLabel => 'ESEMPIO';

  @override
  String get studyImageFailed => 'Immagine non caricata';

  @override
  String get studyAllCaughtUp => 'Tutto in pari!';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hai ripassato tutte le $count carte di oggi',
      one: 'Hai ripassato la carta di oggi',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => 'sicurezza';

  @override
  String get studyViewStats => 'Vedi statistiche';

  @override
  String get quizTimeUp => '⏰ Tempo scaduto! Ecco la risposta corretta.';

  @override
  String quizProgress(int index, int total) {
    return 'D$index di $total';
  }

  @override
  String get quizFinish => 'Termina';

  @override
  String get quizNextQuestion => 'Prossima domanda →';

  @override
  String get quizNotEnough => 'Carte insufficienti per il quiz';

  @override
  String quizNotEnoughAll(int min) {
    return 'Aggiungi almeno $min carte con traduzioni diverse e il quiz si costruirà da solo.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck ha bisogno di almeno $min carte con traduzioni diverse per poter essere quizzato.';
  }

  @override
  String get quizBack => 'Indietro';

  @override
  String get quizPerfect => 'Punteggio perfetto!';

  @override
  String get quizGreat => 'Ottimo lavoro!';

  @override
  String get quizNice => 'Bel progresso';

  @override
  String get quizKeepPractising => 'Continua a esercitarti';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return 'Hai risposto correttamente a $score su $total';
  }

  @override
  String get quizScore => 'punteggio';

  @override
  String get quizDone => 'Fatto';

  @override
  String get statsTitle => 'Statistiche';

  @override
  String get statsSubtitle => 'Il tuo percorso in numeri';

  @override
  String get statsStreak => 'Serie';

  @override
  String get statsReviews => 'Ripassi';

  @override
  String get statsRecall => 'Memoria';

  @override
  String statsTodayDelta(int count) {
    return '+$count oggi';
  }

  @override
  String get statsNoData => 'nessun dato';

  @override
  String get statsHeatmap => 'Mappa dell\'apprendimento';

  @override
  String statsStreakSummary(int days, int total) {
    return 'serie di $days giorni · $total ripassi registrati';
  }

  @override
  String statsReviewsLogged(int total) {
    return '$total ripassi registrati';
  }

  @override
  String get statsLess => 'Meno';

  @override
  String get statsMore => 'Più';

  @override
  String get statsNoActivity => 'Ancora nessuna attività';

  @override
  String get statsLibraryBreakdown => 'Composizione della libreria';

  @override
  String get statsAchievements => 'Traguardi';

  @override
  String statsEarned(int earned, int total) {
    return '$earned / $total ottenuti';
  }

  @override
  String get statsAddCards => 'Aggiungi qualche carta per vedere i progressi';

  @override
  String get statsDaily => 'Giornaliero';

  @override
  String get statsWeekly => 'Settimanale';

  @override
  String get statsMonthly => 'Mensile';

  @override
  String get statsChartDaily => 'Ripassi, ultimi 7 giorni';

  @override
  String get statsChartWeekly => 'Ripassi, ultime 4 settimane';

  @override
  String get statsChartMonthly => 'Ripassi, ultimi 6 mesi';

  @override
  String statsChartTotal(int count) {
    return '$count in totale';
  }

  @override
  String get profileStudyPreferences => 'Preferenze di studio';

  @override
  String get profileNativeLanguage => 'Lingua madre';

  @override
  String get profileTargetLanguage => 'Lingua da imparare';

  @override
  String get profileLearningPurpose => 'Obiettivo di apprendimento';

  @override
  String get profileStudyCategories => 'Temi di studio';

  @override
  String get profileDailyGoal => 'Obiettivo giornaliero';

  @override
  String get profileAppPreferences => 'Preferenze dell\'app';

  @override
  String get profileDarkMode => 'Tema scuro';

  @override
  String get profileAppLanguage => 'Lingua dell\'app';

  @override
  String get profileSoundEffects => 'Effetti sonori';

  @override
  String get profileDailyReminder => 'Promemoria giornaliero';

  @override
  String get profileThemeColor => 'Colore del tema';

  @override
  String get profileTextSize => 'Dimensione del testo';

  @override
  String get profileDifficultyMode => 'Modalità difficoltà';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileEditProfile => 'Modifica profilo';

  @override
  String get profilePrivacySecurity => 'Privacy e sicurezza';

  @override
  String get profileUpgradePremium => 'Passa a Premium';

  @override
  String get profileHelpSupport => 'Aiuto e supporto';

  @override
  String get profileLogOut => 'Esci';

  @override
  String get profileLogOutConfirm => 'Uscire?';

  @override
  String get profileLogOutBody =>
      'Dovrai accedere di nuovo per continuare a studiare.';

  @override
  String get profileNoneYet => 'Nessuno ancora';

  @override
  String profileSelectedCount(int count) {
    return '$count selezionati';
  }

  @override
  String profileTopicsCount(int count) {
    return '$count temi';
  }

  @override
  String profileMinutes(int min) {
    return '$min min';
  }

  @override
  String get profileNative => 'Madrelingua';

  @override
  String get profileEdit => 'Modifica';

  @override
  String get profileFullName => 'Nome completo';

  @override
  String get profileEmailAddress => 'Indirizzo email';

  @override
  String get profileNameRequired => 'Il nome è obbligatorio';

  @override
  String get profileEmailRequired => 'L\'email è obbligatoria';

  @override
  String get profileClose => 'Chiudi';

  @override
  String get profileWhyLearning =>
      'Perché stai imparando? Scegli tutte le opzioni che valgono.';

  @override
  String get profileDecreaseGoal => 'Riduci obiettivo giornaliero';

  @override
  String get profileIncreaseGoal => 'Aumenta obiettivo giornaliero';

  @override
  String get profileYouSpeakThis => 'parli questa lingua';

  @override
  String get profileLearningThis => 'stai imparando questa';

  @override
  String profileLevelBadge(int level) {
    return '⭐ Livello $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ serie di $days giorni';
  }

  @override
  String get profileServerUnreachable =>
      'Impossibile raggiungere il server. Controlla la connessione e riprova.';

  @override
  String get profileSaveNameFailed =>
      'Impossibile salvare il tuo nome. Riprova.';

  @override
  String get profileSaveLanguageFailed =>
      'Impossibile salvare la tua lingua. Riprova.';

  @override
  String get profileSaveGoalFailed =>
      'Impossibile salvare il tuo obiettivo giornaliero. Riprova.';

  @override
  String get profileSaveCategoriesFailed =>
      'Impossibile salvare i tuoi temi. Riprova.';

  @override
  String get profileSavePurposesFailed =>
      'Impossibile salvare i tuoi obiettivi. Riprova.';

  @override
  String get profileLoadCategoriesFailed =>
      'Impossibile caricare i temi. Controlla la connessione e riprova.';

  @override
  String get profileLoadPurposesFailed =>
      'Impossibile caricare gli obiettivi. Controlla la connessione e riprova.';

  @override
  String wizardStep(int current, int total, String label) {
    return 'PASSO $current DI $total — $label';
  }

  @override
  String get wizardNativeLanguage => 'LINGUA MADRE';

  @override
  String get wizardTargetLanguage => 'LINGUA DA IMPARARE';

  @override
  String get wizardTargetLevel => 'LIVELLO NELLA LINGUA';

  @override
  String get wizardLearningPurpose => 'OBIETTIVO';

  @override
  String get wizardTopics => 'TEMI E CATEGORIE';

  @override
  String get wizardAge => 'LA TUA ETÀ';

  @override
  String get wizardDailyGoal => 'OBIETTIVO GIORNALIERO';

  @override
  String get wizardNativeQuestion => 'Qual è la tua lingua madre?';

  @override
  String get wizardTargetQuestion => 'Quale lingua vuoi imparare?';

  @override
  String wizardLevelQuestion(String language) {
    return 'Qual è il tuo livello attuale di $language?';
  }

  @override
  String get wizardLevelHint =>
      'Scegli quello che ti sembra giusto — puoi cambiarlo quando vuoi.';

  @override
  String get wizardGoalQuestion => 'Quanto tempo puoi dedicare ogni giorno?';

  @override
  String wizardSelectedHint(int count) {
    return '$count selezionati · Potrai cambiarlo più avanti';
  }

  @override
  String get wizardNativePrefix => 'Madrelingua: ';

  @override
  String get wizardStart => 'Iniziamo a imparare 🚀';

  @override
  String get wizardLoadFailed =>
      'Impossibile caricare le opzioni di configurazione';

  @override
  String get wizardSaveFailed =>
      'Impossibile salvare i tuoi temi o il tuo obiettivo. Riprova.';

  @override
  String get levelJustStarting => 'Sto iniziando';

  @override
  String get levelJustStartingDesc => 'Imparo le basi';

  @override
  String get levelBeginner => 'Principiante';

  @override
  String get levelBeginnerDesc => 'Conosco alcune parole e frasi';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelIntermediateDesc => 'Riesco a fare conversazioni semplici';

  @override
  String get levelAdvanced => 'Avanzato';

  @override
  String get levelAdvancedDesc => 'A mio agio in quasi tutte le situazioni';

  @override
  String get levelFluent => 'Fluente';

  @override
  String get levelFluentDesc => 'Quasi come un madrelingua';

  @override
  String get goalCasual => 'Tranquillo';

  @override
  String get goalRegular => 'Regolare';

  @override
  String get goalIntense => 'Intenso';

  @override
  String goalWordsPerDay(int count) {
    return '~$count parole/giorno';
  }

  @override
  String get helpSearchHint => 'Cerca negli articoli di aiuto...';

  @override
  String get helpFrequentlyAsked => 'DOMANDE FREQUENTI';

  @override
  String helpNoMatch(String query) {
    return 'Nessun articolo corrisponde a «$query»';
  }

  @override
  String get helpStillStuck => 'ANCORA BLOCCATO?';

  @override
  String get helpEmailSupport => 'Supporto via email';

  @override
  String get helpCommunityForum => 'Forum della community';

  @override
  String get helpReportProblem => 'Segnala un problema';

  @override
  String get helpTheCommunityForum => 'Il forum della community';

  @override
  String get helpProblemReporting => 'La segnalazione dei problemi';

  @override
  String helpComingSoon(String what) {
    return '$what non è ancora disponibile in questa build.';
  }

  @override
  String get faqSpacedQ => 'Come funziona la ripetizione dilazionata?';

  @override
  String get faqSpacedA =>
      'Dopo aver girato una carta valuti quanto la sapevi. Le carte difficili tornano prima; quelle che segni come Facile vengono allontanate, così dedichi il tempo alle parole che ti mettono davvero in difficoltà.';

  @override
  String get faqRatingsQ =>
      'Cosa significano Ancora, Difficile, Medio e Facile?';

  @override
  String get faqRatingsA =>
      'Stabiliscono quando la carta torna. Ancora la riporta in questa sessione, Difficile dopo circa un giorno, Medio dopo qualche giorno e Facile dopo circa una settimana.';

  @override
  String get faqReviewDueQ => 'Cosa significa «Da ripassare» su una carta?';

  @override
  String get faqReviewDueA =>
      'Quella carta ha superato la data di ripasso prevista. Le carte da ripassare vengono messe all\'inizio della prossima sessione.';

  @override
  String get faqCreateDeckQ => 'Come creo un mazzo?';

  @override
  String get faqCreateDeckA =>
      'Apri la scheda Mazzi e tocca «Nuovo mazzo» in alto a destra. Dagli un titolo, poi usa «Aggiungi carta» dal mazzo per riempirlo.';

  @override
  String get faqPictureQ => 'Posso aggiungere un\'immagine a una carta?';

  @override
  String get faqPictureA =>
      'Sì. Quando aggiungi o modifichi una carta, incolla un URL immagine nel campo URL immagine: comparirà sul lato della risposta.';

  @override
  String get faqGoalQ => 'Come viene calcolato il mio obiettivo giornaliero?';

  @override
  String get faqGoalA =>
      'L\'anello nella schermata iniziale confronta i minuti studiati oggi con l\'obiettivo giornaliero impostato in Profilo → Preferenze di studio.';

  @override
  String get faqStreakQ => 'Perché la mia serie si è azzerata?';

  @override
  String get faqStreakA =>
      'Una serie conta i giorni consecutivi con almeno un ripasso completato. Saltare un giorno intero la interrompe.';

  @override
  String get privacyIntro =>
      'Controlla cosa LanGigaCards conserva su di te e come vengono usati i tuoi dati di studio.';

  @override
  String get privacySectionPrivacy => 'Privacy';

  @override
  String get privacyUsageAnalytics => 'Analisi d\'uso';

  @override
  String get privacyPersonalisedReview => 'Ordine di ripasso personalizzato';

  @override
  String get privacyPublicProfile => 'Profilo pubblico';

  @override
  String get privacyAnalyticsOn =>
      'I dati d\'uso anonimi aiutano a migliorare l\'algoritmo di ripasso.';

  @override
  String get privacyAnalyticsOff =>
      'Le analisi sono disattivate. Non viene raccolto nulla su come usi l\'app.';

  @override
  String get privacySectionSecurity => 'Sicurezza';

  @override
  String get privacyBiometric => 'Richiedi sblocco biometrico';

  @override
  String get privacyChangePassword => 'Cambia password';

  @override
  String get privacyActiveSessions => 'Sessioni attive';

  @override
  String get privacySectionYourData => 'I tuoi dati';

  @override
  String get privacyExportDecks => 'Esporta i miei mazzi';

  @override
  String get privacyDeleteAccount => 'Elimina account';

  @override
  String get privacyDeleteConfirm => 'Eliminare l\'account?';

  @override
  String get privacyDeleteBody =>
      'Questo rimuoverebbe definitivamente i tuoi mazzi, le carte e la cronologia dei ripassi. Non è reversibile.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what richiede un account con accesso effettuato, che questa build non ha ancora.';
  }

  @override
  String get privacyChangingPassword => 'Il cambio della password';

  @override
  String get privacySessionManagement => 'La gestione delle sessioni';

  @override
  String get privacyExportingDecks => 'L\'esportazione dei mazzi';

  @override
  String get privacyAccountDeletion => 'L\'eliminazione dell\'account';

  @override
  String get categoriesEditTitle => 'Modifica temi';

  @override
  String get categoriesSearchHint => 'Cerca temi...';

  @override
  String get languagesSearchHint => 'Cerca lingue...';

  @override
  String get languagesPopular => 'POPOLARI';

  @override
  String get reminderPermissionNeeded =>
      'I promemoria richiedono il permesso per le notifiche. Attivalo nelle impostazioni di sistema.';

  @override
  String reminderSetFor(String time) {
    return 'Promemoria giornaliero impostato per le $time';
  }

  @override
  String get reminderPickTime => 'Ricordamelo alle';

  @override
  String get wizardPurposeQuestion => 'Perché stai imparando questa lingua?';

  @override
  String get wizardSelectAllThatApply => 'Scegli tutte le opzioni che valgono';

  @override
  String get wizardAgeQuestion => 'Qual è la tua fascia d\'età?';

  @override
  String get wizardTopicsQuestion => 'Quali temi vuoi studiare per primi?';

  @override
  String get wizardAgeNote =>
      'Usiamo la tua età per ottimizzare le impostazioni di accessibilità e l\'esperienza di studio.';

  @override
  String get studyAllUpToDate =>
      'Tutte le tue carte sono in pari. Aggiungi nuove parole o torna quando ci saranno ripassi.';

  @override
  String studyDeckMastered(String deck) {
    return 'Hai imparato tutto in $deck. Aggiungi nuove parole per continuare.';
  }

  @override
  String get ttsVoiceMissingUnknown =>
      'La voce per questa lingua non è ancora installata sul dispositivo.';

  @override
  String ttsVoiceMissing(String language) {
    return 'La voce $language non è ancora installata. Aggiungila nelle impostazioni di sintesi vocale del sistema.';
  }

  @override
  String get ttsUnavailable =>
      'Questo dispositivo non ha un motore di sintesi vocale disponibile.';

  @override
  String get ttsPlay => 'Ascolta la pronuncia';

  @override
  String get ttsNothing => 'Niente da pronunciare';

  @override
  String ttsPlayOf(String text) {
    return 'Ascolta la pronuncia di $text';
  }

  @override
  String get reminderNotificationTitle => 'È ora di ripassare';

  @override
  String get reminderNotificationBody =>
      'Le tue carte ti aspettano: bastano pochi minuti per mantenere la serie.';

  @override
  String get splashTagline => 'IMPARA QUALSIASI LINGUA';

  @override
  String get profileLearningLabel => 'impara';
}
