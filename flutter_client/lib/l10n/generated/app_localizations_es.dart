// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'HomeSync';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Elegí el idioma de la app';

  @override
  String get settingsCurrencyTitle => 'Moneda';

  @override
  String get settingsCurrencySubtitle =>
      'Elegí cómo se muestran los importes de Finanzas';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonError => 'Algo salió mal';

  @override
  String get commonNoConnection => 'Sin conexión a internet';

  @override
  String get offlineDisconnectedMessage =>
      'Sin conexión · Los cambios se guardarán cuando vuelvas a estar online';

  @override
  String get offlineSyncingMessage => 'Sincronizando cambios...';

  @override
  String offlinePendingShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String offlinePendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios pendientes de sincronizar',
      one: '1 cambio pendiente de sincronizar',
    );
    return '$_temp0';
  }

  @override
  String get offlineSyncedMessage => 'Sincronizado';

  @override
  String offlineSyncButton(int count) {
    return 'Sincronizar ($count)';
  }

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonSend => 'Enviar';

  @override
  String get mainTabHome => 'Inicio';

  @override
  String get mainTabTasks => 'Tareas';

  @override
  String get mainTabExpenses => 'Finanzas';

  @override
  String get mainTabProgress => 'Progreso';

  @override
  String get mainTabShopping => 'Compras';

  @override
  String get mainTabShoppingChild => 'Tienda';

  @override
  String householdSocialTabLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Pareja',
        'family': 'Familia',
        'friends': 'Piso',
        'solo': 'Mi espacio',
        'other': 'Mi espacio',
      },
    );
    return '$_temp0';
  }

  @override
  String householdSocialHubTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Pareja',
        'family': 'Centro familiar',
        'friends': 'Convivencia',
        'solo': 'Mi espacio',
        'other': 'Mi espacio',
      },
    );
    return '$_temp0';
  }

  @override
  String householdSocialHubSubtitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple':
            'El repaso de la semana, la plata entre los dos y lo que se proponen.',
        'family':
            'Coordinación, miembros y acuerdos del hogar para toda la familia.',
        'friends': 'Organización, convivencia y reparto claro para el piso.',
        'solo': 'Todo tu progreso personal en un solo lugar.',
        'other': 'Todo tu progreso personal en un solo lugar.',
      },
    );
    return '$_temp0';
  }

  @override
  String householdDashboardGreeting(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Nuestro Hogar',
        'family': 'Hogar Familiar',
        'friends': 'Convivencia',
        'solo': 'Mi Progreso',
        'other': 'Mi Progreso',
      },
    );
    return '$_temp0';
  }

  @override
  String householdBalanceMessage(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'solo': 'Llevas gastado este mes',
        'other': 'Balance acumulado',
      },
    );
    return '$_temp0';
  }

  @override
  String householdEmptyTasksSubtitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'solo': 'Agrega tu primera tarea para organizar tu dia.',
        'other': 'Agreguen su primera tarea para organizar el hogar.',
      },
    );
    return '$_temp0';
  }

  @override
  String householdMemberLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Pareja',
        'family': 'Familia',
        'friends': 'Compañeros',
        'solo': 'Yo',
        'other': 'Yo',
      },
    );
    return '$_temp0';
  }

  @override
  String householdActionMemberLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'con tu pareja',
        'family': 'con la familia',
        'friends': 'con tus compañeros',
        'solo': 'conmigo',
        'other': 'conmigo',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsAppBarTitle => 'Configuración';

  @override
  String get settingsBackTooltip => 'Volver';

  @override
  String get settingsSectionProfileEyebrow => 'PERFIL';

  @override
  String get settingsSectionProfileTitle => 'Tu espacio';

  @override
  String get settingsSectionProfileSubtitle =>
      'Avatar, nombre y datos básicos de tu cuenta.';

  @override
  String get settingsSectionHouseholdEyebrow => 'HOGAR';

  @override
  String get settingsSectionHouseholdTitle => 'Casa compartida';

  @override
  String get settingsSectionHouseholdSubtitle =>
      'Miembros, invitaciones y reglas del hogar.';

  @override
  String get settingsSectionAppEyebrow => 'APP';

  @override
  String get settingsSectionAppTitle => 'Preferencias';

  @override
  String get settingsSectionAppSubtitle =>
      'Tema, notificaciones, ayuda y feedback.';

  @override
  String get settingsSectionAccountEyebrow => 'CUENTA';

  @override
  String get settingsSectionAccountTitle => 'Sesión y seguridad';

  @override
  String get settingsSectionAccountSubtitle =>
      'Salir de la cuenta o reiniciar tus datos si lo necesitas.';

  @override
  String get settingsSectionLegalEyebrow => 'LEGAL';

  @override
  String get settingsSectionLegalTitle => 'Privacidad';

  @override
  String get settingsSectionLegalSubtitle =>
      'Política de privacidad y términos de uso.';

  @override
  String get settingsAppearanceTitle => 'Apariencia';

  @override
  String get settingsAppearanceSubtitle => 'Elegí el tema visual de la app';

  @override
  String get settingsThemeModeTitle => 'Modo del Tema';

  @override
  String get settingsThemeModeLight => 'Claro';

  @override
  String get settingsThemeModeDark => 'Oscuro';

  @override
  String get settingsThemeModeSystem => 'Sistema';

  @override
  String get settingsThemePaletteTitle => 'Color del Tema';

  @override
  String get settingsPremiumBadge => 'PREMIUM';

  @override
  String get settingsPremiumTitle => 'HomeSync Premium';

  @override
  String get settingsPremiumActiveSubtitle => 'Gestionar plan';

  @override
  String get settingsPremiumInactiveSubtitle => 'Funciones avanzadas';

  @override
  String get settingsPremiumFeedbackRewardNote =>
      'Reportá errores o sugerí mejoras útiles y podés ganar meses Premium gratis.';

  @override
  String get settingsPremiumFeatureShoppingFinanceSync =>
      'Sincronización de compras con finanzas';

  @override
  String get settingsPremiumFeatureRecurringPayments =>
      'Pagos Recurrentes (Suscripciones)';

  @override
  String get settingsPremiumFeatureExclusiveAvatars => 'Avatares Exclusivos';

  @override
  String get settingsMinorPremiumSnack =>
      'Esta función es premium 🌟 Pedile a un adulto del hogar que active el plan.';

  @override
  String get settingsReplayTourTitle => 'Ver guia de nuevo';

  @override
  String get settingsReplayTourSubtitle => 'Repasá la introducción del hogar';

  @override
  String get settingsFeedbackTitle => 'Enviar feedback';

  @override
  String get settingsFeedbackSubtitle => 'Reporta un bug o sugiere una mejora';

  @override
  String get settingsLegalPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsLegalTermsOfUse => 'Términos de uso';

  @override
  String get settingsNotificationsEnabled => '🔔 Notificaciones activadas';

  @override
  String get settingsNotificationsDisabled => '🔕 Notificaciones desactivadas';

  @override
  String get settingsProfileNameUpdated => '✅ Nombre actualizado';

  @override
  String get settingsAccountReset => '✅ Datos reiniciados y hogar liberado';

  @override
  String get settingsAccountResetError => 'No se pudo reiniciar la cuenta.';

  @override
  String get settingsLinkOpenError => 'No se pudo abrir el enlace';

  @override
  String get settingsProfileNameFallback => 'Usuario';

  @override
  String get settingsProfileAvatarAction => 'Avatar';

  @override
  String get settingsProfileNameAction => 'Nombre';

  @override
  String get settingsRenameProfileTitle => 'Cambiar nombre';

  @override
  String get settingsRenameProfileLabel => 'Nombre';

  @override
  String get settingsNotificationsTitle => 'Notificaciones';

  @override
  String get settingsFaqTitle => 'Preguntas Frecuentes';

  @override
  String get settingsLogoutButton => 'Cerrar sesión';

  @override
  String get settingsDangerZoneEyebrow => 'ZONA DE PELIGRO';

  @override
  String get settingsResetAccountButton => 'Reiniciar Datos de Cuenta';

  @override
  String get settingsLogoutDialogTitle => '¿Cerrar sesión?';

  @override
  String get settingsLogoutDialogBody =>
      'Vas a tener que iniciar sesión de nuevo para acceder a tu hogar.';

  @override
  String get settingsLogoutDialogConfirm => 'Salir';

  @override
  String get settingsResetDialogTitle => '¿Reiniciar todo?';

  @override
  String get settingsResetDialogBody =>
      'Esta acción borrará todas tus tareas, gastos y progreso de forma permanente, y te quitará del hogar actual para que puedas configurar uno nuevo o unirte a otro.';

  @override
  String get settingsResetDialogConfirm => 'Reiniciar';

  @override
  String get settingsDeleteAccountButton => 'Eliminar mi cuenta';

  @override
  String get settingsDeleteAccountDialogTitle => '¿Eliminar tu cuenta?';

  @override
  String get settingsDeleteAccountDialogBody =>
      'Esto elimina tu cuenta y todos tus datos (tareas, gastos, recompensas y progreso) de forma permanente. No se puede deshacer. Si compartís un hogar, dejarás de formar parte de él.';

  @override
  String get settingsDeleteAccountConfirm => 'Eliminar definitivamente';

  @override
  String get settingsDeleteAccountSuccess => 'Cuenta eliminada';

  @override
  String get settingsDeleteAccountError =>
      'No se pudo eliminar la cuenta. Intentá de nuevo.';

  @override
  String get settingsDeleteAccountReauthNeeded =>
      'Por seguridad, volvé a iniciar sesión y luego eliminá tu cuenta.';

  @override
  String get splashLoadingMessage => 'Preparando tu hogar compartido.';

  @override
  String get authWelcomeTitle => 'Bienvenido';

  @override
  String get authSignUpTitle => 'Armá tu hogar';

  @override
  String get authWelcomeSubtitle =>
      'Ingresá para entrar a tu hogar y mantener todo al día.';

  @override
  String get authSignUpSubtitle =>
      'Creá tu cuenta para empezar a organizar tu hogar.';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authEmailFullHint => 'Correo electrónico';

  @override
  String get authPasswordHint => 'Contraseña';

  @override
  String get authPasswordHintWithMin => 'Contraseña (mínimo 6 caracteres)';

  @override
  String get authNameHint => 'Tu nombre o apodo';

  @override
  String get authValidationRequired => 'Requerido';

  @override
  String get authValidationInvalidEmail => 'Inválido';

  @override
  String get authValidationInvalidPassword => 'Inválida';

  @override
  String get authForgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get authSignInButton => 'Ingresar';

  @override
  String get authCreateAccountButton => 'Crear cuenta';

  @override
  String get authTermsAcceptance =>
      'Al crear una cuenta aceptás nuestros términos y la política de privacidad.';

  @override
  String get authShowPasswordTooltip => 'Mostrar contraseña';

  @override
  String get authHidePasswordTooltip => 'Ocultar contraseña';

  @override
  String get authOrContinueWith => 'o continuá con';

  @override
  String get authToggleHasAccount => '¿Ya tenés cuenta?';

  @override
  String get authToggleNewToApp => '¿Sos nuevo en HomeSync?';

  @override
  String get authToggleSignInLink => 'Ingresá';

  @override
  String get authToggleSignUpLink => 'Registrate';

  @override
  String get authForgotDialogTitle => 'Recuperar contraseña';

  @override
  String get authForgotDialogBody =>
      'Te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get authForgotDialogSendButton => 'Enviar enlace';

  @override
  String get authForgotInvalidEmail => 'Ingresá un correo válido';

  @override
  String get authForgotEmailSent =>
      '¡Revisá tu correo para cambiar tu contraseña!';

  @override
  String get authSignUpEmailSent =>
      '¡Revisá tu correo para confirmar tu cuenta!';

  @override
  String get authSignInError =>
      'No pudimos iniciar sesión. Revisá tus datos e intentá de nuevo.';

  @override
  String get authSignUpError => 'No pudimos crear tu cuenta. Intentá de nuevo.';

  @override
  String get authPasswordResetError =>
      'No pudimos enviar el correo de recuperación. Intentá de nuevo.';

  @override
  String get authGoogleSignInError =>
      'No pudimos ingresar con Google. Intentá de nuevo.';

  @override
  String get invitationLoadError =>
      'No pudimos generar el código de invitación.';

  @override
  String commonErrorWithDetails(String message) {
    return 'Error: $message';
  }

  @override
  String get commonUserFallback => 'Usuario';

  @override
  String get homeWelcomeMasculine => 'Bienvenido';

  @override
  String get homeWelcomeFeminine => 'Bienvenida';

  @override
  String get homeViewWeekButton => 'Ver semana';

  @override
  String homeTodayProgressLabel(int done, int total) {
    return '$done de $total';
  }

  @override
  String homeTodayProgressSemantic(int done, int total) {
    return 'Progreso de hoy: $done de $total tareas completadas';
  }

  @override
  String get homeAllDoneToday => 'Todo listo por hoy';

  @override
  String get homeTaskAddedNoticeTitle => 'Tarea agregada';

  @override
  String homeTaskAddedNoticeBody(String taskTitle) {
    return 'Ya aparece en Hoy en casa: $taskTitle';
  }

  @override
  String get homeFabActions => 'Acciones';

  @override
  String get homeFabExpenses => 'Gastos';

  @override
  String get homeFabTasks => 'Tareas';

  @override
  String get balanceCardSettled => 'Todo equilibrado';

  @override
  String get balanceCardMyBudget => 'Mi presupuesto';

  @override
  String get balanceCardBalanced => 'Balance en calma';

  @override
  String get balanceCardNeedsSettlement => 'Hace falta equilibrar';

  @override
  String get balanceCardInYourFavor => 'Quedó a tu favor';

  @override
  String get balanceCardSettleButton => 'Equilibrar';

  @override
  String get balanceCardXpLabel => 'XP';

  @override
  String get balanceCardCoinsLabel => 'coins';

  @override
  String get balanceCardIntegratedTitle => 'Economía integrada';

  @override
  String get balanceCardIntegratedSubtitle => 'Gastos del hogar';

  @override
  String get homeNoActivityYet => 'No hay actividad aún';

  @override
  String get homeHeadlinePrimary => 'Todo lo importante';

  @override
  String get homeSoloHeadlineSecondary => 'de tus días';

  @override
  String get homeSoloFocusToday => 'Enfocate en tus objetivos hoy 🚀';

  @override
  String get homeSoloBalanceLabel => 'Gastado este mes';

  @override
  String get homeSoloXpCaption => 'Tu progreso';

  @override
  String get homeSoloLevelEyebrow => 'Nivel';

  @override
  String get homeSoloTasksTitle => 'Tus tareas';

  @override
  String get homeSoloAddTaskButton => 'Agregar tarea';

  @override
  String get homeSoloActivityTitle => 'Tu actividad';

  @override
  String get homeGreetingMorning => 'Buenos días,';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes,';

  @override
  String get homeGreetingEvening => 'Buenas noches,';

  @override
  String get homeSoloSpentEmpty => 'Sin gastos aún ✨';

  @override
  String homeSoloSpentDailyAvg(String month, String amount) {
    return '$month · $amount/día';
  }

  @override
  String get soloSpaceEyebrow => 'Mi espacio';

  @override
  String soloSpaceLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String soloSpaceXpToNext(int xp) {
    return 'Te faltan $xp XP para el próximo nivel.';
  }

  @override
  String get soloSpaceStageRecentMove => 'Mudanza reciente';

  @override
  String get soloSpaceStageRecentMoveSubtitle =>
      'Tu espacio está empezando a tomar forma. Elegí una acción simple y construí desde ahí.';

  @override
  String get soloSpaceStageInMotion => 'Hogar en marcha';

  @override
  String get soloSpaceStageInMotionSubtitle =>
      'Ya hay movimiento: algunas rutinas, gastos o tareas empiezan a ordenar tus días.';

  @override
  String get soloSpaceStageSteadyRoutine => 'Rutina estable';

  @override
  String get soloSpaceStageSteadyRoutineSubtitle =>
      'Ya tenés una base; ahora se trata de sostenerla sin pensarlo tanto.';

  @override
  String get soloSpaceStageOrganizedHome => 'Casa organizada';

  @override
  String get soloSpaceStageOrganizedHomeSubtitle =>
      'Tus pendientes, gastos y actividad empiezan a leerse como un sistema claro.';

  @override
  String get soloSpaceStageOwnRhythm => 'Tu espacio, tu ritmo';

  @override
  String get soloSpaceStageOwnRhythmSubtitle =>
      'Ya no es solo registrar cosas: estás construyendo una forma propia de vivir tu hogar.';

  @override
  String get soloSpaceSignalsTitle => 'Señales de la semana';

  @override
  String get soloSpaceStreakTitle => 'Racha';

  @override
  String soloSpaceStreakMetric(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
      zero: 'Sin racha',
    );
    return '$_temp0';
  }

  @override
  String soloSpaceActiveDays14(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días activos en 14 días',
      one: '1 día activo en 14 días',
      zero: 'Sin días activos recientes',
    );
    return '$_temp0';
  }

  @override
  String get soloSpaceWeeklyXpTitle => 'XP semanal';

  @override
  String get soloSpaceWeeklyTasksTitle => 'Tareas semanales';

  @override
  String soloSpaceDeltaUp(int value) {
    return '+$value vs semana anterior';
  }

  @override
  String soloSpaceDeltaDown(int value) {
    return '$value vs semana anterior';
  }

  @override
  String get soloSpaceDeltaSame => 'Igual que la semana anterior';

  @override
  String soloSpaceTopTaskCategory(String category) {
    return 'Tareas: $category';
  }

  @override
  String soloSpaceTopExpenseCategory(String category) {
    return 'Gastos: $category';
  }

  @override
  String get soloSpaceSignalsSyncing =>
      'Actualizando señales reales de tu hogar.';

  @override
  String get soloSpaceDimensionsTitle => 'Cómo viene tu hogar';

  @override
  String get soloSpaceOrderTitle => 'Orden';

  @override
  String get soloSpaceOrderSubtitle => 'Tareas, pendientes y cierre del día.';

  @override
  String get soloSpaceClarityTitle => 'Claridad';

  @override
  String get soloSpaceClaritySubtitle =>
      'Gastos registrados y lectura del mes.';

  @override
  String get soloSpaceContinuityTitle => 'Continuidad';

  @override
  String get soloSpaceContinuitySubtitle =>
      'Actividad reciente y constancia real.';

  @override
  String get soloSpaceNextTitle => 'Próximo gesto';

  @override
  String get soloSpaceNextCreateTask => 'Creá una tarea base';

  @override
  String get soloSpaceNextCreateTaskSubtitle =>
      'Una rutina chica alcanza para empezar a darle forma a tu espacio.';

  @override
  String get soloSpaceNextCompleteTask => 'Cerrá una tarea de hoy';

  @override
  String get soloSpaceNextCompleteTaskSubtitle =>
      'Bajar pendientes es la forma más directa de mejorar tu Orden.';

  @override
  String get soloSpaceNextRegisterExpense => 'Registrá tu primer gasto del mes';

  @override
  String get soloSpaceNextRegisterExpenseSubtitle =>
      'Con un movimiento cargado, tu Claridad empieza a tener contexto.';

  @override
  String get soloSpaceNextReviewShopping => 'Revisá tu lista de compras';

  @override
  String get soloSpaceNextReviewShoppingSubtitle =>
      'Una compra ordenada evita ruido y mantiene el mes más liviano.';

  @override
  String get soloSpaceNextKeepGoing => 'Sumá una acción simple';

  @override
  String get soloSpaceNextKeepGoingSubtitle =>
      'Un gesto chico hoy sostiene la continuidad de tu hogar.';

  @override
  String get soloSpaceMilestonesTitle => 'Hitos personales';

  @override
  String get soloSpaceMilestoneFirstStep => 'Primer paso';

  @override
  String get soloSpaceMilestoneFirstStepDesc => 'Completaste tu primera tarea.';

  @override
  String get soloSpaceMilestoneWeekInMotion => 'Semana en marcha';

  @override
  String get soloSpaceMilestoneWeekInMotionDesc =>
      'Tuviste actividad reciente suficiente para marcar ritmo.';

  @override
  String get soloSpaceMilestoneClearerHome => 'Casa más clara';

  @override
  String get soloSpaceMilestoneClearerHomeDesc =>
      'Tus finanzas ya tienen señales útiles este mes.';

  @override
  String get soloSpaceMilestoneSteadyRoutine => 'Rutina sostenida';

  @override
  String get soloSpaceMilestoneSteadyRoutineDesc =>
      'Orden y continuidad empiezan a trabajar juntos.';

  @override
  String get soloSpaceMilestoneOwnRhythm => 'Ritmo propio';

  @override
  String get soloSpaceMilestoneOwnRhythmDesc =>
      'Tu progreso ya muestra una identidad personal.';

  @override
  String get soloSpaceFutureHint =>
      'Tu espacio se ajusta con tus tareas, gastos y ritmo semanal.';

  @override
  String get soloSpaceRitualTitle => 'Cierre semanal';

  @override
  String soloSpaceRitualProgress(int done, int total) {
    return '$done de $total gestos';
  }

  @override
  String get soloSpaceRitualReviewTasks => 'Revisar pendientes abiertos';

  @override
  String get soloSpaceRitualCheckSpending => 'Mirar gastos del mes';

  @override
  String get soloSpaceRitualPlanShopping => 'Ajustar la lista de compras';

  @override
  String get soloSpaceRitualChooseNextRoutine =>
      'Elegir una rutina para sostener';

  @override
  String get soloSpaceInsightsTitle => 'Lectura de la semana';

  @override
  String get soloSpaceInsightNoActivity => 'Punto de partida';

  @override
  String get soloSpaceInsightNoActivityDesc =>
      'Todavía no hay señales fuertes esta semana. Un gesto simple alcanza para arrancar.';

  @override
  String get soloSpaceInsightStreak => 'Racha en construcción';

  @override
  String soloSpaceInsightStreakDesc(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días activos seguidos empiezan a formar ritmo.',
      one: 'Un día activo ya marca continuidad.',
    );
    return '$_temp0';
  }

  @override
  String get soloSpaceInsightWeekImproved => 'Semana más fuerte';

  @override
  String soloSpaceInsightWeekImprovedDesc(int value) {
    return '+$value XP contra la semana anterior. Hay más movimiento en tu casa.';
  }

  @override
  String get soloSpaceInsightWeekSlowed => 'Semana más baja';

  @override
  String get soloSpaceInsightWeekSlowedDesc =>
      'Bajó el movimiento. Conviene elegir una acción chica y cerrar el día.';

  @override
  String get soloSpaceInsightFinanceVisible => 'Finanzas con contexto';

  @override
  String get soloSpaceInsightFinanceVisibleDesc =>
      'Ya hay movimientos suficientes para leer el mes con más claridad.';

  @override
  String get soloSpaceInsightNoFinance => 'Falta lectura financiera';

  @override
  String get soloSpaceInsightNoFinanceDesc =>
      'Registrar un gasto real activa mejores señales de Claridad.';

  @override
  String get soloSpaceInsightTaskCategory => 'Patrón de tareas';

  @override
  String soloSpaceInsightTaskCategoryDesc(String category) {
    return '$category aparece como foco fuerte este mes.';
  }

  @override
  String get soloSpaceInsightExpenseCategory => 'Patrón de gastos';

  @override
  String soloSpaceInsightExpenseCategoryDesc(String category) {
    return '$category concentra más movimiento este mes.';
  }

  @override
  String get soloSpaceSuggestionsTitle => 'Herramientas sugeridas';

  @override
  String get soloSpaceSuggestionRecurringTask => 'Convertir algo en rutina';

  @override
  String get soloSpaceSuggestionRecurringTaskDesc =>
      'Una tarea recurrente baja fricción y sostiene Orden.';

  @override
  String get soloSpaceSuggestionClosePending => 'Cerrar lo pendiente';

  @override
  String get soloSpaceSuggestionClosePendingDesc =>
      'Resolver una tarea de hoy libera espacio mental.';

  @override
  String get soloSpaceSuggestionRegisterExpense => 'Cargar un gasto real';

  @override
  String get soloSpaceSuggestionRegisterExpenseDesc =>
      'Con un movimiento, la lectura del mes deja de estar vacía.';

  @override
  String get soloSpaceSuggestionReviewShopping => 'Revisar compras';

  @override
  String get soloSpaceSuggestionReviewShoppingDesc =>
      'Una lista clara evita compras repetidas o de último minuto.';

  @override
  String get soloSpaceSuggestionProtectStreak => 'Proteger la racha';

  @override
  String get soloSpaceSuggestionProtectStreakDesc =>
      'Una acción chica hoy mantiene viva la continuidad.';

  @override
  String get soloSpaceSuggestionWeeklyReview => 'Hacer cierre semanal';

  @override
  String get soloSpaceSuggestionWeeklyReviewDesc =>
      'Marcá los gestos del ritual y dejá la semana ordenada.';

  @override
  String get soloSpaceUnlocksTitle => 'Desbloqueos suaves';

  @override
  String get soloSpaceUnlockActive => 'Activo';

  @override
  String get soloSpaceUnlockNext => 'Luego';

  @override
  String get soloSpaceUnlockWeeklyReview => 'Vista de cierre';

  @override
  String get soloSpaceUnlockWeeklyReviewDesc =>
      'Disponible desde el inicio para ordenar la semana sin presión.';

  @override
  String get soloSpaceUnlockRecurringTemplates => 'Plantillas recurrentes';

  @override
  String get soloSpaceUnlockRecurringTemplatesDesc =>
      'Aparecen cuando ya hay base para repetir rutinas.';

  @override
  String get soloSpaceUnlockHabitInsights => 'Insights de hábitos';

  @override
  String get soloSpaceUnlockHabitInsightsDesc =>
      'Se activan con varios días de actividad real.';

  @override
  String get soloSpaceUnlockPersonalMedal => 'Medalla personal';

  @override
  String get soloSpaceUnlockPersonalMedalDesc =>
      'Reconoce una etapa sostenida sin competir con nadie.';

  @override
  String get soloSpaceUnlockRhythmRecommendations => 'Recomendaciones de ritmo';

  @override
  String get soloSpaceUnlockRhythmRecommendationsDesc =>
      'Cruzan claridad financiera con continuidad semanal.';

  @override
  String activityCoinsPlus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count coins',
      one: '+1 coin',
    );
    return '$_temp0';
  }

  @override
  String activityCoinsMinus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '-$count coins',
      one: '-1 coin',
    );
    return '$_temp0';
  }

  @override
  String get homeFamilyApprovalsTileLabel => 'Aprobaciones';

  @override
  String homeFamilyApprovalsPendingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pendientes',
      one: 'pendiente',
    );
    return '$_temp0';
  }

  @override
  String get homeFamilyApprovalsAllClear => 'Al día';

  @override
  String expensesYouAreOwed(String amount) {
    return 'Te deben $amount';
  }

  @override
  String expensesYouOwe(String amount) {
    return 'Debés $amount';
  }

  @override
  String expensesDailyAvg(String amount) {
    return '≈ $amount/día';
  }

  @override
  String get homeCoupleHeadlineSecondary => 'del hogar';

  @override
  String get homeCoupleHeadlineConnector => 'con';

  @override
  String get homeCouplePartnerFallback => 'tu pareja';

  @override
  String get homeCoupleShoppingListTitle => 'Lista actual';

  @override
  String get homeShoppingPreviewOpen => 'Abrir compras';

  @override
  String get homeShoppingPreviewEmpty => 'No hay productos pendientes.';

  @override
  String get homeShoppingPreviewLoadError => 'No pudimos cargar la lista.';

  @override
  String homeShoppingPreviewPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String homeShoppingPreviewMoreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count más en la lista',
      one: '+1 más en la lista',
    );
    return '$_temp0';
  }

  @override
  String get homeCoupleTasksTitle => 'Hoy en casa';

  @override
  String get homeCoupleActivityTitle => 'Movimientos del hogar';

  @override
  String get homeCoupleActivityEmptyTitle => 'Todavía no hay movimientos';

  @override
  String get homeCoupleActivityEmptyBody =>
      'Cuando haya una tarea o un gasto nuevo, aparece acá.';

  @override
  String get homeCoupleSettlementErrorNoUser =>
      'No pudimos identificar tu usuario.';

  @override
  String get homeCoupleSettlementDialogTitle => 'Registrar equilibrio';

  @override
  String homeCoupleSettlementDialogDirectionPay(String partnerName) {
    return 'Vos → $partnerName';
  }

  @override
  String homeCoupleSettlementDialogDirectionReceive(String partnerName) {
    return '$partnerName → vos';
  }

  @override
  String get homeCoupleSettlementDialogBalanceZero =>
      'Esto va a dejar el balance del hogar en cero.';

  @override
  String get homeCoupleSettlementDialogCancel => 'Ahora no';

  @override
  String get homeCoupleSettlementDialogConfirm => 'Registrar pago';

  @override
  String homeCoupleSettlementDialogTitlePay(String partnerName) {
    return 'Equilibrar con $partnerName';
  }

  @override
  String get homeCoupleSettlementDialogTitleReceive => 'Registrar equilibrio';

  @override
  String homeCoupleSettlementDialogBodyPay(String amount, String partnerName) {
    return 'Se va a registrar un pago de $amount para saldar el balance con $partnerName.';
  }

  @override
  String homeCoupleSettlementDialogBodyReceive(
      String partnerName, String amount) {
    return 'Se va a registrar que $partnerName te compensó $amount para dejar el balance al día.';
  }

  @override
  String get homeCoupleSettlementDoneBadge => 'Listo';

  @override
  String homeCoupleSettlementSuccessPay(String partnerName) {
    return 'Balance equilibrado con $partnerName.';
  }

  @override
  String homeCoupleSettlementSuccessReceive(String partnerName) {
    return 'Registramos el equilibrio con $partnerName.';
  }

  @override
  String homeCoupleSettlementError(String message) {
    return 'No se pudo equilibrar el balance: $message';
  }

  @override
  String get commonGreetingMorning => 'Buen día';

  @override
  String get commonGreetingAfternoon => 'Buenas tardes';

  @override
  String get commonGreetingEvening => 'Buenas noches';

  @override
  String get homeViewAllButton => 'Ver todas';

  @override
  String get homeViewListButton => 'Ver lista';

  @override
  String get homeFriendsHeaderSubtitle => 'Así viene el piso hoy.';

  @override
  String get homeFriendsMemberNotFound =>
      'No encontramos tu perfil en este piso.';

  @override
  String get homeFriendsBalancesTitle => 'Saldos del piso';

  @override
  String get homeFriendsBalancesEmptyTitle =>
      'Todavía no hay balances para mostrar.';

  @override
  String get homeFriendsBalancesEmptyBody =>
      'Cuando registren gastos compartidos, vas a ver acá el saldo neto de cada integrante.';

  @override
  String get homeFriendsBalanceCardTitle => 'Estado del balance';

  @override
  String get homeFriendsTasksTitle => 'Tareas del piso';

  @override
  String get homeFriendsTasksSubtitle =>
      'Lo que sigue pendiente para mantener todo en orden.';

  @override
  String get homeFriendsTaskCompleteError =>
      'No pudimos completar la tarea. Intentá de nuevo.';

  @override
  String get homeFriendsShoppingTitle => 'Compras del piso';

  @override
  String get homeFriendsShoppingSubtitle =>
      'Lo que falta comprar para la semana.';

  @override
  String get homeFriendsAllCleanTitle => '¡Todo limpio!';

  @override
  String get homeFriendsActivityTitle => 'Actividad del piso';

  @override
  String get homeFriendsActivitySubtitle =>
      'Los últimos movimientos compartidos del hogar.';

  @override
  String get homeFriendsActivityEmpty =>
      'Todavía no hubo movimientos compartidos.';

  @override
  String get homeFriendsSettleTitle => 'Saldar cuentas';

  @override
  String get homeFriendsSettleSubtitle =>
      'Quién le paga a quién para quedar en cero.';

  @override
  String get homeFriendsBalancesLoadError =>
      'No pudimos cargar los saldos. Tocá para reintentar.';

  @override
  String get homeFriendsTasksLoadError =>
      'No pudimos cargar las tareas. Tocá para reintentar.';

  @override
  String get homeFriendsShoppingLoadError =>
      'No pudimos cargar las compras. Tocá para reintentar.';

  @override
  String get homeFriendsActivityLoadError =>
      'No pudimos cargar la actividad. Tocá para reintentar.';

  @override
  String get balanceCardStatusOwed => 'Te toca acomodar tu saldo';

  @override
  String get balanceCardStatusFavor => 'Quedó a tu favor';

  @override
  String get balanceCardStatusShared => 'Balance compartido';

  @override
  String get balanceCardBadgeSettled => 'Al día';

  @override
  String get balanceCardBadgeOwes => 'Debés';

  @override
  String get balanceCardBadgeFavor => 'A favor';

  @override
  String balanceCardMovements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos',
      one: '1 movimiento',
      zero: '0 movimientos',
    );
    return '$_temp0';
  }

  @override
  String balanceCardMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Integrantes',
      one: 'Integrante',
    );
    return '$_temp0';
  }

  @override
  String balanceCardOpenBalances(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saldos abiertos',
      one: 'Saldo abierto',
      zero: 'Todo al día',
    );
    return '$_temp0';
  }

  @override
  String get balanceCardSingleMemberHint =>
      'Cuando sumes más integrantes, acá vas a ver cómo queda el balance compartido.';

  @override
  String get balanceCardMemberOwes => 'Debe';

  @override
  String get balanceCardMemberFavor => 'A favor';

  @override
  String get balanceCardMemberSettled => 'Al día';

  @override
  String get settleSectionTitle => 'Saldar deudas';

  @override
  String get settleSectionOnePayment => '1 pago necesario para equilibrar';

  @override
  String settleSectionPayments(int count) {
    return '$count pagos para equilibrar todo';
  }

  @override
  String get settleAllSettled => 'Todo equilibrado. Nadie le debe a nadie.';

  @override
  String settlePaysTo(String name) {
    return 'le paga a $name';
  }

  @override
  String get settleConfirmTitle => 'Confirmar pago';

  @override
  String settleConfirmBody(String from, String amount, String to) {
    return '$from le paga $amount a $to.';
  }

  @override
  String settleSuccess(String amount) {
    return 'Pago de $amount registrado.';
  }

  @override
  String settleError(String error) {
    return 'No se pudo registrar el pago: $error';
  }

  @override
  String get homeFamilyMemberNotFound =>
      'No encontramos tu perfil en este hogar.';

  @override
  String get homeFamilyMetricCoins => 'Monedas';

  @override
  String get homeFamilyAdultFallbackName => 'Familia';

  @override
  String get homeFamilyChildHello => '¡Vamos, ';

  @override
  String get homeFamilyChildGreetingSuffix => '!';

  @override
  String get homeFamilyChildFallbackName => 'campeon';

  @override
  String get homeFamilyChildHeroTitle => 'Aventura de hoy';

  @override
  String homeFamilyChildHeroBody(String firstName) {
    return '$firstName, cada misión aprobada suma coins para la tienda.';
  }

  @override
  String get homeFamilyChildRewardsPrompt => 'Mirá qué premios podés alcanzar.';

  @override
  String get homeFamilyChildActivityTitle => 'Mis logros';

  @override
  String get homeFamilyActivityTitle => 'Movimientos del hogar';

  @override
  String get homeFamilyActivityTitleDefault => 'Actividad Reciente';

  @override
  String get homeFamilyActivityEmptyTitle =>
      'Todavía no hay actividad reciente';

  @override
  String get homeFamilyActivityEmptyBody =>
      'Las tareas, gastos y compras van a aparecer acá.';

  @override
  String get homeFamilyShoppingTitle => 'Compras del hogar';

  @override
  String get homeFamilyShoppingAllDone => 'Lista al día';

  @override
  String homeFamilyShoppingMoreItems(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $countString productos más en la lista',
      one: 'Hay 1 producto más en la lista',
    );
    return '$_temp0';
  }

  @override
  String get homeFamilyFinanceTitle => 'Finanzas familiares';

  @override
  String get homeFamilyFinanceLoadError =>
      'No pudimos cargar las finanzas del hogar por ahora.';

  @override
  String get homeFamilyFinanceViewAll => 'Ver todos';

  @override
  String get homeFamilyFinanceMonthSpent => 'Gasto compartido del mes';

  @override
  String get homeFamilyFinanceMonthEmpty => 'Mes sin gastos';

  @override
  String get familyTasksTitleChild => 'Mis misiones';

  @override
  String get familyTasksTitleTeen => 'Tareas del hogar';

  @override
  String get familyTasksEmptyTitle => 'Todo al día';

  @override
  String get familyTasksEmptyChildSubtitle =>
      'Hoy podés descansar o mirar la tienda.';

  @override
  String get familyTasksEmptyOtherSubtitle =>
      'No hay tareas programadas para hoy.';

  @override
  String get familyTasksMarkTitle => 'Marcar tarea';

  @override
  String familyTasksMarkBodyApproval(String taskTitle, String actorName) {
    return 'Se va a marcar \"$taskTitle\" como realizada por $actorName y se enviará a revisión.';
  }

  @override
  String familyTasksMarkBodyDirect(String taskTitle, String actorName) {
    return 'Se va a marcar \"$taskTitle\" como realizada por $actorName.';
  }

  @override
  String get familyTasksActorFallback => 'vos';

  @override
  String get familyTasksTakeoverTitle => 'Completar tarea';

  @override
  String familyTasksTakeoverBody(String ownerName) {
    return 'Esta tarea estaba asignada a $ownerName. Si seguís, se va a marcar como realizada por vos.';
  }

  @override
  String get familyTasksTakeoverConfirm => 'Completar';

  @override
  String get familyTasksTakeoverOwnerFallback => 'otro integrante';

  @override
  String familyTasksLockedMessage(String ownerName) {
    return 'Esta tarea le toca a $ownerName.';
  }

  @override
  String get familyTasksLockedOwnerFallback => 'otra persona';

  @override
  String get familyTasksSubmittedSnack => 'Enviada para revisión de un adulto.';

  @override
  String familyTasksSubmitError(String message) {
    return 'No pudimos enviar la tarea: $message';
  }

  @override
  String get familyTasksReviewTitle => 'Revisar tarea';

  @override
  String familyTasksReviewBody(String performerName, String taskTitle) {
    return '$performerName marcó \"$taskTitle\" como realizada.';
  }

  @override
  String get familyTasksReviewPerformerFallback => 'este integrante';

  @override
  String get familyTasksReviewApprove => 'Aprobar tarea';

  @override
  String get familyTasksReviewReject => 'Devolver para corregir';

  @override
  String get familyTasksApproveError => 'No pudimos aprobar la tarea.';

  @override
  String get familyTasksApproveSuccess => 'Tarea aprobada.';

  @override
  String familyTasksApproveErrorWithDetails(String message) {
    return 'No pudimos aprobar la tarea: $message';
  }

  @override
  String get familyTasksRejectSuccess => 'La tarea volvió a quedar pendiente.';

  @override
  String familyTasksRejectError(String message) {
    return 'No pudimos devolver la tarea: $message';
  }

  @override
  String get familyWeeklyTitle => 'Esta semana en el hogar';

  @override
  String get familyWeeklyMetricPoints => 'Puntos totales';

  @override
  String get familyWeeklyMetricTasks => 'Tareas cerradas';

  @override
  String get familyWeeklyMetricStatus => 'Estado';

  @override
  String get familyWeeklyStatusActive => 'Activo';

  @override
  String get familyWeeklyStatusCalm => 'Calma';

  @override
  String get familyWeeklyRankingTitle => 'Ranking Semanal';

  @override
  String get familyWeeklyRankingSubtitle => 'Esta semana';

  @override
  String get familyWeeklyRankingTabAll => 'Todos';

  @override
  String get familyWeeklyRankingTabAdults => 'Adultos';

  @override
  String get familyWeeklyRankingTabKids => 'Peques';

  @override
  String get familyWeeklyRankingMemberFallback => 'Integrante';

  @override
  String get familyWeeklyRankingEmptyMessage =>
      'Completen tareas para sumar puntos';

  @override
  String familyWeeklyRankingTabEmptyMessage(String tabLabel) {
    return 'Nadie sumó puntos en $tabLabel todavía';
  }

  @override
  String setupModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Pareja',
        'family': 'Familia',
        'friends': 'Convivencia',
        'solo': 'Solo yo',
        'other': 'Solo yo',
      },
    );
    return '$_temp0';
  }

  @override
  String setupModeDescription(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Gastos y tareas compartidas',
        'family': 'Tareas, compras y seguimiento familiar',
        'friends': 'Cuentas claras entre roommates',
        'solo': 'Rutinas y pendientes personales',
        'other': 'Rutinas y pendientes personales',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupProfileAvatarLabel => 'Avatar';

  @override
  String get setupSignOutLink => 'Cerrar sesión';

  @override
  String get setupFamilyDefaultName => 'Mi familia';

  @override
  String get setupSnackJoinedHousehold => '¡Te uniste al hogar!';

  @override
  String get setupSnackPickAtLeastOneTask => 'Seleccioná al menos una tarea';

  @override
  String get setupSnackUnknownError => 'Error desconocido';

  @override
  String get setupSnackOnboardingFailed =>
      'No se pudo completar el onboarding. Intentá de nuevo.';

  @override
  String get setupSnackCodeCopied => '¡Código copiado al portapapeles! 📋';

  @override
  String get setupFamilyRoleLabel => 'Tu rol visible';

  @override
  String get setupFamilyRoleFather => 'Padre';

  @override
  String get setupFamilyRoleMother => 'Madre';

  @override
  String get setupFamilyRoleGuardian => 'Tutor/a';

  @override
  String get setupFamilyRoleTeen => 'Adolescente';

  @override
  String setupFirstTasksTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Primeras tareas para la familia',
        'solo': '¿Qué querés tener en orden?',
        'other': '¿Qué tareas se reparten?',
      },
    );
    return '$_temp0';
  }

  @override
  String setupFirstTasksSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family':
            'Elegí tareas iniciales para coordinar el hogar desde el primer día.',
        'other':
            'Elegí las primeras tareas. Ya dejamos algunas sugeridas para arrancar.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupFinishButton => 'Terminar configuración';

  @override
  String setupCompletionTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': '¡Su hogar está listo!',
        'family': '¡El hogar familiar está listo!',
        'friends': '¡La convivencia está lista!',
        'solo': '¡Tu espacio está listo!',
        'other': '¡Tu espacio está listo!',
      },
    );
    return '$_temp0';
  }

  @override
  String setupCompletionMessage(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Ya pueden organizar tareas, gastos y metas juntos.',
        'family': 'Ya pueden repartir tareas y coordinar la casa.',
        'friends': 'Cuentas claras desde el día uno.',
        'solo': 'Todo ordenado para arrancar tus rutinas.',
        'other': 'Todo ordenado para arrancar tus rutinas.',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsHouseholdEmptyTitle => '¡Comienza tu equipo!';

  @override
  String get settingsHouseholdEmptyBody =>
      'Unite a un equipo existente con un código de invitación para empezar a compartir tareas y gastos.';

  @override
  String get settingsHouseholdJoinWithCodeButton => 'Unirse con código';

  @override
  String get settingsHouseholdTasksToggleTitle => 'Tareas del hogar';

  @override
  String get settingsHouseholdTasksToggleOnSubtitle =>
      'Mostrar tareas, progreso y accesos rápidos.';

  @override
  String get settingsHouseholdTasksToggleOffSubtitle =>
      'Ocultar tareas y dejar solo finanzas y compras.';

  @override
  String get settingsHouseholdMembersEyebrow => 'MIEMBROS';

  @override
  String settingsHouseholdMembersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get settingsHouseholdMemberFallbackName => 'Miembro';

  @override
  String get settingsHouseholdMemberSelfChip => 'Vos';

  @override
  String get settingsHouseholdMemberAdminChip => 'Admin';

  @override
  String get settingsHouseholdMemberMenuTooltip => 'Opciones del miembro';

  @override
  String get settingsHouseholdMemberMenuEditRole => 'Editar rol';

  @override
  String get settingsHouseholdMemberMenuRemove => 'Quitar del hogar';

  @override
  String get settingsHouseholdMemberMenuDeleteDummyQa => 'Eliminar dummy QA';

  @override
  String get settingsHouseholdJoinDialogTitle => 'Unirse a un hogar';

  @override
  String get settingsHouseholdJoinDialogBody =>
      'Ingresá el código de invitación que te compartieron para unirte al hogar:';

  @override
  String get settingsHouseholdJoinDialogConfirm => 'Unirme';

  @override
  String get settingsHouseholdEditMenuRenameTitle => 'Editar nombre';

  @override
  String get settingsHouseholdEditMenuRenameSubtitle =>
      'Cambiá el nombre de tu hogar';

  @override
  String get settingsHouseholdEditMenuInviteTitle => 'Código de invitación';

  @override
  String get settingsHouseholdEditMenuInviteSubtitleExisting =>
      'Compartir o generar nuevo código';

  @override
  String get settingsHouseholdEditMenuInviteSubtitleNone =>
      'Generar código para invitar';

  @override
  String settingsHouseholdEditMenuSplitTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Finanzas familiares',
        'other': 'División de gastos',
      },
    );
    return '$_temp0';
  }

  @override
  String settingsHouseholdEditMenuSplitSubtitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Elegir economía compartida o dividida',
        'couple': 'Economía integrada o gastos divididos',
        'other': 'Ajustar porcentaje',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsHouseholdInviteSheetTitle => 'Código de invitación';

  @override
  String get settingsHouseholdInviteSheetSubtitle =>
      'Compartí este código para que otros se unan a tu hogar';

  @override
  String get settingsHouseholdInviteSheetCopyTooltip => 'Copiar código';

  @override
  String get settingsHouseholdInviteSheetEmpty => 'Sin código activo';

  @override
  String get settingsHouseholdInviteSheetGenerate => 'Generar código';

  @override
  String get settingsHouseholdInviteSheetRegenerate => 'Generar nuevo código';

  @override
  String get settingsHouseholdRemoveMemberTitle => 'Quitar miembro';

  @override
  String settingsHouseholdRemoveMemberBody(String memberName) {
    return '¿Estás seguro de que querés quitar a $memberName de este hogar?';
  }

  @override
  String get settingsHouseholdRemoveMemberConfirm => 'Quitar';

  @override
  String get settingsHouseholdDeleteDummyTitle => 'Eliminar dummy QA';

  @override
  String settingsHouseholdDeleteDummyBody(String memberName) {
    return 'Esto eliminará a $memberName como usuario dummy QA. Si no pertenece a otro hogar QA, también se borrará su identidad técnica.';
  }

  @override
  String get settingsHouseholdDeleteDummyConfirm => 'Eliminar dummy';

  @override
  String get settingsHouseholdRenameDialogTitle => 'Nombre del hogar';

  @override
  String get settingsHouseholdRenameDialogLabel => 'Nombre';

  @override
  String get settingsHouseholdFallbackName => 'Mi hogar';

  @override
  String get settingsHouseholdCodeGenerated => 'Código generado';

  @override
  String get settingsHouseholdCodeCopied => 'Código copiado al portapapeles';

  @override
  String get settingsHouseholdCodeGenerateFirst => 'Generá un código primero';

  @override
  String get settingsHouseholdWhatsAppFallback =>
      'No se pudo abrir WhatsApp. Código copiado.';

  @override
  String get settingsHouseholdJoinSuccess => 'Te uniste al hogar exitosamente';

  @override
  String get settingsHouseholdJoinCodeLength =>
      'El código debe tener 6 caracteres';

  @override
  String get settingsHouseholdRoleUpdated => '✅ Rol actualizado';

  @override
  String get settingsHouseholdRenamed => '✅ Hogar renombrado';

  @override
  String get settingsHouseholdTasksEnabledSnack =>
      '✅ Tareas del hogar activadas';

  @override
  String get settingsHouseholdFinanceModeSnack =>
      '✅ Modo finanzas y compras activado';

  @override
  String settingsHouseholdUpdateError(String error) {
    return 'No se pudo actualizar la configuración: $error';
  }

  @override
  String get settingsAssignRoleTitle => 'Asignar rol o apodo';

  @override
  String settingsAssignRoleFieldLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Nombre del rol (ej: Pareja)',
        'friends': 'Nombre del rol (ej: Compañero)',
        'other': 'Nombre del rol (ej: Madre)',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsAssignRoleSuggestionsLabel => 'Sugerencias:';

  @override
  String get settingsRoleSuggestionsCouple =>
      'Pareja,Novio,Novia,Esposo,Esposa';

  @override
  String get settingsRoleSuggestionsFriends =>
      'Compañero,Roommate,Invitado,Responsable';

  @override
  String get settingsMemberRoleOwner => 'Propietario';

  @override
  String get settingsMemberRoleCouple => 'Pareja';

  @override
  String get settingsMemberRoleFriends => 'Compañero';

  @override
  String get settingsMemberRoleDefault => 'Miembro';

  @override
  String get settingsHouseholdLoadError =>
      'No pudimos cargar tu hogar. Revisá tu conexión e intentá de nuevo.';

  @override
  String get settingsParentModeTitle => 'Modo Padres';

  @override
  String get settingsParentModeSubtitle => 'Vos coordinas, ellos cumplen.';

  @override
  String get settingsParentModeBulletApproval =>
      'Aprobación de tareas antes de dar coins.';

  @override
  String get settingsParentModeBulletPerMember =>
      'Vista por miembro y resumen familiar semanal.';

  @override
  String get settingsParentModeBulletRotation =>
      'Rotación automática de tareas entre integrantes.';

  @override
  String get settingsParentModeUnlockButton => 'Activar Modo Padres';

  @override
  String get settingsParentModeApprovalSectionTitle => 'Aprobación de tareas';

  @override
  String get settingsParentModeApprovalSectionSubtitle =>
      'Cuando un miembro completa una tarea, queda pendiente hasta que vos la apruebes.';

  @override
  String get settingsParentModeApprovalOffTitle => 'Desactivado';

  @override
  String get settingsParentModeApprovalOffSubtitle =>
      'Las tareas se acreditan apenas se completan.';

  @override
  String get settingsParentModeApprovalChildrenOnlyTitle =>
      'Solo niños y adolescentes';

  @override
  String get settingsParentModeApprovalChildrenOnlySubtitle =>
      'Los adultos completan directo; los demás requieren aprobación.';

  @override
  String get settingsParentModeApprovalPerMemberTitle => 'Por miembro';

  @override
  String get settingsParentModeApprovalPerMemberSubtitle =>
      'Vos elegís exactamente quién necesita aprobación en la lista de abajo.';

  @override
  String get settingsParentModeInboxIdle => 'Bandeja de aprobaciones';

  @override
  String settingsParentModeInboxWithCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bandeja de aprobaciones — $countString pendientes',
      one: 'Bandeja de aprobaciones — 1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String get settingsParentModeMemberView => 'Vista por miembro';

  @override
  String get settingsParentModeWeeklySummary => 'Resumen de la semana';

  @override
  String get settingsParentModeAllowanceTitle => 'Mesadas';

  @override
  String get settingsParentModeAllowanceSubtitle =>
      'Enviá mesadas a adolescentes con finanzas personales.';

  @override
  String get settingsParentModeAllowanceCta => 'Dar mesada';

  @override
  String get settingsParentModePerMemberEmpty =>
      'No hay otros miembros en el hogar todavía.';

  @override
  String get settingsParentModeSaveError =>
      'No pudimos guardar el cambio. Intentá de nuevo.';

  @override
  String get settingsParentModeLoadError =>
      'No pudimos cargar la configuración por integrante.';

  @override
  String get notificationsMarkReadError =>
      'No pudimos marcar la notificación como leída.';

  @override
  String get notificationsMarkAllReadError =>
      'No pudimos marcar todas las notificaciones como leídas.';

  @override
  String get notificationsLoadMoreError =>
      'No pudimos cargar más notificaciones. Intentá de nuevo.';

  @override
  String get settingsParentModeMemberTypeChild => 'Hijo/a';

  @override
  String get settingsParentModeMemberTypeTeen => 'Adolescente';

  @override
  String get settingsParentModeMemberTypeAdult => 'Adulto';

  @override
  String get settingsParentModeMemberTypeGuardian => 'Tutor/a';

  @override
  String get settingsParentModeRoleOwnerSuffix => 'Owner';

  @override
  String get settingsParentModeRoleAdminSuffix => 'Admin';

  @override
  String get memberOnboardingWelcomeTitle => '¡Bienvenido al hogar!';

  @override
  String get memberOnboardingWelcomeSubtitle => 'Elegí tu rol para empezar.';

  @override
  String get memberOnboardingEyebrow => 'Rol en el hogar';

  @override
  String get memberOnboardingTitle => '¿Quién sos?';

  @override
  String get memberOnboardingSubtitle => 'Elegí tu rol en el hogar.';

  @override
  String get memberOnboardingFinishButton => '¡Listo!';

  @override
  String get memberOnboardingSaveError =>
      'No se pudo guardar. Intentá de nuevo.';

  @override
  String get memberOnboardingRoleDescAdult =>
      'Responsable del hogar. Administra gastos y tareas.';

  @override
  String get memberOnboardingRoleDescTeen =>
      'Gestión personal de gastos y tareas.';

  @override
  String get memberOnboardingRoleDescChild =>
      'Participa con tareas y puede ganar recompensas.';

  @override
  String get memberOnboardingRoleDescDefault => 'Miembro del hogar.';

  @override
  String coupleSplitTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Finanzas familiares',
        'couple': 'Finanzas en pareja',
        'other': 'División de gastos',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitSavedSnack => 'Configuración guardada correctamente';

  @override
  String get coupleSplitSaveError =>
      'No pudimos guardar la configuración. Intentá de nuevo.';

  @override
  String get setupTemplatesLoadError =>
      'No pudimos cargar las tareas sugeridas.';

  @override
  String get coupleSplitFamilyHowTitle => 'Cómo se registran los gastos';

  @override
  String get coupleSplitFamilyHowBody =>
      'En familia, lo normal es una economía compartida: el gasto queda visible para el hogar, pero no genera deuda entre adultos. Si lo necesitás, podés activar división como en pareja.';

  @override
  String get coupleSplitFamilySharedTitle => 'Economía compartida';

  @override
  String get coupleSplitFamilySharedBody =>
      'Los gastos no se reparten por porcentaje ni generan balances entre adultos.';

  @override
  String get coupleSplitFamilyDividedTitle => 'Gastos divididos';

  @override
  String get coupleSplitFamilyDividedBody =>
      'Usa porcentajes y balances como en pareja.';

  @override
  String coupleSplitModeHowTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Cómo se registran los gastos',
        'other': 'Cómo manejan la plata',
      },
    );
    return '$_temp0';
  }

  @override
  String coupleSplitModeHowBody(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family':
            'En familia, lo normal es una economía compartida: el gasto queda visible para el hogar, pero no genera deuda entre adultos. Si lo necesitás, podés activar división como en pareja.',
        'other':
            'Hay dos formas de manejar la plata en pareja. En la economía integrada todo es del hogar: los gastos quedan visibles pero no generan deuda entre ustedes. En la dividida cada gasto se reparte y se lleva el balance.',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitModeSharedTitle => 'Economía integrada';

  @override
  String coupleSplitModeSharedBody(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family':
            'Los gastos no se reparten por porcentaje ni generan balances entre adultos.',
        'other':
            'Todo es plata del hogar: los gastos quedan registrados pero no generan deuda ni balances entre ustedes. Ideal para parejas con economía unificada.',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitModeDividedTitle => 'Gastos divididos';

  @override
  String coupleSplitModeDividedBody(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Usa porcentajes y balances como en pareja.',
        'other':
            'Cada gasto compartido se reparte según el porcentaje que elijan y se lleva el balance entre ustedes.',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitInfoTitle => '¿Cómo dividir gastos?';

  @override
  String get coupleSplitInfoBody =>
      'No hay una única forma correcta. Cada pareja es un mundo y la mejor estrategia es la que les dé paz mental a ambos.';

  @override
  String get coupleSplitStrategiesTitle => 'Estrategias comunes';

  @override
  String get coupleSplitStrategy5050Title => '50% / 50% (Igualitario)';

  @override
  String get coupleSplitStrategy5050Body =>
      'Ideal cuando ambos tienen ingresos similares. Cada uno aporta la mitad de los gastos compartidos.';

  @override
  String get coupleSplitStrategy6040Title => '60% / 40% (Equitativo)';

  @override
  String get coupleSplitStrategy6040Body =>
      'Si hay una diferencia de ingresos, el que gana más aporta una parte mayor proporcionalmente.';

  @override
  String get coupleSplitCustomTitle => 'Configuración personalizada';

  @override
  String get coupleSplitCustomBody =>
      'Ajustá el porcentaje que vos vas a aportar de forma predeterminada.';

  @override
  String get coupleSplitVisualizerYou => 'VOS';

  @override
  String get coupleSplitVisualizerPartner => 'TU PAREJA';

  @override
  String get coupleSplitSaveButton => 'Guardar Configuración';

  @override
  String get tasksTabList => 'Lista';

  @override
  String get tasksTabCalendar => 'Calendario';

  @override
  String get tasksFabNew => 'Nueva tarea';

  @override
  String get tasksLoadingMessage => 'Cargando tareas...';

  @override
  String get tasksLoadError => 'No pudimos cargar las tareas.';

  @override
  String get tasksLoadMore => 'Cargar más tareas';

  @override
  String get tasksFilterAll => 'Todas';

  @override
  String get tasksSearchHint => 'Buscar tarea o rutina';

  @override
  String get tasksSearchClearTooltip => 'Limpiar búsqueda';

  @override
  String get tasksSearchActiveLabel => 'Buscando';

  @override
  String get tasksSearchIdleLabel => 'Buscar';

  @override
  String get tasksEmptyTitle => 'No hay tareas configuradas';

  @override
  String get tasksEmptyFilteredTitle => 'No hay tareas con esos filtros';

  @override
  String get tasksEmptySoloSubtitle =>
      'Agregá tu primera tarea para empezar a organizar tu hogar.';

  @override
  String get tasksEmptySharedSubtitle =>
      'Agregá tu primera tarea o activá una categoría para empezar a organizar la casa.';

  @override
  String get tasksEmptyFilteredSubtitle =>
      'Probá cambiar la categoría o crear una nueva tarea.';

  @override
  String get tasksPillNoDate => 'Sin fecha';

  @override
  String get tasksSectionOverdue => 'Vencidas';

  @override
  String get tasksSectionToday => 'Hoy';

  @override
  String get tasksSectionTomorrow => 'Mañana';

  @override
  String get tasksSectionThisWeek => 'Esta semana';

  @override
  String get tasksSectionUpcoming => 'Más adelante';

  @override
  String get tasksSectionNoDate => 'Sin fecha';

  @override
  String get tasksPillOverdue => 'Vencida';

  @override
  String get tasksPillInReview => 'En revisión';

  @override
  String get tasksActionSchedule => 'Programar';

  @override
  String get tasksActionComplete => 'Completar';

  @override
  String get tasksActionCompleting => 'Completando...';

  @override
  String get tasksActionSendForReview => 'Enviar a revisión';

  @override
  String get tasksActionSending => 'Enviando...';

  @override
  String get tasksStatusWaitingForAdult => 'Esperando revisión de un adulto.';

  @override
  String get tasksStatusWaitingReview => 'Esperando revisión.';

  @override
  String tasksStatusBelongsTo(String ownerName) {
    return 'Le toca a $ownerName.';
  }

  @override
  String tasksTakeoverHeading(String ownerName) {
    return 'Esta tarea le toca a $ownerName';
  }

  @override
  String get tasksTakeoverPrompt =>
      '¿Querés darle una mano y completarla de todas formas?';

  @override
  String get tasksTakeoverConfirm => 'Completar igual';

  @override
  String get tasksSnackFrequencyUpdated => 'Frecuencia actualizada';

  @override
  String get tasksSnackCompleted => 'Tarea completada.';

  @override
  String get tasksSnackCompleteError => 'No pudimos completar la tarea.';

  @override
  String get createTaskDifficultyEasy => 'Fácil';

  @override
  String get createTaskDifficultyMedium => 'Media';

  @override
  String get createTaskDifficultyHard => 'Difícil';

  @override
  String get createTaskRecurrenceDaily => 'Diaria';

  @override
  String get createTaskRecurrenceWeekly => 'Semanal';

  @override
  String get createTaskRecurrenceMonthly => 'Mensual';

  @override
  String get createTaskRecurrenceNone => 'Sin repetir';

  @override
  String get createTaskRecurrenceCustom => 'Personalizada';

  @override
  String get createTaskValidationCustomDays =>
      'Elegí al menos un día para la repetición personalizada.';

  @override
  String get createTaskValidationCustomMonthDates =>
      'Elegí al menos una fecha del mes.';

  @override
  String get createTaskValidationInterval =>
      'El intervalo debe ser de al menos 1 día.';

  @override
  String get createTaskValidationTitleRequired => 'Título requerido';

  @override
  String get createTaskValidationNumberRequired => 'Ingresá un número';

  @override
  String get createTaskValidationNotNegative => 'No puede ser negativo';

  @override
  String get createTaskValidationRewardRange =>
      'Usá entre 0 y 50 XP y entre 0 y 5 coins.';

  @override
  String get createTaskSnackCategoryNotReady =>
      'Esperá un momento y elegí una categoría.';

  @override
  String get createTaskSnackDuplicate => 'Ya existe una tarea idéntica activa';

  @override
  String get createTaskSnackCreated => 'Tarea creada';

  @override
  String get createTaskHeaderTitle => 'Nueva tarea';

  @override
  String get createTaskSectionDetailEyebrow => 'DETALLE';

  @override
  String get createTaskSectionDetailTitle => 'Qué hay que hacer';

  @override
  String get createTaskSectionDetailSubtitle =>
      'Ponele un nombre claro para que se entienda de un vistazo.';

  @override
  String get createTaskFieldTitleLabel => 'Qué hay que hacer';

  @override
  String get createTaskFieldNotesLabel => 'Notas (opcional)';

  @override
  String get createTaskSectionCategoryEyebrow => 'CATEGORÍA';

  @override
  String get createTaskSectionCategoryTitle => 'Dónde vive mejor';

  @override
  String get createTaskSectionCategorySubtitle =>
      'Elegí la zona del hogar para que aparezca ordenada.';

  @override
  String get createTaskSectionFrequencyEyebrow => 'FRECUENCIA';

  @override
  String get createTaskSectionFrequencyTitle => 'Cuándo se repite';

  @override
  String get createTaskSectionFrequencySubtitle =>
      'Puede quedar única, repetirse o seguir un patrón propio.';

  @override
  String get createTaskSectionAssigneeEyebrow => 'RESPONSABLE';

  @override
  String get createTaskSectionAssigneeTitle => 'Quién puede hacerla';

  @override
  String get createTaskSectionAssigneeSubtitle =>
      'Podés dejarla abierta o asignarla a alguien en particular.';

  @override
  String get createTaskAssigneeAnyone => 'Cualquiera';

  @override
  String get createTaskSectionValueEyebrow => 'VALOR';

  @override
  String get createTaskSectionValueTitle => 'Cuánto vale completarla';

  @override
  String get createTaskSectionValueSubtitle =>
      'La dificultad define puntos y coins de forma rápida.';

  @override
  String get createTaskRewardsTitle => 'Recompensas';

  @override
  String get createTaskCustomizeRewards => 'Personalizar';

  @override
  String get createTaskFieldCoinsLabel => 'Coins';

  @override
  String get createTaskSectionRotationEyebrow => 'ROTACIÓN';

  @override
  String get createTaskSectionRotationTitle => 'Que se turnen los miembros';

  @override
  String get createTaskSectionRotationSubtitle =>
      'Elegí al menos dos. Cada vez que se complete, le toca al siguiente.';

  @override
  String get createTaskRotationMinimumPeople =>
      'Elegí al menos 2 personas para armar el turno.';

  @override
  String get createTaskCustomTabWeekdays => 'Por día';

  @override
  String get createTaskCustomTabInterval => 'Intervalo';

  @override
  String get createTaskCustomTabMonthDays => 'Fecha';

  @override
  String get createTaskCustomRepeatEvery => 'Repetir cada';

  @override
  String get createTaskCustomDecreaseTooltip => 'Disminuir';

  @override
  String get createTaskCustomIncreaseTooltip => 'Aumentar';

  @override
  String get createTaskCustomMonthDaysHelp => 'Elegí los días del mes';

  @override
  String get createTaskWeekdayMonday => 'L';

  @override
  String get createTaskWeekdayTuesday => 'M';

  @override
  String get createTaskWeekdayWednesday => 'X';

  @override
  String get createTaskWeekdayThursday => 'J';

  @override
  String get createTaskWeekdayFriday => 'V';

  @override
  String get createTaskWeekdaySaturday => 'S';

  @override
  String get createTaskWeekdaySunday => 'D';

  @override
  String get createTaskCreateButton => 'Crear tarea';

  @override
  String get addTaskOptionsHeaderTitle => 'Nueva tarea';

  @override
  String get addTaskOptionsCustomChip => 'Personalizada';

  @override
  String get addTaskOptionsAddTooltip => 'Agregar tarea';

  @override
  String get addTaskOptionsAllSuggestedDone => 'Ya tenés todas las sugeridas';

  @override
  String get addTaskOptionsCreateCustomBelow =>
      'Creá una tarea personalizada abajo.';

  @override
  String get addTaskOptionsLoadMore => 'Cargar más';

  @override
  String addTaskOptionsDone(int count) {
    return 'Listo ($count)';
  }

  @override
  String get completeTaskSnackPickAtLeastOne =>
      'Seleccioná al menos una tarea para completar.';

  @override
  String get completeTaskSnackPickWho =>
      'Seleccioná quién la hizo antes de continuar.';

  @override
  String get completeTaskSnackFutureDate =>
      'La fecha de finalización no puede ser futura.';

  @override
  String get completeTaskSnackTasksMissing =>
      'No pudimos encontrar todas las tareas elegidas. Refrescá e intentá de nuevo.';

  @override
  String get completeTaskHeaderTitle => 'Completar tareas';

  @override
  String get completeTaskHeaderSubtitle =>
      'Marcá lo que ya hicieron y asigná el mérito en un solo paso.';

  @override
  String get completeTaskWhoTitle => '¿Quién lo hizo?';

  @override
  String get completeTaskWhoSubtitle => 'Seleccioná quiénes ayudaron';

  @override
  String get completeTaskWhenTitle => '¿Cuándo?';

  @override
  String get completeTaskWhenSubtitle => 'Elegí el momento de finalización';

  @override
  String get completeTaskTimeNow => 'Ahora';

  @override
  String get completeTaskTimeBefore => 'Antes';

  @override
  String get completeTaskTasksTitle => 'Seleccionar tareas';

  @override
  String get completeTaskTasksSubtitle => 'Buscá y seleccioná lo terminado';

  @override
  String get completeTaskSearchHint => 'Buscar tarea...';

  @override
  String get completeTaskNoTasksAvailable => 'No hay tareas disponibles';

  @override
  String get completeTaskAddPromptTitle => '¿No encontrás la tarea?';

  @override
  String get completeTaskAddPromptButton => 'Agregar nueva tarea';

  @override
  String completeTaskRewardVerb(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ganaron',
      one: 'Ganaste',
    );
    return '$_temp0';
  }

  @override
  String completeTaskMixedApprovalMessage(int count, int xp, int coins) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas pendientes de aprobación',
      one: '1 tarea pendiente de aprobación',
    );
    return '$_temp0, ⭐ $xp XP y $coins Coins!';
  }

  @override
  String completeTaskApprovalOnlyMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas enviadas para aprobación',
      one: '1 tarea enviada para aprobación',
    );
    return '$_temp0';
  }

  @override
  String completeTaskRewardMessage(String verb, int xp, int coins) {
    return '⭐ $verb $xp XP y $coins Coins!';
  }

  @override
  String get editTaskHeaderTitle => 'Editar tarea';

  @override
  String get editTaskHeaderSubtitle =>
      'Actualizá el nombre, la categoría y la recompensa de esta tarea.';

  @override
  String get editTaskFieldNameHint => 'Nombre de la tarea';

  @override
  String get editTaskSectionDetailEyebrow => 'DETALLE';

  @override
  String get editTaskSectionCategoryEyebrow => 'CATEGORÍA';

  @override
  String get editTaskSectionRewardEyebrow => 'RECOMPENSA';

  @override
  String get editTaskSnackNameRequired =>
      'Por favor ingresá un nombre para la tarea';

  @override
  String get editTaskSaveChanges => 'Guardar cambios';

  @override
  String get editTaskCompleteButton => 'Completar tarea';

  @override
  String get editTaskSubmitForReviewButton => 'Enviar a revisión';

  @override
  String get editTaskSnackSentForReview => 'Tarea enviada a revisión.';

  @override
  String get editTaskDeleteTitle => 'Eliminar tarea';

  @override
  String get editTaskDeleteConfirm => 'Eliminar';

  @override
  String get taskDetailHeaderTitle => 'Detalle de tarea';

  @override
  String get taskDetailFallbackUser => 'Alguien';

  @override
  String get taskDetailStatusCompleted => 'Completada';

  @override
  String get taskDetailStatusDisputed => 'En disputa';

  @override
  String get taskDetailStatusPending => 'Pendiente';

  @override
  String get taskDetailUndoButton => 'Deshacer';

  @override
  String get taskDetailUndoErrorNotFound =>
      'No se puede deshacer: actividad no encontrada';

  @override
  String get taskDetailUndoSuccess => 'Tarea devuelta a pendientes.';

  @override
  String get taskDetailUndoError => 'No se pudo deshacer';

  @override
  String get taskDetailNoRecord => 'Sin registro';

  @override
  String get taskDetailExperience => 'Experiencia';

  @override
  String get taskDetailReward => 'Recompensa';

  @override
  String taskDetailCoinsAwarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins',
      one: '1 coin',
    );
    return '+$_temp0';
  }

  @override
  String get taskDetailCompletedBy => 'La completó';

  @override
  String get taskDetailAssignedTo => 'Responsable';

  @override
  String get taskDetailComment => 'Comentario';

  @override
  String get familyDashboardAppBarTitle => 'Familia';

  @override
  String get familyDashboardTitle => 'Vista por miembro';

  @override
  String get familyDashboardLockedNotice =>
      'Esta vista es para administradores de hogares familiares.';

  @override
  String get familyDashboardWeekFilter => 'Semana';

  @override
  String get familyDashboardMonthFilter => 'Mes';

  @override
  String familyDashboardProgress(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      done,
      locale: localeName,
      other: '$done de $total hechas',
      one: '1 de $total hecha',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atrasadas',
      one: '1 atrasada',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardToApproveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count a aprobar',
      one: '1 a aprobar',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardActiveMembers(int active, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active de $total integrantes tienen tareas activas.',
      one: '1 de $total integrante tiene tareas activas.',
    );
    return '$_temp0';
  }

  @override
  String get familyDashboardEmptyWeek => 'Sin tareas esta semana';

  @override
  String get familyDashboardEmptyMonth => 'Sin tareas este mes';

  @override
  String get familyDashboardNoStreak => 'Sin racha';

  @override
  String get familyDashboardTopCategoriesWeek => 'Top categorías de la semana';

  @override
  String get familyDashboardTopCategoriesMonth => 'Top categorías del mes';

  @override
  String get familyDashboardStateNoTasks => 'Sin tareas';

  @override
  String get familyDashboardStateAttention => 'Atención';

  @override
  String get familyDashboardStateToReview => 'A revisar';

  @override
  String get familyDashboardTrackingWeekly => 'Seguimiento semanal';

  @override
  String get familyDashboardTrackingMonthly => 'Seguimiento mensual';

  @override
  String get familyDashboardEmptySubtitleWeek =>
      'Aún no hay tareas para esta semana.';

  @override
  String get familyDashboardEmptySubtitleMonth =>
      'Aún no hay tareas para este mes.';

  @override
  String get familyDashboardLabelDone => 'Hechas';

  @override
  String get familyDashboardLabelPending => 'Pendientes';

  @override
  String get familyDashboardLabelOverdue => 'Atrasadas';

  @override
  String get familyDashboardLabelToReview => 'A revisar';

  @override
  String get familyDashboardLockedTitle => 'Vista por miembro';

  @override
  String get familyDashboardLockedBody =>
      'Activá Modo Padres para ver el progreso de cada integrante de la familia en un solo lugar.';

  @override
  String get familyDashboardEmptyTitle => 'Todavía no hay datos';

  @override
  String get familyDashboardEmptyBody =>
      'Cuando los miembros completen tareas o reciban coins, los vas a ver acá.';

  @override
  String get weeklySummaryAppBarTitle => 'Resumen semanal';

  @override
  String get weeklySummaryLockedNotice =>
      'Esta sección es para administradores de hogares familiares.';

  @override
  String get weeklySummaryHeaderTitle => 'Resumen semanal';

  @override
  String get weeklySummaryTitleAttention => 'Semana con puntos a revisar';

  @override
  String get weeklySummaryTitleGood => 'Buena coordinación';

  @override
  String get weeklySummaryTitleQuietWithExpenses =>
      'Semana tranquila con gastos';

  @override
  String get weeklySummaryTitleQuiet => 'Semana tranquila';

  @override
  String get weeklySummaryBodyExpensesNoTasks =>
      'Hubo gastos compartidos, pero todavía no hubo tareas planificadas.';

  @override
  String get weeklySummaryBodyNoActivity =>
      'Todavía no hubo actividad suficiente para un cierre completo.';

  @override
  String get weeklySummaryNoData => 'Sin datos';

  @override
  String get weeklySummaryMetricTasks => 'Tareas';

  @override
  String get weeklySummaryMetricExpenses => 'Gastos';

  @override
  String get weeklySummaryMetricCompletion => 'Cumpl.';

  @override
  String get weeklySummaryEyebrowCompletion => 'Cumplimiento';

  @override
  String get weeklySummaryEyebrowNeedsBoost => 'Necesita un empujón';

  @override
  String weeklySummaryMvpTitle(String name) {
    return '$name se llevó la semana';
  }

  @override
  String weeklySummaryMvpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completó $count tareas en el hogar.',
      one: 'Completó 1 tarea en el hogar.',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryNeedsBoostTitle(String name) {
    return '$name se quedó con tareas pendientes';
  }

  @override
  String weeklySummaryNeedsBoostSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tareas atrasadas. Quizá esta semana puedas ayudarle a destrabar.',
      one: '1 tarea atrasada. Quizá esta semana puedas ayudarle a destrabar.',
    );
    return '$_temp0';
  }

  @override
  String get weeklySummaryEyebrowMostForgotten => 'La más olvidada';

  @override
  String get weeklySummaryEyebrowExpenses => 'Gastos compartidos';

  @override
  String get weeklySummaryEyebrowTopCategory => 'Top categoría';

  @override
  String get weeklySummaryCompletionEmpty => 'Sin tareas esta semana';

  @override
  String get weeklySummaryCompletionGoodPace =>
      'Buen ritmo: la semana cerró con lo planificado al día.';

  @override
  String get weeklySummaryCompletionLockedBody =>
      'Cuando asignen tareas, acá vas a ver cumplimiento real y comparación semanal.';

  @override
  String get weeklySummaryExpensesNone =>
      'No hubo gastos compartidos esta semana.';

  @override
  String get weeklySummaryExpensesFirst =>
      'Primera semana con gastos compartidos.';

  @override
  String get weeklySummaryExpensesSame => 'Mismo gasto que la semana anterior.';

  @override
  String get weeklySummaryOverdueToday => 'venció hoy';

  @override
  String weeklySummaryOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'venció hace $count días',
      one: 'venció hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryForgottenSubtitle(String overdueLabel) {
    return 'Esta recurrente quedó en el camino — $overdueLabel.';
  }

  @override
  String weeklySummaryExpensesLess(String amount) {
    return 'Gastaron $amount menos que la semana anterior.';
  }

  @override
  String weeklySummaryExpensesMore(String amount) {
    return 'Gastaron $amount más que la semana anterior.';
  }

  @override
  String get weeklySummaryEmptyTitle => 'Tu primer resumen viene en camino';

  @override
  String get weeklySummaryEmptyBody =>
      'Cuando empiecen a completar tareas y cargar gastos vamos a generar el reporte de la semana automáticamente.';

  @override
  String get weeklySummaryLockedTitle => 'Resumen semanal';

  @override
  String get weeklySummaryLockedBody =>
      'Activá Modo Padres para recibir el resumen de la semana con cumplimiento, MVP y gastos.';

  @override
  String get calendarWeekOf => 'Semana de';

  @override
  String get calendarNoTasksScheduled => 'Sin tareas programadas';

  @override
  String get pendingApprovalsAppBarShortTitle => 'Aprobaciones';

  @override
  String get pendingApprovalsAppBarTitle => 'Aprobaciones pendientes';

  @override
  String get pendingApprovalsLockedNotice =>
      'Esta sección es para administradores de hogares familiares.';

  @override
  String pendingApprovalsSubmittedBy(Object name) {
    return 'Enviada por $name';
  }

  @override
  String get pendingApprovalsApproveButton => 'Aprobar';

  @override
  String get pendingApprovalsRejectButton => 'Rechazar';

  @override
  String get pendingApprovalsLoadError =>
      'No pudimos cargar las aprobaciones pendientes.';

  @override
  String pendingApprovalsApprovedSnack(Object coins) {
    return 'Aprobada. Se acreditaron $coins coins.';
  }

  @override
  String get pendingApprovalsApproveErrorRetry =>
      'No pudimos aprobar la tarea. Reintentá.';

  @override
  String get pendingApprovalsRejectedSnack => 'Tarea rechazada.';

  @override
  String get pendingApprovalsRejectErrorRetry =>
      'No pudimos rechazar la tarea. Reintentá.';

  @override
  String get pendingApprovalsRejectDialogTitle => 'Motivo del rechazo';

  @override
  String get pendingApprovalsRejectDialogHint =>
      'Por qué no está aprobada (opcional)';

  @override
  String get pendingApprovalsEmptyTitle => 'Nada pendiente por ahora';

  @override
  String get pendingApprovalsEmptyBody =>
      'Cuando alguien complete una tarea aparecerá acá para que la revises.';

  @override
  String get pendingApprovalsLockedTitle => 'Aprobación de tareas';

  @override
  String get pendingApprovalsLockedBody =>
      'Activá Modo Padres para revisar y aprobar lo que cumple cada miembro del hogar antes de acreditar los coins.';

  @override
  String get expensesTabMovements => 'Movimientos';

  @override
  String get expensesTabRecurring => 'Recurrentes';

  @override
  String get expensesTabGoals => 'Metas';

  @override
  String get expensesFabMovement => 'Movimiento';

  @override
  String get expensesFabNewSubscription => 'Nueva Suscripción';

  @override
  String get expensesFabNewGoal => 'Nueva Meta';

  @override
  String get expensesActivityRecentEyebrow => 'ACTIVIDAD RECIENTE';

  @override
  String get expensesActivityEmpty => 'No hay movimientos recientes';

  @override
  String get expensesDateToday => 'HOY';

  @override
  String get expensesDateYesterday => 'AYER';

  @override
  String get expensesDateTomorrow => 'MAÑANA';

  @override
  String get expensesSummaryMainBalance => 'TU BALANCE ACTUAL';

  @override
  String get expensesSummaryMainProjected => 'TOTAL PREVISTO DEL MES';

  @override
  String get expensesSummaryMainExpenses => 'GASTOS DEL MES';

  @override
  String get expensesStatTileEstimatedIncome => 'Ingreso estimado';

  @override
  String get expensesStatTileIncomes => 'Ingresos';

  @override
  String get expensesStatTilePaid => 'Pagado';

  @override
  String get expensesStatTileExpenses => 'Gastos';

  @override
  String get expensesStatTilePending => 'Pendiente';

  @override
  String get expensesProjectionPendingShare => 'Tu parte pendiente';

  @override
  String get expensesProjectionEstimated => 'Cierre estimado';

  @override
  String get expensesProjectionOwedToYou => 'Te deben';

  @override
  String get expensesProjectionYouOwe => 'Debés';

  @override
  String get expensesProjectionTitle => 'Cálculo de proyección';

  @override
  String get expensesProjectionSubtitle =>
      'Así llegamos a tu cierre estimado para fin de mes.';

  @override
  String get expensesProjectionRowBalance => 'Tu balance actual';

  @override
  String get expensesProjectionRowEstimated => 'Tu cierre estimado';

  @override
  String get expensesPendingDetailsEyebrow => 'DETALLE DE PENDIENTES';

  @override
  String get expensesGotIt => 'Entendido';

  @override
  String get expensesIncomeBreakdownTitle => 'Detalle de Ingresos';

  @override
  String get expensesIncomeBreakdownSubtitle =>
      'Tus ingresos registrados este mes.';

  @override
  String get expensesExpensesBreakdownTitle => 'Detalle de Gastos';

  @override
  String get expensesExpensesBreakdownSubtitle =>
      'Tus gastos pagados este mes.';

  @override
  String get expensesPendingBreakdownTitle => 'Tu Parte Pendiente';

  @override
  String get expensesPendingBreakdownSubtitle =>
      'Lo que te corresponde de los gastos planificados de este mes.';

  @override
  String get expensesPendingBreakdownTotalLabel => 'Tu total pendiente';

  @override
  String get expensesBreakdownTotalLabel => 'Total del mes';

  @override
  String get expensesBreakdownEmpty => 'No hay movimientos registrados';

  @override
  String get expensesBreakdownMovementsEyebrow => 'MOVIMIENTOS';

  @override
  String get budgetsSectionTitle => 'PRESUPUESTOS';

  @override
  String get budgetsManageAction => 'Gestionar';

  @override
  String get budgetsTeaserTitle => 'Presupuestos por categoría';

  @override
  String get budgetsTeaserSubtitle =>
      'Definí topes mensuales y mirá cuánto te queda';

  @override
  String get budgetsEmptyCta => 'Crear tu primer presupuesto';

  @override
  String get budgetsManageTitle => 'Presupuestos';

  @override
  String get budgetsLoadError => 'No pudimos cargar tus presupuestos.';

  @override
  String get budgetsSaveError =>
      'No pudimos guardar el presupuesto. Intentá de nuevo.';

  @override
  String get budgetsDeleteError =>
      'No pudimos eliminar el presupuesto. Intentá de nuevo.';

  @override
  String get expensesPlannedPaymentError =>
      'No pudimos registrar el pago. Intentá de nuevo.';

  @override
  String get expensesPlannedPaymentMembersLoadError =>
      'No pudimos cargar los integrantes.';

  @override
  String get settingsHouseholdCodeGenerateError =>
      'No pudimos generar el código. Intentá de nuevo.';

  @override
  String get budgetsManageSubtitleShared =>
      'Topes mensuales del hogar, visibles para todos.';

  @override
  String get budgetsManageSubtitlePersonal =>
      'Tus topes mensuales, sobre tu parte de los gastos.';

  @override
  String get budgetsManageEmpty => 'Todavía no hay presupuestos.';

  @override
  String get budgetsAddCategory => 'Agregar categoría';

  @override
  String get budgetsNewTitle => 'Nuevo presupuesto';

  @override
  String get budgetsEditTitle => 'Editar presupuesto';

  @override
  String get budgetsCategoryEyebrow => 'CATEGORÍA';

  @override
  String get budgetsLimitEyebrow => 'TOPE MENSUAL';

  @override
  String get budgetsDeleteTitle => '¿Eliminar presupuesto?';

  @override
  String budgetsDeleteBody(String category) {
    return 'Se elimina el tope de $category. Tus gastos no se tocan.';
  }

  @override
  String budgetsRemaining(String amount) {
    return 'Queda $amount';
  }

  @override
  String budgetsOverBy(String amount) {
    return '$amount de más';
  }

  @override
  String budgetsSpentOf(String spent, String limit) {
    return '$spent de $limit';
  }

  @override
  String get financeInsightsTitle => 'Análisis';

  @override
  String get financeInsightsSubtitle => 'Tendencia y presupuestos del mes';

  @override
  String get financeInsightsTooltip => 'Ver análisis';

  @override
  String get trendTitle => 'TENDENCIA · 6 MESES';

  @override
  String trendDeltaDown(int pct, String month) {
    return '$pct% menos que en $month';
  }

  @override
  String trendDeltaUp(int pct, String month) {
    return '$pct% más que en $month';
  }

  @override
  String trendDeltaFlat(String month) {
    return 'Parecido a $month';
  }

  @override
  String get trendCurrentMonthLabel => 'Gasto de este mes';

  @override
  String get exportCsvTooltip => 'Exportar mes (CSV)';

  @override
  String get exportCsvEmpty => 'No hay movimientos este mes para exportar';

  @override
  String exportCsvShareSubject(String month) {
    return 'Finanzas de $month — HomeSync';
  }

  @override
  String get csvHeaderDate => 'Fecha';

  @override
  String get csvHeaderType => 'Tipo';

  @override
  String get csvHeaderTitle => 'Detalle';

  @override
  String get csvHeaderCategory => 'Categoría';

  @override
  String get csvHeaderAmount => 'Monto';

  @override
  String get csvHeaderPayer => 'Pagó';

  @override
  String get csvHeaderSplit => 'División';

  @override
  String get csvTypeExpense => 'Gasto';

  @override
  String get csvTypeIncome => 'Ingreso';

  @override
  String get csvTypeSettlement => 'Liquidación';

  @override
  String subsSuggestionTitle(String title) {
    return '¿\"$title\" es un gasto fijo?';
  }

  @override
  String subsSuggestionBody(String amount) {
    return 'Se repite todos los meses (~$amount). Crealo como recurrente y se agenda solo.';
  }

  @override
  String get subsSuggestionCreate => 'Crear recurrente';

  @override
  String get subsSuggestionDismiss => 'Ahora no';

  @override
  String get goalAutoMenuAction => 'Aporte automático';

  @override
  String get goalAutoTitle => 'Aporte automático';

  @override
  String goalAutoSubtitle(String goal) {
    return 'Todos los meses se agenda un aporte a \"$goal\" que confirmás con un toque.';
  }

  @override
  String get goalAutoAmountEyebrow => 'APORTE MENSUAL';

  @override
  String get goalAutoDayEyebrow => 'DÍA DEL MES';

  @override
  String get goalAutoDisable => 'Desactivar';

  @override
  String get goalAutoSavedSnack => 'Aporte automático activado';

  @override
  String get goalAutoDisabledSnack => 'Aporte automático desactivado';

  @override
  String recapBannerTitle(String month) {
    return 'Tu $month está listo ✨';
  }

  @override
  String get recapBannerSubtitle =>
      'Cuánto se gastó, en qué y cuánto se ahorró.';

  @override
  String recapSheetTitle(String month) {
    return 'Tu $month';
  }

  @override
  String recapMovementsCount(int count) {
    return '$count movimientos registrados';
  }

  @override
  String get recapTotalLabelShared => 'GASTO DEL HOGAR';

  @override
  String get recapTotalLabelPersonal => 'TU PARTE DEL MES';

  @override
  String recapIncomeRow(String amount) {
    return 'Ingresos del mes: $amount';
  }

  @override
  String get recapCategoriesTitle => 'EN QUÉ SE FUE';

  @override
  String get recapPayersTitle => 'QUIÉN PUSO';

  @override
  String get allowanceRepeatToggle => 'Repetir todos los meses';

  @override
  String allowanceActiveScheduleInfo(String amount, int day) {
    return 'Mesada mensual activa: $amount el día $day';
  }

  @override
  String get allowanceScheduleDisable => 'Desactivar';

  @override
  String get allowanceScheduleDisabledSnack => 'Mesada mensual desactivada';

  @override
  String allowanceScheduledSnack(int day) {
    return 'Mesada enviada y programada para el día $day de cada mes';
  }

  @override
  String allowanceScheduleError(String details) {
    return 'No se pudo programar la mesada: $details';
  }

  @override
  String get poolsSectionTitle => 'FONDOS';

  @override
  String get poolsNewAction => 'Nuevo';

  @override
  String get poolsEmptyCta => 'Crear un fondo (asado, viaje, regalo…)';

  @override
  String get poolsCardSettled => 'Saldado ✓';

  @override
  String poolsCardExpenseCount(int count) {
    return '$count movimientos';
  }

  @override
  String get poolsCreateTitle => 'Nuevo fondo';

  @override
  String get poolsCreateSubtitle =>
      'Agrupá los gastos de un evento y saldalo aparte del día a día del piso.';

  @override
  String get poolsCreateNameHint => 'Asado del sábado, Viaje a Córdoba…';

  @override
  String get poolsCreateCta => 'Crear fondo';

  @override
  String get poolsLoadError => 'No pudimos cargar los fondos.';

  @override
  String get poolsCreateError => 'No pudimos crear el fondo. Intentá de nuevo.';

  @override
  String get poolsDetailLoadError => 'No pudimos cargar este fondo.';

  @override
  String get poolsSettleError =>
      'No pudimos registrar el pago. Intentá de nuevo.';

  @override
  String get poolsCloseError => 'No pudimos cerrar el fondo. Intentá de nuevo.';

  @override
  String get poolsDetailNotFound => 'Este fondo ya no existe';

  @override
  String get poolsDetailTotalLabel => 'TOTAL DEL FONDO';

  @override
  String get poolsDetailSettleTitle => 'PARA SALDAR ESTE FONDO';

  @override
  String get poolsDetailAllSettled => 'Fondo saldado — nadie debe nada acá.';

  @override
  String poolsDetailDebtRow(String from, String amount, String to) {
    return '$from le pasa $amount a $to';
  }

  @override
  String get poolsDetailSettleCta => 'Registrar';

  @override
  String get poolsCloseCta => 'Cerrar fondo';

  @override
  String get poolsCloseConfirmTitle => '¿Cerrar este fondo?';

  @override
  String get poolsCloseConfirmBodySettled =>
      'El fondo se archiva y deja de aparecer. Sus movimientos quedan en el historial.';

  @override
  String get poolsCloseConfirmBodyPending =>
      'Quedan cuentas sin saldar: siguen vivas en el balance general del hogar. El fondo se archiva igual.';

  @override
  String poolsClosedSnack(String name) {
    return '\"$name\" cerrado';
  }

  @override
  String get expensesFormSectionPoolEyebrow => 'FONDO';

  @override
  String get expensesFormSectionPoolTitle => '¿Es de un fondo?';

  @override
  String get expensesFormSectionPoolSubtitle =>
      'Sumalo a un evento para verlo agrupado y saldarlo aparte.';

  @override
  String get expensesFormPoolNone => 'Sin fondo';

  @override
  String recapSavingsRow(String type, String amount) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'solo': 'Sumaste $amount a tus metas de ahorro.',
        'other': 'Sumaron $amount a las metas de ahorro.',
      },
    );
    return '$_temp0';
  }

  @override
  String get expensesPlannedSkip => 'Omitir';

  @override
  String expensesPlannedPay(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'Cobrar',
        'other': 'Pagar',
      },
    );
    return '$_temp0';
  }

  @override
  String expensesPlannedPaymentSnack(String type, String title) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'Cobro de \"$title\" registrado',
        'other': 'Pago de \"$title\" registrado',
      },
    );
    return '$_temp0';
  }

  @override
  String get expensesPlannedBadgeUpcoming => 'PRÓXIMO';

  @override
  String get expensesPlannedBadgePending => 'PENDIENTE';

  @override
  String get expensesPlannedBadgeDueToday => 'VENCE HOY';

  @override
  String get expensesPlannedBadgeTomorrow => 'MAÑANA';

  @override
  String get expensesPlannedBadgeSoon => 'VENCE PRONTO';

  @override
  String get expensesDeleteDialogTitle => '¿Eliminar gasto?';

  @override
  String get expensesDeleteDialogBody => 'Esta acción no se puede deshacer.';

  @override
  String get expensesDeletedSnack => 'Movimiento eliminado';

  @override
  String get expensesTypeBadgeGift => 'Regalo';

  @override
  String get expensesTypeBadgeShared => 'Compartido';

  @override
  String get expensesTypeBadgePersonal => 'Personal';

  @override
  String get expensesSettlementCardTitle => 'Liquidación de saldo';

  @override
  String expensesSettlementCardBody(String name) {
    return '$name equilibró el balance';
  }

  @override
  String get expensesEmptyDefaultSubtitle =>
      'Empezá hoy mismo a organizar tus finanzas del hogar.';

  @override
  String get expensesFormOcrDuplicate =>
      'Este ticket ya fue escaneado hace poco. Revisá que no cargues el gasto dos veces.';

  @override
  String get expensesFormOcrLowConfidence =>
      'Ticket difícil de leer; revisá los datos antes de guardar';

  @override
  String get expensesFormOcrRateLimited =>
      'Demasiados escaneos seguidos. Esperá unos segundos y volvé a intentar.';

  @override
  String expensesFormOcrImageTooLarge(String sizeMb) {
    return 'La imagen es demasiado grande ($sizeMb MB, máx 5 MB). Probá con otra foto o desde la galería.';
  }

  @override
  String get expensesFormOcrSessionExpired =>
      'Sesión expirada. Iniciá sesión nuevamente para escanear.';

  @override
  String get expensesFormOcrTimeout =>
      'El escaneo tardó demasiado. Revisá tu conexión y volvé a intentar.';

  @override
  String get expensesFormOcrFailed =>
      'No pudimos leer el ticket. Probá con más luz y con el ticket entero en la foto.';

  @override
  String get expensesFormOcrDailyLimit =>
      'Llegaste al límite de escaneos por hoy. Podés cargar el gasto a mano.';

  @override
  String get expensesFormOcrAmountMismatch =>
      'El total no coincide con la suma de los productos. Revisá el monto antes de guardar.';

  @override
  String expensesFormOcrPossibleDuplicate(String title, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Ya cargaste «$title» por este monto el $dateString. Revisá que no sea el mismo gasto.';
  }

  @override
  String get expensesFormValidationAmountRequired => 'Ingresá un monto válido.';

  @override
  String get expensesFormValidationNoHousehold => 'No pertenecés a un hogar';

  @override
  String get expensesFormSavedIncome => 'Ingreso guardado';

  @override
  String get expensesFormSavedExpense => 'Gasto guardado';

  @override
  String get expensesFormUpdatedExpense => 'Gasto actualizado';

  @override
  String get plannedExpensePaymentConfirmButton => 'Confirmar y registrar';

  @override
  String get expensesFormDeleteDialogTitle => '¿Eliminar gasto?';

  @override
  String get expensesFormDeleteDialogBody =>
      'Esta acción no se puede deshacer.';

  @override
  String get expensesFormSectionDetailEyebrow => 'DETALLE';

  @override
  String get expensesFormSectionDetailTitleIncome => '¿De dónde viene?';

  @override
  String get expensesFormSectionDetailTitleExpense => '¿Qué estás registrando?';

  @override
  String get expensesFormSectionDetailSubtitleIncome =>
      'Podés dejar un nombre claro para reconocer este ingreso más rápido.';

  @override
  String get expensesFormSectionDetailSubtitleExpense =>
      'Dale un nombre simple para ubicar este gasto de un vistazo.';

  @override
  String get expensesFormSectionContextEyebrow => 'CONTEXTO';

  @override
  String get expensesFormSectionContextTitleIncome =>
      'Cuándo y quién lo recibió';

  @override
  String get expensesFormSectionContextTitleExpense => 'Cuándo y quién pagó';

  @override
  String get expensesFormSectionContextSubtitle =>
      'Estos datos ordenan el movimiento dentro del hogar.';

  @override
  String get expensesFormSectionCategoryEyebrow => 'CATEGORÍA';

  @override
  String get expensesFormSectionCategoryTitleIncome =>
      'Cómo querés clasificarlo';

  @override
  String get expensesFormSectionCategoryTitleExpense =>
      'Dónde entra este gasto';

  @override
  String get expensesFormSectionCategorySubtitle =>
      'Podés elegirla, pero también la sugerimos automáticamente según cómo lo describas.';

  @override
  String get expensesFormSectionSplitEyebrow => 'REPARTO';

  @override
  String get expensesFormSectionSplitTitleIncome =>
      'Cómo se reparte este ingreso';

  @override
  String get expensesFormSectionSplitTitleExpense =>
      'Cómo se divide este gasto';

  @override
  String get expensesFormSectionSplitSubtitle =>
      'Definí si es compartido, fijo, regalo o personal.';

  @override
  String get expensesFormFieldDate => 'Fecha';

  @override
  String get expensesFormFieldPayer => 'Pagó';

  @override
  String get expensesFormFieldCategory => 'Categoría';

  @override
  String get expensesFormShoppingUnlinkedSnack => 'Vinculaciones removidas';

  @override
  String get expensesFormShoppingUnlinkedUndo => 'Deshacer';

  @override
  String get expensesFormSplitShared => 'Compartido';

  @override
  String get expensesFormSplit5050 => '50/50';

  @override
  String get expensesFormSplitFixed => 'Fijo';

  @override
  String get expensesFormSplitGift => 'Regalo';

  @override
  String get expensesFormSplitPersonal => 'Solo yo';

  @override
  String expensesFormInfoBoxGift(String memberLabel) {
    return 'Este gasto no afectará el balance $memberLabel.';
  }

  @override
  String get expensesFormInfoBoxPersonal => 'Registrado como gasto personal.';

  @override
  String get expensesFormSaveButtonUpdated => 'Actualizado';

  @override
  String get expensesFormSaveButtonSaveIncome => 'Guardar ingreso';

  @override
  String get expensesFormSaveButtonSaveExpense => 'Guardar gasto';

  @override
  String get expensesFormMembersEmpty =>
      'No hay miembros disponibles para registrar gastos.';

  @override
  String get expensesFormTitleHintIncome => '¿De qué es el ingreso? (Opcional)';

  @override
  String get expensesFormTitleHintExpense => '¿Qué compraste? (Opcional)';

  @override
  String get expensesFormTypeExpense => 'Gasto';

  @override
  String get expensesFormTypeIncome => 'Ingreso';

  @override
  String get expensesFormHeaderEditIncome => 'Modificar Ingreso';

  @override
  String get expensesFormHeaderEditExpense => 'Modificar Gasto';

  @override
  String get expensesFormHeaderNewIncome => 'Nuevo Ingreso';

  @override
  String get expensesFormHeaderNewExpense => 'Nuevo Gasto';

  @override
  String get allowanceEntryTitle => 'Dar mesada';

  @override
  String get allowanceSheetTitle => 'Dar mesada';

  @override
  String get allowanceSheetSubtitle =>
      'Elegí destinatario y monto. Se registra como ingreso personal.';

  @override
  String get allowanceRecipientLabel => 'Para';

  @override
  String get allowanceAmountLabel => 'Monto';

  @override
  String get allowanceNoteHint => 'Nota opcional, ej: Mesada de junio';

  @override
  String get allowanceSubmitButton => 'Enviar mesada';

  @override
  String get allowanceNoRecipients =>
      'No hay adolescentes con finanzas personales en este hogar.';

  @override
  String get allowanceRecipientRequired => 'Elegí a quién darle la mesada.';

  @override
  String get allowanceAmountInvalid => 'Ingresá un monto válido.';

  @override
  String get allowanceSendGenericError => 'No se pudo enviar la mesada.';

  @override
  String get allowanceMembersLoadError =>
      'No pudimos cargar los destinatarios.';

  @override
  String get allowanceSentScheduleFailed =>
      'La mesada se envió, pero no pudimos programar la repetición.';

  @override
  String get allowanceScheduleDisableError =>
      'No pudimos desactivar la mesada programada. Intentá de nuevo.';

  @override
  String get allowanceSentSnack => 'Mesada enviada.';

  @override
  String allowanceSendError(String error) {
    return 'Error al enviar la mesada: $error';
  }

  @override
  String get expensesFormSelectCategoryTitle => 'Seleccionar categoría';

  @override
  String get expensesFormAutoTitleSupermarketShopping =>
      'Compras del supermercado';

  @override
  String expensesFormShoppingSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos comprados',
      one: '1 artículo comprado',
    );
    return '$_temp0';
  }

  @override
  String get expensesFormShoppingDetectedTitle => 'Productos detectados';

  @override
  String get expensesFormShoppingLinkTitle => 'Vincular con lista de compras';

  @override
  String expensesFormShoppingDetectedSummary(int linkedCount, int newCount) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedCount,
      locale: localeName,
      other: '$linkedCount artículos',
      one: '1 artículo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      newCount,
      locale: localeName,
      other: '$newCount nuevos para tu lista',
      one: '1 nuevo para tu lista',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get expensesFormShoppingWillMarkBought =>
      'Se marcarán como comprados al guardar';

  @override
  String get expensesFormShoppingPreparingProducts => 'Preparando productos...';

  @override
  String get expensesFormShoppingTapToLink => 'Tocá para vincular artículos';

  @override
  String get expensesFormShoppingClearAllSemantic =>
      'Quitar todas las vinculaciones';

  @override
  String expensesFormShoppingDetectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos detectados',
      one: '1 producto detectado',
    );
    return '$_temp0';
  }

  @override
  String get expensesFormShoppingBadgeNew => 'nuevo';

  @override
  String get expensesFormShoppingItemsSheetTitle => 'Artículos de la lista';

  @override
  String get expensesFormShoppingSearchHint => 'Buscar o agregar producto...';

  @override
  String expensesFormShoppingAddQuery(String query) {
    return 'Agregar \"$query\"';
  }

  @override
  String get expensesFormShoppingCustomProduct => 'Producto personalizado';

  @override
  String get expensesFormShoppingGlobalSuggestions => 'Sugerencias globales';

  @override
  String get expensesFormCategorySupermarket => 'Supermercado';

  @override
  String get expensesFormCategoryUtilities => 'Servicios';

  @override
  String get expensesFormCategoryRent => 'Alquiler y hogar';

  @override
  String get expensesFormCategoryRestaurants => 'Salidas y comidas';

  @override
  String get expensesFormCategoryTransport => 'Transporte';

  @override
  String get expensesFormCategoryEntertainment => 'Ocio y planes';

  @override
  String get expensesFormCategoryHealth => 'Salud';

  @override
  String get expensesFormCategoryFinances => 'Ahorro e inversión';

  @override
  String get expensesFormCategorySettlement => 'Liquidación de balance';

  @override
  String get expensesFormCategoryOnlineShopping => 'Compras online';

  @override
  String get expensesFormCategoryPets => 'Mascotas';

  @override
  String get expensesFormCategoryClothing => 'Ropa y calzado';

  @override
  String get expensesFormCategoryElectronics => 'Tecnología';

  @override
  String get expensesFormCategoryEducation => 'Educación';

  @override
  String get expensesFormCategoryOtherExpenses => 'Otros gastos';

  @override
  String get expensesFormIncomeCategorySalary => 'Sueldo';

  @override
  String get expensesFormIncomeCategoryFreelance => 'Freelance';

  @override
  String get expensesFormIncomeCategorySales => 'Ventas';

  @override
  String get expensesFormIncomeCategoryBonus => 'Bono o premio';

  @override
  String get expensesFormIncomeCategoryRefund => 'Reembolso';

  @override
  String get expensesFormIncomeCategoryGift => 'Regalo';

  @override
  String get expensesFormIncomeCategoryInvestment => 'Rendimiento';

  @override
  String get expensesFormIncomeCategoryOtherIncome => 'Otros ingresos';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsMarkAllReadTooltip => 'Marcar todo como leído';

  @override
  String get notificationsEmptyTitle => 'Sin notificaciones';

  @override
  String get notificationsEmptySubtitle => 'Estás al día';

  @override
  String get notificationsErrorTitle => 'No pudimos cargar tus notificaciones';

  @override
  String get notificationsErrorSubtitle =>
      'Deslizá hacia abajo para reintentar';

  @override
  String get premiumPaywallCloseTooltip => 'Cerrar';

  @override
  String get premiumPaywallEyebrow => 'HomeSync Premium';

  @override
  String premiumPaywallEyebrowFor(String name) {
    return 'Premium · $name';
  }

  @override
  String premiumPaywallCoupleNames(String first, String second) {
    return '$first y $second';
  }

  @override
  String premiumPaywallTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Un solo plan para los dos',
        'family': 'Un solo plan para toda la familia',
        'friends': 'Un solo plan para toda la casa',
        'other': 'Automatizá tu hogar sin cargar dos veces',
      },
    );
    return '$_temp0';
  }

  @override
  String premiumPaywallSubtitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple':
            'Paga uno y lo usan los dos: pagos, compras y presupuestos trabajando juntos.',
        'family':
            'Paga uno y lo usa toda la familia, también quienes se sumen después.',
        'friends':
            'Paga uno y lo usan todos en la casa, también quienes se sumen después.',
        'other':
            'Pagos, compras y presupuestos trabajando juntos para que el balance esté siempre claro.',
      },
    );
    return '$_temp0';
  }

  @override
  String get premiumBenefitRecurringPayments => 'Pagos recurrentes';

  @override
  String get premiumBenefitRecurringPaymentsDesc =>
      'Programá suscripciones, servicios y cuotas para que se repitan solas y no se pierdan en el mes.';

  @override
  String get premiumBenefitShoppingFinanceSync =>
      'Compras conectadas a Finanzas';

  @override
  String get premiumBenefitShoppingFinanceSyncDesc =>
      'Vinculá productos de la lista con gastos reales y evitá cargar la misma compra dos veces.';

  @override
  String get premiumBenefitFullCustomization => 'Personalización completa';

  @override
  String get premiumBenefitFullCustomizationDesc =>
      'Elegí colores, temas y avatares personalizados para que el hogar se sienta propio.';

  @override
  String get premiumRestorePurchases => 'Restaurar compras';

  @override
  String get premiumCancelAnytime => 'Cancelá cuando quieras';

  @override
  String premiumSavePercent(int percent) {
    return 'Ahorrá $percent%';
  }

  @override
  String get premiumChoosePlanTitle => 'Elegí tu plan';

  @override
  String get premiumAnnualPlan => 'Anual';

  @override
  String get premiumMonthlyPlan => 'Mensual';

  @override
  String get premiumBestValueBadge => 'Mejor valor';

  @override
  String get premiumBilledAnnually => 'Facturado una vez al año';

  @override
  String get premiumBilledMonthly => 'Se renueva mes a mes';

  @override
  String premiumMonthlyEquivalent(String price) {
    return '$price/mes';
  }

  @override
  String premiumActivateAnnualCta(String price) {
    return 'Activar Premium · $price/año';
  }

  @override
  String premiumActivateMonthlyCta(String price) {
    return 'Activar Premium · $price/mes';
  }

  @override
  String get premiumLegalTerms => 'Términos';

  @override
  String get premiumLegalPrivacy => 'Privacidad';

  @override
  String get premiumAlreadyActiveTitle => 'Premium activo en tu hogar';

  @override
  String get premiumAlreadyActiveBody =>
      'Todo listo: las funciones premium ya están disponibles para este hogar.';

  @override
  String get premiumActiveStatusPill => 'Plan activo';

  @override
  String get premiumActiveBenefitsTitle => 'Beneficios habilitados';

  @override
  String get premiumContinueButton => 'Continuar';

  @override
  String get premiumDeactivateTesting => 'Desactivar Premium (testing)';

  @override
  String get premiumStoreErrorTitle => 'No pudimos conectar con la tienda';

  @override
  String get premiumDeveloperModeButton =>
      'Modo Desarrollador: Activar Premium';

  @override
  String get faqSheetTitle => 'Preguntas Frecuentes';

  @override
  String get faqSheetSubtitle => 'Ayuda pensada para tu hogar';

  @override
  String get faqSearchHint => 'Buscá una pregunta...';

  @override
  String get faqSearchEmpty =>
      'No encontramos nada con esa búsqueda. Probá con otra palabra o contanos desde “Enviar feedback”.';

  @override
  String faqContextPill(String label) {
    return 'Ayuda para: $label';
  }

  @override
  String get faqCatHousehold => 'Tu hogar';

  @override
  String get faqCatTasks => 'Tareas';

  @override
  String get faqCatRewards => 'Puntos y premios';

  @override
  String get faqCatFinances => 'Finanzas';

  @override
  String get faqCatApp => 'La app y tu cuenta';

  @override
  String get faqHowSharedHome => '¿Cómo funciona mi hogar en HomeSync?';

  @override
  String faqHowSharedHomeAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple':
            'Vos y tu pareja comparten un mismo hogar digital: tareas, gastos, lista de compras y ahorros viven en un solo lugar y se sincronizan al instante. Lo que carga uno, el otro lo ve al toque.',
        'family':
            'Toda la familia comparte un mismo hogar digital. Cada miembro tiene su rol (padre, madre, tutor/a, adolescente o hijo/a) y la app adapta lo que cada uno ve y puede hacer: los adultos administran, los chicos suman completando tareas.',
        'friends':
            'Quienes conviven comparten tareas, gastos y compras en un solo lugar, entre pares: sin jerarquías ni premios infantiles, solo un reparto claro de lo que cada uno aporta.',
        'solo':
            'Tu hogar es tu espacio personal: organizás tus tareas, tus gastos y tu lista de compras a tu ritmo. Si más adelante convivís con alguien, lo invitás con un código y listo.',
        'other':
            'Comparten un mismo hogar digital: tareas, gastos, compras y ahorros sincronizados al instante entre todos los miembros.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqInviteMembers => '¿Cómo invito a alguien a mi hogar?';

  @override
  String faqInviteMembersAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family':
            'En Configuración está el código de invitación de tu hogar: compartilo y, al ingresarlo en su app, esa persona entra con todo sincronizado. Después, desde la lista de miembros, los adultos le asignan su rol (padre, madre, tutor/a, adolescente o hijo/a).',
        'other':
            'En Configuración está el código de invitación de tu hogar: compartilo con quien quieras sumar y, al ingresarlo en su app, entra directo con tareas, gastos y compras sincronizados.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqFamilyRoles => '¿Qué significan los roles de la familia?';

  @override
  String get faqFamilyRolesAnswer =>
      'Padre, madre y tutor/a son los adultos: administran el hogar, aprueban tareas, manejan las finanzas compartidas y la tienda de premios. Los adolescentes tienen más autonomía y su propio espacio de finanzas personales. Los hijos e hijas viven la experiencia más simple y divertida: completan tareas, juntan coins y canjean premios.';

  @override
  String get faqWhoSeesWhat => '¿Qué ve cada miembro del hogar?';

  @override
  String get faqWhoSeesWhatAnswer =>
      'Cada rol ve lo que le corresponde: los adultos ven todo, incluidas las finanzas compartidas; los adolescentes ven sus finanzas personales pero no los gastos de los adultos; y los hijos/as no ven finanzas — su mundo son las tareas, los puntos y los premios.';

  @override
  String get faqTasksBasics => '¿Cómo funcionan las tareas?';

  @override
  String get faqTasksBasicsAnswer =>
      'Creá tareas puntuales o recurrentes (diarias, semanales, mensuales), asignalas a alguien o dejalas libres para quien las agarre. El calendario muestra lo que viene y las recurrentes se reprograman solas. En Pareja, completarlas actualiza el progreso compartido sin XP ni coins.';

  @override
  String get faqApprovals => '¿Cómo funcionan las aprobaciones de tareas?';

  @override
  String faqApprovalsAnswer(String role) {
    String _temp0 = intl.Intl.selectLogic(
      role,
      {
        'parent':
            'Cuando un hijo/a o adolescente marca una tarea como hecha, queda pendiente de tu aprobación: la revisás desde Aprobaciones y, al confirmarla, recién ahí se acreditan los XP y coins. Quién necesita aprobación se ajusta en la configuración del hogar.',
        'teen':
            'Según cómo esté configurado el hogar, al marcar una tarea como hecha puede quedar pendiente hasta que un adulto la confirme. Recién ahí se te acreditan los XP y coins.',
        'child':
            'Cuando marcás una tarea como hecha, un adulto la revisa y la confirma. ¡Apenas la apruebe te llegan los XP y los coins!',
        'other':
            'Las tareas de hijos/as y adolescentes pueden requerir la confirmación de un adulto antes de acreditar XP y coins, según la configuración del hogar.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqHowEarnXp => '¿Cómo gano XP y subo de nivel?';

  @override
  String get faqHowEarnXpAnswer =>
      'Cada tarea completada suma XP (las más difíciles dan más). Con el XP subís de nivel y desbloqueás logros: medallas por hitos como completar 50 tareas. Todo tu progreso se ve en Estadísticas.';

  @override
  String get faqWhatCoins => '¿Para qué sirven los Coins?';

  @override
  String faqWhatCoinsAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family':
            'Los coins son la moneda del hogar: los chicos los ganan completando tareas y los canjean en la tienda de premios por las recompensas que crearon los adultos — una salida, tiempo de pantalla, su comida favorita.',
        'other':
            'En modo Pareja no se usan coins: las tareas muestran cómo se reparte el trabajo y las propuestas se conversan sin precio, deuda ni obligación. Los coins quedan reservados para la dinámica familiar con chicos.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqWhatWeeklyDuels => '¿Hay un duelo semanal en Pareja?';

  @override
  String get faqWhatWeeklyDuelsAnswer =>
      'No. En modo Pareja la semana se mira como un esfuerzo compartido: pueden ver cuántas tareas hicieron y cómo se repartieron, sin ganador, marcador ni bonus.';

  @override
  String get faqFamilyRanking => '¿Cómo funciona el ranking familiar?';

  @override
  String get faqFamilyRankingAnswer =>
      'Cada semana la familia compite sano: el ranking muestra quién sumó más XP completando tareas. Al cierre hay un ganador con corona y bonus, y el resumen semanal les cuenta cómo le fue a cada uno.';

  @override
  String get faqWhatSpecialEvents => '¿Qué hay en la pestaña Pareja?';

  @override
  String get faqWhatSpecialEventsAnswer =>
      'Es el repaso de la semana de los dos: cómo se repartieron las tareas (sin ganadores), cómo está la plata entre ustedes y las propuestas pendientes. Si algo cayó siempre del mismo lado, te sugiere proponer turnarse. También podés mandarle una nota a tu pareja.';

  @override
  String get faqContributionBalance => '¿Qué es el equilibrio de aporte?';

  @override
  String get faqContributionBalanceAnswer =>
      'Es la foto neutral del mes: combina tareas hechas y gastos compartidos para mostrar cuánto viene aportando cada uno a la convivencia. Sin ganadores ni perdedores — sirve para charlar con datos, no para competir.';

  @override
  String get faqRewardsStore => '¿Cómo funciona la tienda de premios?';

  @override
  String faqRewardsStoreAnswer(String role) {
    String _temp0 = intl.Intl.selectLogic(
      role,
      {
        'parent':
            'Vos creás los premios (una salida, tiempo de juego, su postre favorito) y les ponés un precio en coins. Los chicos los canjean con lo que ganaron completando tareas, y vos confirmás el canje.',
        'other':
            'En la tienda están los premios que crearon los adultos del hogar. Juntá coins completando tareas y canjealos cuando te alcance: el premio queda pendiente hasta que un adulto lo confirme.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqHowFinancesWork => '¿Cómo funcionan las finanzas?';

  @override
  String faqHowFinancesWorkAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'friends':
            'Cada gasto compartido se divide según lo que configuren (partes iguales o porcentajes). El balance muestra quién está al día y quién debe, y cualquiera puede registrar un pago para saldar cuentas.',
        'family':
            'Las finanzas compartidas son territorio de los adultos: los gastos del hogar se dividen entre ellos. Los adolescentes tienen su espacio personal de finanzas, separado de las cuentas grandes.',
        'other':
            'Registrás gastos reales y también anticipás gastos que todavía no pagaste. Los confirmados afectan el balance real entre ustedes; los pendientes sirven de recordatorio y proyección, pero no cambian la deuda hasta que se paguen.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqHowRecurringCount =>
      '¿Cómo cuentan los recurrentes y el balance estimado?';

  @override
  String get faqHowRecurringCountAnswer =>
      'Un gasto recurrente nuevo arranca desde su primera fecha válida. Si lo creás antes o en la fecha de vencimiento, puede contar este mes; si lo creás después, arranca en el próximo ciclo. “Tu parte pendiente” muestra solo lo que te corresponde según la división, y “Balance estimado” usa tu balance actual menos esa parte pendiente.';

  @override
  String get faqWhoCanPay => '¿Quién puede registrar un pago?';

  @override
  String get faqWhoCanPayAnswer =>
      'Cualquiera de los dos lados puede registrar un pago compartido, incluso en nombre del otro — útil cuando uno paga y el otro lo carga. “Pagado” y “Pendiente” muestran siempre el total del hogar, así todos ven la misma foto.';

  @override
  String get faqSavingsGoals => '¿Cómo funcionan las metas de ahorro?';

  @override
  String get faqSavingsGoalsAnswer =>
      'Creás una meta con su monto objetivo (un viaje, un fondo de emergencia) y vas registrando aportes. El progreso se ve clarito y, en hogares compartidos, todos pueden aportar a la misma meta.';

  @override
  String get faqPremium => '¿Qué incluye HomeSync Premium?';

  @override
  String get faqPremiumAnswer =>
      'Premium se activa para todo el hogar con una sola compra: mascotas premium animadas, colores de tema exclusivos y todo lo que vayamos sumando. Se gestiona desde Configuración y solo los adultos pueden comprarlo.';

  @override
  String get faqCustomization => '¿Puedo personalizar la app?';

  @override
  String get faqCustomizationAnswer =>
      'Sí: tema claro, oscuro o automático según el sistema, color principal (con Premium), idioma (español o inglés) y la moneda en que se muestran las finanzas. Todo desde Configuración → Apariencia.';

  @override
  String get faqNotifications => '¿Qué notificaciones llegan?';

  @override
  String get faqNotificationsAnswer =>
      'Avisos de lo que pasa en tu hogar: tareas que te asignan, novedades de gastos y aprobaciones pendientes. Podés activarlas o silenciarlas desde Configuración → Notificaciones.';

  @override
  String get faqAccountSafety => '¿Cómo cuido mi cuenta y mis datos?';

  @override
  String get faqAccountSafetyAnswer =>
      'Tu sesión es personal: cerrala cuando quieras desde Configuración. Si necesitás empezar de cero, “Reiniciar datos” borra el contenido del hogar, y “Eliminar mi cuenta” la elimina definitivamente. Tus datos viven cifrados en la nube y solo los miembros de tu hogar ven lo que comparten.';

  @override
  String get feedbackThanksBug => '¡Gracias por reportarlo!';

  @override
  String get feedbackThanksSuggestion => '¡Gracias por la idea!';

  @override
  String get feedbackReviewBug => 'Lo vamos a revisar en breve.';

  @override
  String get feedbackConsiderSuggestion => 'Lo vamos a tener en cuenta.';

  @override
  String get feedbackSendError => 'No se pudo enviar. Intentá de nuevo.';

  @override
  String get feedbackBugTitlePlaceholder => '¿Qué pasó?';

  @override
  String get feedbackSuggestionTitlePlaceholder => '¿Qué mejorarías?';

  @override
  String get feedbackBugHint => 'Ej: La pantalla de gastos no carga';

  @override
  String get feedbackSuggestionHint => 'Ej: Filtrar tareas por semana';

  @override
  String get feedbackBugDescHint =>
      'Descripción opcional: pasos para reproducirlo, qué esperabas ver...';

  @override
  String get feedbackSuggestionDescHint =>
      'Descripción opcional: contexto, por qué sería útil...';

  @override
  String get feedbackEmailResponseTitle => 'Quiero recibir respuesta por mail';

  @override
  String get feedbackEmailResponseSubtitle =>
      'Te escribiremos a tu correo si necesitamos más contexto o tenemos novedades.';

  @override
  String get feedbackSendBugReport => 'Enviar reporte';

  @override
  String get feedbackSendSuggestion => 'Enviar sugerencia';

  @override
  String get feedbackReportErrorOption => 'Reportar error';

  @override
  String get feedbackSuggestImprovementOption => 'Sugerir mejora';

  @override
  String get membersTitle => 'Miembros';

  @override
  String membersSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas en tu hogar',
      one: '1 persona en tu hogar',
    );
    return '$_temp0';
  }

  @override
  String get membersAdminBadge => 'Admin';

  @override
  String membersRolePickerTitle(String memberName) {
    return 'Rol de $memberName';
  }

  @override
  String get membersRolePickerSubtitle =>
      'Padres y tutores pueden aprobar tareas. Adolescentes y chicos envían sus tareas para revisión.';

  @override
  String get membersRoleParent => 'Padre/Madre';

  @override
  String get membersRoleGuardian => 'Tutor/a';

  @override
  String get membersRoleTeen => 'Adolescente';

  @override
  String get membersRoleChild => 'Chico/a';

  @override
  String get membersRoleFather => 'Padre';

  @override
  String get membersRoleMother => 'Madre';

  @override
  String get membersRoleDad => 'Papá';

  @override
  String get membersRoleMom => 'Mamá';

  @override
  String get membersRoleGuardianMale => 'Tutor';

  @override
  String get membersRoleGuardianFemale => 'Tutora';

  @override
  String get membersRoleSon => 'Hijo';

  @override
  String get membersRoleDaughter => 'Hija';

  @override
  String get membersRoleParentGuardianDesc =>
      'Aprueba tareas, administra el hogar.';

  @override
  String get membersRoleTeenDesc =>
      'Crea sus tareas, pero las completa bajo revisión.';

  @override
  String get membersRoleChildDesc =>
      'Solo completa sus tareas, siempre bajo revisión.';

  @override
  String get membersRoleUpdateError =>
      'No pudimos cambiar el rol. Intentá de nuevo.';

  @override
  String get membersRoleUpdated => 'Rol actualizado';

  @override
  String get membersLoadError => 'No pudimos cargar los integrantes del hogar.';

  @override
  String get setupCreateHouseholdError =>
      'No pudimos crear el hogar o generar el código. Intentá de nuevo.';

  @override
  String get setupJoinCodeLengthError => 'El código debe tener 6 caracteres.';

  @override
  String get setupJoinHouseholdError =>
      'No pudimos unirte al hogar. Revisá el código e intentá de nuevo.';

  @override
  String get setupCompleteError =>
      'No pudimos terminar la configuración. Intentá de nuevo.';

  @override
  String get membersInviteTitle => 'Invitar miembro';

  @override
  String get membersInviteSubtitle =>
      'Agregá otra persona al hogar con un código de invitación.';

  @override
  String get shoppingSearchHint => 'Necesito...';

  @override
  String get shoppingListTitle => 'Lista actual';

  @override
  String get shoppingAllDone => 'Todo listo';

  @override
  String get shoppingListResolved => 'Lista resuelta';

  @override
  String get shoppingEmptyFirstLineDone =>
      'La lista está vacía.\n¿Qué falta en casa?';

  @override
  String get shoppingEmptyFirstLineBought =>
      'Todo comprado.\n¿Querés agregar algo más?';

  @override
  String get shoppingEmptyHint =>
      'Agregá productos usando las categorías\no la barra de búsqueda abajo.';

  @override
  String get shoppingRecentSection => 'Comprar de nuevo';

  @override
  String get shoppingCategoriesSection => 'Categorías';

  @override
  String shoppingProductsBought(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString artículos comprados',
      one: '1 artículo comprado',
    );
    return '$_temp0';
  }

  @override
  String get shoppingScanReceipt => 'Escanear ticket y registrar gasto';

  @override
  String get shoppingItemNameHint => 'Nombre del producto';

  @override
  String get shoppingDeleteTooltip => 'Eliminar';

  @override
  String get shoppingCategoryLabel => 'Categoría';

  @override
  String get shoppingAddToList => 'Agregar a la lista';

  @override
  String get shoppingSaveChanges => 'Guardar cambios';

  @override
  String get rewardsTabDuel => 'Duelo';

  @override
  String get rewardsTabPrizes => 'Premios';

  @override
  String get rewardsLoadMore => 'Cargar más';

  @override
  String get rewardsLoading => 'Cargando premios...';

  @override
  String rewardsLoadError(String error) {
    return 'No pudimos cargar premios.\n$error';
  }

  @override
  String get rewardsProposalsSection => 'Propuestas';

  @override
  String get rewardsPendingApproval =>
      'Deseos pendientes de aprobación. Tocá una propuesta para revisarla.';

  @override
  String get rewardsStatusPending => 'Pendiente';

  @override
  String get rewardsStatusReview => 'Revisar';

  @override
  String get rewardsPendingRedemptionsTitle => 'Canjes por entregar';

  @override
  String get rewardsPendingRedemptionsSubtitle =>
      'Premios ya canjeados que faltan entregar.';

  @override
  String rewardsRedeemedByOn(String name, String date) {
    return 'Canjeado por $name · $date';
  }

  @override
  String rewardsRedeemedByYouOn(String date) {
    return 'Lo canjeaste el $date';
  }

  @override
  String get rewardsWaitingFulfillment => 'En camino';

  @override
  String get rewardsMarkFulfilled => 'Entregado';

  @override
  String get rewardsFulfillConfirmTitle => '¿Premio entregado?';

  @override
  String rewardsFulfillConfirmBody(String title, String name) {
    return 'Vas a marcar \"$title\" como entregado para $name.';
  }

  @override
  String rewardsFulfilledSnack(String title) {
    return 'Marcaste \"$title\" como entregado.';
  }

  @override
  String get rewardsMemberFallbackName => 'Miembro';

  @override
  String get rewardsWaitingPartnerDecision =>
      'Esperando una decisión de tu pareja.';

  @override
  String rewardsCoinsAvailable(int count) {
    return '$count coins disponibles';
  }

  @override
  String rewardsCoinsAvailableShort(int count) {
    return '$count coins';
  }

  @override
  String get rewardsCoinsAvailableToRedeem => 'Disponibles para canjear ahora';

  @override
  String get rewardsBalance => 'Saldo';

  @override
  String get rewardsDeleteTooltip => 'Eliminar recompensa';

  @override
  String get rewardsEmptyBoutique => 'Boutique vacía';

  @override
  String get rewardsEmptyNoPrizes =>
      'Todavía no hay premios cargados en esta casa.';

  @override
  String get rewardsLoadSuggested => 'Cargar premios sugeridos';

  @override
  String get rewardsOrCreateCustom => 'O crear un premio personalizado';

  @override
  String get rewardsAddNewDesirePrompt => '¿Querés sumar un deseo nuevo?';

  @override
  String get rewardsAddNewDesireHint =>
      'Proponelo y tu compañero podrá aprobarlo para que aparezca en la tienda.';

  @override
  String get rewardsSuggestNewDesire => 'Proponer un deseo nuevo';

  @override
  String get rewardsSeedNothingNew =>
      'Ya hay premios o propuestas cargadas en esta casa.';

  @override
  String get rewardsNoteOptionalLabel => 'NOTA (OPCIONAL)';

  @override
  String get rewardsSendProposal => 'Enviar propuesta';

  @override
  String get rewardsCreatePrize => 'Crear premio';

  @override
  String get rewardsProposalSentToast => 'Propuesta enviada.';

  @override
  String get rewardsPrizeCreatedToast => 'Premio creado con éxito.';

  @override
  String get rewardsEmptyNoChildStore => 'Todavía no hay premios en tu tienda.';

  @override
  String get rewardsNotYet => 'Aún no';

  @override
  String get rewardsYesWeDid => 'Sí, lo hicimos';

  @override
  String get rewardsDeletePrompt => '¿Eliminar premio?';

  @override
  String rewardsDeleteBody(String title) {
    return 'Se eliminará \"$title\" de la boutique.';
  }

  @override
  String get rewardsInsufficientCoins =>
      'Coins insuficientes. A completar tareas.';

  @override
  String get rewardsRedeemPrompt => '¿Canjear este premio?';

  @override
  String get rewardsRedeem => 'Canjear';

  @override
  String get rewardsRedeemed => 'Premio canjeado';

  @override
  String rewardsRedeemedBody(String title) {
    return 'Disfrutá de \"$title\". El amor también vive en los pequeños detalles.';
  }

  @override
  String get rewardsApprovalReason => 'Motivo para aprobarlo';

  @override
  String rewardsCostLabel(int cost) {
    return 'Costo: $cost coins';
  }

  @override
  String get rewardsSuggestTitle => 'Proponer un deseo';

  @override
  String get rewardsNewHouseReward => 'Nuevo premio de la casa';

  @override
  String get rewardsTitleLabel => 'TÍTULO';

  @override
  String get rewardsReasonLabel => 'POR QUÉ DEBERÍA APROBARLO';

  @override
  String get rewardsDescriptionLabel => 'DESCRIPCIÓN';

  @override
  String get rewardsCostFieldLabel => 'COSTO';

  @override
  String get rewardsCategoryFieldLabel => 'CATEGORÍA';

  @override
  String get rewardsCostHint => 'Costo en coins';

  @override
  String get rewardsPendingReview => 'Pendientes de aprobación';

  @override
  String get rewardsPendingReviewSubtitle =>
      'Premios propuestos que todavía necesitan decisión.';

  @override
  String get rewardsForKids => 'Premios para chicos';

  @override
  String get rewardsForKidsSubtitle =>
      'Recompensas pensadas para motivar y celebrar avances.';

  @override
  String get rewardsForAdults => 'Premios para adultos';

  @override
  String get rewardsForAdultsSubtitle =>
      'Mimos y recompensas pensados para los adultos de la casa.';

  @override
  String get rewardsFamilyPlans => 'Planes familiares';

  @override
  String get rewardsFamilyPlansSubtitle =>
      'Premios y salidas para disfrutar entre todos.';

  @override
  String get rewardsForYou => 'Premios para vos';

  @override
  String get rewardsForYouSubtitle =>
      'Elegí qué querés conseguir con tus coins.';

  @override
  String get rewardsPlansTogether => 'Planes en familia';

  @override
  String get rewardsPlansTogetherSubtitle => 'Premios para disfrutar juntos.';

  @override
  String get rewardsChildStoreTitle => 'Mi tienda';

  @override
  String get rewardsFamilyStoreTitle => 'Tienda del hogar';

  @override
  String get rewardsNewPrizeLabel => 'Nuevo premio';

  @override
  String get rewardsEmptyNoChildPrizes => 'Todavía no hay premios para chicos.';

  @override
  String get rewardsEmptyNoAdultPrizes =>
      'Todavía no hay premios para adultos.';

  @override
  String get rewardsEmptyNoFamilyPlans =>
      'Todavía no hay planes familiares cargados.';

  @override
  String get rewardsEmptyNoFamilyPlansChild =>
      'Todavía no hay planes familiares disponibles.';

  @override
  String get rewardsEditPrize => 'Editar premio';

  @override
  String get rewardsNewFamilyPrize => 'Nuevo premio familiar';

  @override
  String get rewardsPrizeTitleField => 'Título del premio';

  @override
  String get rewardsPrizeDescriptionField => 'Descripción breve';

  @override
  String get rewardsCostInCoinsField => 'Costo en monedas';

  @override
  String get rewardsTargetAudience => 'Dirigido a';

  @override
  String get rewardsWholeFamily => 'Toda la familia';

  @override
  String get rewardsAdults => 'Adultos';

  @override
  String get rewardsKids => 'Chicos';

  @override
  String get rewardsIconLabel => 'Icono';

  @override
  String get rewardsSaveChanges => 'Guardar cambios';

  @override
  String get rewardsSavePrize => 'Guardar premio';

  @override
  String rewardsApprovedSnack(String title) {
    return '\"$title\" quedó aprobado.';
  }

  @override
  String get rewardsDeleteDialogTitle => 'Eliminar premio';

  @override
  String rewardsDeleteDialogBody(String title) {
    return 'Se va a quitar \"$title\" de la tienda.';
  }

  @override
  String rewardsPrizeCostCoins(int cost) {
    return '$cost monedas';
  }

  @override
  String get rewardsRemovePrize => 'Quitar premio';

  @override
  String get rewardsNotEnoughCoins => 'No te alcanzan las monedas todavía.';

  @override
  String get rewardsRedeemDialogTitle => 'Canjear premio';

  @override
  String rewardsRedeemDialogBody(String title, int cost) {
    return '¿Querés canjear \"$title\" por $cost monedas?';
  }

  @override
  String rewardsRedeemedSnack(String title) {
    return 'Canjeaste \"$title\".';
  }

  @override
  String get rewardsChildCoinPurse => 'Tu bolsita de coins';

  @override
  String get rewardsCurrentBalance => 'Balance actual';

  @override
  String get rewardsYourCoins => 'Tus monedas';

  @override
  String rewardsBalanceAmount(int balance) {
    return '$balance monedas';
  }

  @override
  String get rewardsChildBalanceHint =>
      'Cuando un adulto aprueba tus misiones, crece.';

  @override
  String get rewardsEmptyBoutiqueAdmin =>
      'Cargá premios sugeridos o creá el primer catálogo del hogar.';

  @override
  String get rewardsEmptyBoutiqueNonAdmin =>
      'Todavía no hay premios disponibles en la tienda del hogar.';

  @override
  String get rewardsLoadInitialCatalog => 'Cargar catálogo inicial';

  @override
  String get rewardsReviewPill => 'Revisar';

  @override
  String get rewardsRemove => 'Quitar';

  @override
  String get rewardsApprove => 'Aprobar';

  @override
  String rewardsProposalStatusWaiting(int count) {
    return '$count coins · esperando respuesta';
  }

  @override
  String rewardsProposalStatusAction(int count) {
    return '$count coins · tocá para aprobar o quitar';
  }

  @override
  String get coupleSpaceTaskEffortEyebrow => 'ESFUERZO';

  @override
  String get coupleSpaceTaskEffortTitle => 'Qué tan demandante es';

  @override
  String get coupleSpaceTaskEffortSubtitle =>
      'La dificultad ayuda a repartir mejor las tareas; no genera puntos ni coins.';

  @override
  String coupleSpaceTaskCompletionMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas completadas. La semana avanzó un poco más.',
      one: 'Tarea completada. La semana avanzó un poco más.',
    );
    return '$_temp0';
  }

  @override
  String get coupleSpacePlansSubtitle =>
      'Propuestas gratuitas: se pueden aceptar, posponer o retirar sin consecuencias.';

  @override
  String get coupleSpaceProposeAction => 'Proponer algo';

  @override
  String get coupleSpaceProposalAccepted => 'Acordado';

  @override
  String get coupleSpaceProposalDeferred => 'Para después';

  @override
  String get coupleSpaceProposalCategoryTalk => 'Para charlar';

  @override
  String get coupleSpaceProposalCategoryPlan => 'Plan juntos';

  @override
  String get coupleSpaceProposalCategoryAffection => 'Afecto';

  @override
  String get coupleSpaceProposalCategorySupport => 'Apoyo';

  @override
  String get coupleSpaceNewProposalTitle => 'Proponer algo';

  @override
  String get coupleSpaceNewProposalBody =>
      'No tiene precio ni crea una obligación. La otra persona siempre puede decir “ahora no”.';

  @override
  String get coupleSpaceProposalTitleLabel => '¿Qué te gustaría proponer?';

  @override
  String get coupleSpaceProposalTitleHint => 'Ej.: Cocinar algo nuevo juntos';

  @override
  String get coupleSpaceProposalDescriptionLabel =>
      'Contá un poco más (opcional)';

  @override
  String get coupleSpaceProposalDescriptionHint =>
      'Qué imaginás, cuándo podría ser o qué necesitás';

  @override
  String get coupleSpaceProposalCategoryLabel => 'Tipo de propuesta';

  @override
  String get coupleSpaceProposalSend => 'Enviar propuesta';

  @override
  String get coupleSpaceProposalTitleValidation =>
      'Escribí al menos 3 caracteres.';

  @override
  String get coupleSpaceProposalCreated =>
      'Propuesta enviada. No genera ninguna deuda.';

  @override
  String get coupleSpaceProposalResponseTitle => 'Responder la propuesta';

  @override
  String get coupleSpaceProposalResponseBody =>
      'Elegí con libertad. Decir “ahora no” no resta puntos ni requiere explicación.';

  @override
  String get coupleSpaceProposalAccept => 'Dale';

  @override
  String get coupleSpaceProposalDefer => 'Para después';

  @override
  String get coupleSpaceProposalDecline => 'Ahora no';

  @override
  String get coupleSpaceProposalWithdraw => 'Retirar propuesta';

  @override
  String get coupleSpaceProposalArchive => 'Archivar';

  @override
  String get coupleSpaceProposalAcceptedToast => 'Quedó como un plan acordado.';

  @override
  String get coupleSpaceProposalDeferredToast =>
      'Quedó guardada para retomarla cuando quieran.';

  @override
  String get coupleSpaceProposalDeclinedToast =>
      'Respuesta guardada sin penalizaciones.';

  @override
  String get coupleSpaceProposalWithdrawnToast => 'Retiraste la propuesta.';

  @override
  String get coupleSpaceProposalArchivedToast => 'Plan archivado.';

  @override
  String get coupleSpaceLoadError => 'No pudimos cargar este espacio.';

  @override
  String tourStepLabel(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get tourWelcomeEyebrow => 'Bienvenidos';

  @override
  String get tourCtaStart => 'Empezar';

  @override
  String get tourCtaNext => 'Siguiente';

  @override
  String get tourCtaLater => 'Después';

  @override
  String get tourFinaleTitle => '¡Listo!';

  @override
  String get tourFinaleCta => 'Empezar a usar';

  @override
  String get tourCoupleWelcomeTitle => 'Su hogar, en 30 segundos';

  @override
  String get tourCoupleWelcomeBody =>
      'Les muestro lo esencial: tareas compartidas, propuestas, momentos especiales y gastos. Corto y al punto.';

  @override
  String tourCoupleWelcomeBodyNamed(String partnerName) {
    return 'Te muestro lo esencial para organizar todo con $partnerName: tareas compartidas, propuestas, momentos especiales y gastos.';
  }

  @override
  String get tourTasksTitleHas => 'Las tareas, entre los dos';

  @override
  String get tourTasksBodyHas =>
      'Tocá ✓ para completar. El progreso semanal ayuda a ver lo que falta y a repartir mejor el trabajo.';

  @override
  String get tourTasksTitleEmpty => 'Hoy en casa está vacío';

  @override
  String get tourTasksBodyEmpty =>
      'Acá van a vivir las tareas del día. Programá la primera ahora y vela aparecer — o seguí el recorrido y lo hacés después.';

  @override
  String get tourTasksCtaCreate => 'Programar una tarea';

  @override
  String get tourBalanceTitle => 'El pulso del hogar';

  @override
  String tourBalanceBody(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'shared':
            'Tienen economía integrada: acá no hay deudas entre ustedes y ven cuánto gastó el hogar este mes.',
        'other':
            'Acá ven cuánto se deben por gastos compartidos. Con “Equilibrar” pueden saldar las cuentas reales en un toque.',
      },
    );
    return '$_temp0';
  }

  @override
  String get tourBalanceBulletSettle =>
      'Equilibrar → saldar gastos compartidos';

  @override
  String get tourBalanceBulletMonth => 'Gasto del mes → el pulso de la casa';

  @override
  String get tourBalanceBulletXp => 'XP → para el duelo semanal';

  @override
  String get tourBalanceBulletCoins => 'Monedas → para canjear recompensas';

  @override
  String get tourDuelTitle => 'Duelo semanal';

  @override
  String get tourDuelBody =>
      'Cada semana compiten por XP con marcador oculto. El domingo se revela quién ganó. Se reinicia los lunes.';

  @override
  String get tourRewardsTitle => 'Canjeá las monedas';

  @override
  String get tourRewardsBody =>
      'Acá viven las recompensas: peli, masaje, día libre. Ustedes arman la tienda y se premian mutuamente.';

  @override
  String tourExpensesTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'shared': 'Las finanzas del hogar',
        'other': 'Dividan los gastos',
      },
    );
    return '$_temp0';
  }

  @override
  String tourExpensesBody(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'shared':
            'Registren acá los gastos del hogar: recurrentes, compras y metas de ahorro, todo en un solo lugar.',
        'other':
            'Sumen gastos del hogar y la app calcula quién le debe a quién, según la división que configuraron.',
      },
    );
    return '$_temp0';
  }

  @override
  String get tourCoupleFinaleBody =>
      'A disfrutar su hogar. Cualquier duda, las Preguntas Frecuentes se adaptan a ustedes.';

  @override
  String get tourFamilyWelcomeTitle => 'Tu familia, organizada';

  @override
  String get tourFamilyWelcomeBody =>
      'Te muestro cómo manejar tareas, puntos y premios de toda la familia — en un minuto.';

  @override
  String get tourFamilyTasksTitleHas => 'Las tareas de la familia';

  @override
  String tourFamilyTasksBody(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'approvals':
            'Asigná tareas a cada uno. Cuando los chicos las completen, te llegan para aprobar — recién ahí cobran sus monedas.',
        'other':
            'Asigná tareas a cada uno y seguí el progreso de todos desde acá.',
      },
    );
    return '$_temp0';
  }

  @override
  String get tourFamilyFinanceTitle => 'Los gastos, entre adultos';

  @override
  String get tourFamilyFinanceBody =>
      'Los gastos compartidos del hogar se manejan acá, solo entre adultos. Los chicos no los ven.';

  @override
  String get tourFamilyRankingTitle => 'Ranking semanal';

  @override
  String get tourFamilyRankingBody =>
      'Cada semana, quien más XP suma completando tareas se lleva la corona. Sana competencia familiar.';

  @override
  String get tourFamilyRewardsTitle => 'La tienda de premios';

  @override
  String get tourFamilyRewardsBody =>
      'Creá premios (una salida, tiempo de pantalla, su postre favorito) y los chicos los canjean con las monedas que ganan.';

  @override
  String get tourFamilyFinaleBody =>
      'A organizar la tropa. Las Preguntas Frecuentes se adaptan a tu rol si necesitás ayuda.';

  @override
  String get familyRewardsCoinsLabel => 'monedas';

  @override
  String get statsTabWeek => 'Semana';

  @override
  String get statsTabEvolution => 'Evolución';

  @override
  String get statsTabAchievements => 'Logros';

  @override
  String get statsRetry => 'Reintentar';

  @override
  String get statsHouseholdSummary => 'Resumen del hogar';

  @override
  String get statsTasks => 'Tareas';

  @override
  String statsTasksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tareas',
      one: 'Tarea',
    );
    return '$_temp0';
  }

  @override
  String get statsXP => 'XP';

  @override
  String get statsCoins => 'Coins';

  @override
  String get statsWeeklyHistory => 'Historial semanal';

  @override
  String get statsVictoryHistory => 'Historial de victorias';

  @override
  String get statsPrivacyMessage =>
      'Las estadísticas son privadas de tu hogar. Solo vos y tu pareja pueden ver estos datos.';

  @override
  String get statsPrivacyDetailed =>
      'Tus datos de progreso son privados y solo vos podés ver este historial detallado.';

  @override
  String get statsPrivacyFull =>
      'Las estadísticas son totalmente privadas de tu hogar. Solo vos y tu pareja pueden ver estos datos.';

  @override
  String get statsWeeklyDuel => 'Duelo semanal';

  @override
  String get statsEmptyTitle => 'Todavía no hay datos';

  @override
  String get statsEmptySubtitle =>
      'Completá algunas tareas para ver tus áreas de dominio.';

  @override
  String get statsRefreshButton => 'Actualizar datos';

  @override
  String get weeklyWinnerEmptyTitle => 'Todavía no hay ganador semanal';

  @override
  String get weeklyWinnerEmptyBody =>
      'Completá tareas esta semana y el duelo empezará a tomar forma.';

  @override
  String get weeklyWinnerWeeklyClose => 'CIERRE SEMANAL';

  @override
  String get weeklyWinnerTitle => 'Ganador semanal';

  @override
  String weeklyWinnerHeadline(String name) {
    return '$name ganó la semana';
  }

  @override
  String get weeklyWinnerSubtitle => 'Así cerró la semana entre ustedes.';

  @override
  String get weeklyWinnerCardSubtitle =>
      'Buen cierre: más constancia, más puntos y más ritmo.';

  @override
  String get weeklyWinnerCoinsReward => '+20 coins';

  @override
  String weeklyWinnerCoinsAwarded(int coins) {
    return '+$coins coins';
  }

  @override
  String get weeklyWinnerSecondPlace => 'Segundo puesto';

  @override
  String get weeklyWinnerFinalScore => 'Marcador final';

  @override
  String get weeklyWinnerRankingTitle => 'Ranking semanal';

  @override
  String get weeklyWinnerFallbackWinner => 'Ganador';

  @override
  String get weeklyWinnerFallbackLoser => 'Perdedor';

  @override
  String get weeklyWinnerFallbackParticipant => 'Participante';

  @override
  String get weeklyWinnerFallbackPlayer => 'Jugador';

  @override
  String get weeklyWinnerClose => 'Cerrar';

  @override
  String get weeklyWinnerContinue => 'Continuar';

  @override
  String get loveNoteHint => 'Escribí algo tierno...';

  @override
  String get loveNoteSent => 'Nota enviada con amor';

  @override
  String get weeklyProgressTitle => 'Progreso semanal';

  @override
  String get weeklyProgressSubtitle =>
      'Seguí cómo viene la semana, quién tomó ventaja y cuánto ritmo llevan juntos.';

  @override
  String weeklyProgressWeekLabel(String weekRange) {
    return 'Semana actual · $weekRange';
  }

  @override
  String get personalEvolutionTitle => 'Tu evolución personal';

  @override
  String get streakLabel => 'Racha';

  @override
  String streakDaysValue(int days) {
    return '$days días';
  }

  @override
  String get streakSubtitle => '¡Vas con todo!';

  @override
  String get levelLabel => 'Nivel';

  @override
  String levelXpToNext(int xp) {
    return '$xp XP para subir';
  }

  @override
  String get progressEmptyTitle =>
      'Empezá a completar tareas\npara ver tu progreso.';

  @override
  String get categoriesDominance => 'Dominio por categoría';

  @override
  String get categoriesBreakdown => 'Desglose detallado';

  @override
  String get categoriesBalanceTip =>
      'Balancear las categorías ayuda a mantener un hogar más armonioso y divertido.';

  @override
  String get categoriesImpactDistribution => 'DISTRIBUCIÓN DE IMPACTO';

  @override
  String categoriesTasksCount(int count) {
    return '$count TAREAS';
  }

  @override
  String categoriesCompletedCount(int count) {
    return '$count completadas';
  }

  @override
  String get categoriesXpTotal => 'XP TOTAL';

  @override
  String get achievementsTitle => 'Tus medallas';

  @override
  String get achievementsCoupleChallenges => 'Desafíos de pareja';

  @override
  String get achievementsIconicMoments => 'Momentos icónicos';

  @override
  String get duelHistoryLastWeek => 'Semana pasada';

  @override
  String get duelVsText => ' vs ';

  @override
  String get rewardsTitleRequiredError => 'Escribí el nombre del deseo.';

  @override
  String get rewardsTitleMinLengthError => 'Usá al menos 3 caracteres.';

  @override
  String get rewardsTitleHint => 'Ej: Masaje de 20 minutos';

  @override
  String get rewardsTargetTypeAdult => 'Adultos';

  @override
  String get rewardsTargetTypeChild => 'Chicos';

  @override
  String get rewardsTargetTypeFamily => 'Familia';

  @override
  String get rewardsCostValidationInvalid => 'Ingresá un costo válido.';

  @override
  String get rewardsCostValidationMin => 'Debe costar al menos 1 coin.';

  @override
  String get rewardsDescriptionSuggestionHint =>
      'Explicá por qué tu pareja debería aprobar este deseo.';

  @override
  String get rewardsDescriptionPrizeHint =>
      'Un detalle corto para describir el premio.';

  @override
  String get rewardsValidationMinLength =>
      'Contá un poco más para que sea fácil evaluarlo.';

  @override
  String get statsWeeklyProgressTitle => 'Progreso semanal';

  @override
  String get statsWeeklyProgressSubtitle =>
      'Seguí cómo viene la semana, quién tomó ventaja y cuánto ritmo llevan juntos.';

  @override
  String get faceoffWeeklyDuelLabel => 'DUELO SEMANAL';

  @override
  String get faceoffHiddenScoreTitle => 'Tu pareja juega con marcador oculto';

  @override
  String get faceoffHiddenScoreSubtitle =>
      'Vos ves tu propio avance. El resultado real se descubre al cierre de la semana.';

  @override
  String get faceoffYouLabel => 'Vos';

  @override
  String get faceoffPartnerLabel => 'Pareja';

  @override
  String faceoffXpValue(int xp) {
    return '$xp XP';
  }

  @override
  String get faceoffHiddenXp => 'XP oculta';

  @override
  String get faceoffWeeklyAdvantage => 'Ventaja semanal';

  @override
  String get faceoffHiddenScore => 'Marcador oculto';

  @override
  String faceoffCurrentXpCounts(int xp) {
    return 'Tus $xp XP ya cuentan. La XP de tu pareja queda oculta hasta el domingo.';
  }

  @override
  String get faceoffWeeklyRhythm => 'Ritmo semanal';

  @override
  String get weekDayInitials => 'L,M,X,J,V,S,D';

  @override
  String get faceoffMyWeekLabel => 'Tu semana';

  @override
  String faceoffPersonalRecordChip(int xp) {
    return 'Récord: $xp XP';
  }

  @override
  String faceoffStarterGoalChip(int xp) {
    return 'Meta: $xp XP';
  }

  @override
  String get faceoffNewRecord => '¡Nuevo récord personal!';

  @override
  String get faceoffClosesToday => 'Cierra hoy';

  @override
  String faceoffDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días restantes',
      one: '1 día restante',
    );
    return '$_temp0';
  }

  @override
  String get statsCurrentWeek => 'Semana actual';

  @override
  String get statsNoDataMessage =>
      'Empezá a completar tareas para ver tu progreso.';

  @override
  String get statsStreak => 'Racha';

  @override
  String statsStreakDays(Object count) {
    return '$count días';
  }

  @override
  String get statsStreakMessage => '¡Vas con todo!';

  @override
  String get statsLevel => 'Nivel';

  @override
  String statsXPToNextLevel(Object count) {
    return '$count XP para subir';
  }

  @override
  String get statsNoDataTitle => 'Todavía no hay datos';

  @override
  String get statsNoDataSubtitle =>
      'Completá algunas tareas para ver tus áreas de dominio.';

  @override
  String get commonRefresh => 'Actualizar datos';

  @override
  String get rewardsWaitingResponse => 'esperando respuesta';

  @override
  String get rewardsTapToApprove => 'toca para aprobar o quitar';

  @override
  String rewardsCostCoins(Object cost) {
    return '$cost coins';
  }

  @override
  String householdSocialHubYourRole(Object role) {
    return 'Tu rol: $role';
  }

  @override
  String get householdSocialHubRoleFallback =>
      'Roles y premios listos para organizar la semana.';

  @override
  String get householdSocialHubRoleMember => 'Integrante';

  @override
  String get contributionBalanceTitle => 'Aporte del mes';

  @override
  String get contributionBalanceSubtitle =>
      'Cómo venimos repartidos en el piso.';

  @override
  String get contributionBalanceEmptyTitle => 'Todavía no hay aportes este mes';

  @override
  String get contributionBalanceEmptyBody =>
      'Cuando completen tareas o carguen gastos compartidos, acá van a ver cómo queda el reparto.';

  @override
  String contributionBalanceTasksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '$count tarea',
      zero: 'Sin tareas',
    );
    return '$_temp0';
  }

  @override
  String get contributionBalanceFootnote =>
      'Sin ganadores: esto es solo para ver que estemos parejos.';

  @override
  String get householdBillsTitle => 'Cuentas del piso';

  @override
  String get householdBillsSubtitle =>
      'Gastos fijos que se reparten entre todos cada mes.';

  @override
  String get householdBillsEmptyTitle => 'Todavía no hay cuentas fijas';

  @override
  String get householdBillsEmptyBody =>
      'Cargá el alquiler, la luz o internet y se van a dividir solas cada mes.';

  @override
  String get householdBillsAddButton => 'Agregar cuenta del piso';

  @override
  String get householdBillsPremiumBody =>
      'Las cuentas fijas que se dividen solas cada mes son parte de Premium.';

  @override
  String get householdBillsPremiumUnlock => 'Desbloquear con Premium';

  @override
  String householdBillsPerMonth(String amount) {
    return '$amount / mes';
  }

  @override
  String householdBillsDayOfMonth(int day) {
    return 'Día $day';
  }

  @override
  String get householdSettleUpTitle => 'Saldar cuentas';

  @override
  String get householdSettleUpSubtitle =>
      'Quién le debe a quién para quedar a mano.';

  @override
  String get householdSocialHubStoreButton => 'Tienda';

  @override
  String get householdSocialHubTrackingTitle => 'Seguimiento familiar';

  @override
  String get householdSocialHubTrackingSubtitle =>
      'Avances por integrante y cierre semanal.';

  @override
  String get householdSocialHubShortcutMemberView => 'Vista por miembro';

  @override
  String get householdSocialHubShortcutWeeklySummary => 'Resumen semanal';

  @override
  String householdSocialHubRankingPoints(Object count) {
    return '$count pts';
  }

  @override
  String get householdSocialHubRankingHidden => 'Oculto';

  @override
  String get householdSocialHubRankingSurprise => 'Sorpresa';

  @override
  String householdSocialHubRankingLeader(Object name) {
    return '$name viene liderando la semana.';
  }

  @override
  String get householdSocialHubRankingHideHint =>
      'Desde el jueves guardamos los puntos para revelar al ganador al cierre.';

  @override
  String get householdSocialHubRankingEmpty =>
      'Completen tareas para sumar puntos';

  @override
  String householdSocialHubRankingEmptyTab(Object tab) {
    return 'Nadie sumó puntos en $tab todavía';
  }

  @override
  String householdSocialHubRankingTasksCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
    );
    return '$_temp0';
  }

  @override
  String get householdSocialHubMemberFallback => 'Integrante';

  @override
  String get householdSocialHubLoading => 'Cargando ranking...';

  @override
  String get householdSocialHubLoadError => 'No pudimos cargar el ranking.';

  @override
  String get householdSocialHubRetry => 'Reintentar';

  @override
  String get taskCategoryCleaningGeneral => 'Limpieza general';

  @override
  String get taskCategoryKitchen => 'Cocina';

  @override
  String get taskCategoryBedroom => 'Dormitorio';

  @override
  String get taskCategoryBathroom => 'Baño';

  @override
  String get taskCategoryCommonSpaces => 'Espacios comunes';

  @override
  String get taskCategoryLaundry => 'Ropa';

  @override
  String get taskCategoryTrashRecycling => 'Basura / reciclaje';

  @override
  String get taskCategoryShoppingOrganization => 'Compras / organización';

  @override
  String get taskCategoryPets => 'Mascotas';

  @override
  String get taskCategoryOutdoorGarden => 'Exterior / jardín';

  @override
  String get taskCategoryHomeMaintenance => 'Mantenimiento del hogar';

  @override
  String get taskCategoryKidsCare => 'Niños / cuidado';

  @override
  String get taskCategoryHomeAdmin => 'Administración del hogar';

  @override
  String get taskTemplateSweepFloors => 'Barrer pisos';

  @override
  String get taskTemplateVacuumFloorsOrRugs => 'Aspirar pisos o alfombras';

  @override
  String get taskTemplateMopFloors => 'Trapear / fregar pisos';

  @override
  String get taskTemplateDustFurniture => 'Limpiar polvo de muebles';

  @override
  String get taskTemplateCleanWindows => 'Limpiar ventanas';

  @override
  String get taskTemplateGeneralHouseTidying => 'Orden general de la casa';

  @override
  String get taskTemplateDeepCleanGeneral => 'Limpieza profunda general';

  @override
  String get taskTemplateWashDishes => 'Lavar los platos';

  @override
  String get taskTemplateEmptyDishwasher => 'Guardar / vaciar lavavajillas';

  @override
  String get taskTemplateCookSimpleMeal => 'Cocinar comida sencilla';

  @override
  String get taskTemplateCookFullMeal => 'Cocinar comida completa';

  @override
  String get taskTemplateSetTable => 'Poner la mesa';

  @override
  String get taskTemplateClearTable => 'Levantar la mesa';

  @override
  String get taskTemplateCleanCounters => 'Limpiar mesada y superficies';

  @override
  String get taskTemplateCleanFullKitchen => 'Limpiar cocina completa';

  @override
  String get taskTemplateCleanFridge => 'Limpiar heladera';

  @override
  String get taskTemplateCleanOven => 'Limpiar horno';

  @override
  String get taskTemplateOrganizePantry => 'Organizar despensa';

  @override
  String get taskTemplateMakeBed => 'Hacer la cama';

  @override
  String get taskTemplateTidyBedroom => 'Ordenar habitación';

  @override
  String get taskTemplateChangeSheets => 'Cambiar sábanas';

  @override
  String get taskTemplateOrganizeCloset => 'Ordenar placard';

  @override
  String get taskTemplateBedroomGeneralClean =>
      'Limpieza general del dormitorio';

  @override
  String get taskTemplateCleanToilet => 'Limpiar inodoro';

  @override
  String get taskTemplateCleanSink => 'Limpiar lavamanos';

  @override
  String get taskTemplateCleanMirror => 'Limpiar espejo';

  @override
  String get taskTemplateCleanShowerTub => 'Limpiar ducha / bañera';

  @override
  String get taskTemplateRestockBathroomSupplies =>
      'Reponer papel higiénico o jabón';

  @override
  String get taskTemplateCleanFullBathroom => 'Limpieza completa del baño';

  @override
  String get taskTemplateTidyLivingRoom => 'Ordenar sala / living';

  @override
  String get taskTemplateCleanFurniture => 'Limpiar muebles';

  @override
  String get taskTemplateCleanSofas => 'Limpiar sillones';

  @override
  String get taskTemplateCleanDiningTable => 'Limpiar mesa del comedor';

  @override
  String get taskTemplateCleanCommonArea => 'Aspirar o limpiar área común';

  @override
  String get taskTemplateWashLaundry => 'Lavar ropa';

  @override
  String get taskTemplateHangLaundry => 'Tender ropa';

  @override
  String get taskTemplateUseDryer => 'Usar secadora';

  @override
  String get taskTemplateFoldPutAwayLaundry => 'Doblar y guardar ropa';

  @override
  String get taskTemplateIronClothes => 'Planchar ropa';

  @override
  String get taskTemplateChangeTowels => 'Cambiar toallas';

  @override
  String get taskTemplateOrganizeWardrobe => 'Organizar placard';

  @override
  String get taskTemplateTakeOutTrash => 'Sacar la basura';

  @override
  String get taskTemplateSortRecycling => 'Separar reciclaje';

  @override
  String get taskTemplateTakeRecycling => 'Llevar reciclaje';

  @override
  String get taskTemplateMakeShoppingList => 'Hacer lista de compras';

  @override
  String get taskTemplateGoGroceryShopping => 'Ir al supermercado';

  @override
  String get taskTemplatePutAwayGroceries => 'Guardar compras';

  @override
  String get taskTemplatePlanWeeklyMenu => 'Planificar menú semanal';

  @override
  String get taskTemplateFeedPet => 'Dar de comer a la mascota';

  @override
  String get taskTemplateWalkPet => 'Pasear mascota';

  @override
  String get taskTemplateCleanPetArea => 'Limpiar arenero / área';

  @override
  String get taskTemplateBathePet => 'Bañar mascota';

  @override
  String get taskTemplatePetAreaGeneralClean =>
      'Limpieza general de zona de mascota';

  @override
  String get taskTemplateWaterPlants => 'Regar plantas';

  @override
  String get taskTemplateCleanPatioTerrace => 'Limpiar patio / terraza';

  @override
  String get taskTemplateRakeLeaves => 'Juntar hojas';

  @override
  String get taskTemplateMowLawn => 'Cortar césped';

  @override
  String get taskTemplateTidyGarden => 'Ordenar jardín';

  @override
  String get taskTemplateChangeLightBulbs => 'Cambiar bombillas';

  @override
  String get taskTemplateSmallHomeRepair => 'Pequeño arreglo del hogar';

  @override
  String get taskTemplateCheckFilters => 'Revisión de filtros';

  @override
  String get taskTemplateUnclogDrains => 'Desatascar desagües';

  @override
  String get taskTemplateMediumRepair => 'Arreglo mediano';

  @override
  String get taskTemplateLargeRepair => 'Arreglo grande';

  @override
  String get taskTemplateTidyToys => 'Ordenar juguetes';

  @override
  String get taskTemplateFeedKids => 'Dar de comer';

  @override
  String get taskTemplateHelpWithHomework => 'Ayudar con tareas escolares';

  @override
  String get taskTemplateSchoolPickupDropoff => 'Llevar o buscar del colegio';

  @override
  String get taskTemplateBatheKids => 'Bañar niños';

  @override
  String get taskTemplatePayBills => 'Pagar facturas';

  @override
  String get taskTemplateReviewHouseholdExpenses => 'Revisar gastos del hogar';

  @override
  String get taskTemplateOrganizeDocuments => 'Organizar documentos';

  @override
  String get taskTemplatePlanHouseholdTasks => 'Planificar tareas del hogar';

  @override
  String get taskTemplateCleanMicrowave => 'Limpiar microondas';

  @override
  String get taskTemplateWashCar => 'Lavar el auto';

  @override
  String get taskTemplateCleanTrashBins => 'Lavar tachos de basura';

  @override
  String get taskTemplatePackSchoolBag => 'Preparar mochila del colegio';

  @override
  String get taskTemplateGivePetWater => 'Cambiar agua de la mascota';

  @override
  String addTaskOptionsAddedSnack(String title) {
    return '\"$title\" añadida';
  }

  @override
  String get addTaskOptionsAddError => 'No pudimos agregar la tarea.';

  @override
  String get editTaskSaveError => 'No pudimos guardar los cambios.';

  @override
  String get editTaskDeleteError => 'No pudimos eliminar la tarea.';

  @override
  String get recurringExpenseSaveError =>
      'No pudimos guardar este registro recurrente.';

  @override
  String get recurringExpenseMembersLoadError =>
      'No pudimos cargar los integrantes del hogar.';

  @override
  String get recurringExpenseValidationTitleAmount =>
      'Completá título y monto válido.';

  @override
  String get recurringExpenseValidationPayer =>
      'Elegí quién suele abonarla para dejarla lista.';

  @override
  String get recurringExpenseDeleteTitle => '¿Eliminar suscripción?';

  @override
  String get recurringExpenseDeleteBody =>
      'Dejará de aparecer en futuros meses.';

  @override
  String get recurringExpenseDetailEyebrow => 'DETALLE';

  @override
  String get recurringExpenseDetailTitle => 'Qué se renueva cada mes';

  @override
  String get recurringExpenseDetailSubtitle =>
      'Definí el nombre y el monto para reconocerla rápido.';

  @override
  String get recurringExpenseCalendarEyebrow => 'CALENDARIO';

  @override
  String get recurringExpenseCalendarTitle => 'Cuándo se registra';

  @override
  String get recurringExpenseCalendarSubtitle =>
      'Elegimos el día habitual para programarla sola.';

  @override
  String get recurringExpenseCategoryEyebrow => 'CATEGORÍA';

  @override
  String get recurringExpenseCategoryTitle => 'Dónde encaja mejor';

  @override
  String get recurringExpenseCategorySubtitle =>
      'Ayuda a ordenar Finanzas y mantener la lectura clara.';

  @override
  String get recurringExpenseSplitEyebrow => 'REPARTO';

  @override
  String get recurringExpenseSplitTitle => 'Cómo se reparte';

  @override
  String get recurringExpenseSplitSubtitle =>
      'Definí si se comparte en el hogar o si queda como personal.';

  @override
  String get recurringExpensePayerEyebrow => 'PAGADOR';

  @override
  String get recurringExpensePayerTitle => 'Quién suele abonarla';

  @override
  String get recurringExpensePayerSubtitle =>
      'Esto deja una sugerencia lista para los próximos meses.';

  @override
  String get recurringExpenseHeaderEditIncome => 'Editar ingreso';

  @override
  String get recurringExpenseHeaderEditSubscription => 'Editar suscripción';

  @override
  String get recurringExpenseHeaderNewIncome => 'Nuevo ingreso fijo';

  @override
  String get recurringExpenseHeaderNewSubscription => 'Nueva suscripción';

  @override
  String get recurringExpenseHeaderEditSubtitle =>
      'Ajustá monto, categoría y reparto para mantenerlo al día.';

  @override
  String get recurringExpenseHeaderNewIncomeSubtitle =>
      'Se sumará automáticamente a tu balance cada mes.';

  @override
  String get recurringExpenseHeaderNewSubscriptionSubtitle =>
      'Dejala configurada y lista para que se registre sola todos los meses.';

  @override
  String get recurringExpenseDeleteIncome => 'Eliminar ingreso';

  @override
  String get recurringExpenseDeleteSubscription => 'Eliminar suscripción';

  @override
  String get recurringExpenseNameRequired =>
      'Escribí un nombre para reconocerla.';

  @override
  String get recurringExpenseNameMinLength => 'Usá al menos 3 caracteres.';

  @override
  String get recurringExpenseNameLabel => 'Nombre';

  @override
  String get recurringExpenseNameHint => 'Ej: Netflix, alquiler o internet';

  @override
  String get recurringExpenseAmountLabel => 'Monto por defecto';

  @override
  String get recurringExpenseSaveIncome => 'Guardar ingreso';

  @override
  String get recurringExpenseSaveSubscription => 'Guardar suscripción';

  @override
  String get recurringExpenseCategoryLabel => 'Categoría:';

  @override
  String get recurringExpenseSplitLabel => 'Reparto de gasto:';

  @override
  String get recurringExpenseAmountInvalid => 'Ingresá un monto válido.';

  @override
  String get recurringExpenseAmountPositive =>
      'El monto debe ser mayor a cero.';

  @override
  String get recurringExpenseDayLabel => 'Se cobra el día:';

  @override
  String get recurringExpenseRegularPayerLabel => 'Pagador habitual:';

  @override
  String expensesNewItemsAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos agregados a la lista',
      one: '1 producto agregado a la lista',
    );
    return '$_temp0';
  }

  @override
  String get expensesNewItemsDetectedTitle => 'Nuevos para tu lista';

  @override
  String get expensesNewItemsDetectedSubtitle =>
      '¿Los agregamos a la lista para la próxima?';

  @override
  String get expensesNewItemsIgnore => 'Ignorar';

  @override
  String expensesNewItemsAddToList(int count) {
    return 'Agregar $count a lista';
  }

  @override
  String get expensesNewItemsAddError =>
      'No pudimos agregar todos los productos. Reintentá los que quedaron.';

  @override
  String get expensesRecurringLoadError =>
      'No pudimos cargar tus gastos recurrentes.';

  @override
  String get expensesFormSaveError =>
      'No pudimos guardar el movimiento. Intentá de nuevo.';

  @override
  String get expensesFormMembersLoadError =>
      'No pudimos cargar los integrantes.';

  @override
  String get expensesDeleteError =>
      'No pudimos eliminar el movimiento. Intentá de nuevo.';

  @override
  String expensesPlannedPaymentTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'Confirmar cobro',
        'other': 'Confirmar pago',
      },
    );
    return '$_temp0';
  }

  @override
  String expensesPlannedPaymentSubtitle(String type, String title) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'Vas a marcar \"$title\" como cobrado.',
        'other': 'Vas a marcar \"$title\" como pagado.',
      },
    );
    return '$_temp0';
  }

  @override
  String get expensesPlannedPaymentAmountEyebrow => 'MONTO EFECTIVO';

  @override
  String expensesPlannedPaymentDateEyebrow(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'FECHA DE COBRO',
        'other': 'FECHA DE PAGO',
      },
    );
    return '$_temp0';
  }

  @override
  String get expensesDetailHeaderIncome => 'Detalle de ingreso';

  @override
  String get expensesDetailHeaderSettlement =>
      'Detalle de liquidación de balance';

  @override
  String get expensesDetailHeaderExpense => 'Detalle de gasto';

  @override
  String expensesDetailPaidBy(String name) {
    return 'Pagó $name';
  }

  @override
  String get expensesDetailNoteLabel => 'Nota:';

  @override
  String get expensesDetailPurchasedItems => 'Ítems comprados';

  @override
  String get expensesDetailLabel => 'Detalle';

  @override
  String get expensesDetailSplitLabel => 'División';

  @override
  String get expensesDetailPaidLabel => 'Pagó';

  @override
  String get expensesDetailTheirPartLabel => 'Su parte';

  @override
  String get expensesDetailSplitEqual => 'Dividido equitativamente';

  @override
  String get expensesDetailSplitPersonal => 'Gasto solo';

  @override
  String expensesRecurrentesDayOfMonth(int day) {
    return 'Día $day de cada mes';
  }

  @override
  String get expensesRecurrentesPremiumTitle => 'Pagos recurrentes';

  @override
  String get expensesRecurrentesPremiumSubtitle =>
      'Gestioná tus suscripciones, alquileres y servicios de forma automática con HomeSync Premium.';

  @override
  String get expensesRecurrentesPremiumCta => 'SABER MÁS';

  @override
  String get expensesRecurrentesPremiumBullet1 =>
      'Alquiler, servicios y suscripciones se registran solos cada mes.';

  @override
  String get expensesRecurrentesPremiumBullet2 =>
      'Recordatorios antes del vencimiento para que nada se pase.';

  @override
  String get expensesRecurrentesPremiumBullet3 =>
      'Todos ven qué viene y cuánto falta pagar.';

  @override
  String get expensesRecurringEmptyTitle => 'Sin recurrentes';

  @override
  String get expensesRecurringEmptySubtitle =>
      'Creá plantillas para tus suscripciones, alquileres o ingresos fijos.';

  @override
  String get expensesRecurringIncomeSection => 'INGRESOS FIJOS';

  @override
  String get expensesRecurringExpenseSection => 'GASTOS FIJOS';

  @override
  String get financeTitleSupermarket => 'Supermercado';

  @override
  String get financeTitleOnlineShopping => 'Compras online';

  @override
  String get financeTitleBalanceSettlement => 'Liquidación de balance';

  @override
  String get financeTitlePartnerSettlement => 'Liquidación de pareja';

  @override
  String get financeTitleSalary => 'Sueldo';

  @override
  String get financeTitleRent => 'Alquiler';

  @override
  String get financeTitleBuildingFees => 'Expensas';

  @override
  String get financeTitleGas => 'Gas';

  @override
  String get financeTitleElectricity => 'Luz';

  @override
  String get financeTitleWater => 'Agua';

  @override
  String get financeTitleInternet => 'Internet';

  @override
  String get financeTitleNetflix => 'Netflix';

  @override
  String get financeTitleMovies => 'Películas';

  @override
  String get financeTitleInsurance => 'Seguro';

  @override
  String get financeTitlePhone => 'Celular';

  @override
  String get expensesSavingsGoalNameLabel => 'Nombre';

  @override
  String get expensesSavingsGoalNameHint => '¿Cuál es tu objetivo?';

  @override
  String get expensesSavingsGoalAmountLabel => 'Monto objetivo';

  @override
  String get expensesSavingsGoalAmountHint => '¿Cuánto quieren juntar?';

  @override
  String savingsLoadError(String details) {
    return 'Error: $details';
  }

  @override
  String get savingsEmptyTitle => 'No hay metas activas aún';

  @override
  String get savingsEmptySubtitle =>
      'Empezá a guardar para algo que de verdad les entusiasme.';

  @override
  String get savingsEmptyFallbackSubtitle =>
      'Empezá hoy mismo a organizar tus finanzas del hogar.';

  @override
  String savingsGoalTarget(String amount) {
    return 'Meta: $amount';
  }

  @override
  String get savingsGoalProgressCaption => 'objetivo';

  @override
  String savingsGoalSaved(String amount) {
    return 'Ahorrado: $amount';
  }

  @override
  String savingsGoalSavedOf(String amount) {
    return 'ahorrados de $amount';
  }

  @override
  String get savingsGoalContributeAction => 'Aportar';

  @override
  String get savingsNewGoalTitle => 'Nueva Meta';

  @override
  String savingsNewGoalSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'solo':
            'Definí qué querés lograr y cuánto necesitás juntar para hacerlo realidad.',
        'family':
            'Definí qué quiere lograr la familia y cuánto necesitan juntar para hacerlo realidad.',
        'friends':
            'Definan qué quieren lograr y cuánto necesitan juntar para hacerlo realidad.',
        'other':
            'Definí qué quieren lograr en pareja y cuánto necesitan juntar para hacerlo realidad.',
      },
    );
    return '$_temp0';
  }

  @override
  String get savingsSectionDetail => 'DETALLE';

  @override
  String savingsSectionDetailTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'solo': 'Qué querés alcanzar',
        'family': 'Qué quiere alcanzar la familia',
        'friends': 'Qué quieren alcanzar',
        'other': 'Qué quieren alcanzar',
      },
    );
    return '$_temp0';
  }

  @override
  String get savingsSectionPersonalization => 'PERSONALIZACIÓN';

  @override
  String get savingsSectionPersonalizationTitle => 'Dale personalidad';

  @override
  String get savingsFieldEmoji => 'Emoji';

  @override
  String get savingsFieldColor => 'Color';

  @override
  String get savingsPickIconTitle => 'Elegí un ícono';

  @override
  String get savingsPickColorTitle => 'Elegí un color';

  @override
  String get savingsCreateGoalAction => 'Crear Meta';

  @override
  String get savingsContributeTo => 'Ingresar dinero a';

  @override
  String get savingsConfirmContribution => 'Confirmar Aporte';

  @override
  String get savingsTotalLabel => 'Ahorro Total';

  @override
  String get savingsStatGoals => 'Metas';

  @override
  String get savingsStatCompleted => 'Cumplidas';

  @override
  String get savingsHistoryTitle => 'HISTORIAL DE APORTES';

  @override
  String get savingsCompletedGoalsHistoryTitle => 'Historial de metas';

  @override
  String savingsContributionLine(String name, String amount) {
    return '$name sumó $amount';
  }

  @override
  String savingsSharedContributionLine(String names, String amount) {
    return '$names aportaron $amount';
  }

  @override
  String get savingsContributionSomeone => 'Alguien';

  @override
  String get savingsCompletedBadge => '¡Cumplida!';

  @override
  String savingsDeadlineChip(String date) {
    return 'Para el $date';
  }

  @override
  String get savingsEditAction => 'Editar meta';

  @override
  String get savingsDeleteAction => 'Eliminar';

  @override
  String get savingsDeleteConfirmTitle => '¿Eliminar meta?';

  @override
  String savingsDeleteConfirmBody(String title) {
    return 'Se perderá el registro de \"$title\".';
  }

  @override
  String get savingsArchiveAction => 'Archivar';

  @override
  String get savingsArchiveConfirmTitle => '¿Archivar meta cumplida?';

  @override
  String get savingsArchiveConfirmBody =>
      'La meta se guardará como cumplida y dejará de aparecer en la lista.';

  @override
  String get savingsEditGoalTitle => 'Editar Meta';

  @override
  String get savingsSaveChangesAction => 'Guardar cambios';

  @override
  String get savingsContributeSplitTitle => '¿CÓMO REGISTRAR EL APORTE?';

  @override
  String get savingsContributeSoloLabel => 'Solo yo';

  @override
  String get savingsContributeSoloDesc =>
      'Sale de tu bolsillo, como un regalo.';

  @override
  String savingsContributeSharedLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'En familia',
        'friends': 'Entre todos',
        'solo': 'Entre todos',
        'other': 'En pareja',
      },
    );
    return '$_temp0';
  }

  @override
  String savingsContributeSharedDesc(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Se reparte entre los adultos del hogar.',
        'friends': 'Se reparte entre quienes conviven.',
        'solo': 'Se reparte según la economía del hogar.',
        'other': 'Se reparte entre vos y tu pareja.',
      },
    );
    return '$_temp0';
  }

  @override
  String get savingsNoteLabel => 'Nota (opcional)';

  @override
  String get savingsNoteHint => '¿Para qué es este aporte?';

  @override
  String get savingsTargetDateLabel => 'Fecha objetivo (opcional)';

  @override
  String get savingsTargetDateClear => 'Sin fecha límite';

  @override
  String savingsSuggesterMessage(String amount, String percent, String goal) {
    return 'Según tu plan, podrías ahorrar $amount extra este mes. ¡Adelantarías un $percent% tu meta \"$goal\"!';
  }

  @override
  String get savingsSuggesterCta => 'Aportar ahora';

  @override
  String get savingsCompletedCelebrationTitle => '¡Meta cumplida! 🎉';

  @override
  String savingsCompletedCelebrationBody(String title) {
    return 'Juntaron todo para \"$title\". ¡Felicitaciones!';
  }

  @override
  String get savingsCelebrationDismiss => '¡Genial!';

  @override
  String get achievementsBadgesSection => 'Tus Medallas';

  @override
  String get achievementsCoupleChallengesSection => 'Desafíos de Pareja';

  @override
  String get achievementsIconicMomentsSection => 'Momentos Icónicos';

  @override
  String get achievementsFirstStepsTitle => 'Primeros Pasos';

  @override
  String get achievementsFirstStepsDesc =>
      'Completaste tu primera tarea en pareja.';

  @override
  String get achievementsUnstoppableTitle => 'Equipo Imparable';

  @override
  String get achievementsUnstoppableDesc => 'Completaron 50 tareas juntos.';

  @override
  String get achievementsHomeMastersTitle => 'Maestros del Hogar';

  @override
  String get achievementsHomeMastersDesc =>
      'Llegaron a los 5000 XP acumulados.';

  @override
  String get achievementsCollectorTitle => 'Coleccionista de Citas';

  @override
  String get achievementsLoveInMotionTitle => 'Amor en Movimiento';

  @override
  String get achievementsDeepConnectionTitle => 'Conexión Profunda';

  @override
  String get achievementsRomanceLegendsTitle => 'Leyendas del Romance';

  @override
  String get achievementsRomanceLegendsDesc =>
      '¡Completaron los 50 desafíos del año!';

  @override
  String achievementsSpecialChallengesDesc(int count) {
    return 'Completaron $count desafíos especiales.';
  }

  @override
  String get achievementsLoveRootsTitle => 'Raíces del Amor';

  @override
  String get achievementsLoveRootsDesc => 'Recrearon su primera cita.';

  @override
  String get achievementsBlindDateTitle => 'Cita a Ciegas';

  @override
  String get achievementsBlindDateDesc =>
      'Completaron una cena a ciegas o sensorial.';

  @override
  String get achievementsDreamArchitectsTitle => 'Arquitectos de Sueños';

  @override
  String get achievementsDreamArchitectsDesc =>
      'Diseñaron su lista de metas compartidas.';

  @override
  String get achievementsSoloMilestonesSection => 'Tus hitos';

  @override
  String get achievementsSoloFirstStepTitle => 'Primer paso';

  @override
  String get achievementsSoloFirstStepDesc =>
      'Completaste tu primera tarea en tu espacio.';

  @override
  String get achievementsSoloRoutineTitle => 'Rutina en marcha';

  @override
  String get achievementsSoloRoutineDesc => 'Completaste 50 tareas personales.';

  @override
  String get achievementsSoloHomeClearTitle => 'Casa más clara';

  @override
  String get achievementsSoloHomeClearDesc =>
      'Llegaste a 5000 XP construyendo tu ritmo.';

  @override
  String get achievementsSoloNextSection => 'Próximos hitos';

  @override
  String get achievementsSoloWeekTitle => 'Semana activa';

  @override
  String get achievementsSoloWeekDesc =>
      'Sostuviste varias acciones en tu hogar.';

  @override
  String get achievementsSoloRhythmTitle => 'Ritmo propio';

  @override
  String get achievementsSoloRhythmDesc =>
      'Tu rutina ya empieza a tener continuidad.';

  @override
  String get achievementsSoloOwnSpaceTitle => 'Espacio propio';

  @override
  String get achievementsSoloOwnSpaceDesc =>
      'Tu progreso personal ya tiene identidad.';

  @override
  String get scheduleTitle => 'Programar tarea';

  @override
  String get scheduleSubtitle => 'Elegí cómo se repite y quién queda a cargo.';

  @override
  String get scheduleSectionRepeat => 'REPETICIÓN';

  @override
  String get scheduleSectionResponsible => 'RESPONSABLE';

  @override
  String get scheduleRepeatNone => 'Ninguna';

  @override
  String get scheduleRepeatDaily => 'Diaria';

  @override
  String get scheduleRepeatWeekly => 'Semanal';

  @override
  String get scheduleRepeatMonthly => 'Mensual';

  @override
  String get scheduleRepeatCustom => 'Personalizada';

  @override
  String get scheduleWeeklyTitle => 'Elegí el día de la semana';

  @override
  String get scheduleWeeklySubtitle =>
      'La tarea se repetirá cada semana en ese día.';

  @override
  String get scheduleMonthlyTitle => 'Elegí el día del mes';

  @override
  String get scheduleMonthlySubtitle =>
      'La tarea se repetirá todos los meses en esa fecha.';

  @override
  String get scheduleCustomTabDays => 'Días';

  @override
  String get scheduleCustomTabInterval => 'Intervalo';

  @override
  String get scheduleCustomTabDate => 'Fecha';

  @override
  String get scheduleIntervalEvery => 'Cada';

  @override
  String get scheduleIntervalDecrease => 'Disminuir';

  @override
  String get scheduleIntervalIncrease => 'Aumentar';

  @override
  String scheduleIntervalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días',
      one: 'día',
    );
    return '$_temp0';
  }

  @override
  String get scheduleAssigneeAnyone => 'Cualquiera';

  @override
  String get scheduleAssigneeAnyoneSubtitle =>
      'Queda abierta para quien la quiera hacer.';

  @override
  String get scheduleAssigneeMemberSubtitle =>
      'Responsable principal de esta tarea.';

  @override
  String get scheduleAssigneeMemberFallback => 'Miembro';

  @override
  String get scheduleErrorPickWeekday =>
      'Elegí al menos un día para la repetición personalizada.';

  @override
  String get scheduleErrorPickMonthDay =>
      'Elegí al menos una fecha para repetir la tarea.';

  @override
  String get invitationTitle => 'Invitar al hogar';

  @override
  String get invitationSubtitleFamily => 'Compartí este código con tu familia.';

  @override
  String get invitationSubtitleFriends =>
      'Compartí este código con quienes viven con vos.';

  @override
  String get invitationSubtitleDefault =>
      'Compartí este código para que alguien se sume a tu hogar.';

  @override
  String get invitationTapToCopy => 'Tocá para copiar';

  @override
  String get invitationCopied => 'Código copiado al portapapeles';

  @override
  String get invitationShareWhatsApp => 'Compartir por WhatsApp';

  @override
  String get invitationRetry => 'Reintentar generar código';

  @override
  String get invitationIntroCouple =>
      '¡Hola! Sumate conmigo a HomeSync así organizamos las tareas y los gastos de la casa.';

  @override
  String get invitationIntroFamily =>
      '¡Hola! Te invito a sumarte a nuestro hogar familiar en HomeSync.';

  @override
  String get invitationIntroFriends =>
      '¡Hola! Sumate a nuestra convivencia en HomeSync así organizamos mejor la casa.';

  @override
  String get invitationIntroDefault =>
      '¡Hola! Te invito a sumarte a nuestro hogar en HomeSync.';

  @override
  String get avatarPickerTitle => 'Tu Identidad Visual';

  @override
  String get avatarPickerSubtitle =>
      'Elegí un avatar de la colección o creá el tuyo propio';

  @override
  String get avatarPickerUpdated => 'Avatar actualizado con exito';

  @override
  String avatarPickerUpdateError(String error) {
    return 'Error al actualizar avatar: $error';
  }

  @override
  String get avatarPickerPremiumSection => 'Avatares premium';

  @override
  String get avatarPickerYourCustomSection => 'Tus personalizados';

  @override
  String get avatarPickerCustomKeepHint =>
      'Guardamos los últimos 6 generados por IA.';

  @override
  String get avatarPickerCustomName => 'Personalizado';

  @override
  String get avatarPickerDeleteCustom => 'Eliminar avatar personalizado';

  @override
  String get avatarPickerDeleteCustomTitle => '¿Eliminar avatar?';

  @override
  String get avatarPickerDeleteCustomBody =>
      'Vas a eliminar este avatar personalizado. Si lo estás usando, volvemos al avatar básico.';

  @override
  String get avatarPickerCustomDeleted => 'Avatar personalizado eliminado';

  @override
  String avatarPickerCustomDeleteError(String error) {
    return 'No se pudo eliminar el avatar: $error';
  }

  @override
  String get avatarPickerCreateCustom =>
      'Crear avatar personalizado (1 por mes)';

  @override
  String get avatarPickerUnlockCustom => 'Desbloquear avatar personalizado';

  @override
  String get avatarPickerAiCardTitle => 'Tu avatar con IA';

  @override
  String get avatarPickerAiCardBody =>
      'Convertí una foto en un avatar ilustrado al estilo HomeSync. Tenés 1 creación por mes.';

  @override
  String get avatarPickerAiCreateButton => 'Crear mi avatar';

  @override
  String avatarPickerAiUsedThisMonth(String date) {
    return 'Ya creaste tu avatar de este mes. Vas a poder crear otro el $date.';
  }

  @override
  String get avatarPickerGooglePhotoTitle => 'Foto de Google';

  @override
  String get avatarPickerGooglePhotoSubtitle =>
      'Usá la imagen de tu cuenta de Google como avatar.';

  @override
  String get avatarPickerCustomSheetTitle => 'Avatar personalizado';

  @override
  String get avatarPickerCustomSheetBody =>
      'Tenés 1 creación por mes. Se guarda como avatar nuevo y conservamos tus últimos 6 personalizados. Si dejás Premium, quedan guardados pero bloqueados.';

  @override
  String get avatarPickerTakePhoto => 'Sacar foto';

  @override
  String get avatarPickerChooseFromGallery => 'Elegir de galería';

  @override
  String get avatarPickerCreatingTitle => 'Creando tu avatar...';

  @override
  String get avatarPickerCreatingSubtitle => 'Puede tardar unos segundos.';

  @override
  String settingsMemberRemoved(String name) {
    return '✅ $name ha sido quitado del hogar';
  }

  @override
  String get rewardCategoryTreats => 'Mimos';

  @override
  String get rewardCategoryMoments => 'Momentos';

  @override
  String get rewardCategoryPerks => 'Libertades';

  @override
  String get rewardCategoryExperiences => 'Experiencias';

  @override
  String get rewardCategoryFamily => 'Familia';

  @override
  String get rewardCategoryOther => 'Otros';

  @override
  String get rewardTemplateCoffeeMatePrepared => 'Café o mate preparado';

  @override
  String get rewardTemplateCoffeeMatePreparedDescription =>
      'Una pausa rica preparada con cariño';

  @override
  String get rewardTemplateSurpriseSnack => 'Snack sorpresa';

  @override
  String get rewardTemplateSurpriseSnackDescription =>
      'Un antojo inesperado para alegrar el día';

  @override
  String get rewardTemplateMiniRomanticNote => 'Mini nota romántica';

  @override
  String get rewardTemplateMiniRomanticNoteDescription =>
      'Un mensaje corto para sonreír';

  @override
  String get rewardTemplateMassage15Minutes => '15 minutos de masajes';

  @override
  String get rewardTemplateMassage15MinutesDescription =>
      'Masaje relajante de 15 minutos';

  @override
  String get rewardTemplateIceCreamChoice => 'Helado de tu elección';

  @override
  String get rewardTemplateIceCreamChoiceDescription =>
      'Un postre frío para celebrar';

  @override
  String get rewardTemplateMovieNightHome => 'Noche de cine en casa';

  @override
  String get rewardTemplateMovieNightHomeDescription =>
      'Película y ambiente especial en casa';

  @override
  String get rewardTemplateGamingAfternoon => 'Tarde de gaming';

  @override
  String get rewardTemplateGamingAfternoonDescription =>
      'Partida juntos con snacks incluidos';

  @override
  String get rewardTemplateBoardGameNight => 'Noche de juegos de mesa';

  @override
  String get rewardTemplateBoardGameNightDescription =>
      'Tiempo de juego y risas';

  @override
  String get rewardTemplateSpecialHomemadeDinner => 'Cena casera especial';

  @override
  String get rewardTemplateSpecialHomemadeDinnerDescription =>
      'Tu comida favorita hecha en casa';

  @override
  String get rewardTemplateHomePicnic => 'Picnic en casa';

  @override
  String get rewardTemplateHomePicnicDescription =>
      'Manta, algo rico y desconexión';

  @override
  String get rewardTemplateNoScreensNight => 'Noche sin pantallas';

  @override
  String get rewardTemplateNoScreensNightDescription =>
      'Tiempo de charla y conexión';

  @override
  String get rewardTemplateEpisodeMarathonChoice =>
      'Maratón de episodios a elección';

  @override
  String get rewardTemplateEpisodeMarathonChoiceDescription =>
      'Vos elegís la serie y el ritmo';

  @override
  String get rewardTemplateNoDishesVoucher => 'Vale por no lavar los platos';

  @override
  String get rewardTemplateNoDishesVoucherDescription =>
      'Hoy te salvás de esa tarea';

  @override
  String get rewardTemplateChooseMovieVoucher => 'Vale por elegir la peli';

  @override
  String get rewardTemplateChooseMovieVoucherDescription =>
      'Vos elegís qué ver';

  @override
  String get rewardTemplateChooseSeriesWeekVoucher =>
      'Vale por elegir la serie una semana';

  @override
  String get rewardTemplateChooseSeriesWeekVoucherDescription =>
      'Tu serie, tus reglas por 7 días';

  @override
  String get rewardTemplateWeekendPlanVoucher =>
      'Vale por decidir el plan del finde';

  @override
  String get rewardTemplateWeekendPlanVoucherDescription =>
      'Vos elegís el plan principal';

  @override
  String get rewardTemplateSkipOneChoreVoucher =>
      'Vale por no hacer una tarea puntual';

  @override
  String get rewardTemplateSkipOneChoreVoucherDescription =>
      'Elegís una tarea para delegar';

  @override
  String get rewardTemplateYesToAnyPlanVoucher =>
      'Vale por “sí a cualquier plan”';

  @override
  String get rewardTemplateYesToAnyPlanVoucherDescription =>
      'Hoy tu idea se cumple';

  @override
  String get rewardTemplateDinnerOut => 'Cena afuera';

  @override
  String get rewardTemplateDinnerOutDescription =>
      'Salida a cenar a un lugar especial';

  @override
  String get rewardTemplatePlannedDate => 'Cita planeada completa';

  @override
  String get rewardTemplatePlannedDateDescription =>
      'Plan completo organizado de principio a fin';

  @override
  String get rewardTemplateChoreFreeDay => 'Día libre de tareas';

  @override
  String get rewardTemplateChoreFreeDayDescription =>
      'Cero obligaciones por todo el día';

  @override
  String get rewardTemplateExtraScreen15Minutes =>
      '15 minutos extra de pantalla';

  @override
  String get rewardTemplateExtraScreen15MinutesDescription =>
      'Un ratito más para jugar o mirar algo.';

  @override
  String get rewardTemplateChooseDinner => 'Elegir la cena';

  @override
  String get rewardTemplateChooseDinnerDescription =>
      'Decidir el menú de una noche en casa.';

  @override
  String get rewardTemplateIceCreamForEveryone => 'Helado para todos';

  @override
  String get rewardTemplateIceCreamForEveryoneDescription =>
      'Salida o pedido de helado familiar.';

  @override
  String get rewardTemplateSmallToyPrize => 'Juguete o premio pequeño';

  @override
  String get rewardTemplateSmallToyPrizeDescription =>
      'Canje por algo simple elegido con un adulto.';

  @override
  String get rewardTemplateFamilyMovieNight => 'Noche de peli';

  @override
  String get rewardTemplateFamilyMovieNightDescription =>
      'Plan simple para disfrutar todos juntos.';

  @override
  String get rewardTemplateOrderTakeout => 'Pedir comida';

  @override
  String get rewardTemplateOrderTakeoutDescription =>
      'Una noche sin cocinar para toda la familia.';

  @override
  String get rewardTemplateWeekendFamilyPlan => 'Plan del fin de semana';

  @override
  String get rewardTemplateWeekendFamilyPlanDescription =>
      'Elegir una salida o actividad para hacer juntos.';

  @override
  String get rewardTemplateSpecialDessert => 'Postre especial';

  @override
  String get rewardTemplateSpecialDessertDescription =>
      'Elegir un postre favorito para después de cenar.';

  @override
  String get errorGeneric => 'Algo salió mal. Probá de nuevo en un momento.';

  @override
  String get errorOffline =>
      'Sin conexión. Verificá tu red e intentá de nuevo.';

  @override
  String get errorTooManyRequests =>
      'Demasiadas solicitudes. Reintentá en un momento.';

  @override
  String get errorServerUnreachable =>
      'No pudimos conectar con el servidor. Verificá tu red.';

  @override
  String get errorTimeout => 'La operación tardó demasiado. Probá de nuevo.';

  @override
  String get errorNetworkCheckConnection => 'Error de red: revisá tu conexión';

  @override
  String get errorUnexpected => 'Ha ocurrido un error inesperado';

  @override
  String get errorOfflineQueued => 'Estás offline. Acción guardada para luego.';

  @override
  String get errorNotAuthenticated => 'Usuario no autenticado';

  @override
  String get errorHouseholdNotFound => 'Hogar no encontrado';

  @override
  String get avatarErrorImageTooLarge =>
      'La imagen es demasiado grande. Probá con otra foto.';

  @override
  String get avatarErrorSessionExpired =>
      'Sesión expirada. Iniciá sesión nuevamente.';

  @override
  String get avatarErrorTimeout =>
      'La generación tardó demasiado. Probá de nuevo en un momento.';

  @override
  String get avatarErrorMonthlyLimit =>
      'Ya usaste tu creación de avatar de este mes. Vas a poder crear otro el mes que viene.';

  @override
  String get avatarErrorPremiumRequired =>
      'Esta función es para usuarios Premium.';

  @override
  String get avatarErrorCreateFailed =>
      'No se pudo crear el avatar. Probá de nuevo.';

  @override
  String get avatarErrorInvalidResult =>
      'El generador no devolvió un avatar válido.';

  @override
  String get avatarErrorDeleteFailed =>
      'No se pudo eliminar el avatar. Probá de nuevo.';

  @override
  String get avatarErrorSaveFailed => 'No se pudo guardar el avatar generado.';

  @override
  String editTaskDeleteBody(String title) {
    return 'Se va a eliminar \"$title\" y no se puede deshacer.';
  }

  @override
  String get notifTaskAssignedTitle => 'Nueva tarea asignada';

  @override
  String notifTaskAssignedBody(String actor, String task) {
    return '$actor te asignó la tarea: $task';
  }

  @override
  String get notifTaskCompletedTitle => 'Tarea completada';

  @override
  String notifTaskCompletedBody(String actor, String task) {
    return '$actor completó: $task';
  }

  @override
  String get notifTaskPendingApprovalTitle => 'Tarea pendiente de aprobación';

  @override
  String notifTaskPendingApprovalBody(String actor, String task) {
    return '$actor completó \"$task\"';
  }

  @override
  String get notifTaskApprovedTitle => 'Tarea aprobada';

  @override
  String notifTaskApprovedBody(String task, int coins) {
    return '\"$task\" fue aprobada. Ganaste $coins coins.';
  }

  @override
  String get notifTaskRejectedTitle => 'Tarea no aprobada';

  @override
  String notifTaskRejectedBody(String task) {
    return 'Tu tarea \"$task\" necesita ajustes.';
  }

  @override
  String get notifExpenseAddedTitle => 'Nuevo movimiento';

  @override
  String notifExpenseAddedBody(
      String actor, String kind, String title, String amount) {
    String _temp0 = intl.Intl.selectLogic(
      kind,
      {
        'groceries': 'compró en',
        'other': 'gastó en',
      },
    );
    return '$actor $_temp0 $title ($amount)';
  }

  @override
  String get notifSettlementTitle => '¡Deuda saldada!';

  @override
  String notifSettlementBody(String actor, String amount) {
    return '$actor saldó su deuda de $amount';
  }

  @override
  String get notifWeeklySummaryTitle => 'Tu resumen semanal está listo';

  @override
  String get notifWeeklySummaryBody =>
      'Mirá cómo cerró la semana del hogar: cumplimiento, MVP y gastos.';

  @override
  String notifPlannedUpcomingTitle(String title) {
    return 'Pago próximo: $title';
  }

  @override
  String notifPlannedUpcomingBody(String date, String amount) {
    return 'Vence el $date - $amount';
  }

  @override
  String notifPlannedDueTitle(String title) {
    return 'Vence hoy: $title';
  }

  @override
  String notifPlannedDueBody(String amount) {
    return 'Registralo desde Finanzas cuando lo pagues - $amount';
  }

  @override
  String get financeOnlyConfirmTitle => 'Confirmar cambio';

  @override
  String financeOnlyConfirmBody(String action) {
    String _temp0 = intl.Intl.selectLogic(
      action,
      {
        'enable': 'activar',
        'other': 'desactivar',
      },
    );
    return 'Al $_temp0 el modo \"Solo finanzas\", TODOS los miembros del hogar verán solo funcionalidades financieras (sin tareas, compras, etc.). Esta configuración se aplica a todo el hogar.';
  }

  @override
  String get activityFallbackTitle => 'Actividad';

  @override
  String get activitySettlementTitle => 'Balance equilibrado';

  @override
  String get activityTimeNow => 'Ahora';

  @override
  String activityTimeMinutesAgo(int minutes) {
    return 'Hace ${minutes}m';
  }

  @override
  String activityTimeHoursAgo(int hours) {
    return 'Hace ${hours}h';
  }

  @override
  String get activityTimeDoneYesterday => 'Hecha ayer';

  @override
  String activityTimeDoneDaysAgo(int days) {
    return 'Hecha hace $days días';
  }

  @override
  String get homeLoadingStart => 'Cargando inicio...';

  @override
  String get homeLoadingHousehold => 'Cargando hogar...';

  @override
  String get homeErrorLoadHousehold => 'No pudimos cargar tu hogar.';

  @override
  String get homeNoHouseholdTitle => 'No perteneces a un hogar todavía';

  @override
  String get homeNoHouseholdSubtitle =>
      'Creá o unite a un hogar para comenzar.';

  @override
  String get mainIdentityLoadError =>
      'Error de carga de identidad. Intentá salir de la app y volver a entrar:';

  @override
  String get notifLoveNoteTitle => '💌 Tenés una nota especial';

  @override
  String get notifLoveNoteBody => 'Tu pareja te mandó una nota de amor ❤️';

  @override
  String get contributionTitle => 'Cómo se repartió';

  @override
  String get contributionEmpty =>
      'Todavía no hay tareas completadas esta semana.';

  @override
  String get contributionRhythmLabel => 'Ritmo del hogar';

  @override
  String contributionRhythmValue(int weeks, int window) {
    return '$weeks de las últimas $window semanas';
  }

  @override
  String contributionTasksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
      zero: 'sin tareas',
    );
    return '$_temp0';
  }

  @override
  String contributionDemandingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de las pesadas',
      one: '1 de las pesadas',
      zero: 'ninguna de las pesadas',
    );
    return '$_temp0';
  }

  @override
  String coupleWeekOf(String date) {
    return 'Semana del $date';
  }

  @override
  String get coupleWeekYou => 'Vos';

  @override
  String coupleWeekSplitSemantics(int mine, String name, int theirs) {
    return 'Reparto de la semana: vos $mine, $name $theirs.';
  }

  @override
  String get coupleWeekReadingBalanced =>
      'Viene parejo: se repartieron bien la semana.';

  @override
  String coupleWeekReadingCategoryPartner(String category, String name) {
    return '$category: esta semana lo hizo casi todo $name.';
  }

  @override
  String coupleWeekReadingCategoryMe(String category) {
    return '$category: esta semana lo hiciste casi todo vos.';
  }

  @override
  String coupleWeekReadingOverallPartner(String name) {
    return 'Esta semana la mayoría de las tareas las hizo $name.';
  }

  @override
  String get coupleWeekReadingOverallMe =>
      'Esta semana la mayoría de las tareas las hiciste vos.';

  @override
  String get coupleWeekProposeTurns => 'Proponer turnarse';

  @override
  String get coupleWeekOfferHand => 'Ofrecer una mano';

  @override
  String coupleWeekTurnsProposalTitle(String category) {
    return '¿Nos turnamos con $category?';
  }

  @override
  String coupleWeekOfferProposalTitle(String category) {
    return 'Esta semana me encargo yo de $category';
  }

  @override
  String get coupleWeekTurnsProposalTitleGeneral =>
      '¿Nos repartimos mejor las tareas de la semana?';

  @override
  String get coupleWeekOfferProposalTitleGeneral =>
      'Esta semana me pongo con más tareas';

  @override
  String get coupleWeekSeeTasks => 'Ver tareas';

  @override
  String coupleWeekRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count tareas para esta semana',
      one: 'Queda 1 tarea para esta semana',
      zero: 'No queda nada pendiente esta semana',
    );
    return '$_temp0';
  }

  @override
  String coupleWeekOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vencidas',
      one: '1 vencida',
    );
    return '$_temp0';
  }

  @override
  String get coupleWeekMoneyTitle => 'La plata';

  @override
  String get coupleWeekMoneySeeAll => 'Ver movimientos';

  @override
  String get coupleWeekMoneyEven => 'Están a mano.';

  @override
  String coupleWeekMoneyYouOwe(String amount, String name) {
    return 'Le debés $amount a $name.';
  }

  @override
  String coupleWeekMoneyTheyOwe(String name, String amount) {
    return '$name te debe $amount.';
  }

  @override
  String coupleWeekMoneyPaid(String mine, String name, String theirs) {
    return 'Este mes pusiste $mine y $name puso $theirs en gastos compartidos.';
  }

  @override
  String get coupleWeekMoneyNoExpenses =>
      'Todavía no cargaron gastos compartidos este mes.';

  @override
  String coupleWeekMoneySharedTotal(String amount) {
    return 'Este mes gastaron $amount entre los dos.';
  }

  @override
  String coupleWeekMoneySharedPaid(String mine, String name, String theirs) {
    return 'Pagaste $mine · $name pagó $theirs';
  }

  @override
  String get coupleWeekMoneySettle => 'Saldar';

  @override
  String get coupleWeekMoneyRecordPayment => 'Registrar pago';

  @override
  String get coupleWeekMoneyError => 'No pudimos cargar la plata de este mes.';

  @override
  String get coupleWeekAsksTitle => 'Entre ustedes';

  @override
  String get coupleWeekAsksSubtitle =>
      'Planes, pedidos y charlas pendientes. Siempre se puede decir “ahora no”.';

  @override
  String get coupleWeekAsksEmpty => 'Nada pendiente entre ustedes.';

  @override
  String coupleWeekAsksEmptyHint(String action) {
    return 'Para pedir una mano o proponer un plan, tocá “$action”.';
  }

  @override
  String get coupleWeekAskToAnswer => 'Te toca responder';

  @override
  String coupleWeekAskWaiting(String name) {
    return 'Esperando a $name';
  }

  @override
  String coupleWeekAskFrom(String name, String when) {
    return 'De $name · $when';
  }

  @override
  String coupleWeekAskFromYou(String when) {
    return 'Tuya · $when';
  }

  @override
  String coupleWeekNoteTitle(String name) {
    return 'Una nota para $name';
  }

  @override
  String get coupleWeekNoteBody =>
      'Le llega como un sobre al inicio de su app.';

  @override
  String coupleProposalPushTitle(String name) {
    return '$name te propuso algo';
  }

  @override
  String coupleProposalAnsweredPushTitle(String name) {
    return '$name respondió tu propuesta';
  }

  @override
  String coupleProposalAnsweredPushBody(String answer, String title) {
    return '$answer: $title';
  }

  @override
  String loveNotePushTitle(String name) {
    return '💌 $name te dejó una nota';
  }

  @override
  String get loveNotePushBody => 'Abrí HomeSync para leerla.';

  @override
  String loveNoteEnvelopeFrom(String name) {
    return '$name te escribió';
  }

  @override
  String get loveNoteEnvelopeSaved => 'Guardada en el hogar';

  @override
  String get partnerInviteTitle => 'Esto se disfruta de a dos';

  @override
  String get partnerInviteBody =>
      'Cuando se sume tu pareja, acá van a ver cómo se repartió la semana, la plata entre ustedes y lo que se proponen.';

  @override
  String get partnerInviteCodeLabel => 'Código para tu pareja';

  @override
  String partnerInviteCodeSemantics(String code) {
    return 'Código de invitación $code. Tocá para copiarlo.';
  }

  @override
  String get partnerInviteShare => 'Invitar por WhatsApp';

  @override
  String get partnerInviteShareOther => 'Compartir por otra app';

  @override
  String get partnerInviteCopy => 'Copiar código';

  @override
  String get partnerInviteMessageCopied =>
      'Copiamos la invitación: pegala donde quieras.';

  @override
  String get partnerInviteHint =>
      'Tiene que bajar HomeSync, tocar “Tengo un código” y poner este.';

  @override
  String get partnerInviteHomeTitle => 'Falta que se sume tu pareja';

  @override
  String get partnerInviteHomeBody =>
      'Mandale el código y empiecen a repartir tareas y gastos.';

  @override
  String get partnerInviteHomeAction => 'Invitar';

  @override
  String invitationShareMessage(String intro, String link, String code) {
    return '$intro\n\n1. Bajate HomeSync: $link\n2. Tocá “Tengo un código” y poné: *$code*';
  }

  @override
  String get setupStartTitle => 'Tareas y gastos de la casa, parejos.';

  @override
  String get setupStartBody =>
      'Repartan las tareas, anoten quién pagó qué y vean cómo quedan, sin planillas ni discusiones.';

  @override
  String get setupStartBulletTasks =>
      'Las tareas de la casa, a la vista de los dos';

  @override
  String get setupStartBulletMoney =>
      'Gastos compartidos y el saldo siempre al día';

  @override
  String get setupStartBulletWeek => 'Un repaso semanal de cómo se repartieron';

  @override
  String get setupStartCreate => 'Empezar mi hogar';

  @override
  String get setupStartJoin => 'Tengo un código';

  @override
  String get setupStartJoinTitle => 'Unirte a un hogar';

  @override
  String get setupStartJoinBody =>
      'Poné el código de 6 caracteres que te mandaron.';

  @override
  String get setupStartJoinNameLabel => '¿Cómo te llamás?';

  @override
  String get setupStartJoinCodeLabel => 'Código';

  @override
  String get setupStartJoinButton => 'Unirme';

  @override
  String get setupStartTime => 'Te lleva menos de un minuto.';

  @override
  String get setupHouseholdTitle => 'Contanos de tu casa';

  @override
  String get setupHouseholdSubtitle =>
      'Con esto adaptamos la app a cómo viven.';

  @override
  String get setupHouseholdModeLabel => '¿Con quién compartís la casa?';

  @override
  String get setupHouseholdNameLabel => 'Tu nombre';

  @override
  String get setupHouseholdFinanceNote =>
      'Arrancan dividiendo los gastos 50/50. Lo pueden cambiar cuando quieran en Ajustes.';

  @override
  String setupFamilyHouseholdNameFor(String name) {
    return '$name y familia';
  }

  @override
  String setupInviteTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Sumá a tu pareja',
        'family': 'Sumá a tu familia',
        'friends': 'Sumá a quienes viven con vos',
        'other': 'Sumá a alguien más',
      },
    );
    return '$_temp0';
  }

  @override
  String setupInviteBody(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple':
            'HomeSync funciona de a dos: cuando se sume, van a ver las tareas, la plata y el repaso de la semana juntos.',
        'family':
            'Cuando se sumen, cada uno va a ver lo que le toca y lo que se comparte.',
        'friends':
            'Cuando se sumen, van a tener las tareas y las cuentas claras entre todos.',
        'other': 'Compartí el código para que se sumen a tu hogar.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupInviteCodeLabel => 'Tu código de invitación';

  @override
  String setupInviteHint(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family':
            'Tienen que bajar HomeSync, tocar “Tengo un código” y poner este.',
        'friends':
            'Tienen que bajar HomeSync, tocar “Tengo un código” y poner este.',
        'other':
            'Tiene que bajar HomeSync, tocar “Tengo un código” y poner este.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupInviteLater => 'Lo hago después';

  @override
  String get setupInviteDone => 'Listo, ya lo mandé';

  @override
  String get homeNextStepExpenseTitle => 'Carguen el primer gasto compartido';

  @override
  String get homeNextStepExpenseBody =>
      'Así la app lleva la cuenta de quién puso qué.';

  @override
  String get homeNextStepExpenseAction => 'Cargar';

  @override
  String get premiumProductsUnavailableTitle => 'No pudimos cargar los planes';

  @override
  String get premiumProductsUnavailableBody =>
      'Revisá tu conexión y probá de nuevo. Si ya pagaste, restaurá tu compra.';

  @override
  String get premiumRestoreNothing => 'No encontramos compras para restaurar.';

  @override
  String get premiumRestoreError =>
      'No pudimos restaurar la compra. Probá de nuevo.';

  @override
  String coupleWeekReadingEarly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Van $count tareas esta semana: es temprano para leer el reparto.',
      one: 'Va 1 tarea esta semana: es temprano para leer el reparto.',
    );
    return '$_temp0';
  }

  @override
  String get balanceCardRecordPaymentButton => 'Registrar pago';

  @override
  String get homeActivityLoadError => 'No pudimos cargar la actividad.';

  @override
  String get expensesSummaryLoadError =>
      'No pudimos cargar el resumen del mes.';

  @override
  String get expensesFeedLoadError => 'No pudimos cargar los movimientos.';

  @override
  String get premiumBenefitBudgetsRecap => 'Presupuestos y resumen del mes';

  @override
  String get premiumBenefitBudgetsRecapDesc =>
      'Poné topes por categoría y mirá el cierre de cada mes: en qué se fue la plata y quién puso qué.';

  @override
  String get currencyNameArs => 'Peso argentino';

  @override
  String get currencyNameUsd => 'Dólar estadounidense';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameBrl => 'Real brasileño';

  @override
  String get currencyNameClp => 'Peso chileno';

  @override
  String get currencyNameUyu => 'Peso uruguayo';

  @override
  String get categoryLabelHome => 'Hogar';

  @override
  String get categoryLabelOther => 'Otros';

  @override
  String weeklySummaryTasksDoneBody(int planned, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      planned,
      locale: localeName,
      other: '$done de $planned tareas completadas.',
      one: '$done de 1 tarea completada.',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryCompletionTitle(int planned, int done, int pct) {
    String _temp0 = intl.Intl.pluralLogic(
      planned,
      locale: localeName,
      other: '$done de $planned tareas · $pct%',
      one: '$done de 1 tarea · $pct%',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryVsLastWeek(String delta) {
    return '$delta vs. la semana anterior';
  }

  @override
  String weeklySummaryExpensesThisWeek(String amount) {
    return '$amount esta semana';
  }

  @override
  String weeklySummaryTopCategoryBody(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount en $count gastos.',
      one: '$amount en 1 gasto.',
    );
    return '$_temp0';
  }

  @override
  String get coachmarkSkip => 'Saltar';

  @override
  String get activityBubbleHouseholdExpense => 'Gasto del hogar';

  @override
  String get activityBubbleSettlement => 'Equilibrio';

  @override
  String savingsSuggesterCompleteMessage(String amount, String goal) {
    return 'Según tu plan, este mes te sobra plata: con $amount completás tu meta \"$goal\".';
  }

  @override
  String get expenseSplitErrorNoMembers =>
      'Elegí al menos una persona para dividir el gasto.';

  @override
  String expenseSplitErrorFixedTotal(String amount) {
    return 'Los montos del reparto tienen que sumar el total ($amount).';
  }

  @override
  String familyTaskCardMarkedDoneBy(String name) {
    return '$name la marcó como hecha';
  }

  @override
  String get familyTaskCardReadyToReview => 'Lista para revisar';

  @override
  String get familyTaskCardAwaitingApproval => 'Esperando aprobación';

  @override
  String get familyTaskCardAwaitingAdult => 'Esperando que un adulto la revise';

  @override
  String get familyTaskCardUnassignedOverdue => 'Pendiente de coordinar';

  @override
  String get familyTaskCardUnassignedToday => 'A coordinar';

  @override
  String get familyTaskCardMyMissionOverdue => 'Tu misión pendiente';

  @override
  String get familyTaskCardMyMission => 'Tu misión';

  @override
  String get familyTaskCardMineOverdue => 'Te quedó pendiente';

  @override
  String get familyTaskCardMineToday => 'Te toca hoy';

  @override
  String get familyTaskCardOtherOverdue => 'Le quedó a otro integrante';

  @override
  String get familyTaskCardOther => 'Para otro integrante';

  @override
  String familyTaskCardNamedOverdue(String name) {
    return 'Le quedó a $name';
  }

  @override
  String familyTaskCardNamed(String name) {
    return 'Para $name';
  }

  @override
  String get familyTaskCardUrgencyReview => 'Revisar';

  @override
  String get familyTaskCardUrgencyInReview => 'En revisión';

  @override
  String get familyTaskCardUrgencyOverdue => 'Vencida';

  @override
  String get familyTaskCardUrgencyToday => 'Hoy';

  @override
  String get familyTaskCardUrgencyUpcoming => 'Próxima';

  @override
  String familyTaskCardRotation(int count) {
    return 'Rota entre $count';
  }

  @override
  String familyFeedSettled(String name) {
    return '$name equilibró la cuenta';
  }

  @override
  String familyFeedLeftReady(String name) {
    return '$name dejó lista';
  }

  @override
  String familyFeedCompleted(String name) {
    return '$name completó';
  }

  @override
  String familyFeedAddedExpense(String name) {
    return '$name registró un gasto';
  }

  @override
  String familyFeedDidSomething(String name) {
    return '$name hizo algo en el hogar';
  }

  @override
  String get familyFeedSomeone => 'Alguien';

  @override
  String familyFeedWaitingReview(String name) {
    return '$name espera revisión de';
  }

  @override
  String get familyFeedTaskNotFound => 'No encontramos esa tarea para revisar.';

  @override
  String get familyFeedApproveFailed => 'No pudimos aprobar la tarea.';

  @override
  String get familyFeedApproved => 'Tarea aprobada.';

  @override
  String get familyFeedReturnFailed => 'No pudimos devolver la tarea.';

  @override
  String get familyFeedReturned => 'La tarea volvió para corregir.';

  @override
  String get familyFeedReturn => 'Devolver';

  @override
  String get familyFeedApprove => 'Aprobar';

  @override
  String familyFeedCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins',
      one: '1 coin',
    );
    return '$_temp0';
  }

  @override
  String familyTasksMoreOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count tareas atrasadas más.',
      one: 'Hay 1 tarea atrasada más.',
    );
    return '$_temp0';
  }

  @override
  String familyFeedRedeemedReward(String name) {
    return '$name canjeó un premio';
  }

  @override
  String get settingsPaletteOrange => 'Naranja';

  @override
  String get settingsPaletteDark => 'Oscuro';

  @override
  String get settingsPaletteIndigo => 'Índigo';

  @override
  String get settingsPaletteRose => 'Rosa';

  @override
  String get settingsPaletteEmerald => 'Esmeralda';

  @override
  String get settingsPaletteViolet => 'Violeta';

  @override
  String get settingsPaletteAmber => 'Ámbar';

  @override
  String get settingsPaletteCyan => 'Cian';

  @override
  String settingsPaletteLocked(String name) {
    return '$name, requiere Premium';
  }

  @override
  String get expensesFormAmountTotalLabel => 'Monto total';

  @override
  String get estimatedIncomeSheetTitle => 'Ingreso mensual estimado';

  @override
  String get estimatedIncomeSheetSubtitle =>
      'Solo para calcular tu balance. No crea movimientos.';

  @override
  String get estimatedIncomeSheetAmountEyebrow => 'MONTO NETO MENSUAL';

  @override
  String get estimatedIncomeSheetPaydayEyebrow => 'DÍA DE COBRO';

  @override
  String get estimatedIncomeSheetRemove => 'Quitar ingreso estimado';

  @override
  String estimatedIncomeSheetDayLabel(int day) {
    return 'Día $day';
  }

  @override
  String get homeFamilyActivityErrorBody =>
      'No pudimos cargar la actividad del hogar.';
}
