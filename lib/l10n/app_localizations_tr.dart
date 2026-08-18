// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appLanguageTitle => 'Uygulama Dilini Seçin';

  @override
  String get appLanguageSubtitle =>
      'LanGigaCards\'ı hangi dilde kullanmak istediğinizi seçin.';

  @override
  String get commonContinue => 'Devam';

  @override
  String get commonSignIn => 'Giriş Yap';

  @override
  String get commonSkip => 'Atla';

  @override
  String get commonGetStarted => 'Başlayalım';

  @override
  String get commonTryAgain => 'Tekrar Dene';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonRequiredField => 'Bu alan zorunlu';

  @override
  String get commonSomethingWrong =>
      'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  @override
  String get commonNetworkError =>
      'Sunucuya ulaşılamıyor. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get onboardingSlide1Title => 'Kartlarla Öğrenin';

  @override
  String get onboardingSlide1Body =>
      'Kanıtlanmış aralıklı tekrar sistemimizle kelimeleri kalıcı hale getirin. Kartları tam doğru anda tekrar ederek hafızanızda en uzun süre kalmasını sağlayın.';

  @override
  String get onboardingSlide2Title => 'İlerlemenizi Takip Edin';

  @override
  String get onboardingSlide2Body =>
      'Öğrenme yolculuğunuzu şık istatistiklerle görün. Kelime dağarcığınızın gün geçtikçe büyümesini seriler ve başarımlarla izleyin.';

  @override
  String get onboardingSlide3Title => 'Hedeflerinize Ulaşın';

  @override
  String get onboardingSlide3Body =>
      'Size özel günlük hedefler belirleyin ve motivasyonunuzu koruyun. Akıllı algoritmamız hızınıza uyum sağlar, öğrenmek zahmetsiz olur.';

  @override
  String get onboardingHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get loginTitle => 'Tekrar hoş geldiniz';

  @override
  String get loginSubtitle =>
      'Öğrenme yolculuğunuza devam etmek için giriş yapın';

  @override
  String get loginEmailLabel => 'E-posta adresi';

  @override
  String get loginPasswordLabel => 'Şifre';

  @override
  String get loginRememberMe => 'Beni hatırla';

  @override
  String get loginForgotPassword => 'Şifremi unuttum';

  @override
  String get loginOrContinueWith => 'ya da şununla devam edin';

  @override
  String get loginNoAccount => 'Hesabınız yok mu?';

  @override
  String get loginInvalidCredentials =>
      'E-posta veya şifre hatalı. Henüz hesabınız yoksa bir hesap oluşturun.';

  @override
  String get registerTitle => 'Hesap Oluştur';

  @override
  String get registerBackToSignIn => 'Girişe dön';

  @override
  String get registerSubtitle =>
      'Bilgileriniz — diller ve çalışma tercihleri sonraki adımda.';

  @override
  String get registerFirstName => 'Ad';

  @override
  String get registerLastName => 'Soyad';

  @override
  String get registerEmail => 'E-posta Adresi';

  @override
  String get registerPassword => 'Şifre';

  @override
  String get registerPasswordHint => 'En az 8 karakter';

  @override
  String get registerConfirmPassword => 'Şifre Tekrar';

  @override
  String get registerConfirmHint => 'Şifrenizi tekrar girin';

  @override
  String get registerInvalidEmail => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get registerPasswordTooShort => 'Şifre en az 8 karakter olmalı';

  @override
  String get registerPasswordsDontMatch => 'Şifreler eşleşmiyor';

  @override
  String get registerEmailTaken => 'Bu e-posta ile bir hesap zaten var.';

  @override
  String get verifyTitle => 'E-postanızı Doğrulayın';

  @override
  String verifySubtitle(String email) {
    return '$email adresine 6 haneli bir kod gönderdik. Hesabınızı onaylamak için kodu aşağıya girin.';
  }

  @override
  String get verifyNoCode => 'Kod gelmedi mi?';

  @override
  String get verifyResend => 'Kodu tekrar gönder';

  @override
  String get verifySending => 'Gönderiliyor…';

  @override
  String get verifyAction => 'Doğrula';

  @override
  String verifyEnterAllDigits(int count) {
    return '$count hanenin tamamını girin';
  }

  @override
  String get verifyIncorrect => 'Kod hatalı, lütfen tekrar deneyin';

  @override
  String get verifyTooManyAttempts =>
      'Çok fazla deneme yapıldı. Yeni kod için \"Kodu tekrar gönder\"e dokunun.';

  @override
  String get verifyResent => 'E-postanıza yeni bir kod gönderildi';

  @override
  String get forgotTitle => 'Şifrenizi sıfırlayın';

  @override
  String get forgotSubtitle =>
      'Kayıt olurken kullandığınız e-postayı girin, yeni bir şifre belirlemeniz için bağlantı gönderelim.';

  @override
  String get forgotEmailLabel => 'E-posta adresi';

  @override
  String get forgotInvalidEmail => 'Geçerli bir e-posta adresi girin';

  @override
  String get forgotSend => 'Sıfırlama bağlantısı gönder';

  @override
  String get forgotCheckInbox => 'Gelen kutunuzu kontrol edin';

  @override
  String forgotSentTo(String email) {
    return '$email adresine ait bir hesap varsa, sıfırlama bağlantısı yolda.';
  }

  @override
  String get forgotNoMailServer =>
      'Bu sürümde bağlı bir e-posta sunucusu yok, bu yüzden gerçek bir e-posta gönderilmiyor.';

  @override
  String get forgotUseDifferent => 'Başka bir e-posta kullan';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navDecks => 'Desteler';

  @override
  String get navQuiz => 'Test';

  @override
  String get navStats => 'İstatistik';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeGreetingMorning => 'Günaydın,';

  @override
  String get homeGreetingAfternoon => 'İyi günler,';

  @override
  String get homeGreetingEvening => 'İyi akşamlar,';

  @override
  String get homeContinueLearning => 'ÖĞRENMEYE DEVAM';

  @override
  String homeCardsDue(int count) {
    return '$count kart bekliyor';
  }

  @override
  String homeMinGoal(int minutes) {
    return '$minutes dk hedef';
  }

  @override
  String get homeFinishSetup =>
      'İlk destenizi almak için profilinizi tamamlayın.';

  @override
  String get homeWords => 'Kelime';

  @override
  String get homeAccuracy => 'Doğruluk';

  @override
  String get homeStreak => 'Seri';

  @override
  String get homeContinueQuizLabel => 'TEST';

  @override
  String get homeContinueQuizTitle => 'Quiz\'e Devam Et';

  @override
  String homeContinueQuizSubtitle(String deck, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count soru',
    );
    return '$deck · $_temp0';
  }

  @override
  String homeReviewDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bekliyor',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewDoneBadge => 'Tamamlandı';

  @override
  String get homeYourTopics => 'Konularınız';

  @override
  String get homeRecentlyLearned => 'Son Öğrenilenler';

  @override
  String get homeSeeAll => 'Tümünü gör';

  @override
  String get shellProfileLoadFailed => 'Profiliniz yüklenemedi';

  @override
  String get shellCheckConnection =>
      'Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get shellSyncDroppedOne => '1 değişiklik kaydedilemedi ve silindi.';

  @override
  String shellSyncDroppedMany(int count) {
    return '$count değişiklik kaydedilemedi ve silindi.';
  }

  @override
  String get commonDelete => 'Sil';

  @override
  String get decksTitle => 'Destelerim';

  @override
  String get decksNewDeck => 'Yeni Deste';

  @override
  String decksSummary(int decks, int due) {
    return '$decks deste · bugün $due kart bekliyor';
  }

  @override
  String decksDueForReview(int count) {
    return 'Tekrar için $count kart bekliyor';
  }

  @override
  String get decksSortedByUrgency =>
      'Aciliyete göre sıralı · Başlamak için dokunun';

  @override
  String get decksSearchHint => 'Destelerde ara...';

  @override
  String decksNoMatch(String query) {
    return '\"$query\" ile eşleşen deste yok';
  }

  @override
  String get decksNoneYet => 'Henüz deste yok';

  @override
  String get decksTryDifferentSearch =>
      'Farklı bir arama deneyin ya da bu adla bir deste oluşturun.';

  @override
  String get decksEmptyHelp =>
      'Desteler öğrenmek istediğiniz kelimeleri bir arada tutar. Başlamak için ilkini oluşturun.';

  @override
  String get decksCreateADeck => 'Deste oluştur';

  @override
  String get decksOptions => 'Deste seçenekleri';

  @override
  String get decksQuizThis => 'Bu desteyi test et';

  @override
  String get decksRename => 'Desteyi yeniden adlandır';

  @override
  String get decksDelete => 'Desteyi sil';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kart',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => 'Tekrar Zamanı';

  @override
  String decksReviewCount(int count) {
    return '$count tekrar';
  }

  @override
  String get decksMastery => 'Ustalık';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kart çalış',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'Hepsi tamam';

  @override
  String get decksBrowse => 'Göz at';

  @override
  String get decksRenameTitle => 'Desteyi Yeniden Adlandır';

  @override
  String get decksCreateTitle => 'Yeni Deste Oluştur';

  @override
  String get decksTitleLabel => 'BAŞLIK *';

  @override
  String get decksTitleHint => 'örn. Fransızca Temeller';

  @override
  String get decksDescriptionLabel => 'AÇIKLAMA (İSTEĞE BAĞLI)';

  @override
  String get decksDescriptionHint => 'Bu deste neyi kapsıyor...';

  @override
  String get decksSaveChanges => 'Değişiklikleri Kaydet';

  @override
  String get decksCreateDeck => 'Deste Oluştur';

  @override
  String get decksNoDescription => 'Henüz açıklama yok';

  @override
  String decksDeleteConfirm(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get decksDeleteEmpty => 'Bu deste boş ve kaldırılacak.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deste ve içindeki $count kart kaldırılacak.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '\"$name\" silindi';
  }

  @override
  String get decksCreateFailed =>
      'Deste oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get decksDeleteFailed => 'Deste silinemedi. Lütfen tekrar deneyin.';

  @override
  String get decksSaveFailed =>
      'Değişiklikler kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get quizDecksTitle => 'Quiz Desteleri';

  @override
  String get quizDecksStartQuiz => 'Quiz Başlat';

  @override
  String get quizDecksEmpty => 'Henüz deste yok';

  @override
  String get quizDecksEmptyHelp =>
      'Desteler sekmesinden bir deste oluşturun, sonra kendinizi test etmek için buraya dönün.';

  @override
  String quizDecksNotEnoughCards(int min) {
    return 'Quiz için en az $min kart ekleyin';
  }

  @override
  String get detailNotFound => 'Bu deste artık mevcut değil';

  @override
  String get detailBackToDecks => 'Destelere dön';

  @override
  String get detailProgress => 'İLERLEME';

  @override
  String get detailMastered => 'Öğrenildi';

  @override
  String get detailLearning => 'Öğreniliyor';

  @override
  String get detailCards => 'Kart';

  @override
  String get detailReviews => 'Tekrar';

  @override
  String get detailBrowseAll => 'Tümüne göz at';

  @override
  String detailMore(int count) {
    return '+ $count tane daha';
  }

  @override
  String get detailBack => 'Geri';

  @override
  String get detailAddCardTooltip => 'Bu desteye kart ekle';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label: $total karttan $count tanesi';
  }

  @override
  String get detailEmpty => 'Bu deste boş';

  @override
  String get detailEmptyHelp =>
      'Birkaç kelime ekleyin, hemen çalışmaya başlayabilirsiniz.';

  @override
  String get detailAddCard => 'Kart ekle';

  @override
  String get cardEditTitle => 'Kartı Düzenle';

  @override
  String get cardAddTitle => 'Yeni Kart Ekle';

  @override
  String get cardDeckLabel => 'DESTE *';

  @override
  String get cardFrontLabel => 'ÖN YÜZ (HEDEF KELİME) *';

  @override
  String get cardBackLabel => 'ARKA YÜZ (ÇEVİRİ) *';

  @override
  String get cardFrontHint => 'örn. Bonjour';

  @override
  String get cardBackHint => 'örn. Merhaba';

  @override
  String get cardExampleLabel => 'ÖRNEK CÜMLE';

  @override
  String get cardExampleHint => 'Bir örnek cümle yazın...';

  @override
  String get cardImageLabel => 'GÖRSEL BAĞLANTISI';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError =>
      'http:// veya https:// ile başlayan tam bir görsel adresi girin';

  @override
  String get cardAdd => 'Kart Ekle';

  @override
  String get cardAddFailed => 'Kart eklenemedi. Lütfen tekrar deneyin.';

  @override
  String get libraryTitle => 'Kart Kütüphanesi';

  @override
  String get librarySearchHint => 'Ön ya da arka yüzde ara...';

  @override
  String get libraryAllDecks => 'Tüm Desteler';

  @override
  String libraryTotalItems(int count) {
    return 'Toplam: $count';
  }

  @override
  String get libraryShowingAll => 'Tümü gösteriliyor';

  @override
  String get libraryFilteredByDeck => 'Desteye göre süzülmüş';

  @override
  String get libraryStudyThisDeck => 'Bu Desteyi Çalış';

  @override
  String libraryNoMatch(String query) {
    return '\"$query\" ile eşleşen kart yok';
  }

  @override
  String get libraryNoneYet => 'Burada henüz kart yok';

  @override
  String get libraryCheckSpelling =>
      'Yazımı kontrol edin ya da her yerde aramak için deste süzgecini kaldırın.';

  @override
  String get libraryAddFirst =>
      'İlk kelimenizi ekleyin, bir sonraki çalışmanızda karşınıza çıkacak.';

  @override
  String get libraryUnknownDeck => 'Bilinmeyen deste';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · $count tekrar';
  }

  @override
  String get libraryEditCard => 'Kartı düzenle';

  @override
  String get libraryDeleteCard => 'Kartı sil';

  @override
  String get libraryDeleteConfirmTitle => 'Kart silinsin mi?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '\"$term\" kütüphanenizden kalıcı olarak kaldırılacak.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '\"$term\" silindi';
  }

  @override
  String get libraryDeleteFailed => 'Kart silinemedi. Lütfen tekrar deneyin.';

  @override
  String get studyAllDecks => 'Tüm desteler';

  @override
  String studyDailyReview(String deck) {
    return 'Günlük Tekrar · $deck';
  }

  @override
  String studyWordHint(String term) {
    return 'Kelime: $term. Çeviriyi görmek için dokunun.';
  }

  @override
  String studyAnswerHint(String translation) {
    return 'Cevap: $translation. Kelimeyi yeniden görmek için dokunun. Atlamak için kaydırın ya da aşağıdan puanlayın.';
  }

  @override
  String get studyRateBelow =>
      'Aşağıdan puanlayın ya da puanlamadan kaydırıp geçin';

  @override
  String get studyRecallHint =>
      'Çeviriyi hatırlayın, sonra çevirip kontrol edin';

  @override
  String get studyNothingDue => 'Şu an bekleyen kart yok';

  @override
  String get studyBackToDecks => 'Destelere Dön';

  @override
  String get studyQueueFailed => 'Tekrar listeniz yüklenemedi';

  @override
  String get studyTapToSeeExample => '[ örnek için dokunun ]';

  @override
  String get studyShowExample => 'Örnek Cümleyi Göster';

  @override
  String get studyTapToReveal => 'Çeviriyi görmek için dokunun';

  @override
  String studyHearPronounced(String term) {
    return '$term kelimesinin okunuşunu dinle';
  }

  @override
  String get studyHearIt => 'Dinle';

  @override
  String get studyTranslationLabel => 'ÇEVİRİ';

  @override
  String get studyExampleLabel => 'ÖRNEK';

  @override
  String get studyImageFailed => 'Görsel yüklenemedi';

  @override
  String get studyAllCaughtUp => 'Hepsi Tamam!';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bugün bekleyen $count kartın tamamını tekrar ettiniz',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => 'güven';

  @override
  String get studyViewStats => 'İstatistikler';

  @override
  String get quizTimeUp => '⏰ Süre doldu! Doğru cevap şu.';

  @override
  String quizProgress(int index, int total) {
    return 'Soru $index / $total';
  }

  @override
  String get quizFinish => 'Bitir';

  @override
  String get quizNextQuestion => 'Sonraki Soru →';

  @override
  String get quizNotEnough => 'Test için yeterli kart yok';

  @override
  String quizNotEnoughAll(int min) {
    return 'Farklı çevirilere sahip en az $min kart ekleyin; test kendiliğinden oluşacak.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck destesinin test edilebilmesi için farklı çevirilere sahip en az $min karta ihtiyacı var.';
  }

  @override
  String get quizBack => 'Geri';

  @override
  String get quizPerfect => 'Kusursuz!';

  @override
  String get quizGreat => 'Harika iş!';

  @override
  String get quizNice => 'Güzel ilerleme';

  @override
  String get quizKeepPractising => 'Çalışmaya devam';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return '$total sorudan $score tanesini doğru yanıtladınız';
  }

  @override
  String get quizScore => 'puan';

  @override
  String get quizDone => 'Tamam';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get statsSubtitle => 'Öğrenme yolculuğunuz rakamlarla';

  @override
  String get statsStreak => 'Seri';

  @override
  String get statsReviews => 'Tekrar';

  @override
  String get statsRecall => 'Hatırlama';

  @override
  String statsTodayDelta(int count) {
    return 'bugün +$count';
  }

  @override
  String get statsNoData => 'veri yok';

  @override
  String get statsHeatmap => 'Öğrenme Haritası';

  @override
  String statsStreakSummary(int days, int total) {
    return '$days günlük seri · $total tekrar kaydedildi';
  }

  @override
  String statsReviewsLogged(int total) {
    return '$total tekrar kaydedildi';
  }

  @override
  String get statsLess => 'Az';

  @override
  String get statsMore => 'Çok';

  @override
  String get statsNoActivity => 'Henüz etkinlik yok';

  @override
  String get statsLibraryBreakdown => 'Kütüphane Dağılımı';

  @override
  String get statsAchievements => 'Başarımlar';

  @override
  String statsEarned(int earned, int total) {
    return '$total başarımdan $earned tanesi';
  }

  @override
  String get statsAddCards => 'İlerlemenizi görmek için birkaç kart ekleyin';

  @override
  String get statsDaily => 'Günlük';

  @override
  String get statsWeekly => 'Haftalık';

  @override
  String get statsMonthly => 'Aylık';

  @override
  String get statsChartDaily => 'Tekrarlar, son 7 gün';

  @override
  String get statsChartWeekly => 'Tekrarlar, son 4 hafta';

  @override
  String get statsChartMonthly => 'Tekrarlar, son 6 ay';

  @override
  String statsChartTotal(int count) {
    return 'toplam $count';
  }

  @override
  String get profileStudyPreferences => 'Çalışma Tercihleri';

  @override
  String get profileNativeLanguage => 'Ana Dil';

  @override
  String get profileTargetLanguage => 'Hedef Dil';

  @override
  String get profileLearningPurpose => 'Öğrenme Amacı';

  @override
  String get profileStudyCategories => 'Çalışma Konuları';

  @override
  String get profileDailyGoal => 'Günlük Hedef';

  @override
  String get profileAppPreferences => 'Uygulama Tercihleri';

  @override
  String get profileDarkMode => 'Koyu Tema';

  @override
  String get profileAppLanguage => 'Uygulama Dili';

  @override
  String get profileSoundEffects => 'Ses Efektleri';

  @override
  String get profileDailyReminder => 'Günlük Hatırlatma';

  @override
  String get profileThemeColor => 'Tema Rengi';

  @override
  String get profileTextSize => 'Yazı Boyutu';

  @override
  String get profileDifficultyMode => 'Zorluk Modu';

  @override
  String get profileAccount => 'Hesap';

  @override
  String get profileEditProfile => 'Profili Düzenle';

  @override
  String get profilePrivacySecurity => 'Gizlilik ve Güvenlik';

  @override
  String get profileUpgradePremium => 'Premium\'a Geç';

  @override
  String get profileHelpSupport => 'Yardım ve Destek';

  @override
  String get profileLogOut => 'Çıkış Yap';

  @override
  String get profileLogOutConfirm => 'Çıkış yapılsın mı?';

  @override
  String get profileLogOutBody =>
      'Öğrenmeye devam etmek için tekrar giriş yapmanız gerekecek.';

  @override
  String get profileNoneYet => 'Henüz yok';

  @override
  String profileSelectedCount(int count) {
    return '$count seçili';
  }

  @override
  String profileTopicsCount(int count) {
    return '$count konu';
  }

  @override
  String profileMinutes(int min) {
    return '$min dk';
  }

  @override
  String get profileNative => 'Ana dil';

  @override
  String get profileEdit => 'Düzenle';

  @override
  String get profileFullName => 'Ad Soyad';

  @override
  String get profileEmailAddress => 'E-posta Adresi';

  @override
  String get profileNameRequired => 'Ad zorunlu';

  @override
  String get profileEmailRequired => 'E-posta zorunlu';

  @override
  String get profileClose => 'Kapat';

  @override
  String get profileWhyLearning =>
      'Neden öğreniyorsunuz? Uyanların hepsini seçin.';

  @override
  String get profileDecreaseGoal => 'Günlük hedefi azalt';

  @override
  String get profileIncreaseGoal => 'Günlük hedefi artır';

  @override
  String get profileYouSpeakThis => 'bu dili konuşuyorsunuz';

  @override
  String get profileLearningThis => 'bu dili öğreniyorsunuz';

  @override
  String profileLevelBadge(int level) {
    return '⭐ Seviye $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ $days günlük seri';
  }

  @override
  String get profileServerUnreachable =>
      'Sunucuya ulaşılamadı. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get profileSaveNameFailed =>
      'Adınız kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get profileSaveLanguageFailed =>
      'Diliniz kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get profileSaveGoalFailed =>
      'Günlük hedefiniz kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get profileSaveCategoriesFailed =>
      'Konularınız kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get profileSavePurposesFailed =>
      'Öğrenme amaçlarınız kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get profileLoadCategoriesFailed =>
      'Konular yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get profileLoadPurposesFailed =>
      'Öğrenme amaçları yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String wizardStep(int current, int total, String label) {
    return 'ADIM $current / $total — $label';
  }

  @override
  String get wizardNativeLanguage => 'ANA DİL';

  @override
  String get wizardTargetLanguage => 'HEDEF DİL';

  @override
  String get wizardTargetLevel => 'HEDEF DİL SEVİYESİ';

  @override
  String get wizardLearningPurpose => 'ÖĞRENME AMACI';

  @override
  String get wizardTopics => 'KONULAR VE KATEGORİLER';

  @override
  String get wizardAge => 'YAŞINIZ';

  @override
  String get wizardDailyGoal => 'GÜNLÜK HEDEF';

  @override
  String get wizardNativeQuestion => 'Ana diliniz nedir?';

  @override
  String get wizardTargetQuestion => 'Hangi dili öğrenmek istiyorsunuz?';

  @override
  String wizardLevelQuestion(String language) {
    return '$language seviyeniz nedir?';
  }

  @override
  String get wizardLevelHint =>
      'Size uygun geleni seçin — istediğiniz zaman değiştirebilirsiniz.';

  @override
  String get wizardGoalQuestion => 'Günde ne kadar vakit ayırabilirsiniz?';

  @override
  String wizardSelectedHint(int count) {
    return '$count seçili · Bunu sonra değiştirebilirsiniz';
  }

  @override
  String get wizardNativePrefix => 'Ana dil: ';

  @override
  String get wizardStart => 'Öğrenmeye Başlayalım 🚀';

  @override
  String get wizardLoadFailed => 'Kurulum seçenekleriniz yüklenemedi';

  @override
  String get wizardSaveFailed =>
      'Konularınız ya da öğrenme amacınız kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get levelJustStarting => 'Yeni Başlıyorum';

  @override
  String get levelJustStartingDesc => 'Temelleri öğreniyorum';

  @override
  String get levelBeginner => 'Başlangıç';

  @override
  String get levelBeginnerDesc => 'Bazı kelime ve kalıpları biliyorum';

  @override
  String get levelIntermediate => 'Orta';

  @override
  String get levelIntermediateDesc => 'Basit sohbetler edebiliyorum';

  @override
  String get levelAdvanced => 'İleri';

  @override
  String get levelAdvancedDesc => 'Çoğu durumda rahatım';

  @override
  String get levelFluent => 'Akıcı';

  @override
  String get levelFluentDesc => 'Ana diline yakın';

  @override
  String get goalCasual => 'Rahat';

  @override
  String get goalRegular => 'Düzenli';

  @override
  String get goalIntense => 'Yoğun';

  @override
  String goalWordsPerDay(int count) {
    return 'günde ~$count kelime';
  }

  @override
  String get helpSearchHint => 'Yardım makalelerinde ara...';

  @override
  String get helpFrequentlyAsked => 'SIKÇA SORULANLAR';

  @override
  String helpNoMatch(String query) {
    return '\"$query\" ile eşleşen makale yok';
  }

  @override
  String get helpStillStuck => 'HÂLÂ TAKILDINIZ MI?';

  @override
  String get helpEmailSupport => 'E-posta desteği';

  @override
  String get helpCommunityForum => 'Topluluk forumu';

  @override
  String get helpReportProblem => 'Sorun bildir';

  @override
  String get helpTheCommunityForum => 'Topluluk forumu';

  @override
  String get helpProblemReporting => 'Sorun bildirimi';

  @override
  String helpComingSoon(String what) {
    return '$what bu sürümde henüz kullanılamıyor.';
  }

  @override
  String get faqSpacedQ => 'Aralıklı tekrar nasıl çalışır?';

  @override
  String get faqSpacedA =>
      'Kartı çevirdikten sonra ne kadar bildiğinizi puanlarsınız. Zor bulduğunuz kartlar daha erken geri gelir; Kolay dediğiniz kartlar ileriye atılır. Böylece vaktinizi gerçekten zorlandığınız kelimelere ayırırsınız.';

  @override
  String get faqRatingsQ => 'Tekrar, Zor, Orta ve Kolay ne demek?';

  @override
  String get faqRatingsA =>
      'Kartın ne kadar sonra geri geleceğini belirler. Tekrar aynı oturumda geri getirir, Zor yaklaşık bir gün, Orta birkaç gün, Kolay ise yaklaşık bir hafta sonra.';

  @override
  String get faqReviewDueQ => 'Karttaki \"Tekrar Zamanı\" ne anlama geliyor?';

  @override
  String get faqReviewDueA =>
      'O kartın planlanan tekrar tarihi geçmiş demektir. Tekrar zamanı gelen kartlar bir sonraki çalışmanızın başına alınır.';

  @override
  String get faqCreateDeckQ => 'Nasıl deste oluştururum?';

  @override
  String get faqCreateDeckA =>
      'Desteler sekmesini açıp sağ üstteki \"Yeni Deste\"ye dokunun. Bir başlık verin, ardından destedeki \"Kart Ekle\" ile doldurmaya başlayın.';

  @override
  String get faqPictureQ => 'Karta resim ekleyebilir miyim?';

  @override
  String get faqPictureA =>
      'Evet. Kart eklerken ya da düzenlerken Görsel Bağlantısı alanına bir resim adresi yapıştırın; cevap tarafında görünecektir.';

  @override
  String get faqGoalQ => 'Günlük hedefim nasıl hesaplanıyor?';

  @override
  String get faqGoalA =>
      'Ana ekrandaki halka, bugün çalıştığınız dakikaları Profil → Çalışma Tercihleri\'nde belirlediğiniz günlük hedefle karşılaştırır.';

  @override
  String get faqStreakQ => 'Serim neden sıfırlandı?';

  @override
  String get faqStreakA =>
      'Seri, en az bir tekrar tamamladığınız ardışık günleri sayar. Bir günü tamamen kaçırmak seriyi bitirir.';

  @override
  String get privacyIntro =>
      'LanGigaCards\'ın sizinle ilgili neleri sakladığını ve öğrenme verinizin nasıl kullanıldığını yönetin.';

  @override
  String get privacySectionPrivacy => 'Gizlilik';

  @override
  String get privacyUsageAnalytics => 'Kullanım analizi';

  @override
  String get privacyPersonalisedReview => 'Kişiselleştirilmiş tekrar sırası';

  @override
  String get privacyPublicProfile => 'Herkese açık profil';

  @override
  String get privacyAnalyticsOn =>
      'Anonim kullanım verisi tekrar algoritmasını geliştirmeye yardım eder.';

  @override
  String get privacyAnalyticsOff =>
      'Analiz kapalı. Uygulamayı nasıl kullandığınıza dair hiçbir şey toplanmıyor.';

  @override
  String get privacySectionSecurity => 'Güvenlik';

  @override
  String get privacyBiometric => 'Biyometrik kilit iste';

  @override
  String get privacyChangePassword => 'Şifre değiştir';

  @override
  String get privacyActiveSessions => 'Etkin oturumlar';

  @override
  String get privacySectionYourData => 'Verileriniz';

  @override
  String get privacyExportDecks => 'Destelerimi dışa aktar';

  @override
  String get privacyDeleteAccount => 'Hesabı sil';

  @override
  String get privacyDeleteConfirm => 'Hesap silinsin mi?';

  @override
  String get privacyDeleteBody =>
      'Bu işlem destelerinizi, kartlarınızı ve tekrar geçmişinizi kalıcı olarak siler. Geri alınamaz.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what için giriş yapılmış bir hesap gerekiyor; bu sürümde henüz yok.';
  }

  @override
  String get privacyChangingPassword => 'Şifre değiştirme';

  @override
  String get privacySessionManagement => 'Oturum yönetimi';

  @override
  String get privacyExportingDecks => 'Desteleri dışa aktarma';

  @override
  String get privacyAccountDeletion => 'Hesap silme';

  @override
  String get categoriesEditTitle => 'Konuları Düzenle';

  @override
  String get categoriesSearchHint => 'Konularda ara...';

  @override
  String get languagesSearchHint => 'Dillerde ara...';

  @override
  String get languagesPopular => 'POPÜLER';

  @override
  String get reminderPermissionNeeded =>
      'Hatırlatmalar için bildirim izni gerekiyor. Sistem ayarlarından açın.';

  @override
  String reminderSetFor(String time) {
    return 'Günlük hatırlatma $time için kuruldu';
  }

  @override
  String get reminderPickTime => 'Bana şu saatte hatırlat';

  @override
  String get wizardPurposeQuestion => 'Bu dili neden öğreniyorsunuz?';

  @override
  String get wizardSelectAllThatApply => 'Uyanların hepsini seçin';

  @override
  String get wizardAgeQuestion => 'Yaş aralığınız nedir?';

  @override
  String get wizardTopicsQuestion => 'Önce hangi konuları çalışmak istersiniz?';

  @override
  String get wizardAgeNote =>
      'Yaşınızı erişilebilirlik ayarlarını ve öğrenme deneyimini iyileştirmek için kullanıyoruz.';

  @override
  String get studyAllUpToDate =>
      'Öğrendiğiniz her kart güncel. Yeni kelimeler ekleyin ya da tekrar zamanı gelince dönün.';

  @override
  String studyDeckMastered(String deck) {
    return '$deck destesindeki her şeyi öğrendiniz. Devam etmek için yeni kelimeler ekleyin.';
  }

  @override
  String get ttsVoiceMissingUnknown =>
      'Bu dilin sesi cihazınızda henüz yüklü değil.';

  @override
  String ttsVoiceMissing(String language) {
    return '$language konuşma sesi cihazınızda henüz yüklü değil. Sistem metin okuma ayarlarından ekleyin.';
  }

  @override
  String get ttsUnavailable =>
      'Bu cihazda kullanılabilir bir metin okuma motoru yok.';

  @override
  String get ttsPlay => 'Telaffuzu dinle';

  @override
  String get ttsNothing => 'Okunacak bir şey yok';

  @override
  String ttsPlayOf(String text) {
    return '$text kelimesinin telaffuzunu dinle';
  }

  @override
  String get reminderNotificationTitle => 'Tekrar zamanı';

  @override
  String get reminderNotificationBody =>
      'Kartlarınız bekliyor — birkaç dakika seriyi ayakta tutar.';

  @override
  String get splashTagline => 'HER DİLİ ÖĞREN';

  @override
  String get profileLearningLabel => 'öğreniyor';
}
