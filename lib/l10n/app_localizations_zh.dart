// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appLanguageTitle => '选择应用语言';

  @override
  String get appLanguageSubtitle => '选择你想用来使用 LanGigaCards 的语言。';

  @override
  String get commonContinue => '继续';

  @override
  String get commonSignIn => '登录';

  @override
  String get commonSkip => '跳过';

  @override
  String get commonGetStarted => '开始使用';

  @override
  String get commonTryAgain => '重试';

  @override
  String get commonSave => '保存';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRequiredField => '此项为必填';

  @override
  String get commonSomethingWrong => '出了点问题，请重试。';

  @override
  String get commonNetworkError => '无法连接服务器。请检查网络后重试。';

  @override
  String get onboardingSlide1Title => '用卡片学习';

  @override
  String get onboardingSlide1Body => '通过成熟的间隔重复系统掌握词汇。在最恰当的时机复习卡片，让记忆更持久。';

  @override
  String get onboardingSlide2Title => '追踪学习进度';

  @override
  String get onboardingSlide2Body => '用清晰的统计图表回顾学习历程。在连续打卡和成就中，看着词汇量一天天增长。';

  @override
  String get onboardingSlide3Title => '达成你的目标';

  @override
  String get onboardingSlide3Body => '设定专属的每日目标，保持学习动力。智能算法会适应你的节奏，让学习变得轻松。';

  @override
  String get onboardingHaveAccount => '已经有账号了？';

  @override
  String get loginTitle => '欢迎回来';

  @override
  String get loginSubtitle => '登录以继续你的学习之旅';

  @override
  String get loginEmailLabel => '电子邮箱';

  @override
  String get loginPasswordLabel => '密码';

  @override
  String get loginRememberMe => '记住我';

  @override
  String get loginForgotPassword => '忘记密码？';

  @override
  String get loginOrContinueWith => '或使用以下方式继续';

  @override
  String get loginNoAccount => '还没有账号？';

  @override
  String get loginInvalidCredentials => '邮箱或密码不正确。如果还没有账号，请先注册。';

  @override
  String get registerTitle => '创建账号';

  @override
  String get registerBackToSignIn => '返回登录';

  @override
  String get registerSubtitle => '你的信息 — 语言和学习偏好在下一步设置。';

  @override
  String get registerFirstName => '名字';

  @override
  String get registerLastName => '姓氏';

  @override
  String get registerEmail => '电子邮箱';

  @override
  String get registerPassword => '密码';

  @override
  String get registerPasswordHint => '至少 8 个字符';

  @override
  String get registerConfirmPassword => '确认密码';

  @override
  String get registerConfirmHint => '请再次输入密码';

  @override
  String get registerInvalidEmail => '请输入有效的电子邮箱地址';

  @override
  String get registerPasswordTooShort => '密码至少需要 8 个字符';

  @override
  String get registerPasswordsDontMatch => '两次输入的密码不一致';

  @override
  String get registerEmailTaken => '该邮箱已注册过账号。';

  @override
  String get verifyTitle => '验证你的邮箱';

  @override
  String verifySubtitle(String email) {
    return '我们已向 $email 发送了 6 位验证码。请在下方输入以确认你的账号。';
  }

  @override
  String get verifyNoCode => '没有收到验证码？';

  @override
  String get verifyResend => '重新发送验证码';

  @override
  String get verifySending => '发送中…';

  @override
  String get verifyAction => '验证';

  @override
  String verifyEnterAllDigits(int count) {
    return '请输入全部 $count 位数字';
  }

  @override
  String get verifyIncorrect => '验证码不正确，请重试';

  @override
  String get verifyTooManyAttempts => '尝试次数过多。请点击「重新发送验证码」获取新验证码。';

  @override
  String get verifyResent => '新的验证码已发送到你的邮箱';

  @override
  String get forgotTitle => '重置密码';

  @override
  String get forgotSubtitle => '请输入你注册时使用的邮箱，我们会发送一个链接让你设置新密码。';

  @override
  String get forgotEmailLabel => '电子邮箱';

  @override
  String get forgotInvalidEmail => '请输入有效的邮箱地址';

  @override
  String get forgotSend => '发送重置链接';

  @override
  String get forgotCheckInbox => '请查看收件箱';

  @override
  String forgotSentTo(String email) {
    return '如果 $email 已注册，重置链接正在发送中。';
  }

  @override
  String get forgotNoMailServer => '此版本未连接邮件服务器，因此不会真正发送邮件。';

  @override
  String get forgotUseDifferent => '使用其他邮箱';

  @override
  String get navHome => '首页';

  @override
  String get navDecks => '卡组';

  @override
  String get navQuiz => '测验';

  @override
  String get navStats => '统计';

  @override
  String get navProfile => '我的';

  @override
  String get homeGreetingMorning => '早上好，';

  @override
  String get homeGreetingAfternoon => '下午好，';

  @override
  String get homeGreetingEvening => '晚上好，';

  @override
  String get homeContinueLearning => '继续学习';

  @override
  String homeCardsDue(int count) {
    return '$count 张待复习';
  }

  @override
  String homeMinGoal(int minutes) {
    return '每日 $minutes 分钟目标';
  }

  @override
  String get homeFinishSetup => '完成个人资料设置即可获得你的第一个卡组。';

  @override
  String get homeWords => '词汇';

  @override
  String get homeAccuracy => '正确率';

  @override
  String get homeStreak => '连续天数';

  @override
  String get homeContinueQuizLabel => '测验';

  @override
  String get homeContinueQuizTitle => '继续测验';

  @override
  String homeContinueQuizSubtitle(String deck, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 题',
    );
    return '$deck · $_temp0';
  }

  @override
  String homeReviewDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 待复习',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewDoneBadge => '已完成';

  @override
  String get homeYourTopics => '你的主题';

  @override
  String get homeRecentlyLearned => '最近学习';

  @override
  String get homeSeeAll => '查看全部';

  @override
  String get shellProfileLoadFailed => '无法加载你的资料';

  @override
  String get shellCheckConnection => '请检查网络后重试。';

  @override
  String get shellSyncDroppedOne => '有 1 项更改未能保存，已丢弃。';

  @override
  String shellSyncDroppedMany(int count) {
    return '有 $count 项更改未能保存，已丢弃。';
  }

  @override
  String get commonDelete => '删除';

  @override
  String get decksTitle => '我的卡组';

  @override
  String get decksNewDeck => '新建卡组';

  @override
  String decksSummary(int decks, int due) {
    return '$decks 个卡组 · 今日待复习 $due 张';
  }

  @override
  String decksDueForReview(int count) {
    return '$count 张待复习';
  }

  @override
  String get decksSortedByUrgency => '按紧急程度排序 · 点击开始';

  @override
  String get decksSearchHint => '搜索卡组...';

  @override
  String decksNoMatch(String query) {
    return '没有与「$query」匹配的卡组';
  }

  @override
  String get decksNoneYet => '还没有卡组';

  @override
  String get decksTryDifferentSearch => '换个关键词搜索，或用这个名字新建一个卡组。';

  @override
  String get decksEmptyHelp => '卡组用来归纳你想学的单词。先创建第一个吧。';

  @override
  String get decksCreateADeck => '创建卡组';

  @override
  String get decksOptions => '卡组选项';

  @override
  String get decksQuizThis => '测验这个卡组';

  @override
  String get decksRename => '重命名卡组';

  @override
  String get decksDelete => '删除卡组';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张卡片',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => '待复习';

  @override
  String decksReviewCount(int count) {
    return '复习 $count 次';
  }

  @override
  String get decksMastery => '掌握度';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '学习 $count 张',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => '全部完成';

  @override
  String get decksBrowse => '浏览';

  @override
  String get decksRenameTitle => '重命名卡组';

  @override
  String get decksCreateTitle => '创建新卡组';

  @override
  String get decksTitleLabel => '标题 *';

  @override
  String get decksTitleHint => '例如：法语基础';

  @override
  String get decksDescriptionLabel => '描述（可选）';

  @override
  String get decksDescriptionHint => '描述这个卡组的内容...';

  @override
  String get decksSaveChanges => '保存更改';

  @override
  String get decksCreateDeck => '创建卡组';

  @override
  String get decksNoDescription => '暂无描述';

  @override
  String decksDeleteConfirm(String name) {
    return '要删除「$name」吗？';
  }

  @override
  String get decksDeleteEmpty => '该卡组为空，将被删除。';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '卡组及其 $count 张卡片都将被删除。',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '已删除「$name」';
  }

  @override
  String get decksCreateFailed => '无法创建卡组，请重试。';

  @override
  String get decksDeleteFailed => '无法删除卡组，请重试。';

  @override
  String get decksSaveFailed => '无法保存更改，请重试。';

  @override
  String get quizDecksTitle => '测验卡组';

  @override
  String get quizDecksStartQuiz => '开始测验';

  @override
  String get quizDecksEmpty => '还没有卡组';

  @override
  String get quizDecksEmptyHelp => '在「卡组」标签页创建一个卡组，然后回到这里进行测验。';

  @override
  String quizDecksNotEnoughCards(int min) {
    return '至少添加 $min 张卡片以解锁测验';
  }

  @override
  String get detailNotFound => '该卡组已不存在';

  @override
  String get detailBackToDecks => '返回卡组';

  @override
  String get detailProgress => '进度';

  @override
  String get detailMastered => '已掌握';

  @override
  String get detailLearning => '学习中';

  @override
  String get detailCards => '卡片';

  @override
  String get detailReviews => '复习';

  @override
  String get detailBrowseAll => '查看全部';

  @override
  String detailMore(int count) {
    return '还有 $count 张';
  }

  @override
  String get detailBack => '返回';

  @override
  String get detailAddCardTooltip => '为该卡组添加卡片';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label：$total 张中的 $count 张';
  }

  @override
  String get detailEmpty => '该卡组为空';

  @override
  String get detailEmptyHelp => '添加几个单词，马上就能开始学习。';

  @override
  String get detailAddCard => '添加卡片';

  @override
  String get cardEditTitle => '编辑卡片';

  @override
  String get cardAddTitle => '新建卡片';

  @override
  String get cardDeckLabel => '卡组 *';

  @override
  String get cardFrontLabel => '正面（目标词）*';

  @override
  String get cardBackLabel => '背面（翻译）*';

  @override
  String get cardFrontHint => '例如：Bonjour';

  @override
  String get cardBackHint => '例如：你好';

  @override
  String get cardExampleLabel => '例句';

  @override
  String get cardExampleHint => '写一个例句...';

  @override
  String get cardImageLabel => '图片链接';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError => '请输入以 http:// 或 https:// 开头的完整图片地址';

  @override
  String get cardAdd => '添加卡片';

  @override
  String get cardAddFailed => '无法添加卡片，请重试。';

  @override
  String get libraryTitle => '卡片库';

  @override
  String get librarySearchHint => '搜索正面或背面...';

  @override
  String get libraryAllDecks => '所有卡组';

  @override
  String libraryTotalItems(int count) {
    return '共 $count 项';
  }

  @override
  String get libraryShowingAll => '显示全部';

  @override
  String get libraryFilteredByDeck => '已按卡组筛选';

  @override
  String get libraryStudyThisDeck => '学习这个卡组';

  @override
  String libraryNoMatch(String query) {
    return '没有与「$query」匹配的卡片';
  }

  @override
  String get libraryNoneYet => '这里还没有卡片';

  @override
  String get libraryCheckSpelling => '检查拼写，或清除卡组筛选以搜索全部。';

  @override
  String get libraryAddFirst => '添加第一个单词，它会出现在你的下次学习中。';

  @override
  String get libraryUnknownDeck => '未知卡组';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · 复习 $count 次';
  }

  @override
  String get libraryEditCard => '编辑卡片';

  @override
  String get libraryDeleteCard => '删除卡片';

  @override
  String get libraryDeleteConfirmTitle => '要删除这张卡片吗？';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '「$term」将从你的卡片库中永久删除。';
  }

  @override
  String libraryCardDeleted(String term) {
    return '已删除「$term」';
  }

  @override
  String get libraryDeleteFailed => '无法删除卡片，请重试。';

  @override
  String get studyAllDecks => '所有卡组';

  @override
  String studyDailyReview(String deck) {
    return '每日复习 · $deck';
  }

  @override
  String studyWordHint(String term) {
    return '单词：$term。点击查看翻译。';
  }

  @override
  String studyAnswerHint(String translation) {
    return '答案：$translation。点击可再次查看单词。滑动跳过，或在下方评分。';
  }

  @override
  String get studyRateBelow => '在下方评分，或滑动跳过不评分';

  @override
  String get studyRecallHint => '先回想翻译，再翻面确认';

  @override
  String get studyNothingDue => '当前没有待复习的卡片';

  @override
  String get studyBackToDecks => '返回卡组';

  @override
  String get studyQueueFailed => '无法加载你的复习队列';

  @override
  String get studyTapToSeeExample => '[ 点击查看例句 ]';

  @override
  String get studyShowExample => '显示例句';

  @override
  String get studyTapToReveal => '点击查看翻译';

  @override
  String studyHearPronounced(String term) {
    return '听 $term 的发音';
  }

  @override
  String get studyHearIt => '朗读';

  @override
  String get studyTranslationLabel => '翻译';

  @override
  String get studyExampleLabel => '例句';

  @override
  String get studyImageFailed => '图片加载失败';

  @override
  String get studyAllCaughtUp => '全部完成！';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你已复习完今天全部 $count 张卡片',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => '把握度';

  @override
  String get studyViewStats => '查看统计';

  @override
  String get quizTimeUp => '⏰ 时间到！正确答案如下。';

  @override
  String quizProgress(int index, int total) {
    return '第 $index 题 / 共 $total 题';
  }

  @override
  String get quizFinish => '完成';

  @override
  String get quizNextQuestion => '下一题 →';

  @override
  String get quizNotEnough => '卡片不足，无法测验';

  @override
  String quizNotEnoughAll(int min) {
    return '添加至少 $min 张翻译各不相同的卡片，测验就会自动生成。';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck 需要至少 $min 张翻译各不相同的卡片才能进行测验。';
  }

  @override
  String get quizBack => '返回';

  @override
  String get quizPerfect => '满分！';

  @override
  String get quizGreat => '做得很好！';

  @override
  String get quizNice => '进步不错';

  @override
  String get quizKeepPractising => '继续练习';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return '你答对了 $total 题中的 $score 题';
  }

  @override
  String get quizScore => '得分';

  @override
  String get quizDone => '完成';

  @override
  String get statsTitle => '统计';

  @override
  String get statsSubtitle => '用数字看你的学习历程';

  @override
  String get statsStreak => '连续天数';

  @override
  String get statsReviews => '复习';

  @override
  String get statsRecall => '记忆率';

  @override
  String statsTodayDelta(int count) {
    return '今日 +$count';
  }

  @override
  String get statsNoData => '暂无数据';

  @override
  String get statsHeatmap => '学习热力图';

  @override
  String statsStreakSummary(int days, int total) {
    return '连续 $days 天 · 已记录 $total 次复习';
  }

  @override
  String statsReviewsLogged(int total) {
    return '已记录 $total 次复习';
  }

  @override
  String get statsLess => '少';

  @override
  String get statsMore => '多';

  @override
  String get statsNoActivity => '还没有活动记录';

  @override
  String get statsLibraryBreakdown => '卡片库构成';

  @override
  String get statsAchievements => '成就';

  @override
  String statsEarned(int earned, int total) {
    return '已获得 $earned / $total';
  }

  @override
  String get statsAddCards => '添加一些卡片即可查看进度';

  @override
  String get statsDaily => '日';

  @override
  String get statsWeekly => '周';

  @override
  String get statsMonthly => '月';

  @override
  String get statsChartDaily => '复习，最近 7 天';

  @override
  String get statsChartWeekly => '复习，最近 4 周';

  @override
  String get statsChartMonthly => '复习，最近 6 个月';

  @override
  String statsChartTotal(int count) {
    return '共 $count';
  }

  @override
  String get profileStudyPreferences => '学习偏好';

  @override
  String get profileNativeLanguage => '母语';

  @override
  String get profileTargetLanguage => '目标语言';

  @override
  String get profileLearningPurpose => '学习目的';

  @override
  String get profileStudyCategories => '学习主题';

  @override
  String get profileDailyGoal => '每日目标';

  @override
  String get profileAppPreferences => '应用偏好';

  @override
  String get profileDarkMode => '深色模式';

  @override
  String get profileAppLanguage => '应用语言';

  @override
  String get profileSoundEffects => '音效';

  @override
  String get profileDailyReminder => '每日提醒';

  @override
  String get profileThemeColor => '主题色';

  @override
  String get profileTextSize => '文字大小';

  @override
  String get profileDifficultyMode => '难度模式';

  @override
  String get profileAccount => '账号';

  @override
  String get profileEditProfile => '编辑资料';

  @override
  String get profilePrivacySecurity => '隐私与安全';

  @override
  String get profileUpgradePremium => '升级到高级版';

  @override
  String get profileHelpSupport => '帮助与支持';

  @override
  String get profileLogOut => '退出登录';

  @override
  String get profileLogOutConfirm => '要退出登录吗？';

  @override
  String get profileLogOutBody => '继续学习需要重新登录。';

  @override
  String get profileNoneYet => '暂无';

  @override
  String profileSelectedCount(int count) {
    return '已选 $count 项';
  }

  @override
  String profileTopicsCount(int count) {
    return '$count 个主题';
  }

  @override
  String profileMinutes(int min) {
    return '$min 分钟';
  }

  @override
  String get profileNative => '母语';

  @override
  String get profileEdit => '编辑';

  @override
  String get profileFullName => '姓名';

  @override
  String get profileEmailAddress => '电子邮箱';

  @override
  String get profileNameRequired => '姓名为必填项';

  @override
  String get profileEmailRequired => '邮箱为必填项';

  @override
  String get profileClose => '关闭';

  @override
  String get profileWhyLearning => '你为什么学习？可多选。';

  @override
  String get profileDecreaseGoal => '减少每日目标';

  @override
  String get profileIncreaseGoal => '增加每日目标';

  @override
  String get profileYouSpeakThis => '这是你会说的语言';

  @override
  String get profileLearningThis => '这是你正在学的语言';

  @override
  String profileLevelBadge(int level) {
    return '⭐ 等级 $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ 连续 $days 天';
  }

  @override
  String get profileServerUnreachable => '无法连接服务器。请检查网络后重试。';

  @override
  String get profileSaveNameFailed => '无法保存姓名，请重试。';

  @override
  String get profileSaveLanguageFailed => '无法保存语言设置，请重试。';

  @override
  String get profileSaveGoalFailed => '无法保存每日目标，请重试。';

  @override
  String get profileSaveCategoriesFailed => '无法保存学习主题，请重试。';

  @override
  String get profileSavePurposesFailed => '无法保存学习目的，请重试。';

  @override
  String get profileLoadCategoriesFailed => '无法加载学习主题。请检查网络后重试。';

  @override
  String get profileLoadPurposesFailed => '无法加载学习目的。请检查网络后重试。';

  @override
  String wizardStep(int current, int total, String label) {
    return '第 $current 步 / 共 $total 步 — $label';
  }

  @override
  String get wizardNativeLanguage => '母语';

  @override
  String get wizardTargetLanguage => '目标语言';

  @override
  String get wizardTargetLevel => '目标语言水平';

  @override
  String get wizardLearningPurpose => '学习目的';

  @override
  String get wizardTopics => '主题与分类';

  @override
  String get wizardAge => '你的年龄';

  @override
  String get wizardDailyGoal => '每日目标';

  @override
  String get wizardNativeQuestion => '你的母语是什么？';

  @override
  String get wizardTargetQuestion => '你想学习哪种语言？';

  @override
  String wizardLevelQuestion(String language) {
    return '你目前的$language水平如何？';
  }

  @override
  String get wizardLevelHint => '选一个感觉合适的 — 随时可以调整。';

  @override
  String get wizardGoalQuestion => '你每天能投入多少时间？';

  @override
  String wizardSelectedHint(int count) {
    return '已选 $count 项 · 之后可以修改';
  }

  @override
  String get wizardNativePrefix => '母语：';

  @override
  String get wizardStart => '开始学习吧 🚀';

  @override
  String get wizardLoadFailed => '无法加载设置选项';

  @override
  String get wizardSaveFailed => '无法保存你的主题或学习目的，请重试。';

  @override
  String get levelJustStarting => '刚刚起步';

  @override
  String get levelJustStartingDesc => '正在学习基础';

  @override
  String get levelBeginner => '初级';

  @override
  String get levelBeginnerDesc => '认识一些单词和短语';

  @override
  String get levelIntermediate => '中级';

  @override
  String get levelIntermediateDesc => '能进行简单对话';

  @override
  String get levelAdvanced => '高级';

  @override
  String get levelAdvancedDesc => '大多数场合都能应对';

  @override
  String get levelFluent => '流利';

  @override
  String get levelFluentDesc => '接近母语水平';

  @override
  String get goalCasual => '轻松';

  @override
  String get goalRegular => '常规';

  @override
  String get goalIntense => '强化';

  @override
  String goalWordsPerDay(int count) {
    return '每天约 $count 个词';
  }

  @override
  String get helpSearchHint => '搜索帮助文章...';

  @override
  String get helpFrequentlyAsked => '常见问题';

  @override
  String helpNoMatch(String query) {
    return '没有与「$query」匹配的文章';
  }

  @override
  String get helpStillStuck => '还没解决？';

  @override
  String get helpEmailSupport => '邮件支持';

  @override
  String get helpCommunityForum => '社区论坛';

  @override
  String get helpReportProblem => '报告问题';

  @override
  String get helpTheCommunityForum => '社区论坛';

  @override
  String get helpProblemReporting => '问题反馈';

  @override
  String helpComingSoon(String what) {
    return '$what在此版本中尚不可用。';
  }

  @override
  String get faqSpacedQ => '间隔重复是怎么运作的？';

  @override
  String get faqSpacedA =>
      '翻开卡片后，你会评价自己掌握的程度。觉得困难的卡片会更早回来，标为「简单」的会推得更远，这样你的时间就花在真正难住你的词上。';

  @override
  String get faqRatingsQ => '重来、困难、一般、简单分别是什么意思？';

  @override
  String get faqRatingsA => '它们决定卡片多久后再出现。重来会在本次学习中再次出现，困难约一天后，一般几天后，简单约一周后。';

  @override
  String get faqReviewDueQ => '卡片上的「待复习」是什么意思？';

  @override
  String get faqReviewDueA => '该卡片已过了预定的复习日期。待复习的卡片会排在你下次学习的最前面。';

  @override
  String get faqCreateDeckQ => '怎么创建卡组？';

  @override
  String get faqCreateDeckA => '打开「卡组」标签，点击右上角的「新建卡组」。取好标题后，在卡组中用「添加卡片」开始填充内容。';

  @override
  String get faqPictureQ => '可以给卡片加图片吗？';

  @override
  String get faqPictureA => '可以。添加或编辑卡片时，把图片地址粘贴到「图片链接」栏，它就会出现在答案面。';

  @override
  String get faqGoalQ => '每日目标是怎么计算的？';

  @override
  String get faqGoalA => '主页上的圆环会把你今天学习的分钟数与「我的 → 学习偏好」中设定的每日目标做对比。';

  @override
  String get faqStreakQ => '我的连续天数为什么归零了？';

  @override
  String get faqStreakA => '连续天数统计的是每天至少完成一次复习的连续天数。整整错过一天就会中断。';

  @override
  String get privacyIntro => '管理 LanGigaCards 保存的关于你的信息，以及学习数据的使用方式。';

  @override
  String get privacySectionPrivacy => '隐私';

  @override
  String get privacyUsageAnalytics => '使用分析';

  @override
  String get privacyPersonalisedReview => '个性化复习顺序';

  @override
  String get privacyPublicProfile => '公开资料';

  @override
  String get privacyAnalyticsOn => '匿名使用数据有助于改进复习算法。';

  @override
  String get privacyAnalyticsOff => '分析已关闭。不会收集任何关于你如何使用应用的信息。';

  @override
  String get privacySectionSecurity => '安全';

  @override
  String get privacyBiometric => '要求生物识别解锁';

  @override
  String get privacyChangePassword => '修改密码';

  @override
  String get privacyActiveSessions => '活跃会话';

  @override
  String get privacySectionYourData => '你的数据';

  @override
  String get privacyExportDecks => '导出我的卡组';

  @override
  String get privacyDeleteAccount => '删除账号';

  @override
  String get privacyDeleteConfirm => '要删除账号吗？';

  @override
  String get privacyDeleteBody => '这会永久删除你的卡组、卡片和复习记录，且无法撤销。';

  @override
  String privacyNeedsAccount(String what) {
    return '$what需要已登录的账号，而此版本还没有。';
  }

  @override
  String get privacyChangingPassword => '修改密码';

  @override
  String get privacySessionManagement => '会话管理';

  @override
  String get privacyExportingDecks => '导出卡组';

  @override
  String get privacyAccountDeletion => '删除账号';

  @override
  String get categoriesEditTitle => '编辑主题';

  @override
  String get categoriesSearchHint => '搜索主题...';

  @override
  String get languagesSearchHint => '搜索语言...';

  @override
  String get languagesPopular => '热门';

  @override
  String get reminderPermissionNeeded => '提醒需要通知权限，请在系统设置中开启。';

  @override
  String reminderSetFor(String time) {
    return '每日提醒已设为 $time';
  }

  @override
  String get reminderPickTime => '提醒时间';

  @override
  String get wizardPurposeQuestion => '你为什么学习这门语言？';

  @override
  String get wizardSelectAllThatApply => '可多选';

  @override
  String get wizardAgeQuestion => '你的年龄段是？';

  @override
  String get wizardTopicsQuestion => '你想先学习哪些主题？';

  @override
  String get wizardAgeNote => '我们使用你的年龄来优化无障碍设置和学习体验。';

  @override
  String get studyAllUpToDate => '你正在学习的卡片都已是最新。添加新单词，或等到复习时间再回来。';

  @override
  String studyDeckMastered(String deck) {
    return '你已掌握 $deck 中的全部内容。添加新单词继续学习。';
  }

  @override
  String get ttsVoiceMissingUnknown => '该语言的语音尚未安装到你的设备上。';

  @override
  String ttsVoiceMissing(String language) {
    return '$language 语音尚未安装。请在系统的文字转语音设置中添加。';
  }

  @override
  String get ttsUnavailable => '此设备没有可用的文字转语音引擎。';

  @override
  String get ttsPlay => '播放发音';

  @override
  String get ttsNothing => '没有可朗读的内容';

  @override
  String ttsPlayOf(String text) {
    return '播放 $text 的发音';
  }

  @override
  String get reminderNotificationTitle => '该复习了';

  @override
  String get reminderNotificationBody => '你的卡片在等着你——几分钟就能保住连续记录。';

  @override
  String get splashTagline => '学习任何语言';

  @override
  String get profileLearningLabel => '学习中';
}
