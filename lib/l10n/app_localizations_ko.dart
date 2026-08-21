// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appLanguageTitle => '앱 언어 선택';

  @override
  String get appLanguageSubtitle => 'LanGigaCards를 사용할 언어를 선택하세요.';

  @override
  String get commonContinue => '계속';

  @override
  String get commonSignIn => '로그인';

  @override
  String get commonSkip => '건너뛰기';

  @override
  String get commonGetStarted => '시작하기';

  @override
  String get commonTryAgain => '다시 시도';

  @override
  String get commonSave => '저장';

  @override
  String get commonCancel => '취소';

  @override
  String get commonRequiredField => '필수 항목입니다';

  @override
  String get commonSomethingWrong => '문제가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get commonNetworkError => '서버에 연결할 수 없습니다. 연결 상태를 확인한 뒤 다시 시도해 주세요.';

  @override
  String get onboardingSlide1Title => '플래시카드로 배우기';

  @override
  String get onboardingSlide1Body =>
      '검증된 간격 반복 시스템으로 어휘를 익히세요. 가장 적절한 순간에 복습해 기억에 오래 남깁니다.';

  @override
  String get onboardingSlide2Title => '진행 상황 확인';

  @override
  String get onboardingSlide2Body =>
      '학습 여정을 한눈에 보이는 통계로 확인하세요. 연속 기록과 업적과 함께 어휘가 매일 늘어나는 것을 지켜보세요.';

  @override
  String get onboardingSlide3Title => '목표 달성';

  @override
  String get onboardingSlide3Body =>
      '나에게 맞는 일일 목표를 세우고 동기를 유지하세요. 스마트 알고리즘이 속도에 맞춰 학습을 쉽게 만들어 줍니다.';

  @override
  String get onboardingHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get loginTitle => '다시 오신 것을 환영합니다';

  @override
  String get loginSubtitle => '로그인하고 학습을 이어가세요';

  @override
  String get loginEmailLabel => '이메일 주소';

  @override
  String get loginPasswordLabel => '비밀번호';

  @override
  String get loginRememberMe => '로그인 상태 유지';

  @override
  String get loginForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get loginOrContinueWith => '또는 다음으로 계속';

  @override
  String get loginNoAccount => '계정이 없으신가요?';

  @override
  String get loginInvalidCredentials =>
      '이메일 또는 비밀번호가 올바르지 않습니다. 계정이 없다면 새로 만드세요.';

  @override
  String get registerTitle => '계정 만들기';

  @override
  String get registerBackToSignIn => '로그인으로 돌아가기';

  @override
  String get registerSubtitle => '회원 정보 — 언어와 학습 설정은 다음 단계입니다.';

  @override
  String get registerFirstName => '이름';

  @override
  String get registerLastName => '성';

  @override
  String get registerEmail => '이메일 주소';

  @override
  String get registerPassword => '비밀번호';

  @override
  String get registerPasswordHint => '최소 8자';

  @override
  String get registerConfirmPassword => '비밀번호 확인';

  @override
  String get registerConfirmHint => '비밀번호를 다시 입력하세요';

  @override
  String get registerInvalidEmail => '올바른 이메일 주소를 입력해 주세요';

  @override
  String get registerPasswordTooShort => '비밀번호는 8자 이상이어야 합니다';

  @override
  String get registerPasswordsDontMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get registerEmailTaken => '이 이메일로 등록된 계정이 이미 있습니다.';

  @override
  String get verifyTitle => '이메일 확인';

  @override
  String verifySubtitle(String email) {
    return '$email(으)로 6자리 코드를 보냈습니다. 아래에 입력해 계정을 확인하세요.';
  }

  @override
  String get verifyNoCode => '코드를 받지 못하셨나요?';

  @override
  String get verifyResend => '코드 다시 보내기';

  @override
  String get verifySending => '보내는 중…';

  @override
  String get verifyAction => '확인';

  @override
  String get verifySkip => '나중에 하기';

  @override
  String verifyEnterAllDigits(int count) {
    return '$count자리를 모두 입력하세요';
  }

  @override
  String get verifyIncorrect => '코드가 올바르지 않습니다. 다시 시도해 주세요';

  @override
  String get verifyTooManyAttempts =>
      '시도 횟수를 초과했습니다. \"코드 다시 보내기\"를 눌러 새 코드를 받으세요.';

  @override
  String get verifyResent => '새 코드를 이메일로 보냈습니다';

  @override
  String get forgotTitle => '비밀번호 재설정';

  @override
  String get forgotSubtitle =>
      '가입할 때 사용한 이메일을 입력하시면 새 비밀번호를 설정할 수 있는 링크를 보내드립니다.';

  @override
  String get forgotEmailLabel => '이메일 주소';

  @override
  String get forgotInvalidEmail => '올바른 이메일 주소를 입력하세요';

  @override
  String get forgotSend => '재설정 링크 보내기';

  @override
  String get forgotCheckInbox => '받은 편지함을 확인하세요';

  @override
  String forgotSentTo(String email) {
    return '$email 계정이 있다면 재설정 링크가 곧 도착합니다.';
  }

  @override
  String get forgotNoMailServer =>
      '이 빌드에는 메일 서버가 연결되어 있지 않아 실제로 이메일이 발송되지 않습니다.';

  @override
  String get forgotUseDifferent => '다른 이메일 사용';

  @override
  String get navHome => '홈';

  @override
  String get navDecks => '덱';

  @override
  String get navQuiz => '퀴즈';

  @override
  String get navStats => '통계';

  @override
  String get navProfile => '프로필';

  @override
  String get homeGreetingMorning => '좋은 아침입니다,';

  @override
  String get homeGreetingAfternoon => '안녕하세요,';

  @override
  String get homeGreetingEvening => '좋은 저녁입니다,';

  @override
  String get homeContinueLearning => '학습 이어가기';

  @override
  String homeCardsDue(int count) {
    return '복습할 카드 $count장';
  }

  @override
  String homeMinGoal(int minutes) {
    return '하루 $minutes분 목표';
  }

  @override
  String get homeFinishSetup => '프로필 설정을 마치면 첫 덱이 만들어집니다.';

  @override
  String get homeWords => '단어';

  @override
  String get homeAccuracy => '정확도';

  @override
  String get homeStreak => '연속 학습';

  @override
  String get homeContinueQuizLabel => '퀴즈';

  @override
  String get homeContinueQuizTitle => '퀴즈 이어가기';

  @override
  String homeContinueQuizSubtitle(String deck, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count문제',
    );
    return '$deck · $_temp0';
  }

  @override
  String homeReviewDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '복습 $count개',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewDoneBadge => '완료';

  @override
  String get homeYourTopics => '내 주제';

  @override
  String get homeRecentlyLearned => '최근 학습';

  @override
  String get homeSeeAll => '전체 보기';

  @override
  String get shellProfileLoadFailed => '프로필을 불러오지 못했습니다';

  @override
  String get shellCheckConnection => '연결 상태를 확인한 뒤 다시 시도해 주세요.';

  @override
  String get shellSyncDroppedOne => '변경 사항 1건을 저장하지 못해 취소했습니다.';

  @override
  String shellSyncDroppedMany(int count) {
    return '변경 사항 $count건을 저장하지 못해 취소했습니다.';
  }

  @override
  String get commonDelete => '삭제';

  @override
  String get decksTitle => '내 덱';

  @override
  String get decksNewDeck => '새 덱';

  @override
  String decksSummary(int decks, int due) {
    return '덱 $decks개 · 오늘 $due장 예정';
  }

  @override
  String decksDueForReview(int count) {
    return '복습할 카드 $count장';
  }

  @override
  String get decksSortedByUrgency => '긴급도순 · 탭하여 시작';

  @override
  String get decksSearchHint => '덱 검색...';

  @override
  String decksNoMatch(String query) {
    return '\"$query\"와 일치하는 덱이 없습니다';
  }

  @override
  String get decksNoneYet => '아직 덱이 없습니다';

  @override
  String get decksTryDifferentSearch => '다른 검색어를 사용하거나 이 이름으로 덱을 만들어 보세요.';

  @override
  String get decksEmptyHelp => '덱은 배우고 싶은 단어를 모아 두는 곳입니다. 첫 덱을 만들어 시작하세요.';

  @override
  String get decksCreateADeck => '덱 만들기';

  @override
  String get decksOptions => '덱 옵션';

  @override
  String get decksQuizThis => '이 덱으로 퀴즈';

  @override
  String get decksRename => '덱 이름 변경';

  @override
  String get decksDelete => '덱 삭제';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '카드 $count장',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => '복습 예정';

  @override
  String decksReviewCount(int count) {
    return '복습 $count회';
  }

  @override
  String get decksMastery => '숙련도';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count장 학습',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => '모두 완료';

  @override
  String get decksBrowse => '둘러보기';

  @override
  String get decksRenameTitle => '덱 이름 변경';

  @override
  String get decksCreateTitle => '새 덱 만들기';

  @override
  String get decksTitleLabel => '제목 *';

  @override
  String get decksTitleHint => '예: 프랑스어 기초';

  @override
  String get decksDescriptionLabel => '설명 (선택)';

  @override
  String get decksDescriptionHint => '이 덱의 내용을 적어 주세요...';

  @override
  String get decksSaveChanges => '변경 사항 저장';

  @override
  String get decksCreateDeck => '덱 만들기';

  @override
  String get decksNoDescription => '아직 설명이 없습니다';

  @override
  String decksDeleteConfirm(String name) {
    return '\"$name\"을(를) 삭제할까요?';
  }

  @override
  String get decksDeleteEmpty => '이 덱은 비어 있어 삭제됩니다.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '덱과 카드 $count장이 삭제됩니다.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '\"$name\" 삭제됨';
  }

  @override
  String get decksCreateFailed => '덱을 만들지 못했습니다. 다시 시도해 주세요.';

  @override
  String get decksDeleteFailed => '덱을 삭제하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get decksSaveFailed => '변경 사항을 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get quizDecksTitle => '퀴즈 덱';

  @override
  String get quizDecksStartQuiz => '퀴즈 시작';

  @override
  String get quizDecksEmpty => '아직 덱이 없습니다';

  @override
  String get quizDecksEmptyHelp => '덱 탭에서 덱을 만든 다음 여기로 돌아와 퀴즈를 풀어보세요.';

  @override
  String quizDecksNotEnoughCards(int min) {
    return '퀴즈를 사용하려면 카드를 최소 $min장 추가하세요';
  }

  @override
  String get detailNotFound => '이 덱은 더 이상 존재하지 않습니다';

  @override
  String get detailBackToDecks => '덱 목록으로';

  @override
  String get detailProgress => '진행 상황';

  @override
  String get detailMastered => '숙달';

  @override
  String get detailLearning => '학습 중';

  @override
  String get detailCards => '카드';

  @override
  String get detailReviews => '복습';

  @override
  String get detailBrowseAll => '전체 보기';

  @override
  String detailMore(int count) {
    return '외 $count개';
  }

  @override
  String get detailBack => '뒤로';

  @override
  String get detailAddCardTooltip => '이 덱에 카드 추가';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label: $total장 중 $count장';
  }

  @override
  String get detailEmpty => '이 덱은 비어 있습니다';

  @override
  String get detailEmptyHelp => '단어를 몇 개 추가하면 바로 학습을 시작할 수 있습니다.';

  @override
  String get detailAddCard => '카드 추가';

  @override
  String get cardEditTitle => '카드 편집';

  @override
  String get cardAddTitle => '새 카드';

  @override
  String get cardDeckLabel => '덱 *';

  @override
  String get cardFrontLabel => '앞면 (학습할 단어) *';

  @override
  String get cardBackLabel => '뒷면 (번역) *';

  @override
  String get cardFrontHint => '예: Bonjour';

  @override
  String get cardBackHint => '예: 안녕하세요';

  @override
  String get cardExampleLabel => '예문';

  @override
  String get cardExampleHint => '예문을 입력하세요...';

  @override
  String get cardImageLabel => '이미지 URL';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError => 'http:// 또는 https:// 로 시작하는 전체 이미지 주소를 입력하세요';

  @override
  String get cardAdd => '카드 추가';

  @override
  String get cardAddFailed => '카드를 추가하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get libraryTitle => '카드 라이브러리';

  @override
  String get librarySearchHint => '앞면 또는 뒷면 검색...';

  @override
  String get libraryAllDecks => '모든 덱';

  @override
  String libraryTotalItems(int count) {
    return '전체: $count';
  }

  @override
  String get libraryShowingAll => '전체 표시 중';

  @override
  String get libraryFilteredByDeck => '덱으로 필터링됨';

  @override
  String get libraryStudyThisDeck => '이 덱 학습하기';

  @override
  String libraryNoMatch(String query) {
    return '\"$query\"와 일치하는 카드가 없습니다';
  }

  @override
  String get libraryNoneYet => '아직 카드가 없습니다';

  @override
  String get libraryCheckSpelling => '철자를 확인하거나 덱 필터를 해제해 전체에서 검색해 보세요.';

  @override
  String get libraryAddFirst => '첫 단어를 추가하면 다음 학습에 나타납니다.';

  @override
  String get libraryUnknownDeck => '알 수 없는 덱';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · 복습 $count회';
  }

  @override
  String get libraryEditCard => '카드 편집';

  @override
  String get libraryDeleteCard => '카드 삭제';

  @override
  String get libraryDeleteConfirmTitle => '카드를 삭제할까요?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '\"$term\"이(가) 라이브러리에서 영구히 삭제됩니다.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '\"$term\" 삭제됨';
  }

  @override
  String get libraryDeleteFailed => '카드를 삭제하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get studyAllDecks => '모든 덱';

  @override
  String studyDailyReview(String deck) {
    return '오늘의 복습 · $deck';
  }

  @override
  String studyWordHint(String term) {
    return '단어: $term. 탭하면 번역이 표시됩니다.';
  }

  @override
  String studyAnswerHint(String translation) {
    return '정답: $translation. 탭하면 단어를 다시 봅니다. 넘기려면 스와이프하거나 아래에서 평가하세요.';
  }

  @override
  String get studyRateBelow => '아래에서 평가하거나, 스와이프해 평가 없이 넘기세요';

  @override
  String get studyRecallHint => '번역을 떠올린 뒤 뒤집어 확인하세요';

  @override
  String get studyNothingDue => '지금은 복습할 카드가 없습니다';

  @override
  String get studyBackToDecks => '덱으로 돌아가기';

  @override
  String get studyQueueFailed => '복습 목록을 불러오지 못했습니다';

  @override
  String get studyTapToSeeExample => '[ 탭하면 예문 ]';

  @override
  String get studyShowExample => '예문 보기';

  @override
  String get studyTapToReveal => '탭하여 번역 보기';

  @override
  String studyHearPronounced(String term) {
    return '$term 발음 듣기';
  }

  @override
  String get studyHearIt => '듣기';

  @override
  String get studyTranslationLabel => '번역';

  @override
  String get studyExampleLabel => '예문';

  @override
  String get studyImageFailed => '이미지를 불러오지 못했습니다';

  @override
  String get studyAllCaughtUp => '모두 완료!';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '오늘 예정된 카드 $count장을 모두 복습했습니다',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => '확신도';

  @override
  String get studyViewStats => '통계 보기';

  @override
  String get quizTimeUp => '⏰ 시간이 다 됐습니다! 정답은 이것입니다.';

  @override
  String quizProgress(int index, int total) {
    return '$total문제 중 $index번';
  }

  @override
  String get quizFinish => '완료';

  @override
  String get quizNextQuestion => '다음 문제 →';

  @override
  String get quizNotEnough => '퀴즈를 만들 카드가 부족합니다';

  @override
  String quizNotEnoughAll(int min) {
    return '번역이 서로 다른 카드를 $min장 이상 추가하면 퀴즈가 자동으로 만들어집니다.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck을(를) 퀴즈로 만들려면 번역이 서로 다른 카드가 $min장 이상 필요합니다.';
  }

  @override
  String get quizBack => '뒤로';

  @override
  String get quizPerfect => '만점입니다!';

  @override
  String get quizGreat => '잘하셨어요!';

  @override
  String get quizNice => '좋은 진전이에요';

  @override
  String get quizKeepPractising => '계속 연습하세요';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return '$total문제 중 $score문제를 맞혔습니다';
  }

  @override
  String get quizScore => '점수';

  @override
  String get quizDone => '완료';

  @override
  String get statsTitle => '통계';

  @override
  String get statsSubtitle => '숫자로 보는 학습 여정';

  @override
  String get statsStreak => '연속 학습';

  @override
  String get statsReviews => '복습';

  @override
  String get statsRecall => '기억률';

  @override
  String statsTodayDelta(int count) {
    return '오늘 +$count';
  }

  @override
  String get statsNoData => '데이터 없음';

  @override
  String get statsHeatmap => '학습 히트맵';

  @override
  String statsStreakSummary(int days, int total) {
    return '$days일 연속 · 복습 $total회 기록';
  }

  @override
  String statsReviewsLogged(int total) {
    return '복습 $total회 기록';
  }

  @override
  String get statsLess => '적음';

  @override
  String get statsMore => '많음';

  @override
  String get statsNoActivity => '아직 활동이 없습니다';

  @override
  String get statsLibraryBreakdown => '라이브러리 구성';

  @override
  String get statsAchievements => '업적';

  @override
  String statsEarned(int earned, int total) {
    return '$total개 중 $earned개 달성';
  }

  @override
  String get statsAddCards => '카드를 추가하면 진행 상황이 표시됩니다';

  @override
  String get statsDaily => '일간';

  @override
  String get statsWeekly => '주간';

  @override
  String get statsMonthly => '월간';

  @override
  String get statsChartDaily => '복습, 최근 7일';

  @override
  String get statsChartWeekly => '복습, 최근 4주';

  @override
  String get statsChartMonthly => '복습, 최근 6개월';

  @override
  String statsChartTotal(int count) {
    return '총 $count';
  }

  @override
  String get profileStudyPreferences => '학습 설정';

  @override
  String get profileNativeLanguage => '모국어';

  @override
  String get profileTargetLanguage => '학습 언어';

  @override
  String get profileLearningPurpose => '학습 목적';

  @override
  String get profileStudyCategories => '학습 주제';

  @override
  String get profileDailyGoal => '일일 목표';

  @override
  String get profileAppPreferences => '앱 설정';

  @override
  String get profileDarkMode => '다크 모드';

  @override
  String get profileAppLanguage => '앱 언어';

  @override
  String get profileSoundEffects => '효과음';

  @override
  String get profileDailyReminder => '일일 알림';

  @override
  String get profileThemeColor => '테마 색상';

  @override
  String get profileTextSize => '글자 크기';

  @override
  String get profileDifficultyMode => '난이도 모드';

  @override
  String get profileEmailVerification => '이메일 인증';

  @override
  String get profileVerified => '인증됨';

  @override
  String get profileNotVerified => '미인증';

  @override
  String get profileAccount => '계정';

  @override
  String get profileEditProfile => '프로필 편집';

  @override
  String get profilePrivacySecurity => '개인정보 및 보안';

  @override
  String get profileUpgradePremium => '프리미엄으로 업그레이드';

  @override
  String get profileHelpSupport => '도움말 및 지원';

  @override
  String get profileLogOut => '로그아웃';

  @override
  String get profileLogOutConfirm => '로그아웃할까요?';

  @override
  String get profileLogOutBody => '학습을 이어가려면 다시 로그인해야 합니다.';

  @override
  String get profileNoneYet => '아직 없음';

  @override
  String profileSelectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String profileTopicsCount(int count) {
    return '주제 $count개';
  }

  @override
  String profileMinutes(int min) {
    return '$min분';
  }

  @override
  String get profileNative => '모국어';

  @override
  String get profileEdit => '편집';

  @override
  String get profileFullName => '이름';

  @override
  String get profileEmailAddress => '이메일 주소';

  @override
  String get profileNameRequired => '이름은 필수입니다';

  @override
  String get profileEmailRequired => '이메일은 필수입니다';

  @override
  String get profileClose => '닫기';

  @override
  String get profileWhyLearning => '왜 배우시나요? 해당하는 항목을 모두 선택하세요.';

  @override
  String get profileDecreaseGoal => '일일 목표 줄이기';

  @override
  String get profileIncreaseGoal => '일일 목표 늘리기';

  @override
  String get profileYouSpeakThis => '이미 사용하는 언어입니다';

  @override
  String get profileLearningThis => '학습 중인 언어입니다';

  @override
  String profileLevelBadge(int level) {
    return '⭐ 레벨 $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ $days일 연속';
  }

  @override
  String get profileServerUnreachable =>
      '서버에 연결하지 못했습니다. 연결 상태를 확인한 뒤 다시 시도해 주세요.';

  @override
  String get profileSaveNameFailed => '이름을 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get profileSaveLanguageFailed => '언어를 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get profileSaveGoalFailed => '일일 목표를 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get profileSaveCategoriesFailed => '주제를 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get profileSavePurposesFailed => '학습 목적을 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get profileLoadCategoriesFailed =>
      '주제를 불러오지 못했습니다. 연결 상태를 확인한 뒤 다시 시도해 주세요.';

  @override
  String get profileLoadPurposesFailed =>
      '학습 목적을 불러오지 못했습니다. 연결 상태를 확인한 뒤 다시 시도해 주세요.';

  @override
  String wizardStep(int current, int total, String label) {
    return '$total단계 중 $current단계 — $label';
  }

  @override
  String get wizardNativeLanguage => '모국어';

  @override
  String get wizardTargetLanguage => '학습 언어';

  @override
  String get wizardTargetLevel => '학습 언어 수준';

  @override
  String get wizardLearningPurpose => '학습 목적';

  @override
  String get wizardTopics => '주제와 카테고리';

  @override
  String get wizardAge => '나이';

  @override
  String get wizardDailyGoal => '일일 목표';

  @override
  String get wizardNativeQuestion => '모국어가 무엇인가요?';

  @override
  String get wizardTargetQuestion => '어떤 언어를 배우고 싶으신가요?';

  @override
  String wizardLevelQuestion(String language) {
    return '$language 실력은 어느 정도인가요?';
  }

  @override
  String get wizardLevelHint => '편한 것을 고르세요 — 언제든 바꿀 수 있습니다.';

  @override
  String get wizardGoalQuestion => '하루에 얼마나 시간을 낼 수 있나요?';

  @override
  String wizardSelectedHint(int count) {
    return '$count개 선택됨 · 나중에 바꿀 수 있습니다';
  }

  @override
  String get wizardNativePrefix => '모국어: ';

  @override
  String get wizardStart => '학습을 시작해요 🚀';

  @override
  String get wizardLoadFailed => '설정 항목을 불러오지 못했습니다';

  @override
  String get wizardSaveFailed => '주제 또는 학습 목적을 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get levelJustStarting => '이제 시작';

  @override
  String get levelJustStartingDesc => '기초를 배우는 중';

  @override
  String get levelBeginner => '초급';

  @override
  String get levelBeginnerDesc => '단어와 표현을 조금 압니다';

  @override
  String get levelIntermediate => '중급';

  @override
  String get levelIntermediateDesc => '간단한 대화가 가능합니다';

  @override
  String get levelAdvanced => '고급';

  @override
  String get levelAdvancedDesc => '대부분의 상황에서 편안합니다';

  @override
  String get levelFluent => '유창';

  @override
  String get levelFluentDesc => '원어민에 가까움';

  @override
  String get goalCasual => '가볍게';

  @override
  String get goalRegular => '꾸준히';

  @override
  String get goalIntense => '집중';

  @override
  String goalWordsPerDay(int count) {
    return '하루 약 $count단어';
  }

  @override
  String get helpSearchHint => '도움말 검색...';

  @override
  String get helpFrequentlyAsked => '자주 묻는 질문';

  @override
  String helpNoMatch(String query) {
    return '\"$query\"와 일치하는 문서가 없습니다';
  }

  @override
  String get helpStillStuck => '아직 해결되지 않았나요?';

  @override
  String get helpEmailSupport => '이메일 지원';

  @override
  String get helpCommunityForum => '커뮤니티 포럼';

  @override
  String get helpReportProblem => '문제 신고';

  @override
  String get helpTheCommunityForum => '커뮤니티 포럼';

  @override
  String get helpProblemReporting => '문제 신고';

  @override
  String get helpReportHint => '무슨 일이 있었는지 설명해 주세요...';

  @override
  String get helpReportSend => '보고서 보내기';

  @override
  String get helpReportEmpty => '먼저 문제를 설명해 주세요';

  @override
  String get helpReportSent => '감사합니다. 보고서가 전송되었습니다';

  @override
  String helpComingSoon(String what) {
    return '$what 기능은 이 빌드에서 아직 사용할 수 없습니다.';
  }

  @override
  String get faqSpacedQ => '간격 반복은 어떻게 작동하나요?';

  @override
  String get faqSpacedA =>
      '카드를 뒤집은 뒤 얼마나 알았는지 평가합니다. 어려웠던 카드는 더 빨리 돌아오고, 쉬움으로 평가한 카드는 더 멀리 밀려납니다. 덕분에 정말 어려운 단어에 시간을 쓰게 됩니다.';

  @override
  String get faqRatingsQ => '다시·어려움·보통·쉬움은 무슨 뜻인가요?';

  @override
  String get faqRatingsA =>
      '카드가 언제 다시 나올지를 정합니다. 다시는 이번 세션 안에, 어려움은 약 하루 뒤, 보통은 며칠 뒤, 쉬움은 약 일주일 뒤입니다.';

  @override
  String get faqReviewDueQ => '카드의 \"복습 예정\"은 무슨 뜻인가요?';

  @override
  String get faqReviewDueA =>
      '예정된 복습 날짜가 지난 카드입니다. 복습 예정 카드는 다음 학습의 맨 앞에 배치됩니다.';

  @override
  String get faqCreateDeckQ => '덱은 어떻게 만드나요?';

  @override
  String get faqCreateDeckA =>
      '덱 탭을 열고 오른쪽 위의 \"새 덱\"을 누르세요. 제목을 정한 뒤 덱에서 \"카드 추가\"로 내용을 채우면 됩니다.';

  @override
  String get faqPictureQ => '카드에 사진을 넣을 수 있나요?';

  @override
  String get faqPictureA =>
      '네. 카드를 추가하거나 편집할 때 이미지 URL 칸에 주소를 붙여넣으면 정답 면에 표시됩니다.';

  @override
  String get faqGoalQ => '일일 목표는 어떻게 계산되나요?';

  @override
  String get faqGoalA => '홈 화면의 링은 오늘 학습한 시간을 프로필 → 학습 설정에서 정한 일일 목표와 비교합니다.';

  @override
  String get faqStreakQ => '연속 학습이 왜 초기화됐나요?';

  @override
  String get faqStreakA =>
      '연속 학습은 복습을 최소 한 번 완료한 날이 이어진 수입니다. 하루를 통째로 건너뛰면 끊깁니다.';

  @override
  String get privacyIntro => 'LanGigaCards가 저장하는 정보와 학습 데이터 사용 방식을 관리하세요.';

  @override
  String get privacySectionPrivacy => '개인정보';

  @override
  String get privacyUsageAnalytics => '사용 통계';

  @override
  String get privacyPersonalisedReview => '맞춤 복습 순서';

  @override
  String get privacyPublicProfile => '공개 프로필';

  @override
  String get privacyAnalyticsOn => '익명 사용 데이터는 복습 알고리즘 개선에 도움이 됩니다.';

  @override
  String get privacyAnalyticsOff => '통계가 꺼져 있습니다. 앱 사용 방식에 관한 정보는 수집되지 않습니다.';

  @override
  String get privacySectionSecurity => '보안';

  @override
  String get privacyBiometric => '생체 인증 잠금 해제 요구';

  @override
  String get privacyChangePassword => '비밀번호 변경';

  @override
  String get privacyActiveSessions => '활성 세션';

  @override
  String get privacySectionYourData => '내 데이터';

  @override
  String get privacyExportDecks => '내 덱 내보내기';

  @override
  String get privacyDeleteAccount => '계정 삭제';

  @override
  String get privacyDeleteConfirm => '계정을 삭제할까요?';

  @override
  String get privacyDeleteBody => '덱, 카드, 복습 기록이 영구히 삭제됩니다. 되돌릴 수 없습니다.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what에는 로그인된 계정이 필요하지만 이 빌드에는 아직 없습니다.';
  }

  @override
  String get privacyChangingPassword => '비밀번호 변경';

  @override
  String get privacySessionManagement => '세션 관리';

  @override
  String privacyExportSaved(String path) {
    return '$path에 저장되었습니다';
  }

  @override
  String get changePasswordCurrentLabel => '현재 비밀번호';

  @override
  String get changePasswordNewLabel => '새 비밀번호';

  @override
  String get changePasswordSuccess => '비밀번호가 업데이트되었습니다';

  @override
  String get changePasswordIncorrectCurrent => '현재 비밀번호가 올바르지 않습니다';

  @override
  String get privacyAccountDeletion => '계정 삭제';

  @override
  String get categoriesEditTitle => '주제 편집';

  @override
  String get categoriesSearchHint => '주제 검색...';

  @override
  String get languagesSearchHint => '언어 검색...';

  @override
  String get languagesPopular => '인기';

  @override
  String get reminderPermissionNeeded =>
      '알림 권한이 있어야 리마인더를 사용할 수 있습니다. 시스템 설정에서 허용해 주세요.';

  @override
  String reminderSetFor(String time) {
    return '매일 알림이 $time으로 설정되었습니다';
  }

  @override
  String get reminderPickTime => '알림 시각';

  @override
  String get wizardPurposeQuestion => '이 언어를 배우는 이유는 무엇인가요?';

  @override
  String get wizardSelectAllThatApply => '해당하는 항목을 모두 선택하세요';

  @override
  String get wizardAgeQuestion => '연령대가 어떻게 되시나요?';

  @override
  String get wizardTopicsQuestion => '어떤 주제부터 공부하고 싶으신가요?';

  @override
  String get wizardAgeNote => '연령 정보는 접근성 설정과 학습 경험을 최적화하는 데 사용됩니다.';

  @override
  String get studyAllUpToDate =>
      '학습 중인 카드가 모두 최신입니다. 새 단어를 추가하거나 복습 시기에 다시 오세요.';

  @override
  String studyDeckMastered(String deck) {
    return '$deck의 모든 내용을 익히셨습니다. 계속하려면 새 단어를 추가하세요.';
  }

  @override
  String get ttsVoiceMissingUnknown => '이 언어의 음성이 아직 기기에 설치되어 있지 않습니다.';

  @override
  String ttsVoiceMissing(String language) {
    return '$language 음성이 아직 설치되어 있지 않습니다. 시스템 음성 변환 설정에서 추가해 주세요.';
  }

  @override
  String get ttsUnavailable => '이 기기에는 사용할 수 있는 음성 변환 엔진이 없습니다.';

  @override
  String get ttsPlay => '발음 재생';

  @override
  String get ttsNothing => '읽을 내용이 없습니다';

  @override
  String ttsPlayOf(String text) {
    return '$text 발음 재생';
  }

  @override
  String get reminderNotificationTitle => '복습할 시간입니다';

  @override
  String get reminderNotificationBody =>
      '카드가 기다리고 있어요. 몇 분이면 연속 기록을 지킬 수 있습니다.';

  @override
  String get splashTagline => '어떤 언어든 배우세요';

  @override
  String get profileLearningLabel => '학습 중';
}
