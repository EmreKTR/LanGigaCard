// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appLanguageTitle => 'Elige el idioma de la app';

  @override
  String get appLanguageSubtitle =>
      'Elige el idioma en el que quieres usar LanGigaCards.';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonSignIn => 'Iniciar sesión';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get commonGetStarted => 'Empezar';

  @override
  String get commonTryAgain => 'Reintentar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRequiredField => 'Este campo es obligatorio';

  @override
  String get commonSomethingWrong => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get commonNetworkError =>
      'No se puede conectar con el servidor. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get onboardingSlide1Title => 'Aprende con tarjetas';

  @override
  String get onboardingSlide1Body =>
      'Domina el vocabulario con nuestro sistema de repetición espaciada. Repasa las tarjetas en el momento justo para recordar mejor.';

  @override
  String get onboardingSlide2Title => 'Sigue tu progreso';

  @override
  String get onboardingSlide2Body =>
      'Visualiza tu aprendizaje con estadísticas claras. Mira crecer tu vocabulario día a día con rachas y logros.';

  @override
  String get onboardingSlide3Title => 'Alcanza tus metas';

  @override
  String get onboardingSlide3Body =>
      'Fija metas diarias personalizadas y mantén la motivación. Nuestro algoritmo se adapta a tu ritmo para que aprender sea fácil.';

  @override
  String get onboardingHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar tu aprendizaje';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginRememberMe => 'Recordarme';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginOrContinueWith => 'o continúa con';

  @override
  String get loginNoAccount => '¿No tienes cuenta?';

  @override
  String get loginInvalidCredentials =>
      'Correo o contraseña incorrectos. Crea una cuenta si aún no tienes una.';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerBackToSignIn => 'Volver al inicio de sesión';

  @override
  String get registerSubtitle =>
      'Tus datos — los idiomas y preferencias vienen después.';

  @override
  String get registerFirstName => 'Nombre';

  @override
  String get registerLastName => 'Apellidos';

  @override
  String get registerEmail => 'Correo electrónico';

  @override
  String get registerPassword => 'Contraseña';

  @override
  String get registerPasswordHint => 'Mín. 8 caracteres';

  @override
  String get registerConfirmPassword => 'Confirmar contraseña';

  @override
  String get registerConfirmHint => 'Vuelve a escribir tu contraseña';

  @override
  String get registerInvalidEmail => 'Introduce un correo electrónico válido';

  @override
  String get registerPasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get registerPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get registerEmailTaken => 'Ya existe una cuenta con este correo.';

  @override
  String get verifyTitle => 'Verifica tu correo';

  @override
  String verifySubtitle(String email) {
    return 'Enviamos un código de 6 dígitos a $email. Introdúcelo abajo para confirmar tu cuenta.';
  }

  @override
  String get verifyNoCode => '¿No recibiste el código?';

  @override
  String get verifyResend => 'Reenviar código';

  @override
  String get verifySending => 'Enviando…';

  @override
  String get verifyAction => 'Verificar';

  @override
  String verifyEnterAllDigits(int count) {
    return 'Introduce los $count dígitos';
  }

  @override
  String get verifyIncorrect => 'Código incorrecto, inténtalo de nuevo';

  @override
  String get verifyTooManyAttempts =>
      'Demasiados intentos. Toca \"Reenviar código\" para obtener uno nuevo.';

  @override
  String get verifyResent => 'Se envió un nuevo código a tu correo';

  @override
  String get forgotTitle => 'Restablece tu contraseña';

  @override
  String get forgotSubtitle =>
      'Introduce el correo con el que te registraste y te enviaremos un enlace para elegir una nueva contraseña.';

  @override
  String get forgotEmailLabel => 'Correo electrónico';

  @override
  String get forgotInvalidEmail => 'Introduce un correo válido';

  @override
  String get forgotSend => 'Enviar enlace';

  @override
  String get forgotCheckInbox => 'Revisa tu bandeja de entrada';

  @override
  String forgotSentTo(String email) {
    return 'Si existe una cuenta para $email, el enlace de restablecimiento está en camino.';
  }

  @override
  String get forgotNoMailServer =>
      'Esta versión no tiene servidor de correo conectado, así que no se envía ningún correo.';

  @override
  String get forgotUseDifferent => 'Usar otro correo';

  @override
  String get navHome => 'Inicio';

  @override
  String get navDecks => 'Mazos';

  @override
  String get navQuiz => 'Test';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get homeGreetingMorning => 'Buenos días,';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes,';

  @override
  String get homeGreetingEvening => 'Buenas noches,';

  @override
  String get homeContinueLearning => 'CONTINUAR APRENDIENDO';

  @override
  String homeCardsDue(int count) {
    return '$count tarjetas pendientes';
  }

  @override
  String homeMinGoal(int minutes) {
    return 'meta de $minutes min';
  }

  @override
  String get homeFinishSetup =>
      'Termina de configurar tu perfil para recibir tu primer mazo.';

  @override
  String get homeWords => 'Palabras';

  @override
  String get homeAccuracy => 'Precisión';

  @override
  String get homeStreak => 'Racha';

  @override
  String get homeQuickActions => 'ACCIONES RÁPIDAS';

  @override
  String get homeAddWord => 'Añadir palabra';

  @override
  String get homeYourTopics => 'Tus temas';

  @override
  String get homeRecentlyLearned => 'Aprendido recientemente';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get shellProfileLoadFailed => 'No se pudo cargar tu perfil';

  @override
  String get shellCheckConnection =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get shellSyncDroppedOne =>
      'No se pudo guardar 1 cambio y se descartó.';

  @override
  String shellSyncDroppedMany(int count) {
    return 'No se pudieron guardar $count cambios y se descartaron.';
  }

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get decksTitle => 'Mis mazos';

  @override
  String get decksNewDeck => 'Nuevo mazo';

  @override
  String decksSummary(int decks, int due) {
    return '$decks mazos · $due tarjetas para hoy';
  }

  @override
  String decksDueForReview(int count) {
    return '$count tarjetas para repasar';
  }

  @override
  String get decksSortedByUrgency =>
      'Ordenadas por urgencia · Toca para empezar';

  @override
  String get decksSearchHint => 'Buscar mazos...';

  @override
  String decksNoMatch(String query) {
    return 'Ningún mazo coincide con \"$query\"';
  }

  @override
  String get decksNoneYet => 'Aún no hay mazos';

  @override
  String get decksTryDifferentSearch =>
      'Prueba otra búsqueda o crea un mazo con este nombre.';

  @override
  String get decksEmptyHelp =>
      'Los mazos agrupan las palabras que quieres aprender. Crea el primero para empezar.';

  @override
  String get decksCreateADeck => 'Crear un mazo';

  @override
  String get decksOptions => 'Opciones del mazo';

  @override
  String get decksQuizThis => 'Hacer test de este mazo';

  @override
  String get decksRename => 'Renombrar mazo';

  @override
  String get decksDelete => 'Eliminar mazo';

  @override
  String decksCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarjetas',
      one: '1 tarjeta',
    );
    return '$_temp0';
  }

  @override
  String get decksReviewDue => 'Toca repasar';

  @override
  String decksReviewCount(int count) {
    return '$count repasos';
  }

  @override
  String get decksMastery => 'Dominio';

  @override
  String decksStudyCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estudiar $count tarjetas',
      one: 'Estudiar 1 tarjeta',
    );
    return '$_temp0';
  }

  @override
  String get decksAllCaughtUp => 'Todo al día';

  @override
  String get decksBrowse => 'Explorar';

  @override
  String get decksRenameTitle => 'Renombrar mazo';

  @override
  String get decksCreateTitle => 'Crear nuevo mazo';

  @override
  String get decksTitleLabel => 'TÍTULO *';

  @override
  String get decksTitleHint => 'p. ej. Francés básico';

  @override
  String get decksDescriptionLabel => 'DESCRIPCIÓN (OPCIONAL)';

  @override
  String get decksDescriptionHint => 'Describe qué cubre este mazo...';

  @override
  String get decksSaveChanges => 'Guardar cambios';

  @override
  String get decksCreateDeck => 'Crear mazo';

  @override
  String get decksNoDescription => 'Sin descripción';

  @override
  String decksDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get decksDeleteEmpty => 'Este mazo está vacío y se eliminará.';

  @override
  String decksDeleteWithCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminarán el mazo y sus $count tarjetas.',
      one: 'Se eliminará el mazo y su tarjeta.',
    );
    return '$_temp0';
  }

  @override
  String decksDeleted(String name) {
    return '\"$name\" eliminado';
  }

  @override
  String get decksCreateFailed =>
      'No se pudo crear el mazo. Inténtalo de nuevo.';

  @override
  String get decksDeleteFailed =>
      'No se pudo eliminar el mazo. Inténtalo de nuevo.';

  @override
  String get decksSaveFailed =>
      'No se pudieron guardar los cambios. Inténtalo de nuevo.';

  @override
  String get detailNotFound => 'Este mazo ya no existe';

  @override
  String get detailBackToDecks => 'Volver a los mazos';

  @override
  String get detailProgress => 'PROGRESO';

  @override
  String get detailMastered => 'Dominadas';

  @override
  String get detailLearning => 'Aprendiendo';

  @override
  String get detailCards => 'Tarjetas';

  @override
  String get detailReviews => 'Repasos';

  @override
  String get detailBrowseAll => 'Ver todas';

  @override
  String detailMore(int count) {
    return '+ $count más';
  }

  @override
  String get detailBack => 'Atrás';

  @override
  String get detailAddCardTooltip => 'Añadir una tarjeta a este mazo';

  @override
  String detailBreakdown(String label, int count, int total) {
    return '$label: $count de $total tarjetas';
  }

  @override
  String get detailEmpty => 'Este mazo está vacío';

  @override
  String get detailEmptyHelp =>
      'Añade unas palabras y podrás empezar a estudiar enseguida.';

  @override
  String get detailAddCard => 'Añadir tarjeta';

  @override
  String get cardEditTitle => 'Editar tarjeta';

  @override
  String get cardAddTitle => 'Nueva tarjeta';

  @override
  String get cardDeckLabel => 'MAZO *';

  @override
  String get cardFrontLabel => 'ANVERSO (PALABRA OBJETIVO) *';

  @override
  String get cardBackLabel => 'REVERSO (TRADUCCIÓN) *';

  @override
  String get cardFrontHint => 'p. ej. Bonjour';

  @override
  String get cardBackHint => 'p. ej. Hola';

  @override
  String get cardExampleLabel => 'FRASE DE EJEMPLO';

  @override
  String get cardExampleHint => 'Escribe una frase de ejemplo...';

  @override
  String get cardImageLabel => 'URL DE IMAGEN';

  @override
  String get cardImageHint => 'https://...';

  @override
  String get cardImageError =>
      'Introduce una URL de imagen completa que empiece por http:// o https://';

  @override
  String get cardAdd => 'Añadir tarjeta';

  @override
  String get cardAddFailed =>
      'No se pudo añadir la tarjeta. Inténtalo de nuevo.';

  @override
  String get libraryTitle => 'Biblioteca de tarjetas';

  @override
  String get librarySearchHint => 'Buscar en anverso o reverso...';

  @override
  String get libraryAllDecks => 'Todos los mazos';

  @override
  String libraryTotalItems(int count) {
    return 'Total: $count';
  }

  @override
  String get libraryShowingAll => 'Mostrando todo';

  @override
  String get libraryFilteredByDeck => 'Filtrado por mazo';

  @override
  String get libraryStudyThisDeck => 'Estudiar este mazo';

  @override
  String libraryNoMatch(String query) {
    return 'Ninguna tarjeta coincide con \"$query\"';
  }

  @override
  String get libraryNoneYet => 'Aún no hay tarjetas aquí';

  @override
  String get libraryCheckSpelling =>
      'Revisa la ortografía o quita el filtro de mazo para buscar en todo.';

  @override
  String get libraryAddFirst =>
      'Añade tu primera palabra y aparecerá en tu próxima sesión.';

  @override
  String get libraryUnknownDeck => 'Mazo desconocido';

  @override
  String libraryDeckReviews(String deck, int count) {
    return '$deck · $count repasos';
  }

  @override
  String get libraryEditCard => 'Editar tarjeta';

  @override
  String get libraryDeleteCard => 'Eliminar tarjeta';

  @override
  String get libraryDeleteConfirmTitle => '¿Eliminar tarjeta?';

  @override
  String libraryDeleteConfirmBody(String term) {
    return '\"$term\" se eliminará permanentemente de tu biblioteca.';
  }

  @override
  String libraryCardDeleted(String term) {
    return '\"$term\" eliminada';
  }

  @override
  String get libraryDeleteFailed =>
      'No se pudo eliminar la tarjeta. Inténtalo de nuevo.';

  @override
  String get studyAllDecks => 'Todos los mazos';

  @override
  String studyDailyReview(String deck) {
    return 'Repaso diario · $deck';
  }

  @override
  String studyWordHint(String term) {
    return 'Palabra: $term. Toca para ver la traducción.';
  }

  @override
  String studyAnswerHint(String translation) {
    return 'Respuesta: $translation. Toca para ver la palabra otra vez. Desliza para saltar o valora abajo.';
  }

  @override
  String get studyRateBelow => 'Valora abajo o desliza para saltar sin valorar';

  @override
  String get studyRecallHint => 'Recuerda la traducción y gira para comprobar';

  @override
  String get studyNothingDue => 'Nada pendiente ahora mismo';

  @override
  String get studyBackToDecks => 'Volver a los mazos';

  @override
  String get studyQueueFailed => 'No se pudo cargar tu lista de repaso';

  @override
  String get studyTapToSeeExample => '[ toca para ver el ejemplo ]';

  @override
  String get studyShowExample => 'Mostrar frase de ejemplo';

  @override
  String get studyTapToReveal => 'Toca para ver la traducción';

  @override
  String studyHearPronounced(String term) {
    return 'Escuchar la pronunciación de $term';
  }

  @override
  String get studyHearIt => 'Escuchar';

  @override
  String get studyTranslationLabel => 'TRADUCCIÓN';

  @override
  String get studyExampleLabel => 'EJEMPLO';

  @override
  String get studyImageFailed => 'No se pudo cargar la imagen';

  @override
  String get studyAllCaughtUp => '¡Todo al día!';

  @override
  String studyReviewedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Has repasado las $count tarjetas pendientes de hoy',
      one: 'Has repasado la tarjeta pendiente de hoy',
    );
    return '$_temp0';
  }

  @override
  String get studyConfidence => 'confianza';

  @override
  String get studyViewStats => 'Ver estadísticas';

  @override
  String get quizTimeUp =>
      '⏰ ¡Se acabó el tiempo! Esta es la respuesta correcta.';

  @override
  String quizProgress(int index, int total) {
    return 'P$index de $total';
  }

  @override
  String get quizFinish => 'Terminar';

  @override
  String get quizNextQuestion => 'Siguiente →';

  @override
  String get quizNotEnough => 'No hay tarjetas suficientes';

  @override
  String quizNotEnoughAll(int min) {
    return 'Añade al menos $min tarjetas con traducciones distintas y el test se creará solo.';
  }

  @override
  String quizNotEnoughDeck(String deck, int min) {
    return '$deck necesita al menos $min tarjetas con traducciones distintas para poder hacer el test.';
  }

  @override
  String get quizBack => 'Atrás';

  @override
  String get quizPerfect => '¡Puntuación perfecta!';

  @override
  String get quizGreat => '¡Buen trabajo!';

  @override
  String get quizNice => 'Buen progreso';

  @override
  String get quizKeepPractising => 'Sigue practicando';

  @override
  String quizAnsweredCorrectly(int score, int total) {
    return 'Acertaste $score de $total';
  }

  @override
  String get quizScore => 'puntuación';

  @override
  String get quizDone => 'Listo';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsSubtitle => 'Tu aprendizaje en números';

  @override
  String get statsStreak => 'Racha';

  @override
  String get statsReviews => 'Repasos';

  @override
  String get statsRecall => 'Retención';

  @override
  String statsTodayDelta(int count) {
    return '+$count hoy';
  }

  @override
  String get statsNoData => 'sin datos';

  @override
  String get statsHeatmap => 'Mapa de aprendizaje';

  @override
  String statsStreakSummary(int days, int total) {
    return 'racha de $days días · $total repasos registrados';
  }

  @override
  String statsReviewsLogged(int total) {
    return '$total repasos registrados';
  }

  @override
  String get statsLess => 'Menos';

  @override
  String get statsMore => 'Más';

  @override
  String get statsNoActivity => 'Aún no hay actividad';

  @override
  String get statsLibraryBreakdown => 'Desglose de la biblioteca';

  @override
  String get statsAchievements => 'Logros';

  @override
  String statsEarned(int earned, int total) {
    return '$earned / $total conseguidos';
  }

  @override
  String get statsAddCards => 'Añade tarjetas para ver tu progreso';

  @override
  String get statsDaily => 'Diario';

  @override
  String get statsWeekly => 'Semanal';

  @override
  String get statsMonthly => 'Mensual';

  @override
  String get statsChartDaily => 'Repasos, últimos 7 días';

  @override
  String get statsChartWeekly => 'Repasos, últimas 4 semanas';

  @override
  String get statsChartMonthly => 'Repasos, últimos 6 meses';

  @override
  String statsChartTotal(int count) {
    return '$count en total';
  }

  @override
  String get profileStudyPreferences => 'Preferencias de estudio';

  @override
  String get profileNativeLanguage => 'Idioma nativo';

  @override
  String get profileTargetLanguage => 'Idioma objetivo';

  @override
  String get profileLearningPurpose => 'Motivo de aprendizaje';

  @override
  String get profileStudyCategories => 'Temas de estudio';

  @override
  String get profileDailyGoal => 'Meta diaria';

  @override
  String get profileAppPreferences => 'Preferencias de la app';

  @override
  String get profileDarkMode => 'Modo oscuro';

  @override
  String get profileSoundEffects => 'Efectos de sonido';

  @override
  String get profileDailyReminder => 'Recordatorio diario';

  @override
  String get profileThemeColor => 'Color del tema';

  @override
  String get profileTextSize => 'Tamaño del texto';

  @override
  String get profileDifficultyMode => 'Modo de dificultad';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profilePrivacySecurity => 'Privacidad y seguridad';

  @override
  String get profileUpgradePremium => 'Pasar a Premium';

  @override
  String get profileHelpSupport => 'Ayuda y soporte';

  @override
  String get profileLogOut => 'Cerrar sesión';

  @override
  String get profileLogOutConfirm => '¿Cerrar sesión?';

  @override
  String get profileLogOutBody =>
      'Tendrás que iniciar sesión de nuevo para seguir aprendiendo.';

  @override
  String get profileNoneYet => 'Ninguno aún';

  @override
  String profileSelectedCount(int count) {
    return '$count seleccionados';
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
  String get profileFullName => 'Nombre completo';

  @override
  String get profileEmailAddress => 'Correo electrónico';

  @override
  String get profileNameRequired => 'El nombre es obligatorio';

  @override
  String get profileEmailRequired => 'El correo es obligatorio';

  @override
  String get profileClose => 'Cerrar';

  @override
  String get profileWhyLearning =>
      '¿Por qué aprendes? Elige todas las que apliquen.';

  @override
  String get profileDecreaseGoal => 'Reducir meta diaria';

  @override
  String get profileIncreaseGoal => 'Aumentar meta diaria';

  @override
  String get profileYouSpeakThis => 'hablas este idioma';

  @override
  String get profileLearningThis => 'estás aprendiendo este';

  @override
  String profileLevelBadge(int level) {
    return '⭐ Nivel $level';
  }

  @override
  String profileStreakBadge(int days) {
    return '⚡ racha de $days días';
  }

  @override
  String get profileServerUnreachable =>
      'No se pudo conectar con el servidor. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get profileSaveNameFailed =>
      'No se pudo guardar tu nombre. Inténtalo de nuevo.';

  @override
  String get profileSaveLanguageFailed =>
      'No se pudo guardar tu idioma. Inténtalo de nuevo.';

  @override
  String get profileSaveGoalFailed =>
      'No se pudo guardar tu meta diaria. Inténtalo de nuevo.';

  @override
  String get profileSaveCategoriesFailed =>
      'No se pudieron guardar tus temas. Inténtalo de nuevo.';

  @override
  String get profileSavePurposesFailed =>
      'No se pudieron guardar tus motivos. Inténtalo de nuevo.';

  @override
  String get profileLoadCategoriesFailed =>
      'No se pudieron cargar los temas. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get profileLoadPurposesFailed =>
      'No se pudieron cargar los motivos. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String wizardStep(int current, int total, String label) {
    return 'PASO $current DE $total — $label';
  }

  @override
  String get wizardNativeLanguage => 'IDIOMA NATIVO';

  @override
  String get wizardTargetLanguage => 'IDIOMA OBJETIVO';

  @override
  String get wizardTargetLevel => 'NIVEL DEL IDIOMA OBJETIVO';

  @override
  String get wizardLearningPurpose => 'MOTIVO DE APRENDIZAJE';

  @override
  String get wizardTopics => 'TEMAS Y CATEGORÍAS';

  @override
  String get wizardAge => 'TU EDAD';

  @override
  String get wizardDailyGoal => 'META DIARIA';

  @override
  String get wizardNativeQuestion => '¿Cuál es tu idioma nativo?';

  @override
  String get wizardTargetQuestion => '¿Qué idioma quieres aprender?';

  @override
  String wizardLevelQuestion(String language) {
    return '¿Cuál es tu nivel actual de $language?';
  }

  @override
  String get wizardLevelHint =>
      'Elige lo que te parezca — puedes ajustarlo cuando quieras.';

  @override
  String get wizardGoalQuestion => '¿Cuánto tiempo puedes dedicar al día?';

  @override
  String wizardSelectedHint(int count) {
    return '$count seleccionados · Puedes cambiarlo después';
  }

  @override
  String get wizardNativePrefix => 'Nativo: ';

  @override
  String get wizardStart => 'Empecemos a aprender 🚀';

  @override
  String get wizardLoadFailed =>
      'No se pudieron cargar tus opciones de configuración';

  @override
  String get wizardSaveFailed =>
      'No se pudieron guardar tus temas o tu motivo. Inténtalo de nuevo.';

  @override
  String get levelJustStarting => 'Empezando';

  @override
  String get levelJustStartingDesc => 'Aprendiendo lo básico';

  @override
  String get levelBeginner => 'Principiante';

  @override
  String get levelBeginnerDesc => 'Sé algunas palabras y frases';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelIntermediateDesc => 'Puedo mantener conversaciones sencillas';

  @override
  String get levelAdvanced => 'Avanzado';

  @override
  String get levelAdvancedDesc => 'Me manejo en casi todas las situaciones';

  @override
  String get levelFluent => 'Fluido';

  @override
  String get levelFluentDesc => 'Casi como un nativo';

  @override
  String get goalCasual => 'Relajado';

  @override
  String get goalRegular => 'Regular';

  @override
  String get goalIntense => 'Intenso';

  @override
  String goalWordsPerDay(int count) {
    return '~$count palabras/día';
  }

  @override
  String get helpSearchHint => 'Buscar artículos de ayuda...';

  @override
  String get helpFrequentlyAsked => 'PREGUNTAS FRECUENTES';

  @override
  String helpNoMatch(String query) {
    return 'Ningún artículo coincide con \"$query\"';
  }

  @override
  String get helpStillStuck => '¿SIGUES ATASCADO?';

  @override
  String get helpEmailSupport => 'Soporte por correo';

  @override
  String get helpCommunityForum => 'Foro de la comunidad';

  @override
  String get helpReportProblem => 'Informar de un problema';

  @override
  String get helpTheCommunityForum => 'El foro de la comunidad';

  @override
  String get helpProblemReporting => 'El informe de problemas';

  @override
  String helpComingSoon(String what) {
    return '$what todavía no está disponible en esta versión.';
  }

  @override
  String get faqSpacedQ => '¿Cómo funciona la repetición espaciada?';

  @override
  String get faqSpacedA =>
      'Al girar una tarjeta valoras cuánto la sabías. Las que te resultan difíciles vuelven antes; las que marcas como Fácil se alejan en el tiempo, así dedicas tu tiempo a las palabras que de verdad te cuestan.';

  @override
  String get faqRatingsQ => '¿Qué significan Otra vez, Difícil, Medio y Fácil?';

  @override
  String get faqRatingsA =>
      'Definen cuándo vuelve la tarjeta. Otra vez la trae de nuevo en esta sesión, Difícil en un día, Medio en unos días y Fácil en una semana aproximadamente.';

  @override
  String get faqReviewDueQ => '¿Qué significa \"Toca repasar\" en una tarjeta?';

  @override
  String get faqReviewDueA =>
      'Esa tarjeta ha pasado su fecha de repaso. Las tarjetas pendientes se colocan al principio de tu próxima sesión.';

  @override
  String get faqCreateDeckQ => '¿Cómo creo un mazo?';

  @override
  String get faqCreateDeckA =>
      'Abre la pestaña Mazos y toca \"Nuevo mazo\" arriba a la derecha. Ponle un título y luego usa \"Añadir tarjeta\" desde el mazo para empezar a llenarlo.';

  @override
  String get faqPictureQ => '¿Puedo añadir una imagen a una tarjeta?';

  @override
  String get faqPictureA =>
      'Sí. Al añadir o editar una tarjeta, pega una URL de imagen en el campo URL de imagen y aparecerá en el lado de la respuesta.';

  @override
  String get faqGoalQ => '¿Cómo se calcula mi meta diaria?';

  @override
  String get faqGoalA =>
      'El anillo de la pantalla de inicio compara los minutos que has estudiado hoy con la meta diaria fijada en Perfil → Preferencias de estudio.';

  @override
  String get faqStreakQ => '¿Por qué se reinició mi racha?';

  @override
  String get faqStreakA =>
      'Una racha cuenta días consecutivos con al menos un repaso completado. Saltarte un día entero la termina.';

  @override
  String get privacyIntro =>
      'Controla qué guarda LanGigaCards sobre ti y cómo se usan tus datos de aprendizaje.';

  @override
  String get privacySectionPrivacy => 'Privacidad';

  @override
  String get privacyUsageAnalytics => 'Analíticas de uso';

  @override
  String get privacyPersonalisedReview => 'Orden de repaso personalizado';

  @override
  String get privacyPublicProfile => 'Perfil público';

  @override
  String get privacyAnalyticsOn =>
      'Los datos de uso anónimos ayudan a mejorar el algoritmo de repaso.';

  @override
  String get privacyAnalyticsOff =>
      'Las analíticas están desactivadas. No se recoge nada sobre cómo usas la app.';

  @override
  String get privacySectionSecurity => 'Seguridad';

  @override
  String get privacyBiometric => 'Exigir desbloqueo biométrico';

  @override
  String get privacyChangePassword => 'Cambiar contraseña';

  @override
  String get privacyActiveSessions => 'Sesiones activas';

  @override
  String get privacySectionYourData => 'Tus datos';

  @override
  String get privacyExportDecks => 'Exportar mis mazos';

  @override
  String get privacyDeleteAccount => 'Eliminar cuenta';

  @override
  String get privacyDeleteConfirm => '¿Eliminar cuenta?';

  @override
  String get privacyDeleteBody =>
      'Esto eliminaría permanentemente tus mazos, tarjetas e historial de repasos. No se puede deshacer.';

  @override
  String privacyNeedsAccount(String what) {
    return '$what necesita una cuenta con sesión iniciada, y esta versión aún no la tiene.';
  }

  @override
  String get privacyChangingPassword => 'Cambiar la contraseña';

  @override
  String get privacySessionManagement => 'La gestión de sesiones';

  @override
  String get privacyExportingDecks => 'Exportar tus mazos';

  @override
  String get privacyAccountDeletion => 'Eliminar la cuenta';

  @override
  String get categoriesEditTitle => 'Editar temas';

  @override
  String get categoriesSearchHint => 'Buscar temas...';

  @override
  String get languagesSearchHint => 'Buscar idiomas...';

  @override
  String get languagesPopular => 'POPULARES';

  @override
  String get reminderPermissionNeeded =>
      'Los recordatorios necesitan permiso de notificaciones. Actívalo en los ajustes del sistema.';

  @override
  String reminderSetFor(String time) {
    return 'Recordatorio diario fijado para las $time';
  }

  @override
  String get reminderPickTime => 'Recordarme a las';

  @override
  String get wizardPurposeQuestion => '¿Por qué estás aprendiendo este idioma?';

  @override
  String get wizardSelectAllThatApply => 'Elige todas las que apliquen';

  @override
  String get wizardAgeQuestion => '¿Cuál es tu rango de edad?';

  @override
  String get wizardTopicsQuestion => '¿Qué temas te gustaría estudiar primero?';

  @override
  String get wizardAgeNote =>
      'Usamos tu edad para optimizar los ajustes de accesibilidad y la experiencia de aprendizaje.';

  @override
  String get studyAllUpToDate =>
      'Todas tus tarjetas están al día. Añade palabras nuevas o vuelve cuando toque repasar.';

  @override
  String studyDeckMastered(String deck) {
    return 'Has dominado todo en $deck. Añade palabras nuevas para seguir.';
  }

  @override
  String get ttsVoiceMissingUnknown =>
      'La voz de este idioma aún no está instalada en tu dispositivo.';

  @override
  String ttsVoiceMissing(String language) {
    return 'La voz de $language aún no está instalada. Añádela en los ajustes de texto a voz del sistema.';
  }

  @override
  String get ttsUnavailable =>
      'Este dispositivo no tiene un motor de texto a voz disponible.';

  @override
  String get ttsPlay => 'Reproducir pronunciación';

  @override
  String get ttsNothing => 'Nada que pronunciar';

  @override
  String ttsPlayOf(String text) {
    return 'Reproducir la pronunciación de $text';
  }

  @override
  String get reminderNotificationTitle => 'Hora de repasar';

  @override
  String get reminderNotificationBody =>
      'Tus tarjetas te esperan: unos minutos mantienen viva la racha.';

  @override
  String get splashTagline => 'APRENDE CUALQUIER IDIOMA';

  @override
  String get profileLearningLabel => 'aprendiendo';
}
