// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appLanguageTitle => 'アプリの言語を選択';

  @override
  String get appLanguageSubtitle => 'LanGigaCards を使用する言語を選んでください。';

  @override
  String get commonContinue => '続ける';

  @override
  String get commonSignIn => 'ログイン';

  @override
  String get commonSkip => 'スキップ';

  @override
  String get commonGetStarted => 'はじめる';

  @override
  String get commonTryAgain => '再試行';

  @override
  String get commonSave => '保存';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonRequiredField => 'この項目は必須です';

  @override
  String get commonSomethingWrong => '問題が発生しました。もう一度お試しください。';

  @override
  String get commonNetworkError => 'サーバーに接続できません。通信環境を確認して、もう一度お試しください。';

  @override
  String get onboardingSlide1Title => 'カードで学ぶ';

  @override
  String get onboardingSlide1Body =>
      '実績ある間隔反復システムで語彙を身につけましょう。最適なタイミングで復習することで、記憶に長く残ります。';

  @override
  String get onboardingSlide2Title => '進捗を確認';

  @override
  String get onboardingSlide2Body =>
      '学習の歩みを見やすい統計で確認できます。連続記録と実績とともに、語彙が日々増えていくのを実感しましょう。';

  @override
  String get onboardingSlide3Title => '目標を達成';

  @override
  String get onboardingSlide3Body =>
      '自分に合った毎日の目標を設定して、やる気を保ちましょう。アルゴリズムがあなたのペースに合わせ、学習が楽になります。';

  @override
  String get onboardingHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get loginTitle => 'おかえりなさい';

  @override
  String get loginSubtitle => 'ログインして学習を続けましょう';

  @override
  String get loginEmailLabel => 'メールアドレス';

  @override
  String get loginPasswordLabel => 'パスワード';

  @override
  String get loginRememberMe => 'ログイン状態を保持';

  @override
  String get loginForgotPassword => 'パスワードをお忘れですか？';

  @override
  String get loginOrContinueWith => 'または次で続行';

  @override
  String get loginNoAccount => 'アカウントをお持ちでないですか？';

  @override
  String get loginInvalidCredentials =>
      'メールアドレスまたはパスワードが違います。アカウントがない場合は作成してください。';

  @override
  String get registerTitle => 'アカウント作成';

  @override
  String get registerBackToSignIn => 'ログインに戻る';

  @override
  String get registerSubtitle => 'あなたの情報 — 言語と学習設定は次のステップです。';

  @override
  String get registerFirstName => '名';

  @override
  String get registerLastName => '姓';

  @override
  String get registerEmail => 'メールアドレス';

  @override
  String get registerPassword => 'パスワード';

  @override
  String get registerPasswordHint => '8文字以上';

  @override
  String get registerConfirmPassword => 'パスワードの確認';

  @override
  String get registerConfirmHint => 'パスワードを再入力';

  @override
  String get registerInvalidEmail => '有効なメールアドレスを入力してください';

  @override
  String get registerPasswordTooShort => 'パスワードは8文字以上で入力してください';

  @override
  String get registerPasswordsDontMatch => 'パスワードが一致しません';

  @override
  String get registerEmailTaken => 'このメールアドレスのアカウントは既に存在します。';

  @override
  String get verifyTitle => 'メールアドレスの確認';

  @override
  String verifySubtitle(String email) {
    return '$email に6桁のコードを送信しました。下に入力してアカウントを確認してください。';
  }

  @override
  String get verifyNoCode => 'コードが届きませんか？';

  @override
  String get verifyResend => 'コードを再送信';

  @override
  String get verifySending => '送信中…';

  @override
  String get verifyAction => '確認';

  @override
  String verifyEnterAllDigits(int count) {
    return '$count桁すべてを入力してください';
  }

  @override
  String get verifyIncorrect => 'コードが違います。もう一度お試しください';

  @override
  String get verifyTooManyAttempts =>
      '試行回数が多すぎます。「コードを再送信」をタップして新しいコードを取得してください。';

  @override
  String get verifyResent => '新しいコードをメールに送信しました';

  @override
  String get forgotTitle => 'パスワードの再設定';

  @override
  String get forgotSubtitle =>
      '登録時のメールアドレスを入力してください。新しいパスワードを設定するためのリンクをお送りします。';

  @override
  String get forgotEmailLabel => 'メールアドレス';

  @override
  String get forgotInvalidEmail => '有効なメールアドレスを入力してください';

  @override
  String get forgotSend => '再設定リンクを送信';

  @override
  String get forgotCheckInbox => '受信トレイをご確認ください';

  @override
  String forgotSentTo(String email) {
    return '$email のアカウントが存在する場合、再設定リンクを送信しました。';
  }

  @override
  String get forgotNoMailServer => 'このビルドにはメールサーバーが接続されていないため、実際にはメールは送信されません。';

  @override
  String get forgotUseDifferent => '別のメールアドレスを使う';

  @override
  String get navHome => 'ホーム';

  @override
  String get navDecks => 'デッキ';

  @override
  String get navQuiz => 'クイズ';

  @override
  String get navStats => '統計';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get homeGreetingMorning => 'おはようございます、';

  @override
  String get homeGreetingAfternoon => 'こんにちは、';

  @override
  String get homeGreetingEvening => 'こんばんは、';

  @override
  String get homeContinueLearning => '学習を続ける';

  @override
  String homeCardsDue(int count) {
    return '$count枚が復習待ち';
  }

  @override
  String homeMinGoal(int minutes) {
    return '1日$minutes分の目標';
  }

  @override
  String get homeFinishSetup => 'プロフィールの設定を完了すると最初のデッキが作成されます。';

  @override
  String get homeWords => '単語';

  @override
  String get homeAccuracy => '正答率';

  @override
  String get homeStreak => '連続日数';

  @override
  String get homeContinueQuizLabel => 'クイズ';

  @override
  String get homeContinueQuizTitle => 'クイズを続ける';

  @override
  String homeContinueQuizSubtitle(String deck, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count問',
    );
    return '$deck · $_temp0';
  }

  @override
  String homeReviewDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '復習$count件',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewDoneBadge => '完了';

  @override
  String get homeYourTopics => 'あなたのトピック';

  @override
  String get homeRecentlyLearned => '最近学んだ単語';

  @override
  String get homeSeeAll => 'すべて見る';

  @override
  String get shellProfileLoadFailed => 'プロフィールを読み込めませんでした';

  @override
  String get shellCheckConnection => '通信環境を確認して、もう一度お試しください。';

  @override
  String get shellSyncDroppedOne => '1件の変更を保存できず、破棄しました。';

  @override
  String shellSyncDroppedMany(int count) {
    return '$count件の変更を保存できず、破棄しました。';
  }

  @override
  String get commonDelete => '削除';

  @override
  String get decksTitle => 'マイデッキ';

  @override
  String get decksNewDeck => '新しいデッキ';

  @override
  String decksSummary(int decks, int due) {
    return '$decksデッキ · 本日$due枚が対象';
  }

  @override
  String decksDueForReview(int count) {
    return '復習待ち$count枚';
  }

  @override
  String get decksSortedByUrgency => '緊急度順 · タップで開始';

  @override
  String get decksSearchHint => 'デッキを検索...';

  @override
  String decksNoMatch(String query) {
    return '「$query」に一致するデッキはありません';
  }

  @override
  String get decksNoneYet => 'デッキがまだありません';

  @override
  String get decksTryDifferentSearch => '別の語句で検索するか、この名前でデッキを作成してください。';

  @override
  String get decksEmptyHelp => 'デッキは学びたい単語をまとめる場所です。まず1つ作成しましょう。';

  @override
  String get decksCreateADeck => 'デッキを作成';

  @override
  String get decksOptions => 'デッキの操作';

  @override
  String get decksQuizThis => 'このデッキをクイズ';

  @override
  String get decksRename => 'デッキ名を変更';

  @override
  String get decksDelete => 'デッキを削除';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => '復習時期';

  @override
  String decksReviewCount(int count) {
    return '$count回復習';
  }

  @override
  String get decksMastery => '習得度';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚を学習',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'すべて完了';

  @override
  String get decksBrowse => '一覧';

  @override
  String get decksRenameTitle => 'デッキ名を変更';

  @override
  String get decksCreateTitle => '新しいデッキを作成';

  @override
  String get decksTitleLabel => 'タイトル *';

  @override
  String get decksTitleHint => '例：フランス語の基礎';

  @override
  String get decksDescriptionLabel => '説明（任意）';

  @override
  String get decksDescriptionHint => 'このデッキの内容を書いてください...';

  @override
  String get decksSaveChanges => '変更を保存';

  @override
  String get decksCreateDeck => 'デッキを作成';

  @override
  String get decksNoDescription => '説明はまだありません';

  @override
  String decksDeleteConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get decksDeleteEmpty => 'このデッキは空なので削除されます。';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'デッキと$count枚のカードが削除されます。',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '「$name」を削除しました';
  }

  @override
  String get decksCreateFailed => 'デッキを作成できませんでした。もう一度お試しください。';

  @override
  String get decksDeleteFailed => 'デッキを削除できませんでした。もう一度お試しください。';

  @override
  String get decksSaveFailed => '変更を保存できませんでした。もう一度お試しください。';

  @override
  String get quizDecksTitle => 'クイズデッキ';

  @override
  String get quizDecksStartQuiz => 'クイズを始める';

  @override
  String get quizDecksEmpty => 'デッキがまだありません';

  @override
  String get quizDecksEmptyHelp => '「デッキ」タブでデッキを作成してから、ここに戻ってクイズに挑戦しましょう。';

  @override
  String quizDecksNotEnoughCards(int min) {
    return 'クイズを解放するには最低$min枚のカードが必要です';
  }

  @override
  String get detailNotFound => 'このデッキは存在しません';

  @override
  String get detailBackToDecks => 'デッキ一覧へ戻る';

  @override
  String get detailProgress => '進捗';

  @override
  String get detailMastered => '習得済み';

  @override
  String get detailLearning => '学習中';

  @override
  String get detailCards => 'カード';

  @override
  String get detailReviews => '復習回数';

  @override
  String get detailBrowseAll => 'すべて見る';

  @override
  String detailMore(int count) {
    return '他$count件';
  }

  @override
  String get detailBack => '戻る';

  @override
  String get detailAddCardTooltip => 'このデッキにカードを追加';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label：$total枚中$count枚';
  }

  @override
  String get detailEmpty => 'このデッキは空です';

  @override
  String get detailEmptyHelp => '単語をいくつか追加すれば、すぐに学習を始められます。';

  @override
  String get detailAddCard => 'カードを追加';

  @override
  String get cardEditTitle => 'カードを編集';

  @override
  String get cardAddTitle => '新しいカード';

  @override
  String get cardDeckLabel => 'デッキ *';

  @override
  String get cardFrontLabel => '表（学習する単語）*';

  @override
  String get cardBackLabel => '裏（訳）*';

  @override
  String get cardFrontHint => '例：Bonjour';

  @override
  String get cardBackHint => '例：こんにちは';

  @override
  String get cardExampleLabel => '例文';

  @override
  String get cardExampleHint => '例文を入力してください...';

  @override
  String get cardImageLabel => '画像URL';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError => 'http:// または https:// で始まる完全な画像URLを入力してください';

  @override
  String get cardAdd => 'カードを追加';

  @override
  String get cardAddFailed => 'カードを追加できませんでした。もう一度お試しください。';

  @override
  String get libraryTitle => 'カードライブラリ';

  @override
  String get librarySearchHint => '表・裏を検索...';

  @override
  String get libraryAllDecks => 'すべてのデッキ';

  @override
  String libraryTotalItems(int count) {
    return '合計：$count';
  }

  @override
  String get libraryShowingAll => 'すべて表示中';

  @override
  String get libraryFilteredByDeck => 'デッキで絞り込み中';

  @override
  String get libraryStudyThisDeck => 'このデッキを学習';

  @override
  String libraryNoMatch(String query) {
    return '「$query」に一致するカードはありません';
  }

  @override
  String get libraryNoneYet => 'ここにはまだカードがありません';

  @override
  String get libraryCheckSpelling => '綴りを確認するか、デッキの絞り込みを外して全体から検索してください。';

  @override
  String get libraryAddFirst => '最初の単語を追加すると、次の学習で出題されます。';

  @override
  String get libraryUnknownDeck => '不明なデッキ';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · 復習$count回';
  }

  @override
  String get libraryEditCard => 'カードを編集';

  @override
  String get libraryDeleteCard => 'カードを削除';

  @override
  String get libraryDeleteConfirmTitle => 'カードを削除しますか？';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '「$term」はライブラリから完全に削除されます。';
  }

  @override
  String libraryCardDeleted(String term) {
    return '「$term」を削除しました';
  }

  @override
  String get libraryDeleteFailed => 'カードを削除できませんでした。もう一度お試しください。';

  @override
  String get studyAllDecks => 'すべてのデッキ';

  @override
  String studyDailyReview(String deck) {
    return '今日の復習 · $deck';
  }

  @override
  String studyWordHint(String term) {
    return '単語：$term。タップして訳を表示します。';
  }

  @override
  String studyAnswerHint(String translation) {
    return '答え：$translation。タップで単語に戻ります。スワイプでスキップ、または下から評価してください。';
  }

  @override
  String get studyRateBelow => '下から評価するか、スワイプして評価せずにスキップ';

  @override
  String get studyRecallHint => '訳を思い出してから、めくって確認しましょう';

  @override
  String get studyNothingDue => '今は復習するカードがありません';

  @override
  String get studyBackToDecks => 'デッキに戻る';

  @override
  String get studyQueueFailed => '復習リストを読み込めませんでした';

  @override
  String get studyTapToSeeExample => '[ タップで例文 ]';

  @override
  String get studyShowExample => '例文を表示';

  @override
  String get studyTapToReveal => 'タップして訳を表示';

  @override
  String studyHearPronounced(String term) {
    return '$term の発音を聞く';
  }

  @override
  String get studyHearIt => '聞く';

  @override
  String get studyTranslationLabel => '訳';

  @override
  String get studyExampleLabel => '例文';

  @override
  String get studyImageFailed => '画像を読み込めませんでした';

  @override
  String get studyAllCaughtUp => 'すべて完了！';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '本日分の$count枚をすべて復習しました',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => '自信度';

  @override
  String get studyViewStats => '統計を見る';

  @override
  String get quizTimeUp => '⏰ 時間切れです。正解はこちら。';

  @override
  String quizProgress(int index, int total) {
    return '第$index問 / $total問';
  }

  @override
  String get quizFinish => '終了';

  @override
  String get quizNextQuestion => '次の問題 →';

  @override
  String get quizNotEnough => 'クイズに必要なカードが足りません';

  @override
  String quizNotEnoughAll(int min) {
    return '訳が異なるカードを$min枚以上追加すると、クイズが自動的に作られます。';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck をクイズにするには、訳が異なるカードが$min枚以上必要です。';
  }

  @override
  String get quizBack => '戻る';

  @override
  String get quizPerfect => '満点です！';

  @override
  String get quizGreat => 'よくできました！';

  @override
  String get quizNice => 'いい調子です';

  @override
  String get quizKeepPractising => '練習を続けましょう';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return '$total問中$score問正解しました';
  }

  @override
  String get quizScore => 'スコア';

  @override
  String get quizDone => '完了';

  @override
  String get statsTitle => '統計';

  @override
  String get statsSubtitle => '数字で見る学習の歩み';

  @override
  String get statsStreak => '連続日数';

  @override
  String get statsReviews => '復習';

  @override
  String get statsRecall => '定着度';

  @override
  String statsTodayDelta(int count) {
    return '本日 +$count';
  }

  @override
  String get statsNoData => 'データなし';

  @override
  String get statsHeatmap => '学習ヒートマップ';

  @override
  String statsStreakSummary(int days, int total) {
    return '$days日連続 · 復習$total件を記録';
  }

  @override
  String statsReviewsLogged(int total) {
    return '復習$total件を記録';
  }

  @override
  String get statsLess => '少';

  @override
  String get statsMore => '多';

  @override
  String get statsNoActivity => 'まだ記録がありません';

  @override
  String get statsLibraryBreakdown => 'ライブラリの内訳';

  @override
  String get statsAchievements => '実績';

  @override
  String statsEarned(int earned, int total) {
    return '$total件中$earned件達成';
  }

  @override
  String get statsAddCards => 'カードを追加すると進捗が表示されます';

  @override
  String get statsDaily => '日別';

  @override
  String get statsWeekly => '週別';

  @override
  String get statsMonthly => '月別';

  @override
  String get statsChartDaily => '復習（過去7日）';

  @override
  String get statsChartWeekly => '復習（過去4週）';

  @override
  String get statsChartMonthly => '復習（過去6か月）';

  @override
  String statsChartTotal(int count) {
    return '合計$count';
  }

  @override
  String get profileStudyPreferences => '学習設定';

  @override
  String get profileNativeLanguage => '母語';

  @override
  String get profileTargetLanguage => '学習する言語';

  @override
  String get profileLearningPurpose => '学習の目的';

  @override
  String get profileStudyCategories => '学習テーマ';

  @override
  String get profileDailyGoal => '1日の目標';

  @override
  String get profileAppPreferences => 'アプリ設定';

  @override
  String get profileDarkMode => 'ダークモード';

  @override
  String get profileAppLanguage => 'アプリの言語';

  @override
  String get profileSoundEffects => '効果音';

  @override
  String get profileDailyReminder => '毎日のリマインダー';

  @override
  String get profileThemeColor => 'テーマカラー';

  @override
  String get profileTextSize => '文字サイズ';

  @override
  String get profileDifficultyMode => '難易度モード';

  @override
  String get profileAccount => 'アカウント';

  @override
  String get profileEditProfile => 'プロフィールを編集';

  @override
  String get profilePrivacySecurity => 'プライバシーとセキュリティ';

  @override
  String get profileUpgradePremium => 'プレミアムにアップグレード';

  @override
  String get profileHelpSupport => 'ヘルプとサポート';

  @override
  String get profileLogOut => 'ログアウト';

  @override
  String get profileLogOutConfirm => 'ログアウトしますか？';

  @override
  String get profileLogOutBody => '学習を続けるには再度ログインが必要です。';

  @override
  String get profileNoneYet => 'まだありません';

  @override
  String profileSelectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String profileTopicsCount(int count) {
    return '$countテーマ';
  }

  @override
  String profileMinutes(int min) {
    return '$min分';
  }

  @override
  String get profileNative => '母語';

  @override
  String get profileEdit => '編集';

  @override
  String get profileFullName => '氏名';

  @override
  String get profileEmailAddress => 'メールアドレス';

  @override
  String get profileNameRequired => '氏名は必須です';

  @override
  String get profileEmailRequired => 'メールアドレスは必須です';

  @override
  String get profileClose => '閉じる';

  @override
  String get profileWhyLearning => '学ぶ理由は？当てはまるものをすべて選んでください。';

  @override
  String get profileDecreaseGoal => '1日の目標を減らす';

  @override
  String get profileIncreaseGoal => '1日の目標を増やす';

  @override
  String get profileYouSpeakThis => 'あなたが話す言語です';

  @override
  String get profileLearningThis => '学習中の言語です';

  @override
  String profileLevelBadge(int level) {
    return '⭐ レベル$level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ $days日連続';
  }

  @override
  String get profileServerUnreachable =>
      'サーバーに接続できませんでした。通信環境を確認して、もう一度お試しください。';

  @override
  String get profileSaveNameFailed => '氏名を保存できませんでした。もう一度お試しください。';

  @override
  String get profileSaveLanguageFailed => '言語を保存できませんでした。もう一度お試しください。';

  @override
  String get profileSaveGoalFailed => '1日の目標を保存できませんでした。もう一度お試しください。';

  @override
  String get profileSaveCategoriesFailed => 'テーマを保存できませんでした。もう一度お試しください。';

  @override
  String get profileSavePurposesFailed => '学習の目的を保存できませんでした。もう一度お試しください。';

  @override
  String get profileLoadCategoriesFailed =>
      'テーマを読み込めませんでした。通信環境を確認して、もう一度お試しください。';

  @override
  String get profileLoadPurposesFailed =>
      '学習の目的を読み込めませんでした。通信環境を確認して、もう一度お試しください。';

  @override
  String wizardStep(int current, int total, String label) {
    return 'ステップ $current/$total — $label';
  }

  @override
  String get wizardNativeLanguage => '母語';

  @override
  String get wizardTargetLanguage => '学習する言語';

  @override
  String get wizardTargetLevel => '学習する言語のレベル';

  @override
  String get wizardLearningPurpose => '学習の目的';

  @override
  String get wizardTopics => 'テーマとカテゴリ';

  @override
  String get wizardAge => '年齢';

  @override
  String get wizardDailyGoal => '1日の目標';

  @override
  String get wizardNativeQuestion => '母語は何ですか？';

  @override
  String get wizardTargetQuestion => 'どの言語を学びたいですか？';

  @override
  String wizardLevelQuestion(String language) {
    return '$languageの現在のレベルは？';
  }

  @override
  String get wizardLevelHint => 'しっくりくるものを選んでください。あとから変更できます。';

  @override
  String get wizardGoalQuestion => '1日にどれくらい時間を使えますか？';

  @override
  String wizardSelectedHint(int count) {
    return '$count件選択中 · あとから変更できます';
  }

  @override
  String get wizardNativePrefix => '母語：';

  @override
  String get wizardStart => '学習を始めましょう 🚀';

  @override
  String get wizardLoadFailed => '設定の選択肢を読み込めませんでした';

  @override
  String get wizardSaveFailed => 'テーマまたは学習の目的を保存できませんでした。もう一度お試しください。';

  @override
  String get levelJustStarting => 'はじめたばかり';

  @override
  String get levelJustStartingDesc => '基礎を学んでいます';

  @override
  String get levelBeginner => '初級';

  @override
  String get levelBeginnerDesc => '単語やフレーズを少し知っています';

  @override
  String get levelIntermediate => '中級';

  @override
  String get levelIntermediateDesc => '簡単な会話ができます';

  @override
  String get levelAdvanced => '上級';

  @override
  String get levelAdvancedDesc => 'ほとんどの場面で困りません';

  @override
  String get levelFluent => '流暢';

  @override
  String get levelFluentDesc => 'ネイティブに近い';

  @override
  String get goalCasual => 'ゆっくり';

  @override
  String get goalRegular => 'ふつう';

  @override
  String get goalIntense => 'しっかり';

  @override
  String goalWordsPerDay(int count) {
    return '1日約$count語';
  }

  @override
  String get helpSearchHint => 'ヘルプ記事を検索...';

  @override
  String get helpFrequentlyAsked => 'よくある質問';

  @override
  String helpNoMatch(String query) {
    return '「$query」に一致する記事はありません';
  }

  @override
  String get helpStillStuck => '解決しませんか？';

  @override
  String get helpEmailSupport => 'メールサポート';

  @override
  String get helpCommunityForum => 'コミュニティフォーラム';

  @override
  String get helpReportProblem => '問題を報告';

  @override
  String get helpTheCommunityForum => 'コミュニティフォーラム';

  @override
  String get helpProblemReporting => '問題の報告';

  @override
  String get helpReportHint => '何が起きたか説明してください...';

  @override
  String get helpReportSend => '報告を送信';

  @override
  String get helpReportEmpty => 'まず問題を説明してください';

  @override
  String get helpReportSent => 'ありがとうございます。報告が送信されました';

  @override
  String helpComingSoon(String what) {
    return '$whatはこのビルドではまだ利用できません。';
  }

  @override
  String get faqSpacedQ => '間隔反復はどのように機能しますか？';

  @override
  String get faqSpacedA =>
      'カードをめくったあと、どれくらい分かっていたかを評価します。難しかったカードは早く戻り、「簡単」と評価したカードは先に送られます。そのため、本当に苦手な単語に時間を使えます。';

  @override
  String get faqRatingsQ => 'もう一度・難しい・普通・簡単の違いは？';

  @override
  String get faqRatingsA =>
      'カードが戻るまでの間隔を決めます。もう一度は同じセッション内、難しいは約1日後、普通は数日後、簡単は約1週間後です。';

  @override
  String get faqReviewDueQ => 'カードの「復習時期」とは何ですか？';

  @override
  String get faqReviewDueA => '予定された復習日を過ぎたカードです。復習時期のカードは次の学習の最初に出題されます。';

  @override
  String get faqCreateDeckQ => 'デッキはどう作りますか？';

  @override
  String get faqCreateDeckA =>
      'デッキタブを開き、右上の「新しいデッキ」をタップします。タイトルを付けたら、デッキ内の「カードを追加」から中身を入れていきます。';

  @override
  String get faqPictureQ => 'カードに画像を追加できますか？';

  @override
  String get faqPictureA => 'はい。カードの追加・編集時に画像URL欄に画像のURLを貼り付けると、答え側に表示されます。';

  @override
  String get faqGoalQ => '1日の目標はどう計算されますか？';

  @override
  String get faqGoalA => 'ホーム画面のリングは、今日学習した分数を「プロフィール → 学習設定」で決めた1日の目標と比べています。';

  @override
  String get faqStreakQ => '連続日数がリセットされたのはなぜ？';

  @override
  String get faqStreakA => '連続日数は、復習を1件以上終えた日が続いた数です。まる1日空くと途切れます。';

  @override
  String get privacyIntro => 'LanGigaCards が保存する情報と、学習データの使われ方を管理できます。';

  @override
  String get privacySectionPrivacy => 'プライバシー';

  @override
  String get privacyUsageAnalytics => '利用状況の分析';

  @override
  String get privacyPersonalisedReview => 'パーソナライズされた復習順';

  @override
  String get privacyPublicProfile => '公開プロフィール';

  @override
  String get privacyAnalyticsOn => '匿名の利用データは復習アルゴリズムの改善に役立ちます。';

  @override
  String get privacyAnalyticsOff => '分析はオフです。アプリの使い方に関する情報は一切収集されません。';

  @override
  String get privacySectionSecurity => 'セキュリティ';

  @override
  String get privacyBiometric => '生体認証によるロック解除を必須にする';

  @override
  String get privacyChangePassword => 'パスワードを変更';

  @override
  String get privacyActiveSessions => 'アクティブなセッション';

  @override
  String get privacySectionYourData => 'あなたのデータ';

  @override
  String get privacyExportDecks => 'デッキをエクスポート';

  @override
  String get privacyDeleteAccount => 'アカウントを削除';

  @override
  String get privacyDeleteConfirm => 'アカウントを削除しますか？';

  @override
  String get privacyDeleteBody => 'デッキ・カード・復習履歴が完全に削除されます。元に戻すことはできません。';

  @override
  String privacyNeedsAccount(String what) {
    return '$whatにはログイン済みのアカウントが必要ですが、このビルドにはまだありません。';
  }

  @override
  String get privacyChangingPassword => 'パスワードの変更';

  @override
  String get privacySessionManagement => 'セッション管理';

  @override
  String privacyExportSaved(String path) {
    return '$path に保存されました';
  }

  @override
  String get changePasswordCurrentLabel => '現在のパスワード';

  @override
  String get changePasswordNewLabel => '新しいパスワード';

  @override
  String get changePasswordSuccess => 'パスワードを更新しました';

  @override
  String get changePasswordIncorrectCurrent => '現在のパスワードが正しくありません';

  @override
  String get privacyAccountDeletion => 'アカウントの削除';

  @override
  String get categoriesEditTitle => 'テーマを編集';

  @override
  String get categoriesSearchHint => 'テーマを検索...';

  @override
  String get languagesSearchHint => '言語を検索...';

  @override
  String get languagesPopular => '人気';

  @override
  String get reminderPermissionNeeded => 'リマインダーには通知の許可が必要です。システム設定で有効にしてください。';

  @override
  String reminderSetFor(String time) {
    return '毎日のリマインダーを$timeに設定しました';
  }

  @override
  String get reminderPickTime => '通知する時刻';

  @override
  String get wizardPurposeQuestion => 'この言語を学ぶ理由は何ですか？';

  @override
  String get wizardSelectAllThatApply => '当てはまるものをすべて選んでください';

  @override
  String get wizardAgeQuestion => '年齢層を教えてください';

  @override
  String get wizardTopicsQuestion => '最初にどのテーマを学びたいですか？';

  @override
  String get wizardAgeNote => '年齢はアクセシビリティ設定と学習体験の最適化に使用します。';

  @override
  String get studyAllUpToDate => '学習中のカードはすべて最新です。新しい単語を追加するか、復習の時期に戻ってきてください。';

  @override
  String studyDeckMastered(String deck) {
    return '$deckの内容はすべて習得済みです。続けるには新しい単語を追加してください。';
  }

  @override
  String get ttsVoiceMissingUnknown => 'この言語の音声はまだ端末にインストールされていません。';

  @override
  String ttsVoiceMissing(String language) {
    return '$languageの音声がまだインストールされていません。端末の音声読み上げ設定から追加してください。';
  }

  @override
  String get ttsUnavailable => 'この端末には利用可能な音声読み上げエンジンがありません。';

  @override
  String get ttsPlay => '発音を再生';

  @override
  String get ttsNothing => '読み上げる内容がありません';

  @override
  String ttsPlayOf(String text) {
    return '$text の発音を再生';
  }

  @override
  String get reminderNotificationTitle => '復習の時間です';

  @override
  String get reminderNotificationBody => 'カードが待っています。数分で連続記録を守れます。';

  @override
  String get splashTagline => 'どんな言語も学べる';

  @override
  String get profileLearningLabel => '学習中';
}
