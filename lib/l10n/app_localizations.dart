import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @appLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your App Language'**
  String get appLanguageTitle;

  /// No description provided for @appLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the language you want to use LanGigaCards in.'**
  String get appLanguageSubtitle;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get commonSignIn;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get commonGetStarted;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get commonRequiredField;

  /// No description provided for @commonSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWrong;

  /// No description provided for @commonNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get commonNetworkError;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Learn with Flashcards'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Master vocabulary through our proven spaced repetition system. Review cards at the perfect moment to maximize memory retention.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Visualize your learning journey with beautiful statistics. Watch your vocabulary grow day by day with streaks and achievements.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Reach Your Goals'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Set personalized daily goals and stay motivated. Our smart algorithm adapts to your pace, making learning effortless.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get onboardingHaveAccount;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your learning journey'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get loginRememberMe;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get loginOrContinueWith;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Create an account if you don\'t have one yet.'**
  String get loginInvalidCredentials;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get registerBackToSignIn;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your details — languages and study preferences come next.'**
  String get registerSubtitle;

  /// No description provided for @registerFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get registerFirstName;

  /// No description provided for @registerLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get registerLastName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get registerConfirmHint;

  /// No description provided for @registerInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get registerInvalidEmail;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get registerPasswordTooShort;

  /// No description provided for @registerPasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get registerPasswordsDontMatch;

  /// No description provided for @registerEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get registerEmailTaken;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. Enter it below to confirm your account.'**
  String verifySubtitle(String email);

  /// No description provided for @verifyNoCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get a code?'**
  String get verifyNoCode;

  /// No description provided for @verifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyResend;

  /// No description provided for @verifySending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get verifySending;

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// No description provided for @verifyEnterAllDigits.
  ///
  /// In en, this message translates to:
  /// **'Enter all {count} digits'**
  String verifyEnterAllDigits(int count);

  /// No description provided for @verifyIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code, please try again'**
  String get verifyIncorrect;

  /// No description provided for @verifyTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Tap \"Resend code\" for a new one.'**
  String get verifyTooManyAttempts;

  /// No description provided for @verifyResent.
  ///
  /// In en, this message translates to:
  /// **'A new code was sent to your email'**
  String get verifyResent;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email you signed up with and we\'ll send you a link to choose a new password.'**
  String get forgotSubtitle;

  /// No description provided for @forgotEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get forgotEmailLabel;

  /// No description provided for @forgotInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get forgotInvalidEmail;

  /// No description provided for @forgotSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotSend;

  /// No description provided for @forgotCheckInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get forgotCheckInbox;

  /// No description provided for @forgotSentTo.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a reset link is on its way.'**
  String forgotSentTo(String email);

  /// No description provided for @forgotNoMailServer.
  ///
  /// In en, this message translates to:
  /// **'This build has no mail server connected, so no email is actually sent.'**
  String get forgotNoMailServer;

  /// No description provided for @forgotUseDifferent.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get forgotUseDifferent;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDecks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navDecks;

  /// No description provided for @navQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get navQuiz;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get homeGreetingEvening;

  /// No description provided for @homeContinueLearning.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE LEARNING'**
  String get homeContinueLearning;

  /// No description provided for @homeCardsDue.
  ///
  /// In en, this message translates to:
  /// **'{count} cards due'**
  String homeCardsDue(int count);

  /// No description provided for @homeMinGoal.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min goal'**
  String homeMinGoal(int minutes);

  /// No description provided for @homeFinishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your profile to get your first deck.'**
  String get homeFinishSetup;

  /// No description provided for @homeWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get homeWords;

  /// No description provided for @homeAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get homeAccuracy;

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get homeStreak;

  /// No description provided for @homeContinueQuizLabel.
  ///
  /// In en, this message translates to:
  /// **'QUIZ'**
  String get homeContinueQuizLabel;

  /// No description provided for @homeContinueQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Quiz'**
  String get homeContinueQuizTitle;

  /// No description provided for @homeContinueQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{deck} · {count, plural, =1{1 question} other{{count} questions}}'**
  String homeContinueQuizSubtitle(String deck, int count);

  /// No description provided for @homeReviewDueBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 due} other{{count} due}}'**
  String homeReviewDueBadge(int count);

  /// No description provided for @homeReviewDoneBadge.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homeReviewDoneBadge;

  /// No description provided for @homeYourTopics.
  ///
  /// In en, this message translates to:
  /// **'Your Topics'**
  String get homeYourTopics;

  /// No description provided for @homeRecentlyLearned.
  ///
  /// In en, this message translates to:
  /// **'Recently Learned'**
  String get homeRecentlyLearned;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @shellProfileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile'**
  String get shellProfileLoadFailed;

  /// No description provided for @shellCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get shellCheckConnection;

  /// No description provided for @shellSyncDroppedOne.
  ///
  /// In en, this message translates to:
  /// **'1 change couldn\'t be saved and was discarded.'**
  String get shellSyncDroppedOne;

  /// No description provided for @shellSyncDroppedMany.
  ///
  /// In en, this message translates to:
  /// **'{count} changes couldn\'t be saved and were discarded.'**
  String shellSyncDroppedMany(int count);

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @decksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Decks'**
  String get decksTitle;

  /// No description provided for @decksNewDeck.
  ///
  /// In en, this message translates to:
  /// **'New Deck'**
  String get decksNewDeck;

  /// No description provided for @decksSummary.
  ///
  /// In en, this message translates to:
  /// **'{decks} decks · {due} cards due today'**
  String decksSummary(int decks, int due);

  /// No description provided for @decksDueForReview.
  ///
  /// In en, this message translates to:
  /// **'{count} cards due for review'**
  String decksDueForReview(int count);

  /// No description provided for @decksSortedByUrgency.
  ///
  /// In en, this message translates to:
  /// **'Sorted by urgency · Tap to start session'**
  String get decksSortedByUrgency;

  /// No description provided for @decksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search decks...'**
  String get decksSearchHint;

  /// No description provided for @decksNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No decks match \"{query}\"'**
  String decksNoMatch(String query);

  /// No description provided for @decksNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get decksNoneYet;

  /// No description provided for @decksTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search, or create a deck with this name.'**
  String get decksTryDifferentSearch;

  /// No description provided for @decksEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Decks group the words you want to learn. Create your first one to get started.'**
  String get decksEmptyHelp;

  /// No description provided for @decksCreateADeck.
  ///
  /// In en, this message translates to:
  /// **'Create a deck'**
  String get decksCreateADeck;

  /// No description provided for @decksOptions.
  ///
  /// In en, this message translates to:
  /// **'Deck options'**
  String get decksOptions;

  /// No description provided for @decksQuizThis.
  ///
  /// In en, this message translates to:
  /// **'Quiz this deck'**
  String get decksQuizThis;

  /// No description provided for @decksRename.
  ///
  /// In en, this message translates to:
  /// **'Rename deck'**
  String get decksRename;

  /// No description provided for @decksDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get decksDelete;

  /// No description provided for @decksCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String decksCardCount(int count);

  /// No description provided for @decksReviewDue.
  ///
  /// In en, this message translates to:
  /// **'Review Due'**
  String get decksReviewDue;

  /// No description provided for @decksReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String decksReviewCount(int count);

  /// No description provided for @decksMastery.
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get decksMastery;

  /// No description provided for @decksStudyCards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Study 1 card} other{Study {count} cards}}'**
  String decksStudyCards(int count);

  /// No description provided for @decksAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get decksAllCaughtUp;

  /// No description provided for @decksBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get decksBrowse;

  /// No description provided for @decksRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Deck'**
  String get decksRenameTitle;

  /// No description provided for @decksCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Deck'**
  String get decksCreateTitle;

  /// No description provided for @decksTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'TITLE *'**
  String get decksTitleLabel;

  /// No description provided for @decksTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. French Basics'**
  String get decksTitleHint;

  /// No description provided for @decksDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION (OPTIONAL)'**
  String get decksDescriptionLabel;

  /// No description provided for @decksDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what this deck covers...'**
  String get decksDescriptionHint;

  /// No description provided for @decksSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get decksSaveChanges;

  /// No description provided for @decksCreateDeck.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get decksCreateDeck;

  /// No description provided for @decksNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet'**
  String get decksNoDescription;

  /// No description provided for @decksDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String decksDeleteConfirm(String name);

  /// No description provided for @decksDeleteEmpty.
  ///
  /// In en, this message translates to:
  /// **'This deck is empty and will be removed.'**
  String get decksDeleteEmpty;

  /// No description provided for @decksDeleteWithCards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The deck and its 1 card will be removed.} other{The deck and its {count} cards will be removed.}}'**
  String decksDeleteWithCards(int count);

  /// No description provided for @decksDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted'**
  String decksDeleted(String name);

  /// No description provided for @decksCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the deck. Please try again.'**
  String get decksCreateFailed;

  /// No description provided for @decksDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the deck. Please try again.'**
  String get decksDeleteFailed;

  /// No description provided for @decksSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save changes. Please try again.'**
  String get decksSaveFailed;

  /// No description provided for @quizDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Decks'**
  String get quizDecksTitle;

  /// No description provided for @quizDecksStartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get quizDecksStartQuiz;

  /// No description provided for @quizDecksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get quizDecksEmpty;

  /// No description provided for @quizDecksEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Create a deck from the Decks tab, then come back here to quiz yourself on it.'**
  String get quizDecksEmptyHelp;

  /// No description provided for @quizDecksNotEnoughCards.
  ///
  /// In en, this message translates to:
  /// **'Add at least {min} cards to unlock quiz'**
  String quizDecksNotEnoughCards(int min);

  /// No description provided for @detailNotFound.
  ///
  /// In en, this message translates to:
  /// **'This deck no longer exists'**
  String get detailNotFound;

  /// No description provided for @detailBackToDecks.
  ///
  /// In en, this message translates to:
  /// **'Back to decks'**
  String get detailBackToDecks;

  /// No description provided for @detailProgress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get detailProgress;

  /// No description provided for @detailMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get detailMastered;

  /// No description provided for @detailLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get detailLearning;

  /// No description provided for @detailCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get detailCards;

  /// No description provided for @detailReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get detailReviews;

  /// No description provided for @detailBrowseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse all'**
  String get detailBrowseAll;

  /// No description provided for @detailMore.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String detailMore(int count);

  /// No description provided for @detailBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get detailBack;

  /// No description provided for @detailAddCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a card to this deck'**
  String get detailAddCardTooltip;

  /// No description provided for @detailBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{label}: {count} of {total} cards'**
  String detailBreakdown(String label, int count, int total);

  /// No description provided for @detailEmpty.
  ///
  /// In en, this message translates to:
  /// **'This deck is empty'**
  String get detailEmpty;

  /// No description provided for @detailEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Add a few words and you can start studying straight away.'**
  String get detailEmptyHelp;

  /// No description provided for @detailAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add a card'**
  String get detailAddCard;

  /// No description provided for @cardEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get cardEditTitle;

  /// No description provided for @cardAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get cardAddTitle;

  /// No description provided for @cardDeckLabel.
  ///
  /// In en, this message translates to:
  /// **'DECK *'**
  String get cardDeckLabel;

  /// No description provided for @cardFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'FRONT (TARGET WORD) *'**
  String get cardFrontLabel;

  /// No description provided for @cardBackLabel.
  ///
  /// In en, this message translates to:
  /// **'BACK (TRANSLATION) *'**
  String get cardBackLabel;

  /// No description provided for @cardFrontHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bonjour'**
  String get cardFrontHint;

  /// No description provided for @cardBackHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hello'**
  String get cardBackHint;

  /// No description provided for @cardExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'EXAMPLE SENTENCE'**
  String get cardExampleLabel;

  /// No description provided for @cardExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Write an example sentence...'**
  String get cardExampleHint;

  /// No description provided for @cardImageLabel.
  ///
  /// In en, this message translates to:
  /// **'IMAGE URL'**
  String get cardImageLabel;

  /// No description provided for @cardImageHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get cardImageHint;

  /// No description provided for @cardImageError.
  ///
  /// In en, this message translates to:
  /// **'Enter a full image URL starting with http:// or https://'**
  String get cardImageError;

  /// No description provided for @cardAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get cardAdd;

  /// No description provided for @cardAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the card. Please try again.'**
  String get cardAddFailed;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Library'**
  String get libraryTitle;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search front or back...'**
  String get librarySearchHint;

  /// No description provided for @libraryAllDecks.
  ///
  /// In en, this message translates to:
  /// **'All Decks'**
  String get libraryAllDecks;

  /// No description provided for @libraryTotalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items: {count}'**
  String libraryTotalItems(int count);

  /// No description provided for @libraryShowingAll.
  ///
  /// In en, this message translates to:
  /// **'Showing all'**
  String get libraryShowingAll;

  /// No description provided for @libraryFilteredByDeck.
  ///
  /// In en, this message translates to:
  /// **'Filtered by deck'**
  String get libraryFilteredByDeck;

  /// No description provided for @libraryStudyThisDeck.
  ///
  /// In en, this message translates to:
  /// **'Study This Deck'**
  String get libraryStudyThisDeck;

  /// No description provided for @libraryNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No cards match \"{query}\"'**
  String libraryNoMatch(String query);

  /// No description provided for @libraryNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No cards here yet'**
  String get libraryNoneYet;

  /// No description provided for @libraryCheckSpelling.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or clear the deck filter to search everywhere.'**
  String get libraryCheckSpelling;

  /// No description provided for @libraryAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first word and it will show up in your next study session.'**
  String get libraryAddFirst;

  /// No description provided for @libraryUnknownDeck.
  ///
  /// In en, this message translates to:
  /// **'Unknown deck'**
  String get libraryUnknownDeck;

  /// No description provided for @libraryDeckReviews.
  ///
  /// In en, this message translates to:
  /// **'{deck} · {count} reviews'**
  String libraryDeckReviews(String deck, int count);

  /// No description provided for @libraryEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get libraryEditCard;

  /// No description provided for @libraryDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get libraryDeleteCard;

  /// No description provided for @libraryDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete card?'**
  String get libraryDeleteConfirmTitle;

  /// No description provided for @libraryDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{term}\" will be permanently removed from your library.'**
  String libraryDeleteConfirmBody(String term);

  /// No description provided for @libraryCardDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{term}\" deleted'**
  String libraryCardDeleted(String term);

  /// No description provided for @libraryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the card. Please try again.'**
  String get libraryDeleteFailed;

  /// No description provided for @studyAllDecks.
  ///
  /// In en, this message translates to:
  /// **'All decks'**
  String get studyAllDecks;

  /// No description provided for @studyDailyReview.
  ///
  /// In en, this message translates to:
  /// **'Daily Review · {deck}'**
  String studyDailyReview(String deck);

  /// No description provided for @studyWordHint.
  ///
  /// In en, this message translates to:
  /// **'Word: {term}. Tap to reveal the translation.'**
  String studyWordHint(String term);

  /// No description provided for @studyAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Answer: {translation}. Tap to see the word again. Swipe to skip, or rate below.'**
  String studyAnswerHint(String translation);

  /// No description provided for @studyRateBelow.
  ///
  /// In en, this message translates to:
  /// **'Rate below, or swipe to skip without rating'**
  String get studyRateBelow;

  /// No description provided for @studyRecallHint.
  ///
  /// In en, this message translates to:
  /// **'Recall the translation, then flip to check'**
  String get studyRecallHint;

  /// No description provided for @studyNothingDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing due right now'**
  String get studyNothingDue;

  /// No description provided for @studyBackToDecks.
  ///
  /// In en, this message translates to:
  /// **'Back to Decks'**
  String get studyBackToDecks;

  /// No description provided for @studyQueueFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your review queue'**
  String get studyQueueFailed;

  /// No description provided for @studyTapToSeeExample.
  ///
  /// In en, this message translates to:
  /// **'[ tap to see example ]'**
  String get studyTapToSeeExample;

  /// No description provided for @studyShowExample.
  ///
  /// In en, this message translates to:
  /// **'Show Example Sentence'**
  String get studyShowExample;

  /// No description provided for @studyTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal translation'**
  String get studyTapToReveal;

  /// No description provided for @studyHearPronounced.
  ///
  /// In en, this message translates to:
  /// **'Hear {term} pronounced'**
  String studyHearPronounced(String term);

  /// No description provided for @studyHearIt.
  ///
  /// In en, this message translates to:
  /// **'Hear it'**
  String get studyHearIt;

  /// No description provided for @studyTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATION'**
  String get studyTranslationLabel;

  /// No description provided for @studyExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'EXAMPLE'**
  String get studyExampleLabel;

  /// No description provided for @studyImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Image didn\'t load'**
  String get studyImageFailed;

  /// No description provided for @studyAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All Caught Up!'**
  String get studyAllCaughtUp;

  /// No description provided for @studyReviewedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You reviewed the 1 card due today} other{You reviewed all {count} cards due today}}'**
  String studyReviewedCount(int count);

  /// No description provided for @studyConfidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get studyConfidence;

  /// No description provided for @studyViewStats.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get studyViewStats;

  /// No description provided for @quizTimeUp.
  ///
  /// In en, this message translates to:
  /// **'⏰ Time\'s up! Here\'s the correct answer.'**
  String get quizTimeUp;

  /// No description provided for @quizProgress.
  ///
  /// In en, this message translates to:
  /// **'Q{index} of {total}'**
  String quizProgress(int index, int total);

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get quizFinish;

  /// No description provided for @quizNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question →'**
  String get quizNextQuestion;

  /// No description provided for @quizNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough cards to quiz'**
  String get quizNotEnough;

  /// No description provided for @quizNotEnoughAll.
  ///
  /// In en, this message translates to:
  /// **'Add at least {min} cards with different translations and the quiz will build itself from them.'**
  String quizNotEnoughAll(int min);

  /// No description provided for @quizNotEnoughDeck.
  ///
  /// In en, this message translates to:
  /// **'{deck} needs at least {min} cards with different translations before it can be quizzed.'**
  String quizNotEnoughDeck(String deck, int min);

  /// No description provided for @quizBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get quizBack;

  /// No description provided for @quizPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect score!'**
  String get quizPerfect;

  /// No description provided for @quizGreat.
  ///
  /// In en, this message translates to:
  /// **'Great work!'**
  String get quizGreat;

  /// No description provided for @quizNice.
  ///
  /// In en, this message translates to:
  /// **'Nice progress'**
  String get quizNice;

  /// No description provided for @quizKeepPractising.
  ///
  /// In en, this message translates to:
  /// **'Keep practising'**
  String get quizKeepPractising;

  /// No description provided for @quizAnsweredCorrectly.
  ///
  /// In en, this message translates to:
  /// **'You answered {score} of {total} correctly'**
  String quizAnsweredCorrectly(int score, int total);

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'score'**
  String get quizScore;

  /// No description provided for @quizDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get quizDone;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your learning journey in numbers'**
  String get statsSubtitle;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsStreak;

  /// No description provided for @statsReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get statsReviews;

  /// No description provided for @statsRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get statsRecall;

  /// No description provided for @statsTodayDelta.
  ///
  /// In en, this message translates to:
  /// **'+{count} today'**
  String statsTodayDelta(int count);

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'no data'**
  String get statsNoData;

  /// No description provided for @statsHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Learning Heatmap'**
  String get statsHeatmap;

  /// No description provided for @statsStreakSummary.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak · {total} reviews logged'**
  String statsStreakSummary(int days, int total);

  /// No description provided for @statsReviewsLogged.
  ///
  /// In en, this message translates to:
  /// **'{total} reviews logged'**
  String statsReviewsLogged(int total);

  /// No description provided for @statsLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get statsLess;

  /// No description provided for @statsMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get statsMore;

  /// No description provided for @statsNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get statsNoActivity;

  /// No description provided for @statsLibraryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Library Breakdown'**
  String get statsLibraryBreakdown;

  /// No description provided for @statsAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get statsAchievements;

  /// No description provided for @statsEarned.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {total} earned'**
  String statsEarned(int earned, int total);

  /// No description provided for @statsAddCards.
  ///
  /// In en, this message translates to:
  /// **'Add some cards to see your progress'**
  String get statsAddCards;

  /// No description provided for @statsDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get statsDaily;

  /// No description provided for @statsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get statsWeekly;

  /// No description provided for @statsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get statsMonthly;

  /// No description provided for @statsChartDaily.
  ///
  /// In en, this message translates to:
  /// **'Reviews, last 7 days'**
  String get statsChartDaily;

  /// No description provided for @statsChartWeekly.
  ///
  /// In en, this message translates to:
  /// **'Reviews, last 4 weeks'**
  String get statsChartWeekly;

  /// No description provided for @statsChartMonthly.
  ///
  /// In en, this message translates to:
  /// **'Reviews, last 6 months'**
  String get statsChartMonthly;

  /// No description provided for @statsChartTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String statsChartTotal(int count);

  /// No description provided for @profileStudyPreferences.
  ///
  /// In en, this message translates to:
  /// **'Study Preferences'**
  String get profileStudyPreferences;

  /// No description provided for @profileNativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Native Language'**
  String get profileNativeLanguage;

  /// No description provided for @profileTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target Language'**
  String get profileTargetLanguage;

  /// No description provided for @profileLearningPurpose.
  ///
  /// In en, this message translates to:
  /// **'Learning Purpose'**
  String get profileLearningPurpose;

  /// No description provided for @profileStudyCategories.
  ///
  /// In en, this message translates to:
  /// **'Study Categories'**
  String get profileStudyCategories;

  /// No description provided for @profileDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get profileDailyGoal;

  /// No description provided for @profileAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get profileAppPreferences;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get profileAppLanguage;

  /// No description provided for @profileSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get profileSoundEffects;

  /// No description provided for @profileDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get profileDailyReminder;

  /// No description provided for @profileThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get profileThemeColor;

  /// No description provided for @profileTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get profileTextSize;

  /// No description provided for @profileDifficultyMode.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Mode'**
  String get profileDifficultyMode;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profilePrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get profilePrivacySecurity;

  /// No description provided for @profileUpgradePremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get profileUpgradePremium;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogOut;

  /// No description provided for @profileLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileLogOutConfirm;

  /// No description provided for @profileLogOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to continue learning.'**
  String get profileLogOutBody;

  /// No description provided for @profileNoneYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get profileNoneYet;

  /// No description provided for @profileSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String profileSelectedCount(int count);

  /// No description provided for @profileTopicsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} topics'**
  String profileTopicsCount(int count);

  /// No description provided for @profileMinutes.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String profileMinutes(int min);

  /// No description provided for @profileNative.
  ///
  /// In en, this message translates to:
  /// **'Native'**
  String get profileNative;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEmailAddress;

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get profileNameRequired;

  /// No description provided for @profileEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get profileEmailRequired;

  /// No description provided for @profileClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profileClose;

  /// No description provided for @profileWhyLearning.
  ///
  /// In en, this message translates to:
  /// **'Why are you learning? Pick as many as apply.'**
  String get profileWhyLearning;

  /// No description provided for @profileDecreaseGoal.
  ///
  /// In en, this message translates to:
  /// **'Decrease daily goal'**
  String get profileDecreaseGoal;

  /// No description provided for @profileIncreaseGoal.
  ///
  /// In en, this message translates to:
  /// **'Increase daily goal'**
  String get profileIncreaseGoal;

  /// No description provided for @profileYouSpeakThis.
  ///
  /// In en, this message translates to:
  /// **'you speak this'**
  String get profileYouSpeakThis;

  /// No description provided for @profileLearningThis.
  ///
  /// In en, this message translates to:
  /// **'you\'re learning this'**
  String get profileLearningThis;

  /// No description provided for @profileLevelBadge.
  ///
  /// In en, this message translates to:
  /// **'⭐ Level {level}'**
  String profileLevelBadge(int level);

  /// No description provided for @profileStreakBadge.
  ///
  /// In en, this message translates to:
  /// **'⚡ {days}-day streak'**
  String profileStreakBadge(int days);

  /// No description provided for @profileServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your connection and try again.'**
  String get profileServerUnreachable;

  /// No description provided for @profileSaveNameFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your name. Please try again.'**
  String get profileSaveNameFailed;

  /// No description provided for @profileSaveLanguageFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your language. Please try again.'**
  String get profileSaveLanguageFailed;

  /// No description provided for @profileSaveGoalFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your daily goal. Please try again.'**
  String get profileSaveGoalFailed;

  /// No description provided for @profileSaveCategoriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your categories. Please try again.'**
  String get profileSaveCategoriesFailed;

  /// No description provided for @profileSavePurposesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your learning purposes. Please try again.'**
  String get profileSavePurposesFailed;

  /// No description provided for @profileLoadCategoriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load categories. Check your connection and try again.'**
  String get profileLoadCategoriesFailed;

  /// No description provided for @profileLoadPurposesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load learning purposes. Check your connection and try again.'**
  String get profileLoadPurposesFailed;

  /// No description provided for @wizardStep.
  ///
  /// In en, this message translates to:
  /// **'STEP {current} OF {total} — {label}'**
  String wizardStep(int current, int total, String label);

  /// No description provided for @wizardNativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'NATIVE LANGUAGE'**
  String get wizardNativeLanguage;

  /// No description provided for @wizardTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'TARGET LANGUAGE'**
  String get wizardTargetLanguage;

  /// No description provided for @wizardTargetLevel.
  ///
  /// In en, this message translates to:
  /// **'TARGET LANGUAGE LEVEL'**
  String get wizardTargetLevel;

  /// No description provided for @wizardLearningPurpose.
  ///
  /// In en, this message translates to:
  /// **'LEARNING PURPOSE'**
  String get wizardLearningPurpose;

  /// No description provided for @wizardTopics.
  ///
  /// In en, this message translates to:
  /// **'TOPICS & CATEGORIES'**
  String get wizardTopics;

  /// No description provided for @wizardAge.
  ///
  /// In en, this message translates to:
  /// **'YOUR AGE'**
  String get wizardAge;

  /// No description provided for @wizardDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'DAILY GOAL'**
  String get wizardDailyGoal;

  /// No description provided for @wizardNativeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your native language?'**
  String get wizardNativeQuestion;

  /// No description provided for @wizardTargetQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which language do you want to learn?'**
  String get wizardTargetQuestion;

  /// No description provided for @wizardLevelQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your current level in {language}?'**
  String wizardLevelQuestion(String language);

  /// No description provided for @wizardLevelHint.
  ///
  /// In en, this message translates to:
  /// **'Pick what feels right — you can adjust this anytime.'**
  String get wizardLevelHint;

  /// No description provided for @wizardGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much time can you dedicate daily?'**
  String get wizardGoalQuestion;

  /// No description provided for @wizardSelectedHint.
  ///
  /// In en, this message translates to:
  /// **'{count} selected · You can change this later'**
  String wizardSelectedHint(int count);

  /// No description provided for @wizardNativePrefix.
  ///
  /// In en, this message translates to:
  /// **'Native: '**
  String get wizardNativePrefix;

  /// No description provided for @wizardStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start Learning 🚀'**
  String get wizardStart;

  /// No description provided for @wizardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your setup options'**
  String get wizardLoadFailed;

  /// No description provided for @wizardSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your topics or learning purpose. Please try again.'**
  String get wizardSaveFailed;

  /// No description provided for @levelJustStarting.
  ///
  /// In en, this message translates to:
  /// **'Just Starting'**
  String get levelJustStarting;

  /// No description provided for @levelJustStartingDesc.
  ///
  /// In en, this message translates to:
  /// **'Learning the basics'**
  String get levelJustStartingDesc;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelBeginnerDesc.
  ///
  /// In en, this message translates to:
  /// **'Know some words and phrases'**
  String get levelBeginnerDesc;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelIntermediateDesc.
  ///
  /// In en, this message translates to:
  /// **'Can have simple conversations'**
  String get levelIntermediateDesc;

  /// No description provided for @levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// No description provided for @levelAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Comfortable in most situations'**
  String get levelAdvancedDesc;

  /// No description provided for @levelFluent.
  ///
  /// In en, this message translates to:
  /// **'Fluent'**
  String get levelFluent;

  /// No description provided for @levelFluentDesc.
  ///
  /// In en, this message translates to:
  /// **'Near-native proficiency'**
  String get levelFluentDesc;

  /// No description provided for @goalCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get goalCasual;

  /// No description provided for @goalRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get goalRegular;

  /// No description provided for @goalIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get goalIntense;

  /// No description provided for @goalWordsPerDay.
  ///
  /// In en, this message translates to:
  /// **'~{count} words/day'**
  String goalWordsPerDay(int count);

  /// No description provided for @helpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search help articles...'**
  String get helpSearchHint;

  /// No description provided for @helpFrequentlyAsked.
  ///
  /// In en, this message translates to:
  /// **'FREQUENTLY ASKED'**
  String get helpFrequentlyAsked;

  /// No description provided for @helpNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No articles match \"{query}\"'**
  String helpNoMatch(String query);

  /// No description provided for @helpStillStuck.
  ///
  /// In en, this message translates to:
  /// **'STILL STUCK?'**
  String get helpStillStuck;

  /// No description provided for @helpEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get helpEmailSupport;

  /// No description provided for @helpCommunityForum.
  ///
  /// In en, this message translates to:
  /// **'Community forum'**
  String get helpCommunityForum;

  /// No description provided for @helpReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get helpReportProblem;

  /// No description provided for @helpTheCommunityForum.
  ///
  /// In en, this message translates to:
  /// **'The community forum'**
  String get helpTheCommunityForum;

  /// No description provided for @helpProblemReporting.
  ///
  /// In en, this message translates to:
  /// **'Problem reporting'**
  String get helpProblemReporting;

  /// No description provided for @helpReportHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened...'**
  String get helpReportHint;

  /// No description provided for @helpReportSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get helpReportSend;

  /// No description provided for @helpReportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem first'**
  String get helpReportEmpty;

  /// No description provided for @helpReportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks -- your report has been sent'**
  String get helpReportSent;

  /// No description provided for @helpComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{what} is not available in this build yet.'**
  String helpComingSoon(String what);

  /// No description provided for @faqSpacedQ.
  ///
  /// In en, this message translates to:
  /// **'How does spaced repetition work?'**
  String get faqSpacedQ;

  /// No description provided for @faqSpacedA.
  ///
  /// In en, this message translates to:
  /// **'After you flip a card you rate how well you knew it. Cards you find hard come back sooner; cards you rate Easy are pushed further out, so you spend your time on the words you actually struggle with.'**
  String get faqSpacedA;

  /// No description provided for @faqRatingsQ.
  ///
  /// In en, this message translates to:
  /// **'What do Again, Hard, Medium and Easy mean?'**
  String get faqRatingsQ;

  /// No description provided for @faqRatingsA.
  ///
  /// In en, this message translates to:
  /// **'They set how soon a card returns. Again brings it back in this session, Hard in about a day, Medium in a few days, and Easy in about a week.'**
  String get faqRatingsA;

  /// No description provided for @faqReviewDueQ.
  ///
  /// In en, this message translates to:
  /// **'What does \"Review Due\" mean on a card?'**
  String get faqReviewDueQ;

  /// No description provided for @faqReviewDueA.
  ///
  /// In en, this message translates to:
  /// **'That card has passed its scheduled review date. Review Due cards are put at the front of your next study session.'**
  String get faqReviewDueA;

  /// No description provided for @faqCreateDeckQ.
  ///
  /// In en, this message translates to:
  /// **'How do I create a deck?'**
  String get faqCreateDeckQ;

  /// No description provided for @faqCreateDeckA.
  ///
  /// In en, this message translates to:
  /// **'Open the Decks tab and tap \"New Deck\" in the top right. Give it a title, then use \"Add Card\" from the deck to start filling it.'**
  String get faqCreateDeckA;

  /// No description provided for @faqPictureQ.
  ///
  /// In en, this message translates to:
  /// **'Can I add a picture to a card?'**
  String get faqPictureQ;

  /// No description provided for @faqPictureA.
  ///
  /// In en, this message translates to:
  /// **'Yes. When adding or editing a card, paste an image URL into the Image URL field and it will appear on the answer side.'**
  String get faqPictureA;

  /// No description provided for @faqGoalQ.
  ///
  /// In en, this message translates to:
  /// **'How is my daily goal calculated?'**
  String get faqGoalQ;

  /// No description provided for @faqGoalA.
  ///
  /// In en, this message translates to:
  /// **'The ring on the home screen compares the minutes you have studied today against the daily goal set in Profile → Study Preferences.'**
  String get faqGoalA;

  /// No description provided for @faqStreakQ.
  ///
  /// In en, this message translates to:
  /// **'Why did my streak reset?'**
  String get faqStreakQ;

  /// No description provided for @faqStreakA.
  ///
  /// In en, this message translates to:
  /// **'A streak counts consecutive days with at least one completed review. Missing a full day ends it.'**
  String get faqStreakA;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Control what LanGigaCards stores about you and how your learning data is used.'**
  String get privacyIntro;

  /// No description provided for @privacySectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySectionPrivacy;

  /// No description provided for @privacyUsageAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Usage analytics'**
  String get privacyUsageAnalytics;

  /// No description provided for @privacyPersonalisedReview.
  ///
  /// In en, this message translates to:
  /// **'Personalised review order'**
  String get privacyPersonalisedReview;

  /// No description provided for @privacyPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get privacyPublicProfile;

  /// No description provided for @privacyAnalyticsOn.
  ///
  /// In en, this message translates to:
  /// **'Anonymous usage data helps improve the review algorithm.'**
  String get privacyAnalyticsOn;

  /// No description provided for @privacyAnalyticsOff.
  ///
  /// In en, this message translates to:
  /// **'Analytics are off. Nothing about how you use the app is collected.'**
  String get privacyAnalyticsOff;

  /// No description provided for @privacySectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get privacySectionSecurity;

  /// No description provided for @privacyBiometric.
  ///
  /// In en, this message translates to:
  /// **'Require biometric unlock'**
  String get privacyBiometric;

  /// No description provided for @privacyChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get privacyChangePassword;

  /// No description provided for @privacyActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get privacyActiveSessions;

  /// No description provided for @privacySectionYourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get privacySectionYourData;

  /// No description provided for @privacyExportDecks.
  ///
  /// In en, this message translates to:
  /// **'Export my decks'**
  String get privacyExportDecks;

  /// No description provided for @privacyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get privacyDeleteAccount;

  /// No description provided for @privacyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get privacyDeleteConfirm;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This would permanently remove your decks, cards and review history. This cannot be undone.'**
  String get privacyDeleteBody;

  /// No description provided for @privacyNeedsAccount.
  ///
  /// In en, this message translates to:
  /// **'{what} needs a signed-in account, which this build does not have yet.'**
  String privacyNeedsAccount(String what);

  /// No description provided for @privacyChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Changing your password'**
  String get privacyChangingPassword;

  /// No description provided for @privacySessionManagement.
  ///
  /// In en, this message translates to:
  /// **'Session management'**
  String get privacySessionManagement;

  /// No description provided for @privacyExportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String privacyExportSaved(String path);

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordIncorrectCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get changePasswordIncorrectCurrent;

  /// No description provided for @privacyAccountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account deletion'**
  String get privacyAccountDeletion;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Categories'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get categoriesSearchHint;

  /// No description provided for @languagesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search languages...'**
  String get languagesSearchHint;

  /// No description provided for @languagesPopular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get languagesPopular;

  /// No description provided for @reminderPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Reminders need notification permission. Enable it in your system settings.'**
  String get reminderPermissionNeeded;

  /// No description provided for @reminderSetFor.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder set for {time}'**
  String reminderSetFor(String time);

  /// No description provided for @reminderPickTime.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get reminderPickTime;

  /// No description provided for @wizardPurposeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Why are you learning this language?'**
  String get wizardPurposeQuestion;

  /// No description provided for @wizardSelectAllThatApply.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get wizardSelectAllThatApply;

  /// No description provided for @wizardAgeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your age range?'**
  String get wizardAgeQuestion;

  /// No description provided for @wizardTopicsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What topics would you like to study first?'**
  String get wizardTopicsQuestion;

  /// No description provided for @wizardAgeNote.
  ///
  /// In en, this message translates to:
  /// **'We use your age to optimize accessibility settings and learning experience.'**
  String get wizardAgeNote;

  /// No description provided for @studyAllUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Every card you\'re learning is up to date. Add new words or come back when reviews are due.'**
  String get studyAllUpToDate;

  /// No description provided for @studyDeckMastered.
  ///
  /// In en, this message translates to:
  /// **'You\'ve mastered everything in {deck}. Add new words to keep going.'**
  String studyDeckMastered(String deck);

  /// No description provided for @ttsVoiceMissingUnknown.
  ///
  /// In en, this message translates to:
  /// **'This language\'s voice isn\'t installed on your device yet.'**
  String get ttsVoiceMissingUnknown;

  /// No description provided for @ttsVoiceMissing.
  ///
  /// In en, this message translates to:
  /// **'{language} speech isn\'t installed on your device yet. Add it in your system text-to-speech settings.'**
  String ttsVoiceMissing(String language);

  /// No description provided for @ttsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device doesn\'t have a text-to-speech engine available.'**
  String get ttsUnavailable;

  /// No description provided for @ttsPlay.
  ///
  /// In en, this message translates to:
  /// **'Play pronunciation'**
  String get ttsPlay;

  /// No description provided for @ttsNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pronounce'**
  String get ttsNothing;

  /// No description provided for @ttsPlayOf.
  ///
  /// In en, this message translates to:
  /// **'Play pronunciation of {text}'**
  String ttsPlayOf(String text);

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to review'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your cards are waiting — a few minutes keeps the streak alive.'**
  String get reminderNotificationBody;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'LEARN ANY LANGUAGE'**
  String get splashTagline;

  /// No description provided for @profileLearningLabel.
  ///
  /// In en, this message translates to:
  /// **'learning'**
  String get profileLearningLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'pt',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
