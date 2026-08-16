// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appLanguageTitle => 'Escolha o idioma do app';

  @override
  String get appLanguageSubtitle =>
      'Escolha o idioma em que quer usar o LanGigaCards.';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonSignIn => 'Entrar';

  @override
  String get commonSkip => 'Pular';

  @override
  String get commonGetStarted => 'Começar';

  @override
  String get commonTryAgain => 'Tentar novamente';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRequiredField => 'Este campo é obrigatório';

  @override
  String get commonSomethingWrong => 'Algo deu errado. Tente novamente.';

  @override
  String get commonNetworkError =>
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  @override
  String get onboardingSlide1Title => 'Aprenda com flashcards';

  @override
  String get onboardingSlide1Body =>
      'Domine o vocabulário com nosso sistema de repetição espaçada. Revise os cartões no momento certo para lembrar por mais tempo.';

  @override
  String get onboardingSlide2Title => 'Acompanhe seu progresso';

  @override
  String get onboardingSlide2Body =>
      'Veja sua jornada em estatísticas claras. Acompanhe seu vocabulário crescer dia após dia, com sequências e conquistas.';

  @override
  String get onboardingSlide3Title => 'Alcance suas metas';

  @override
  String get onboardingSlide3Body =>
      'Defina metas diárias personalizadas e mantenha a motivação. Nosso algoritmo se adapta ao seu ritmo e torna o estudo leve.';

  @override
  String get onboardingHaveAccount => 'Já tem uma conta?';

  @override
  String get loginTitle => 'Bem-vindo de volta';

  @override
  String get loginSubtitle => 'Entre para continuar sua jornada de aprendizado';

  @override
  String get loginEmailLabel => 'Endereço de e-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginRememberMe => 'Lembrar de mim';

  @override
  String get loginForgotPassword => 'Esqueceu a senha?';

  @override
  String get loginOrContinueWith => 'ou continue com';

  @override
  String get loginNoAccount => 'Não tem uma conta?';

  @override
  String get loginInvalidCredentials =>
      'E-mail ou senha incorretos. Crie uma conta se ainda não tiver uma.';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get registerBackToSignIn => 'Voltar ao login';

  @override
  String get registerSubtitle =>
      'Seus dados — idiomas e preferências de estudo vêm a seguir.';

  @override
  String get registerFirstName => 'Nome';

  @override
  String get registerLastName => 'Sobrenome';

  @override
  String get registerEmail => 'Endereço de e-mail';

  @override
  String get registerPassword => 'Senha';

  @override
  String get registerPasswordHint => 'Mín. 8 caracteres';

  @override
  String get registerConfirmPassword => 'Confirmar senha';

  @override
  String get registerConfirmHint => 'Digite a senha novamente';

  @override
  String get registerInvalidEmail => 'Digite um endereço de e-mail válido';

  @override
  String get registerPasswordTooShort =>
      'A senha deve ter pelo menos 8 caracteres';

  @override
  String get registerPasswordsDontMatch => 'As senhas não coincidem';

  @override
  String get registerEmailTaken => 'Já existe uma conta com este e-mail.';

  @override
  String get verifyTitle => 'Verifique seu e-mail';

  @override
  String verifySubtitle(String email) {
    return 'Enviamos um código de 6 dígitos para $email. Digite-o abaixo para confirmar sua conta.';
  }

  @override
  String get verifyNoCode => 'Não recebeu o código?';

  @override
  String get verifyResend => 'Reenviar código';

  @override
  String get verifySending => 'Enviando…';

  @override
  String get verifyAction => 'Verificar';

  @override
  String verifyEnterAllDigits(int count) {
    return 'Digite todos os $count dígitos';
  }

  @override
  String get verifyIncorrect => 'Código incorreto, tente novamente';

  @override
  String get verifyTooManyAttempts =>
      'Tentativas demais. Toque em \"Reenviar código\" para receber um novo.';

  @override
  String get verifyResent => 'Um novo código foi enviado para seu e-mail';

  @override
  String get forgotTitle => 'Redefinir sua senha';

  @override
  String get forgotSubtitle =>
      'Digite o e-mail com que você se cadastrou e enviaremos um link para escolher uma nova senha.';

  @override
  String get forgotEmailLabel => 'Endereço de e-mail';

  @override
  String get forgotInvalidEmail => 'Digite um e-mail válido';

  @override
  String get forgotSend => 'Enviar link';

  @override
  String get forgotCheckInbox => 'Verifique sua caixa de entrada';

  @override
  String forgotSentTo(String email) {
    return 'Se existir uma conta para $email, o link de redefinição está a caminho.';
  }

  @override
  String get forgotNoMailServer =>
      'Esta versão não tem servidor de e-mail conectado, então nenhum e-mail é realmente enviado.';

  @override
  String get forgotUseDifferent => 'Usar outro e-mail';

  @override
  String get navHome => 'Início';

  @override
  String get navDecks => 'Baralhos';

  @override
  String get navQuiz => 'Quiz';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get homeGreetingMorning => 'Bom dia,';

  @override
  String get homeGreetingAfternoon => 'Boa tarde,';

  @override
  String get homeGreetingEvening => 'Boa noite,';

  @override
  String get homeContinueLearning => 'CONTINUAR APRENDENDO';

  @override
  String homeCardsDue(int count) {
    return '$count cartões pendentes';
  }

  @override
  String homeMinGoal(int minutes) {
    return 'meta de $minutes min';
  }

  @override
  String get homeFinishSetup =>
      'Conclua a configuração do seu perfil para receber seu primeiro baralho.';

  @override
  String get homeWords => 'Palavras';

  @override
  String get homeAccuracy => 'Precisão';

  @override
  String get homeStreak => 'Sequência';

  @override
  String get homeQuickActions => 'AÇÕES RÁPIDAS';

  @override
  String get homeAddWord => 'Adicionar palavra';

  @override
  String get homeYourTopics => 'Seus temas';

  @override
  String get homeRecentlyLearned => 'Aprendido recentemente';

  @override
  String get homeSeeAll => 'Ver tudo';

  @override
  String get shellProfileLoadFailed => 'Não foi possível carregar seu perfil';

  @override
  String get shellCheckConnection => 'Verifique sua conexão e tente novamente.';

  @override
  String get shellSyncDroppedOne =>
      '1 alteração não pôde ser salva e foi descartada.';

  @override
  String shellSyncDroppedMany(int count) {
    return '$count alterações não puderam ser salvas e foram descartadas.';
  }

  @override
  String get commonDelete => 'Excluir';

  @override
  String get decksTitle => 'Meus baralhos';

  @override
  String get decksNewDeck => 'Novo baralho';

  @override
  String decksSummary(int decks, int due) {
    return '$decks baralhos · $due cartões para hoje';
  }

  @override
  String decksDueForReview(int count) {
    return '$count cartões para revisar';
  }

  @override
  String get decksSortedByUrgency =>
      'Ordenados por urgência · Toque para começar';

  @override
  String get decksSearchHint => 'Buscar baralhos...';

  @override
  String decksNoMatch(String query) {
    return 'Nenhum baralho corresponde a \"$query\"';
  }

  @override
  String get decksNoneYet => 'Nenhum baralho ainda';

  @override
  String get decksTryDifferentSearch =>
      'Tente outra busca ou crie um baralho com esse nome.';

  @override
  String get decksEmptyHelp =>
      'Baralhos agrupam as palavras que você quer aprender. Crie o primeiro para começar.';

  @override
  String get decksCreateADeck => 'Criar um baralho';

  @override
  String get decksOptions => 'Opções do baralho';

  @override
  String get decksQuizThis => 'Fazer quiz deste baralho';

  @override
  String get decksRename => 'Renomear baralho';

  @override
  String get decksDelete => 'Excluir baralho';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões',
      one: '1 cartão',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => 'Revisar';

  @override
  String decksReviewCount(int count) {
    return '$count revisões';
  }

  @override
  String get decksMastery => 'Domínio';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estudar $count cartões',
      one: 'Estudar 1 cartão',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'Tudo em dia';

  @override
  String get decksBrowse => 'Explorar';

  @override
  String get decksRenameTitle => 'Renomear baralho';

  @override
  String get decksCreateTitle => 'Criar novo baralho';

  @override
  String get decksTitleLabel => 'TÍTULO *';

  @override
  String get decksTitleHint => 'ex. Francês básico';

  @override
  String get decksDescriptionLabel => 'DESCRIÇÃO (OPCIONAL)';

  @override
  String get decksDescriptionHint => 'Descreva o que este baralho cobre...';

  @override
  String get decksSaveChanges => 'Salvar alterações';

  @override
  String get decksCreateDeck => 'Criar baralho';

  @override
  String get decksNoDescription => 'Sem descrição ainda';

  @override
  String decksDeleteConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get decksDeleteEmpty => 'Este baralho está vazio e será removido.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'O baralho e seus $count cartões serão removidos.',
      one: 'O baralho e seu cartão serão removidos.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '\"$name\" excluído';
  }

  @override
  String get decksCreateFailed =>
      'Não foi possível criar o baralho. Tente novamente.';

  @override
  String get decksDeleteFailed =>
      'Não foi possível excluir o baralho. Tente novamente.';

  @override
  String get decksSaveFailed =>
      'Não foi possível salvar as alterações. Tente novamente.';

  @override
  String get detailNotFound => 'Este baralho não existe mais';

  @override
  String get detailBackToDecks => 'Voltar aos baralhos';

  @override
  String get detailProgress => 'PROGRESSO';

  @override
  String get detailMastered => 'Dominados';

  @override
  String get detailLearning => 'Aprendendo';

  @override
  String get detailCards => 'Cartões';

  @override
  String get detailReviews => 'Revisões';

  @override
  String get detailBrowseAll => 'Ver todos';

  @override
  String detailMore(int count) {
    return '+ $count a mais';
  }

  @override
  String get detailBack => 'Voltar';

  @override
  String get detailAddCardTooltip => 'Adicionar um cartão a este baralho';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label: $count de $total cartões';
  }

  @override
  String get detailEmpty => 'Este baralho está vazio';

  @override
  String get detailEmptyHelp =>
      'Adicione algumas palavras e já poderá começar a estudar.';

  @override
  String get detailAddCard => 'Adicionar cartão';

  @override
  String get cardEditTitle => 'Editar cartão';

  @override
  String get cardAddTitle => 'Novo cartão';

  @override
  String get cardDeckLabel => 'BARALHO *';

  @override
  String get cardFrontLabel => 'FRENTE (PALAVRA-ALVO) *';

  @override
  String get cardBackLabel => 'VERSO (TRADUÇÃO) *';

  @override
  String get cardFrontHint => 'ex. Bonjour';

  @override
  String get cardBackHint => 'ex. Olá';

  @override
  String get cardExampleLabel => 'FRASE DE EXEMPLO';

  @override
  String get cardExampleHint => 'Escreva uma frase de exemplo...';

  @override
  String get cardImageLabel => 'URL DA IMAGEM';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError =>
      'Digite uma URL de imagem completa começando com http:// ou https://';

  @override
  String get cardAdd => 'Adicionar cartão';

  @override
  String get cardAddFailed =>
      'Não foi possível adicionar o cartão. Tente novamente.';

  @override
  String get libraryTitle => 'Biblioteca de cartões';

  @override
  String get librarySearchHint => 'Buscar frente ou verso...';

  @override
  String get libraryAllDecks => 'Todos os baralhos';

  @override
  String libraryTotalItems(int count) {
    return 'Total: $count';
  }

  @override
  String get libraryShowingAll => 'Mostrando tudo';

  @override
  String get libraryFilteredByDeck => 'Filtrado por baralho';

  @override
  String get libraryStudyThisDeck => 'Estudar este baralho';

  @override
  String libraryNoMatch(String query) {
    return 'Nenhum cartão corresponde a \"$query\"';
  }

  @override
  String get libraryNoneYet => 'Ainda não há cartões aqui';

  @override
  String get libraryCheckSpelling =>
      'Verifique a grafia ou remova o filtro de baralho para buscar em tudo.';

  @override
  String get libraryAddFirst =>
      'Adicione sua primeira palavra e ela aparecerá na próxima sessão.';

  @override
  String get libraryUnknownDeck => 'Baralho desconhecido';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · $count revisões';
  }

  @override
  String get libraryEditCard => 'Editar cartão';

  @override
  String get libraryDeleteCard => 'Excluir cartão';

  @override
  String get libraryDeleteConfirmTitle => 'Excluir cartão?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '\"$term\" será removido permanentemente da sua biblioteca.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '\"$term\" excluído';
  }

  @override
  String get libraryDeleteFailed =>
      'Não foi possível excluir o cartão. Tente novamente.';

  @override
  String get studyAllDecks => 'Todos os baralhos';

  @override
  String studyDailyReview(String deck) {
    return 'Revisão diária · $deck';
  }

  @override
  String studyWordHint(String term) {
    return 'Palavra: $term. Toque para ver a tradução.';
  }

  @override
  String studyAnswerHint(String translation) {
    return 'Resposta: $translation. Toque para ver a palavra de novo. Deslize para pular ou avalie abaixo.';
  }

  @override
  String get studyRateBelow =>
      'Avalie abaixo ou deslize para pular sem avaliar';

  @override
  String get studyRecallHint => 'Lembre a tradução e vire para conferir';

  @override
  String get studyNothingDue => 'Nada pendente agora';

  @override
  String get studyBackToDecks => 'Voltar aos baralhos';

  @override
  String get studyQueueFailed =>
      'Não foi possível carregar sua fila de revisão';

  @override
  String get studyTapToSeeExample => '[ toque para ver o exemplo ]';

  @override
  String get studyShowExample => 'Mostrar frase de exemplo';

  @override
  String get studyTapToReveal => 'Toque para ver a tradução';

  @override
  String studyHearPronounced(String term) {
    return 'Ouvir a pronúncia de $term';
  }

  @override
  String get studyHearIt => 'Ouvir';

  @override
  String get studyTranslationLabel => 'TRADUÇÃO';

  @override
  String get studyExampleLabel => 'EXEMPLO';

  @override
  String get studyImageFailed => 'A imagem não carregou';

  @override
  String get studyAllCaughtUp => 'Tudo em dia!';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você revisou todos os $count cartões pendentes de hoje',
      one: 'Você revisou o cartão pendente de hoje',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => 'confiança';

  @override
  String get studyViewStats => 'Ver estatísticas';

  @override
  String get quizTimeUp => '⏰ Tempo esgotado! Esta é a resposta correta.';

  @override
  String quizProgress(int index, int total) {
    return 'Q$index de $total';
  }

  @override
  String get quizFinish => 'Concluir';

  @override
  String get quizNextQuestion => 'Próxima pergunta →';

  @override
  String get quizNotEnough => 'Cartões insuficientes para o quiz';

  @override
  String quizNotEnoughAll(int min) {
    return 'Adicione pelo menos $min cartões com traduções diferentes e o quiz se montará sozinho.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck precisa de pelo menos $min cartões com traduções diferentes para virar um quiz.';
  }

  @override
  String get quizBack => 'Voltar';

  @override
  String get quizPerfect => 'Pontuação perfeita!';

  @override
  String get quizGreat => 'Ótimo trabalho!';

  @override
  String get quizNice => 'Bom progresso';

  @override
  String get quizKeepPractising => 'Continue praticando';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return 'Você acertou $score de $total';
  }

  @override
  String get quizScore => 'pontuação';

  @override
  String get quizDone => 'Concluído';

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statsSubtitle => 'Sua jornada de aprendizado em números';

  @override
  String get statsStreak => 'Sequência';

  @override
  String get statsReviews => 'Revisões';

  @override
  String get statsRecall => 'Retenção';

  @override
  String statsTodayDelta(int count) {
    return '+$count hoje';
  }

  @override
  String get statsNoData => 'sem dados';

  @override
  String get statsHeatmap => 'Mapa de aprendizado';

  @override
  String statsStreakSummary(int days, int total) {
    return 'sequência de $days dias · $total revisões registradas';
  }

  @override
  String statsReviewsLogged(int total) {
    return '$total revisões registradas';
  }

  @override
  String get statsLess => 'Menos';

  @override
  String get statsMore => 'Mais';

  @override
  String get statsNoActivity => 'Nenhuma atividade ainda';

  @override
  String get statsLibraryBreakdown => 'Composição da biblioteca';

  @override
  String get statsAchievements => 'Conquistas';

  @override
  String statsEarned(int earned, int total) {
    return '$earned / $total conquistadas';
  }

  @override
  String get statsAddCards => 'Adicione alguns cartões para ver seu progresso';

  @override
  String get statsDaily => 'Diário';

  @override
  String get statsWeekly => 'Semanal';

  @override
  String get statsMonthly => 'Mensal';

  @override
  String get statsChartDaily => 'Revisões, últimos 7 dias';

  @override
  String get statsChartWeekly => 'Revisões, últimas 4 semanas';

  @override
  String get statsChartMonthly => 'Revisões, últimos 6 meses';

  @override
  String statsChartTotal(int count) {
    return '$count no total';
  }

  @override
  String get profileStudyPreferences => 'Preferências de estudo';

  @override
  String get profileNativeLanguage => 'Idioma nativo';

  @override
  String get profileTargetLanguage => 'Idioma-alvo';

  @override
  String get profileLearningPurpose => 'Objetivo de aprendizado';

  @override
  String get profileStudyCategories => 'Temas de estudo';

  @override
  String get profileDailyGoal => 'Meta diária';

  @override
  String get profileAppPreferences => 'Preferências do app';

  @override
  String get profileDarkMode => 'Modo escuro';

  @override
  String get profileSoundEffects => 'Efeitos sonoros';

  @override
  String get profileDailyReminder => 'Lembrete diário';

  @override
  String get profileThemeColor => 'Cor do tema';

  @override
  String get profileTextSize => 'Tamanho do texto';

  @override
  String get profileDifficultyMode => 'Modo de dificuldade';

  @override
  String get profileAccount => 'Conta';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profilePrivacySecurity => 'Privacidade e segurança';

  @override
  String get profileUpgradePremium => 'Assinar Premium';

  @override
  String get profileHelpSupport => 'Ajuda e suporte';

  @override
  String get profileLogOut => 'Sair';

  @override
  String get profileLogOutConfirm => 'Sair da conta?';

  @override
  String get profileLogOutBody =>
      'Você precisará entrar novamente para continuar aprendendo.';

  @override
  String get profileNoneYet => 'Nenhum ainda';

  @override
  String profileSelectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String profileTopicsCount(int count) {
    return '$count temas';
  }

  @override
  String profileMinutes(int min) {
    return '$min min';
  }

  @override
  String get profileNative => 'Nativo';

  @override
  String get profileEdit => 'Editar';

  @override
  String get profileFullName => 'Nome completo';

  @override
  String get profileEmailAddress => 'Endereço de e-mail';

  @override
  String get profileNameRequired => 'O nome é obrigatório';

  @override
  String get profileEmailRequired => 'O e-mail é obrigatório';

  @override
  String get profileClose => 'Fechar';

  @override
  String get profileWhyLearning =>
      'Por que você está aprendendo? Escolha quantos quiser.';

  @override
  String get profileDecreaseGoal => 'Diminuir meta diária';

  @override
  String get profileIncreaseGoal => 'Aumentar meta diária';

  @override
  String get profileYouSpeakThis => 'você fala este idioma';

  @override
  String get profileLearningThis => 'você está aprendendo este';

  @override
  String profileLevelBadge(int level) {
    return '⭐ Nível $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ sequência de $days dias';
  }

  @override
  String get profileServerUnreachable =>
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  @override
  String get profileSaveNameFailed =>
      'Não foi possível salvar seu nome. Tente novamente.';

  @override
  String get profileSaveLanguageFailed =>
      'Não foi possível salvar seu idioma. Tente novamente.';

  @override
  String get profileSaveGoalFailed =>
      'Não foi possível salvar sua meta diária. Tente novamente.';

  @override
  String get profileSaveCategoriesFailed =>
      'Não foi possível salvar seus temas. Tente novamente.';

  @override
  String get profileSavePurposesFailed =>
      'Não foi possível salvar seus objetivos. Tente novamente.';

  @override
  String get profileLoadCategoriesFailed =>
      'Não foi possível carregar os temas. Verifique sua conexão e tente novamente.';

  @override
  String get profileLoadPurposesFailed =>
      'Não foi possível carregar os objetivos. Verifique sua conexão e tente novamente.';

  @override
  String wizardStep(int current, int total, String label) {
    return 'ETAPA $current DE $total — $label';
  }

  @override
  String get wizardNativeLanguage => 'IDIOMA NATIVO';

  @override
  String get wizardTargetLanguage => 'IDIOMA-ALVO';

  @override
  String get wizardTargetLevel => 'NÍVEL NO IDIOMA-ALVO';

  @override
  String get wizardLearningPurpose => 'OBJETIVO DE APRENDIZADO';

  @override
  String get wizardTopics => 'TEMAS E CATEGORIAS';

  @override
  String get wizardAge => 'SUA IDADE';

  @override
  String get wizardDailyGoal => 'META DIÁRIA';

  @override
  String get wizardNativeQuestion => 'Qual é o seu idioma nativo?';

  @override
  String get wizardTargetQuestion => 'Qual idioma você quer aprender?';

  @override
  String wizardLevelQuestion(String language) {
    return 'Qual é o seu nível atual em $language?';
  }

  @override
  String get wizardLevelHint =>
      'Escolha o que fizer sentido — dá para ajustar depois.';

  @override
  String get wizardGoalQuestion => 'Quanto tempo você pode dedicar por dia?';

  @override
  String wizardSelectedHint(int count) {
    return '$count selecionados · Você pode mudar depois';
  }

  @override
  String get wizardNativePrefix => 'Nativo: ';

  @override
  String get wizardStart => 'Vamos começar 🚀';

  @override
  String get wizardLoadFailed =>
      'Não foi possível carregar suas opções de configuração';

  @override
  String get wizardSaveFailed =>
      'Não foi possível salvar seus temas ou objetivo. Tente novamente.';

  @override
  String get levelJustStarting => 'Começando agora';

  @override
  String get levelJustStartingDesc => 'Aprendendo o básico';

  @override
  String get levelBeginner => 'Iniciante';

  @override
  String get levelBeginnerDesc => 'Sei algumas palavras e frases';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelIntermediateDesc => 'Consigo ter conversas simples';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get levelAdvancedDesc => 'Confortável na maioria das situações';

  @override
  String get levelFluent => 'Fluente';

  @override
  String get levelFluentDesc => 'Quase como nativo';

  @override
  String get goalCasual => 'Tranquilo';

  @override
  String get goalRegular => 'Regular';

  @override
  String get goalIntense => 'Intenso';

  @override
  String goalWordsPerDay(int count) {
    return '~$count palavras/dia';
  }

  @override
  String get helpSearchHint => 'Buscar artigos de ajuda...';

  @override
  String get helpFrequentlyAsked => 'PERGUNTAS FREQUENTES';

  @override
  String helpNoMatch(String query) {
    return 'Nenhum artigo corresponde a \"$query\"';
  }

  @override
  String get helpStillStuck => 'AINDA COM DÚVIDA?';

  @override
  String get helpEmailSupport => 'Suporte por e-mail';

  @override
  String get helpCommunityForum => 'Fórum da comunidade';

  @override
  String get helpReportProblem => 'Relatar um problema';

  @override
  String get helpTheCommunityForum => 'O fórum da comunidade';

  @override
  String get helpProblemReporting => 'O relato de problemas';

  @override
  String helpComingSoon(String what) {
    return '$what ainda não está disponível nesta versão.';
  }

  @override
  String get faqSpacedQ => 'Como funciona a repetição espaçada?';

  @override
  String get faqSpacedA =>
      'Depois de virar um cartão, você avalia o quanto sabia. Cartões difíceis voltam mais cedo; os marcados como Fácil são adiados, para que você gaste tempo nas palavras que realmente custam.';

  @override
  String get faqRatingsQ => 'O que significam De novo, Difícil, Médio e Fácil?';

  @override
  String get faqRatingsA =>
      'Definem quando o cartão volta. De novo traz de volta nesta sessão, Difícil em cerca de um dia, Médio em alguns dias e Fácil em cerca de uma semana.';

  @override
  String get faqReviewDueQ => 'O que significa \"Revisar\" em um cartão?';

  @override
  String get faqReviewDueA =>
      'Esse cartão passou da data de revisão prevista. Cartões a revisar vão para o início da sua próxima sessão.';

  @override
  String get faqCreateDeckQ => 'Como crio um baralho?';

  @override
  String get faqCreateDeckA =>
      'Abra a aba Baralhos e toque em \"Novo baralho\" no canto superior direito. Dê um título e use \"Adicionar cartão\" no baralho para preenchê-lo.';

  @override
  String get faqPictureQ => 'Posso adicionar uma imagem a um cartão?';

  @override
  String get faqPictureA =>
      'Sim. Ao adicionar ou editar um cartão, cole uma URL de imagem no campo URL da imagem e ela aparecerá no lado da resposta.';

  @override
  String get faqGoalQ => 'Como minha meta diária é calculada?';

  @override
  String get faqGoalA =>
      'O anel na tela inicial compara os minutos estudados hoje com a meta diária definida em Perfil → Preferências de estudo.';

  @override
  String get faqStreakQ => 'Por que minha sequência zerou?';

  @override
  String get faqStreakA =>
      'Uma sequência conta dias consecutivos com pelo menos uma revisão concluída. Perder um dia inteiro encerra a sequência.';

  @override
  String get privacyIntro =>
      'Controle o que o LanGigaCards guarda sobre você e como seus dados de aprendizado são usados.';

  @override
  String get privacySectionPrivacy => 'Privacidade';

  @override
  String get privacyUsageAnalytics => 'Análises de uso';

  @override
  String get privacyPersonalisedReview => 'Ordem de revisão personalizada';

  @override
  String get privacyPublicProfile => 'Perfil público';

  @override
  String get privacyAnalyticsOn =>
      'Dados de uso anônimos ajudam a melhorar o algoritmo de revisão.';

  @override
  String get privacyAnalyticsOff =>
      'As análises estão desativadas. Nada sobre como você usa o app é coletado.';

  @override
  String get privacySectionSecurity => 'Segurança';

  @override
  String get privacyBiometric => 'Exigir desbloqueio biométrico';

  @override
  String get privacyChangePassword => 'Alterar senha';

  @override
  String get privacyActiveSessions => 'Sessões ativas';

  @override
  String get privacySectionYourData => 'Seus dados';

  @override
  String get privacyExportDecks => 'Exportar meus baralhos';

  @override
  String get privacyDeleteAccount => 'Excluir conta';

  @override
  String get privacyDeleteConfirm => 'Excluir conta?';

  @override
  String get privacyDeleteBody =>
      'Isso removeria permanentemente seus baralhos, cartões e histórico de revisões. Não há como desfazer.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what exige uma conta conectada, que esta versão ainda não tem.';
  }

  @override
  String get privacyChangingPassword => 'Alterar sua senha';

  @override
  String get privacySessionManagement => 'O gerenciamento de sessões';

  @override
  String get privacyExportingDecks => 'Exportar seus baralhos';

  @override
  String get privacyAccountDeletion => 'A exclusão da conta';
}
