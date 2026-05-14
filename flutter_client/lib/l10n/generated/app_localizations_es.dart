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
        'friends': 'Convivencia',
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
        'couple': 'Desafios, premios y pequenas recompensas para compartir.',
        'family':
            'Coordinacion, miembros y acuerdos del hogar para toda la familia.',
        'friends': 'Organizacion, convivencia y reparto claro para el piso.',
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
        'friends': 'Companeros',
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
        'friends': 'con tus companeros',
        'solo': 'conmigo',
        'other': 'conmigo',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsAppBarTitle => 'Configuracion';

  @override
  String get settingsBackTooltip => 'Volver';

  @override
  String get settingsSectionProfileEyebrow => 'PERFIL';

  @override
  String get settingsSectionProfileTitle => 'Tu espacio';

  @override
  String get settingsSectionProfileSubtitle =>
      'Avatar, nombre y datos basicos de tu cuenta.';

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
  String get settingsSectionAccountTitle => 'Sesion y seguridad';

  @override
  String get settingsSectionAccountSubtitle =>
      'Salir de la cuenta o reiniciar tus datos si lo necesitas.';

  @override
  String get settingsSectionLegalEyebrow => 'LEGAL';

  @override
  String get settingsSectionLegalTitle => 'Privacidad';

  @override
  String get settingsSectionLegalSubtitle =>
      'Politica de privacidad y terminos de uso.';

  @override
  String get settingsAppearanceTitle => 'Apariencia';

  @override
  String get settingsAppearanceSubtitle => 'Elige el tema visual de la app';

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
  String get settingsPremiumActiveSubtitle => 'Premium activo';

  @override
  String get settingsPremiumInactiveSubtitle => 'Funciones avanzadas';

  @override
  String get settingsPremiumFeatureShoppingFinanceSync =>
      'Sincronizacion Shopping a Finanzas';

  @override
  String get settingsPremiumFeatureRecurringPayments =>
      'Pagos Recurrentes (Suscripciones)';

  @override
  String get settingsPremiumFeatureLoveNotes => 'Notas de Amor en Dashboard';

  @override
  String get settingsPremiumFeatureExclusiveAvatars => 'Avatares Exclusivos';

  @override
  String get settingsMinorPremiumTitle => 'Funciones Premium';

  @override
  String get settingsMinorPremiumChildBody =>
      'Pedi a tus papas que activen el plan para desbloquear avatares exclusivos, colores y mas 🌟';

  @override
  String get settingsMinorPremiumAdultBody =>
      'Los adultos del hogar pueden activar el plan premium para desbloquear funciones adicionales.';

  @override
  String get settingsReplayTourTitle => 'Ver guia de nuevo';

  @override
  String get settingsReplayTourSubtitle => 'Repasa la introduccion del hogar';

  @override
  String get settingsFeedbackTitle => 'Enviar feedback';

  @override
  String get settingsFeedbackSubtitle => 'Reporta un bug o sugiere una mejora';

  @override
  String get settingsLegalPrivacyPolicy => 'Politica de Privacidad';

  @override
  String get settingsLegalTermsOfUse => 'Terminos de Uso';

  @override
  String get settingsNotificationsEnabled => '🔔 Notificaciones activadas';

  @override
  String get settingsNotificationsDisabled => '🔕 Notificaciones desactivadas';

  @override
  String get settingsProfileNameUpdated => '✅ Nombre actualizado';

  @override
  String get settingsAccountReset => '✅ Datos reiniciados y hogar liberado';

  @override
  String get settingsNotificationsTitle => 'Notificaciones';

  @override
  String get settingsNotificationsSubtitle =>
      'Recibe avisos de gastos y tareas';

  @override
  String get settingsFaqTitle => 'Preguntas Frecuentes';

  @override
  String get settingsFaqSubtitle => 'Aprende como funciona HomeSync';

  @override
  String get settingsLogoutButton => 'Cerrar Sesion';

  @override
  String get settingsDangerZoneEyebrow => 'ZONA DE PELIGRO';

  @override
  String get settingsResetAccountButton => 'Reiniciar Datos de Cuenta';

  @override
  String get settingsFeedbackBugTitle => 'Reportar un error';

  @override
  String get settingsFeedbackBugSubtitle => 'Algo no funciona bien? Avisanos';

  @override
  String get settingsFeedbackSuggestionTitle => 'Sugerir una mejora';

  @override
  String get settingsFeedbackSuggestionSubtitle =>
      'Tenes una idea? Nos encanta escucharte';

  @override
  String get settingsLogoutDialogTitle => 'Cerrar sesión?';

  @override
  String get settingsLogoutDialogBody =>
      'Vas a tener que iniciar sesión de nuevo para acceder a tu hogar.';

  @override
  String get settingsLogoutDialogConfirm => 'Salir';

  @override
  String get settingsResetDialogTitle => 'Reiniciar todo?';

  @override
  String get settingsResetDialogBody =>
      'Esta accion borrara todas tus tareas, gastos y progreso de forma permanente, y te quitara del hogar actual para que puedas configurar uno nuevo o unirte a otro.';

  @override
  String get settingsResetDialogConfirm => 'Reiniciar';

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
  String get homeViewWeekButton => 'Ver Semana';

  @override
  String get homeAllDoneToday => 'Todo listo por hoy';

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
  String get homeSoloTasksTitle => 'Tus tareas';

  @override
  String get homeSoloAddTaskButton => 'Agregar tarea';

  @override
  String get homeSoloActivityTitle => 'Tu actividad';

  @override
  String get homeCoupleHeadlineSecondary => 'del hogar';

  @override
  String get homeCoupleHeadlineConnector => 'con';

  @override
  String get homeCouplePartnerFallback => 'tu pareja';

  @override
  String get homeCoupleShoppingListTitle => 'Lista actual';

  @override
  String get homeCoupleTasksTitle => 'Hoy en casa';

  @override
  String get homeCoupleActivityTitle => 'Movimientos del hogar';

  @override
  String get homeCoupleActivityEmptyTitle => 'Todavia no hay movimientos';

  @override
  String get homeCoupleActivityEmptyBody =>
      'Cuando haya una tarea o un gasto nuevo, aparece aca.';

  @override
  String get homeCoupleSettlementErrorNoUser =>
      'No pudimos identificar tu usuario.';

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
      'No pudimos completar la tarea. Intenta de nuevo.';

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
  String get homeFamilyMemberNotFound =>
      'No encontramos tu perfil en este hogar.';

  @override
  String get homeFamilyMetricCoins => 'Monedas';

  @override
  String get homeFamilyAdultFallbackName => 'Familia';

  @override
  String get homeFamilyChildHello => 'Hola, ';

  @override
  String get homeFamilyChildFallbackName => 'campeon';

  @override
  String get homeFamilyChildHeroTitle => 'Aventura de hoy';

  @override
  String homeFamilyChildHeroBody(String firstName) {
    return '$firstName, cada mision aprobada suma coins para la tienda.';
  }

  @override
  String get homeFamilyChildRewardsPrompt => 'Mira que premios podes alcanzar.';

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
  String get homeFamilyShoppingAllDone => 'Lista al dia';

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
  String get familyTasksEmptyTitle => 'Todo al dia';

  @override
  String get familyTasksEmptyChildSubtitle =>
      'Hoy podes descansar o mirar la tienda.';

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
  String get setupValuePropEyebrow => 'Tu hogar, sincronizado';

  @override
  String get setupValuePropTagline => 'El hogar mejor organizado empieza aquí.';

  @override
  String get setupValuePropStartButton => 'Comenzar';

  @override
  String get setupValuePropTimeHint => 'Te llevará menos de 2 minutos';

  @override
  String get setupFeatureTasksTitle => 'Tareas compartidas';

  @override
  String get setupFeatureTasksDesc =>
      'Organizá tareas del hogar y repartí responsabilidades sin fricción.';

  @override
  String get setupFeatureExpensesTitle => 'Gastos en equipo';

  @override
  String get setupFeatureExpensesDesc =>
      'Registrá gastos, dividí cuentas y mantené el balance siempre claro.';

  @override
  String get setupFeatureGamificationTitle => 'Gamificación real';

  @override
  String get setupFeatureGamificationDesc =>
      'Convertí la organización diaria en progreso, premios y motivación.';

  @override
  String get setupFeatureShoppingTitle => 'Compras sincronizadas';

  @override
  String get setupFeatureShoppingDesc =>
      'Listas compartidas en tiempo real para que nadie compre dos veces.';

  @override
  String get setupWelcomeTitle => '¡Bienvenido!';

  @override
  String get setupWelcomeBody =>
      'Vamos a dejar tu hogar listo para empezar con tareas, gastos y compras compartidas desde el primer día.';

  @override
  String get setupWelcomeBulletQuick =>
      'Configuración rápida de menos de 1 minuto.';

  @override
  String get setupWelcomeBulletJoin =>
      'Podés crear un hogar nuevo o sumarte con un código.';

  @override
  String get setupWelcomeStartButton => 'Configurar mi hogar';

  @override
  String get setupProfileEyebrow => 'Tu perfil';

  @override
  String get setupProfileTitle => '¿Cómo te llamas?';

  @override
  String get setupProfileSubtitle =>
      'Personalizá tu perfil para que tu equipo te identifique mejor.';

  @override
  String get setupProfileGoogleAvatarHint =>
      'Usamos tu foto de Google como punto de partida. Si querés, podés cambiarla por uno de nuestros avatares.';

  @override
  String get setupProfileEmptyAvatarHint =>
      'Elegí un avatar y un nombre para empezar con una identidad clara dentro del hogar.';

  @override
  String get setupProfileAvatarLabel => 'Avatar';

  @override
  String get setupModePickerEyebrow => 'Tipo de hogar';

  @override
  String get setupModePickerTitle => '¡Comencemos!';

  @override
  String get setupModePickerSubtitle => '¿Cómo vas a organizar tu hogar?';

  @override
  String get setupSignOutLink => 'Cerrar sesión';

  @override
  String get setupSeeFeaturesLink => 'Ver características';

  @override
  String get setupHouseholdDefaultName => 'Mi Hogar';

  @override
  String get setupFamilyDefaultName => 'Mi familia';

  @override
  String get setupSnackJoinedHousehold => '¡Te uniste al hogar!';

  @override
  String get setupSnackPickAtLeastOneTask => 'Selecciona al menos una tarea';

  @override
  String get setupSnackUnknownError => 'Error desconocido';

  @override
  String get setupSnackOnboardingFailed =>
      'No se pudo completar el onboarding. Intentá de nuevo.';

  @override
  String get setupSnackCodeCopied => '¡Código copiado al portapapeles! 📋';

  @override
  String get setupSnackWhatsappFailed =>
      'No se pudo abrir WhatsApp. Código copiado.';

  @override
  String get setupJoinCodeTitle => 'Ingresa el código';

  @override
  String get setupConnectEyebrow => 'Conectar el hogar';

  @override
  String get setupConnectTitle => 'Conecta tu hogar';

  @override
  String get setupConnectSubtitle =>
      'Podés crear un nuevo equipo o sumarte con un código de invitación.';

  @override
  String get setupConnectCreateTitle => 'Crear nuevo hogar';

  @override
  String get setupConnectCreateDesc =>
      'Generá un código para invitar a quienes comparten este espacio.';

  @override
  String get setupConnectJoinTitle => 'Tengo un código';

  @override
  String get setupConnectJoinDesc => 'Ingresá el código para sumarte al hogar.';

  @override
  String get setupConnectCodeInputLabel => 'Ingresá el código';

  @override
  String get setupConnectCreateButton => 'Crear mi hogar';

  @override
  String get setupConnectJoinButton => 'Unirme ahora';

  @override
  String get setupConnectBackButton => 'Volver atrás';

  @override
  String get setupInvitationEyebrow => 'Invitación';

  @override
  String setupInvitationTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Familia creada',
        'friends': 'Familia creada',
        'couple': 'Hogar creado',
        'solo': 'Hogar creado',
        'other': 'Hogar creado',
      },
    );
    return '$_temp0';
  }

  @override
  String setupInvitationSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Compartí este código con quienes forman parte del hogar.',
        'friends': 'Compartí este código con quienes forman parte del hogar.',
        'couple': 'Compartí este código para invitar a la otra persona.',
        'solo': 'Compartí este código para invitar a la otra persona.',
        'other': 'Compartí este código para invitar a la otra persona.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupInvitationCodeEyebrow => 'CODIGO DE INVITACION';

  @override
  String get setupInvitationFooter =>
      'Podés copiarlo o compartirlo ahora. Más adelante también lo vas a encontrar en ajustes.';

  @override
  String get setupInvitationCopyButton => 'Copiar';

  @override
  String get setupInvitationShareButton => 'Compartir';

  @override
  String get setupFamilyBaseEyebrow => 'Base familiar';

  @override
  String get setupFamilyBaseTitle => 'Base del hogar familiar';

  @override
  String get setupFamilyBaseSubtitle =>
      'Antes de empezar, definamos cómo se organiza esta familia.';

  @override
  String get setupFamilyHouseholdNameLabel => 'Nombre del hogar';

  @override
  String get setupFamilyHouseholdNameHint => 'Ej: Casa de los Gómez';

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
  String get setupSaveAndContinue => 'Guardar y continuar';

  @override
  String get setupConfigureLater => 'Configurar luego';

  @override
  String get setupExpensesEyebrow => 'Gastos del hogar';

  @override
  String get setupExpensesTitle => 'División de gastos';

  @override
  String get setupFriendsExpensesSubtitle =>
      'En un piso compartido, lo más simple es dividir todo en partes iguales.';

  @override
  String get setupFriendsExpensesCardTitle => 'Reparto equitativo';

  @override
  String get setupFriendsExpensesCardBody =>
      'Cada compañero paga la misma proporción. Pueden ajustar gastos individuales más adelante.';

  @override
  String get setupFriendsExpensesTipTitle => 'Equitativo por defecto';

  @override
  String get setupFriendsExpensesTipDesc =>
      'Ideal para compañeros que comparten gastos del piso.';

  @override
  String setupCoupleFamilyExpensesSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Configuremos una base simple para dividir gastos en pareja.',
        'other':
            'Configuremos una base simple para dividir gastos en convivencia.',
      },
    );
    return '$_temp0';
  }

  @override
  String setupCoupleFamilyExpensesNote(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple':
            'Pueden cambiar esto después en ajustes. Como base arrancamos con una división 50/50.',
        'other':
            'Pueden cambiar esto después en ajustes. Como base arrancamos con una división equitativa.',
      },
    );
    return '$_temp0';
  }

  @override
  String setupCoupleFamilyExpensesSplitLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'VOS / PAREJA',
        'other': 'VOS / OTROS',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupCoupleFamilyTipEqualTitle => 'Igualitario (50/50)';

  @override
  String get setupCoupleFamilyTipEqualDescCouple =>
      'Ideal para ingresos y responsabilidades similares.';

  @override
  String get setupCoupleFamilyTipEqualDescOther =>
      'Ideal para hogares donde los gastos se reparten parejo.';

  @override
  String get setupCoupleFamilyTipProportionalTitle => 'Proporcional';

  @override
  String get setupCoupleFamilyTipProportionalDesc =>
      'Ajustado a lo que cada persona puede aportar.';

  @override
  String get setupFirstTasksEyebrow => 'Primeras tareas';

  @override
  String setupFirstTasksTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Primeras tareas para la familia',
        'other': 'Personaliza tu hogar',
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
      'Mostrar tareas, progreso y accesos rapidos.';

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
      'Cambia el nombre de tu hogar';

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
        'other': 'Ajustar porcentaje de pareja',
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
  String get settingsHouseholdRenameDialogLabel => 'Tu nombre';

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
  String get settingsParentModeApprovalAllTitle => 'Todos los miembros';

  @override
  String get settingsParentModeApprovalAllSubtitle =>
      'Cualquier completion pasa por tu OK antes de pagar coins.';

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
  String get settingsParentModePerMemberEmpty =>
      'No hay otros miembros en el hogar todavía.';

  @override
  String settingsParentModeSaveError(String message) {
    return 'No pudimos guardar el cambio: $message';
  }

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
        'other': 'División de gastos',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitSavedSnack => 'Configuración guardada correctamente';

  @override
  String coupleSplitSaveError(String message) {
    return 'Error al guardar: $message';
  }

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
  String get createTaskValidationTitleRequired => 'Título requerido';

  @override
  String get createTaskValidationNumberRequired => 'Ingresá un número';

  @override
  String get createTaskValidationNotNegative => 'No puede ser negativo';

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
  String get pendingApprovalsApproveButton => 'Aprobar';

  @override
  String get pendingApprovalsRejectButton => 'Rechazar';

  @override
  String get pendingApprovalsApproveErrorRetry =>
      'No pudimos aprobar la tarea. Reintentá.';

  @override
  String get pendingApprovalsRejectedSnack => 'Tarea rechazada.';

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
  String get expensesPlannedSkip => 'Omitir';

  @override
  String get expensesPlannedPay => 'Pagar';

  @override
  String expensesPlannedPaymentSnack(String title) {
    return 'Pago de \"$title\" registrado';
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
  String expensesFormOcrError(String error) {
    return 'No se pudo leer el ticket: $error';
  }

  @override
  String get expensesFormOcrLowConfidence =>
      'Ticket difícil de leer; revisá los datos antes de guardar';

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
  String get expensesFormSaveButtonSaveIncome => 'Guardar Ingreso';

  @override
  String get expensesFormSaveButtonSaveExpense => 'Guardar Gasto';

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
  String get premiumPaywallTitle => 'Llevá tu hogar\nal siguiente nivel';

  @override
  String get premiumPaywallSubtitle =>
      'Desbloqueá todas las funciones pro y simplificá la vida en equipo.';

  @override
  String get premiumBenefitAdvancedStats => 'Estadísticas Avanzadas';

  @override
  String get premiumBenefitAdvancedStatsDesc =>
      'Analizá tus gastos y tareas por categoría con gráficos detallados.';

  @override
  String get premiumBenefitUnlimitedHouseholds => 'Hogares Ilimitados';

  @override
  String get premiumBenefitUnlimitedHouseholdsDesc =>
      'Creá múltiples hogares para tu pareja, familia, amigos o proyectos.';

  @override
  String get premiumBenefitFullCustomization => 'Personalización Completa';

  @override
  String get premiumBenefitFullCustomizationDesc =>
      'Accedé a temas premium, colores únicos y widgets personalizados.';

  @override
  String get premiumRestorePurchases => 'Restaurar compras';

  @override
  String get premiumFreeTrialAvailable => 'Prueba Gratis Disponible';

  @override
  String get premiumActivateButton => 'Activar Premium';

  @override
  String get premiumTestingModeLabel => 'Modo testing · sin cargo';

  @override
  String get premiumSavePercent => 'Ahorrá 20%';

  @override
  String get premiumAlreadyActiveTitle => '¡Ya sos Premium!';

  @override
  String get premiumAlreadyActiveBody =>
      'Gracias por apoyar el desarrollo de HomeSync.';

  @override
  String get premiumContinueButton => 'Continuar';

  @override
  String get premiumDeactivateTesting => 'Desactivar Premium (testing)';

  @override
  String get premiumStoreErrorTitle => 'Error al conectar con la tienda';

  @override
  String get premiumDeveloperModeButton =>
      'Modo Desarrollador: Activar Premium';

  @override
  String get faqSheetTitle => 'Preguntas Frecuentes';

  @override
  String get faqSheetSubtitle => 'Todo lo que necesitás saber sobre HomeSync';

  @override
  String get faqHowSharedHome => '¿Cómo funciona el hogar compartido?';

  @override
  String get faqHowSharedHomeAnswer =>
      'HomeSync está pensado para parejas y personas que conviven. Cuando te unís a un hogar con un código, ambos comparten la misma lista de tareas, gastos y ahorros. Todo lo que hace uno se refleja para el otro.';

  @override
  String get faqWhatCoins => '¿Para qué sirven los Coins?';

  @override
  String get faqWhatCoinsAnswer =>
      'Los Coins son la recompensa por completar tareas. Podés usarlos en la sección de premios para canjear vouchers creados por tu pareja, como una cena romántica o un día de descanso.';

  @override
  String get faqWhatWeeklyDuels => '¿Qué son los Duelos Semanales?';

  @override
  String get faqWhatWeeklyDuelsAnswer =>
      'Cada semana empieza un duelo de XP nuevo. El miembro que complete más tareas y gane más puntos de experiencia será el ganador. Es una forma divertida de motivarse mutuamente.';

  @override
  String get faqHowEarnXp => '¿Cómo gano XP?';

  @override
  String get faqHowEarnXpAnswer =>
      'Ganás XP cada vez que completás una tarea. Las tareas más difíciles o importantes suelen dar más XP. Subir de nivel muestra tu progreso dentro del hogar.';

  @override
  String get faqHowFinancesWork => '¿Cómo funcionan las finanzas?';

  @override
  String get faqHowFinancesWorkAnswer =>
      'En HomeSync podés registrar gastos reales y también anticipar gastos que aún no pagaste. Los gastos confirmados son los que afectan el balance real entre ustedes. Los pendientes sirven como recordatorio y proyección, pero no cambian la deuda hasta que se paguen.';

  @override
  String get faqHowRecurringCount =>
      '¿Cómo cuentan los gastos recurrentes y el balance estimado?';

  @override
  String get faqHowRecurringCountAnswer =>
      'Un gasto recurrente nuevo arranca desde su primera fecha válida. Si lo creás antes o en la fecha de vencimiento, puede contar este mes. Si lo creás después, arranca en el próximo ciclo. \"Tu parte pendiente\" muestra solo lo que te corresponde según la división, y \"Balance estimado\" usa tu balance actual menos esa parte pendiente.';

  @override
  String get faqWhatSpecialEvents => '¿Qué son los Eventos Especiales?';

  @override
  String get faqWhatSpecialEventsAnswer =>
      'Cada semana aparece un desafío de pareja en la tienda. Son actividades diseñadas para fortalecer la relación. Cuando los completan, ambos reciben Coins y desbloquean medallas en su perfil de logros.';

  @override
  String get faqLevelsAndAchievements => '¿Niveles y logros?';

  @override
  String get faqLevelsAndAchievementsAnswer =>
      'A medida que ganás XP, subís de nivel. En la sección de estadísticas podés ver tus logros, que son medallas por hitos alcanzados, como completar 50 tareas o ganar desafíos semanales.';

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
  String get membersRoleParentGuardianDesc =>
      'Aprueba tareas, administra el hogar.';

  @override
  String get membersRoleTeenDesc =>
      'Crea sus tareas, pero las completa bajo revisión.';

  @override
  String get membersRoleChildDesc =>
      'Solo completa sus tareas, siempre bajo revisión.';

  @override
  String membersRoleUpdateError(String message) {
    return 'No se pudo cambiar el rol: $message';
  }

  @override
  String get membersRoleUpdated => 'Rol actualizado';

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
      'La heladera está llena.\n¿Necesitás algo hoy?';

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
  String get rewardsChallengeCompletePrompt => '¿Completaron el desafío?';

  @override
  String rewardsChallengeCompleteBody(int count) {
    return 'Qué alegría. Al confirmar, ambos recibirán $count coins.';
  }

  @override
  String get rewardsNotYet => 'Aún no';

  @override
  String get rewardsYesWeDid => 'Sí, lo hicimos';

  @override
  String rewardsChallengeTitle(String title) {
    return 'Desafío: $title';
  }

  @override
  String get rewardsChallengeCompleted => 'Desafío completado';

  @override
  String rewardsChallengeCompletedBody(int count) {
    return 'Ambos ganaron $count coins. Sigan cultivando su conexión.';
  }

  @override
  String rewardsChallengeError(String error) {
    return 'Error al completar el desafío: $error';
  }

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
    return 'Disfruta de \"$title\". El amor también vive en los pequeños detalles.';
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
      'Toman el lenguaje visual y emocional de la boutique de pareja.';

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
  String coupleChallengeWeeklyPill(int number, int total) {
    return 'Especial semanal $number de $total';
  }

  @override
  String get coupleChallengeExpandTooltip => 'Expandir';

  @override
  String get coupleChallengeShowLess => 'Ver menos';

  @override
  String get coupleChallengeShowMore => 'Ver detalles completos';

  @override
  String get coupleChallengeSharedReward => 'Recompensa compartida';

  @override
  String coupleChallengeSharedRewardBody(int count) {
    return 'Si lo completan, ambos reciben $count coins.';
  }

  @override
  String get coupleChallengeWeDidIt => 'Lo hicimos';

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
  String get weeklyWinnerSubtitle =>
      'Así terminó el duelo semanal entre ustedes.';

  @override
  String get weeklyWinnerCardSubtitle =>
      'Terminó adelante en XP y se llevó el cierre semanal.';

  @override
  String get weeklyWinnerCoinsReward => '+20 coins';

  @override
  String get weeklyWinnerSecondPlace => 'Segundo puesto';

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
  String get loveNoteDialogTitle => 'Nueva nota de amor';

  @override
  String get loveNoteHint => 'Escribí algo tierno...';

  @override
  String get loveNoteSent => 'Nota enviada con amor';

  @override
  String get loveNoteSendMessageTitle => 'Enviar mensaje a tu pareja';

  @override
  String get loveNotePremiumHintActive =>
      'Sorprendé con una nota especial hoy ✨';

  @override
  String get loveNotePremiumHintInactive =>
      'Función Premium. Desbloqueala para enviar notas.';

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
  String get rewardsTitleRequiredError => 'Escribe el nombre del deseo.';

  @override
  String get rewardsTitleMinLengthError => 'Usa al menos 3 caracteres.';

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
  String get loveNoteSendTitle => 'Enviar mensaje a tu pareja';

  @override
  String get loveNoteSendSubtitle => 'Sorprendé con una nota especial hoy.';

  @override
  String get loveNotePremiumFeature =>
      'Función premium. Desbloqueala para enviar notas.';

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
  String get rewardsChallengeCompleteConfirm => 'Sí, lo hicimos';

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
  String addTaskOptionsAddedSnack(String title) {
    return '\"$title\" añadida';
  }

  @override
  String get recurringExpenseValidationTitleAmount =>
      'Complet? t?tulo y monto v?lido.';

  @override
  String get recurringExpenseValidationPayer =>
      'Eleg? qui?n suele abonarla para dejarla lista.';

  @override
  String get recurringExpenseDeleteTitle => '?Eliminar suscripci?n?';

  @override
  String get recurringExpenseDeleteBody =>
      'Dejar? de aparecer en futuros meses.';

  @override
  String get recurringExpenseDetailEyebrow => 'DETALLE';

  @override
  String get recurringExpenseDetailTitle => 'Qu? se renueva cada mes';

  @override
  String get recurringExpenseDetailSubtitle =>
      'Defin? el nombre y el monto para reconocerla r?pido.';

  @override
  String get recurringExpenseCalendarEyebrow => 'CALENDARIO';

  @override
  String get recurringExpenseCalendarTitle => 'Cu?ndo se registra';

  @override
  String get recurringExpenseCalendarSubtitle =>
      'Elegimos el d?a habitual para programarla sola.';

  @override
  String get recurringExpenseCategoryEyebrow => 'CATEGOR?A';

  @override
  String get recurringExpenseCategoryTitle => 'D?nde encaja mejor';

  @override
  String get recurringExpenseCategorySubtitle =>
      'Ayuda a ordenar Finanzas y mantener la lectura clara.';

  @override
  String get recurringExpenseSplitEyebrow => 'REPARTO';

  @override
  String get recurringExpenseSplitTitle => 'C?mo se reparte';

  @override
  String get recurringExpenseSplitSubtitle =>
      'Defin? si se comparte en el hogar o si queda como personal.';

  @override
  String get recurringExpensePayerEyebrow => 'PAGADOR';

  @override
  String get recurringExpensePayerTitle => 'Qui?n suele abonarla';

  @override
  String get recurringExpensePayerSubtitle =>
      'Esto deja una sugerencia lista para los pr?ximos meses.';

  @override
  String get recurringExpenseHeaderEditIncome => 'Editar ingreso';

  @override
  String get recurringExpenseHeaderEditSubscription => 'Editar suscripci?n';

  @override
  String get recurringExpenseHeaderNewIncome => 'Nuevo ingreso fijo';

  @override
  String get recurringExpenseHeaderNewSubscription => 'Nueva suscripci?n';

  @override
  String get recurringExpenseHeaderEditSubtitle =>
      'Ajust? monto, categor?a y reparto para mantenerlo al d?a.';

  @override
  String get recurringExpenseHeaderNewIncomeSubtitle =>
      'Se sumar? autom?ticamente a tu balance cada mes.';

  @override
  String get recurringExpenseHeaderNewSubscriptionSubtitle =>
      'Dejala configurada y lista para que se registre sola todos los meses.';

  @override
  String get recurringExpenseDeleteIncome => 'Eliminar ingreso';

  @override
  String get recurringExpenseDeleteSubscription => 'Eliminar suscripci?n';

  @override
  String get recurringExpenseNameRequired =>
      'Escrib? un nombre para reconocerla.';

  @override
  String get recurringExpenseNameMinLength => 'Us? al menos 3 caracteres.';

  @override
  String get recurringExpenseNameLabel => 'Nombre';

  @override
  String get recurringExpenseNameHint => 'Ej: Netflix, alquiler o internet';

  @override
  String get recurringExpenseAmountLabel => 'Monto por defecto';

  @override
  String get recurringExpenseSaveIncome => 'Guardar ingreso';

  @override
  String get recurringExpenseSaveSubscription => 'Guardar suscripci?n';

  @override
  String get recurringExpenseCategoryLabel => 'Categor?a:';

  @override
  String get recurringExpenseSplitLabel => 'Reparto de gasto:';

  @override
  String get recurringExpenseAmountInvalid => 'Ingres? un monto v?lido.';

  @override
  String get recurringExpenseAmountPositive =>
      'El monto debe ser mayor a cero.';

  @override
  String get recurringExpenseDayLabel => 'Se cobra el d?a:';

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
  String get expensesNewItemsDetectedTitle => 'Productos nuevos detectados';

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
  String get expensesPlannedPaymentTitle => 'Confirmar pago';

  @override
  String expensesPlannedPaymentSubtitle(String title) {
    return 'Vas a marcar \"$title\" como pagado.';
  }

  @override
  String get expensesPlannedPaymentAmountEyebrow => 'MONTO EFECTIVO';

  @override
  String get expensesPlannedPaymentDateEyebrow => 'FECHA DE PAGO';

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
  String get coupleChallenge1Title => 'Recreando la primera cita';

  @override
  String get coupleChallenge1Description => '';

  @override
  String get coupleChallenge1Motivation =>
      'A veces volver atrás es la mejor forma de ver cuánto han avanzado juntos.';

  @override
  String get coupleChallenge1Category => 'Experiencial';

  @override
  String get coupleChallenge1Location => 'Exterior';

  @override
  String get coupleChallenge1Timing => 'Cualquier momento';

  @override
  String get coupleChallenge2Title => 'Cena a la luz de las velas';

  @override
  String get coupleChallenge2Description => '';

  @override
  String get coupleChallenge2Motivation =>
      'Una cita perfecta para reconectar sin distracciones y recordar por qué se eligen cada día.';

  @override
  String get coupleChallenge2Category => 'Romántico';

  @override
  String get coupleChallenge2Location => 'En casa';

  @override
  String get coupleChallenge2Timing => 'Noche';

  @override
  String get coupleChallenge3Title => 'Lista de sueños compartidos';

  @override
  String get coupleChallenge3Description => '';

  @override
  String get coupleChallenge3Motivation =>
      'Tener sueños en común no solo une, sino que da dirección a su historia.';

  @override
  String get coupleChallenge3Category => 'Emocional';

  @override
  String get coupleChallenge3Location => 'En casa';

  @override
  String get coupleChallenge3Timing => 'Tarde';

  @override
  String get coupleChallenge4Title => 'Karaoke casero';

  @override
  String get coupleChallenge4Description => '';

  @override
  String get coupleChallenge4Motivation =>
      'El amor también se canta desafinando, pero al mismo ritmo.';

  @override
  String get coupleChallenge4Category => 'Lúdico';

  @override
  String get coupleChallenge4Location => 'En casa';

  @override
  String get coupleChallenge4Timing => 'Noche';

  @override
  String get coupleChallenge5Title => 'Pintando juntos';

  @override
  String get coupleChallenge5Description => '';

  @override
  String get coupleChallenge5Motivation =>
      'Porque el arte no busca perfección, busca conexión.';

  @override
  String get coupleChallenge5Category => 'Creativo';

  @override
  String get coupleChallenge5Location => 'En casa';

  @override
  String get coupleChallenge5Timing => 'A definir';

  @override
  String get coupleChallenge6Title => 'Maratón de películas';

  @override
  String get coupleChallenge6Description => '';

  @override
  String get coupleChallenge6Motivation =>
      'Pequeñas cosas que hacen grande el amor.';

  @override
  String get coupleChallenge6Category => 'Relajado';

  @override
  String get coupleChallenge6Location => 'En casa';

  @override
  String get coupleChallenge6Timing => 'Noche';

  @override
  String get coupleChallenge7Title => 'Caminata fotográfica';

  @override
  String get coupleChallenge7Description => '';

  @override
  String get coupleChallenge7Motivation =>
      'A veces mirar el mundo a través del lente es la mejor forma de volver a mirarse entre sí.';

  @override
  String get coupleChallenge7Category => 'Aventura';

  @override
  String get coupleChallenge7Location => 'Ciudad';

  @override
  String get coupleChallenge7Timing => 'Tarde';

  @override
  String get coupleChallenge8Title => 'Picnic improvisado';

  @override
  String get coupleChallenge8Description => '';

  @override
  String get coupleChallenge8Motivation =>
      'No hace falta ir lejos para sentir que se escapan del mundo.';

  @override
  String get coupleChallenge8Category => 'Experiencial';

  @override
  String get coupleChallenge8Location => 'Al aire libre';

  @override
  String get coupleChallenge8Timing => 'Tarde';

  @override
  String get coupleChallenge9Title => 'Cartas que no se borran';

  @override
  String get coupleChallenge9Description => '';

  @override
  String get coupleChallenge9Motivation =>
      'Las cartas quedan, las palabras se leen, pero lo que más perdura es cómo te hacen sentir.';

  @override
  String get coupleChallenge9Category => 'Emocional';

  @override
  String get coupleChallenge9Location => 'En casa';

  @override
  String get coupleChallenge9Timing => 'Noche';

  @override
  String get coupleChallenge10Title => 'Desconexión total';

  @override
  String get coupleChallenge10Description => '';

  @override
  String get coupleChallenge10Motivation =>
      'Esta cita no se mide en minutos, sino en conexión real.';

  @override
  String get coupleChallenge10Category => 'Emocional';

  @override
  String get coupleChallenge10Location => 'En casa';

  @override
  String get coupleChallenge10Timing => 'Noche';

  @override
  String get coupleChallenge11Title => 'Frasco de preguntas';

  @override
  String get coupleChallenge11Description => '';

  @override
  String get coupleChallenge11Motivation =>
      'Algunas charlas no surgen hasta que se invitan.';

  @override
  String get coupleChallenge11Category => 'Lúdico';

  @override
  String get coupleChallenge11Location => 'En casa';

  @override
  String get coupleChallenge11Timing => 'Cualquier momento';

  @override
  String get coupleChallenge23Title => 'Desayuno con vista';

  @override
  String get coupleChallenge23Description => '';

  @override
  String get coupleChallenge23Motivation =>
      'El café sabe mejor cuando el horizonte es el límite.';

  @override
  String get coupleChallenge23Category => 'Exploración';

  @override
  String get coupleChallenge23Location => 'Exterior';

  @override
  String get coupleChallenge23Timing => 'Mañana';

  @override
  String get coupleChallenge24Title => 'A la orilla del mundo';

  @override
  String get coupleChallenge24Description => '';

  @override
  String get coupleChallenge24Motivation =>
      'El silencio compartido frente al agua dice más que mil palabras.';

  @override
  String get coupleChallenge24Category => 'Emocional';

  @override
  String get coupleChallenge24Location => 'Naturaleza';

  @override
  String get coupleChallenge24Timing => 'Atardecer';

  @override
  String get coupleChallenge25Title => 'Destino incierto';

  @override
  String get coupleChallenge25Description => '';

  @override
  String get coupleChallenge25Motivation =>
      'Perderse juntos es la mejor forma de encontrarse.';

  @override
  String get coupleChallenge25Category => 'Exploración';

  @override
  String get coupleChallenge25Location => 'Ciudad';

  @override
  String get coupleChallenge25Timing => 'Tarde';

  @override
  String get coupleChallenge26Title => 'Ritual del presente';

  @override
  String get coupleChallenge26Description => '';

  @override
  String get coupleChallenge26Motivation =>
      'Limpiar el pasado deja lugar para un futuro más brillante.';

  @override
  String get coupleChallenge26Category => 'Emocional';

  @override
  String get coupleChallenge26Location => 'En casa';

  @override
  String get coupleChallenge26Timing => 'Noche';

  @override
  String get coupleChallenge27Title => 'Arquitecto de sorpresas';

  @override
  String get coupleChallenge27Description => '';

  @override
  String get coupleChallenge27Motivation =>
      'El amor vive en los detalles que dicen \"pensé en vos\".';

  @override
  String get coupleChallenge27Category => 'Detallista';

  @override
  String get coupleChallenge27Location => 'Cualquier lugar';

  @override
  String get coupleChallenge27Timing => 'Sorpresa';

  @override
  String get coupleChallenge28Title => 'Al servicio del amor';

  @override
  String get coupleChallenge28Description => '';

  @override
  String get coupleChallenge28Motivation =>
      'Cuidar es una forma silenciosa y poderosa de amar.';

  @override
  String get coupleChallenge28Category => 'Cotidiano';

  @override
  String get coupleChallenge28Location => 'En casa';

  @override
  String get coupleChallenge28Timing => 'Noche';

  @override
  String get coupleChallenge29Title => 'Historias en escena';

  @override
  String get coupleChallenge29Description => '';

  @override
  String get coupleChallenge29Motivation =>
      'Jugar a ser otros ayuda a redescubrir quiénes son ustedes.';

  @override
  String get coupleChallenge29Category => 'Lúdico';

  @override
  String get coupleChallenge29Location => 'En casa';

  @override
  String get coupleChallenge29Timing => 'Cualquier momento';

  @override
  String get coupleChallenge30Title => 'Sabores con historia';

  @override
  String get coupleChallenge30Description => '';

  @override
  String get coupleChallenge30Motivation =>
      'Cada bocado es una puerta abierta a un recuerdo.';

  @override
  String get coupleChallenge30Category => 'Experiencial';

  @override
  String get coupleChallenge30Location => 'Cualquier lugar';

  @override
  String get coupleChallenge30Timing => 'Noche';

  @override
  String get coupleChallenge31Title => 'El arte de no hacer nada';

  @override
  String get coupleChallenge31Description => '';

  @override
  String get coupleChallenge31Motivation =>
      'El tiempo \"perdido\" juntos es tiempo ganado en conexión.';

  @override
  String get coupleChallenge31Category => 'Relajado';

  @override
  String get coupleChallenge31Location => 'En casa';

  @override
  String get coupleChallenge31Timing => 'Todo el día';

  @override
  String get coupleChallenge32Title => 'Domingo de mercado';

  @override
  String get coupleChallenge32Description => '';

  @override
  String get coupleChallenge32Motivation =>
      'La rutina también tiene su propia magia artesanal.';

  @override
  String get coupleChallenge32Category => 'Exploración';

  @override
  String get coupleChallenge32Location => 'Ciudad';

  @override
  String get coupleChallenge32Timing => 'Mañana';

  @override
  String get coupleChallenge33Title => 'Bajo las estrellas';

  @override
  String get coupleChallenge33Description => '';

  @override
  String get coupleChallenge33Motivation =>
      'El universo entero cabe en el espacio entre los dos.';

  @override
  String get coupleChallenge33Category => 'Romántico';

  @override
  String get coupleChallenge33Location => 'Naturaleza';

  @override
  String get coupleChallenge33Timing => 'Noche';

  @override
  String get coupleChallenge34Title => 'Noche de los sentidos';

  @override
  String get coupleChallenge34Description => '';

  @override
  String get coupleChallenge34Motivation =>
      'El amor se saborea, se huele y se toca.';

  @override
  String get coupleChallenge34Category => 'Sensoral';

  @override
  String get coupleChallenge34Location => 'En casa';

  @override
  String get coupleChallenge34Timing => 'Noche';

  @override
  String get coupleChallenge35Title => 'Lectura compartida';

  @override
  String get coupleChallenge35Description => '';

  @override
  String get coupleChallenge35Motivation =>
      'Las palabras son el puente que une dos mentes.';

  @override
  String get coupleChallenge35Category => 'Intelectual';

  @override
  String get coupleChallenge35Location => 'Tranquilo';

  @override
  String get coupleChallenge35Timing => 'Noche';

  @override
  String get coupleChallenge36Title => 'Microteatro en pareja';

  @override
  String get coupleChallenge36Description => '';

  @override
  String get coupleChallenge36Motivation =>
      'Vivir mil vidas en una noche, siempre de la mano.';

  @override
  String get coupleChallenge36Category => 'Cultural';

  @override
  String get coupleChallenge36Location => 'Ciudad';

  @override
  String get coupleChallenge36Timing => 'Noche';

  @override
  String get coupleChallenge37Title => 'Viaje sin maletas';

  @override
  String get coupleChallenge37Description => '';

  @override
  String get coupleChallenge37Motivation =>
      'El mejor destino es aquel que crean entre los dos.';

  @override
  String get coupleChallenge37Category => 'Creativo';

  @override
  String get coupleChallenge37Location => 'En casa';

  @override
  String get coupleChallenge37Timing => 'Noche';

  @override
  String get coupleChallenge38Title => 'El sobre secreto';

  @override
  String get coupleChallenge38Description => '';

  @override
  String get coupleChallenge38Motivation =>
      'Cada sobre es un \"te pensé\" esperando ser abierto.';

  @override
  String get coupleChallenge38Category => 'Aventura';

  @override
  String get coupleChallenge38Location => 'Sorpresa';

  @override
  String get coupleChallenge38Timing => 'Toda la tarde';

  @override
  String get coupleChallenge39Title => 'Propósitos al alba';

  @override
  String get coupleChallenge39Description => '';

  @override
  String get coupleChallenge39Motivation =>
      'Cada amanecer es la oportunidad de empezar de nuevo.';

  @override
  String get coupleChallenge39Category => 'Emocional';

  @override
  String get coupleChallenge39Location => 'Exterior';

  @override
  String get coupleChallenge39Timing => 'Alba';

  @override
  String get coupleChallenge40Title => 'Construyendo paciencia';

  @override
  String get coupleChallenge40Description => '';

  @override
  String get coupleChallenge40Motivation =>
      'Armar lo pequeño es practicar la paciencia para lo grande.';

  @override
  String get coupleChallenge40Category => 'Relajado';

  @override
  String get coupleChallenge40Location => 'En casa';

  @override
  String get coupleChallenge40Timing => 'Tarde';

  @override
  String get coupleChallenge41Title => 'Día de gratitud absoluta';

  @override
  String get coupleChallenge41Description => '';

  @override
  String get coupleChallenge41Motivation =>
      'Cambiar el foco cambia la relación entera.';

  @override
  String get coupleChallenge41Category => 'Emocional';

  @override
  String get coupleChallenge41Location => 'Cualquier lugar';

  @override
  String get coupleChallenge41Timing => 'Todo el día';

  @override
  String get coupleChallenge42Title => 'Cápsula del tiempo';

  @override
  String get coupleChallenge42Description => '';

  @override
  String get coupleChallenge42Motivation =>
      'Guardar el presente es dejarle un regalo al futuro.';

  @override
  String get coupleChallenge42Category => 'Emocional';

  @override
  String get coupleChallenge42Location => 'En casa';

  @override
  String get coupleChallenge42Timing => 'Noche';

  @override
  String get coupleChallenge43Title => 'Pintura a ciegas';

  @override
  String get coupleChallenge43Description => '';

  @override
  String get coupleChallenge43Motivation =>
      'El amor también se pinta con los ojos cerrados.';

  @override
  String get coupleChallenge43Category => 'Lúdico';

  @override
  String get coupleChallenge43Location => 'En casa';

  @override
  String get coupleChallenge43Timing => 'Cualquier momento';

  @override
  String get coupleChallenge44Title => 'Nuestro propio Podcast';

  @override
  String get coupleChallenge44Description => '';

  @override
  String get coupleChallenge44Motivation =>
      'Grabar la voz del amor es guardar una memoria viva.';

  @override
  String get coupleChallenge44Category => 'Creativo';

  @override
  String get coupleChallenge44Location => 'Tranquilo';

  @override
  String get coupleChallenge44Timing => 'Cualquier momento';

  @override
  String get coupleChallenge45Title => 'Mensajes diferidos';

  @override
  String get coupleChallenge45Description => '';

  @override
  String get coupleChallenge45Motivation =>
      'El amor también se escribe en tiempo diferido.';

  @override
  String get coupleChallenge45Category => 'Emocional';

  @override
  String get coupleChallenge45Location => 'En casa';

  @override
  String get coupleChallenge45Timing => 'Noche';

  @override
  String get coupleChallenge46Title => 'Proyección de recuerdos';

  @override
  String get coupleChallenge46Description => '';

  @override
  String get coupleChallenge46Motivation =>
      'Mirar atrás es la mejor forma de valorar el presente.';

  @override
  String get coupleChallenge46Category => 'Emocional';

  @override
  String get coupleChallenge46Location => 'En casa';

  @override
  String get coupleChallenge46Timing => 'Noche';

  @override
  String get coupleChallenge47Title => 'El día del \"Sí\"';

  @override
  String get coupleChallenge47Description => '';

  @override
  String get coupleChallenge47Motivation =>
      'La estructura cansa, la fluidez conecta.';

  @override
  String get coupleChallenge47Category => 'Lúdico';

  @override
  String get coupleChallenge47Location => 'Cualquier lugar';

  @override
  String get coupleChallenge47Timing => 'Todo el día';

  @override
  String get coupleChallenge48Title => 'Brindis por el futuro';

  @override
  String get coupleChallenge48Description => '';

  @override
  String get coupleChallenge48Motivation =>
      'Brindar por lo que viene es honrar lo que ya son.';

  @override
  String get coupleChallenge48Category => 'Emocional';

  @override
  String get coupleChallenge48Location => 'Cualquier lugar';

  @override
  String get coupleChallenge48Timing => 'Noche';

  @override
  String get coupleChallenge49Title => 'Cocina experimental';

  @override
  String get coupleChallenge49Description => '';

  @override
  String get coupleChallenge49Motivation =>
      'El sabor de lo improvisado siempre tiene un toque especial.';

  @override
  String get coupleChallenge49Category => 'Creativo';

  @override
  String get coupleChallenge49Location => 'Cocina';

  @override
  String get coupleChallenge49Timing => 'Almuerzo/Cena';

  @override
  String get coupleChallenge50Title => 'Muro de los deseos';

  @override
  String get coupleChallenge50Description => '';

  @override
  String get coupleChallenge50Motivation =>
      'Hacer visible el deseo es empezar a cumplirlo.';

  @override
  String get coupleChallenge50Category => 'Detallista';

  @override
  String get coupleChallenge50Location => 'En casa';

  @override
  String get coupleChallenge50Timing => 'Toda la semana';

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
}
