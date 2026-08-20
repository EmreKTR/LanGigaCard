// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appLanguageTitle => 'App-Sprache wählen';

  @override
  String get appLanguageSubtitle =>
      'Wähle die Sprache, in der du LanGigaCards verwenden möchtest.';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonSignIn => 'Anmelden';

  @override
  String get commonSkip => 'Überspringen';

  @override
  String get commonGetStarted => 'Los geht\'s';

  @override
  String get commonTryAgain => 'Erneut versuchen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonRequiredField => 'Dieses Feld ist erforderlich';

  @override
  String get commonSomethingWrong =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get commonNetworkError =>
      'Server nicht erreichbar. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get onboardingSlide1Title => 'Mit Karteikarten lernen';

  @override
  String get onboardingSlide1Body =>
      'Beherrsche Vokabeln mit unserem bewährten System der verteilten Wiederholung. Wiederhole Karten genau im richtigen Moment, damit sie hängen bleiben.';

  @override
  String get onboardingSlide2Title => 'Fortschritt verfolgen';

  @override
  String get onboardingSlide2Body =>
      'Sieh deinen Lernweg in übersichtlichen Statistiken. Beobachte, wie dein Wortschatz Tag für Tag wächst — mit Serien und Erfolgen.';

  @override
  String get onboardingSlide3Title => 'Ziele erreichen';

  @override
  String get onboardingSlide3Body =>
      'Setze persönliche Tagesziele und bleib motiviert. Unser Algorithmus passt sich deinem Tempo an, damit Lernen leichtfällt.';

  @override
  String get onboardingHaveAccount => 'Du hast bereits ein Konto?';

  @override
  String get loginTitle => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Melde dich an, um weiterzulernen';

  @override
  String get loginEmailLabel => 'E-Mail-Adresse';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginRememberMe => 'Angemeldet bleiben';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginOrContinueWith => 'oder weiter mit';

  @override
  String get loginNoAccount => 'Noch kein Konto?';

  @override
  String get loginInvalidCredentials =>
      'E-Mail oder Passwort ist falsch. Erstelle ein Konto, falls du noch keins hast.';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerBackToSignIn => 'Zurück zur Anmeldung';

  @override
  String get registerSubtitle =>
      'Deine Daten — Sprachen und Lernvorlieben kommen als Nächstes.';

  @override
  String get registerFirstName => 'Vorname';

  @override
  String get registerLastName => 'Nachname';

  @override
  String get registerEmail => 'E-Mail-Adresse';

  @override
  String get registerPassword => 'Passwort';

  @override
  String get registerPasswordHint => 'Mind. 8 Zeichen';

  @override
  String get registerConfirmPassword => 'Passwort bestätigen';

  @override
  String get registerConfirmHint => 'Passwort erneut eingeben';

  @override
  String get registerInvalidEmail =>
      'Bitte gib eine gültige E-Mail-Adresse ein';

  @override
  String get registerPasswordTooShort =>
      'Das Passwort muss mindestens 8 Zeichen haben';

  @override
  String get registerPasswordsDontMatch => 'Passwörter stimmen nicht überein';

  @override
  String get registerEmailTaken =>
      'Mit dieser E-Mail existiert bereits ein Konto.';

  @override
  String get verifyTitle => 'E-Mail bestätigen';

  @override
  String verifySubtitle(String email) {
    return 'Wir haben einen 6-stelligen Code an $email gesendet. Gib ihn unten ein, um dein Konto zu bestätigen.';
  }

  @override
  String get verifyNoCode => 'Keinen Code erhalten?';

  @override
  String get verifyResend => 'Code erneut senden';

  @override
  String get verifySending => 'Wird gesendet…';

  @override
  String get verifyAction => 'Bestätigen';

  @override
  String verifyEnterAllDigits(int count) {
    return 'Gib alle $count Ziffern ein';
  }

  @override
  String get verifyIncorrect => 'Falscher Code, bitte erneut versuchen';

  @override
  String get verifyTooManyAttempts =>
      'Zu viele Versuche. Tippe auf „Code erneut senden“ für einen neuen.';

  @override
  String get verifyResent => 'Ein neuer Code wurde an deine E-Mail gesendet';

  @override
  String get forgotTitle => 'Passwort zurücksetzen';

  @override
  String get forgotSubtitle =>
      'Gib die E-Mail-Adresse ein, mit der du dich registriert hast, und wir senden dir einen Link zum Festlegen eines neuen Passworts.';

  @override
  String get forgotEmailLabel => 'E-Mail-Adresse';

  @override
  String get forgotInvalidEmail => 'Gib eine gültige E-Mail-Adresse ein';

  @override
  String get forgotSend => 'Link senden';

  @override
  String get forgotCheckInbox => 'Sieh in deinem Posteingang nach';

  @override
  String forgotSentTo(String email) {
    return 'Falls ein Konto für $email existiert, ist der Link zum Zurücksetzen unterwegs.';
  }

  @override
  String get forgotNoMailServer =>
      'In dieser Version ist kein Mailserver angebunden, es wird also keine E-Mail verschickt.';

  @override
  String get forgotUseDifferent => 'Andere E-Mail verwenden';

  @override
  String get navHome => 'Start';

  @override
  String get navDecks => 'Stapel';

  @override
  String get navQuiz => 'Quiz';

  @override
  String get navStats => 'Statistik';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeGreetingMorning => 'Guten Morgen,';

  @override
  String get homeGreetingAfternoon => 'Guten Tag,';

  @override
  String get homeGreetingEvening => 'Guten Abend,';

  @override
  String get homeContinueLearning => 'WEITERLERNEN';

  @override
  String homeCardsDue(int count) {
    return '$count Karten fällig';
  }

  @override
  String homeMinGoal(int minutes) {
    return '$minutes Min. Ziel';
  }

  @override
  String get homeFinishSetup =>
      'Vervollständige dein Profil, um deinen ersten Stapel zu erhalten.';

  @override
  String get homeWords => 'Wörter';

  @override
  String get homeAccuracy => 'Genauigkeit';

  @override
  String get homeStreak => 'Serie';

  @override
  String get homeContinueQuizLabel => 'QUIZ';

  @override
  String get homeContinueQuizTitle => 'Quiz fortsetzen';

  @override
  String homeContinueQuizSubtitle(String deck, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fragen',
      one: '1 Frage',
    );
    return '$deck · $_temp0';
  }

  @override
  String homeReviewDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fällig',
      one: '1 fällig',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewDoneBadge => 'Fertig';

  @override
  String get homeYourTopics => 'Deine Themen';

  @override
  String get homeRecentlyLearned => 'Zuletzt gelernt';

  @override
  String get homeSeeAll => 'Alle ansehen';

  @override
  String get shellProfileLoadFailed => 'Profil konnte nicht geladen werden';

  @override
  String get shellCheckConnection =>
      'Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get shellSyncDroppedOne =>
      '1 Änderung konnte nicht gespeichert werden und wurde verworfen.';

  @override
  String shellSyncDroppedMany(int count) {
    return '$count Änderungen konnten nicht gespeichert werden und wurden verworfen.';
  }

  @override
  String get commonDelete => 'Löschen';

  @override
  String get decksTitle => 'Meine Stapel';

  @override
  String get decksNewDeck => 'Neuer Stapel';

  @override
  String decksSummary(int decks, int due) {
    return '$decks Stapel · heute $due Karten fällig';
  }

  @override
  String decksDueForReview(int count) {
    return '$count Karten zur Wiederholung';
  }

  @override
  String get decksSortedByUrgency =>
      'Nach Dringlichkeit sortiert · Zum Starten tippen';

  @override
  String get decksSearchHint => 'Stapel suchen...';

  @override
  String decksNoMatch(String query) {
    return 'Kein Stapel passt zu „$query“';
  }

  @override
  String get decksNoneYet => 'Noch keine Stapel';

  @override
  String get decksTryDifferentSearch =>
      'Versuche eine andere Suche oder erstelle einen Stapel mit diesem Namen.';

  @override
  String get decksEmptyHelp =>
      'Stapel bündeln die Wörter, die du lernen willst. Erstelle deinen ersten, um loszulegen.';

  @override
  String get decksCreateADeck => 'Stapel erstellen';

  @override
  String get decksOptions => 'Stapeloptionen';

  @override
  String get decksQuizThis => 'Diesen Stapel abfragen';

  @override
  String get decksRename => 'Stapel umbenennen';

  @override
  String get decksDelete => 'Stapel löschen';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten',
      one: '1 Karte',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => 'Fällig';

  @override
  String decksReviewCount(int count) {
    return '$count Wiederholungen';
  }

  @override
  String get decksMastery => 'Beherrschung';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten lernen',
      one: '1 Karte lernen',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'Alles erledigt';

  @override
  String get decksBrowse => 'Durchsehen';

  @override
  String get decksRenameTitle => 'Stapel umbenennen';

  @override
  String get decksCreateTitle => 'Neuen Stapel erstellen';

  @override
  String get decksTitleLabel => 'TITEL *';

  @override
  String get decksTitleHint => 'z. B. Französisch Grundlagen';

  @override
  String get decksDescriptionLabel => 'BESCHREIBUNG (OPTIONAL)';

  @override
  String get decksDescriptionHint => 'Beschreibe, was dieser Stapel abdeckt...';

  @override
  String get decksSaveChanges => 'Änderungen speichern';

  @override
  String get decksCreateDeck => 'Stapel erstellen';

  @override
  String get decksNoDescription => 'Noch keine Beschreibung';

  @override
  String decksDeleteConfirm(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get decksDeleteEmpty => 'Dieser Stapel ist leer und wird entfernt.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Der Stapel und seine $count Karten werden entfernt.',
      one: 'Der Stapel und seine Karte werden entfernt.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '„$name“ gelöscht';
  }

  @override
  String get decksCreateFailed =>
      'Stapel konnte nicht erstellt werden. Bitte erneut versuchen.';

  @override
  String get decksDeleteFailed =>
      'Stapel konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String get decksSaveFailed =>
      'Änderungen konnten nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get quizDecksTitle => 'Quiz-Decks';

  @override
  String get quizDecksStartQuiz => 'Quiz starten';

  @override
  String get quizDecksEmpty => 'Noch keine Decks';

  @override
  String get quizDecksEmptyHelp =>
      'Erstelle ein Deck im Tab „Decks“ und komm dann hierher zurück, um dich testen zu lassen.';

  @override
  String quizDecksNotEnoughCards(int min) {
    return 'Füge mindestens $min Karten hinzu, um das Quiz freizuschalten';
  }

  @override
  String get detailNotFound => 'Diesen Stapel gibt es nicht mehr';

  @override
  String get detailBackToDecks => 'Zurück zu den Stapeln';

  @override
  String get detailProgress => 'FORTSCHRITT';

  @override
  String get detailMastered => 'Beherrscht';

  @override
  String get detailLearning => 'Am Lernen';

  @override
  String get detailCards => 'Karten';

  @override
  String get detailReviews => 'Wiederholungen';

  @override
  String get detailBrowseAll => 'Alle ansehen';

  @override
  String detailMore(int count) {
    return '+ $count weitere';
  }

  @override
  String get detailBack => 'Zurück';

  @override
  String get detailAddCardTooltip => 'Diesem Stapel eine Karte hinzufügen';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label: $count von $total Karten';
  }

  @override
  String get detailEmpty => 'Dieser Stapel ist leer';

  @override
  String get detailEmptyHelp =>
      'Füge ein paar Wörter hinzu, dann kannst du sofort loslegen.';

  @override
  String get detailAddCard => 'Karte hinzufügen';

  @override
  String get cardEditTitle => 'Karte bearbeiten';

  @override
  String get cardAddTitle => 'Neue Karte';

  @override
  String get cardDeckLabel => 'STAPEL *';

  @override
  String get cardFrontLabel => 'VORDERSEITE (ZIELWORT) *';

  @override
  String get cardBackLabel => 'RÜCKSEITE (ÜBERSETZUNG) *';

  @override
  String get cardFrontHint => 'z. B. Bonjour';

  @override
  String get cardBackHint => 'z. B. Hallo';

  @override
  String get cardExampleLabel => 'BEISPIELSATZ';

  @override
  String get cardExampleHint => 'Schreibe einen Beispielsatz...';

  @override
  String get cardImageLabel => 'BILD-URL';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError =>
      'Gib eine vollständige Bild-URL ein, die mit http:// oder https:// beginnt';

  @override
  String get cardAdd => 'Karte hinzufügen';

  @override
  String get cardAddFailed =>
      'Karte konnte nicht hinzugefügt werden. Bitte erneut versuchen.';

  @override
  String get libraryTitle => 'Kartenbibliothek';

  @override
  String get librarySearchHint => 'Vorder- oder Rückseite durchsuchen...';

  @override
  String get libraryAllDecks => 'Alle Stapel';

  @override
  String libraryTotalItems(int count) {
    return 'Gesamt: $count';
  }

  @override
  String get libraryShowingAll => 'Alle werden angezeigt';

  @override
  String get libraryFilteredByDeck => 'Nach Stapel gefiltert';

  @override
  String get libraryStudyThisDeck => 'Diesen Stapel lernen';

  @override
  String libraryNoMatch(String query) {
    return 'Keine Karte passt zu „$query“';
  }

  @override
  String get libraryNoneYet => 'Hier gibt es noch keine Karten';

  @override
  String get libraryCheckSpelling =>
      'Prüfe die Schreibweise oder entferne den Stapelfilter, um überall zu suchen.';

  @override
  String get libraryAddFirst =>
      'Füge dein erstes Wort hinzu — es taucht in der nächsten Lernsitzung auf.';

  @override
  String get libraryUnknownDeck => 'Unbekannter Stapel';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · $count Wiederholungen';
  }

  @override
  String get libraryEditCard => 'Karte bearbeiten';

  @override
  String get libraryDeleteCard => 'Karte löschen';

  @override
  String get libraryDeleteConfirmTitle => 'Karte löschen?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '„$term“ wird dauerhaft aus deiner Bibliothek entfernt.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '„$term“ gelöscht';
  }

  @override
  String get libraryDeleteFailed =>
      'Karte konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String get studyAllDecks => 'Alle Stapel';

  @override
  String studyDailyReview(String deck) {
    return 'Tägliche Wiederholung · $deck';
  }

  @override
  String studyWordHint(String term) {
    return 'Wort: $term. Tippe, um die Übersetzung zu sehen.';
  }

  @override
  String studyAnswerHint(String translation) {
    return 'Antwort: $translation. Tippe, um das Wort erneut zu sehen. Wische zum Überspringen oder bewerte unten.';
  }

  @override
  String get studyRateBelow =>
      'Bewerte unten oder wische, um ohne Bewertung zu überspringen';

  @override
  String get studyRecallHint =>
      'Erinnere dich an die Übersetzung und drehe zum Prüfen um';

  @override
  String get studyNothingDue => 'Gerade ist nichts fällig';

  @override
  String get studyBackToDecks => 'Zurück zu den Stapeln';

  @override
  String get studyQueueFailed =>
      'Deine Wiederholungsliste konnte nicht geladen werden';

  @override
  String get studyTapToSeeExample => '[ tippen für das Beispiel ]';

  @override
  String get studyShowExample => 'Beispielsatz anzeigen';

  @override
  String get studyTapToReveal => 'Tippen, um die Übersetzung zu sehen';

  @override
  String studyHearPronounced(String term) {
    return 'Aussprache von $term anhören';
  }

  @override
  String get studyHearIt => 'Anhören';

  @override
  String get studyTranslationLabel => 'ÜBERSETZUNG';

  @override
  String get studyExampleLabel => 'BEISPIEL';

  @override
  String get studyImageFailed => 'Bild konnte nicht geladen werden';

  @override
  String get studyAllCaughtUp => 'Alles erledigt!';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du hast alle $count heute fälligen Karten wiederholt',
      one: 'Du hast die heute fällige Karte wiederholt',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => 'Sicherheit';

  @override
  String get studyViewStats => 'Statistik ansehen';

  @override
  String get quizTimeUp => '⏰ Zeit abgelaufen! Das ist die richtige Antwort.';

  @override
  String quizProgress(int index, int total) {
    return 'F$index von $total';
  }

  @override
  String get quizFinish => 'Fertig';

  @override
  String get quizNextQuestion => 'Nächste Frage →';

  @override
  String get quizNotEnough => 'Nicht genug Karten für ein Quiz';

  @override
  String quizNotEnoughAll(int min) {
    return 'Füge mindestens $min Karten mit unterschiedlichen Übersetzungen hinzu, dann baut sich das Quiz von selbst.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck braucht mindestens $min Karten mit unterschiedlichen Übersetzungen, bevor daraus ein Quiz werden kann.';
  }

  @override
  String get quizBack => 'Zurück';

  @override
  String get quizPerfect => 'Perfekte Punktzahl!';

  @override
  String get quizGreat => 'Gut gemacht!';

  @override
  String get quizNice => 'Schöner Fortschritt';

  @override
  String get quizKeepPractising => 'Weiter üben';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return 'Du hast $score von $total richtig beantwortet';
  }

  @override
  String get quizScore => 'Punkte';

  @override
  String get quizDone => 'Fertig';

  @override
  String get statsTitle => 'Statistik';

  @override
  String get statsSubtitle => 'Dein Lernweg in Zahlen';

  @override
  String get statsStreak => 'Serie';

  @override
  String get statsReviews => 'Wiederholungen';

  @override
  String get statsRecall => 'Erinnerung';

  @override
  String statsTodayDelta(int count) {
    return '+$count heute';
  }

  @override
  String get statsNoData => 'keine Daten';

  @override
  String get statsHeatmap => 'Lern-Heatmap';

  @override
  String statsStreakSummary(int days, int total) {
    return '$days Tage Serie · $total Wiederholungen erfasst';
  }

  @override
  String statsReviewsLogged(int total) {
    return '$total Wiederholungen erfasst';
  }

  @override
  String get statsLess => 'Weniger';

  @override
  String get statsMore => 'Mehr';

  @override
  String get statsNoActivity => 'Noch keine Aktivität';

  @override
  String get statsLibraryBreakdown => 'Bibliotheksaufteilung';

  @override
  String get statsAchievements => 'Erfolge';

  @override
  String statsEarned(int earned, int total) {
    return '$earned / $total erreicht';
  }

  @override
  String get statsAddCards =>
      'Füge Karten hinzu, um deinen Fortschritt zu sehen';

  @override
  String get statsDaily => 'Täglich';

  @override
  String get statsWeekly => 'Wöchentlich';

  @override
  String get statsMonthly => 'Monatlich';

  @override
  String get statsChartDaily => 'Wiederholungen, letzte 7 Tage';

  @override
  String get statsChartWeekly => 'Wiederholungen, letzte 4 Wochen';

  @override
  String get statsChartMonthly => 'Wiederholungen, letzte 6 Monate';

  @override
  String statsChartTotal(int count) {
    return '$count gesamt';
  }

  @override
  String get profileStudyPreferences => 'Lerneinstellungen';

  @override
  String get profileNativeLanguage => 'Muttersprache';

  @override
  String get profileTargetLanguage => 'Zielsprache';

  @override
  String get profileLearningPurpose => 'Lernziel';

  @override
  String get profileStudyCategories => 'Lernthemen';

  @override
  String get profileDailyGoal => 'Tagesziel';

  @override
  String get profileAppPreferences => 'App-Einstellungen';

  @override
  String get profileDarkMode => 'Dunkler Modus';

  @override
  String get profileAppLanguage => 'App-Sprache';

  @override
  String get profileSoundEffects => 'Soundeffekte';

  @override
  String get profileDailyReminder => 'Tägliche Erinnerung';

  @override
  String get profileThemeColor => 'Themenfarbe';

  @override
  String get profileTextSize => 'Schriftgröße';

  @override
  String get profileDifficultyMode => 'Schwierigkeitsmodus';

  @override
  String get profileAccount => 'Konto';

  @override
  String get profileEditProfile => 'Profil bearbeiten';

  @override
  String get profilePrivacySecurity => 'Datenschutz und Sicherheit';

  @override
  String get profileUpgradePremium => 'Auf Premium upgraden';

  @override
  String get profileHelpSupport => 'Hilfe und Support';

  @override
  String get profileLogOut => 'Abmelden';

  @override
  String get profileLogOutConfirm => 'Abmelden?';

  @override
  String get profileLogOutBody =>
      'Du musst dich erneut anmelden, um weiterzulernen.';

  @override
  String get profileNoneYet => 'Noch keine';

  @override
  String profileSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String profileTopicsCount(int count) {
    return '$count Themen';
  }

  @override
  String profileMinutes(int min) {
    return '$min Min.';
  }

  @override
  String get profileNative => 'Muttersprache';

  @override
  String get profileEdit => 'Bearbeiten';

  @override
  String get profileFullName => 'Vollständiger Name';

  @override
  String get profileEmailAddress => 'E-Mail-Adresse';

  @override
  String get profileNameRequired => 'Name ist erforderlich';

  @override
  String get profileEmailRequired => 'E-Mail ist erforderlich';

  @override
  String get profileClose => 'Schließen';

  @override
  String get profileWhyLearning => 'Warum lernst du? Wähle alles Zutreffende.';

  @override
  String get profileDecreaseGoal => 'Tagesziel verringern';

  @override
  String get profileIncreaseGoal => 'Tagesziel erhöhen';

  @override
  String get profileYouSpeakThis => 'diese Sprache sprichst du';

  @override
  String get profileLearningThis => 'diese Sprache lernst du';

  @override
  String profileLevelBadge(int level) {
    return '⭐ Level $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ $days Tage Serie';
  }

  @override
  String get profileServerUnreachable =>
      'Server nicht erreichbar. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get profileSaveNameFailed =>
      'Dein Name konnte nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get profileSaveLanguageFailed =>
      'Deine Sprache konnte nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get profileSaveGoalFailed =>
      'Dein Tagesziel konnte nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get profileSaveCategoriesFailed =>
      'Deine Themen konnten nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get profileSavePurposesFailed =>
      'Deine Lernziele konnten nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get profileLoadCategoriesFailed =>
      'Themen konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get profileLoadPurposesFailed =>
      'Lernziele konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String wizardStep(int current, int total, String label) {
    return 'SCHRITT $current VON $total — $label';
  }

  @override
  String get wizardNativeLanguage => 'MUTTERSPRACHE';

  @override
  String get wizardTargetLanguage => 'ZIELSPRACHE';

  @override
  String get wizardTargetLevel => 'NIVEAU DER ZIELSPRACHE';

  @override
  String get wizardLearningPurpose => 'LERNZIEL';

  @override
  String get wizardTopics => 'THEMEN UND KATEGORIEN';

  @override
  String get wizardAge => 'DEIN ALTER';

  @override
  String get wizardDailyGoal => 'TAGESZIEL';

  @override
  String get wizardNativeQuestion => 'Was ist deine Muttersprache?';

  @override
  String get wizardTargetQuestion => 'Welche Sprache möchtest du lernen?';

  @override
  String wizardLevelQuestion(String language) {
    return 'Wie ist dein aktuelles Niveau in $language?';
  }

  @override
  String get wizardLevelHint =>
      'Wähle, was sich richtig anfühlt — jederzeit änderbar.';

  @override
  String get wizardGoalQuestion =>
      'Wie viel Zeit kannst du täglich investieren?';

  @override
  String wizardSelectedHint(int count) {
    return '$count ausgewählt · Du kannst das später ändern';
  }

  @override
  String get wizardNativePrefix => 'Muttersprache: ';

  @override
  String get wizardStart => 'Lass uns loslegen 🚀';

  @override
  String get wizardLoadFailed =>
      'Deine Einrichtungsoptionen konnten nicht geladen werden';

  @override
  String get wizardSaveFailed =>
      'Deine Themen oder dein Lernziel konnten nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get levelJustStarting => 'Ganz am Anfang';

  @override
  String get levelJustStartingDesc => 'Ich lerne die Grundlagen';

  @override
  String get levelBeginner => 'Anfänger';

  @override
  String get levelBeginnerDesc => 'Ich kenne ein paar Wörter und Sätze';

  @override
  String get levelIntermediate => 'Mittelstufe';

  @override
  String get levelIntermediateDesc => 'Ich kann einfache Gespräche führen';

  @override
  String get levelAdvanced => 'Fortgeschritten';

  @override
  String get levelAdvancedDesc => 'In den meisten Situationen sicher';

  @override
  String get levelFluent => 'Fließend';

  @override
  String get levelFluentDesc => 'Nahezu muttersprachlich';

  @override
  String get goalCasual => 'Locker';

  @override
  String get goalRegular => 'Regelmäßig';

  @override
  String get goalIntense => 'Intensiv';

  @override
  String goalWordsPerDay(int count) {
    return '~$count Wörter/Tag';
  }

  @override
  String get helpSearchHint => 'Hilfeartikel durchsuchen...';

  @override
  String get helpFrequentlyAsked => 'HÄUFIGE FRAGEN';

  @override
  String helpNoMatch(String query) {
    return 'Kein Artikel passt zu „$query“';
  }

  @override
  String get helpStillStuck => 'IMMER NOCH FESTGEFAHREN?';

  @override
  String get helpEmailSupport => 'E-Mail-Support';

  @override
  String get helpCommunityForum => 'Community-Forum';

  @override
  String get helpReportProblem => 'Problem melden';

  @override
  String get helpTheCommunityForum => 'Das Community-Forum';

  @override
  String get helpProblemReporting => 'Das Melden von Problemen';

  @override
  String get helpReportHint => 'Beschreibe, was passiert ist...';

  @override
  String get helpReportSend => 'Bericht senden';

  @override
  String get helpReportEmpty => 'Bitte beschreibe zuerst das Problem';

  @override
  String get helpReportSent => 'Danke, dein Bericht wurde gesendet';

  @override
  String helpComingSoon(String what) {
    return '$what ist in dieser Version noch nicht verfügbar.';
  }

  @override
  String get faqSpacedQ => 'Wie funktioniert verteilte Wiederholung?';

  @override
  String get faqSpacedA =>
      'Nach dem Umdrehen bewertest du, wie gut du die Karte konntest. Schwere Karten kommen früher zurück; als Leicht bewertete werden weiter hinausgeschoben — so verbringst du deine Zeit mit den Wörtern, die dir wirklich schwerfallen.';

  @override
  String get faqRatingsQ => 'Was bedeuten Nochmal, Schwer, Mittel und Leicht?';

  @override
  String get faqRatingsA =>
      'Sie legen fest, wann eine Karte wiederkommt. Nochmal holt sie in dieser Sitzung zurück, Schwer in etwa einem Tag, Mittel in ein paar Tagen und Leicht in etwa einer Woche.';

  @override
  String get faqReviewDueQ => 'Was bedeutet „Fällig“ auf einer Karte?';

  @override
  String get faqReviewDueA =>
      'Diese Karte hat ihr geplantes Wiederholungsdatum überschritten. Fällige Karten kommen an den Anfang deiner nächsten Lernsitzung.';

  @override
  String get faqCreateDeckQ => 'Wie erstelle ich einen Stapel?';

  @override
  String get faqCreateDeckA =>
      'Öffne den Tab Stapel und tippe oben rechts auf „Neuer Stapel“. Gib ihm einen Titel und fülle ihn dann über „Karte hinzufügen“.';

  @override
  String get faqPictureQ => 'Kann ich ein Bild zu einer Karte hinzufügen?';

  @override
  String get faqPictureA =>
      'Ja. Füge beim Anlegen oder Bearbeiten einer Karte eine Bild-URL in das Feld Bild-URL ein; sie erscheint auf der Antwortseite.';

  @override
  String get faqGoalQ => 'Wie wird mein Tagesziel berechnet?';

  @override
  String get faqGoalA =>
      'Der Ring auf dem Startbildschirm vergleicht die heute gelernten Minuten mit dem Tagesziel aus Profil → Lerneinstellungen.';

  @override
  String get faqStreakQ => 'Warum wurde meine Serie zurückgesetzt?';

  @override
  String get faqStreakA =>
      'Eine Serie zählt aufeinanderfolgende Tage mit mindestens einer abgeschlossenen Wiederholung. Ein ganz ausgelassener Tag beendet sie.';

  @override
  String get privacyIntro =>
      'Bestimme, was LanGigaCards über dich speichert und wie deine Lerndaten verwendet werden.';

  @override
  String get privacySectionPrivacy => 'Datenschutz';

  @override
  String get privacyUsageAnalytics => 'Nutzungsanalyse';

  @override
  String get privacyPersonalisedReview =>
      'Personalisierte Wiederholungsreihenfolge';

  @override
  String get privacyPublicProfile => 'Öffentliches Profil';

  @override
  String get privacyAnalyticsOn =>
      'Anonyme Nutzungsdaten helfen, den Wiederholungsalgorithmus zu verbessern.';

  @override
  String get privacyAnalyticsOff =>
      'Die Analyse ist aus. Es wird nichts darüber erfasst, wie du die App nutzt.';

  @override
  String get privacySectionSecurity => 'Sicherheit';

  @override
  String get privacyBiometric => 'Biometrische Entsperrung verlangen';

  @override
  String get privacyChangePassword => 'Passwort ändern';

  @override
  String get privacyActiveSessions => 'Aktive Sitzungen';

  @override
  String get privacySectionYourData => 'Deine Daten';

  @override
  String get privacyExportDecks => 'Meine Stapel exportieren';

  @override
  String get privacyDeleteAccount => 'Konto löschen';

  @override
  String get privacyDeleteConfirm => 'Konto löschen?';

  @override
  String get privacyDeleteBody =>
      'Damit würden deine Stapel, Karten und dein Wiederholungsverlauf dauerhaft entfernt. Das lässt sich nicht rückgängig machen.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what erfordert ein angemeldetes Konto, das diese Version noch nicht hat.';
  }

  @override
  String get privacyChangingPassword => 'Das Ändern des Passworts';

  @override
  String get privacySessionManagement => 'Die Sitzungsverwaltung';

  @override
  String privacyExportSaved(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String get changePasswordCurrentLabel => 'Aktuelles Passwort';

  @override
  String get changePasswordNewLabel => 'Neues Passwort';

  @override
  String get changePasswordSuccess => 'Passwort aktualisiert';

  @override
  String get changePasswordIncorrectCurrent =>
      'Das aktuelle Passwort ist falsch';

  @override
  String get privacyAccountDeletion => 'Das Löschen des Kontos';

  @override
  String get categoriesEditTitle => 'Themen bearbeiten';

  @override
  String get categoriesSearchHint => 'Themen durchsuchen...';

  @override
  String get languagesSearchHint => 'Sprachen durchsuchen...';

  @override
  String get languagesPopular => 'BELIEBT';

  @override
  String get reminderPermissionNeeded =>
      'Erinnerungen brauchen die Benachrichtigungserlaubnis. Aktiviere sie in den Systemeinstellungen.';

  @override
  String reminderSetFor(String time) {
    return 'Tägliche Erinnerung auf $time gesetzt';
  }

  @override
  String get reminderPickTime => 'Erinnere mich um';

  @override
  String get wizardPurposeQuestion => 'Warum lernst du diese Sprache?';

  @override
  String get wizardSelectAllThatApply => 'Wähle alles Zutreffende';

  @override
  String get wizardAgeQuestion => 'Wie alt bist du ungefähr?';

  @override
  String get wizardTopicsQuestion => 'Welche Themen möchtest du zuerst lernen?';

  @override
  String get wizardAgeNote =>
      'Wir nutzen dein Alter, um Barrierefreiheit und Lernerlebnis anzupassen.';

  @override
  String get studyAllUpToDate =>
      'Alle deine Karten sind aktuell. Füge neue Wörter hinzu oder komm wieder, wenn Wiederholungen fällig sind.';

  @override
  String studyDeckMastered(String deck) {
    return 'Du beherrschst alles in $deck. Füge neue Wörter hinzu, um weiterzumachen.';
  }

  @override
  String get ttsVoiceMissingUnknown =>
      'Die Stimme für diese Sprache ist auf deinem Gerät noch nicht installiert.';

  @override
  String ttsVoiceMissing(String language) {
    return 'Die Stimme für $language ist noch nicht installiert. Füge sie in den Sprachausgabe-Einstellungen des Systems hinzu.';
  }

  @override
  String get ttsUnavailable =>
      'Auf diesem Gerät ist keine Sprachausgabe verfügbar.';

  @override
  String get ttsPlay => 'Aussprache abspielen';

  @override
  String get ttsNothing => 'Nichts vorzulesen';

  @override
  String ttsPlayOf(String text) {
    return 'Aussprache von $text abspielen';
  }

  @override
  String get reminderNotificationTitle => 'Zeit zu wiederholen';

  @override
  String get reminderNotificationBody =>
      'Deine Karten warten — ein paar Minuten halten die Serie am Leben.';

  @override
  String get splashTagline => 'LERNE JEDE SPRACHE';

  @override
  String get profileLearningLabel => 'lernt';
}
