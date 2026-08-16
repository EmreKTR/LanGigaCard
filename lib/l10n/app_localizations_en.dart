// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appLanguageTitle => 'Choose Your App Language';

  @override
  String get appLanguageSubtitle =>
      'Pick the language you want to use LanGigaCards in.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSignIn => 'Sign In';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonGetStarted => 'Get Started';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRequiredField => 'This field is required';

  @override
  String get commonSomethingWrong => 'Something went wrong. Please try again.';

  @override
  String get commonNetworkError =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get onboardingSlide1Title => 'Learn with Flashcards';

  @override
  String get onboardingSlide1Body =>
      'Master vocabulary through our proven spaced repetition system. Review cards at the perfect moment to maximize memory retention.';

  @override
  String get onboardingSlide2Title => 'Track Your Progress';

  @override
  String get onboardingSlide2Body =>
      'Visualize your learning journey with beautiful statistics. Watch your vocabulary grow day by day with streaks and achievements.';

  @override
  String get onboardingSlide3Title => 'Reach Your Goals';

  @override
  String get onboardingSlide3Body =>
      'Set personalized daily goals and stay motivated. Our smart algorithm adapts to your pace, making learning effortless.';

  @override
  String get onboardingHaveAccount => 'Already have an account?';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue your learning journey';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginOrContinueWith => 'or continue with';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginInvalidCredentials =>
      'Incorrect email or password. Create an account if you don\'t have one yet.';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerBackToSignIn => 'Back to sign in';

  @override
  String get registerSubtitle =>
      'Your details — languages and study preferences come next.';

  @override
  String get registerFirstName => 'First Name';

  @override
  String get registerLastName => 'Last Name';

  @override
  String get registerEmail => 'Email Address';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerPasswordHint => 'Min. 8 characters';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerConfirmHint => 'Re-enter your password';

  @override
  String get registerInvalidEmail => 'Please enter a valid email address';

  @override
  String get registerPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get registerPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get registerEmailTaken => 'An account with this email already exists.';

  @override
  String get verifyTitle => 'Verify Your Email';

  @override
  String verifySubtitle(String email) {
    return 'We sent a 6-digit code to $email. Enter it below to confirm your account.';
  }

  @override
  String get verifyNoCode => 'Didn\'t get a code?';

  @override
  String get verifyResend => 'Resend code';

  @override
  String get verifySending => 'Sending…';

  @override
  String get verifyAction => 'Verify';

  @override
  String verifyEnterAllDigits(int count) {
    return 'Enter all $count digits';
  }

  @override
  String get verifyIncorrect => 'Incorrect code, please try again';

  @override
  String get verifyTooManyAttempts =>
      'Too many attempts. Tap \"Resend code\" for a new one.';

  @override
  String get verifyResent => 'A new code was sent to your email';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotSubtitle =>
      'Enter the email you signed up with and we\'ll send you a link to choose a new password.';

  @override
  String get forgotEmailLabel => 'Email address';

  @override
  String get forgotInvalidEmail => 'Enter a valid email address';

  @override
  String get forgotSend => 'Send reset link';

  @override
  String get forgotCheckInbox => 'Check your inbox';

  @override
  String forgotSentTo(String email) {
    return 'If an account exists for $email, a reset link is on its way.';
  }

  @override
  String get forgotNoMailServer =>
      'This build has no mail server connected, so no email is actually sent.';

  @override
  String get forgotUseDifferent => 'Use a different email';

  @override
  String get navHome => 'Home';

  @override
  String get navDecks => 'Decks';

  @override
  String get navQuiz => 'Quiz';

  @override
  String get navStats => 'Stats';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreetingMorning => 'Good morning,';

  @override
  String get homeGreetingAfternoon => 'Good afternoon,';

  @override
  String get homeGreetingEvening => 'Good evening,';

  @override
  String get homeContinueLearning => 'CONTINUE LEARNING';

  @override
  String homeCardsDue(int count) {
    return '$count cards due';
  }

  @override
  String homeMinGoal(int minutes) {
    return '$minutes min goal';
  }

  @override
  String get homeFinishSetup =>
      'Finish setting up your profile to get your first deck.';

  @override
  String get homeWords => 'Words';

  @override
  String get homeAccuracy => 'Accuracy';

  @override
  String get homeStreak => 'Streak';

  @override
  String get homeQuickActions => 'QUICK ACTIONS';

  @override
  String get homeAddWord => 'Add Word';

  @override
  String get homeYourTopics => 'Your Topics';

  @override
  String get homeRecentlyLearned => 'Recently Learned';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get shellProfileLoadFailed => 'Couldn\'t load your profile';

  @override
  String get shellCheckConnection => 'Check your connection and try again.';

  @override
  String get shellSyncDroppedOne =>
      '1 change couldn\'t be saved and was discarded.';

  @override
  String shellSyncDroppedMany(int count) {
    return '$count changes couldn\'t be saved and were discarded.';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String get decksTitle => 'My Decks';

  @override
  String get decksNewDeck => 'New Deck';

  @override
  String decksSummary(int decks, int due) {
    return '$decks decks · $due cards due today';
  }

  @override
  String decksDueForReview(int count) {
    return '$count cards due for review';
  }

  @override
  String get decksSortedByUrgency => 'Sorted by urgency · Tap to start session';

  @override
  String get decksSearchHint => 'Search decks...';

  @override
  String decksNoMatch(String query) {
    return 'No decks match \"$query\"';
  }

  @override
  String get decksNoneYet => 'No decks yet';

  @override
  String get decksTryDifferentSearch =>
      'Try a different search, or create a deck with this name.';

  @override
  String get decksEmptyHelp =>
      'Decks group the words you want to learn. Create your first one to get started.';

  @override
  String get decksCreateADeck => 'Create a deck';

  @override
  String get decksOptions => 'Deck options';

  @override
  String get decksQuizThis => 'Quiz this deck';

  @override
  String get decksRename => 'Rename deck';

  @override
  String get decksDelete => 'Delete deck';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => 'Review Due';

  @override
  String decksReviewCount(int count) {
    return '$count reviews';
  }

  @override
  String get decksMastery => 'Mastery';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Study $count cards',
      one: 'Study 1 card',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'All caught up';

  @override
  String get decksBrowse => 'Browse';

  @override
  String get decksRenameTitle => 'Rename Deck';

  @override
  String get decksCreateTitle => 'Create New Deck';

  @override
  String get decksTitleLabel => 'TITLE *';

  @override
  String get decksTitleHint => 'e.g. French Basics';

  @override
  String get decksDescriptionLabel => 'DESCRIPTION (OPTIONAL)';

  @override
  String get decksDescriptionHint => 'Describe what this deck covers...';

  @override
  String get decksSaveChanges => 'Save Changes';

  @override
  String get decksCreateDeck => 'Create Deck';

  @override
  String get decksNoDescription => 'No description yet';

  @override
  String decksDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get decksDeleteEmpty => 'This deck is empty and will be removed.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The deck and its $count cards will be removed.',
      one: 'The deck and its 1 card will be removed.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '\"$name\" deleted';
  }

  @override
  String get decksCreateFailed =>
      'Couldn\'t create the deck. Please try again.';

  @override
  String get decksDeleteFailed =>
      'Couldn\'t delete the deck. Please try again.';

  @override
  String get decksSaveFailed => 'Couldn\'t save changes. Please try again.';

  @override
  String get detailNotFound => 'This deck no longer exists';

  @override
  String get detailBackToDecks => 'Back to decks';

  @override
  String get detailProgress => 'PROGRESS';

  @override
  String get detailMastered => 'Mastered';

  @override
  String get detailLearning => 'Learning';

  @override
  String get detailCards => 'Cards';

  @override
  String get detailReviews => 'Reviews';

  @override
  String get detailBrowseAll => 'Browse all';

  @override
  String detailMore(int count) {
    return '+ $count more';
  }

  @override
  String get detailBack => 'Back';

  @override
  String get detailAddCardTooltip => 'Add a card to this deck';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label: $count of $total cards';
  }

  @override
  String get detailEmpty => 'This deck is empty';

  @override
  String get detailEmptyHelp =>
      'Add a few words and you can start studying straight away.';

  @override
  String get detailAddCard => 'Add a card';

  @override
  String get cardEditTitle => 'Edit Card';

  @override
  String get cardAddTitle => 'Add New Card';

  @override
  String get cardDeckLabel => 'DECK *';

  @override
  String get cardFrontLabel => 'FRONT (TARGET WORD) *';

  @override
  String get cardBackLabel => 'BACK (TRANSLATION) *';

  @override
  String get cardFrontHint => 'e.g. Bonjour';

  @override
  String get cardBackHint => 'e.g. Hello';

  @override
  String get cardExampleLabel => 'EXAMPLE SENTENCE';

  @override
  String get cardExampleHint => 'Write an example sentence...';

  @override
  String get cardImageLabel => 'IMAGE URL';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError =>
      'Enter a full image URL starting with http:// or https://';

  @override
  String get cardAdd => 'Add Card';

  @override
  String get cardAddFailed => 'Couldn\'t add the card. Please try again.';

  @override
  String get libraryTitle => 'Card Library';

  @override
  String get librarySearchHint => 'Search front or back...';

  @override
  String get libraryAllDecks => 'All Decks';

  @override
  String libraryTotalItems(int count) {
    return 'Total Items: $count';
  }

  @override
  String get libraryShowingAll => 'Showing all';

  @override
  String get libraryFilteredByDeck => 'Filtered by deck';

  @override
  String get libraryStudyThisDeck => 'Study This Deck';

  @override
  String libraryNoMatch(String query) {
    return 'No cards match \"$query\"';
  }

  @override
  String get libraryNoneYet => 'No cards here yet';

  @override
  String get libraryCheckSpelling =>
      'Check the spelling, or clear the deck filter to search everywhere.';

  @override
  String get libraryAddFirst =>
      'Add your first word and it will show up in your next study session.';

  @override
  String get libraryUnknownDeck => 'Unknown deck';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · $count reviews';
  }

  @override
  String get libraryEditCard => 'Edit card';

  @override
  String get libraryDeleteCard => 'Delete card';

  @override
  String get libraryDeleteConfirmTitle => 'Delete card?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '\"$term\" will be permanently removed from your library.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '\"$term\" deleted';
  }

  @override
  String get libraryDeleteFailed =>
      'Couldn\'t delete the card. Please try again.';

  @override
  String get studyAllDecks => 'All decks';

  @override
  String studyDailyReview(String deck) {
    return 'Daily Review · $deck';
  }

  @override
  String studyWordHint(String term) {
    return 'Word: $term. Tap to reveal the translation.';
  }

  @override
  String studyAnswerHint(String translation) {
    return 'Answer: $translation. Tap to see the word again. Swipe to skip, or rate below.';
  }

  @override
  String get studyRateBelow => 'Rate below, or swipe to skip without rating';

  @override
  String get studyRecallHint => 'Recall the translation, then flip to check';

  @override
  String get studyNothingDue => 'Nothing due right now';

  @override
  String get studyBackToDecks => 'Back to Decks';

  @override
  String get studyQueueFailed => 'Couldn\'t load your review queue';

  @override
  String get studyTapToSeeExample => '[ tap to see example ]';

  @override
  String get studyShowExample => 'Show Example Sentence';

  @override
  String get studyTapToReveal => 'Tap to reveal translation';

  @override
  String studyHearPronounced(String term) {
    return 'Hear $term pronounced';
  }

  @override
  String get studyHearIt => 'Hear it';

  @override
  String get studyTranslationLabel => 'TRANSLATION';

  @override
  String get studyExampleLabel => 'EXAMPLE';

  @override
  String get studyImageFailed => 'Image didn\'t load';

  @override
  String get studyAllCaughtUp => 'All Caught Up!';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You reviewed all $count cards due today',
      one: 'You reviewed the 1 card due today',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => 'confidence';

  @override
  String get studyViewStats => 'View Stats';

  @override
  String get quizTimeUp => '⏰ Time\'s up! Here\'s the correct answer.';

  @override
  String quizProgress(int index, int total) {
    return 'Q$index of $total';
  }

  @override
  String get quizFinish => 'Finish';

  @override
  String get quizNextQuestion => 'Next Question →';

  @override
  String get quizNotEnough => 'Not enough cards to quiz';

  @override
  String quizNotEnoughAll(int min) {
    return 'Add at least $min cards with different translations and the quiz will build itself from them.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck needs at least $min cards with different translations before it can be quizzed.';
  }

  @override
  String get quizBack => 'Back';

  @override
  String get quizPerfect => 'Perfect score!';

  @override
  String get quizGreat => 'Great work!';

  @override
  String get quizNice => 'Nice progress';

  @override
  String get quizKeepPractising => 'Keep practising';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return 'You answered $score of $total correctly';
  }

  @override
  String get quizScore => 'score';

  @override
  String get quizDone => 'Done';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsSubtitle => 'Your learning journey in numbers';

  @override
  String get statsStreak => 'Streak';

  @override
  String get statsReviews => 'Reviews';

  @override
  String get statsRecall => 'Recall';

  @override
  String statsTodayDelta(int count) {
    return '+$count today';
  }

  @override
  String get statsNoData => 'no data';

  @override
  String get statsHeatmap => 'Learning Heatmap';

  @override
  String statsStreakSummary(int days, int total) {
    return '$days-day streak · $total reviews logged';
  }

  @override
  String statsReviewsLogged(int total) {
    return '$total reviews logged';
  }

  @override
  String get statsLess => 'Less';

  @override
  String get statsMore => 'More';

  @override
  String get statsNoActivity => 'No activity yet';

  @override
  String get statsLibraryBreakdown => 'Library Breakdown';

  @override
  String get statsAchievements => 'Achievements';

  @override
  String statsEarned(int earned, int total) {
    return '$earned / $total earned';
  }

  @override
  String get statsAddCards => 'Add some cards to see your progress';

  @override
  String get statsDaily => 'Daily';

  @override
  String get statsWeekly => 'Weekly';

  @override
  String get statsMonthly => 'Monthly';

  @override
  String get statsChartDaily => 'Reviews, last 7 days';

  @override
  String get statsChartWeekly => 'Reviews, last 4 weeks';

  @override
  String get statsChartMonthly => 'Reviews, last 6 months';

  @override
  String statsChartTotal(int count) {
    return '$count total';
  }

  @override
  String get profileStudyPreferences => 'Study Preferences';

  @override
  String get profileNativeLanguage => 'Native Language';

  @override
  String get profileTargetLanguage => 'Target Language';

  @override
  String get profileLearningPurpose => 'Learning Purpose';

  @override
  String get profileStudyCategories => 'Study Categories';

  @override
  String get profileDailyGoal => 'Daily Goal';

  @override
  String get profileAppPreferences => 'App Preferences';

  @override
  String get profileDarkMode => 'Dark Mode';

  @override
  String get profileSoundEffects => 'Sound Effects';

  @override
  String get profileDailyReminder => 'Daily Reminder';

  @override
  String get profileThemeColor => 'Theme Color';

  @override
  String get profileTextSize => 'Text Size';

  @override
  String get profileDifficultyMode => 'Difficulty Mode';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profilePrivacySecurity => 'Privacy & Security';

  @override
  String get profileUpgradePremium => 'Upgrade to Premium';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileLogOut => 'Log Out';

  @override
  String get profileLogOutConfirm => 'Log out?';

  @override
  String get profileLogOutBody =>
      'You will need to sign in again to continue learning.';

  @override
  String get profileNoneYet => 'None yet';

  @override
  String profileSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String profileTopicsCount(int count) {
    return '$count topics';
  }

  @override
  String profileMinutes(int min) {
    return '$min min';
  }

  @override
  String get profileNative => 'Native';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileEmailAddress => 'Email Address';

  @override
  String get profileNameRequired => 'Name is required';

  @override
  String get profileEmailRequired => 'Email is required';

  @override
  String get profileClose => 'Close';

  @override
  String get profileWhyLearning =>
      'Why are you learning? Pick as many as apply.';

  @override
  String get profileDecreaseGoal => 'Decrease daily goal';

  @override
  String get profileIncreaseGoal => 'Increase daily goal';

  @override
  String get profileYouSpeakThis => 'you speak this';

  @override
  String get profileLearningThis => 'you\'re learning this';

  @override
  String profileLevelBadge(int level) {
    return '⭐ Level $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ $days-day streak';
  }

  @override
  String get profileServerUnreachable =>
      'Couldn\'t reach the server. Check your connection and try again.';

  @override
  String get profileSaveNameFailed =>
      'Couldn\'t save your name. Please try again.';

  @override
  String get profileSaveLanguageFailed =>
      'Couldn\'t save your language. Please try again.';

  @override
  String get profileSaveGoalFailed =>
      'Couldn\'t save your daily goal. Please try again.';

  @override
  String get profileSaveCategoriesFailed =>
      'Couldn\'t save your categories. Please try again.';

  @override
  String get profileSavePurposesFailed =>
      'Couldn\'t save your learning purposes. Please try again.';

  @override
  String get profileLoadCategoriesFailed =>
      'Couldn\'t load categories. Check your connection and try again.';

  @override
  String get profileLoadPurposesFailed =>
      'Couldn\'t load learning purposes. Check your connection and try again.';

  @override
  String wizardStep(int current, int total, String label) {
    return 'STEP $current OF $total — $label';
  }

  @override
  String get wizardNativeLanguage => 'NATIVE LANGUAGE';

  @override
  String get wizardTargetLanguage => 'TARGET LANGUAGE';

  @override
  String get wizardTargetLevel => 'TARGET LANGUAGE LEVEL';

  @override
  String get wizardLearningPurpose => 'LEARNING PURPOSE';

  @override
  String get wizardTopics => 'TOPICS & CATEGORIES';

  @override
  String get wizardAge => 'YOUR AGE';

  @override
  String get wizardDailyGoal => 'DAILY GOAL';

  @override
  String get wizardNativeQuestion => 'What is your native language?';

  @override
  String get wizardTargetQuestion => 'Which language do you want to learn?';

  @override
  String wizardLevelQuestion(String language) {
    return 'What\'s your current level in $language?';
  }

  @override
  String get wizardLevelHint =>
      'Pick what feels right — you can adjust this anytime.';

  @override
  String get wizardGoalQuestion => 'How much time can you dedicate daily?';

  @override
  String wizardSelectedHint(int count) {
    return '$count selected · You can change this later';
  }

  @override
  String get wizardNativePrefix => 'Native: ';

  @override
  String get wizardStart => 'Let\'s Start Learning 🚀';

  @override
  String get wizardLoadFailed => 'Couldn\'t load your setup options';

  @override
  String get wizardSaveFailed =>
      'Couldn\'t save your topics or learning purpose. Please try again.';

  @override
  String get levelJustStarting => 'Just Starting';

  @override
  String get levelJustStartingDesc => 'Learning the basics';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelBeginnerDesc => 'Know some words and phrases';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelIntermediateDesc => 'Can have simple conversations';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelAdvancedDesc => 'Comfortable in most situations';

  @override
  String get levelFluent => 'Fluent';

  @override
  String get levelFluentDesc => 'Near-native proficiency';

  @override
  String get goalCasual => 'Casual';

  @override
  String get goalRegular => 'Regular';

  @override
  String get goalIntense => 'Intense';

  @override
  String goalWordsPerDay(int count) {
    return '~$count words/day';
  }

  @override
  String get helpSearchHint => 'Search help articles...';

  @override
  String get helpFrequentlyAsked => 'FREQUENTLY ASKED';

  @override
  String helpNoMatch(String query) {
    return 'No articles match \"$query\"';
  }

  @override
  String get helpStillStuck => 'STILL STUCK?';

  @override
  String get helpEmailSupport => 'Email support';

  @override
  String get helpCommunityForum => 'Community forum';

  @override
  String get helpReportProblem => 'Report a problem';

  @override
  String get helpTheCommunityForum => 'The community forum';

  @override
  String get helpProblemReporting => 'Problem reporting';

  @override
  String helpComingSoon(String what) {
    return '$what is not available in this build yet.';
  }

  @override
  String get faqSpacedQ => 'How does spaced repetition work?';

  @override
  String get faqSpacedA =>
      'After you flip a card you rate how well you knew it. Cards you find hard come back sooner; cards you rate Easy are pushed further out, so you spend your time on the words you actually struggle with.';

  @override
  String get faqRatingsQ => 'What do Again, Hard, Medium and Easy mean?';

  @override
  String get faqRatingsA =>
      'They set how soon a card returns. Again brings it back in this session, Hard in about a day, Medium in a few days, and Easy in about a week.';

  @override
  String get faqReviewDueQ => 'What does \"Review Due\" mean on a card?';

  @override
  String get faqReviewDueA =>
      'That card has passed its scheduled review date. Review Due cards are put at the front of your next study session.';

  @override
  String get faqCreateDeckQ => 'How do I create a deck?';

  @override
  String get faqCreateDeckA =>
      'Open the Decks tab and tap \"New Deck\" in the top right. Give it a title, then use \"Add Card\" from the deck to start filling it.';

  @override
  String get faqPictureQ => 'Can I add a picture to a card?';

  @override
  String get faqPictureA =>
      'Yes. When adding or editing a card, paste an image URL into the Image URL field and it will appear on the answer side.';

  @override
  String get faqGoalQ => 'How is my daily goal calculated?';

  @override
  String get faqGoalA =>
      'The ring on the home screen compares the minutes you have studied today against the daily goal set in Profile → Study Preferences.';

  @override
  String get faqStreakQ => 'Why did my streak reset?';

  @override
  String get faqStreakA =>
      'A streak counts consecutive days with at least one completed review. Missing a full day ends it.';

  @override
  String get privacyIntro =>
      'Control what LanGigaCards stores about you and how your learning data is used.';

  @override
  String get privacySectionPrivacy => 'Privacy';

  @override
  String get privacyUsageAnalytics => 'Usage analytics';

  @override
  String get privacyPersonalisedReview => 'Personalised review order';

  @override
  String get privacyPublicProfile => 'Public profile';

  @override
  String get privacyAnalyticsOn =>
      'Anonymous usage data helps improve the review algorithm.';

  @override
  String get privacyAnalyticsOff =>
      'Analytics are off. Nothing about how you use the app is collected.';

  @override
  String get privacySectionSecurity => 'Security';

  @override
  String get privacyBiometric => 'Require biometric unlock';

  @override
  String get privacyChangePassword => 'Change password';

  @override
  String get privacyActiveSessions => 'Active sessions';

  @override
  String get privacySectionYourData => 'Your data';

  @override
  String get privacyExportDecks => 'Export my decks';

  @override
  String get privacyDeleteAccount => 'Delete account';

  @override
  String get privacyDeleteConfirm => 'Delete account?';

  @override
  String get privacyDeleteBody =>
      'This would permanently remove your decks, cards and review history. This cannot be undone.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what needs a signed-in account, which this build does not have yet.';
  }

  @override
  String get privacyChangingPassword => 'Changing your password';

  @override
  String get privacySessionManagement => 'Session management';

  @override
  String get privacyExportingDecks => 'Exporting your decks';

  @override
  String get privacyAccountDeletion => 'Account deletion';
}
