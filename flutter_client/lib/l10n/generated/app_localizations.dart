import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('es')
  ];

  /// Application name. Brand name — should typically NOT be translated.
  ///
  /// In es, this message translates to:
  /// **'HomeSync'**
  String get appName;

  /// Title of the language selector card in Settings.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageTitle;

  /// Subtitle below the language selector title. Argentine Spanish 'voseo' (elegí, no elige).
  ///
  /// In es, this message translates to:
  /// **'Elegí el idioma de la app'**
  String get settingsLanguageSubtitle;

  /// Title of the currency selector card in Settings.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get settingsCurrencyTitle;

  /// Subtitle below the currency selector title. The setting only changes display/input formatting, not stored amounts.
  ///
  /// In es, this message translates to:
  /// **'Elegí cómo se muestran los importes de Finanzas'**
  String get settingsCurrencySubtitle;

  /// Option that follows the OS language.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado del sistema'**
  String get languageSystem;

  /// Spanish language option label.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// English language option label.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get commonAccept;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get commonLoading;

  /// Generic user-facing error message. Soft, not alarming.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal'**
  String get commonError;

  /// No description provided for @commonNoConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get commonNoConnection;

  /// Mensaje del indicador offline cuando no hay conexión.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión · Los cambios se guardarán cuando vuelvas a estar online'**
  String get offlineDisconnectedMessage;

  /// Mensaje del indicador mientras sincroniza cambios pendientes.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando cambios...'**
  String get offlineSyncingMessage;

  /// Contador compacto de cambios pendientes en el indicador offline.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 pendiente} other{{count} pendientes}}'**
  String offlinePendingShort(int count);

  /// Estado completo de cambios pendientes de sincronización.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 cambio pendiente de sincronizar} other{{count} cambios pendientes de sincronizar}}'**
  String offlinePendingChanges(int count);

  /// Estado mostrado cuando no quedan cambios pendientes.
  ///
  /// In es, this message translates to:
  /// **'Sincronizado'**
  String get offlineSyncedMessage;

  /// Botón para sincronizar manualmente, con cantidad pendiente.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar ({count})'**
  String offlineSyncButton(int count);

  /// Generic confirm button label, typically alongside Cancel in a 2-button dialog.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// Generic send/submit button label.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get commonSend;

  /// Bottom-nav tab: home / dashboard.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get mainTabHome;

  /// No description provided for @mainTabTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get mainTabTasks;

  /// No description provided for @mainTabExpenses.
  ///
  /// In es, this message translates to:
  /// **'Finanzas'**
  String get mainTabExpenses;

  /// No description provided for @mainTabProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get mainTabProgress;

  /// No description provided for @mainTabShopping.
  ///
  /// In es, this message translates to:
  /// **'Compras'**
  String get mainTabShopping;

  /// Bottom-nav label for the shopping tab when the current member is a minor (child store, not regular shopping).
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get mainTabShoppingChild;

  /// Label for the 'social' bottom-nav tab. Varies by household mode. couple = romantic partner. family = whole family unit. friends = peers/roommates living together. solo = individual user.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{Pareja} family{Familia} friends{Piso} solo{Mi espacio} other{Mi espacio}}'**
  String householdSocialTabLabel(String type);

  /// Title shown at the top of the social/household hub screen. Varies by mode.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{Pareja} family{Centro familiar} friends{Convivencia} solo{Mi espacio} other{Mi espacio}}'**
  String householdSocialHubTitle(String type);

  /// Subtitle on the social hub screen. Tone: couple romantic; family parental/coordinative; friends casual peer; solo individual.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{El repaso de la semana, la plata entre los dos y lo que se proponen.} family{Coordinación, miembros y acuerdos del hogar para toda la familia.} friends{Organización, convivencia y reparto claro para el piso.} solo{Todo tu progreso personal en un solo lugar.} other{Todo tu progreso personal en un solo lugar.}}'**
  String householdSocialHubSubtitle(String type);

  /// Greeting/title on the dashboard header. Varies by mode.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{Nuestro Hogar} family{Hogar Familiar} friends{Convivencia} solo{Mi Progreso} other{Mi Progreso}}'**
  String householdDashboardGreeting(String type);

  /// Label above the balance/spending figure. solo shows personal spending; couple/family/friends show running shared balance.
  ///
  /// In es, this message translates to:
  /// **'{type, select, solo{Llevas gastado este mes} other{Balance acumulado}}'**
  String householdBalanceMessage(String type);

  /// Empty-state subtitle on the tasks screen. solo uses singular 'tu dia'; others use plural imperative 'agreguen' (Argentine voseo).
  ///
  /// In es, this message translates to:
  /// **'{type, select, solo{Agrega tu primera tarea para organizar tu dia.} other{Agreguen su primera tarea para organizar el hogar.}}'**
  String householdEmptyTasksSubtitle(String type);

  /// Short noun for 'the other people in the household' as a label. solo = self only.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{Pareja} family{Familia} friends{Compañeros} solo{Yo} other{Yo}}'**
  String householdMemberLabel(String type);

  /// Phrase fragment used inside sentences like 'this expense will not affect the balance {with your partner}'. Lowercase, prepositional. solo = 'with myself' which renders awkward — used in contexts where the surrounding sentence still grammatically allows it.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{con tu pareja} family{con la familia} friends{con tus compañeros} solo{conmigo} other{conmigo}}'**
  String householdActionMemberLabel(String type);

  /// Large title at the top of the Settings screen.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsAppBarTitle;

  /// Tooltip on the back arrow in Settings header.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get settingsBackTooltip;

  /// Tiny uppercase label above a section in Settings. Stays uppercase in all locales.
  ///
  /// In es, this message translates to:
  /// **'PERFIL'**
  String get settingsSectionProfileEyebrow;

  /// No description provided for @settingsSectionProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu espacio'**
  String get settingsSectionProfileTitle;

  /// No description provided for @settingsSectionProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Avatar, nombre y datos básicos de tu cuenta.'**
  String get settingsSectionProfileSubtitle;

  /// No description provided for @settingsSectionHouseholdEyebrow.
  ///
  /// In es, this message translates to:
  /// **'HOGAR'**
  String get settingsSectionHouseholdEyebrow;

  /// No description provided for @settingsSectionHouseholdTitle.
  ///
  /// In es, this message translates to:
  /// **'Casa compartida'**
  String get settingsSectionHouseholdTitle;

  /// No description provided for @settingsSectionHouseholdSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Miembros, invitaciones y reglas del hogar.'**
  String get settingsSectionHouseholdSubtitle;

  /// No description provided for @settingsSectionAppEyebrow.
  ///
  /// In es, this message translates to:
  /// **'APP'**
  String get settingsSectionAppEyebrow;

  /// No description provided for @settingsSectionAppTitle.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get settingsSectionAppTitle;

  /// No description provided for @settingsSectionAppSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tema, notificaciones, ayuda y feedback.'**
  String get settingsSectionAppSubtitle;

  /// No description provided for @settingsSectionAccountEyebrow.
  ///
  /// In es, this message translates to:
  /// **'CUENTA'**
  String get settingsSectionAccountEyebrow;

  /// No description provided for @settingsSectionAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Sesión y seguridad'**
  String get settingsSectionAccountTitle;

  /// No description provided for @settingsSectionAccountSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Salir de la cuenta o reiniciar tus datos si lo necesitas.'**
  String get settingsSectionAccountSubtitle;

  /// No description provided for @settingsSectionLegalEyebrow.
  ///
  /// In es, this message translates to:
  /// **'LEGAL'**
  String get settingsSectionLegalEyebrow;

  /// No description provided for @settingsSectionLegalTitle.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get settingsSectionLegalTitle;

  /// No description provided for @settingsSectionLegalSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad y términos de uso.'**
  String get settingsSectionLegalSubtitle;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí el tema visual de la app'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsThemeModeTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo del Tema'**
  String get settingsThemeModeTitle;

  /// No description provided for @settingsThemeModeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeModeLight;

  /// No description provided for @settingsThemeModeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeModeDark;

  /// Theme mode that follows the OS setting.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsThemeModeSystem;

  /// No description provided for @settingsThemePaletteTitle.
  ///
  /// In es, this message translates to:
  /// **'Color del Tema'**
  String get settingsThemePaletteTitle;

  /// Tiny uppercase badge on a feature gated behind premium. Stays uppercase in all locales.
  ///
  /// In es, this message translates to:
  /// **'PREMIUM'**
  String get settingsPremiumBadge;

  /// Brand name — keep as 'HomeSync Premium' in all locales.
  ///
  /// In es, this message translates to:
  /// **'HomeSync Premium'**
  String get settingsPremiumTitle;

  /// Card subtitle when the user already has premium.
  ///
  /// In es, this message translates to:
  /// **'Gestionar plan'**
  String get settingsPremiumActiveSubtitle;

  /// Card subtitle when the user does NOT have premium yet — teaser to upsell.
  ///
  /// In es, this message translates to:
  /// **'Funciones avanzadas'**
  String get settingsPremiumInactiveSubtitle;

  /// Note below the Premium card encouraging users to report bugs or suggest useful improvements in exchange for possible free Premium months.
  ///
  /// In es, this message translates to:
  /// **'Reportá errores o sugerí mejoras útiles y podés ganar meses Premium gratis.'**
  String get settingsPremiumFeedbackRewardNote;

  /// Premium feature label: when a shopping list item is purchased, it auto-creates a finance/expense entry.
  ///
  /// In es, this message translates to:
  /// **'Sincronización de compras con finanzas'**
  String get settingsPremiumFeatureShoppingFinanceSync;

  /// Premium feature label: scheduled/recurring expenses like Netflix, gym, etc.
  ///
  /// In es, this message translates to:
  /// **'Pagos Recurrentes (Suscripciones)'**
  String get settingsPremiumFeatureRecurringPayments;

  /// Premium feature label: exclusive avatar set.
  ///
  /// In es, this message translates to:
  /// **'Avatares Exclusivos'**
  String get settingsPremiumFeatureExclusiveAvatars;

  /// Snackbar shown to minors when they tap a premium-locked theme palette. Argentine voseo.
  ///
  /// In es, this message translates to:
  /// **'Esta función es premium 🌟 Pedile a un adulto del hogar que active el plan.'**
  String get settingsMinorPremiumSnack;

  /// No description provided for @settingsReplayTourTitle.
  ///
  /// In es, this message translates to:
  /// **'Ver guia de nuevo'**
  String get settingsReplayTourTitle;

  /// No description provided for @settingsReplayTourSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Repasá la introducción del hogar'**
  String get settingsReplayTourSubtitle;

  /// No description provided for @settingsFeedbackTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar feedback'**
  String get settingsFeedbackTitle;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reporta un bug o sugiere una mejora'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @settingsLegalPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get settingsLegalPrivacyPolicy;

  /// No description provided for @settingsLegalTermsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get settingsLegalTermsOfUse;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In es, this message translates to:
  /// **'🔔 Notificaciones activadas'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsDisabled.
  ///
  /// In es, this message translates to:
  /// **'🔕 Notificaciones desactivadas'**
  String get settingsNotificationsDisabled;

  /// No description provided for @settingsProfileNameUpdated.
  ///
  /// In es, this message translates to:
  /// **'✅ Nombre actualizado'**
  String get settingsProfileNameUpdated;

  /// No description provided for @settingsAccountReset.
  ///
  /// In es, this message translates to:
  /// **'✅ Datos reiniciados y hogar liberado'**
  String get settingsAccountReset;

  /// No description provided for @settingsAccountResetError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reiniciar la cuenta.'**
  String get settingsAccountResetError;

  /// No description provided for @settingsLinkOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el enlace'**
  String get settingsLinkOpenError;

  /// No description provided for @settingsProfileNameFallback.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get settingsProfileNameFallback;

  /// No description provided for @settingsProfileAvatarAction.
  ///
  /// In es, this message translates to:
  /// **'Avatar'**
  String get settingsProfileAvatarAction;

  /// No description provided for @settingsProfileNameAction.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get settingsProfileNameAction;

  /// No description provided for @settingsRenameProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar nombre'**
  String get settingsRenameProfileTitle;

  /// No description provided for @settingsRenameProfileLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get settingsRenameProfileLabel;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsFaqTitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas Frecuentes'**
  String get settingsFaqTitle;

  /// Big outlined button at the bottom of Settings to sign the user out of the app.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsLogoutButton;

  /// Tiny uppercase label above the destructive 'reset account' button. Stays uppercase in all locales.
  ///
  /// In es, this message translates to:
  /// **'ZONA DE PELIGRO'**
  String get settingsDangerZoneEyebrow;

  /// Destructive button label: wipes all the user's data and removes them from the current household.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar Datos de Cuenta'**
  String get settingsResetAccountButton;

  /// No description provided for @settingsLogoutDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get settingsLogoutDialogTitle;

  /// No description provided for @settingsLogoutDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Vas a tener que iniciar sesión de nuevo para acceder a tu hogar.'**
  String get settingsLogoutDialogBody;

  /// Confirm button on the sign-out dialog. Short — fits next to a Cancel button.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get settingsLogoutDialogConfirm;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Reiniciar todo?'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción borrará todas tus tareas, gastos y progreso de forma permanente, y te quitará del hogar actual para que puedas configurar uno nuevo o unirte a otro.'**
  String get settingsResetDialogBody;

  /// Destructive confirm button on the reset-account dialog.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get settingsResetDialogConfirm;

  /// Destructive button label that permanently deletes the user's account and all their data (Play Store account-deletion requirement).
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get settingsDeleteAccountButton;

  /// Title of the confirmation dialog for permanent account deletion.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar tu cuenta?'**
  String get settingsDeleteAccountDialogTitle;

  /// Body of the permanent account-deletion confirmation dialog. Must make clear the action is irreversible.
  ///
  /// In es, this message translates to:
  /// **'Esto elimina tu cuenta y todos tus datos (tareas, gastos, recompensas y progreso) de forma permanente. No se puede deshacer. Si compartís un hogar, dejarás de formar parte de él.'**
  String get settingsDeleteAccountDialogBody;

  /// Destructive confirm button on the delete-account dialog.
  ///
  /// In es, this message translates to:
  /// **'Eliminar definitivamente'**
  String get settingsDeleteAccountConfirm;

  /// Snackbar shown after the account was deleted successfully.
  ///
  /// In es, this message translates to:
  /// **'Cuenta eliminada'**
  String get settingsDeleteAccountSuccess;

  /// Snackbar shown when account deletion fails on the backend.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta. Intentá de nuevo.'**
  String get settingsDeleteAccountError;

  /// Shown when Firebase requires a recent login before deleting the credential.
  ///
  /// In es, this message translates to:
  /// **'Por seguridad, volvé a iniciar sesión y luego eliminá tu cuenta.'**
  String get settingsDeleteAccountReauthNeeded;

  /// Single line shown on the splash screen while the app boots and warms providers.
  ///
  /// In es, this message translates to:
  /// **'Preparando tu hogar compartido.'**
  String get splashLoadingMessage;

  /// Login screen header title in sign-in mode.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get authWelcomeTitle;

  /// Login screen header title in sign-up mode. Argentine voseo: 'Armá' = 'Set up'.
  ///
  /// In es, this message translates to:
  /// **'Armá tu hogar'**
  String get authSignUpTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresá para entrar a tu hogar y mantener todo al día.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Creá tu cuenta para empezar a organizar tu hogar.'**
  String get authSignUpSubtitle;

  /// Email input hint on the login form. Kept as 'Email' even in Spanish — common loanword.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// Email input hint on the sign-up form and the forgot-password dialog. Spelled-out variant.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmailFullHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordHint;

  /// No description provided for @authPasswordHintWithMin.
  ///
  /// In es, this message translates to:
  /// **'Contraseña (mínimo 6 caracteres)'**
  String get authPasswordHintWithMin;

  /// Name input hint on sign-up form.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre o apodo'**
  String get authNameHint;

  /// Inline form-field error when a required field is empty. Single word.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get authValidationRequired;

  /// Inline error: email is malformed (missing @).
  ///
  /// In es, this message translates to:
  /// **'Inválido'**
  String get authValidationInvalidEmail;

  /// Inline error: password too short (<6 chars). Source uses feminine 'Inválida' to agree with 'Contraseña' (feminine in Spanish).
  ///
  /// In es, this message translates to:
  /// **'Inválida'**
  String get authValidationInvalidPassword;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPasswordLink;

  /// Big primary button to submit the sign-in form. Voseo: 'Ingresar' (infinitive, not 'Inicia sesión').
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get authSignInButton;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccountButton;

  /// Fine-print under the sign-up form. Voseo 'aceptás'.
  ///
  /// In es, this message translates to:
  /// **'Al crear una cuenta aceptás nuestros términos y la política de privacidad.'**
  String get authTermsAcceptance;

  /// No description provided for @authShowPasswordTooltip.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get authShowPasswordTooltip;

  /// No description provided for @authHidePasswordTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get authHidePasswordTooltip;

  /// Divider label between email form and Google sign-in button. Voseo 'continuá'.
  ///
  /// In es, this message translates to:
  /// **'o continuá con'**
  String get authOrContinueWith;

  /// No description provided for @authToggleHasAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tenés cuenta?'**
  String get authToggleHasAccount;

  /// Prompt above the 'Sign up' link when in sign-in mode. HomeSync = brand name, keep.
  ///
  /// In es, this message translates to:
  /// **'¿Sos nuevo en HomeSync?'**
  String get authToggleNewToApp;

  /// Link text inside the toggle prompt that switches to sign-in mode. Voseo imperative.
  ///
  /// In es, this message translates to:
  /// **'Ingresá'**
  String get authToggleSignInLink;

  /// Link text inside the toggle prompt that switches to sign-up mode. Voseo imperative ('Registrate' not 'Regístrate').
  ///
  /// In es, this message translates to:
  /// **'Registrate'**
  String get authToggleSignUpLink;

  /// No description provided for @authForgotDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get authForgotDialogTitle;

  /// No description provided for @authForgotDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un enlace para restablecer tu contraseña.'**
  String get authForgotDialogBody;

  /// No description provided for @authForgotDialogSendButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get authForgotDialogSendButton;

  /// No description provided for @authForgotInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un correo válido'**
  String get authForgotInvalidEmail;

  /// No description provided for @authForgotEmailSent.
  ///
  /// In es, this message translates to:
  /// **'¡Revisá tu correo para cambiar tu contraseña!'**
  String get authForgotEmailSent;

  /// No description provided for @authSignUpEmailSent.
  ///
  /// In es, this message translates to:
  /// **'¡Revisá tu correo para confirmar tu cuenta!'**
  String get authSignUpEmailSent;

  /// Safe error shown when email sign-in fails without exposing provider details.
  ///
  /// In es, this message translates to:
  /// **'No pudimos iniciar sesión. Revisá tus datos e intentá de nuevo.'**
  String get authSignInError;

  /// Safe error shown when email registration fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos crear tu cuenta. Intentá de nuevo.'**
  String get authSignUpError;

  /// Safe error shown when requesting a password reset email fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviar el correo de recuperación. Intentá de nuevo.'**
  String get authPasswordResetError;

  /// Safe error shown when Google sign-in fails, excluding user cancellation.
  ///
  /// In es, this message translates to:
  /// **'No pudimos ingresar con Google. Intentá de nuevo.'**
  String get authGoogleSignInError;

  /// Recoverable inline error shown when the household invitation code cannot be generated.
  ///
  /// In es, this message translates to:
  /// **'No pudimos generar el código de invitación.'**
  String get invitationLoadError;

  /// Generic technical error shown to the user. {message} is the raw exception text — usually English/technical, not localizable.
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String commonErrorWithDetails(String message);

  /// Placeholder when the user's display name is missing.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get commonUserFallback;

  /// Welcome greeting on the dashboard header, masculine form. Spanish has gendered welcomes; English uses one neutral 'Welcome' for both.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get homeWelcomeMasculine;

  /// Welcome greeting on the dashboard header, feminine form. Spanish-only distinction; English collapses to 'Welcome'.
  ///
  /// In es, this message translates to:
  /// **'Bienvenida'**
  String get homeWelcomeFeminine;

  /// Small button next to the day-tasks list that takes the user to the full weekly view.
  ///
  /// In es, this message translates to:
  /// **'Ver semana'**
  String get homeViewWeekButton;

  /// Daily task progress chip next to the home tasks title, e.g. '2 de 5'.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total}'**
  String homeTodayProgressLabel(int done, int total);

  /// Screen-reader label for the daily progress chip.
  ///
  /// In es, this message translates to:
  /// **'Progreso de hoy: {done} de {total} tareas completadas'**
  String homeTodayProgressSemantic(int done, int total);

  /// Empty-state message shown on the dashboard when there are no tasks left for today.
  ///
  /// In es, this message translates to:
  /// **'Todo listo por hoy'**
  String get homeAllDoneToday;

  /// Title for the in-app banner shown when another household member adds or schedules a task for today.
  ///
  /// In es, this message translates to:
  /// **'Tarea agregada'**
  String get homeTaskAddedNoticeTitle;

  /// Body for the in-app banner shown when a task becomes available in the Home today section.
  ///
  /// In es, this message translates to:
  /// **'Ya aparece en Hoy en casa: {taskTitle}'**
  String homeTaskAddedNoticeBody(String taskTitle);

  /// No description provided for @homeFabActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get homeFabActions;

  /// No description provided for @homeFabExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get homeFabExpenses;

  /// No description provided for @homeFabTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get homeFabTasks;

  /// No description provided for @balanceCardSettled.
  ///
  /// In es, this message translates to:
  /// **'Todo equilibrado'**
  String get balanceCardSettled;

  /// No description provided for @balanceCardMyBudget.
  ///
  /// In es, this message translates to:
  /// **'Mi presupuesto'**
  String get balanceCardMyBudget;

  /// No description provided for @balanceCardBalanced.
  ///
  /// In es, this message translates to:
  /// **'Balance en calma'**
  String get balanceCardBalanced;

  /// No description provided for @balanceCardNeedsSettlement.
  ///
  /// In es, this message translates to:
  /// **'Hace falta equilibrar'**
  String get balanceCardNeedsSettlement;

  /// No description provided for @balanceCardInYourFavor.
  ///
  /// In es, this message translates to:
  /// **'Quedó a tu favor'**
  String get balanceCardInYourFavor;

  /// No description provided for @balanceCardSettleButton.
  ///
  /// In es, this message translates to:
  /// **'Equilibrar'**
  String get balanceCardSettleButton;

  /// No description provided for @balanceCardXpLabel.
  ///
  /// In es, this message translates to:
  /// **'XP'**
  String get balanceCardXpLabel;

  /// No description provided for @balanceCardCoinsLabel.
  ///
  /// In es, this message translates to:
  /// **'coins'**
  String get balanceCardCoinsLabel;

  /// Status label on the home balance card when the couple uses integrated economy (no debt/balance between them).
  ///
  /// In es, this message translates to:
  /// **'Economía integrada'**
  String get balanceCardIntegratedTitle;

  /// Secondary line on the home balance card in integrated economy, shown instead of a balance amount. Refers to shared household spending.
  ///
  /// In es, this message translates to:
  /// **'Gastos del hogar'**
  String get balanceCardIntegratedSubtitle;

  /// Empty-state message shown when the activity feed has no entries.
  ///
  /// In es, this message translates to:
  /// **'No hay actividad aún'**
  String get homeNoActivityYet;

  /// First line of the dashboard headline, shared across solo and couple modes. Each mode pairs it with its own second line ('de tus días', 'del hogar', etc.).
  ///
  /// In es, this message translates to:
  /// **'Todo lo importante'**
  String get homeHeadlinePrimary;

  /// Second line of the solo-mode headline ('Everything important / in your day'). Lighter weight in the UI.
  ///
  /// In es, this message translates to:
  /// **'de tus días'**
  String get homeSoloHeadlineSecondary;

  /// Encouragement subtitle on the solo home header. Voseo 'Enfocate'.
  ///
  /// In es, this message translates to:
  /// **'Enfocate en tus objetivos hoy 🚀'**
  String get homeSoloFocusToday;

  /// Label on the solo dashboard financial summary. It describes the amount shown for personal monthly spending.
  ///
  /// In es, this message translates to:
  /// **'Gastado este mes'**
  String get homeSoloBalanceLabel;

  /// Label next to the XP progress bar on the solo dashboard summary card. Frames XP as personal progression.
  ///
  /// In es, this message translates to:
  /// **'Tu progreso'**
  String get homeSoloXpCaption;

  /// Tiny uppercase label above the level number badge on the solo dashboard summary card.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get homeSoloLevelEyebrow;

  /// No description provided for @homeSoloTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus tareas'**
  String get homeSoloTasksTitle;

  /// CTA in the solo dashboard empty task state. Opens the tasks tab so the user can create or manage tasks.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarea'**
  String get homeSoloAddTaskButton;

  /// No description provided for @homeSoloActivityTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu actividad'**
  String get homeSoloActivityTitle;

  /// Time-of-day greeting on the editorial home header, shared by solo and family-adult modes (05:00–12:59). Ends with a comma; the user's first name renders below as the hero line.
  ///
  /// In es, this message translates to:
  /// **'Buenos días,'**
  String get homeGreetingMorning;

  /// Time-of-day greeting on the editorial home header (13:00–19:59).
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes,'**
  String get homeGreetingAfternoon;

  /// Time-of-day greeting on the editorial home header (20:00–04:59).
  ///
  /// In es, this message translates to:
  /// **'Buenas noches,'**
  String get homeGreetingEvening;

  /// Shown in place of the monthly-spend amount on the solo bento tile when the month's spend is exactly zero (a giant $0 reads like broken data).
  ///
  /// In es, this message translates to:
  /// **'Sin gastos aún ✨'**
  String get homeSoloSpentEmpty;

  /// Footer of the solo spending tile once there is spending: current month plus the running daily average (already currency-formatted).
  ///
  /// In es, this message translates to:
  /// **'{month} · {amount}/día'**
  String homeSoloSpentDailyAvg(String month, String amount);

  /// Small eyebrow above the solo personal-space progress stage.
  ///
  /// In es, this message translates to:
  /// **'Mi espacio'**
  String get soloSpaceEyebrow;

  /// Compact level pill on the solo space hero.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}'**
  String soloSpaceLevel(int level);

  /// Progress helper text below the solo space level bar.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {xp} XP para el próximo nivel.'**
  String soloSpaceXpToNext(int xp);

  /// No description provided for @soloSpaceStageRecentMove.
  ///
  /// In es, this message translates to:
  /// **'Mudanza reciente'**
  String get soloSpaceStageRecentMove;

  /// No description provided for @soloSpaceStageRecentMoveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu espacio está empezando a tomar forma. Elegí una acción simple y construí desde ahí.'**
  String get soloSpaceStageRecentMoveSubtitle;

  /// No description provided for @soloSpaceStageInMotion.
  ///
  /// In es, this message translates to:
  /// **'Hogar en marcha'**
  String get soloSpaceStageInMotion;

  /// No description provided for @soloSpaceStageInMotionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ya hay movimiento: algunas rutinas, gastos o tareas empiezan a ordenar tus días.'**
  String get soloSpaceStageInMotionSubtitle;

  /// No description provided for @soloSpaceStageSteadyRoutine.
  ///
  /// In es, this message translates to:
  /// **'Rutina estable'**
  String get soloSpaceStageSteadyRoutine;

  /// No description provided for @soloSpaceStageSteadyRoutineSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ya tenés una base; ahora se trata de sostenerla sin pensarlo tanto.'**
  String get soloSpaceStageSteadyRoutineSubtitle;

  /// No description provided for @soloSpaceStageOrganizedHome.
  ///
  /// In es, this message translates to:
  /// **'Casa organizada'**
  String get soloSpaceStageOrganizedHome;

  /// No description provided for @soloSpaceStageOrganizedHomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus pendientes, gastos y actividad empiezan a leerse como un sistema claro.'**
  String get soloSpaceStageOrganizedHomeSubtitle;

  /// No description provided for @soloSpaceStageOwnRhythm.
  ///
  /// In es, this message translates to:
  /// **'Tu espacio, tu ritmo'**
  String get soloSpaceStageOwnRhythm;

  /// No description provided for @soloSpaceStageOwnRhythmSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ya no es solo registrar cosas: estás construyendo una forma propia de vivir tu hogar.'**
  String get soloSpaceStageOwnRhythmSubtitle;

  /// No description provided for @soloSpaceSignalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Señales de la semana'**
  String get soloSpaceSignalsTitle;

  /// No description provided for @soloSpaceStreakTitle.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get soloSpaceStreakTitle;

  /// Solo space streak metric.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =0{Sin racha} =1{1 día} other{{days} días}}'**
  String soloSpaceStreakMetric(int days);

  /// Active days in the last 14 days helper for solo progress.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =0{Sin días activos recientes} =1{1 día activo en 14 días} other{{days} días activos en 14 días}}'**
  String soloSpaceActiveDays14(int days);

  /// No description provided for @soloSpaceWeeklyXpTitle.
  ///
  /// In es, this message translates to:
  /// **'XP semanal'**
  String get soloSpaceWeeklyXpTitle;

  /// No description provided for @soloSpaceWeeklyTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas semanales'**
  String get soloSpaceWeeklyTasksTitle;

  /// Positive weekly delta helper for solo progress.
  ///
  /// In es, this message translates to:
  /// **'+{value} vs semana anterior'**
  String soloSpaceDeltaUp(int value);

  /// Negative weekly delta helper for solo progress.
  ///
  /// In es, this message translates to:
  /// **'{value} vs semana anterior'**
  String soloSpaceDeltaDown(int value);

  /// No description provided for @soloSpaceDeltaSame.
  ///
  /// In es, this message translates to:
  /// **'Igual que la semana anterior'**
  String get soloSpaceDeltaSame;

  /// Top task category chip in solo progress.
  ///
  /// In es, this message translates to:
  /// **'Tareas: {category}'**
  String soloSpaceTopTaskCategory(String category);

  /// Top expense category chip in solo progress.
  ///
  /// In es, this message translates to:
  /// **'Gastos: {category}'**
  String soloSpaceTopExpenseCategory(String category);

  /// No description provided for @soloSpaceSignalsSyncing.
  ///
  /// In es, this message translates to:
  /// **'Actualizando señales reales de tu hogar.'**
  String get soloSpaceSignalsSyncing;

  /// No description provided for @soloSpaceDimensionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo viene tu hogar'**
  String get soloSpaceDimensionsTitle;

  /// No description provided for @soloSpaceOrderTitle.
  ///
  /// In es, this message translates to:
  /// **'Orden'**
  String get soloSpaceOrderTitle;

  /// No description provided for @soloSpaceOrderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas, pendientes y cierre del día.'**
  String get soloSpaceOrderSubtitle;

  /// No description provided for @soloSpaceClarityTitle.
  ///
  /// In es, this message translates to:
  /// **'Claridad'**
  String get soloSpaceClarityTitle;

  /// No description provided for @soloSpaceClaritySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gastos registrados y lectura del mes.'**
  String get soloSpaceClaritySubtitle;

  /// No description provided for @soloSpaceContinuityTitle.
  ///
  /// In es, this message translates to:
  /// **'Continuidad'**
  String get soloSpaceContinuityTitle;

  /// No description provided for @soloSpaceContinuitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Actividad reciente y constancia real.'**
  String get soloSpaceContinuitySubtitle;

  /// No description provided for @soloSpaceNextTitle.
  ///
  /// In es, this message translates to:
  /// **'Próximo gesto'**
  String get soloSpaceNextTitle;

  /// No description provided for @soloSpaceNextCreateTask.
  ///
  /// In es, this message translates to:
  /// **'Creá una tarea base'**
  String get soloSpaceNextCreateTask;

  /// No description provided for @soloSpaceNextCreateTaskSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Una rutina chica alcanza para empezar a darle forma a tu espacio.'**
  String get soloSpaceNextCreateTaskSubtitle;

  /// No description provided for @soloSpaceNextCompleteTask.
  ///
  /// In es, this message translates to:
  /// **'Cerrá una tarea de hoy'**
  String get soloSpaceNextCompleteTask;

  /// No description provided for @soloSpaceNextCompleteTaskSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Bajar pendientes es la forma más directa de mejorar tu Orden.'**
  String get soloSpaceNextCompleteTaskSubtitle;

  /// No description provided for @soloSpaceNextRegisterExpense.
  ///
  /// In es, this message translates to:
  /// **'Registrá tu primer gasto del mes'**
  String get soloSpaceNextRegisterExpense;

  /// No description provided for @soloSpaceNextRegisterExpenseSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Con un movimiento cargado, tu Claridad empieza a tener contexto.'**
  String get soloSpaceNextRegisterExpenseSubtitle;

  /// No description provided for @soloSpaceNextReviewShopping.
  ///
  /// In es, this message translates to:
  /// **'Revisá tu lista de compras'**
  String get soloSpaceNextReviewShopping;

  /// No description provided for @soloSpaceNextReviewShoppingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Una compra ordenada evita ruido y mantiene el mes más liviano.'**
  String get soloSpaceNextReviewShoppingSubtitle;

  /// No description provided for @soloSpaceNextKeepGoing.
  ///
  /// In es, this message translates to:
  /// **'Sumá una acción simple'**
  String get soloSpaceNextKeepGoing;

  /// No description provided for @soloSpaceNextKeepGoingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Un gesto chico hoy sostiene la continuidad de tu hogar.'**
  String get soloSpaceNextKeepGoingSubtitle;

  /// No description provided for @soloSpaceMilestonesTitle.
  ///
  /// In es, this message translates to:
  /// **'Hitos personales'**
  String get soloSpaceMilestonesTitle;

  /// No description provided for @soloSpaceMilestoneFirstStep.
  ///
  /// In es, this message translates to:
  /// **'Primer paso'**
  String get soloSpaceMilestoneFirstStep;

  /// No description provided for @soloSpaceMilestoneFirstStepDesc.
  ///
  /// In es, this message translates to:
  /// **'Completaste tu primera tarea.'**
  String get soloSpaceMilestoneFirstStepDesc;

  /// No description provided for @soloSpaceMilestoneWeekInMotion.
  ///
  /// In es, this message translates to:
  /// **'Semana en marcha'**
  String get soloSpaceMilestoneWeekInMotion;

  /// No description provided for @soloSpaceMilestoneWeekInMotionDesc.
  ///
  /// In es, this message translates to:
  /// **'Tuviste actividad reciente suficiente para marcar ritmo.'**
  String get soloSpaceMilestoneWeekInMotionDesc;

  /// No description provided for @soloSpaceMilestoneClearerHome.
  ///
  /// In es, this message translates to:
  /// **'Casa más clara'**
  String get soloSpaceMilestoneClearerHome;

  /// No description provided for @soloSpaceMilestoneClearerHomeDesc.
  ///
  /// In es, this message translates to:
  /// **'Tus finanzas ya tienen señales útiles este mes.'**
  String get soloSpaceMilestoneClearerHomeDesc;

  /// No description provided for @soloSpaceMilestoneSteadyRoutine.
  ///
  /// In es, this message translates to:
  /// **'Rutina sostenida'**
  String get soloSpaceMilestoneSteadyRoutine;

  /// No description provided for @soloSpaceMilestoneSteadyRoutineDesc.
  ///
  /// In es, this message translates to:
  /// **'Orden y continuidad empiezan a trabajar juntos.'**
  String get soloSpaceMilestoneSteadyRoutineDesc;

  /// No description provided for @soloSpaceMilestoneOwnRhythm.
  ///
  /// In es, this message translates to:
  /// **'Ritmo propio'**
  String get soloSpaceMilestoneOwnRhythm;

  /// No description provided for @soloSpaceMilestoneOwnRhythmDesc.
  ///
  /// In es, this message translates to:
  /// **'Tu progreso ya muestra una identidad personal.'**
  String get soloSpaceMilestoneOwnRhythmDesc;

  /// No description provided for @soloSpaceFutureHint.
  ///
  /// In es, this message translates to:
  /// **'Tu espacio se ajusta con tus tareas, gastos y ritmo semanal.'**
  String get soloSpaceFutureHint;

  /// No description provided for @soloSpaceRitualTitle.
  ///
  /// In es, this message translates to:
  /// **'Cierre semanal'**
  String get soloSpaceRitualTitle;

  /// Weekly solo ritual completion progress.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} gestos'**
  String soloSpaceRitualProgress(int done, int total);

  /// No description provided for @soloSpaceRitualReviewTasks.
  ///
  /// In es, this message translates to:
  /// **'Revisar pendientes abiertos'**
  String get soloSpaceRitualReviewTasks;

  /// No description provided for @soloSpaceRitualCheckSpending.
  ///
  /// In es, this message translates to:
  /// **'Mirar gastos del mes'**
  String get soloSpaceRitualCheckSpending;

  /// No description provided for @soloSpaceRitualPlanShopping.
  ///
  /// In es, this message translates to:
  /// **'Ajustar la lista de compras'**
  String get soloSpaceRitualPlanShopping;

  /// No description provided for @soloSpaceRitualChooseNextRoutine.
  ///
  /// In es, this message translates to:
  /// **'Elegir una rutina para sostener'**
  String get soloSpaceRitualChooseNextRoutine;

  /// No description provided for @soloSpaceInsightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Lectura de la semana'**
  String get soloSpaceInsightsTitle;

  /// No description provided for @soloSpaceInsightNoActivity.
  ///
  /// In es, this message translates to:
  /// **'Punto de partida'**
  String get soloSpaceInsightNoActivity;

  /// No description provided for @soloSpaceInsightNoActivityDesc.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay señales fuertes esta semana. Un gesto simple alcanza para arrancar.'**
  String get soloSpaceInsightNoActivityDesc;

  /// No description provided for @soloSpaceInsightStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha en construcción'**
  String get soloSpaceInsightStreak;

  /// Insight text for a solo streak.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1{Un día activo ya marca continuidad.} other{{days} días activos seguidos empiezan a formar ritmo.}}'**
  String soloSpaceInsightStreakDesc(int days);

  /// No description provided for @soloSpaceInsightWeekImproved.
  ///
  /// In es, this message translates to:
  /// **'Semana más fuerte'**
  String get soloSpaceInsightWeekImproved;

  /// Insight text when weekly XP improved.
  ///
  /// In es, this message translates to:
  /// **'+{value} XP contra la semana anterior. Hay más movimiento en tu casa.'**
  String soloSpaceInsightWeekImprovedDesc(int value);

  /// No description provided for @soloSpaceInsightWeekSlowed.
  ///
  /// In es, this message translates to:
  /// **'Semana más baja'**
  String get soloSpaceInsightWeekSlowed;

  /// No description provided for @soloSpaceInsightWeekSlowedDesc.
  ///
  /// In es, this message translates to:
  /// **'Bajó el movimiento. Conviene elegir una acción chica y cerrar el día.'**
  String get soloSpaceInsightWeekSlowedDesc;

  /// No description provided for @soloSpaceInsightFinanceVisible.
  ///
  /// In es, this message translates to:
  /// **'Finanzas con contexto'**
  String get soloSpaceInsightFinanceVisible;

  /// No description provided for @soloSpaceInsightFinanceVisibleDesc.
  ///
  /// In es, this message translates to:
  /// **'Ya hay movimientos suficientes para leer el mes con más claridad.'**
  String get soloSpaceInsightFinanceVisibleDesc;

  /// No description provided for @soloSpaceInsightNoFinance.
  ///
  /// In es, this message translates to:
  /// **'Falta lectura financiera'**
  String get soloSpaceInsightNoFinance;

  /// No description provided for @soloSpaceInsightNoFinanceDesc.
  ///
  /// In es, this message translates to:
  /// **'Registrar un gasto real activa mejores señales de Claridad.'**
  String get soloSpaceInsightNoFinanceDesc;

  /// No description provided for @soloSpaceInsightTaskCategory.
  ///
  /// In es, this message translates to:
  /// **'Patrón de tareas'**
  String get soloSpaceInsightTaskCategory;

  /// Insight text for the top task category.
  ///
  /// In es, this message translates to:
  /// **'{category} aparece como foco fuerte este mes.'**
  String soloSpaceInsightTaskCategoryDesc(String category);

  /// No description provided for @soloSpaceInsightExpenseCategory.
  ///
  /// In es, this message translates to:
  /// **'Patrón de gastos'**
  String get soloSpaceInsightExpenseCategory;

  /// Insight text for the top expense category.
  ///
  /// In es, this message translates to:
  /// **'{category} concentra más movimiento este mes.'**
  String soloSpaceInsightExpenseCategoryDesc(String category);

  /// No description provided for @soloSpaceSuggestionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Herramientas sugeridas'**
  String get soloSpaceSuggestionsTitle;

  /// No description provided for @soloSpaceSuggestionRecurringTask.
  ///
  /// In es, this message translates to:
  /// **'Convertir algo en rutina'**
  String get soloSpaceSuggestionRecurringTask;

  /// No description provided for @soloSpaceSuggestionRecurringTaskDesc.
  ///
  /// In es, this message translates to:
  /// **'Una tarea recurrente baja fricción y sostiene Orden.'**
  String get soloSpaceSuggestionRecurringTaskDesc;

  /// No description provided for @soloSpaceSuggestionClosePending.
  ///
  /// In es, this message translates to:
  /// **'Cerrar lo pendiente'**
  String get soloSpaceSuggestionClosePending;

  /// No description provided for @soloSpaceSuggestionClosePendingDesc.
  ///
  /// In es, this message translates to:
  /// **'Resolver una tarea de hoy libera espacio mental.'**
  String get soloSpaceSuggestionClosePendingDesc;

  /// No description provided for @soloSpaceSuggestionRegisterExpense.
  ///
  /// In es, this message translates to:
  /// **'Cargar un gasto real'**
  String get soloSpaceSuggestionRegisterExpense;

  /// No description provided for @soloSpaceSuggestionRegisterExpenseDesc.
  ///
  /// In es, this message translates to:
  /// **'Con un movimiento, la lectura del mes deja de estar vacía.'**
  String get soloSpaceSuggestionRegisterExpenseDesc;

  /// No description provided for @soloSpaceSuggestionReviewShopping.
  ///
  /// In es, this message translates to:
  /// **'Revisar compras'**
  String get soloSpaceSuggestionReviewShopping;

  /// No description provided for @soloSpaceSuggestionReviewShoppingDesc.
  ///
  /// In es, this message translates to:
  /// **'Una lista clara evita compras repetidas o de último minuto.'**
  String get soloSpaceSuggestionReviewShoppingDesc;

  /// No description provided for @soloSpaceSuggestionProtectStreak.
  ///
  /// In es, this message translates to:
  /// **'Proteger la racha'**
  String get soloSpaceSuggestionProtectStreak;

  /// No description provided for @soloSpaceSuggestionProtectStreakDesc.
  ///
  /// In es, this message translates to:
  /// **'Una acción chica hoy mantiene viva la continuidad.'**
  String get soloSpaceSuggestionProtectStreakDesc;

  /// No description provided for @soloSpaceSuggestionWeeklyReview.
  ///
  /// In es, this message translates to:
  /// **'Hacer cierre semanal'**
  String get soloSpaceSuggestionWeeklyReview;

  /// No description provided for @soloSpaceSuggestionWeeklyReviewDesc.
  ///
  /// In es, this message translates to:
  /// **'Marcá los gestos del ritual y dejá la semana ordenada.'**
  String get soloSpaceSuggestionWeeklyReviewDesc;

  /// No description provided for @soloSpaceUnlocksTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueos suaves'**
  String get soloSpaceUnlocksTitle;

  /// No description provided for @soloSpaceUnlockActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get soloSpaceUnlockActive;

  /// No description provided for @soloSpaceUnlockNext.
  ///
  /// In es, this message translates to:
  /// **'Luego'**
  String get soloSpaceUnlockNext;

  /// No description provided for @soloSpaceUnlockWeeklyReview.
  ///
  /// In es, this message translates to:
  /// **'Vista de cierre'**
  String get soloSpaceUnlockWeeklyReview;

  /// No description provided for @soloSpaceUnlockWeeklyReviewDesc.
  ///
  /// In es, this message translates to:
  /// **'Disponible desde el inicio para ordenar la semana sin presión.'**
  String get soloSpaceUnlockWeeklyReviewDesc;

  /// No description provided for @soloSpaceUnlockRecurringTemplates.
  ///
  /// In es, this message translates to:
  /// **'Plantillas recurrentes'**
  String get soloSpaceUnlockRecurringTemplates;

  /// No description provided for @soloSpaceUnlockRecurringTemplatesDesc.
  ///
  /// In es, this message translates to:
  /// **'Aparecen cuando ya hay base para repetir rutinas.'**
  String get soloSpaceUnlockRecurringTemplatesDesc;

  /// No description provided for @soloSpaceUnlockHabitInsights.
  ///
  /// In es, this message translates to:
  /// **'Insights de hábitos'**
  String get soloSpaceUnlockHabitInsights;

  /// No description provided for @soloSpaceUnlockHabitInsightsDesc.
  ///
  /// In es, this message translates to:
  /// **'Se activan con varios días de actividad real.'**
  String get soloSpaceUnlockHabitInsightsDesc;

  /// No description provided for @soloSpaceUnlockPersonalMedal.
  ///
  /// In es, this message translates to:
  /// **'Medalla personal'**
  String get soloSpaceUnlockPersonalMedal;

  /// No description provided for @soloSpaceUnlockPersonalMedalDesc.
  ///
  /// In es, this message translates to:
  /// **'Reconoce una etapa sostenida sin competir con nadie.'**
  String get soloSpaceUnlockPersonalMedalDesc;

  /// No description provided for @soloSpaceUnlockRhythmRecommendations.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones de ritmo'**
  String get soloSpaceUnlockRhythmRecommendations;

  /// No description provided for @soloSpaceUnlockRhythmRecommendationsDesc.
  ///
  /// In es, this message translates to:
  /// **'Cruzan claridad financiera con continuidad semanal.'**
  String get soloSpaceUnlockRhythmRecommendationsDesc;

  /// Coins-earned figure on activity feed entries ('coin' is the app's game-currency name, kept in English in both locales).
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{+1 coin} other{+{count} coins}}'**
  String activityCoinsPlus(int count);

  /// Coins-spent figure on activity feed entries (redeemed rewards).
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{-1 coin} other{-{count} coins}}'**
  String activityCoinsMinus(int count);

  /// Tiny uppercase eyebrow on the approvals bento tile of the family-adult dashboard (Parent Mode inbox).
  ///
  /// In es, this message translates to:
  /// **'Aprobaciones'**
  String get homeFamilyApprovalsTileLabel;

  /// Caption under the pending-approvals count on the family dashboard approvals tile. The number renders separately in the tile chip.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{pendiente} other{pendientes}}'**
  String homeFamilyApprovalsPendingLabel(int count);

  /// Caption on the family dashboard approvals tile when there is nothing awaiting review.
  ///
  /// In es, this message translates to:
  /// **'Al día'**
  String get homeFamilyApprovalsAllClear;

  /// Chip on the Finances summary card when household members owe the user money for shared expenses (divided economy). Amount arrives currency-formatted.
  ///
  /// In es, this message translates to:
  /// **'Te deben {amount}'**
  String expensesYouAreOwed(String amount);

  /// Chip on the Finances summary card when the user owes money for shared expenses (divided economy). Voseo 'Debés'.
  ///
  /// In es, this message translates to:
  /// **'Debés {amount}'**
  String expensesYouOwe(String amount);

  /// Running daily average under the Finances hero amount (simple expenses mode). Amount arrives already currency-formatted; the month renders separately in the header pill.
  ///
  /// In es, this message translates to:
  /// **'≈ {amount}/día'**
  String expensesDailyAvg(String amount);

  /// Second line of the couple-mode dashboard headline ('Todo lo importante / del hogar').
  ///
  /// In es, this message translates to:
  /// **'del hogar'**
  String get homeCoupleHeadlineSecondary;

  /// Tiny connector word (single word, no trailing space) shown before the partner's name in the couple home header.
  ///
  /// In es, this message translates to:
  /// **'con'**
  String get homeCoupleHeadlineConnector;

  /// Fallback shown when the partner's display name isn't loaded yet. Lowercase noun phrase.
  ///
  /// In es, this message translates to:
  /// **'tu pareja'**
  String get homeCouplePartnerFallback;

  /// Title of the shopping-list preview card on the couple home.
  ///
  /// In es, this message translates to:
  /// **'Lista actual'**
  String get homeCoupleShoppingListTitle;

  /// Acción para abrir la lista completa desde el preview del Home.
  ///
  /// In es, this message translates to:
  /// **'Abrir compras'**
  String get homeShoppingPreviewOpen;

  /// Estado vacío del preview de compras del Home.
  ///
  /// In es, this message translates to:
  /// **'No hay productos pendientes.'**
  String get homeShoppingPreviewEmpty;

  /// Error amigable al cargar el preview de compras.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la lista.'**
  String get homeShoppingPreviewLoadError;

  /// Cantidad de productos pendientes en el preview de compras.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 pendiente} other{{count} pendientes}}'**
  String homeShoppingPreviewPendingCount(int count);

  /// Cantidad de productos adicionales ocultos en el preview compacto.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{+1 más en la lista} other{+{count} más en la lista}}'**
  String homeShoppingPreviewMoreItems(int count);

  /// Section title above the day-tasks list on the couple home.
  ///
  /// In es, this message translates to:
  /// **'Hoy en casa'**
  String get homeCoupleTasksTitle;

  /// Section title above the recent-activity feed on the couple home.
  ///
  /// In es, this message translates to:
  /// **'Movimientos del hogar'**
  String get homeCoupleActivityTitle;

  /// No description provided for @homeCoupleActivityEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay movimientos'**
  String get homeCoupleActivityEmptyTitle;

  /// Empty-state body for the activity feed. 'aca' = 'aquí' in Argentine voseo.
  ///
  /// In es, this message translates to:
  /// **'Cuando haya una tarea o un gasto nuevo, aparece acá.'**
  String get homeCoupleActivityEmptyBody;

  /// Snackbar shown when the user tries to settle but their user id can't be resolved.
  ///
  /// In es, this message translates to:
  /// **'No pudimos identificar tu usuario.'**
  String get homeCoupleSettlementErrorNoUser;

  /// Main title for the settle-up confirmation dialog.
  ///
  /// In es, this message translates to:
  /// **'Registrar equilibrio'**
  String get homeCoupleSettlementDialogTitle;

  /// Compact payer-to-receiver label when the current user pays the partner.
  ///
  /// In es, this message translates to:
  /// **'Vos → {partnerName}'**
  String homeCoupleSettlementDialogDirectionPay(String partnerName);

  /// Compact payer-to-receiver label when the partner pays the current user.
  ///
  /// In es, this message translates to:
  /// **'{partnerName} → vos'**
  String homeCoupleSettlementDialogDirectionReceive(String partnerName);

  /// Short helper copy in the settle-up dialog explaining the result of the payment.
  ///
  /// In es, this message translates to:
  /// **'Esto va a dejar el balance del hogar en cero.'**
  String get homeCoupleSettlementDialogBalanceZero;

  /// Secondary action in the settle-up dialog.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get homeCoupleSettlementDialogCancel;

  /// Primary action in the settle-up dialog.
  ///
  /// In es, this message translates to:
  /// **'Registrar pago'**
  String get homeCoupleSettlementDialogConfirm;

  /// Settle-up dialog title when the current user owes the partner.
  ///
  /// In es, this message translates to:
  /// **'Equilibrar con {partnerName}'**
  String homeCoupleSettlementDialogTitlePay(String partnerName);

  /// Settle-up dialog title when the partner owes the current user — they're recording a payment they received.
  ///
  /// In es, this message translates to:
  /// **'Registrar equilibrio'**
  String get homeCoupleSettlementDialogTitleReceive;

  /// Settle-up dialog body when the user pays the partner. {amount} is a pre-formatted localized currency string.
  ///
  /// In es, this message translates to:
  /// **'Se va a registrar un pago de {amount} para saldar el balance con {partnerName}.'**
  String homeCoupleSettlementDialogBodyPay(String amount, String partnerName);

  /// Settle-up dialog body when the user receives money from the partner. {amount} is a pre-formatted localized currency string.
  ///
  /// In es, this message translates to:
  /// **'Se va a registrar que {partnerName} te compensó {amount} para dejar el balance al día.'**
  String homeCoupleSettlementDialogBodyReceive(
      String partnerName, String amount);

  /// Tiny success label inside the settle-up button after the operation completes. One word.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get homeCoupleSettlementDoneBadge;

  /// Success snackbar shown after the user settles up by paying.
  ///
  /// In es, this message translates to:
  /// **'Balance equilibrado con {partnerName}.'**
  String homeCoupleSettlementSuccessPay(String partnerName);

  /// Success snackbar after the user records that the partner paid them.
  ///
  /// In es, this message translates to:
  /// **'Registramos el equilibrio con {partnerName}.'**
  String homeCoupleSettlementSuccessReceive(String partnerName);

  /// Error snackbar shown when the settle-up RPC fails. {message} is the raw exception text.
  ///
  /// In es, this message translates to:
  /// **'No se pudo equilibrar el balance: {message}'**
  String homeCoupleSettlementError(String message);

  /// Time-of-day greeting before noon. Argentine 'Buen día' (singular) — not 'Buenos días'.
  ///
  /// In es, this message translates to:
  /// **'Buen día'**
  String get commonGreetingMorning;

  /// No description provided for @commonGreetingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get commonGreetingAfternoon;

  /// No description provided for @commonGreetingEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get commonGreetingEvening;

  /// Generic 'See all' link/button shown next to a section preview that has more items than the preview shows.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get homeViewAllButton;

  /// Generic 'View list' button — opens the full shopping list.
  ///
  /// In es, this message translates to:
  /// **'Ver lista'**
  String get homeViewListButton;

  /// Subtitle under the time greeting on the friends home. 'piso' is Argentine slang for 'shared flat / place'.
  ///
  /// In es, this message translates to:
  /// **'Así viene el piso hoy.'**
  String get homeFriendsHeaderSubtitle;

  /// Warning banner shown when the current user's member profile isn't found in the household member list (rare race / data issue).
  ///
  /// In es, this message translates to:
  /// **'No encontramos tu perfil en este piso.'**
  String get homeFriendsMemberNotFound;

  /// No description provided for @homeFriendsBalancesTitle.
  ///
  /// In es, this message translates to:
  /// **'Saldos del piso'**
  String get homeFriendsBalancesTitle;

  /// No description provided for @homeFriendsBalancesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay balances para mostrar.'**
  String get homeFriendsBalancesEmptyTitle;

  /// No description provided for @homeFriendsBalancesEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando registren gastos compartidos, vas a ver acá el saldo neto de cada integrante.'**
  String get homeFriendsBalancesEmptyBody;

  /// Card title shown on the FamilyBalanceCard widget when rendered for friends mode.
  ///
  /// In es, this message translates to:
  /// **'Estado del balance'**
  String get homeFriendsBalanceCardTitle;

  /// No description provided for @homeFriendsTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas del piso'**
  String get homeFriendsTasksTitle;

  /// No description provided for @homeFriendsTasksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que sigue pendiente para mantener todo en orden.'**
  String get homeFriendsTasksSubtitle;

  /// Snackbar shown when completing a task returns null (silent failure).
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la tarea. Intentá de nuevo.'**
  String get homeFriendsTaskCompleteError;

  /// No description provided for @homeFriendsShoppingTitle.
  ///
  /// In es, this message translates to:
  /// **'Compras del piso'**
  String get homeFriendsShoppingTitle;

  /// No description provided for @homeFriendsShoppingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que falta comprar para la semana.'**
  String get homeFriendsShoppingSubtitle;

  /// Empty-state title in the tasks section (currently rendered nowhere — kept for parity with old code).
  ///
  /// In es, this message translates to:
  /// **'¡Todo limpio!'**
  String get homeFriendsAllCleanTitle;

  /// No description provided for @homeFriendsActivityTitle.
  ///
  /// In es, this message translates to:
  /// **'Actividad del piso'**
  String get homeFriendsActivityTitle;

  /// No description provided for @homeFriendsActivitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los últimos movimientos compartidos del hogar.'**
  String get homeFriendsActivitySubtitle;

  /// No description provided for @homeFriendsActivityEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hubo movimientos compartidos.'**
  String get homeFriendsActivityEmpty;

  /// Section header above the debt-settlement card in friends mode, where roommates settle outstanding balances.
  ///
  /// In es, this message translates to:
  /// **'Saldar cuentas'**
  String get homeFriendsSettleTitle;

  /// Subtitle under the settle-up section header in friends mode.
  ///
  /// In es, this message translates to:
  /// **'Quién le paga a quién para quedar en cero.'**
  String get homeFriendsSettleSubtitle;

  /// Error state shown when the household balances fail to load in friends mode. Tappable to retry.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los saldos. Tocá para reintentar.'**
  String get homeFriendsBalancesLoadError;

  /// Error state shown when the today tasks fail to load in friends mode. Tappable to retry.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las tareas. Tocá para reintentar.'**
  String get homeFriendsTasksLoadError;

  /// Error state shown when the shopping list fails to load in friends mode. Tappable to retry.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las compras. Tocá para reintentar.'**
  String get homeFriendsShoppingLoadError;

  /// Error state shown when the recent activity feed fails to load in friends mode. Tappable to retry.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la actividad. Tocá para reintentar.'**
  String get homeFriendsActivityLoadError;

  /// Status line on the shared balance card when the current user owes money to the group.
  ///
  /// In es, this message translates to:
  /// **'Te toca acomodar tu saldo'**
  String get balanceCardStatusOwed;

  /// Status line on the shared balance card when the group owes money to the current user.
  ///
  /// In es, this message translates to:
  /// **'Quedó a tu favor'**
  String get balanceCardStatusFavor;

  /// Status line on the shared balance card when there's no current-user balance to highlight (generic group view).
  ///
  /// In es, this message translates to:
  /// **'Balance compartido'**
  String get balanceCardStatusShared;

  /// Short badge on the balance card when the current user's balance is settled (zero).
  ///
  /// In es, this message translates to:
  /// **'Al día'**
  String get balanceCardBadgeSettled;

  /// Short badge on the balance card when the current user owes money.
  ///
  /// In es, this message translates to:
  /// **'Debés'**
  String get balanceCardBadgeOwes;

  /// Short badge on the balance card when the current user is owed money.
  ///
  /// In es, this message translates to:
  /// **'A favor'**
  String get balanceCardBadgeFavor;

  /// Headline on the balance card showing the number of open shared movements when there's no per-user balance.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{0 movimientos} one{1 movimiento} other{{count} movimientos}}'**
  String balanceCardMovements(int count);

  /// Inline metric label for the number of household members on the balance card.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Integrante} other{Integrantes}}'**
  String balanceCardMembers(int count);

  /// Inline metric label for the number of open (unsettled) balances on the balance card.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Todo al día} one{Saldo abierto} other{Saldos abiertos}}'**
  String balanceCardOpenBalances(int count);

  /// Hint shown on the balance card when the household has a single member, inviting them to add more.
  ///
  /// In es, this message translates to:
  /// **'Cuando sumes más integrantes, acá vas a ver cómo queda el balance compartido.'**
  String get balanceCardSingleMemberHint;

  /// Per-member balance label when that member owes money to the group.
  ///
  /// In es, this message translates to:
  /// **'Debe'**
  String get balanceCardMemberOwes;

  /// Per-member balance label when the group owes money to that member.
  ///
  /// In es, this message translates to:
  /// **'A favor'**
  String get balanceCardMemberFavor;

  /// Per-member balance label when that member is settled (zero balance).
  ///
  /// In es, this message translates to:
  /// **'Al día'**
  String get balanceCardMemberSettled;

  /// Title of the debt-settlement card that lists who pays whom to balance the household.
  ///
  /// In es, this message translates to:
  /// **'Saldar deudas'**
  String get settleSectionTitle;

  /// Subtitle of the settle-up card when a single payment is needed to balance everyone.
  ///
  /// In es, this message translates to:
  /// **'1 pago necesario para equilibrar'**
  String get settleSectionOnePayment;

  /// Subtitle of the settle-up card when multiple payments are needed.
  ///
  /// In es, this message translates to:
  /// **'{count} pagos para equilibrar todo'**
  String settleSectionPayments(int count);

  /// Empty/positive state of the settle-up card when there are no outstanding debts.
  ///
  /// In es, this message translates to:
  /// **'Todo equilibrado. Nadie le debe a nadie.'**
  String get settleAllSettled;

  /// Caption under a debtor's name in the settle-up row, naming the creditor they pay.
  ///
  /// In es, this message translates to:
  /// **'le paga a {name}'**
  String settlePaysTo(String name);

  /// Title of the dialog confirming a settlement payment between two members.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get settleConfirmTitle;

  /// Body of the settlement confirmation dialog.
  ///
  /// In es, this message translates to:
  /// **'{from} le paga {amount} a {to}.'**
  String settleConfirmBody(String from, String amount, String to);

  /// Snackbar shown after a settlement payment is recorded.
  ///
  /// In es, this message translates to:
  /// **'Pago de {amount} registrado.'**
  String settleSuccess(String amount);

  /// Snackbar shown when recording a settlement payment fails.
  ///
  /// In es, this message translates to:
  /// **'No se pudo registrar el pago: {error}'**
  String settleError(String error);

  /// No description provided for @homeFamilyMemberNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos tu perfil en este hogar.'**
  String get homeFamilyMemberNotFound;

  /// Adult/teen header chip label for in-app coin balance.
  ///
  /// In es, this message translates to:
  /// **'Monedas'**
  String get homeFamilyMetricCoins;

  /// Fallback display name on the adult/teen welcome line when the current user's name isn't loaded.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get homeFamilyAdultFallbackName;

  /// Motivational greeting prefix shown to a child member. Includes trailing comma+space; the child's first name is appended after.
  ///
  /// In es, this message translates to:
  /// **'¡Vamos, '**
  String get homeFamilyChildHello;

  /// Greeting suffix shown after the child member's name.
  ///
  /// In es, this message translates to:
  /// **'!'**
  String get homeFamilyChildGreetingSuffix;

  /// Fallback name for a child whose display name isn't loaded yet. Spanish 'campeón' (champ) — used both in the greeting and in the hero body.
  ///
  /// In es, this message translates to:
  /// **'campeon'**
  String get homeFamilyChildFallbackName;

  /// Hero card title shown to a child on the family home.
  ///
  /// In es, this message translates to:
  /// **'Aventura de hoy'**
  String get homeFamilyChildHeroTitle;

  /// Hero card body for a child. Tells them every approved task awards coins they can spend in the store.
  ///
  /// In es, this message translates to:
  /// **'{firstName}, cada misión aprobada suma coins para la tienda.'**
  String homeFamilyChildHeroBody(String firstName);

  /// Small line above the 'Tienda' button in the child hero card. Voseo 'podés' written without accent in source.
  ///
  /// In es, this message translates to:
  /// **'Mirá qué premios podés alcanzar.'**
  String get homeFamilyChildRewardsPrompt;

  /// Activity feed section title shown to a child member. First-person possessive.
  ///
  /// In es, this message translates to:
  /// **'Mis logros'**
  String get homeFamilyChildActivityTitle;

  /// Activity feed section title shown to adult/teen family members.
  ///
  /// In es, this message translates to:
  /// **'Movimientos del hogar'**
  String get homeFamilyActivityTitle;

  /// Default activity feed title when a specific title isn't passed in (rarely used — adult/child views always pass an explicit title).
  ///
  /// In es, this message translates to:
  /// **'Actividad Reciente'**
  String get homeFamilyActivityTitleDefault;

  /// No description provided for @homeFamilyActivityEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay actividad reciente'**
  String get homeFamilyActivityEmptyTitle;

  /// No description provided for @homeFamilyActivityEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Las tareas, gastos y compras van a aparecer acá.'**
  String get homeFamilyActivityEmptyBody;

  /// No description provided for @homeFamilyShoppingTitle.
  ///
  /// In es, this message translates to:
  /// **'Compras del hogar'**
  String get homeFamilyShoppingTitle;

  /// Empty-state shown when the household shopping list has nothing pending.
  ///
  /// In es, this message translates to:
  /// **'Lista al día'**
  String get homeFamilyShoppingAllDone;

  /// Tappable footer indicating how many more items are in the shopping list beyond the visible 3.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Hay 1 producto más en la lista} other{Hay {count} productos más en la lista}}'**
  String homeFamilyShoppingMoreItems(int count);

  /// No description provided for @homeFamilyFinanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Finanzas familiares'**
  String get homeFamilyFinanceTitle;

  /// No description provided for @homeFamilyFinanceLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las finanzas del hogar por ahora.'**
  String get homeFamilyFinanceLoadError;

  /// 'See all' button next to the family finance section. Masculine plural ('todos') because it refers to 'movimientos' (m.); the tasks section uses the feminine 'todas'.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get homeFamilyFinanceViewAll;

  /// No description provided for @homeFamilyFinanceMonthSpent.
  ///
  /// In es, this message translates to:
  /// **'Gasto compartido del mes'**
  String get homeFamilyFinanceMonthSpent;

  /// No description provided for @homeFamilyFinanceMonthEmpty.
  ///
  /// In es, this message translates to:
  /// **'Mes sin gastos'**
  String get homeFamilyFinanceMonthEmpty;

  /// Section title shown to a child member on the family home — kid-friendly framing of tasks as 'missions'.
  ///
  /// In es, this message translates to:
  /// **'Mis misiones'**
  String get familyTasksTitleChild;

  /// Section title shown to a teen member on the family home.
  ///
  /// In es, this message translates to:
  /// **'Tareas del hogar'**
  String get familyTasksTitleTeen;

  /// No description provided for @familyTasksEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todo al día'**
  String get familyTasksEmptyTitle;

  /// No description provided for @familyTasksEmptyChildSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Hoy podés descansar o mirar la tienda.'**
  String get familyTasksEmptyChildSubtitle;

  /// No description provided for @familyTasksEmptyOtherSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No hay tareas programadas para hoy.'**
  String get familyTasksEmptyOtherSubtitle;

  /// No description provided for @familyTasksMarkTitle.
  ///
  /// In es, this message translates to:
  /// **'Marcar tarea'**
  String get familyTasksMarkTitle;

  /// Confirm dialog body when a child completes a task that requires parent approval.
  ///
  /// In es, this message translates to:
  /// **'Se va a marcar \"{taskTitle}\" como realizada por {actorName} y se enviará a revisión.'**
  String familyTasksMarkBodyApproval(String taskTitle, String actorName);

  /// Confirm dialog body when an adult/teen completes a task directly.
  ///
  /// In es, this message translates to:
  /// **'Se va a marcar \"{taskTitle}\" como realizada por {actorName}.'**
  String familyTasksMarkBodyDirect(String taskTitle, String actorName);

  /// Fallback for the current user's name in confirmation copy. Voseo 'vos' = 'you'.
  ///
  /// In es, this message translates to:
  /// **'vos'**
  String get familyTasksActorFallback;

  /// No description provided for @familyTasksTakeoverTitle.
  ///
  /// In es, this message translates to:
  /// **'Completar tarea'**
  String get familyTasksTakeoverTitle;

  /// Body shown when an adult takes over a task assigned to a child / another member.
  ///
  /// In es, this message translates to:
  /// **'Esta tarea estaba asignada a {ownerName}. Si seguís, se va a marcar como realizada por vos.'**
  String familyTasksTakeoverBody(String ownerName);

  /// No description provided for @familyTasksTakeoverConfirm.
  ///
  /// In es, this message translates to:
  /// **'Completar'**
  String get familyTasksTakeoverConfirm;

  /// Fallback when the original assignee's name isn't loaded for the takeover dialog.
  ///
  /// In es, this message translates to:
  /// **'otro integrante'**
  String get familyTasksTakeoverOwnerFallback;

  /// Snackbar shown when a non-adult tries to complete a task that's assigned to someone else.
  ///
  /// In es, this message translates to:
  /// **'Esta tarea le toca a {ownerName}.'**
  String familyTasksLockedMessage(String ownerName);

  /// No description provided for @familyTasksLockedOwnerFallback.
  ///
  /// In es, this message translates to:
  /// **'otra persona'**
  String get familyTasksLockedOwnerFallback;

  /// No description provided for @familyTasksSubmittedSnack.
  ///
  /// In es, this message translates to:
  /// **'Enviada para revisión de un adulto.'**
  String get familyTasksSubmittedSnack;

  /// No description provided for @familyTasksSubmitError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviar la tarea: {message}'**
  String familyTasksSubmitError(String message);

  /// No description provided for @familyTasksReviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisar tarea'**
  String get familyTasksReviewTitle;

  /// No description provided for @familyTasksReviewBody.
  ///
  /// In es, this message translates to:
  /// **'{performerName} marcó \"{taskTitle}\" como realizada.'**
  String familyTasksReviewBody(String performerName, String taskTitle);

  /// No description provided for @familyTasksReviewPerformerFallback.
  ///
  /// In es, this message translates to:
  /// **'este integrante'**
  String get familyTasksReviewPerformerFallback;

  /// No description provided for @familyTasksReviewApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar tarea'**
  String get familyTasksReviewApprove;

  /// No description provided for @familyTasksReviewReject.
  ///
  /// In es, this message translates to:
  /// **'Devolver para corregir'**
  String get familyTasksReviewReject;

  /// No description provided for @familyTasksApproveError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos aprobar la tarea.'**
  String get familyTasksApproveError;

  /// No description provided for @familyTasksApproveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Tarea aprobada.'**
  String get familyTasksApproveSuccess;

  /// No description provided for @familyTasksApproveErrorWithDetails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos aprobar la tarea: {message}'**
  String familyTasksApproveErrorWithDetails(String message);

  /// No description provided for @familyTasksRejectSuccess.
  ///
  /// In es, this message translates to:
  /// **'La tarea volvió a quedar pendiente.'**
  String get familyTasksRejectSuccess;

  /// No description provided for @familyTasksRejectError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos devolver la tarea: {message}'**
  String familyTasksRejectError(String message);

  /// No description provided for @familyWeeklyTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta semana en el hogar'**
  String get familyWeeklyTitle;

  /// No description provided for @familyWeeklyMetricPoints.
  ///
  /// In es, this message translates to:
  /// **'Puntos totales'**
  String get familyWeeklyMetricPoints;

  /// No description provided for @familyWeeklyMetricTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas cerradas'**
  String get familyWeeklyMetricTasks;

  /// No description provided for @familyWeeklyMetricStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get familyWeeklyMetricStatus;

  /// No description provided for @familyWeeklyStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get familyWeeklyStatusActive;

  /// Status pill when the household has < 5 closed tasks this week — a 'quiet' state.
  ///
  /// In es, this message translates to:
  /// **'Calma'**
  String get familyWeeklyStatusCalm;

  /// No description provided for @familyWeeklyRankingTitle.
  ///
  /// In es, this message translates to:
  /// **'Ranking Semanal'**
  String get familyWeeklyRankingTitle;

  /// No description provided for @familyWeeklyRankingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get familyWeeklyRankingSubtitle;

  /// No description provided for @familyWeeklyRankingTabAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get familyWeeklyRankingTabAll;

  /// No description provided for @familyWeeklyRankingTabAdults.
  ///
  /// In es, this message translates to:
  /// **'Adultos'**
  String get familyWeeklyRankingTabAdults;

  /// Filter tab for child members. 'Peques' = 'little ones / kids', warm/casual.
  ///
  /// In es, this message translates to:
  /// **'Peques'**
  String get familyWeeklyRankingTabKids;

  /// No description provided for @familyWeeklyRankingMemberFallback.
  ///
  /// In es, this message translates to:
  /// **'Integrante'**
  String get familyWeeklyRankingMemberFallback;

  /// No description provided for @familyWeeklyRankingEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Completen tareas para sumar puntos'**
  String get familyWeeklyRankingEmptyMessage;

  /// Empty-state when a category filter (Adultos/Peques) is selected and that category has no points yet. {tabLabel} is the localized tab label.
  ///
  /// In es, this message translates to:
  /// **'Nadie sumó puntos en {tabLabel} todavía'**
  String familyWeeklyRankingTabEmptyMessage(String tabLabel);

  /// Name of each household mode in the setup wizard mode picker.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{Pareja} family{Familia} friends{Convivencia} solo{Solo yo} other{Solo yo}}'**
  String setupModeName(String mode);

  /// One-line tagline under each mode card in the setup wizard.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{Gastos y tareas compartidas} family{Tareas, compras y seguimiento familiar} friends{Cuentas claras entre roommates} solo{Rutinas y pendientes personales} other{Rutinas y pendientes personales}}'**
  String setupModeDescription(String mode);

  /// No description provided for @setupProfileAvatarLabel.
  ///
  /// In es, this message translates to:
  /// **'Avatar'**
  String get setupProfileAvatarLabel;

  /// Tiny sign-out link below the mode picker in the setup wizard. Source uses lowercase 'sesión' (with accent) — distinct from the bigger Settings logout button.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get setupSignOutLink;

  /// Fallback name when creating a family-mode household without an explicit name.
  ///
  /// In es, this message translates to:
  /// **'Mi familia'**
  String get setupFamilyDefaultName;

  /// No description provided for @setupSnackJoinedHousehold.
  ///
  /// In es, this message translates to:
  /// **'¡Te uniste al hogar!'**
  String get setupSnackJoinedHousehold;

  /// No description provided for @setupSnackPickAtLeastOneTask.
  ///
  /// In es, this message translates to:
  /// **'Seleccioná al menos una tarea'**
  String get setupSnackPickAtLeastOneTask;

  /// No description provided for @setupSnackUnknownError.
  ///
  /// In es, this message translates to:
  /// **'Error desconocido'**
  String get setupSnackUnknownError;

  /// No description provided for @setupSnackOnboardingFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar el onboarding. Intentá de nuevo.'**
  String get setupSnackOnboardingFailed;

  /// Toast after copying the household invite code.
  ///
  /// In es, this message translates to:
  /// **'¡Código copiado al portapapeles! 📋'**
  String get setupSnackCodeCopied;

  /// No description provided for @setupFamilyRoleLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu rol visible'**
  String get setupFamilyRoleLabel;

  /// No description provided for @setupFamilyRoleFather.
  ///
  /// In es, this message translates to:
  /// **'Padre'**
  String get setupFamilyRoleFather;

  /// No description provided for @setupFamilyRoleMother.
  ///
  /// In es, this message translates to:
  /// **'Madre'**
  String get setupFamilyRoleMother;

  /// No description provided for @setupFamilyRoleGuardian.
  ///
  /// In es, this message translates to:
  /// **'Tutor/a'**
  String get setupFamilyRoleGuardian;

  /// Family role label. Note: backend stores the Spanish string as-is for back-compat; UI overrides only the displayed label.
  ///
  /// In es, this message translates to:
  /// **'Adolescente'**
  String get setupFamilyRoleTeen;

  /// No description provided for @setupFirstTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, family{Primeras tareas para la familia} solo{¿Qué querés tener en orden?} other{¿Qué tareas se reparten?}}'**
  String setupFirstTasksTitle(String mode);

  /// No description provided for @setupFirstTasksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, family{Elegí tareas iniciales para coordinar el hogar desde el primer día.} other{Elegí las primeras tareas. Ya dejamos algunas sugeridas para arrancar.}}'**
  String setupFirstTasksSubtitle(String mode);

  /// No description provided for @setupFinishButton.
  ///
  /// In es, this message translates to:
  /// **'Terminar configuración'**
  String get setupFinishButton;

  /// Title of the celebration dialog shown when the setup wizard finishes, per household mode.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{¡Su hogar está listo!} family{¡El hogar familiar está listo!} friends{¡La convivencia está lista!} solo{¡Tu espacio está listo!} other{¡Tu espacio está listo!}}'**
  String setupCompletionTitle(String mode);

  /// Supporting message of the setup completion celebration, per household mode.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{Ya pueden organizar tareas, gastos y metas juntos.} family{Ya pueden repartir tareas y coordinar la casa.} friends{Cuentas claras desde el día uno.} solo{Todo ordenado para arrancar tus rutinas.} other{Todo ordenado para arrancar tus rutinas.}}'**
  String setupCompletionMessage(String mode);

  /// No description provided for @settingsHouseholdEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Comienza tu equipo!'**
  String get settingsHouseholdEmptyTitle;

  /// No description provided for @settingsHouseholdEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Unite a un equipo existente con un código de invitación para empezar a compartir tareas y gastos.'**
  String get settingsHouseholdEmptyBody;

  /// No description provided for @settingsHouseholdJoinWithCodeButton.
  ///
  /// In es, this message translates to:
  /// **'Unirse con código'**
  String get settingsHouseholdJoinWithCodeButton;

  /// No description provided for @settingsHouseholdTasksToggleTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas del hogar'**
  String get settingsHouseholdTasksToggleTitle;

  /// No description provided for @settingsHouseholdTasksToggleOnSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mostrar tareas, progreso y accesos rápidos.'**
  String get settingsHouseholdTasksToggleOnSubtitle;

  /// No description provided for @settingsHouseholdTasksToggleOffSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ocultar tareas y dejar solo finanzas y compras.'**
  String get settingsHouseholdTasksToggleOffSubtitle;

  /// No description provided for @settingsHouseholdMembersEyebrow.
  ///
  /// In es, this message translates to:
  /// **'MIEMBROS'**
  String get settingsHouseholdMembersEyebrow;

  /// No description provided for @settingsHouseholdMembersCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 miembro} other{{count} miembros}}'**
  String settingsHouseholdMembersCount(int count);

  /// No description provided for @settingsHouseholdMemberFallbackName.
  ///
  /// In es, this message translates to:
  /// **'Miembro'**
  String get settingsHouseholdMemberFallbackName;

  /// Tiny chip next to the current user's name in the member list. Voseo 'Vos' = 'You'.
  ///
  /// In es, this message translates to:
  /// **'Vos'**
  String get settingsHouseholdMemberSelfChip;

  /// No description provided for @settingsHouseholdMemberAdminChip.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get settingsHouseholdMemberAdminChip;

  /// No description provided for @settingsHouseholdMemberMenuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Opciones del miembro'**
  String get settingsHouseholdMemberMenuTooltip;

  /// No description provided for @settingsHouseholdMemberMenuEditRole.
  ///
  /// In es, this message translates to:
  /// **'Editar rol'**
  String get settingsHouseholdMemberMenuEditRole;

  /// No description provided for @settingsHouseholdMemberMenuRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar del hogar'**
  String get settingsHouseholdMemberMenuRemove;

  /// No description provided for @settingsHouseholdMemberMenuDeleteDummyQa.
  ///
  /// In es, this message translates to:
  /// **'Eliminar dummy QA'**
  String get settingsHouseholdMemberMenuDeleteDummyQa;

  /// No description provided for @settingsHouseholdJoinDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Unirse a un hogar'**
  String get settingsHouseholdJoinDialogTitle;

  /// No description provided for @settingsHouseholdJoinDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Ingresá el código de invitación que te compartieron para unirte al hogar:'**
  String get settingsHouseholdJoinDialogBody;

  /// No description provided for @settingsHouseholdJoinDialogConfirm.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get settingsHouseholdJoinDialogConfirm;

  /// No description provided for @settingsHouseholdEditMenuRenameTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar nombre'**
  String get settingsHouseholdEditMenuRenameTitle;

  /// No description provided for @settingsHouseholdEditMenuRenameSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiá el nombre de tu hogar'**
  String get settingsHouseholdEditMenuRenameSubtitle;

  /// No description provided for @settingsHouseholdEditMenuInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación'**
  String get settingsHouseholdEditMenuInviteTitle;

  /// No description provided for @settingsHouseholdEditMenuInviteSubtitleExisting.
  ///
  /// In es, this message translates to:
  /// **'Compartir o generar nuevo código'**
  String get settingsHouseholdEditMenuInviteSubtitleExisting;

  /// No description provided for @settingsHouseholdEditMenuInviteSubtitleNone.
  ///
  /// In es, this message translates to:
  /// **'Generar código para invitar'**
  String get settingsHouseholdEditMenuInviteSubtitleNone;

  /// Menu item title in the household edit sheet for the split-strategy screen. Family mode reframes it as 'Family finances'; couple mode uses 'Splitting expenses'.
  ///
  /// In es, this message translates to:
  /// **'{type, select, family{Finanzas familiares} other{División de gastos}}'**
  String settingsHouseholdEditMenuSplitTitle(String type);

  /// No description provided for @settingsHouseholdEditMenuSplitSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{type, select, family{Elegir economía compartida o dividida} couple{Economía integrada o gastos divididos} other{Ajustar porcentaje}}'**
  String settingsHouseholdEditMenuSplitSubtitle(String type);

  /// No description provided for @settingsHouseholdInviteSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación'**
  String get settingsHouseholdInviteSheetTitle;

  /// No description provided for @settingsHouseholdInviteSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Compartí este código para que otros se unan a tu hogar'**
  String get settingsHouseholdInviteSheetSubtitle;

  /// No description provided for @settingsHouseholdInviteSheetCopyTooltip.
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get settingsHouseholdInviteSheetCopyTooltip;

  /// No description provided for @settingsHouseholdInviteSheetEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin código activo'**
  String get settingsHouseholdInviteSheetEmpty;

  /// No description provided for @settingsHouseholdInviteSheetGenerate.
  ///
  /// In es, this message translates to:
  /// **'Generar código'**
  String get settingsHouseholdInviteSheetGenerate;

  /// No description provided for @settingsHouseholdInviteSheetRegenerate.
  ///
  /// In es, this message translates to:
  /// **'Generar nuevo código'**
  String get settingsHouseholdInviteSheetRegenerate;

  /// No description provided for @settingsHouseholdRemoveMemberTitle.
  ///
  /// In es, this message translates to:
  /// **'Quitar miembro'**
  String get settingsHouseholdRemoveMemberTitle;

  /// No description provided for @settingsHouseholdRemoveMemberBody.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que querés quitar a {memberName} de este hogar?'**
  String settingsHouseholdRemoveMemberBody(String memberName);

  /// No description provided for @settingsHouseholdRemoveMemberConfirm.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get settingsHouseholdRemoveMemberConfirm;

  /// No description provided for @settingsHouseholdDeleteDummyTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar dummy QA'**
  String get settingsHouseholdDeleteDummyTitle;

  /// No description provided for @settingsHouseholdDeleteDummyBody.
  ///
  /// In es, this message translates to:
  /// **'Esto eliminará a {memberName} como usuario dummy QA. Si no pertenece a otro hogar QA, también se borrará su identidad técnica.'**
  String settingsHouseholdDeleteDummyBody(String memberName);

  /// No description provided for @settingsHouseholdDeleteDummyConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar dummy'**
  String get settingsHouseholdDeleteDummyConfirm;

  /// No description provided for @settingsHouseholdRenameDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Nombre del hogar'**
  String get settingsHouseholdRenameDialogTitle;

  /// Input label inside the rename-household dialog. It renames the HOUSEHOLD, not the user (the old 'Tu nombre' copy was a bug).
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get settingsHouseholdRenameDialogLabel;

  /// No description provided for @settingsHouseholdFallbackName.
  ///
  /// In es, this message translates to:
  /// **'Mi hogar'**
  String get settingsHouseholdFallbackName;

  /// No description provided for @settingsHouseholdCodeGenerated.
  ///
  /// In es, this message translates to:
  /// **'Código generado'**
  String get settingsHouseholdCodeGenerated;

  /// No description provided for @settingsHouseholdCodeCopied.
  ///
  /// In es, this message translates to:
  /// **'Código copiado al portapapeles'**
  String get settingsHouseholdCodeCopied;

  /// No description provided for @settingsHouseholdCodeGenerateFirst.
  ///
  /// In es, this message translates to:
  /// **'Generá un código primero'**
  String get settingsHouseholdCodeGenerateFirst;

  /// No description provided for @settingsHouseholdWhatsAppFallback.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir WhatsApp. Código copiado.'**
  String get settingsHouseholdWhatsAppFallback;

  /// No description provided for @settingsHouseholdJoinSuccess.
  ///
  /// In es, this message translates to:
  /// **'Te uniste al hogar exitosamente'**
  String get settingsHouseholdJoinSuccess;

  /// No description provided for @settingsHouseholdJoinCodeLength.
  ///
  /// In es, this message translates to:
  /// **'El código debe tener 6 caracteres'**
  String get settingsHouseholdJoinCodeLength;

  /// No description provided for @settingsHouseholdRoleUpdated.
  ///
  /// In es, this message translates to:
  /// **'✅ Rol actualizado'**
  String get settingsHouseholdRoleUpdated;

  /// No description provided for @settingsHouseholdRenamed.
  ///
  /// In es, this message translates to:
  /// **'✅ Hogar renombrado'**
  String get settingsHouseholdRenamed;

  /// No description provided for @settingsHouseholdTasksEnabledSnack.
  ///
  /// In es, this message translates to:
  /// **'✅ Tareas del hogar activadas'**
  String get settingsHouseholdTasksEnabledSnack;

  /// No description provided for @settingsHouseholdFinanceModeSnack.
  ///
  /// In es, this message translates to:
  /// **'✅ Modo finanzas y compras activado'**
  String get settingsHouseholdFinanceModeSnack;

  /// No description provided for @settingsHouseholdUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la configuración: {error}'**
  String settingsHouseholdUpdateError(String error);

  /// No description provided for @settingsAssignRoleTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar rol o apodo'**
  String get settingsAssignRoleTitle;

  /// Input label of the assign-role dialog, with a mode-aware example.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{Nombre del rol (ej: Pareja)} friends{Nombre del rol (ej: Compañero)} other{Nombre del rol (ej: Madre)}}'**
  String settingsAssignRoleFieldLabel(String mode);

  /// No description provided for @settingsAssignRoleSuggestionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias:'**
  String get settingsAssignRoleSuggestionsLabel;

  /// Comma-separated suggestion chips for the couple role dialog. No spaces after commas — the code splits on ','.
  ///
  /// In es, this message translates to:
  /// **'Pareja,Novio,Novia,Esposo,Esposa'**
  String get settingsRoleSuggestionsCouple;

  /// Comma-separated suggestion chips for the friends role dialog. No spaces after commas — the code splits on ','.
  ///
  /// In es, this message translates to:
  /// **'Compañero,Roommate,Invitado,Responsable'**
  String get settingsRoleSuggestionsFriends;

  /// No description provided for @settingsMemberRoleOwner.
  ///
  /// In es, this message translates to:
  /// **'Propietario'**
  String get settingsMemberRoleOwner;

  /// No description provided for @settingsMemberRoleCouple.
  ///
  /// In es, this message translates to:
  /// **'Pareja'**
  String get settingsMemberRoleCouple;

  /// No description provided for @settingsMemberRoleFriends.
  ///
  /// In es, this message translates to:
  /// **'Compañero'**
  String get settingsMemberRoleFriends;

  /// No description provided for @settingsMemberRoleDefault.
  ///
  /// In es, this message translates to:
  /// **'Miembro'**
  String get settingsMemberRoleDefault;

  /// No description provided for @settingsHouseholdLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu hogar. Revisá tu conexión e intentá de nuevo.'**
  String get settingsHouseholdLoadError;

  /// Card title for the Parent Mode premium feature. Family-only.
  ///
  /// In es, this message translates to:
  /// **'Modo Padres'**
  String get settingsParentModeTitle;

  /// Card subtitle. Voseo 'Vos coordinás'. Tone: parental authority, friendly.
  ///
  /// In es, this message translates to:
  /// **'Vos coordinas, ellos cumplen.'**
  String get settingsParentModeSubtitle;

  /// No description provided for @settingsParentModeBulletApproval.
  ///
  /// In es, this message translates to:
  /// **'Aprobación de tareas antes de dar coins.'**
  String get settingsParentModeBulletApproval;

  /// No description provided for @settingsParentModeBulletPerMember.
  ///
  /// In es, this message translates to:
  /// **'Vista por miembro y resumen familiar semanal.'**
  String get settingsParentModeBulletPerMember;

  /// No description provided for @settingsParentModeBulletRotation.
  ///
  /// In es, this message translates to:
  /// **'Rotación automática de tareas entre integrantes.'**
  String get settingsParentModeBulletRotation;

  /// No description provided for @settingsParentModeUnlockButton.
  ///
  /// In es, this message translates to:
  /// **'Activar Modo Padres'**
  String get settingsParentModeUnlockButton;

  /// No description provided for @settingsParentModeApprovalSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprobación de tareas'**
  String get settingsParentModeApprovalSectionTitle;

  /// No description provided for @settingsParentModeApprovalSectionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuando un miembro completa una tarea, queda pendiente hasta que vos la apruebes.'**
  String get settingsParentModeApprovalSectionSubtitle;

  /// No description provided for @settingsParentModeApprovalOffTitle.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get settingsParentModeApprovalOffTitle;

  /// No description provided for @settingsParentModeApprovalOffSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las tareas se acreditan apenas se completan.'**
  String get settingsParentModeApprovalOffSubtitle;

  /// No description provided for @settingsParentModeApprovalChildrenOnlyTitle.
  ///
  /// In es, this message translates to:
  /// **'Solo niños y adolescentes'**
  String get settingsParentModeApprovalChildrenOnlyTitle;

  /// No description provided for @settingsParentModeApprovalChildrenOnlySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los adultos completan directo; los demás requieren aprobación.'**
  String get settingsParentModeApprovalChildrenOnlySubtitle;

  /// No description provided for @settingsParentModeApprovalPerMemberTitle.
  ///
  /// In es, this message translates to:
  /// **'Por miembro'**
  String get settingsParentModeApprovalPerMemberTitle;

  /// No description provided for @settingsParentModeApprovalPerMemberSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vos elegís exactamente quién necesita aprobación en la lista de abajo.'**
  String get settingsParentModeApprovalPerMemberSubtitle;

  /// No description provided for @settingsParentModeInboxIdle.
  ///
  /// In es, this message translates to:
  /// **'Bandeja de aprobaciones'**
  String get settingsParentModeInboxIdle;

  /// Inbox button label including pending count. ICU plural.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Bandeja de aprobaciones — 1 pendiente} other{Bandeja de aprobaciones — {count} pendientes}}'**
  String settingsParentModeInboxWithCount(int count);

  /// No description provided for @settingsParentModeMemberView.
  ///
  /// In es, this message translates to:
  /// **'Vista por miembro'**
  String get settingsParentModeMemberView;

  /// No description provided for @settingsParentModeWeeklySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de la semana'**
  String get settingsParentModeWeeklySummary;

  /// No description provided for @settingsParentModeAllowanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Mesadas'**
  String get settingsParentModeAllowanceTitle;

  /// No description provided for @settingsParentModeAllowanceSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Enviá mesadas a adolescentes con finanzas personales.'**
  String get settingsParentModeAllowanceSubtitle;

  /// No description provided for @settingsParentModeAllowanceCta.
  ///
  /// In es, this message translates to:
  /// **'Dar mesada'**
  String get settingsParentModeAllowanceCta;

  /// No description provided for @settingsParentModePerMemberEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay otros miembros en el hogar todavía.'**
  String get settingsParentModePerMemberEmpty;

  /// Mensaje seguro cuando falla un cambio de configuración en Modo Padres.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el cambio. Intentá de nuevo.'**
  String get settingsParentModeSaveError;

  /// Estado recuperable cuando falla la carga de aprobaciones por integrante.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la configuración por integrante.'**
  String get settingsParentModeLoadError;

  /// Mensaje seguro cuando falla la actualización de una notificación.
  ///
  /// In es, this message translates to:
  /// **'No pudimos marcar la notificación como leída.'**
  String get notificationsMarkReadError;

  /// Mensaje seguro cuando falla la actualización masiva de notificaciones.
  ///
  /// In es, this message translates to:
  /// **'No pudimos marcar todas las notificaciones como leídas.'**
  String get notificationsMarkAllReadError;

  /// Mensaje recuperable cuando falla la siguiente página de notificaciones.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más notificaciones. Intentá de nuevo.'**
  String get notificationsLoadMoreError;

  /// Member type label in the per-member approval list. 'Hijo/a' = son/daughter (gender-inclusive).
  ///
  /// In es, this message translates to:
  /// **'Hijo/a'**
  String get settingsParentModeMemberTypeChild;

  /// No description provided for @settingsParentModeMemberTypeTeen.
  ///
  /// In es, this message translates to:
  /// **'Adolescente'**
  String get settingsParentModeMemberTypeTeen;

  /// No description provided for @settingsParentModeMemberTypeAdult.
  ///
  /// In es, this message translates to:
  /// **'Adulto'**
  String get settingsParentModeMemberTypeAdult;

  /// No description provided for @settingsParentModeMemberTypeGuardian.
  ///
  /// In es, this message translates to:
  /// **'Tutor/a'**
  String get settingsParentModeMemberTypeGuardian;

  /// Suffix shown after member type for the household owner. 'Owner' is brand convention; kept in English in source.
  ///
  /// In es, this message translates to:
  /// **'Owner'**
  String get settingsParentModeRoleOwnerSuffix;

  /// No description provided for @settingsParentModeRoleAdminSuffix.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get settingsParentModeRoleAdminSuffix;

  /// No description provided for @memberOnboardingWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido al hogar!'**
  String get memberOnboardingWelcomeTitle;

  /// No description provided for @memberOnboardingWelcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí tu rol para empezar.'**
  String get memberOnboardingWelcomeSubtitle;

  /// No description provided for @memberOnboardingEyebrow.
  ///
  /// In es, this message translates to:
  /// **'Rol en el hogar'**
  String get memberOnboardingEyebrow;

  /// No description provided for @memberOnboardingTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quién sos?'**
  String get memberOnboardingTitle;

  /// No description provided for @memberOnboardingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí tu rol en el hogar.'**
  String get memberOnboardingSubtitle;

  /// No description provided for @memberOnboardingFinishButton.
  ///
  /// In es, this message translates to:
  /// **'¡Listo!'**
  String get memberOnboardingFinishButton;

  /// No description provided for @memberOnboardingSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Intentá de nuevo.'**
  String get memberOnboardingSaveError;

  /// Description card for adult/parent/guardian roles. Same copy is shown for Padre/Madre/Tutor/a/Adulto.
  ///
  /// In es, this message translates to:
  /// **'Responsable del hogar. Administra gastos y tareas.'**
  String get memberOnboardingRoleDescAdult;

  /// No description provided for @memberOnboardingRoleDescTeen.
  ///
  /// In es, this message translates to:
  /// **'Gestión personal de gastos y tareas.'**
  String get memberOnboardingRoleDescTeen;

  /// No description provided for @memberOnboardingRoleDescChild.
  ///
  /// In es, this message translates to:
  /// **'Participa con tareas y puede ganar recompensas.'**
  String get memberOnboardingRoleDescChild;

  /// No description provided for @memberOnboardingRoleDescDefault.
  ///
  /// In es, this message translates to:
  /// **'Miembro del hogar.'**
  String get memberOnboardingRoleDescDefault;

  /// AppBar title of the couple/family split strategy screen. Family mode reframes as 'Finanzas familiares'; couple mode as 'Finanzas en pareja' since couples can now also pick an integrated economy.
  ///
  /// In es, this message translates to:
  /// **'{type, select, family{Finanzas familiares} couple{Finanzas en pareja} other{División de gastos}}'**
  String coupleSplitTitle(String type);

  /// No description provided for @coupleSplitSavedSnack.
  ///
  /// In es, this message translates to:
  /// **'Configuración guardada correctamente'**
  String get coupleSplitSavedSnack;

  /// Mensaje seguro cuando falla el guardado de la configuración financiera del hogar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar la configuración. Intentá de nuevo.'**
  String get coupleSplitSaveError;

  /// Estado recuperable cuando falla la carga de plantillas de tareas durante el setup.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las tareas sugeridas.'**
  String get setupTemplatesLoadError;

  /// No description provided for @coupleSplitFamilyHowTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo se registran los gastos'**
  String get coupleSplitFamilyHowTitle;

  /// No description provided for @coupleSplitFamilyHowBody.
  ///
  /// In es, this message translates to:
  /// **'En familia, lo normal es una economía compartida: el gasto queda visible para el hogar, pero no genera deuda entre adultos. Si lo necesitás, podés activar división como en pareja.'**
  String get coupleSplitFamilyHowBody;

  /// No description provided for @coupleSplitFamilySharedTitle.
  ///
  /// In es, this message translates to:
  /// **'Economía compartida'**
  String get coupleSplitFamilySharedTitle;

  /// No description provided for @coupleSplitFamilySharedBody.
  ///
  /// In es, this message translates to:
  /// **'Los gastos no se reparten por porcentaje ni generan balances entre adultos.'**
  String get coupleSplitFamilySharedBody;

  /// No description provided for @coupleSplitFamilyDividedTitle.
  ///
  /// In es, this message translates to:
  /// **'Gastos divididos'**
  String get coupleSplitFamilyDividedTitle;

  /// No description provided for @coupleSplitFamilyDividedBody.
  ///
  /// In es, this message translates to:
  /// **'Usa porcentajes y balances como en pareja.'**
  String get coupleSplitFamilyDividedBody;

  /// Title of the info card that introduces the finance-mode choice (shared vs divided). Reframed per household type.
  ///
  /// In es, this message translates to:
  /// **'{type, select, family{Cómo se registran los gastos} other{Cómo manejan la plata}}'**
  String coupleSplitModeHowTitle(String type);

  /// Body of the info card explaining shared vs divided economy. Reframed per household type.
  ///
  /// In es, this message translates to:
  /// **'{type, select, family{En familia, lo normal es una economía compartida: el gasto queda visible para el hogar, pero no genera deuda entre adultos. Si lo necesitás, podés activar división como en pareja.} other{Hay dos formas de manejar la plata en pareja. En la economía integrada todo es del hogar: los gastos quedan visibles pero no generan deuda entre ustedes. En la dividida cada gasto se reparte y se lleva el balance.}}'**
  String coupleSplitModeHowBody(String type);

  /// Title of the shared/integrated economy option in the finance-mode selector.
  ///
  /// In es, this message translates to:
  /// **'Economía integrada'**
  String get coupleSplitModeSharedTitle;

  /// Body describing the shared/integrated economy option. Reframed per household type.
  ///
  /// In es, this message translates to:
  /// **'{type, select, family{Los gastos no se reparten por porcentaje ni generan balances entre adultos.} other{Todo es plata del hogar: los gastos quedan registrados pero no generan deuda ni balances entre ustedes. Ideal para parejas con economía unificada.}}'**
  String coupleSplitModeSharedBody(String type);

  /// Title of the divided economy option in the finance-mode selector.
  ///
  /// In es, this message translates to:
  /// **'Gastos divididos'**
  String get coupleSplitModeDividedTitle;

  /// Body describing the divided economy option. Reframed per household type.
  ///
  /// In es, this message translates to:
  /// **'{type, select, family{Usa porcentajes y balances como en pareja.} other{Cada gasto compartido se reparte según el porcentaje que elijan y se lleva el balance entre ustedes.}}'**
  String coupleSplitModeDividedBody(String type);

  /// No description provided for @coupleSplitInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo dividir gastos?'**
  String get coupleSplitInfoTitle;

  /// No description provided for @coupleSplitInfoBody.
  ///
  /// In es, this message translates to:
  /// **'No hay una única forma correcta. Cada pareja es un mundo y la mejor estrategia es la que les dé paz mental a ambos.'**
  String get coupleSplitInfoBody;

  /// No description provided for @coupleSplitStrategiesTitle.
  ///
  /// In es, this message translates to:
  /// **'Estrategias comunes'**
  String get coupleSplitStrategiesTitle;

  /// No description provided for @coupleSplitStrategy5050Title.
  ///
  /// In es, this message translates to:
  /// **'50% / 50% (Igualitario)'**
  String get coupleSplitStrategy5050Title;

  /// No description provided for @coupleSplitStrategy5050Body.
  ///
  /// In es, this message translates to:
  /// **'Ideal cuando ambos tienen ingresos similares. Cada uno aporta la mitad de los gastos compartidos.'**
  String get coupleSplitStrategy5050Body;

  /// No description provided for @coupleSplitStrategy6040Title.
  ///
  /// In es, this message translates to:
  /// **'60% / 40% (Equitativo)'**
  String get coupleSplitStrategy6040Title;

  /// No description provided for @coupleSplitStrategy6040Body.
  ///
  /// In es, this message translates to:
  /// **'Si hay una diferencia de ingresos, el que gana más aporta una parte mayor proporcionalmente.'**
  String get coupleSplitStrategy6040Body;

  /// No description provided for @coupleSplitCustomTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración personalizada'**
  String get coupleSplitCustomTitle;

  /// No description provided for @coupleSplitCustomBody.
  ///
  /// In es, this message translates to:
  /// **'Ajustá el porcentaje que vos vas a aportar de forma predeterminada.'**
  String get coupleSplitCustomBody;

  /// No description provided for @coupleSplitVisualizerYou.
  ///
  /// In es, this message translates to:
  /// **'VOS'**
  String get coupleSplitVisualizerYou;

  /// No description provided for @coupleSplitVisualizerPartner.
  ///
  /// In es, this message translates to:
  /// **'TU PAREJA'**
  String get coupleSplitVisualizerPartner;

  /// No description provided for @coupleSplitSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar Configuración'**
  String get coupleSplitSaveButton;

  /// No description provided for @tasksTabList.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get tasksTabList;

  /// No description provided for @tasksTabCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get tasksTabCalendar;

  /// No description provided for @tasksFabNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get tasksFabNew;

  /// No description provided for @tasksLoadingMessage.
  ///
  /// In es, this message translates to:
  /// **'Cargando tareas...'**
  String get tasksLoadingMessage;

  /// No description provided for @tasksLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las tareas.'**
  String get tasksLoadError;

  /// No description provided for @tasksLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más tareas'**
  String get tasksLoadMore;

  /// Default 'all categories' filter chip in the tasks screen. Feminine plural ('todas') matching 'tareas'.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get tasksFilterAll;

  /// No description provided for @tasksSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar tarea o rutina'**
  String get tasksSearchHint;

  /// No description provided for @tasksSearchClearTooltip.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get tasksSearchClearTooltip;

  /// No description provided for @tasksSearchActiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscando'**
  String get tasksSearchActiveLabel;

  /// No description provided for @tasksSearchIdleLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get tasksSearchIdleLabel;

  /// No description provided for @tasksEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay tareas configuradas'**
  String get tasksEmptyTitle;

  /// No description provided for @tasksEmptyFilteredTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay tareas con esos filtros'**
  String get tasksEmptyFilteredTitle;

  /// No description provided for @tasksEmptySoloSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agregá tu primera tarea para empezar a organizar tu hogar.'**
  String get tasksEmptySoloSubtitle;

  /// No description provided for @tasksEmptySharedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agregá tu primera tarea o activá una categoría para empezar a organizar la casa.'**
  String get tasksEmptySharedSubtitle;

  /// No description provided for @tasksEmptyFilteredSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Probá cambiar la categoría o crear una nueva tarea.'**
  String get tasksEmptyFilteredSubtitle;

  /// No description provided for @tasksPillNoDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get tasksPillNoDate;

  /// Tasks list section header: overdue tasks.
  ///
  /// In es, this message translates to:
  /// **'Vencidas'**
  String get tasksSectionOverdue;

  /// Tasks list section header: tasks due today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get tasksSectionToday;

  /// Tasks list section header: tasks due tomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get tasksSectionTomorrow;

  /// Tasks list section header: tasks due within the next 7 days.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get tasksSectionThisWeek;

  /// Tasks list section header: tasks due beyond this week.
  ///
  /// In es, this message translates to:
  /// **'Más adelante'**
  String get tasksSectionUpcoming;

  /// Tasks list section header: unscheduled tasks.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get tasksSectionNoDate;

  /// No description provided for @tasksPillOverdue.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get tasksPillOverdue;

  /// No description provided for @tasksPillInReview.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get tasksPillInReview;

  /// No description provided for @tasksActionSchedule.
  ///
  /// In es, this message translates to:
  /// **'Programar'**
  String get tasksActionSchedule;

  /// No description provided for @tasksActionComplete.
  ///
  /// In es, this message translates to:
  /// **'Completar'**
  String get tasksActionComplete;

  /// No description provided for @tasksActionCompleting.
  ///
  /// In es, this message translates to:
  /// **'Completando...'**
  String get tasksActionCompleting;

  /// No description provided for @tasksActionSendForReview.
  ///
  /// In es, this message translates to:
  /// **'Enviar a revisión'**
  String get tasksActionSendForReview;

  /// No description provided for @tasksActionSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get tasksActionSending;

  /// No description provided for @tasksStatusWaitingForAdult.
  ///
  /// In es, this message translates to:
  /// **'Esperando revisión de un adulto.'**
  String get tasksStatusWaitingForAdult;

  /// No description provided for @tasksStatusWaitingReview.
  ///
  /// In es, this message translates to:
  /// **'Esperando revisión.'**
  String get tasksStatusWaitingReview;

  /// No description provided for @tasksStatusBelongsTo.
  ///
  /// In es, this message translates to:
  /// **'Le toca a {ownerName}.'**
  String tasksStatusBelongsTo(String ownerName);

  /// Title of the adult-takeover bottom sheet. No period at the end (acts as a heading).
  ///
  /// In es, this message translates to:
  /// **'Esta tarea le toca a {ownerName}'**
  String tasksTakeoverHeading(String ownerName);

  /// No description provided for @tasksTakeoverPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Querés darle una mano y completarla de todas formas?'**
  String get tasksTakeoverPrompt;

  /// No description provided for @tasksTakeoverConfirm.
  ///
  /// In es, this message translates to:
  /// **'Completar igual'**
  String get tasksTakeoverConfirm;

  /// No description provided for @tasksSnackFrequencyUpdated.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia actualizada'**
  String get tasksSnackFrequencyUpdated;

  /// No description provided for @tasksSnackCompleted.
  ///
  /// In es, this message translates to:
  /// **'Tarea completada.'**
  String get tasksSnackCompleted;

  /// No description provided for @tasksSnackCompleteError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la tarea.'**
  String get tasksSnackCompleteError;

  /// No description provided for @createTaskDifficultyEasy.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get createTaskDifficultyEasy;

  /// No description provided for @createTaskDifficultyMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get createTaskDifficultyMedium;

  /// No description provided for @createTaskDifficultyHard.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get createTaskDifficultyHard;

  /// No description provided for @createTaskRecurrenceDaily.
  ///
  /// In es, this message translates to:
  /// **'Diaria'**
  String get createTaskRecurrenceDaily;

  /// No description provided for @createTaskRecurrenceWeekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get createTaskRecurrenceWeekly;

  /// No description provided for @createTaskRecurrenceMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get createTaskRecurrenceMonthly;

  /// No description provided for @createTaskRecurrenceNone.
  ///
  /// In es, this message translates to:
  /// **'Sin repetir'**
  String get createTaskRecurrenceNone;

  /// No description provided for @createTaskRecurrenceCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizada'**
  String get createTaskRecurrenceCustom;

  /// No description provided for @createTaskValidationCustomDays.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos un día para la repetición personalizada.'**
  String get createTaskValidationCustomDays;

  /// No description provided for @createTaskValidationCustomMonthDates.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos una fecha del mes.'**
  String get createTaskValidationCustomMonthDates;

  /// Error mostrado cuando el intervalo de repetición personalizado es menor que un día.
  ///
  /// In es, this message translates to:
  /// **'El intervalo debe ser de al menos 1 día.'**
  String get createTaskValidationInterval;

  /// No description provided for @createTaskValidationTitleRequired.
  ///
  /// In es, this message translates to:
  /// **'Título requerido'**
  String get createTaskValidationTitleRequired;

  /// No description provided for @createTaskValidationNumberRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un número'**
  String get createTaskValidationNumberRequired;

  /// No description provided for @createTaskValidationNotNegative.
  ///
  /// In es, this message translates to:
  /// **'No puede ser negativo'**
  String get createTaskValidationNotNegative;

  /// Límite de seguridad para recompensas personalizadas de tareas.
  ///
  /// In es, this message translates to:
  /// **'Usá entre 0 y 50 XP y entre 0 y 5 coins.'**
  String get createTaskValidationRewardRange;

  /// No description provided for @createTaskSnackCategoryNotReady.
  ///
  /// In es, this message translates to:
  /// **'Esperá un momento y elegí una categoría.'**
  String get createTaskSnackCategoryNotReady;

  /// No description provided for @createTaskSnackDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una tarea idéntica activa'**
  String get createTaskSnackDuplicate;

  /// No description provided for @createTaskSnackCreated.
  ///
  /// In es, this message translates to:
  /// **'Tarea creada'**
  String get createTaskSnackCreated;

  /// No description provided for @createTaskHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get createTaskHeaderTitle;

  /// No description provided for @createTaskSectionDetailEyebrow.
  ///
  /// In es, this message translates to:
  /// **'DETALLE'**
  String get createTaskSectionDetailEyebrow;

  /// No description provided for @createTaskSectionDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Qué hay que hacer'**
  String get createTaskSectionDetailTitle;

  /// No description provided for @createTaskSectionDetailSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ponele un nombre claro para que se entienda de un vistazo.'**
  String get createTaskSectionDetailSubtitle;

  /// No description provided for @createTaskFieldTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Qué hay que hacer'**
  String get createTaskFieldTitleLabel;

  /// No description provided for @createTaskFieldNotesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get createTaskFieldNotesLabel;

  /// No description provided for @createTaskSectionCategoryEyebrow.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get createTaskSectionCategoryEyebrow;

  /// No description provided for @createTaskSectionCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Dónde vive mejor'**
  String get createTaskSectionCategoryTitle;

  /// No description provided for @createTaskSectionCategorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí la zona del hogar para que aparezca ordenada.'**
  String get createTaskSectionCategorySubtitle;

  /// No description provided for @createTaskSectionFrequencyEyebrow.
  ///
  /// In es, this message translates to:
  /// **'FRECUENCIA'**
  String get createTaskSectionFrequencyEyebrow;

  /// No description provided for @createTaskSectionFrequencyTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuándo se repite'**
  String get createTaskSectionFrequencyTitle;

  /// No description provided for @createTaskSectionFrequencySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Puede quedar única, repetirse o seguir un patrón propio.'**
  String get createTaskSectionFrequencySubtitle;

  /// No description provided for @createTaskSectionAssigneeEyebrow.
  ///
  /// In es, this message translates to:
  /// **'RESPONSABLE'**
  String get createTaskSectionAssigneeEyebrow;

  /// No description provided for @createTaskSectionAssigneeTitle.
  ///
  /// In es, this message translates to:
  /// **'Quién puede hacerla'**
  String get createTaskSectionAssigneeTitle;

  /// No description provided for @createTaskSectionAssigneeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Podés dejarla abierta o asignarla a alguien en particular.'**
  String get createTaskSectionAssigneeSubtitle;

  /// No description provided for @createTaskAssigneeAnyone.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera'**
  String get createTaskAssigneeAnyone;

  /// No description provided for @createTaskSectionValueEyebrow.
  ///
  /// In es, this message translates to:
  /// **'VALOR'**
  String get createTaskSectionValueEyebrow;

  /// No description provided for @createTaskSectionValueTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuánto vale completarla'**
  String get createTaskSectionValueTitle;

  /// No description provided for @createTaskSectionValueSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La dificultad define puntos y coins de forma rápida.'**
  String get createTaskSectionValueSubtitle;

  /// No description provided for @createTaskRewardsTitle.
  ///
  /// In es, this message translates to:
  /// **'Recompensas'**
  String get createTaskRewardsTitle;

  /// No description provided for @createTaskCustomizeRewards.
  ///
  /// In es, this message translates to:
  /// **'Personalizar'**
  String get createTaskCustomizeRewards;

  /// No description provided for @createTaskFieldCoinsLabel.
  ///
  /// In es, this message translates to:
  /// **'Coins'**
  String get createTaskFieldCoinsLabel;

  /// No description provided for @createTaskSectionRotationEyebrow.
  ///
  /// In es, this message translates to:
  /// **'ROTACIÓN'**
  String get createTaskSectionRotationEyebrow;

  /// No description provided for @createTaskSectionRotationTitle.
  ///
  /// In es, this message translates to:
  /// **'Que se turnen los miembros'**
  String get createTaskSectionRotationTitle;

  /// No description provided for @createTaskSectionRotationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos dos. Cada vez que se complete, le toca al siguiente.'**
  String get createTaskSectionRotationSubtitle;

  /// Ayuda mostrada cuando el usuario seleccionó una sola persona para la rotación de una tarea.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos 2 personas para armar el turno.'**
  String get createTaskRotationMinimumPeople;

  /// No description provided for @createTaskCustomTabWeekdays.
  ///
  /// In es, this message translates to:
  /// **'Por día'**
  String get createTaskCustomTabWeekdays;

  /// No description provided for @createTaskCustomTabInterval.
  ///
  /// In es, this message translates to:
  /// **'Intervalo'**
  String get createTaskCustomTabInterval;

  /// No description provided for @createTaskCustomTabMonthDays.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get createTaskCustomTabMonthDays;

  /// No description provided for @createTaskCustomRepeatEvery.
  ///
  /// In es, this message translates to:
  /// **'Repetir cada'**
  String get createTaskCustomRepeatEvery;

  /// No description provided for @createTaskCustomDecreaseTooltip.
  ///
  /// In es, this message translates to:
  /// **'Disminuir'**
  String get createTaskCustomDecreaseTooltip;

  /// No description provided for @createTaskCustomIncreaseTooltip.
  ///
  /// In es, this message translates to:
  /// **'Aumentar'**
  String get createTaskCustomIncreaseTooltip;

  /// No description provided for @createTaskCustomMonthDaysHelp.
  ///
  /// In es, this message translates to:
  /// **'Elegí los días del mes'**
  String get createTaskCustomMonthDaysHelp;

  /// No description provided for @createTaskWeekdayMonday.
  ///
  /// In es, this message translates to:
  /// **'L'**
  String get createTaskWeekdayMonday;

  /// No description provided for @createTaskWeekdayTuesday.
  ///
  /// In es, this message translates to:
  /// **'M'**
  String get createTaskWeekdayTuesday;

  /// No description provided for @createTaskWeekdayWednesday.
  ///
  /// In es, this message translates to:
  /// **'X'**
  String get createTaskWeekdayWednesday;

  /// No description provided for @createTaskWeekdayThursday.
  ///
  /// In es, this message translates to:
  /// **'J'**
  String get createTaskWeekdayThursday;

  /// No description provided for @createTaskWeekdayFriday.
  ///
  /// In es, this message translates to:
  /// **'V'**
  String get createTaskWeekdayFriday;

  /// No description provided for @createTaskWeekdaySaturday.
  ///
  /// In es, this message translates to:
  /// **'S'**
  String get createTaskWeekdaySaturday;

  /// No description provided for @createTaskWeekdaySunday.
  ///
  /// In es, this message translates to:
  /// **'D'**
  String get createTaskWeekdaySunday;

  /// No description provided for @createTaskCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear tarea'**
  String get createTaskCreateButton;

  /// No description provided for @addTaskOptionsHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get addTaskOptionsHeaderTitle;

  /// No description provided for @addTaskOptionsCustomChip.
  ///
  /// In es, this message translates to:
  /// **'Personalizada'**
  String get addTaskOptionsCustomChip;

  /// No description provided for @addTaskOptionsAddTooltip.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarea'**
  String get addTaskOptionsAddTooltip;

  /// No description provided for @addTaskOptionsAllSuggestedDone.
  ///
  /// In es, this message translates to:
  /// **'Ya tenés todas las sugeridas'**
  String get addTaskOptionsAllSuggestedDone;

  /// No description provided for @addTaskOptionsCreateCustomBelow.
  ///
  /// In es, this message translates to:
  /// **'Creá una tarea personalizada abajo.'**
  String get addTaskOptionsCreateCustomBelow;

  /// No description provided for @addTaskOptionsLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get addTaskOptionsLoadMore;

  /// Button label for closing the suggested task picker after adding one or more tasks.
  ///
  /// In es, this message translates to:
  /// **'Listo ({count})'**
  String addTaskOptionsDone(int count);

  /// No description provided for @completeTaskSnackPickAtLeastOne.
  ///
  /// In es, this message translates to:
  /// **'Seleccioná al menos una tarea para completar.'**
  String get completeTaskSnackPickAtLeastOne;

  /// No description provided for @completeTaskSnackPickWho.
  ///
  /// In es, this message translates to:
  /// **'Seleccioná quién la hizo antes de continuar.'**
  String get completeTaskSnackPickWho;

  /// No description provided for @completeTaskSnackFutureDate.
  ///
  /// In es, this message translates to:
  /// **'La fecha de finalización no puede ser futura.'**
  String get completeTaskSnackFutureDate;

  /// No description provided for @completeTaskSnackTasksMissing.
  ///
  /// In es, this message translates to:
  /// **'No pudimos encontrar todas las tareas elegidas. Refrescá e intentá de nuevo.'**
  String get completeTaskSnackTasksMissing;

  /// No description provided for @completeTaskHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Completar tareas'**
  String get completeTaskHeaderTitle;

  /// No description provided for @completeTaskHeaderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Marcá lo que ya hicieron y asigná el mérito en un solo paso.'**
  String get completeTaskHeaderSubtitle;

  /// No description provided for @completeTaskWhoTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quién lo hizo?'**
  String get completeTaskWhoTitle;

  /// No description provided for @completeTaskWhoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccioná quiénes ayudaron'**
  String get completeTaskWhoSubtitle;

  /// No description provided for @completeTaskWhenTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo?'**
  String get completeTaskWhenTitle;

  /// No description provided for @completeTaskWhenSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí el momento de finalización'**
  String get completeTaskWhenSubtitle;

  /// No description provided for @completeTaskTimeNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get completeTaskTimeNow;

  /// No description provided for @completeTaskTimeBefore.
  ///
  /// In es, this message translates to:
  /// **'Antes'**
  String get completeTaskTimeBefore;

  /// No description provided for @completeTaskTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar tareas'**
  String get completeTaskTasksTitle;

  /// No description provided for @completeTaskTasksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Buscá y seleccioná lo terminado'**
  String get completeTaskTasksSubtitle;

  /// No description provided for @completeTaskSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar tarea...'**
  String get completeTaskSearchHint;

  /// No description provided for @completeTaskNoTasksAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay tareas disponibles'**
  String get completeTaskNoTasksAvailable;

  /// Helper text shown at the bottom of the complete tasks sheet when the user may need to create a missing task.
  ///
  /// In es, this message translates to:
  /// **'¿No encontrás la tarea?'**
  String get completeTaskAddPromptTitle;

  /// Secondary action button at the bottom of the complete tasks sheet to open the existing new task flow.
  ///
  /// In es, this message translates to:
  /// **'Agregar nueva tarea'**
  String get completeTaskAddPromptButton;

  /// Verb shown next to the rewards earned after completing tasks. Singular when only the current user did it; plural when multiple members participated.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Ganaste} other{Ganaron}}'**
  String completeTaskRewardVerb(int count);

  /// Mensaje al completar tareas cuando algunas requieren aprobación y otras otorgan recompensas inmediatamente.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 tarea pendiente de aprobación} other{{count} tareas pendientes de aprobación}}, ⭐ {xp} XP y {coins} Coins!'**
  String completeTaskMixedApprovalMessage(int count, int xp, int coins);

  /// Mensaje al completar tareas cuando todas quedan pendientes de aprobación.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 tarea enviada para aprobación} other{{count} tareas enviadas para aprobación}}'**
  String completeTaskApprovalOnlyMessage(int count);

  /// Mensaje de recompensas obtenidas al completar tareas sin aprobación.
  ///
  /// In es, this message translates to:
  /// **'⭐ {verb} {xp} XP y {coins} Coins!'**
  String completeTaskRewardMessage(String verb, int xp, int coins);

  /// No description provided for @editTaskHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar tarea'**
  String get editTaskHeaderTitle;

  /// No description provided for @editTaskHeaderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Actualizá el nombre, la categoría y la recompensa de esta tarea.'**
  String get editTaskHeaderSubtitle;

  /// No description provided for @editTaskFieldNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la tarea'**
  String get editTaskFieldNameHint;

  /// No description provided for @editTaskSectionDetailEyebrow.
  ///
  /// In es, this message translates to:
  /// **'DETALLE'**
  String get editTaskSectionDetailEyebrow;

  /// No description provided for @editTaskSectionCategoryEyebrow.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get editTaskSectionCategoryEyebrow;

  /// No description provided for @editTaskSectionRewardEyebrow.
  ///
  /// In es, this message translates to:
  /// **'RECOMPENSA'**
  String get editTaskSectionRewardEyebrow;

  /// No description provided for @editTaskSnackNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresá un nombre para la tarea'**
  String get editTaskSnackNameRequired;

  /// No description provided for @editTaskSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get editTaskSaveChanges;

  /// No description provided for @editTaskCompleteButton.
  ///
  /// In es, this message translates to:
  /// **'Completar tarea'**
  String get editTaskCompleteButton;

  /// No description provided for @editTaskSubmitForReviewButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar a revisión'**
  String get editTaskSubmitForReviewButton;

  /// No description provided for @editTaskSnackSentForReview.
  ///
  /// In es, this message translates to:
  /// **'Tarea enviada a revisión.'**
  String get editTaskSnackSentForReview;

  /// No description provided for @editTaskDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get editTaskDeleteTitle;

  /// No description provided for @editTaskDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get editTaskDeleteConfirm;

  /// No description provided for @taskDetailHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de tarea'**
  String get taskDetailHeaderTitle;

  /// No description provided for @taskDetailFallbackUser.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get taskDetailFallbackUser;

  /// No description provided for @taskDetailStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get taskDetailStatusCompleted;

  /// No description provided for @taskDetailStatusDisputed.
  ///
  /// In es, this message translates to:
  /// **'En disputa'**
  String get taskDetailStatusDisputed;

  /// No description provided for @taskDetailStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get taskDetailStatusPending;

  /// No description provided for @taskDetailUndoButton.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get taskDetailUndoButton;

  /// No description provided for @taskDetailUndoErrorNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se puede deshacer: actividad no encontrada'**
  String get taskDetailUndoErrorNotFound;

  /// No description provided for @taskDetailUndoSuccess.
  ///
  /// In es, this message translates to:
  /// **'Tarea devuelta a pendientes.'**
  String get taskDetailUndoSuccess;

  /// No description provided for @taskDetailUndoError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo deshacer'**
  String get taskDetailUndoError;

  /// No description provided for @taskDetailNoRecord.
  ///
  /// In es, this message translates to:
  /// **'Sin registro'**
  String get taskDetailNoRecord;

  /// No description provided for @taskDetailExperience.
  ///
  /// In es, this message translates to:
  /// **'Experiencia'**
  String get taskDetailExperience;

  /// No description provided for @taskDetailReward.
  ///
  /// In es, this message translates to:
  /// **'Recompensa'**
  String get taskDetailReward;

  /// Recompensa compacta de coins mostrada en el detalle de tarea.
  ///
  /// In es, this message translates to:
  /// **'+{count, plural, =1{1 coin} other{{count} coins}}'**
  String taskDetailCoinsAwarded(int count);

  /// No description provided for @taskDetailCompletedBy.
  ///
  /// In es, this message translates to:
  /// **'La completó'**
  String get taskDetailCompletedBy;

  /// No description provided for @taskDetailAssignedTo.
  ///
  /// In es, this message translates to:
  /// **'Responsable'**
  String get taskDetailAssignedTo;

  /// No description provided for @taskDetailComment.
  ///
  /// In es, this message translates to:
  /// **'Comentario'**
  String get taskDetailComment;

  /// No description provided for @familyDashboardAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get familyDashboardAppBarTitle;

  /// No description provided for @familyDashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista por miembro'**
  String get familyDashboardTitle;

  /// No description provided for @familyDashboardLockedNotice.
  ///
  /// In es, this message translates to:
  /// **'Esta vista es para administradores de hogares familiares.'**
  String get familyDashboardLockedNotice;

  /// No description provided for @familyDashboardWeekFilter.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get familyDashboardWeekFilter;

  /// Opción del selector de período para mostrar el mes completo.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get familyDashboardMonthFilter;

  /// Progreso compacto de tareas completadas sobre el total planificado de un integrante.
  ///
  /// In es, this message translates to:
  /// **'{done, plural, =1{1 de {total} hecha} other{{done} de {total} hechas}}'**
  String familyDashboardProgress(int done, int total);

  /// Cantidad de días de racha de un integrante.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día} other{{count} días}}'**
  String familyDashboardStreakDays(int count);

  /// Cantidad compacta de tareas pendientes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 pendiente} other{{count} pendientes}}'**
  String familyDashboardPendingCount(int count);

  /// Cantidad compacta de tareas atrasadas.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 atrasada} other{{count} atrasadas}}'**
  String familyDashboardOverdueCount(int count);

  /// Cantidad compacta de tareas que esperan aprobación. La frase no cambia entre singular y plural en español.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 a aprobar} other{{count} a aprobar}}'**
  String familyDashboardToApproveCount(int count);

  /// Resumen de integrantes que tienen tareas activas en el período.
  ///
  /// In es, this message translates to:
  /// **'{active, plural, =1{1 de {total} integrante tiene tareas activas.} other{{active} de {total} integrantes tienen tareas activas.}}'**
  String familyDashboardActiveMembers(int active, int total);

  /// No description provided for @familyDashboardEmptyWeek.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas esta semana'**
  String get familyDashboardEmptyWeek;

  /// No description provided for @familyDashboardEmptyMonth.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas este mes'**
  String get familyDashboardEmptyMonth;

  /// No description provided for @familyDashboardNoStreak.
  ///
  /// In es, this message translates to:
  /// **'Sin racha'**
  String get familyDashboardNoStreak;

  /// No description provided for @familyDashboardTopCategoriesWeek.
  ///
  /// In es, this message translates to:
  /// **'Top categorías de la semana'**
  String get familyDashboardTopCategoriesWeek;

  /// No description provided for @familyDashboardTopCategoriesMonth.
  ///
  /// In es, this message translates to:
  /// **'Top categorías del mes'**
  String get familyDashboardTopCategoriesMonth;

  /// No description provided for @familyDashboardStateNoTasks.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas'**
  String get familyDashboardStateNoTasks;

  /// No description provided for @familyDashboardStateAttention.
  ///
  /// In es, this message translates to:
  /// **'Atención'**
  String get familyDashboardStateAttention;

  /// No description provided for @familyDashboardStateToReview.
  ///
  /// In es, this message translates to:
  /// **'A revisar'**
  String get familyDashboardStateToReview;

  /// No description provided for @familyDashboardTrackingWeekly.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento semanal'**
  String get familyDashboardTrackingWeekly;

  /// No description provided for @familyDashboardTrackingMonthly.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento mensual'**
  String get familyDashboardTrackingMonthly;

  /// No description provided for @familyDashboardEmptySubtitleWeek.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay tareas para esta semana.'**
  String get familyDashboardEmptySubtitleWeek;

  /// No description provided for @familyDashboardEmptySubtitleMonth.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay tareas para este mes.'**
  String get familyDashboardEmptySubtitleMonth;

  /// No description provided for @familyDashboardLabelDone.
  ///
  /// In es, this message translates to:
  /// **'Hechas'**
  String get familyDashboardLabelDone;

  /// No description provided for @familyDashboardLabelPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get familyDashboardLabelPending;

  /// No description provided for @familyDashboardLabelOverdue.
  ///
  /// In es, this message translates to:
  /// **'Atrasadas'**
  String get familyDashboardLabelOverdue;

  /// No description provided for @familyDashboardLabelToReview.
  ///
  /// In es, this message translates to:
  /// **'A revisar'**
  String get familyDashboardLabelToReview;

  /// No description provided for @familyDashboardLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista por miembro'**
  String get familyDashboardLockedTitle;

  /// No description provided for @familyDashboardLockedBody.
  ///
  /// In es, this message translates to:
  /// **'Activá Modo Padres para ver el progreso de cada integrante de la familia en un solo lugar.'**
  String get familyDashboardLockedBody;

  /// No description provided for @familyDashboardEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay datos'**
  String get familyDashboardEmptyTitle;

  /// No description provided for @familyDashboardEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando los miembros completen tareas o reciban coins, los vas a ver acá.'**
  String get familyDashboardEmptyBody;

  /// No description provided for @weeklySummaryAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get weeklySummaryAppBarTitle;

  /// No description provided for @weeklySummaryLockedNotice.
  ///
  /// In es, this message translates to:
  /// **'Esta sección es para administradores de hogares familiares.'**
  String get weeklySummaryLockedNotice;

  /// No description provided for @weeklySummaryHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get weeklySummaryHeaderTitle;

  /// No description provided for @weeklySummaryTitleAttention.
  ///
  /// In es, this message translates to:
  /// **'Semana con puntos a revisar'**
  String get weeklySummaryTitleAttention;

  /// No description provided for @weeklySummaryTitleGood.
  ///
  /// In es, this message translates to:
  /// **'Buena coordinación'**
  String get weeklySummaryTitleGood;

  /// No description provided for @weeklySummaryTitleQuietWithExpenses.
  ///
  /// In es, this message translates to:
  /// **'Semana tranquila con gastos'**
  String get weeklySummaryTitleQuietWithExpenses;

  /// No description provided for @weeklySummaryTitleQuiet.
  ///
  /// In es, this message translates to:
  /// **'Semana tranquila'**
  String get weeklySummaryTitleQuiet;

  /// No description provided for @weeklySummaryBodyExpensesNoTasks.
  ///
  /// In es, this message translates to:
  /// **'Hubo gastos compartidos, pero todavía no hubo tareas planificadas.'**
  String get weeklySummaryBodyExpensesNoTasks;

  /// No description provided for @weeklySummaryBodyNoActivity.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hubo actividad suficiente para un cierre completo.'**
  String get weeklySummaryBodyNoActivity;

  /// No description provided for @weeklySummaryNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get weeklySummaryNoData;

  /// No description provided for @weeklySummaryMetricTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get weeklySummaryMetricTasks;

  /// No description provided for @weeklySummaryMetricExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get weeklySummaryMetricExpenses;

  /// No description provided for @weeklySummaryMetricCompletion.
  ///
  /// In es, this message translates to:
  /// **'Cumpl.'**
  String get weeklySummaryMetricCompletion;

  /// No description provided for @weeklySummaryEyebrowCompletion.
  ///
  /// In es, this message translates to:
  /// **'Cumplimiento'**
  String get weeklySummaryEyebrowCompletion;

  /// No description provided for @weeklySummaryEyebrowNeedsBoost.
  ///
  /// In es, this message translates to:
  /// **'Necesita un empujón'**
  String get weeklySummaryEyebrowNeedsBoost;

  /// Título de la persona MVP del resumen semanal.
  ///
  /// In es, this message translates to:
  /// **'{name} se llevó la semana'**
  String weeklySummaryMvpTitle(String name);

  /// Cantidad de tareas completadas por la persona MVP de la semana.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Completó 1 tarea en el hogar.} other{Completó {count} tareas en el hogar.}}'**
  String weeklySummaryMvpSubtitle(int count);

  /// Título para la persona que necesita apoyo con sus tareas.
  ///
  /// In es, this message translates to:
  /// **'{name} se quedó con tareas pendientes'**
  String weeklySummaryNeedsBoostTitle(String name);

  /// Cantidad de tareas atrasadas y sugerencia de apoyo semanal.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 tarea atrasada. Quizá esta semana puedas ayudarle a destrabar.} other{{count} tareas atrasadas. Quizá esta semana puedas ayudarle a destrabar.}}'**
  String weeklySummaryNeedsBoostSubtitle(int count);

  /// No description provided for @weeklySummaryEyebrowMostForgotten.
  ///
  /// In es, this message translates to:
  /// **'La más olvidada'**
  String get weeklySummaryEyebrowMostForgotten;

  /// No description provided for @weeklySummaryEyebrowExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos compartidos'**
  String get weeklySummaryEyebrowExpenses;

  /// No description provided for @weeklySummaryEyebrowTopCategory.
  ///
  /// In es, this message translates to:
  /// **'Top categoría'**
  String get weeklySummaryEyebrowTopCategory;

  /// No description provided for @weeklySummaryCompletionEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas esta semana'**
  String get weeklySummaryCompletionEmpty;

  /// No description provided for @weeklySummaryCompletionGoodPace.
  ///
  /// In es, this message translates to:
  /// **'Buen ritmo: la semana cerró con lo planificado al día.'**
  String get weeklySummaryCompletionGoodPace;

  /// No description provided for @weeklySummaryCompletionLockedBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando asignen tareas, acá vas a ver cumplimiento real y comparación semanal.'**
  String get weeklySummaryCompletionLockedBody;

  /// No description provided for @weeklySummaryExpensesNone.
  ///
  /// In es, this message translates to:
  /// **'No hubo gastos compartidos esta semana.'**
  String get weeklySummaryExpensesNone;

  /// No description provided for @weeklySummaryExpensesFirst.
  ///
  /// In es, this message translates to:
  /// **'Primera semana con gastos compartidos.'**
  String get weeklySummaryExpensesFirst;

  /// No description provided for @weeklySummaryExpensesSame.
  ///
  /// In es, this message translates to:
  /// **'Mismo gasto que la semana anterior.'**
  String get weeklySummaryExpensesSame;

  /// Overdue label for a task that became overdue today.
  ///
  /// In es, this message translates to:
  /// **'venció hoy'**
  String get weeklySummaryOverdueToday;

  /// Overdue label for a task that became overdue N days ago.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{venció hace 1 día} other{venció hace {count} días}}'**
  String weeklySummaryOverdueDays(int count);

  /// Subtitle for the most-forgotten recurring task card. {overdueLabel} is the overdue text.
  ///
  /// In es, this message translates to:
  /// **'Esta recurrente quedó en el camino — {overdueLabel}.'**
  String weeklySummaryForgottenSubtitle(String overdueLabel);

  /// Spending card text when the household spent less than the previous week.
  ///
  /// In es, this message translates to:
  /// **'Gastaron {amount} menos que la semana anterior.'**
  String weeklySummaryExpensesLess(String amount);

  /// Spending card text when the household spent more than the previous week.
  ///
  /// In es, this message translates to:
  /// **'Gastaron {amount} más que la semana anterior.'**
  String weeklySummaryExpensesMore(String amount);

  /// No description provided for @weeklySummaryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu primer resumen viene en camino'**
  String get weeklySummaryEmptyTitle;

  /// No description provided for @weeklySummaryEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando empiecen a completar tareas y cargar gastos vamos a generar el reporte de la semana automáticamente.'**
  String get weeklySummaryEmptyBody;

  /// No description provided for @weeklySummaryLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get weeklySummaryLockedTitle;

  /// No description provided for @weeklySummaryLockedBody.
  ///
  /// In es, this message translates to:
  /// **'Activá Modo Padres para recibir el resumen de la semana con cumplimiento, MVP y gastos.'**
  String get weeklySummaryLockedBody;

  /// No description provided for @calendarWeekOf.
  ///
  /// In es, this message translates to:
  /// **'Semana de'**
  String get calendarWeekOf;

  /// No description provided for @calendarNoTasksScheduled.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas programadas'**
  String get calendarNoTasksScheduled;

  /// No description provided for @pendingApprovalsAppBarShortTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprobaciones'**
  String get pendingApprovalsAppBarShortTitle;

  /// No description provided for @pendingApprovalsAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprobaciones pendientes'**
  String get pendingApprovalsAppBarTitle;

  /// No description provided for @pendingApprovalsLockedNotice.
  ///
  /// In es, this message translates to:
  /// **'Esta sección es para administradores de hogares familiares.'**
  String get pendingApprovalsLockedNotice;

  /// No description provided for @pendingApprovalsSubmittedBy.
  ///
  /// In es, this message translates to:
  /// **'Enviada por {name}'**
  String pendingApprovalsSubmittedBy(Object name);

  /// No description provided for @pendingApprovalsApproveButton.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get pendingApprovalsApproveButton;

  /// No description provided for @pendingApprovalsRejectButton.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get pendingApprovalsRejectButton;

  /// No description provided for @pendingApprovalsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las aprobaciones pendientes.'**
  String get pendingApprovalsLoadError;

  /// No description provided for @pendingApprovalsApprovedSnack.
  ///
  /// In es, this message translates to:
  /// **'Aprobada. Se acreditaron {coins} coins.'**
  String pendingApprovalsApprovedSnack(Object coins);

  /// No description provided for @pendingApprovalsApproveErrorRetry.
  ///
  /// In es, this message translates to:
  /// **'No pudimos aprobar la tarea. Reintentá.'**
  String get pendingApprovalsApproveErrorRetry;

  /// No description provided for @pendingApprovalsRejectedSnack.
  ///
  /// In es, this message translates to:
  /// **'Tarea rechazada.'**
  String get pendingApprovalsRejectedSnack;

  /// No description provided for @pendingApprovalsRejectErrorRetry.
  ///
  /// In es, this message translates to:
  /// **'No pudimos rechazar la tarea. Reintentá.'**
  String get pendingApprovalsRejectErrorRetry;

  /// No description provided for @pendingApprovalsRejectDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Motivo del rechazo'**
  String get pendingApprovalsRejectDialogTitle;

  /// No description provided for @pendingApprovalsRejectDialogHint.
  ///
  /// In es, this message translates to:
  /// **'Por qué no está aprobada (opcional)'**
  String get pendingApprovalsRejectDialogHint;

  /// No description provided for @pendingApprovalsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Nada pendiente por ahora'**
  String get pendingApprovalsEmptyTitle;

  /// No description provided for @pendingApprovalsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando alguien complete una tarea aparecerá acá para que la revises.'**
  String get pendingApprovalsEmptyBody;

  /// No description provided for @pendingApprovalsLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprobación de tareas'**
  String get pendingApprovalsLockedTitle;

  /// No description provided for @pendingApprovalsLockedBody.
  ///
  /// In es, this message translates to:
  /// **'Activá Modo Padres para revisar y aprobar lo que cumple cada miembro del hogar antes de acreditar los coins.'**
  String get pendingApprovalsLockedBody;

  /// No description provided for @expensesTabMovements.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get expensesTabMovements;

  /// No description provided for @expensesTabRecurring.
  ///
  /// In es, this message translates to:
  /// **'Recurrentes'**
  String get expensesTabRecurring;

  /// No description provided for @expensesTabGoals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get expensesTabGoals;

  /// No description provided for @expensesFabMovement.
  ///
  /// In es, this message translates to:
  /// **'Movimiento'**
  String get expensesFabMovement;

  /// No description provided for @expensesFabNewSubscription.
  ///
  /// In es, this message translates to:
  /// **'Nueva Suscripción'**
  String get expensesFabNewSubscription;

  /// No description provided for @expensesFabNewGoal.
  ///
  /// In es, this message translates to:
  /// **'Nueva Meta'**
  String get expensesFabNewGoal;

  /// No description provided for @expensesActivityRecentEyebrow.
  ///
  /// In es, this message translates to:
  /// **'ACTIVIDAD RECIENTE'**
  String get expensesActivityRecentEyebrow;

  /// No description provided for @expensesActivityEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos recientes'**
  String get expensesActivityEmpty;

  /// No description provided for @expensesDateToday.
  ///
  /// In es, this message translates to:
  /// **'HOY'**
  String get expensesDateToday;

  /// No description provided for @expensesDateYesterday.
  ///
  /// In es, this message translates to:
  /// **'AYER'**
  String get expensesDateYesterday;

  /// No description provided for @expensesDateTomorrow.
  ///
  /// In es, this message translates to:
  /// **'MAÑANA'**
  String get expensesDateTomorrow;

  /// No description provided for @expensesSummaryMainBalance.
  ///
  /// In es, this message translates to:
  /// **'TU BALANCE ACTUAL'**
  String get expensesSummaryMainBalance;

  /// No description provided for @expensesSummaryMainProjected.
  ///
  /// In es, this message translates to:
  /// **'TOTAL PREVISTO DEL MES'**
  String get expensesSummaryMainProjected;

  /// No description provided for @expensesSummaryMainExpenses.
  ///
  /// In es, this message translates to:
  /// **'GASTOS DEL MES'**
  String get expensesSummaryMainExpenses;

  /// No description provided for @expensesStatTileEstimatedIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingreso estimado'**
  String get expensesStatTileEstimatedIncome;

  /// No description provided for @expensesStatTileIncomes.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get expensesStatTileIncomes;

  /// No description provided for @expensesStatTilePaid.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get expensesStatTilePaid;

  /// No description provided for @expensesStatTileExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expensesStatTileExpenses;

  /// No description provided for @expensesStatTilePending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get expensesStatTilePending;

  /// No description provided for @expensesProjectionPendingShare.
  ///
  /// In es, this message translates to:
  /// **'Tu parte pendiente'**
  String get expensesProjectionPendingShare;

  /// No description provided for @expensesProjectionEstimated.
  ///
  /// In es, this message translates to:
  /// **'Cierre estimado'**
  String get expensesProjectionEstimated;

  /// No description provided for @expensesProjectionOwedToYou.
  ///
  /// In es, this message translates to:
  /// **'Te deben'**
  String get expensesProjectionOwedToYou;

  /// No description provided for @expensesProjectionYouOwe.
  ///
  /// In es, this message translates to:
  /// **'Debés'**
  String get expensesProjectionYouOwe;

  /// No description provided for @expensesProjectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Cálculo de proyección'**
  String get expensesProjectionTitle;

  /// No description provided for @expensesProjectionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Así llegamos a tu cierre estimado para fin de mes.'**
  String get expensesProjectionSubtitle;

  /// No description provided for @expensesProjectionRowBalance.
  ///
  /// In es, this message translates to:
  /// **'Tu balance actual'**
  String get expensesProjectionRowBalance;

  /// No description provided for @expensesProjectionRowEstimated.
  ///
  /// In es, this message translates to:
  /// **'Tu cierre estimado'**
  String get expensesProjectionRowEstimated;

  /// No description provided for @expensesPendingDetailsEyebrow.
  ///
  /// In es, this message translates to:
  /// **'DETALLE DE PENDIENTES'**
  String get expensesPendingDetailsEyebrow;

  /// No description provided for @expensesGotIt.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get expensesGotIt;

  /// No description provided for @expensesIncomeBreakdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Ingresos'**
  String get expensesIncomeBreakdownTitle;

  /// No description provided for @expensesIncomeBreakdownSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus ingresos registrados este mes.'**
  String get expensesIncomeBreakdownSubtitle;

  /// No description provided for @expensesExpensesBreakdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Gastos'**
  String get expensesExpensesBreakdownTitle;

  /// No description provided for @expensesExpensesBreakdownSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus gastos pagados este mes.'**
  String get expensesExpensesBreakdownSubtitle;

  /// No description provided for @expensesPendingBreakdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu Parte Pendiente'**
  String get expensesPendingBreakdownTitle;

  /// No description provided for @expensesPendingBreakdownSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que te corresponde de los gastos planificados de este mes.'**
  String get expensesPendingBreakdownSubtitle;

  /// No description provided for @expensesPendingBreakdownTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu total pendiente'**
  String get expensesPendingBreakdownTotalLabel;

  /// No description provided for @expensesBreakdownTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total del mes'**
  String get expensesBreakdownTotalLabel;

  /// No description provided for @expensesBreakdownEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos registrados'**
  String get expensesBreakdownEmpty;

  /// No description provided for @expensesBreakdownMovementsEyebrow.
  ///
  /// In es, this message translates to:
  /// **'MOVIMIENTOS'**
  String get expensesBreakdownMovementsEyebrow;

  /// No description provided for @budgetsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'PRESUPUESTOS'**
  String get budgetsSectionTitle;

  /// No description provided for @budgetsManageAction.
  ///
  /// In es, this message translates to:
  /// **'Gestionar'**
  String get budgetsManageAction;

  /// No description provided for @budgetsTeaserTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos por categoría'**
  String get budgetsTeaserTitle;

  /// No description provided for @budgetsTeaserSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Definí topes mensuales y mirá cuánto te queda'**
  String get budgetsTeaserSubtitle;

  /// No description provided for @budgetsEmptyCta.
  ///
  /// In es, this message translates to:
  /// **'Crear tu primer presupuesto'**
  String get budgetsEmptyCta;

  /// No description provided for @budgetsManageTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos'**
  String get budgetsManageTitle;

  /// Recoverable error shown when category budgets cannot be loaded.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus presupuestos.'**
  String get budgetsLoadError;

  /// Snackbar shown when creating or updating a category budget fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el presupuesto. Intentá de nuevo.'**
  String get budgetsSaveError;

  /// Snackbar shown when deleting a category budget fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos eliminar el presupuesto. Intentá de nuevo.'**
  String get budgetsDeleteError;

  /// Snackbar shown when confirming a planned expense payment fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos registrar el pago. Intentá de nuevo.'**
  String get expensesPlannedPaymentError;

  /// Recoverable error shown when household members cannot be loaded in the planned payment sheet.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los integrantes.'**
  String get expensesPlannedPaymentMembersLoadError;

  /// Snackbar shown when generating a household invitation code fails without exposing technical details.
  ///
  /// In es, this message translates to:
  /// **'No pudimos generar el código. Intentá de nuevo.'**
  String get settingsHouseholdCodeGenerateError;

  /// No description provided for @budgetsManageSubtitleShared.
  ///
  /// In es, this message translates to:
  /// **'Topes mensuales del hogar, visibles para todos.'**
  String get budgetsManageSubtitleShared;

  /// No description provided for @budgetsManageSubtitlePersonal.
  ///
  /// In es, this message translates to:
  /// **'Tus topes mensuales, sobre tu parte de los gastos.'**
  String get budgetsManageSubtitlePersonal;

  /// No description provided for @budgetsManageEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay presupuestos.'**
  String get budgetsManageEmpty;

  /// No description provided for @budgetsAddCategory.
  ///
  /// In es, this message translates to:
  /// **'Agregar categoría'**
  String get budgetsAddCategory;

  /// No description provided for @budgetsNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo presupuesto'**
  String get budgetsNewTitle;

  /// No description provided for @budgetsEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar presupuesto'**
  String get budgetsEditTitle;

  /// No description provided for @budgetsCategoryEyebrow.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get budgetsCategoryEyebrow;

  /// No description provided for @budgetsLimitEyebrow.
  ///
  /// In es, this message translates to:
  /// **'TOPE MENSUAL'**
  String get budgetsLimitEyebrow;

  /// No description provided for @budgetsDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar presupuesto?'**
  String get budgetsDeleteTitle;

  /// No description provided for @budgetsDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se elimina el tope de {category}. Tus gastos no se tocan.'**
  String budgetsDeleteBody(String category);

  /// No description provided for @budgetsRemaining.
  ///
  /// In es, this message translates to:
  /// **'Queda {amount}'**
  String budgetsRemaining(String amount);

  /// No description provided for @budgetsOverBy.
  ///
  /// In es, this message translates to:
  /// **'{amount} de más'**
  String budgetsOverBy(String amount);

  /// No description provided for @budgetsSpentOf.
  ///
  /// In es, this message translates to:
  /// **'{spent} de {limit}'**
  String budgetsSpentOf(String spent, String limit);

  /// No description provided for @financeInsightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis'**
  String get financeInsightsTitle;

  /// No description provided for @financeInsightsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tendencia y presupuestos del mes'**
  String get financeInsightsSubtitle;

  /// No description provided for @financeInsightsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ver análisis'**
  String get financeInsightsTooltip;

  /// No description provided for @trendTitle.
  ///
  /// In es, this message translates to:
  /// **'TENDENCIA · 6 MESES'**
  String get trendTitle;

  /// No description provided for @trendDeltaDown.
  ///
  /// In es, this message translates to:
  /// **'{pct}% menos que en {month}'**
  String trendDeltaDown(int pct, String month);

  /// No description provided for @trendDeltaUp.
  ///
  /// In es, this message translates to:
  /// **'{pct}% más que en {month}'**
  String trendDeltaUp(int pct, String month);

  /// No description provided for @trendDeltaFlat.
  ///
  /// In es, this message translates to:
  /// **'Parecido a {month}'**
  String trendDeltaFlat(String month);

  /// No description provided for @trendCurrentMonthLabel.
  ///
  /// In es, this message translates to:
  /// **'Gasto de este mes'**
  String get trendCurrentMonthLabel;

  /// No description provided for @exportCsvTooltip.
  ///
  /// In es, this message translates to:
  /// **'Exportar mes (CSV)'**
  String get exportCsvTooltip;

  /// No description provided for @exportCsvEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos este mes para exportar'**
  String get exportCsvEmpty;

  /// No description provided for @exportCsvShareSubject.
  ///
  /// In es, this message translates to:
  /// **'Finanzas de {month} — HomeSync'**
  String exportCsvShareSubject(String month);

  /// No description provided for @csvHeaderDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get csvHeaderDate;

  /// No description provided for @csvHeaderType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get csvHeaderType;

  /// No description provided for @csvHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get csvHeaderTitle;

  /// No description provided for @csvHeaderCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get csvHeaderCategory;

  /// No description provided for @csvHeaderAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get csvHeaderAmount;

  /// No description provided for @csvHeaderPayer.
  ///
  /// In es, this message translates to:
  /// **'Pagó'**
  String get csvHeaderPayer;

  /// No description provided for @csvHeaderSplit.
  ///
  /// In es, this message translates to:
  /// **'División'**
  String get csvHeaderSplit;

  /// No description provided for @csvTypeExpense.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get csvTypeExpense;

  /// No description provided for @csvTypeIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get csvTypeIncome;

  /// No description provided for @csvTypeSettlement.
  ///
  /// In es, this message translates to:
  /// **'Liquidación'**
  String get csvTypeSettlement;

  /// No description provided for @subsSuggestionTitle.
  ///
  /// In es, this message translates to:
  /// **'¿\"{title}\" es un gasto fijo?'**
  String subsSuggestionTitle(String title);

  /// No description provided for @subsSuggestionBody.
  ///
  /// In es, this message translates to:
  /// **'Se repite todos los meses (~{amount}). Crealo como recurrente y se agenda solo.'**
  String subsSuggestionBody(String amount);

  /// No description provided for @subsSuggestionCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear recurrente'**
  String get subsSuggestionCreate;

  /// No description provided for @subsSuggestionDismiss.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get subsSuggestionDismiss;

  /// No description provided for @goalAutoMenuAction.
  ///
  /// In es, this message translates to:
  /// **'Aporte automático'**
  String get goalAutoMenuAction;

  /// No description provided for @goalAutoTitle.
  ///
  /// In es, this message translates to:
  /// **'Aporte automático'**
  String get goalAutoTitle;

  /// No description provided for @goalAutoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los meses se agenda un aporte a \"{goal}\" que confirmás con un toque.'**
  String goalAutoSubtitle(String goal);

  /// No description provided for @goalAutoAmountEyebrow.
  ///
  /// In es, this message translates to:
  /// **'APORTE MENSUAL'**
  String get goalAutoAmountEyebrow;

  /// No description provided for @goalAutoDayEyebrow.
  ///
  /// In es, this message translates to:
  /// **'DÍA DEL MES'**
  String get goalAutoDayEyebrow;

  /// No description provided for @goalAutoDisable.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get goalAutoDisable;

  /// No description provided for @goalAutoSavedSnack.
  ///
  /// In es, this message translates to:
  /// **'Aporte automático activado'**
  String get goalAutoSavedSnack;

  /// No description provided for @goalAutoDisabledSnack.
  ///
  /// In es, this message translates to:
  /// **'Aporte automático desactivado'**
  String get goalAutoDisabledSnack;

  /// No description provided for @recapBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu {month} está listo ✨'**
  String recapBannerTitle(String month);

  /// No description provided for @recapBannerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuánto se gastó, en qué y cuánto se ahorró.'**
  String get recapBannerSubtitle;

  /// No description provided for @recapSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu {month}'**
  String recapSheetTitle(String month);

  /// No description provided for @recapMovementsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} movimientos registrados'**
  String recapMovementsCount(int count);

  /// No description provided for @recapTotalLabelShared.
  ///
  /// In es, this message translates to:
  /// **'GASTO DEL HOGAR'**
  String get recapTotalLabelShared;

  /// No description provided for @recapTotalLabelPersonal.
  ///
  /// In es, this message translates to:
  /// **'TU PARTE DEL MES'**
  String get recapTotalLabelPersonal;

  /// No description provided for @recapIncomeRow.
  ///
  /// In es, this message translates to:
  /// **'Ingresos del mes: {amount}'**
  String recapIncomeRow(String amount);

  /// No description provided for @recapCategoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'EN QUÉ SE FUE'**
  String get recapCategoriesTitle;

  /// No description provided for @recapPayersTitle.
  ///
  /// In es, this message translates to:
  /// **'QUIÉN PUSO'**
  String get recapPayersTitle;

  /// No description provided for @allowanceRepeatToggle.
  ///
  /// In es, this message translates to:
  /// **'Repetir todos los meses'**
  String get allowanceRepeatToggle;

  /// No description provided for @allowanceActiveScheduleInfo.
  ///
  /// In es, this message translates to:
  /// **'Mesada mensual activa: {amount} el día {day}'**
  String allowanceActiveScheduleInfo(String amount, int day);

  /// No description provided for @allowanceScheduleDisable.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get allowanceScheduleDisable;

  /// No description provided for @allowanceScheduleDisabledSnack.
  ///
  /// In es, this message translates to:
  /// **'Mesada mensual desactivada'**
  String get allowanceScheduleDisabledSnack;

  /// No description provided for @allowanceScheduledSnack.
  ///
  /// In es, this message translates to:
  /// **'Mesada enviada y programada para el día {day} de cada mes'**
  String allowanceScheduledSnack(int day);

  /// No description provided for @allowanceScheduleError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo programar la mesada: {details}'**
  String allowanceScheduleError(String details);

  /// No description provided for @poolsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'FONDOS'**
  String get poolsSectionTitle;

  /// No description provided for @poolsNewAction.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get poolsNewAction;

  /// No description provided for @poolsEmptyCta.
  ///
  /// In es, this message translates to:
  /// **'Crear un fondo (asado, viaje, regalo…)'**
  String get poolsEmptyCta;

  /// No description provided for @poolsCardSettled.
  ///
  /// In es, this message translates to:
  /// **'Saldado ✓'**
  String get poolsCardSettled;

  /// No description provided for @poolsCardExpenseCount.
  ///
  /// In es, this message translates to:
  /// **'{count} movimientos'**
  String poolsCardExpenseCount(int count);

  /// No description provided for @poolsCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo fondo'**
  String get poolsCreateTitle;

  /// No description provided for @poolsCreateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agrupá los gastos de un evento y saldalo aparte del día a día del piso.'**
  String get poolsCreateSubtitle;

  /// No description provided for @poolsCreateNameHint.
  ///
  /// In es, this message translates to:
  /// **'Asado del sábado, Viaje a Córdoba…'**
  String get poolsCreateNameHint;

  /// No description provided for @poolsCreateCta.
  ///
  /// In es, this message translates to:
  /// **'Crear fondo'**
  String get poolsCreateCta;

  /// Recoverable compact error shown when active expense pools cannot be loaded.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los fondos.'**
  String get poolsLoadError;

  /// Snackbar shown when creating an expense pool fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos crear el fondo. Intentá de nuevo.'**
  String get poolsCreateError;

  /// Recoverable error shown when an expense pool summary cannot be loaded.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar este fondo.'**
  String get poolsDetailLoadError;

  /// Snackbar shown when settling a debt inside an expense pool fails without exposing technical details.
  ///
  /// In es, this message translates to:
  /// **'No pudimos registrar el pago. Intentá de nuevo.'**
  String get poolsSettleError;

  /// Snackbar shown when archiving an expense pool fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cerrar el fondo. Intentá de nuevo.'**
  String get poolsCloseError;

  /// No description provided for @poolsDetailNotFound.
  ///
  /// In es, this message translates to:
  /// **'Este fondo ya no existe'**
  String get poolsDetailNotFound;

  /// No description provided for @poolsDetailTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'TOTAL DEL FONDO'**
  String get poolsDetailTotalLabel;

  /// No description provided for @poolsDetailSettleTitle.
  ///
  /// In es, this message translates to:
  /// **'PARA SALDAR ESTE FONDO'**
  String get poolsDetailSettleTitle;

  /// No description provided for @poolsDetailAllSettled.
  ///
  /// In es, this message translates to:
  /// **'Fondo saldado — nadie debe nada acá.'**
  String get poolsDetailAllSettled;

  /// No description provided for @poolsDetailDebtRow.
  ///
  /// In es, this message translates to:
  /// **'{from} le pasa {amount} a {to}'**
  String poolsDetailDebtRow(String from, String amount, String to);

  /// No description provided for @poolsDetailSettleCta.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get poolsDetailSettleCta;

  /// No description provided for @poolsCloseCta.
  ///
  /// In es, this message translates to:
  /// **'Cerrar fondo'**
  String get poolsCloseCta;

  /// No description provided for @poolsCloseConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar este fondo?'**
  String get poolsCloseConfirmTitle;

  /// No description provided for @poolsCloseConfirmBodySettled.
  ///
  /// In es, this message translates to:
  /// **'El fondo se archiva y deja de aparecer. Sus movimientos quedan en el historial.'**
  String get poolsCloseConfirmBodySettled;

  /// No description provided for @poolsCloseConfirmBodyPending.
  ///
  /// In es, this message translates to:
  /// **'Quedan cuentas sin saldar: siguen vivas en el balance general del hogar. El fondo se archiva igual.'**
  String get poolsCloseConfirmBodyPending;

  /// No description provided for @poolsClosedSnack.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" cerrado'**
  String poolsClosedSnack(String name);

  /// No description provided for @expensesFormSectionPoolEyebrow.
  ///
  /// In es, this message translates to:
  /// **'FONDO'**
  String get expensesFormSectionPoolEyebrow;

  /// No description provided for @expensesFormSectionPoolTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Es de un fondo?'**
  String get expensesFormSectionPoolTitle;

  /// No description provided for @expensesFormSectionPoolSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sumalo a un evento para verlo agrupado y saldarlo aparte.'**
  String get expensesFormSectionPoolSubtitle;

  /// No description provided for @expensesFormPoolNone.
  ///
  /// In es, this message translates to:
  /// **'Sin fondo'**
  String get expensesFormPoolNone;

  /// No description provided for @recapSavingsRow.
  ///
  /// In es, this message translates to:
  /// **'{type, select, solo{Sumaste {amount} a tus metas de ahorro.} other{Sumaron {amount} a las metas de ahorro.}}'**
  String recapSavingsRow(String type, String amount);

  /// No description provided for @expensesPlannedSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get expensesPlannedSkip;

  /// No description provided for @expensesPlannedPay.
  ///
  /// In es, this message translates to:
  /// **'{type, select, income{Cobrar} other{Pagar}}'**
  String expensesPlannedPay(String type);

  /// No description provided for @expensesPlannedPaymentSnack.
  ///
  /// In es, this message translates to:
  /// **'{type, select, income{Cobro de \"{title}\" registrado} other{Pago de \"{title}\" registrado}}'**
  String expensesPlannedPaymentSnack(String type, String title);

  /// No description provided for @expensesPlannedBadgeUpcoming.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMO'**
  String get expensesPlannedBadgeUpcoming;

  /// No description provided for @expensesPlannedBadgePending.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get expensesPlannedBadgePending;

  /// No description provided for @expensesPlannedBadgeDueToday.
  ///
  /// In es, this message translates to:
  /// **'VENCE HOY'**
  String get expensesPlannedBadgeDueToday;

  /// No description provided for @expensesPlannedBadgeTomorrow.
  ///
  /// In es, this message translates to:
  /// **'MAÑANA'**
  String get expensesPlannedBadgeTomorrow;

  /// No description provided for @expensesPlannedBadgeSoon.
  ///
  /// In es, this message translates to:
  /// **'VENCE PRONTO'**
  String get expensesPlannedBadgeSoon;

  /// No description provided for @expensesDeleteDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar gasto?'**
  String get expensesDeleteDialogTitle;

  /// No description provided for @expensesDeleteDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get expensesDeleteDialogBody;

  /// No description provided for @expensesDeletedSnack.
  ///
  /// In es, this message translates to:
  /// **'Movimiento eliminado'**
  String get expensesDeletedSnack;

  /// No description provided for @expensesTypeBadgeGift.
  ///
  /// In es, this message translates to:
  /// **'Regalo'**
  String get expensesTypeBadgeGift;

  /// No description provided for @expensesTypeBadgeShared.
  ///
  /// In es, this message translates to:
  /// **'Compartido'**
  String get expensesTypeBadgeShared;

  /// No description provided for @expensesTypeBadgePersonal.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get expensesTypeBadgePersonal;

  /// No description provided for @expensesSettlementCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Liquidación de saldo'**
  String get expensesSettlementCardTitle;

  /// No description provided for @expensesSettlementCardBody.
  ///
  /// In es, this message translates to:
  /// **'{name} equilibró el balance'**
  String expensesSettlementCardBody(String name);

  /// No description provided for @expensesEmptyDefaultSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Empezá hoy mismo a organizar tus finanzas del hogar.'**
  String get expensesEmptyDefaultSubtitle;

  /// Aviso cuando el servidor detecta que la misma imagen de ticket ya se escaneó con éxito recientemente
  ///
  /// In es, this message translates to:
  /// **'Este ticket ya fue escaneado hace poco. Revisá que no cargues el gasto dos veces.'**
  String get expensesFormOcrDuplicate;

  /// Snackbar warning when OCR confidence is low — user should double-check the prefilled data.
  ///
  /// In es, this message translates to:
  /// **'Ticket difícil de leer; revisá los datos antes de guardar'**
  String get expensesFormOcrLowConfidence;

  /// Snackbar shown when the server throttles receipt scans (anti-abuse). Not a plan limit; OCR is free for everyone.
  ///
  /// In es, this message translates to:
  /// **'Demasiados escaneos seguidos. Esperá unos segundos y volvé a intentar.'**
  String get expensesFormOcrRateLimited;

  /// Snackbar shown when the compressed receipt image exceeds the 5 MB scan limit.
  ///
  /// In es, this message translates to:
  /// **'La imagen es demasiado grande ({sizeMb} MB, máx 5 MB). Probá con otra foto o desde la galería.'**
  String expensesFormOcrImageTooLarge(String sizeMb);

  /// Snackbar shown when there is no valid Firebase session to authorize the receipt scan.
  ///
  /// In es, this message translates to:
  /// **'Sesión expirada. Iniciá sesión nuevamente para escanear.'**
  String get expensesFormOcrSessionExpired;

  /// Snackbar shown when the receipt scan request times out (slow or hung mobile network).
  ///
  /// In es, this message translates to:
  /// **'El escaneo tardó demasiado. Revisá tu conexión y volvé a intentar.'**
  String get expensesFormOcrTimeout;

  /// Snackbar shown when the receipt could not be read (AI failed or returned unusable data). Friendly copy, no technical details.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer el ticket. Probá con más luz y con el ticket entero en la foto.'**
  String get expensesFormOcrFailed;

  /// Snackbar shown when the user hit the daily receipt-scan cap (cost guard, ~100 per day).
  ///
  /// In es, this message translates to:
  /// **'Llegaste al límite de escaneos por hoy. Podés cargar el gasto a mano.'**
  String get expensesFormOcrDailyLimit;

  /// Snackbar warning when the scanned total does not add up with the receipt line items.
  ///
  /// In es, this message translates to:
  /// **'El total no coincide con la suma de los productos. Revisá el monto antes de guardar.'**
  String get expensesFormOcrAmountMismatch;

  /// Snackbar warning when an existing household expense has the same amount and date as the scanned receipt.
  ///
  /// In es, this message translates to:
  /// **'Ya cargaste «{title}» por este monto el {date}. Revisá que no sea el mismo gasto.'**
  String expensesFormOcrPossibleDuplicate(String title, DateTime date);

  /// Validation error when the amount field is empty or invalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un monto válido.'**
  String get expensesFormValidationAmountRequired;

  /// Exception thrown when the user tries to save an expense but doesn't belong to a household.
  ///
  /// In es, this message translates to:
  /// **'No pertenecés a un hogar'**
  String get expensesFormValidationNoHousehold;

  /// No description provided for @expensesFormSavedIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingreso guardado'**
  String get expensesFormSavedIncome;

  /// No description provided for @expensesFormSavedExpense.
  ///
  /// In es, this message translates to:
  /// **'Gasto guardado'**
  String get expensesFormSavedExpense;

  /// Success label on the save button when editing an existing expense.
  ///
  /// In es, this message translates to:
  /// **'Gasto actualizado'**
  String get expensesFormUpdatedExpense;

  /// Primary button on the planned expense payment sheet. Confirms the payment and records it as an actual expense.
  ///
  /// In es, this message translates to:
  /// **'Confirmar y registrar'**
  String get plannedExpensePaymentConfirmButton;

  /// Delete confirmation dialog title in the expense form.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar gasto?'**
  String get expensesFormDeleteDialogTitle;

  /// Delete confirmation dialog body in the expense form.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get expensesFormDeleteDialogBody;

  /// Eyebrow label for the 'Detail' section of the expense form.
  ///
  /// In es, this message translates to:
  /// **'DETALLE'**
  String get expensesFormSectionDetailEyebrow;

  /// Detail section title when creating an income entry.
  ///
  /// In es, this message translates to:
  /// **'¿De dónde viene?'**
  String get expensesFormSectionDetailTitleIncome;

  /// Detail section title when creating an expense entry.
  ///
  /// In es, this message translates to:
  /// **'¿Qué estás registrando?'**
  String get expensesFormSectionDetailTitleExpense;

  /// Detail section subtitle when creating an income entry.
  ///
  /// In es, this message translates to:
  /// **'Podés dejar un nombre claro para reconocer este ingreso más rápido.'**
  String get expensesFormSectionDetailSubtitleIncome;

  /// Detail section subtitle when creating an expense entry.
  ///
  /// In es, this message translates to:
  /// **'Dale un nombre simple para ubicar este gasto de un vistazo.'**
  String get expensesFormSectionDetailSubtitleExpense;

  /// Eyebrow label for the 'Context' section of the expense form.
  ///
  /// In es, this message translates to:
  /// **'CONTEXTO'**
  String get expensesFormSectionContextEyebrow;

  /// Context section title when creating an income entry.
  ///
  /// In es, this message translates to:
  /// **'Cuándo y quién lo recibió'**
  String get expensesFormSectionContextTitleIncome;

  /// Context section title when creating an expense entry.
  ///
  /// In es, this message translates to:
  /// **'Cuándo y quién pagó'**
  String get expensesFormSectionContextTitleExpense;

  /// Context section subtitle (same for income and expense).
  ///
  /// In es, this message translates to:
  /// **'Estos datos ordenan el movimiento dentro del hogar.'**
  String get expensesFormSectionContextSubtitle;

  /// Eyebrow label for the 'Category' section of the expense form.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get expensesFormSectionCategoryEyebrow;

  /// Category section title when creating an income entry.
  ///
  /// In es, this message translates to:
  /// **'Cómo querés clasificarlo'**
  String get expensesFormSectionCategoryTitleIncome;

  /// Category section title when creating an expense entry.
  ///
  /// In es, this message translates to:
  /// **'Dónde entra este gasto'**
  String get expensesFormSectionCategoryTitleExpense;

  /// Category section subtitle (same for income and expense).
  ///
  /// In es, this message translates to:
  /// **'Podés elegirla, pero también la sugerimos automáticamente según cómo lo describas.'**
  String get expensesFormSectionCategorySubtitle;

  /// Eyebrow label for the 'Split' section of the expense form.
  ///
  /// In es, this message translates to:
  /// **'REPARTO'**
  String get expensesFormSectionSplitEyebrow;

  /// Split section title when creating an income entry.
  ///
  /// In es, this message translates to:
  /// **'Cómo se reparte este ingreso'**
  String get expensesFormSectionSplitTitleIncome;

  /// Split section title when creating an expense entry.
  ///
  /// In es, this message translates to:
  /// **'Cómo se divide este gasto'**
  String get expensesFormSectionSplitTitleExpense;

  /// Split section subtitle (same for income and expense).
  ///
  /// In es, this message translates to:
  /// **'Definí si es compartido, fijo, regalo o personal.'**
  String get expensesFormSectionSplitSubtitle;

  /// No description provided for @expensesFormFieldDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get expensesFormFieldDate;

  /// No description provided for @expensesFormFieldPayer.
  ///
  /// In es, this message translates to:
  /// **'Pagó'**
  String get expensesFormFieldPayer;

  /// No description provided for @expensesFormFieldCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get expensesFormFieldCategory;

  /// Snackbar shown when user clears all shopping-list linkages from a scanned receipt.
  ///
  /// In es, this message translates to:
  /// **'Vinculaciones removidas'**
  String get expensesFormShoppingUnlinkedSnack;

  /// No description provided for @expensesFormShoppingUnlinkedUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get expensesFormShoppingUnlinkedUndo;

  /// Split mode chip label: shared/equal split.
  ///
  /// In es, this message translates to:
  /// **'Compartido'**
  String get expensesFormSplitShared;

  /// Split mode chip label: 50/50 split.
  ///
  /// In es, this message translates to:
  /// **'50/50'**
  String get expensesFormSplit5050;

  /// Split mode chip label: fixed/per-member amounts.
  ///
  /// In es, this message translates to:
  /// **'Fijo'**
  String get expensesFormSplitFixed;

  /// Split mode chip label: gift (does not affect balance).
  ///
  /// In es, this message translates to:
  /// **'Regalo'**
  String get expensesFormSplitGift;

  /// Split mode chip label: personal (only I).
  ///
  /// In es, this message translates to:
  /// **'Solo yo'**
  String get expensesFormSplitPersonal;

  /// Info box shown when split mode is 'gift'. {memberLabel} is the household-type-aware phrase (e.g. 'with your partner').
  ///
  /// In es, this message translates to:
  /// **'Este gasto no afectará el balance {memberLabel}.'**
  String expensesFormInfoBoxGift(String memberLabel);

  /// Info box shown when split mode is 'personal'.
  ///
  /// In es, this message translates to:
  /// **'Registrado como gasto personal.'**
  String get expensesFormInfoBoxPersonal;

  /// Save button success state label when editing an existing expense.
  ///
  /// In es, this message translates to:
  /// **'Actualizado'**
  String get expensesFormSaveButtonUpdated;

  /// Save button idle label when creating an income entry.
  ///
  /// In es, this message translates to:
  /// **'Guardar ingreso'**
  String get expensesFormSaveButtonSaveIncome;

  /// Save button idle label when creating an expense entry.
  ///
  /// In es, this message translates to:
  /// **'Guardar gasto'**
  String get expensesFormSaveButtonSaveExpense;

  /// Empty state shown when there are no household members to assign as payer.
  ///
  /// In es, this message translates to:
  /// **'No hay miembros disponibles para registrar gastos.'**
  String get expensesFormMembersEmpty;

  /// Hint text in the title field when creating an income entry.
  ///
  /// In es, this message translates to:
  /// **'¿De qué es el ingreso? (Opcional)'**
  String get expensesFormTitleHintIncome;

  /// Hint text in the title field when creating an expense entry.
  ///
  /// In es, this message translates to:
  /// **'¿Qué compraste? (Opcional)'**
  String get expensesFormTitleHintExpense;

  /// Toggle label for 'Expense' type in the form.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get expensesFormTypeExpense;

  /// Toggle label for 'Income' type in the form.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get expensesFormTypeIncome;

  /// No description provided for @expensesFormHeaderEditIncome.
  ///
  /// In es, this message translates to:
  /// **'Modificar Ingreso'**
  String get expensesFormHeaderEditIncome;

  /// No description provided for @expensesFormHeaderEditExpense.
  ///
  /// In es, this message translates to:
  /// **'Modificar Gasto'**
  String get expensesFormHeaderEditExpense;

  /// No description provided for @expensesFormHeaderNewIncome.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Ingreso'**
  String get expensesFormHeaderNewIncome;

  /// No description provided for @expensesFormHeaderNewExpense.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Gasto'**
  String get expensesFormHeaderNewExpense;

  /// No description provided for @allowanceEntryTitle.
  ///
  /// In es, this message translates to:
  /// **'Dar mesada'**
  String get allowanceEntryTitle;

  /// No description provided for @allowanceSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Dar mesada'**
  String get allowanceSheetTitle;

  /// No description provided for @allowanceSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí destinatario y monto. Se registra como ingreso personal.'**
  String get allowanceSheetSubtitle;

  /// No description provided for @allowanceRecipientLabel.
  ///
  /// In es, this message translates to:
  /// **'Para'**
  String get allowanceRecipientLabel;

  /// No description provided for @allowanceAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get allowanceAmountLabel;

  /// No description provided for @allowanceNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Nota opcional, ej: Mesada de junio'**
  String get allowanceNoteHint;

  /// No description provided for @allowanceSubmitButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar mesada'**
  String get allowanceSubmitButton;

  /// No description provided for @allowanceNoRecipients.
  ///
  /// In es, this message translates to:
  /// **'No hay adolescentes con finanzas personales en este hogar.'**
  String get allowanceNoRecipients;

  /// No description provided for @allowanceRecipientRequired.
  ///
  /// In es, this message translates to:
  /// **'Elegí a quién darle la mesada.'**
  String get allowanceRecipientRequired;

  /// No description provided for @allowanceAmountInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un monto válido.'**
  String get allowanceAmountInvalid;

  /// No description provided for @allowanceSendGenericError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar la mesada.'**
  String get allowanceSendGenericError;

  /// Recoverable error shown when household members cannot be loaded in the allowance sheet.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los destinatarios.'**
  String get allowanceMembersLoadError;

  /// Partial-success message shown when the allowance transfer succeeds but its monthly schedule fails.
  ///
  /// In es, this message translates to:
  /// **'La mesada se envió, pero no pudimos programar la repetición.'**
  String get allowanceSentScheduleFailed;

  /// Snackbar shown when disabling an allowance schedule fails.
  ///
  /// In es, this message translates to:
  /// **'No pudimos desactivar la mesada programada. Intentá de nuevo.'**
  String get allowanceScheduleDisableError;

  /// No description provided for @allowanceSentSnack.
  ///
  /// In es, this message translates to:
  /// **'Mesada enviada.'**
  String get allowanceSentSnack;

  /// No description provided for @allowanceSendError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar la mesada: {error}'**
  String allowanceSendError(String error);

  /// No description provided for @expensesFormSelectCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar categoría'**
  String get expensesFormSelectCategoryTitle;

  /// No description provided for @expensesFormAutoTitleSupermarketShopping.
  ///
  /// In es, this message translates to:
  /// **'Compras del supermercado'**
  String get expensesFormAutoTitleSupermarketShopping;

  /// No description provided for @expensesFormShoppingSynced.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 artículo comprado} other{{count} artículos comprados}}'**
  String expensesFormShoppingSynced(int count);

  /// No description provided for @expensesFormShoppingDetectedTitle.
  ///
  /// In es, this message translates to:
  /// **'Productos detectados'**
  String get expensesFormShoppingDetectedTitle;

  /// No description provided for @expensesFormShoppingLinkTitle.
  ///
  /// In es, this message translates to:
  /// **'Vincular con lista de compras'**
  String get expensesFormShoppingLinkTitle;

  /// No description provided for @expensesFormShoppingDetectedSummary.
  ///
  /// In es, this message translates to:
  /// **'{linkedCount, plural, =1{1 artículo} other{{linkedCount} artículos}} · {newCount, plural, =1{1 nuevo para tu lista} other{{newCount} nuevos para tu lista}}'**
  String expensesFormShoppingDetectedSummary(int linkedCount, int newCount);

  /// No description provided for @expensesFormShoppingWillMarkBought.
  ///
  /// In es, this message translates to:
  /// **'Se marcarán como comprados al guardar'**
  String get expensesFormShoppingWillMarkBought;

  /// No description provided for @expensesFormShoppingPreparingProducts.
  ///
  /// In es, this message translates to:
  /// **'Preparando productos...'**
  String get expensesFormShoppingPreparingProducts;

  /// No description provided for @expensesFormShoppingTapToLink.
  ///
  /// In es, this message translates to:
  /// **'Tocá para vincular artículos'**
  String get expensesFormShoppingTapToLink;

  /// No description provided for @expensesFormShoppingClearAllSemantic.
  ///
  /// In es, this message translates to:
  /// **'Quitar todas las vinculaciones'**
  String get expensesFormShoppingClearAllSemantic;

  /// No description provided for @expensesFormShoppingDetectedCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto detectado} other{{count} productos detectados}}'**
  String expensesFormShoppingDetectedCount(int count);

  /// No description provided for @expensesFormShoppingBadgeNew.
  ///
  /// In es, this message translates to:
  /// **'nuevo'**
  String get expensesFormShoppingBadgeNew;

  /// No description provided for @expensesFormShoppingItemsSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Artículos de la lista'**
  String get expensesFormShoppingItemsSheetTitle;

  /// No description provided for @expensesFormShoppingSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar o agregar producto...'**
  String get expensesFormShoppingSearchHint;

  /// No description provided for @expensesFormShoppingAddQuery.
  ///
  /// In es, this message translates to:
  /// **'Agregar \"{query}\"'**
  String expensesFormShoppingAddQuery(String query);

  /// No description provided for @expensesFormShoppingCustomProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto personalizado'**
  String get expensesFormShoppingCustomProduct;

  /// No description provided for @expensesFormShoppingGlobalSuggestions.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias globales'**
  String get expensesFormShoppingGlobalSuggestions;

  /// No description provided for @expensesFormCategorySupermarket.
  ///
  /// In es, this message translates to:
  /// **'Supermercado'**
  String get expensesFormCategorySupermarket;

  /// No description provided for @expensesFormCategoryUtilities.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get expensesFormCategoryUtilities;

  /// No description provided for @expensesFormCategoryRent.
  ///
  /// In es, this message translates to:
  /// **'Alquiler y hogar'**
  String get expensesFormCategoryRent;

  /// No description provided for @expensesFormCategoryRestaurants.
  ///
  /// In es, this message translates to:
  /// **'Salidas y comidas'**
  String get expensesFormCategoryRestaurants;

  /// No description provided for @expensesFormCategoryTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get expensesFormCategoryTransport;

  /// No description provided for @expensesFormCategoryEntertainment.
  ///
  /// In es, this message translates to:
  /// **'Ocio y planes'**
  String get expensesFormCategoryEntertainment;

  /// No description provided for @expensesFormCategoryHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get expensesFormCategoryHealth;

  /// No description provided for @expensesFormCategoryFinances.
  ///
  /// In es, this message translates to:
  /// **'Ahorro e inversión'**
  String get expensesFormCategoryFinances;

  /// No description provided for @expensesFormCategorySettlement.
  ///
  /// In es, this message translates to:
  /// **'Liquidación de balance'**
  String get expensesFormCategorySettlement;

  /// No description provided for @expensesFormCategoryOnlineShopping.
  ///
  /// In es, this message translates to:
  /// **'Compras online'**
  String get expensesFormCategoryOnlineShopping;

  /// No description provided for @expensesFormCategoryPets.
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get expensesFormCategoryPets;

  /// No description provided for @expensesFormCategoryClothing.
  ///
  /// In es, this message translates to:
  /// **'Ropa y calzado'**
  String get expensesFormCategoryClothing;

  /// No description provided for @expensesFormCategoryElectronics.
  ///
  /// In es, this message translates to:
  /// **'Tecnología'**
  String get expensesFormCategoryElectronics;

  /// No description provided for @expensesFormCategoryEducation.
  ///
  /// In es, this message translates to:
  /// **'Educación'**
  String get expensesFormCategoryEducation;

  /// No description provided for @expensesFormCategoryOtherExpenses.
  ///
  /// In es, this message translates to:
  /// **'Otros gastos'**
  String get expensesFormCategoryOtherExpenses;

  /// No description provided for @expensesFormIncomeCategorySalary.
  ///
  /// In es, this message translates to:
  /// **'Sueldo'**
  String get expensesFormIncomeCategorySalary;

  /// No description provided for @expensesFormIncomeCategoryFreelance.
  ///
  /// In es, this message translates to:
  /// **'Freelance'**
  String get expensesFormIncomeCategoryFreelance;

  /// No description provided for @expensesFormIncomeCategorySales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get expensesFormIncomeCategorySales;

  /// No description provided for @expensesFormIncomeCategoryBonus.
  ///
  /// In es, this message translates to:
  /// **'Bono o premio'**
  String get expensesFormIncomeCategoryBonus;

  /// No description provided for @expensesFormIncomeCategoryRefund.
  ///
  /// In es, this message translates to:
  /// **'Reembolso'**
  String get expensesFormIncomeCategoryRefund;

  /// No description provided for @expensesFormIncomeCategoryGift.
  ///
  /// In es, this message translates to:
  /// **'Regalo'**
  String get expensesFormIncomeCategoryGift;

  /// No description provided for @expensesFormIncomeCategoryInvestment.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento'**
  String get expensesFormIncomeCategoryInvestment;

  /// No description provided for @expensesFormIncomeCategoryOtherIncome.
  ///
  /// In es, this message translates to:
  /// **'Otros ingresos'**
  String get expensesFormIncomeCategoryOtherIncome;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllReadTooltip.
  ///
  /// In es, this message translates to:
  /// **'Marcar todo como leído'**
  String get notificationsMarkAllReadTooltip;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin notificaciones'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Estás al día'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus notificaciones'**
  String get notificationsErrorTitle;

  /// No description provided for @notificationsErrorSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Deslizá hacia abajo para reintentar'**
  String get notificationsErrorSubtitle;

  /// No description provided for @premiumPaywallCloseTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get premiumPaywallCloseTooltip;

  /// Short premium paywall badge shown above the title.
  ///
  /// In es, this message translates to:
  /// **'HomeSync Premium'**
  String get premiumPaywallEyebrow;

  /// Badge personalizado del paywall. name es el nombre propio del hogar (ej. 'Casa Pérez') o los nombres de la pareja ('Sofi y Mati').
  ///
  /// In es, this message translates to:
  /// **'Premium · {name}'**
  String premiumPaywallEyebrowFor(String name);

  /// Nombres de los dos miembros de una pareja para el badge del paywall. first = el usuario actual.
  ///
  /// In es, this message translates to:
  /// **'{first} y {second}'**
  String premiumPaywallCoupleNames(String first, String second);

  /// Título del paywall según el tipo de hogar (couple/family/friends/solo). Premium se activa para todo el hogar.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{Un solo plan para los dos} family{Un solo plan para toda la familia} friends{Un solo plan para toda la casa} other{Automatizá tu hogar sin cargar dos veces}}'**
  String premiumPaywallTitle(String type);

  /// Subtítulo del paywall según el tipo de hogar. La suscripción de un miembro activa Premium para todo el hogar.
  ///
  /// In es, this message translates to:
  /// **'{type, select, couple{Paga uno y lo usan los dos: pagos, compras y presupuestos trabajando juntos.} family{Paga uno y lo usa toda la familia, también quienes se sumen después.} friends{Paga uno y lo usan todos en la casa, también quienes se sumen después.} other{Pagos, compras y presupuestos trabajando juntos para que el balance esté siempre claro.}}'**
  String premiumPaywallSubtitle(String type);

  /// Premium benefit title for scheduled or recurring payments.
  ///
  /// In es, this message translates to:
  /// **'Pagos recurrentes'**
  String get premiumBenefitRecurringPayments;

  /// Premium benefit description for scheduled or recurring payments.
  ///
  /// In es, this message translates to:
  /// **'Programá suscripciones, servicios y cuotas para que se repitan solas y no se pierdan en el mes.'**
  String get premiumBenefitRecurringPaymentsDesc;

  /// Premium benefit title for linking shopping list items with finance expenses.
  ///
  /// In es, this message translates to:
  /// **'Compras conectadas a Finanzas'**
  String get premiumBenefitShoppingFinanceSync;

  /// Premium benefit description for linking shopping list items with finance expenses.
  ///
  /// In es, this message translates to:
  /// **'Vinculá productos de la lista con gastos reales y evitá cargar la misma compra dos veces.'**
  String get premiumBenefitShoppingFinanceSyncDesc;

  /// No description provided for @premiumBenefitFullCustomization.
  ///
  /// In es, this message translates to:
  /// **'Personalización completa'**
  String get premiumBenefitFullCustomization;

  /// No description provided for @premiumBenefitFullCustomizationDesc.
  ///
  /// In es, this message translates to:
  /// **'Elegí colores, temas y avatares personalizados para que el hogar se sienta propio.'**
  String get premiumBenefitFullCustomizationDesc;

  /// No description provided for @premiumRestorePurchases.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compras'**
  String get premiumRestorePurchases;

  /// Microcopy de confianza bajo el CTA del paywall
  ///
  /// In es, this message translates to:
  /// **'Cancelá cuando quieras'**
  String get premiumCancelAnytime;

  /// Badge del plan anual. percent se calcula con los precios reales de la tienda; se oculta si no hay plan mensual para comparar.
  ///
  /// In es, this message translates to:
  /// **'Ahorrá {percent}%'**
  String premiumSavePercent(int percent);

  /// No description provided for @premiumChoosePlanTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí tu plan'**
  String get premiumChoosePlanTitle;

  /// No description provided for @premiumAnnualPlan.
  ///
  /// In es, this message translates to:
  /// **'Anual'**
  String get premiumAnnualPlan;

  /// No description provided for @premiumMonthlyPlan.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get premiumMonthlyPlan;

  /// No description provided for @premiumBestValueBadge.
  ///
  /// In es, this message translates to:
  /// **'Mejor valor'**
  String get premiumBestValueBadge;

  /// No description provided for @premiumBilledAnnually.
  ///
  /// In es, this message translates to:
  /// **'Facturado una vez al año'**
  String get premiumBilledAnnually;

  /// No description provided for @premiumBilledMonthly.
  ///
  /// In es, this message translates to:
  /// **'Se renueva mes a mes'**
  String get premiumBilledMonthly;

  /// Shows the equivalent monthly price for an annual subscription.
  ///
  /// In es, this message translates to:
  /// **'{price}/mes'**
  String premiumMonthlyEquivalent(String price);

  /// Botón de compra del paywall con el plan anual elegido. price es el precio de la tienda ya formateado.
  ///
  /// In es, this message translates to:
  /// **'Activar Premium · {price}/año'**
  String premiumActivateAnnualCta(String price);

  /// Botón de compra del paywall con el plan mensual elegido. price es el precio de la tienda ya formateado.
  ///
  /// In es, this message translates to:
  /// **'Activar Premium · {price}/mes'**
  String premiumActivateMonthlyCta(String price);

  /// Link corto a los Términos de uso, debajo del botón de compra.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get premiumLegalTerms;

  /// Link corto a la Política de privacidad, debajo del botón de compra.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get premiumLegalPrivacy;

  /// No description provided for @premiumAlreadyActiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Premium activo en tu hogar'**
  String get premiumAlreadyActiveTitle;

  /// No description provided for @premiumAlreadyActiveBody.
  ///
  /// In es, this message translates to:
  /// **'Todo listo: las funciones premium ya están disponibles para este hogar.'**
  String get premiumAlreadyActiveBody;

  /// No description provided for @premiumActiveStatusPill.
  ///
  /// In es, this message translates to:
  /// **'Plan activo'**
  String get premiumActiveStatusPill;

  /// No description provided for @premiumActiveBenefitsTitle.
  ///
  /// In es, this message translates to:
  /// **'Beneficios habilitados'**
  String get premiumActiveBenefitsTitle;

  /// No description provided for @premiumContinueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get premiumContinueButton;

  /// No description provided for @premiumDeactivateTesting.
  ///
  /// In es, this message translates to:
  /// **'Desactivar Premium (testing)'**
  String get premiumDeactivateTesting;

  /// No description provided for @premiumStoreErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar con la tienda'**
  String get premiumStoreErrorTitle;

  /// No description provided for @premiumDeveloperModeButton.
  ///
  /// In es, this message translates to:
  /// **'Modo Desarrollador: Activar Premium'**
  String get premiumDeveloperModeButton;

  /// No description provided for @faqSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas Frecuentes'**
  String get faqSheetTitle;

  /// No description provided for @faqSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ayuda pensada para tu hogar'**
  String get faqSheetSubtitle;

  /// No description provided for @faqSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscá una pregunta...'**
  String get faqSearchHint;

  /// No description provided for @faqSearchEmpty.
  ///
  /// In es, this message translates to:
  /// **'No encontramos nada con esa búsqueda. Probá con otra palabra o contanos desde “Enviar feedback”.'**
  String get faqSearchEmpty;

  /// No description provided for @faqContextPill.
  ///
  /// In es, this message translates to:
  /// **'Ayuda para: {label}'**
  String faqContextPill(String label);

  /// No description provided for @faqCatHousehold.
  ///
  /// In es, this message translates to:
  /// **'Tu hogar'**
  String get faqCatHousehold;

  /// No description provided for @faqCatTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get faqCatTasks;

  /// No description provided for @faqCatRewards.
  ///
  /// In es, this message translates to:
  /// **'Puntos y premios'**
  String get faqCatRewards;

  /// No description provided for @faqCatFinances.
  ///
  /// In es, this message translates to:
  /// **'Finanzas'**
  String get faqCatFinances;

  /// No description provided for @faqCatApp.
  ///
  /// In es, this message translates to:
  /// **'La app y tu cuenta'**
  String get faqCatApp;

  /// No description provided for @faqHowSharedHome.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funciona mi hogar en HomeSync?'**
  String get faqHowSharedHome;

  /// No description provided for @faqHowSharedHomeAnswer.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{Vos y tu pareja comparten un mismo hogar digital: tareas, gastos, lista de compras y ahorros viven en un solo lugar y se sincronizan al instante. Lo que carga uno, el otro lo ve al toque.} family{Toda la familia comparte un mismo hogar digital. Cada miembro tiene su rol (padre, madre, tutor/a, adolescente o hijo/a) y la app adapta lo que cada uno ve y puede hacer: los adultos administran, los chicos suman completando tareas.} friends{Quienes conviven comparten tareas, gastos y compras en un solo lugar, entre pares: sin jerarquías ni premios infantiles, solo un reparto claro de lo que cada uno aporta.} solo{Tu hogar es tu espacio personal: organizás tus tareas, tus gastos y tu lista de compras a tu ritmo. Si más adelante convivís con alguien, lo invitás con un código y listo.} other{Comparten un mismo hogar digital: tareas, gastos, compras y ahorros sincronizados al instante entre todos los miembros.}}'**
  String faqHowSharedHomeAnswer(String mode);

  /// No description provided for @faqInviteMembers.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo invito a alguien a mi hogar?'**
  String get faqInviteMembers;

  /// No description provided for @faqInviteMembersAnswer.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, family{En Configuración está el código de invitación de tu hogar: compartilo y, al ingresarlo en su app, esa persona entra con todo sincronizado. Después, desde la lista de miembros, los adultos le asignan su rol (padre, madre, tutor/a, adolescente o hijo/a).} other{En Configuración está el código de invitación de tu hogar: compartilo con quien quieras sumar y, al ingresarlo en su app, entra directo con tareas, gastos y compras sincronizados.}}'**
  String faqInviteMembersAnswer(String mode);

  /// No description provided for @faqFamilyRoles.
  ///
  /// In es, this message translates to:
  /// **'¿Qué significan los roles de la familia?'**
  String get faqFamilyRoles;

  /// No description provided for @faqFamilyRolesAnswer.
  ///
  /// In es, this message translates to:
  /// **'Padre, madre y tutor/a son los adultos: administran el hogar, aprueban tareas, manejan las finanzas compartidas y la tienda de premios. Los adolescentes tienen más autonomía y su propio espacio de finanzas personales. Los hijos e hijas viven la experiencia más simple y divertida: completan tareas, juntan coins y canjean premios.'**
  String get faqFamilyRolesAnswer;

  /// No description provided for @faqWhoSeesWhat.
  ///
  /// In es, this message translates to:
  /// **'¿Qué ve cada miembro del hogar?'**
  String get faqWhoSeesWhat;

  /// No description provided for @faqWhoSeesWhatAnswer.
  ///
  /// In es, this message translates to:
  /// **'Cada rol ve lo que le corresponde: los adultos ven todo, incluidas las finanzas compartidas; los adolescentes ven sus finanzas personales pero no los gastos de los adultos; y los hijos/as no ven finanzas — su mundo son las tareas, los puntos y los premios.'**
  String get faqWhoSeesWhatAnswer;

  /// No description provided for @faqTasksBasics.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funcionan las tareas?'**
  String get faqTasksBasics;

  /// No description provided for @faqTasksBasicsAnswer.
  ///
  /// In es, this message translates to:
  /// **'Creá tareas puntuales o recurrentes (diarias, semanales, mensuales), asignalas a alguien o dejalas libres para quien las agarre. El calendario muestra lo que viene y las recurrentes se reprograman solas. En Pareja, completarlas actualiza el progreso compartido sin XP ni coins.'**
  String get faqTasksBasicsAnswer;

  /// No description provided for @faqApprovals.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funcionan las aprobaciones de tareas?'**
  String get faqApprovals;

  /// No description provided for @faqApprovalsAnswer.
  ///
  /// In es, this message translates to:
  /// **'{role, select, parent{Cuando un hijo/a o adolescente marca una tarea como hecha, queda pendiente de tu aprobación: la revisás desde Aprobaciones y, al confirmarla, recién ahí se acreditan los XP y coins. Quién necesita aprobación se ajusta en la configuración del hogar.} teen{Según cómo esté configurado el hogar, al marcar una tarea como hecha puede quedar pendiente hasta que un adulto la confirme. Recién ahí se te acreditan los XP y coins.} child{Cuando marcás una tarea como hecha, un adulto la revisa y la confirma. ¡Apenas la apruebe te llegan los XP y los coins!} other{Las tareas de hijos/as y adolescentes pueden requerir la confirmación de un adulto antes de acreditar XP y coins, según la configuración del hogar.}}'**
  String faqApprovalsAnswer(String role);

  /// No description provided for @faqHowEarnXp.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo gano XP y subo de nivel?'**
  String get faqHowEarnXp;

  /// No description provided for @faqHowEarnXpAnswer.
  ///
  /// In es, this message translates to:
  /// **'Cada tarea completada suma XP (las más difíciles dan más). Con el XP subís de nivel y desbloqueás logros: medallas por hitos como completar 50 tareas. Todo tu progreso se ve en Estadísticas.'**
  String get faqHowEarnXpAnswer;

  /// No description provided for @faqWhatCoins.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué sirven los Coins?'**
  String get faqWhatCoins;

  /// No description provided for @faqWhatCoinsAnswer.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, family{Los coins son la moneda del hogar: los chicos los ganan completando tareas y los canjean en la tienda de premios por las recompensas que crearon los adultos — una salida, tiempo de pantalla, su comida favorita.} other{En modo Pareja no se usan coins: las tareas muestran cómo se reparte el trabajo y las propuestas se conversan sin precio, deuda ni obligación. Los coins quedan reservados para la dinámica familiar con chicos.}}'**
  String faqWhatCoinsAnswer(String mode);

  /// No description provided for @faqWhatWeeklyDuels.
  ///
  /// In es, this message translates to:
  /// **'¿Hay un duelo semanal en Pareja?'**
  String get faqWhatWeeklyDuels;

  /// No description provided for @faqWhatWeeklyDuelsAnswer.
  ///
  /// In es, this message translates to:
  /// **'No. En modo Pareja la semana se mira como un esfuerzo compartido: pueden ver cuántas tareas hicieron y cómo se repartieron, sin ganador, marcador ni bonus.'**
  String get faqWhatWeeklyDuelsAnswer;

  /// No description provided for @faqFamilyRanking.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funciona el ranking familiar?'**
  String get faqFamilyRanking;

  /// No description provided for @faqFamilyRankingAnswer.
  ///
  /// In es, this message translates to:
  /// **'Cada semana la familia compite sano: el ranking muestra quién sumó más XP completando tareas. Al cierre hay un ganador con corona y bonus, y el resumen semanal les cuenta cómo le fue a cada uno.'**
  String get faqFamilyRankingAnswer;

  /// No description provided for @faqWhatSpecialEvents.
  ///
  /// In es, this message translates to:
  /// **'¿Qué hay en la pestaña Pareja?'**
  String get faqWhatSpecialEvents;

  /// No description provided for @faqWhatSpecialEventsAnswer.
  ///
  /// In es, this message translates to:
  /// **'Es el repaso de la semana de los dos: cómo se repartieron las tareas (sin ganadores), cómo está la plata entre ustedes y las propuestas pendientes. Si algo cayó siempre del mismo lado, te sugiere proponer turnarse. También podés mandarle una nota a tu pareja.'**
  String get faqWhatSpecialEventsAnswer;

  /// No description provided for @faqContributionBalance.
  ///
  /// In es, this message translates to:
  /// **'¿Qué es el equilibrio de aporte?'**
  String get faqContributionBalance;

  /// No description provided for @faqContributionBalanceAnswer.
  ///
  /// In es, this message translates to:
  /// **'Es la foto neutral del mes: combina tareas hechas y gastos compartidos para mostrar cuánto viene aportando cada uno a la convivencia. Sin ganadores ni perdedores — sirve para charlar con datos, no para competir.'**
  String get faqContributionBalanceAnswer;

  /// No description provided for @faqRewardsStore.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funciona la tienda de premios?'**
  String get faqRewardsStore;

  /// No description provided for @faqRewardsStoreAnswer.
  ///
  /// In es, this message translates to:
  /// **'{role, select, parent{Vos creás los premios (una salida, tiempo de juego, su postre favorito) y les ponés un precio en coins. Los chicos los canjean con lo que ganaron completando tareas, y vos confirmás el canje.} other{En la tienda están los premios que crearon los adultos del hogar. Juntá coins completando tareas y canjealos cuando te alcance: el premio queda pendiente hasta que un adulto lo confirme.}}'**
  String faqRewardsStoreAnswer(String role);

  /// No description provided for @faqHowFinancesWork.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funcionan las finanzas?'**
  String get faqHowFinancesWork;

  /// No description provided for @faqHowFinancesWorkAnswer.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, friends{Cada gasto compartido se divide según lo que configuren (partes iguales o porcentajes). El balance muestra quién está al día y quién debe, y cualquiera puede registrar un pago para saldar cuentas.} family{Las finanzas compartidas son territorio de los adultos: los gastos del hogar se dividen entre ellos. Los adolescentes tienen su espacio personal de finanzas, separado de las cuentas grandes.} other{Registrás gastos reales y también anticipás gastos que todavía no pagaste. Los confirmados afectan el balance real entre ustedes; los pendientes sirven de recordatorio y proyección, pero no cambian la deuda hasta que se paguen.}}'**
  String faqHowFinancesWorkAnswer(String mode);

  /// No description provided for @faqHowRecurringCount.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo cuentan los recurrentes y el balance estimado?'**
  String get faqHowRecurringCount;

  /// No description provided for @faqHowRecurringCountAnswer.
  ///
  /// In es, this message translates to:
  /// **'Un gasto recurrente nuevo arranca desde su primera fecha válida. Si lo creás antes o en la fecha de vencimiento, puede contar este mes; si lo creás después, arranca en el próximo ciclo. “Tu parte pendiente” muestra solo lo que te corresponde según la división, y “Balance estimado” usa tu balance actual menos esa parte pendiente.'**
  String get faqHowRecurringCountAnswer;

  /// No description provided for @faqWhoCanPay.
  ///
  /// In es, this message translates to:
  /// **'¿Quién puede registrar un pago?'**
  String get faqWhoCanPay;

  /// No description provided for @faqWhoCanPayAnswer.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera de los dos lados puede registrar un pago compartido, incluso en nombre del otro — útil cuando uno paga y el otro lo carga. “Pagado” y “Pendiente” muestran siempre el total del hogar, así todos ven la misma foto.'**
  String get faqWhoCanPayAnswer;

  /// No description provided for @faqSavingsGoals.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funcionan las metas de ahorro?'**
  String get faqSavingsGoals;

  /// No description provided for @faqSavingsGoalsAnswer.
  ///
  /// In es, this message translates to:
  /// **'Creás una meta con su monto objetivo (un viaje, un fondo de emergencia) y vas registrando aportes. El progreso se ve clarito y, en hogares compartidos, todos pueden aportar a la misma meta.'**
  String get faqSavingsGoalsAnswer;

  /// No description provided for @faqPremium.
  ///
  /// In es, this message translates to:
  /// **'¿Qué incluye HomeSync Premium?'**
  String get faqPremium;

  /// No description provided for @faqPremiumAnswer.
  ///
  /// In es, this message translates to:
  /// **'Premium se activa para todo el hogar con una sola compra: mascotas premium animadas, colores de tema exclusivos y todo lo que vayamos sumando. Se gestiona desde Configuración y solo los adultos pueden comprarlo.'**
  String get faqPremiumAnswer;

  /// No description provided for @faqCustomization.
  ///
  /// In es, this message translates to:
  /// **'¿Puedo personalizar la app?'**
  String get faqCustomization;

  /// No description provided for @faqCustomizationAnswer.
  ///
  /// In es, this message translates to:
  /// **'Sí: tema claro, oscuro o automático según el sistema, color principal (con Premium), idioma (español o inglés) y la moneda en que se muestran las finanzas. Todo desde Configuración → Apariencia.'**
  String get faqCustomizationAnswer;

  /// No description provided for @faqNotifications.
  ///
  /// In es, this message translates to:
  /// **'¿Qué notificaciones llegan?'**
  String get faqNotifications;

  /// No description provided for @faqNotificationsAnswer.
  ///
  /// In es, this message translates to:
  /// **'Avisos de lo que pasa en tu hogar: tareas que te asignan, novedades de gastos y aprobaciones pendientes. Podés activarlas o silenciarlas desde Configuración → Notificaciones.'**
  String get faqNotificationsAnswer;

  /// No description provided for @faqAccountSafety.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo cuido mi cuenta y mis datos?'**
  String get faqAccountSafety;

  /// No description provided for @faqAccountSafetyAnswer.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión es personal: cerrala cuando quieras desde Configuración. Si necesitás empezar de cero, “Reiniciar datos” borra el contenido del hogar, y “Eliminar mi cuenta” la elimina definitivamente. Tus datos viven cifrados en la nube y solo los miembros de tu hogar ven lo que comparten.'**
  String get faqAccountSafetyAnswer;

  /// No description provided for @feedbackThanksBug.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por reportarlo!'**
  String get feedbackThanksBug;

  /// No description provided for @feedbackThanksSuggestion.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por la idea!'**
  String get feedbackThanksSuggestion;

  /// No description provided for @feedbackReviewBug.
  ///
  /// In es, this message translates to:
  /// **'Lo vamos a revisar en breve.'**
  String get feedbackReviewBug;

  /// No description provided for @feedbackConsiderSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Lo vamos a tener en cuenta.'**
  String get feedbackConsiderSuggestion;

  /// No description provided for @feedbackSendError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar. Intentá de nuevo.'**
  String get feedbackSendError;

  /// No description provided for @feedbackBugTitlePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasó?'**
  String get feedbackBugTitlePlaceholder;

  /// No description provided for @feedbackSuggestionTitlePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'¿Qué mejorarías?'**
  String get feedbackSuggestionTitlePlaceholder;

  /// No description provided for @feedbackBugHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: La pantalla de gastos no carga'**
  String get feedbackBugHint;

  /// No description provided for @feedbackSuggestionHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Filtrar tareas por semana'**
  String get feedbackSuggestionHint;

  /// No description provided for @feedbackBugDescHint.
  ///
  /// In es, this message translates to:
  /// **'Descripción opcional: pasos para reproducirlo, qué esperabas ver...'**
  String get feedbackBugDescHint;

  /// No description provided for @feedbackSuggestionDescHint.
  ///
  /// In es, this message translates to:
  /// **'Descripción opcional: contexto, por qué sería útil...'**
  String get feedbackSuggestionDescHint;

  /// Toggle label in the feedback form. Enabled by default. User can turn it off if they do not want email follow-up.
  ///
  /// In es, this message translates to:
  /// **'Quiero recibir respuesta por mail'**
  String get feedbackEmailResponseTitle;

  /// Toggle subtitle in the feedback form explaining that follow-up replies will be sent to the user's registered email.
  ///
  /// In es, this message translates to:
  /// **'Te escribiremos a tu correo si necesitamos más contexto o tenemos novedades.'**
  String get feedbackEmailResponseSubtitle;

  /// No description provided for @feedbackSendBugReport.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get feedbackSendBugReport;

  /// No description provided for @feedbackSendSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Enviar sugerencia'**
  String get feedbackSendSuggestion;

  /// No description provided for @feedbackReportErrorOption.
  ///
  /// In es, this message translates to:
  /// **'Reportar error'**
  String get feedbackReportErrorOption;

  /// No description provided for @feedbackSuggestImprovementOption.
  ///
  /// In es, this message translates to:
  /// **'Sugerir mejora'**
  String get feedbackSuggestImprovementOption;

  /// No description provided for @membersTitle.
  ///
  /// In es, this message translates to:
  /// **'Miembros'**
  String get membersTitle;

  /// No description provided for @membersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 persona en tu hogar} other{{count} personas en tu hogar}}'**
  String membersSubtitle(num count);

  /// No description provided for @membersAdminBadge.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get membersAdminBadge;

  /// Title of the role picker sheet for a member.
  ///
  /// In es, this message translates to:
  /// **'Rol de {memberName}'**
  String membersRolePickerTitle(String memberName);

  /// No description provided for @membersRolePickerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Padres y tutores pueden aprobar tareas. Adolescentes y chicos envían sus tareas para revisión.'**
  String get membersRolePickerSubtitle;

  /// No description provided for @membersRoleParent.
  ///
  /// In es, this message translates to:
  /// **'Padre/Madre'**
  String get membersRoleParent;

  /// No description provided for @membersRoleGuardian.
  ///
  /// In es, this message translates to:
  /// **'Tutor/a'**
  String get membersRoleGuardian;

  /// No description provided for @membersRoleTeen.
  ///
  /// In es, this message translates to:
  /// **'Adolescente'**
  String get membersRoleTeen;

  /// No description provided for @membersRoleChild.
  ///
  /// In es, this message translates to:
  /// **'Chico/a'**
  String get membersRoleChild;

  /// No description provided for @membersRoleFather.
  ///
  /// In es, this message translates to:
  /// **'Padre'**
  String get membersRoleFather;

  /// No description provided for @membersRoleMother.
  ///
  /// In es, this message translates to:
  /// **'Madre'**
  String get membersRoleMother;

  /// No description provided for @membersRoleDad.
  ///
  /// In es, this message translates to:
  /// **'Papá'**
  String get membersRoleDad;

  /// No description provided for @membersRoleMom.
  ///
  /// In es, this message translates to:
  /// **'Mamá'**
  String get membersRoleMom;

  /// No description provided for @membersRoleGuardianMale.
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get membersRoleGuardianMale;

  /// No description provided for @membersRoleGuardianFemale.
  ///
  /// In es, this message translates to:
  /// **'Tutora'**
  String get membersRoleGuardianFemale;

  /// No description provided for @membersRoleSon.
  ///
  /// In es, this message translates to:
  /// **'Hijo'**
  String get membersRoleSon;

  /// No description provided for @membersRoleDaughter.
  ///
  /// In es, this message translates to:
  /// **'Hija'**
  String get membersRoleDaughter;

  /// No description provided for @membersRoleParentGuardianDesc.
  ///
  /// In es, this message translates to:
  /// **'Aprueba tareas, administra el hogar.'**
  String get membersRoleParentGuardianDesc;

  /// No description provided for @membersRoleTeenDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea sus tareas, pero las completa bajo revisión.'**
  String get membersRoleTeenDesc;

  /// No description provided for @membersRoleChildDesc.
  ///
  /// In es, this message translates to:
  /// **'Solo completa sus tareas, siempre bajo revisión.'**
  String get membersRoleChildDesc;

  /// Mensaje seguro cuando falla la actualización del rol de un integrante.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cambiar el rol. Intentá de nuevo.'**
  String get membersRoleUpdateError;

  /// No description provided for @membersRoleUpdated.
  ///
  /// In es, this message translates to:
  /// **'Rol actualizado'**
  String get membersRoleUpdated;

  /// Estado de error recuperable cuando no se puede cargar la lista de integrantes.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los integrantes del hogar.'**
  String get membersLoadError;

  /// Mensaje seguro cuando falla la creación del hogar o de su código de invitación.
  ///
  /// In es, this message translates to:
  /// **'No pudimos crear el hogar o generar el código. Intentá de nuevo.'**
  String get setupCreateHouseholdError;

  /// Validación mostrada cuando el código de invitación no tiene seis caracteres.
  ///
  /// In es, this message translates to:
  /// **'El código debe tener 6 caracteres.'**
  String get setupJoinCodeLengthError;

  /// Mensaje seguro cuando falla la unión a un hogar mediante código.
  ///
  /// In es, this message translates to:
  /// **'No pudimos unirte al hogar. Revisá el código e intentá de nuevo.'**
  String get setupJoinHouseholdError;

  /// Mensaje seguro cuando falla la finalización del setup inicial.
  ///
  /// In es, this message translates to:
  /// **'No pudimos terminar la configuración. Intentá de nuevo.'**
  String get setupCompleteError;

  /// No description provided for @membersInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitar miembro'**
  String get membersInviteTitle;

  /// No description provided for @membersInviteSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agregá otra persona al hogar con un código de invitación.'**
  String get membersInviteSubtitle;

  /// No description provided for @shoppingSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Necesito...'**
  String get shoppingSearchHint;

  /// No description provided for @shoppingListTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista actual'**
  String get shoppingListTitle;

  /// No description provided for @shoppingAllDone.
  ///
  /// In es, this message translates to:
  /// **'Todo listo'**
  String get shoppingAllDone;

  /// No description provided for @shoppingListResolved.
  ///
  /// In es, this message translates to:
  /// **'Lista resuelta'**
  String get shoppingListResolved;

  /// No description provided for @shoppingEmptyFirstLineDone.
  ///
  /// In es, this message translates to:
  /// **'La lista está vacía.\n¿Qué falta en casa?'**
  String get shoppingEmptyFirstLineDone;

  /// No description provided for @shoppingEmptyFirstLineBought.
  ///
  /// In es, this message translates to:
  /// **'Todo comprado.\n¿Querés agregar algo más?'**
  String get shoppingEmptyFirstLineBought;

  /// No description provided for @shoppingEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Agregá productos usando las categorías\no la barra de búsqueda abajo.'**
  String get shoppingEmptyHint;

  /// No description provided for @shoppingRecentSection.
  ///
  /// In es, this message translates to:
  /// **'Comprar de nuevo'**
  String get shoppingRecentSection;

  /// No description provided for @shoppingCategoriesSection.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get shoppingCategoriesSection;

  /// No description provided for @shoppingProductsBought.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 artículo comprado} other{{count} artículos comprados}}'**
  String shoppingProductsBought(int count);

  /// No description provided for @shoppingScanReceipt.
  ///
  /// In es, this message translates to:
  /// **'Escanear ticket y registrar gasto'**
  String get shoppingScanReceipt;

  /// No description provided for @shoppingItemNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto'**
  String get shoppingItemNameHint;

  /// No description provided for @shoppingDeleteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get shoppingDeleteTooltip;

  /// No description provided for @shoppingCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get shoppingCategoryLabel;

  /// No description provided for @shoppingAddToList.
  ///
  /// In es, this message translates to:
  /// **'Agregar a la lista'**
  String get shoppingAddToList;

  /// No description provided for @shoppingSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get shoppingSaveChanges;

  /// No description provided for @rewardsTabDuel.
  ///
  /// In es, this message translates to:
  /// **'Duelo'**
  String get rewardsTabDuel;

  /// No description provided for @rewardsTabPrizes.
  ///
  /// In es, this message translates to:
  /// **'Premios'**
  String get rewardsTabPrizes;

  /// No description provided for @rewardsLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get rewardsLoadMore;

  /// No description provided for @rewardsLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando premios...'**
  String get rewardsLoading;

  /// No description provided for @rewardsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar premios.\n{error}'**
  String rewardsLoadError(String error);

  /// No description provided for @rewardsProposalsSection.
  ///
  /// In es, this message translates to:
  /// **'Propuestas'**
  String get rewardsProposalsSection;

  /// No description provided for @rewardsPendingApproval.
  ///
  /// In es, this message translates to:
  /// **'Deseos pendientes de aprobación. Tocá una propuesta para revisarla.'**
  String get rewardsPendingApproval;

  /// No description provided for @rewardsStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get rewardsStatusPending;

  /// No description provided for @rewardsStatusReview.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get rewardsStatusReview;

  /// No description provided for @rewardsPendingRedemptionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Canjes por entregar'**
  String get rewardsPendingRedemptionsTitle;

  /// No description provided for @rewardsPendingRedemptionsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Premios ya canjeados que faltan entregar.'**
  String get rewardsPendingRedemptionsSubtitle;

  /// No description provided for @rewardsRedeemedByOn.
  ///
  /// In es, this message translates to:
  /// **'Canjeado por {name} · {date}'**
  String rewardsRedeemedByOn(String name, String date);

  /// No description provided for @rewardsRedeemedByYouOn.
  ///
  /// In es, this message translates to:
  /// **'Lo canjeaste el {date}'**
  String rewardsRedeemedByYouOn(String date);

  /// No description provided for @rewardsWaitingFulfillment.
  ///
  /// In es, this message translates to:
  /// **'En camino'**
  String get rewardsWaitingFulfillment;

  /// No description provided for @rewardsMarkFulfilled.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get rewardsMarkFulfilled;

  /// No description provided for @rewardsFulfillConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Premio entregado?'**
  String get rewardsFulfillConfirmTitle;

  /// No description provided for @rewardsFulfillConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Vas a marcar \"{title}\" como entregado para {name}.'**
  String rewardsFulfillConfirmBody(String title, String name);

  /// No description provided for @rewardsFulfilledSnack.
  ///
  /// In es, this message translates to:
  /// **'Marcaste \"{title}\" como entregado.'**
  String rewardsFulfilledSnack(String title);

  /// No description provided for @rewardsMemberFallbackName.
  ///
  /// In es, this message translates to:
  /// **'Miembro'**
  String get rewardsMemberFallbackName;

  /// No description provided for @rewardsWaitingPartnerDecision.
  ///
  /// In es, this message translates to:
  /// **'Esperando una decisión de tu pareja.'**
  String get rewardsWaitingPartnerDecision;

  /// No description provided for @rewardsCoinsAvailable.
  ///
  /// In es, this message translates to:
  /// **'{count} coins disponibles'**
  String rewardsCoinsAvailable(int count);

  /// No description provided for @rewardsCoinsAvailableShort.
  ///
  /// In es, this message translates to:
  /// **'{count} coins'**
  String rewardsCoinsAvailableShort(int count);

  /// No description provided for @rewardsCoinsAvailableToRedeem.
  ///
  /// In es, this message translates to:
  /// **'Disponibles para canjear ahora'**
  String get rewardsCoinsAvailableToRedeem;

  /// No description provided for @rewardsBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo'**
  String get rewardsBalance;

  /// No description provided for @rewardsDeleteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar recompensa'**
  String get rewardsDeleteTooltip;

  /// No description provided for @rewardsEmptyBoutique.
  ///
  /// In es, this message translates to:
  /// **'Boutique vacía'**
  String get rewardsEmptyBoutique;

  /// No description provided for @rewardsEmptyNoPrizes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay premios cargados en esta casa.'**
  String get rewardsEmptyNoPrizes;

  /// No description provided for @rewardsLoadSuggested.
  ///
  /// In es, this message translates to:
  /// **'Cargar premios sugeridos'**
  String get rewardsLoadSuggested;

  /// No description provided for @rewardsOrCreateCustom.
  ///
  /// In es, this message translates to:
  /// **'O crear un premio personalizado'**
  String get rewardsOrCreateCustom;

  /// No description provided for @rewardsAddNewDesirePrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Querés sumar un deseo nuevo?'**
  String get rewardsAddNewDesirePrompt;

  /// No description provided for @rewardsAddNewDesireHint.
  ///
  /// In es, this message translates to:
  /// **'Proponelo y tu compañero podrá aprobarlo para que aparezca en la tienda.'**
  String get rewardsAddNewDesireHint;

  /// No description provided for @rewardsSuggestNewDesire.
  ///
  /// In es, this message translates to:
  /// **'Proponer un deseo nuevo'**
  String get rewardsSuggestNewDesire;

  /// No description provided for @rewardsSeedNothingNew.
  ///
  /// In es, this message translates to:
  /// **'Ya hay premios o propuestas cargadas en esta casa.'**
  String get rewardsSeedNothingNew;

  /// No description provided for @rewardsNoteOptionalLabel.
  ///
  /// In es, this message translates to:
  /// **'NOTA (OPCIONAL)'**
  String get rewardsNoteOptionalLabel;

  /// No description provided for @rewardsSendProposal.
  ///
  /// In es, this message translates to:
  /// **'Enviar propuesta'**
  String get rewardsSendProposal;

  /// No description provided for @rewardsCreatePrize.
  ///
  /// In es, this message translates to:
  /// **'Crear premio'**
  String get rewardsCreatePrize;

  /// No description provided for @rewardsProposalSentToast.
  ///
  /// In es, this message translates to:
  /// **'Propuesta enviada.'**
  String get rewardsProposalSentToast;

  /// No description provided for @rewardsPrizeCreatedToast.
  ///
  /// In es, this message translates to:
  /// **'Premio creado con éxito.'**
  String get rewardsPrizeCreatedToast;

  /// No description provided for @rewardsEmptyNoChildStore.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay premios en tu tienda.'**
  String get rewardsEmptyNoChildStore;

  /// No description provided for @rewardsNotYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no'**
  String get rewardsNotYet;

  /// No description provided for @rewardsYesWeDid.
  ///
  /// In es, this message translates to:
  /// **'Sí, lo hicimos'**
  String get rewardsYesWeDid;

  /// No description provided for @rewardsDeletePrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar premio?'**
  String get rewardsDeletePrompt;

  /// No description provided for @rewardsDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{title}\" de la boutique.'**
  String rewardsDeleteBody(String title);

  /// No description provided for @rewardsInsufficientCoins.
  ///
  /// In es, this message translates to:
  /// **'Coins insuficientes. A completar tareas.'**
  String get rewardsInsufficientCoins;

  /// No description provided for @rewardsRedeemPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Canjear este premio?'**
  String get rewardsRedeemPrompt;

  /// No description provided for @rewardsRedeem.
  ///
  /// In es, this message translates to:
  /// **'Canjear'**
  String get rewardsRedeem;

  /// No description provided for @rewardsRedeemed.
  ///
  /// In es, this message translates to:
  /// **'Premio canjeado'**
  String get rewardsRedeemed;

  /// No description provided for @rewardsRedeemedBody.
  ///
  /// In es, this message translates to:
  /// **'Disfrutá de \"{title}\". El amor también vive en los pequeños detalles.'**
  String rewardsRedeemedBody(String title);

  /// No description provided for @rewardsApprovalReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo para aprobarlo'**
  String get rewardsApprovalReason;

  /// No description provided for @rewardsCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo: {cost} coins'**
  String rewardsCostLabel(int cost);

  /// No description provided for @rewardsSuggestTitle.
  ///
  /// In es, this message translates to:
  /// **'Proponer un deseo'**
  String get rewardsSuggestTitle;

  /// No description provided for @rewardsNewHouseReward.
  ///
  /// In es, this message translates to:
  /// **'Nuevo premio de la casa'**
  String get rewardsNewHouseReward;

  /// No description provided for @rewardsTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'TÍTULO'**
  String get rewardsTitleLabel;

  /// No description provided for @rewardsReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'POR QUÉ DEBERÍA APROBARLO'**
  String get rewardsReasonLabel;

  /// No description provided for @rewardsDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'DESCRIPCIÓN'**
  String get rewardsDescriptionLabel;

  /// No description provided for @rewardsCostFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'COSTO'**
  String get rewardsCostFieldLabel;

  /// No description provided for @rewardsCategoryFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get rewardsCategoryFieldLabel;

  /// No description provided for @rewardsCostHint.
  ///
  /// In es, this message translates to:
  /// **'Costo en coins'**
  String get rewardsCostHint;

  /// No description provided for @rewardsPendingReview.
  ///
  /// In es, this message translates to:
  /// **'Pendientes de aprobación'**
  String get rewardsPendingReview;

  /// No description provided for @rewardsPendingReviewSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Premios propuestos que todavía necesitan decisión.'**
  String get rewardsPendingReviewSubtitle;

  /// No description provided for @rewardsForKids.
  ///
  /// In es, this message translates to:
  /// **'Premios para chicos'**
  String get rewardsForKids;

  /// No description provided for @rewardsForKidsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recompensas pensadas para motivar y celebrar avances.'**
  String get rewardsForKidsSubtitle;

  /// No description provided for @rewardsForAdults.
  ///
  /// In es, this message translates to:
  /// **'Premios para adultos'**
  String get rewardsForAdults;

  /// No description provided for @rewardsForAdultsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mimos y recompensas pensados para los adultos de la casa.'**
  String get rewardsForAdultsSubtitle;

  /// No description provided for @rewardsFamilyPlans.
  ///
  /// In es, this message translates to:
  /// **'Planes familiares'**
  String get rewardsFamilyPlans;

  /// No description provided for @rewardsFamilyPlansSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Premios y salidas para disfrutar entre todos.'**
  String get rewardsFamilyPlansSubtitle;

  /// No description provided for @rewardsForYou.
  ///
  /// In es, this message translates to:
  /// **'Premios para vos'**
  String get rewardsForYou;

  /// No description provided for @rewardsForYouSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí qué querés conseguir con tus coins.'**
  String get rewardsForYouSubtitle;

  /// No description provided for @rewardsPlansTogether.
  ///
  /// In es, this message translates to:
  /// **'Planes en familia'**
  String get rewardsPlansTogether;

  /// No description provided for @rewardsPlansTogetherSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Premios para disfrutar juntos.'**
  String get rewardsPlansTogetherSubtitle;

  /// No description provided for @rewardsChildStoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi tienda'**
  String get rewardsChildStoreTitle;

  /// No description provided for @rewardsFamilyStoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienda del hogar'**
  String get rewardsFamilyStoreTitle;

  /// No description provided for @rewardsNewPrizeLabel.
  ///
  /// In es, this message translates to:
  /// **'Nuevo premio'**
  String get rewardsNewPrizeLabel;

  /// No description provided for @rewardsEmptyNoChildPrizes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay premios para chicos.'**
  String get rewardsEmptyNoChildPrizes;

  /// No description provided for @rewardsEmptyNoAdultPrizes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay premios para adultos.'**
  String get rewardsEmptyNoAdultPrizes;

  /// No description provided for @rewardsEmptyNoFamilyPlans.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay planes familiares cargados.'**
  String get rewardsEmptyNoFamilyPlans;

  /// No description provided for @rewardsEmptyNoFamilyPlansChild.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay planes familiares disponibles.'**
  String get rewardsEmptyNoFamilyPlansChild;

  /// No description provided for @rewardsEditPrize.
  ///
  /// In es, this message translates to:
  /// **'Editar premio'**
  String get rewardsEditPrize;

  /// No description provided for @rewardsNewFamilyPrize.
  ///
  /// In es, this message translates to:
  /// **'Nuevo premio familiar'**
  String get rewardsNewFamilyPrize;

  /// No description provided for @rewardsPrizeTitleField.
  ///
  /// In es, this message translates to:
  /// **'Título del premio'**
  String get rewardsPrizeTitleField;

  /// No description provided for @rewardsPrizeDescriptionField.
  ///
  /// In es, this message translates to:
  /// **'Descripción breve'**
  String get rewardsPrizeDescriptionField;

  /// No description provided for @rewardsCostInCoinsField.
  ///
  /// In es, this message translates to:
  /// **'Costo en monedas'**
  String get rewardsCostInCoinsField;

  /// No description provided for @rewardsTargetAudience.
  ///
  /// In es, this message translates to:
  /// **'Dirigido a'**
  String get rewardsTargetAudience;

  /// No description provided for @rewardsWholeFamily.
  ///
  /// In es, this message translates to:
  /// **'Toda la familia'**
  String get rewardsWholeFamily;

  /// No description provided for @rewardsAdults.
  ///
  /// In es, this message translates to:
  /// **'Adultos'**
  String get rewardsAdults;

  /// No description provided for @rewardsKids.
  ///
  /// In es, this message translates to:
  /// **'Chicos'**
  String get rewardsKids;

  /// No description provided for @rewardsIconLabel.
  ///
  /// In es, this message translates to:
  /// **'Icono'**
  String get rewardsIconLabel;

  /// No description provided for @rewardsSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get rewardsSaveChanges;

  /// No description provided for @rewardsSavePrize.
  ///
  /// In es, this message translates to:
  /// **'Guardar premio'**
  String get rewardsSavePrize;

  /// No description provided for @rewardsApprovedSnack.
  ///
  /// In es, this message translates to:
  /// **'\"{title}\" quedó aprobado.'**
  String rewardsApprovedSnack(String title);

  /// No description provided for @rewardsDeleteDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar premio'**
  String get rewardsDeleteDialogTitle;

  /// No description provided for @rewardsDeleteDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Se va a quitar \"{title}\" de la tienda.'**
  String rewardsDeleteDialogBody(String title);

  /// No description provided for @rewardsPrizeCostCoins.
  ///
  /// In es, this message translates to:
  /// **'{cost} monedas'**
  String rewardsPrizeCostCoins(int cost);

  /// No description provided for @rewardsRemovePrize.
  ///
  /// In es, this message translates to:
  /// **'Quitar premio'**
  String get rewardsRemovePrize;

  /// No description provided for @rewardsNotEnoughCoins.
  ///
  /// In es, this message translates to:
  /// **'No te alcanzan las monedas todavía.'**
  String get rewardsNotEnoughCoins;

  /// No description provided for @rewardsRedeemDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Canjear premio'**
  String get rewardsRedeemDialogTitle;

  /// No description provided for @rewardsRedeemDialogBody.
  ///
  /// In es, this message translates to:
  /// **'¿Querés canjear \"{title}\" por {cost} monedas?'**
  String rewardsRedeemDialogBody(String title, int cost);

  /// No description provided for @rewardsRedeemedSnack.
  ///
  /// In es, this message translates to:
  /// **'Canjeaste \"{title}\".'**
  String rewardsRedeemedSnack(String title);

  /// No description provided for @rewardsChildCoinPurse.
  ///
  /// In es, this message translates to:
  /// **'Tu bolsita de coins'**
  String get rewardsChildCoinPurse;

  /// No description provided for @rewardsCurrentBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance actual'**
  String get rewardsCurrentBalance;

  /// No description provided for @rewardsYourCoins.
  ///
  /// In es, this message translates to:
  /// **'Tus monedas'**
  String get rewardsYourCoins;

  /// No description provided for @rewardsBalanceAmount.
  ///
  /// In es, this message translates to:
  /// **'{balance} monedas'**
  String rewardsBalanceAmount(int balance);

  /// No description provided for @rewardsChildBalanceHint.
  ///
  /// In es, this message translates to:
  /// **'Cuando un adulto aprueba tus misiones, crece.'**
  String get rewardsChildBalanceHint;

  /// No description provided for @rewardsEmptyBoutiqueAdmin.
  ///
  /// In es, this message translates to:
  /// **'Cargá premios sugeridos o creá el primer catálogo del hogar.'**
  String get rewardsEmptyBoutiqueAdmin;

  /// No description provided for @rewardsEmptyBoutiqueNonAdmin.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay premios disponibles en la tienda del hogar.'**
  String get rewardsEmptyBoutiqueNonAdmin;

  /// No description provided for @rewardsLoadInitialCatalog.
  ///
  /// In es, this message translates to:
  /// **'Cargar catálogo inicial'**
  String get rewardsLoadInitialCatalog;

  /// No description provided for @rewardsReviewPill.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get rewardsReviewPill;

  /// No description provided for @rewardsRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get rewardsRemove;

  /// No description provided for @rewardsApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get rewardsApprove;

  /// No description provided for @rewardsProposalStatusWaiting.
  ///
  /// In es, this message translates to:
  /// **'{count} coins · esperando respuesta'**
  String rewardsProposalStatusWaiting(int count);

  /// No description provided for @rewardsProposalStatusAction.
  ///
  /// In es, this message translates to:
  /// **'{count} coins · tocá para aprobar o quitar'**
  String rewardsProposalStatusAction(int count);

  /// No description provided for @coupleSpaceTaskEffortEyebrow.
  ///
  /// In es, this message translates to:
  /// **'ESFUERZO'**
  String get coupleSpaceTaskEffortEyebrow;

  /// No description provided for @coupleSpaceTaskEffortTitle.
  ///
  /// In es, this message translates to:
  /// **'Qué tan demandante es'**
  String get coupleSpaceTaskEffortTitle;

  /// No description provided for @coupleSpaceTaskEffortSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La dificultad ayuda a repartir mejor las tareas; no genera puntos ni coins.'**
  String get coupleSpaceTaskEffortSubtitle;

  /// No description provided for @coupleSpaceTaskCompletionMessage.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Tarea completada. La semana avanzó un poco más.} other{{count} tareas completadas. La semana avanzó un poco más.}}'**
  String coupleSpaceTaskCompletionMessage(int count);

  /// No description provided for @coupleSpacePlansSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Propuestas gratuitas: se pueden aceptar, posponer o retirar sin consecuencias.'**
  String get coupleSpacePlansSubtitle;

  /// No description provided for @coupleSpaceProposeAction.
  ///
  /// In es, this message translates to:
  /// **'Proponer algo'**
  String get coupleSpaceProposeAction;

  /// No description provided for @coupleSpaceProposalAccepted.
  ///
  /// In es, this message translates to:
  /// **'Acordado'**
  String get coupleSpaceProposalAccepted;

  /// Estado visible de una propuesta que la pareja decidió retomar más adelante.
  ///
  /// In es, this message translates to:
  /// **'Para después'**
  String get coupleSpaceProposalDeferred;

  /// No description provided for @coupleSpaceProposalCategoryTalk.
  ///
  /// In es, this message translates to:
  /// **'Para charlar'**
  String get coupleSpaceProposalCategoryTalk;

  /// No description provided for @coupleSpaceProposalCategoryPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan juntos'**
  String get coupleSpaceProposalCategoryPlan;

  /// No description provided for @coupleSpaceProposalCategoryAffection.
  ///
  /// In es, this message translates to:
  /// **'Afecto'**
  String get coupleSpaceProposalCategoryAffection;

  /// No description provided for @coupleSpaceProposalCategorySupport.
  ///
  /// In es, this message translates to:
  /// **'Apoyo'**
  String get coupleSpaceProposalCategorySupport;

  /// No description provided for @coupleSpaceNewProposalTitle.
  ///
  /// In es, this message translates to:
  /// **'Proponer algo'**
  String get coupleSpaceNewProposalTitle;

  /// No description provided for @coupleSpaceNewProposalBody.
  ///
  /// In es, this message translates to:
  /// **'No tiene precio ni crea una obligación. La otra persona siempre puede decir “ahora no”.'**
  String get coupleSpaceNewProposalBody;

  /// No description provided for @coupleSpaceProposalTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te gustaría proponer?'**
  String get coupleSpaceProposalTitleLabel;

  /// No description provided for @coupleSpaceProposalTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Cocinar algo nuevo juntos'**
  String get coupleSpaceProposalTitleHint;

  /// No description provided for @coupleSpaceProposalDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Contá un poco más (opcional)'**
  String get coupleSpaceProposalDescriptionLabel;

  /// No description provided for @coupleSpaceProposalDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Qué imaginás, cuándo podría ser o qué necesitás'**
  String get coupleSpaceProposalDescriptionHint;

  /// No description provided for @coupleSpaceProposalCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de propuesta'**
  String get coupleSpaceProposalCategoryLabel;

  /// No description provided for @coupleSpaceProposalSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar propuesta'**
  String get coupleSpaceProposalSend;

  /// No description provided for @coupleSpaceProposalTitleValidation.
  ///
  /// In es, this message translates to:
  /// **'Escribí al menos 3 caracteres.'**
  String get coupleSpaceProposalTitleValidation;

  /// No description provided for @coupleSpaceProposalCreated.
  ///
  /// In es, this message translates to:
  /// **'Propuesta enviada. No genera ninguna deuda.'**
  String get coupleSpaceProposalCreated;

  /// No description provided for @coupleSpaceProposalResponseTitle.
  ///
  /// In es, this message translates to:
  /// **'Responder la propuesta'**
  String get coupleSpaceProposalResponseTitle;

  /// No description provided for @coupleSpaceProposalResponseBody.
  ///
  /// In es, this message translates to:
  /// **'Elegí con libertad. Decir “ahora no” no resta puntos ni requiere explicación.'**
  String get coupleSpaceProposalResponseBody;

  /// No description provided for @coupleSpaceProposalAccept.
  ///
  /// In es, this message translates to:
  /// **'Dale'**
  String get coupleSpaceProposalAccept;

  /// Acción para posponer una propuesta sin aceptarla ni rechazarla.
  ///
  /// In es, this message translates to:
  /// **'Para después'**
  String get coupleSpaceProposalDefer;

  /// No description provided for @coupleSpaceProposalDecline.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get coupleSpaceProposalDecline;

  /// No description provided for @coupleSpaceProposalWithdraw.
  ///
  /// In es, this message translates to:
  /// **'Retirar propuesta'**
  String get coupleSpaceProposalWithdraw;

  /// No description provided for @coupleSpaceProposalArchive.
  ///
  /// In es, this message translates to:
  /// **'Archivar'**
  String get coupleSpaceProposalArchive;

  /// No description provided for @coupleSpaceProposalAcceptedToast.
  ///
  /// In es, this message translates to:
  /// **'Quedó como un plan acordado.'**
  String get coupleSpaceProposalAcceptedToast;

  /// Confirmación sin presión al posponer una propuesta de pareja.
  ///
  /// In es, this message translates to:
  /// **'Quedó guardada para retomarla cuando quieran.'**
  String get coupleSpaceProposalDeferredToast;

  /// No description provided for @coupleSpaceProposalDeclinedToast.
  ///
  /// In es, this message translates to:
  /// **'Respuesta guardada sin penalizaciones.'**
  String get coupleSpaceProposalDeclinedToast;

  /// No description provided for @coupleSpaceProposalWithdrawnToast.
  ///
  /// In es, this message translates to:
  /// **'Retiraste la propuesta.'**
  String get coupleSpaceProposalWithdrawnToast;

  /// No description provided for @coupleSpaceProposalArchivedToast.
  ///
  /// In es, this message translates to:
  /// **'Plan archivado.'**
  String get coupleSpaceProposalArchivedToast;

  /// No description provided for @coupleSpaceLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar este espacio.'**
  String get coupleSpaceLoadError;

  /// No description provided for @tourStepLabel.
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String tourStepLabel(int current, int total);

  /// No description provided for @tourWelcomeEyebrow.
  ///
  /// In es, this message translates to:
  /// **'Bienvenidos'**
  String get tourWelcomeEyebrow;

  /// No description provided for @tourCtaStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get tourCtaStart;

  /// No description provided for @tourCtaNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tourCtaNext;

  /// No description provided for @tourCtaLater.
  ///
  /// In es, this message translates to:
  /// **'Después'**
  String get tourCtaLater;

  /// No description provided for @tourFinaleTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Listo!'**
  String get tourFinaleTitle;

  /// No description provided for @tourFinaleCta.
  ///
  /// In es, this message translates to:
  /// **'Empezar a usar'**
  String get tourFinaleCta;

  /// No description provided for @tourCoupleWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Su hogar, en 30 segundos'**
  String get tourCoupleWelcomeTitle;

  /// No description provided for @tourCoupleWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Les muestro lo esencial: tareas compartidas, propuestas, momentos especiales y gastos. Corto y al punto.'**
  String get tourCoupleWelcomeBody;

  /// No description provided for @tourCoupleWelcomeBodyNamed.
  ///
  /// In es, this message translates to:
  /// **'Te muestro lo esencial para organizar todo con {partnerName}: tareas compartidas, propuestas, momentos especiales y gastos.'**
  String tourCoupleWelcomeBodyNamed(String partnerName);

  /// No description provided for @tourTasksTitleHas.
  ///
  /// In es, this message translates to:
  /// **'Las tareas, entre los dos'**
  String get tourTasksTitleHas;

  /// No description provided for @tourTasksBodyHas.
  ///
  /// In es, this message translates to:
  /// **'Tocá ✓ para completar. El progreso semanal ayuda a ver lo que falta y a repartir mejor el trabajo.'**
  String get tourTasksBodyHas;

  /// No description provided for @tourTasksTitleEmpty.
  ///
  /// In es, this message translates to:
  /// **'Hoy en casa está vacío'**
  String get tourTasksTitleEmpty;

  /// No description provided for @tourTasksBodyEmpty.
  ///
  /// In es, this message translates to:
  /// **'Acá van a vivir las tareas del día. Programá la primera ahora y vela aparecer — o seguí el recorrido y lo hacés después.'**
  String get tourTasksBodyEmpty;

  /// No description provided for @tourTasksCtaCreate.
  ///
  /// In es, this message translates to:
  /// **'Programar una tarea'**
  String get tourTasksCtaCreate;

  /// No description provided for @tourBalanceTitle.
  ///
  /// In es, this message translates to:
  /// **'El pulso del hogar'**
  String get tourBalanceTitle;

  /// No description provided for @tourBalanceBody.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, shared{Tienen economía integrada: acá no hay deudas entre ustedes y ven cuánto gastó el hogar este mes.} other{Acá ven cuánto se deben por gastos compartidos. Con “Equilibrar” pueden saldar las cuentas reales en un toque.}}'**
  String tourBalanceBody(String mode);

  /// No description provided for @tourBalanceBulletSettle.
  ///
  /// In es, this message translates to:
  /// **'Equilibrar → saldar gastos compartidos'**
  String get tourBalanceBulletSettle;

  /// No description provided for @tourBalanceBulletMonth.
  ///
  /// In es, this message translates to:
  /// **'Gasto del mes → el pulso de la casa'**
  String get tourBalanceBulletMonth;

  /// No description provided for @tourBalanceBulletXp.
  ///
  /// In es, this message translates to:
  /// **'XP → para el duelo semanal'**
  String get tourBalanceBulletXp;

  /// No description provided for @tourBalanceBulletCoins.
  ///
  /// In es, this message translates to:
  /// **'Monedas → para canjear recompensas'**
  String get tourBalanceBulletCoins;

  /// No description provided for @tourDuelTitle.
  ///
  /// In es, this message translates to:
  /// **'Duelo semanal'**
  String get tourDuelTitle;

  /// No description provided for @tourDuelBody.
  ///
  /// In es, this message translates to:
  /// **'Cada semana compiten por XP con marcador oculto. El domingo se revela quién ganó. Se reinicia los lunes.'**
  String get tourDuelBody;

  /// No description provided for @tourRewardsTitle.
  ///
  /// In es, this message translates to:
  /// **'Canjeá las monedas'**
  String get tourRewardsTitle;

  /// No description provided for @tourRewardsBody.
  ///
  /// In es, this message translates to:
  /// **'Acá viven las recompensas: peli, masaje, día libre. Ustedes arman la tienda y se premian mutuamente.'**
  String get tourRewardsBody;

  /// No description provided for @tourExpensesTitle.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, shared{Las finanzas del hogar} other{Dividan los gastos}}'**
  String tourExpensesTitle(String mode);

  /// No description provided for @tourExpensesBody.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, shared{Registren acá los gastos del hogar: recurrentes, compras y metas de ahorro, todo en un solo lugar.} other{Sumen gastos del hogar y la app calcula quién le debe a quién, según la división que configuraron.}}'**
  String tourExpensesBody(String mode);

  /// No description provided for @tourCoupleFinaleBody.
  ///
  /// In es, this message translates to:
  /// **'A disfrutar su hogar. Cualquier duda, las Preguntas Frecuentes se adaptan a ustedes.'**
  String get tourCoupleFinaleBody;

  /// No description provided for @tourFamilyWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu familia, organizada'**
  String get tourFamilyWelcomeTitle;

  /// No description provided for @tourFamilyWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Te muestro cómo manejar tareas, puntos y premios de toda la familia — en un minuto.'**
  String get tourFamilyWelcomeBody;

  /// No description provided for @tourFamilyTasksTitleHas.
  ///
  /// In es, this message translates to:
  /// **'Las tareas de la familia'**
  String get tourFamilyTasksTitleHas;

  /// No description provided for @tourFamilyTasksBody.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, approvals{Asigná tareas a cada uno. Cuando los chicos las completen, te llegan para aprobar — recién ahí cobran sus monedas.} other{Asigná tareas a cada uno y seguí el progreso de todos desde acá.}}'**
  String tourFamilyTasksBody(String mode);

  /// No description provided for @tourFamilyFinanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Los gastos, entre adultos'**
  String get tourFamilyFinanceTitle;

  /// No description provided for @tourFamilyFinanceBody.
  ///
  /// In es, this message translates to:
  /// **'Los gastos compartidos del hogar se manejan acá, solo entre adultos. Los chicos no los ven.'**
  String get tourFamilyFinanceBody;

  /// No description provided for @tourFamilyRankingTitle.
  ///
  /// In es, this message translates to:
  /// **'Ranking semanal'**
  String get tourFamilyRankingTitle;

  /// No description provided for @tourFamilyRankingBody.
  ///
  /// In es, this message translates to:
  /// **'Cada semana, quien más XP suma completando tareas se lleva la corona. Sana competencia familiar.'**
  String get tourFamilyRankingBody;

  /// No description provided for @tourFamilyRewardsTitle.
  ///
  /// In es, this message translates to:
  /// **'La tienda de premios'**
  String get tourFamilyRewardsTitle;

  /// No description provided for @tourFamilyRewardsBody.
  ///
  /// In es, this message translates to:
  /// **'Creá premios (una salida, tiempo de pantalla, su postre favorito) y los chicos los canjean con las monedas que ganan.'**
  String get tourFamilyRewardsBody;

  /// No description provided for @tourFamilyFinaleBody.
  ///
  /// In es, this message translates to:
  /// **'A organizar la tropa. Las Preguntas Frecuentes se adaptan a tu rol si necesitás ayuda.'**
  String get tourFamilyFinaleBody;

  /// No description provided for @familyRewardsCoinsLabel.
  ///
  /// In es, this message translates to:
  /// **'monedas'**
  String get familyRewardsCoinsLabel;

  /// No description provided for @statsTabWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get statsTabWeek;

  /// No description provided for @statsTabEvolution.
  ///
  /// In es, this message translates to:
  /// **'Evolución'**
  String get statsTabEvolution;

  /// No description provided for @statsTabAchievements.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get statsTabAchievements;

  /// No description provided for @statsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get statsRetry;

  /// No description provided for @statsHouseholdSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen del hogar'**
  String get statsHouseholdSummary;

  /// No description provided for @statsTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get statsTasks;

  /// Pluralized 'tasks' label under the household summary metric.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Tarea} other{Tareas}}'**
  String statsTasksLabel(int count);

  /// No description provided for @statsXP.
  ///
  /// In es, this message translates to:
  /// **'XP'**
  String get statsXP;

  /// No description provided for @statsCoins.
  ///
  /// In es, this message translates to:
  /// **'Coins'**
  String get statsCoins;

  /// No description provided for @statsWeeklyHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial semanal'**
  String get statsWeeklyHistory;

  /// No description provided for @statsVictoryHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de victorias'**
  String get statsVictoryHistory;

  /// No description provided for @statsPrivacyMessage.
  ///
  /// In es, this message translates to:
  /// **'Las estadísticas son privadas de tu hogar. Solo vos y tu pareja pueden ver estos datos.'**
  String get statsPrivacyMessage;

  /// No description provided for @statsPrivacyDetailed.
  ///
  /// In es, this message translates to:
  /// **'Tus datos de progreso son privados y solo vos podés ver este historial detallado.'**
  String get statsPrivacyDetailed;

  /// No description provided for @statsPrivacyFull.
  ///
  /// In es, this message translates to:
  /// **'Las estadísticas son totalmente privadas de tu hogar. Solo vos y tu pareja pueden ver estos datos.'**
  String get statsPrivacyFull;

  /// No description provided for @statsWeeklyDuel.
  ///
  /// In es, this message translates to:
  /// **'Duelo semanal'**
  String get statsWeeklyDuel;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay datos'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Completá algunas tareas para ver tus áreas de dominio.'**
  String get statsEmptySubtitle;

  /// No description provided for @statsRefreshButton.
  ///
  /// In es, this message translates to:
  /// **'Actualizar datos'**
  String get statsRefreshButton;

  /// No description provided for @weeklyWinnerEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ganador semanal'**
  String get weeklyWinnerEmptyTitle;

  /// No description provided for @weeklyWinnerEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Completá tareas esta semana y el duelo empezará a tomar forma.'**
  String get weeklyWinnerEmptyBody;

  /// No description provided for @weeklyWinnerWeeklyClose.
  ///
  /// In es, this message translates to:
  /// **'CIERRE SEMANAL'**
  String get weeklyWinnerWeeklyClose;

  /// No description provided for @weeklyWinnerTitle.
  ///
  /// In es, this message translates to:
  /// **'Ganador semanal'**
  String get weeklyWinnerTitle;

  /// Headline for the weekly duel winner screen.
  ///
  /// In es, this message translates to:
  /// **'{name} ganó la semana'**
  String weeklyWinnerHeadline(String name);

  /// No description provided for @weeklyWinnerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Así cerró la semana entre ustedes.'**
  String get weeklyWinnerSubtitle;

  /// No description provided for @weeklyWinnerCardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Buen cierre: más constancia, más puntos y más ritmo.'**
  String get weeklyWinnerCardSubtitle;

  /// No description provided for @weeklyWinnerCoinsReward.
  ///
  /// In es, this message translates to:
  /// **'+20 coins'**
  String get weeklyWinnerCoinsReward;

  /// Dynamic weekly duel coin reward shown on the winner screen.
  ///
  /// In es, this message translates to:
  /// **'+{coins} coins'**
  String weeklyWinnerCoinsAwarded(int coins);

  /// No description provided for @weeklyWinnerSecondPlace.
  ///
  /// In es, this message translates to:
  /// **'Segundo puesto'**
  String get weeklyWinnerSecondPlace;

  /// Label of the revealed duel score card on the weekly winner screen.
  ///
  /// In es, this message translates to:
  /// **'Marcador final'**
  String get weeklyWinnerFinalScore;

  /// No description provided for @weeklyWinnerRankingTitle.
  ///
  /// In es, this message translates to:
  /// **'Ranking semanal'**
  String get weeklyWinnerRankingTitle;

  /// No description provided for @weeklyWinnerFallbackWinner.
  ///
  /// In es, this message translates to:
  /// **'Ganador'**
  String get weeklyWinnerFallbackWinner;

  /// No description provided for @weeklyWinnerFallbackLoser.
  ///
  /// In es, this message translates to:
  /// **'Perdedor'**
  String get weeklyWinnerFallbackLoser;

  /// No description provided for @weeklyWinnerFallbackParticipant.
  ///
  /// In es, this message translates to:
  /// **'Participante'**
  String get weeklyWinnerFallbackParticipant;

  /// No description provided for @weeklyWinnerFallbackPlayer.
  ///
  /// In es, this message translates to:
  /// **'Jugador'**
  String get weeklyWinnerFallbackPlayer;

  /// No description provided for @weeklyWinnerClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get weeklyWinnerClose;

  /// No description provided for @weeklyWinnerContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get weeklyWinnerContinue;

  /// No description provided for @loveNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Escribí algo tierno...'**
  String get loveNoteHint;

  /// No description provided for @loveNoteSent.
  ///
  /// In es, this message translates to:
  /// **'Nota enviada con amor'**
  String get loveNoteSent;

  /// No description provided for @weeklyProgressTitle.
  ///
  /// In es, this message translates to:
  /// **'Progreso semanal'**
  String get weeklyProgressTitle;

  /// No description provided for @weeklyProgressSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Seguí cómo viene la semana, quién tomó ventaja y cuánto ritmo llevan juntos.'**
  String get weeklyProgressSubtitle;

  /// No description provided for @weeklyProgressWeekLabel.
  ///
  /// In es, this message translates to:
  /// **'Semana actual · {weekRange}'**
  String weeklyProgressWeekLabel(String weekRange);

  /// No description provided for @personalEvolutionTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu evolución personal'**
  String get personalEvolutionTitle;

  /// No description provided for @streakLabel.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get streakLabel;

  /// No description provided for @streakDaysValue.
  ///
  /// In es, this message translates to:
  /// **'{days} días'**
  String streakDaysValue(int days);

  /// No description provided for @streakSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¡Vas con todo!'**
  String get streakSubtitle;

  /// No description provided for @levelLabel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get levelLabel;

  /// No description provided for @levelXpToNext.
  ///
  /// In es, this message translates to:
  /// **'{xp} XP para subir'**
  String levelXpToNext(int xp);

  /// No description provided for @progressEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Empezá a completar tareas\npara ver tu progreso.'**
  String get progressEmptyTitle;

  /// No description provided for @categoriesDominance.
  ///
  /// In es, this message translates to:
  /// **'Dominio por categoría'**
  String get categoriesDominance;

  /// No description provided for @categoriesBreakdown.
  ///
  /// In es, this message translates to:
  /// **'Desglose detallado'**
  String get categoriesBreakdown;

  /// No description provided for @categoriesBalanceTip.
  ///
  /// In es, this message translates to:
  /// **'Balancear las categorías ayuda a mantener un hogar más armonioso y divertido.'**
  String get categoriesBalanceTip;

  /// No description provided for @categoriesImpactDistribution.
  ///
  /// In es, this message translates to:
  /// **'DISTRIBUCIÓN DE IMPACTO'**
  String get categoriesImpactDistribution;

  /// No description provided for @categoriesTasksCount.
  ///
  /// In es, this message translates to:
  /// **'{count} TAREAS'**
  String categoriesTasksCount(int count);

  /// No description provided for @categoriesCompletedCount.
  ///
  /// In es, this message translates to:
  /// **'{count} completadas'**
  String categoriesCompletedCount(int count);

  /// No description provided for @categoriesXpTotal.
  ///
  /// In es, this message translates to:
  /// **'XP TOTAL'**
  String get categoriesXpTotal;

  /// No description provided for @achievementsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus medallas'**
  String get achievementsTitle;

  /// No description provided for @achievementsCoupleChallenges.
  ///
  /// In es, this message translates to:
  /// **'Desafíos de pareja'**
  String get achievementsCoupleChallenges;

  /// No description provided for @achievementsIconicMoments.
  ///
  /// In es, this message translates to:
  /// **'Momentos icónicos'**
  String get achievementsIconicMoments;

  /// No description provided for @duelHistoryLastWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana pasada'**
  String get duelHistoryLastWeek;

  /// No description provided for @duelVsText.
  ///
  /// In es, this message translates to:
  /// **' vs '**
  String get duelVsText;

  /// No description provided for @rewardsTitleRequiredError.
  ///
  /// In es, this message translates to:
  /// **'Escribí el nombre del deseo.'**
  String get rewardsTitleRequiredError;

  /// No description provided for @rewardsTitleMinLengthError.
  ///
  /// In es, this message translates to:
  /// **'Usá al menos 3 caracteres.'**
  String get rewardsTitleMinLengthError;

  /// No description provided for @rewardsTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Masaje de 20 minutos'**
  String get rewardsTitleHint;

  /// No description provided for @rewardsTargetTypeAdult.
  ///
  /// In es, this message translates to:
  /// **'Adultos'**
  String get rewardsTargetTypeAdult;

  /// No description provided for @rewardsTargetTypeChild.
  ///
  /// In es, this message translates to:
  /// **'Chicos'**
  String get rewardsTargetTypeChild;

  /// No description provided for @rewardsTargetTypeFamily.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get rewardsTargetTypeFamily;

  /// No description provided for @rewardsCostValidationInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un costo válido.'**
  String get rewardsCostValidationInvalid;

  /// No description provided for @rewardsCostValidationMin.
  ///
  /// In es, this message translates to:
  /// **'Debe costar al menos 1 coin.'**
  String get rewardsCostValidationMin;

  /// No description provided for @rewardsDescriptionSuggestionHint.
  ///
  /// In es, this message translates to:
  /// **'Explicá por qué tu pareja debería aprobar este deseo.'**
  String get rewardsDescriptionSuggestionHint;

  /// No description provided for @rewardsDescriptionPrizeHint.
  ///
  /// In es, this message translates to:
  /// **'Un detalle corto para describir el premio.'**
  String get rewardsDescriptionPrizeHint;

  /// No description provided for @rewardsValidationMinLength.
  ///
  /// In es, this message translates to:
  /// **'Contá un poco más para que sea fácil evaluarlo.'**
  String get rewardsValidationMinLength;

  /// No description provided for @statsWeeklyProgressTitle.
  ///
  /// In es, this message translates to:
  /// **'Progreso semanal'**
  String get statsWeeklyProgressTitle;

  /// No description provided for @statsWeeklyProgressSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Seguí cómo viene la semana, quién tomó ventaja y cuánto ritmo llevan juntos.'**
  String get statsWeeklyProgressSubtitle;

  /// No description provided for @faceoffWeeklyDuelLabel.
  ///
  /// In es, this message translates to:
  /// **'DUELO SEMANAL'**
  String get faceoffWeeklyDuelLabel;

  /// No description provided for @faceoffHiddenScoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu pareja juega con marcador oculto'**
  String get faceoffHiddenScoreTitle;

  /// No description provided for @faceoffHiddenScoreSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vos ves tu propio avance. El resultado real se descubre al cierre de la semana.'**
  String get faceoffHiddenScoreSubtitle;

  /// No description provided for @faceoffYouLabel.
  ///
  /// In es, this message translates to:
  /// **'Vos'**
  String get faceoffYouLabel;

  /// No description provided for @faceoffPartnerLabel.
  ///
  /// In es, this message translates to:
  /// **'Pareja'**
  String get faceoffPartnerLabel;

  /// XP value shown on the weekly duel card.
  ///
  /// In es, this message translates to:
  /// **'{xp} XP'**
  String faceoffXpValue(int xp);

  /// No description provided for @faceoffHiddenXp.
  ///
  /// In es, this message translates to:
  /// **'XP oculta'**
  String get faceoffHiddenXp;

  /// No description provided for @faceoffWeeklyAdvantage.
  ///
  /// In es, this message translates to:
  /// **'Ventaja semanal'**
  String get faceoffWeeklyAdvantage;

  /// No description provided for @faceoffHiddenScore.
  ///
  /// In es, this message translates to:
  /// **'Marcador oculto'**
  String get faceoffHiddenScore;

  /// Helper text under the weekly duel hidden-score bar.
  ///
  /// In es, this message translates to:
  /// **'Tus {xp} XP ya cuentan. La XP de tu pareja queda oculta hasta el domingo.'**
  String faceoffCurrentXpCounts(int xp);

  /// No description provided for @faceoffWeeklyRhythm.
  ///
  /// In es, this message translates to:
  /// **'Ritmo semanal'**
  String get faceoffWeeklyRhythm;

  /// Comma-separated single-letter weekday initials, Monday first (7 items). Shared by the weekly duel rhythm row and the schedule dialog day pickers.
  ///
  /// In es, this message translates to:
  /// **'L,M,X,J,V,S,D'**
  String get weekDayInitials;

  /// Label of the personal weekly XP progress bar on the duel card.
  ///
  /// In es, this message translates to:
  /// **'Tu semana'**
  String get faceoffMyWeekLabel;

  /// Personal best week shown next to the weekly progress bar.
  ///
  /// In es, this message translates to:
  /// **'Récord: {xp} XP'**
  String faceoffPersonalRecordChip(int xp);

  /// Starter goal shown when the user has no duel history yet.
  ///
  /// In es, this message translates to:
  /// **'Meta: {xp} XP'**
  String faceoffStarterGoalChip(int xp);

  /// Shown under the weekly progress bar when the user beats their best week.
  ///
  /// In es, this message translates to:
  /// **'¡Nuevo récord personal!'**
  String get faceoffNewRecord;

  /// No description provided for @faceoffClosesToday.
  ///
  /// In es, this message translates to:
  /// **'Cierra hoy'**
  String get faceoffClosesToday;

  /// Remaining days until the weekly duel closes.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1{1 día restante} other{{days} días restantes}}'**
  String faceoffDaysRemaining(int days);

  /// No description provided for @statsCurrentWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana actual'**
  String get statsCurrentWeek;

  /// No description provided for @statsNoDataMessage.
  ///
  /// In es, this message translates to:
  /// **'Empezá a completar tareas para ver tu progreso.'**
  String get statsNoDataMessage;

  /// No description provided for @statsStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get statsStreak;

  /// No description provided for @statsStreakDays.
  ///
  /// In es, this message translates to:
  /// **'{count} días'**
  String statsStreakDays(Object count);

  /// No description provided for @statsStreakMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Vas con todo!'**
  String get statsStreakMessage;

  /// No description provided for @statsLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get statsLevel;

  /// No description provided for @statsXPToNextLevel.
  ///
  /// In es, this message translates to:
  /// **'{count} XP para subir'**
  String statsXPToNextLevel(Object count);

  /// No description provided for @statsNoDataTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay datos'**
  String get statsNoDataTitle;

  /// No description provided for @statsNoDataSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Completá algunas tareas para ver tus áreas de dominio.'**
  String get statsNoDataSubtitle;

  /// No description provided for @commonRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar datos'**
  String get commonRefresh;

  /// No description provided for @rewardsWaitingResponse.
  ///
  /// In es, this message translates to:
  /// **'esperando respuesta'**
  String get rewardsWaitingResponse;

  /// No description provided for @rewardsTapToApprove.
  ///
  /// In es, this message translates to:
  /// **'toca para aprobar o quitar'**
  String get rewardsTapToApprove;

  /// No description provided for @rewardsCostCoins.
  ///
  /// In es, this message translates to:
  /// **'{cost} coins'**
  String rewardsCostCoins(Object cost);

  /// No description provided for @householdSocialHubYourRole.
  ///
  /// In es, this message translates to:
  /// **'Tu rol: {role}'**
  String householdSocialHubYourRole(Object role);

  /// No description provided for @householdSocialHubRoleFallback.
  ///
  /// In es, this message translates to:
  /// **'Roles y premios listos para organizar la semana.'**
  String get householdSocialHubRoleFallback;

  /// Etiqueta de rol neutra para modo convivencia (friends), donde todos son adultos pares sin rol familiar (Padre/Madre).
  ///
  /// In es, this message translates to:
  /// **'Integrante'**
  String get householdSocialHubRoleMember;

  /// Título de la sección de equilibrio de aporte en convivencia: cuánto puso cada integrante en tareas y plata este mes.
  ///
  /// In es, this message translates to:
  /// **'Aporte del mes'**
  String get contributionBalanceTitle;

  /// Subtítulo neutro de la sección de aporte en convivencia. Evita lenguaje competitivo.
  ///
  /// In es, this message translates to:
  /// **'Cómo venimos repartidos en el piso.'**
  String get contributionBalanceSubtitle;

  /// Título del estado vacío del equilibrio de aporte en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay aportes este mes'**
  String get contributionBalanceEmptyTitle;

  /// Cuerpo del estado vacío del equilibrio de aporte en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Cuando completen tareas o carguen gastos compartidos, acá van a ver cómo queda el reparto.'**
  String get contributionBalanceEmptyBody;

  /// Cantidad de tareas hechas por un integrante este mes en convivencia.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin tareas} one{{count} tarea} other{{count} tareas}}'**
  String contributionBalanceTasksLabel(int count);

  /// Nota al pie neutra de la sección de aporte en convivencia, recalca que no es competencia.
  ///
  /// In es, this message translates to:
  /// **'Sin ganadores: esto es solo para ver que estemos parejos.'**
  String get contributionBalanceFootnote;

  /// Título de la sección de gastos fijos compartidos en convivencia (alquiler, luz, internet).
  ///
  /// In es, this message translates to:
  /// **'Cuentas del piso'**
  String get householdBillsTitle;

  /// Subtítulo de la sección de cuentas del piso en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Gastos fijos que se reparten entre todos cada mes.'**
  String get householdBillsSubtitle;

  /// Estado vacío de cuentas del piso en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay cuentas fijas'**
  String get householdBillsEmptyTitle;

  /// Cuerpo del estado vacío de cuentas del piso en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Cargá el alquiler, la luz o internet y se van a dividir solas cada mes.'**
  String get householdBillsEmptyBody;

  /// Botón para crear un gasto fijo compartido en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Agregar cuenta del piso'**
  String get householdBillsAddButton;

  /// Texto del estado bloqueado de cuentas del piso cuando el hogar no es premium.
  ///
  /// In es, this message translates to:
  /// **'Las cuentas fijas que se dividen solas cada mes son parte de Premium.'**
  String get householdBillsPremiumBody;

  /// Botón que abre el paywall desde la sección de cuentas del piso en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con Premium'**
  String get householdBillsPremiumUnlock;

  /// Monto mensual de una cuenta del piso. amount ya viene formateado con moneda.
  ///
  /// In es, this message translates to:
  /// **'{amount} / mes'**
  String householdBillsPerMonth(String amount);

  /// Día del mes en que se registra la cuenta del piso.
  ///
  /// In es, this message translates to:
  /// **'Día {day}'**
  String householdBillsDayOfMonth(int day);

  /// Título de la sección de saldar deudas entre integrantes en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Saldar cuentas'**
  String get householdSettleUpTitle;

  /// Subtítulo de la sección de saldar cuentas en convivencia.
  ///
  /// In es, this message translates to:
  /// **'Quién le debe a quién para quedar a mano.'**
  String get householdSettleUpSubtitle;

  /// No description provided for @householdSocialHubStoreButton.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get householdSocialHubStoreButton;

  /// No description provided for @householdSocialHubTrackingTitle.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento familiar'**
  String get householdSocialHubTrackingTitle;

  /// No description provided for @householdSocialHubTrackingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Avances por integrante y cierre semanal.'**
  String get householdSocialHubTrackingSubtitle;

  /// No description provided for @householdSocialHubShortcutMemberView.
  ///
  /// In es, this message translates to:
  /// **'Vista por miembro'**
  String get householdSocialHubShortcutMemberView;

  /// No description provided for @householdSocialHubShortcutWeeklySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get householdSocialHubShortcutWeeklySummary;

  /// No description provided for @householdSocialHubRankingPoints.
  ///
  /// In es, this message translates to:
  /// **'{count} pts'**
  String householdSocialHubRankingPoints(Object count);

  /// No description provided for @householdSocialHubRankingHidden.
  ///
  /// In es, this message translates to:
  /// **'Oculto'**
  String get householdSocialHubRankingHidden;

  /// No description provided for @householdSocialHubRankingSurprise.
  ///
  /// In es, this message translates to:
  /// **'Sorpresa'**
  String get householdSocialHubRankingSurprise;

  /// No description provided for @householdSocialHubRankingLeader.
  ///
  /// In es, this message translates to:
  /// **'{name} viene liderando la semana.'**
  String householdSocialHubRankingLeader(Object name);

  /// No description provided for @householdSocialHubRankingHideHint.
  ///
  /// In es, this message translates to:
  /// **'Desde el jueves guardamos los puntos para revelar al ganador al cierre.'**
  String get householdSocialHubRankingHideHint;

  /// No description provided for @householdSocialHubRankingEmpty.
  ///
  /// In es, this message translates to:
  /// **'Completen tareas para sumar puntos'**
  String get householdSocialHubRankingEmpty;

  /// No description provided for @householdSocialHubRankingEmptyTab.
  ///
  /// In es, this message translates to:
  /// **'Nadie sumó puntos en {tab} todavía'**
  String householdSocialHubRankingEmptyTab(Object tab);

  /// No description provided for @householdSocialHubRankingTasksCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 tarea} other{{count} tareas}}'**
  String householdSocialHubRankingTasksCount(num count);

  /// No description provided for @householdSocialHubMemberFallback.
  ///
  /// In es, this message translates to:
  /// **'Integrante'**
  String get householdSocialHubMemberFallback;

  /// No description provided for @householdSocialHubLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando ranking...'**
  String get householdSocialHubLoading;

  /// No description provided for @householdSocialHubLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el ranking.'**
  String get householdSocialHubLoadError;

  /// No description provided for @householdSocialHubRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get householdSocialHubRetry;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpieza general'**
  String get taskCategoryCleaningGeneral;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cocina'**
  String get taskCategoryKitchen;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Dormitorio'**
  String get taskCategoryBedroom;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Baño'**
  String get taskCategoryBathroom;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Espacios comunes'**
  String get taskCategoryCommonSpaces;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ropa'**
  String get taskCategoryLaundry;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Basura / reciclaje'**
  String get taskCategoryTrashRecycling;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Compras / organización'**
  String get taskCategoryShoppingOrganization;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get taskCategoryPets;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Exterior / jardín'**
  String get taskCategoryOutdoorGarden;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento del hogar'**
  String get taskCategoryHomeMaintenance;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Niños / cuidado'**
  String get taskCategoryKidsCare;

  /// Localized task category label from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Administración del hogar'**
  String get taskCategoryHomeAdmin;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Barrer pisos'**
  String get taskTemplateSweepFloors;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Aspirar pisos o alfombras'**
  String get taskTemplateVacuumFloorsOrRugs;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Trapear / fregar pisos'**
  String get taskTemplateMopFloors;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar polvo de muebles'**
  String get taskTemplateDustFurniture;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar ventanas'**
  String get taskTemplateCleanWindows;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Orden general de la casa'**
  String get taskTemplateGeneralHouseTidying;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpieza profunda general'**
  String get taskTemplateDeepCleanGeneral;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Lavar los platos'**
  String get taskTemplateWashDishes;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Guardar / vaciar lavavajillas'**
  String get taskTemplateEmptyDishwasher;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cocinar comida sencilla'**
  String get taskTemplateCookSimpleMeal;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cocinar comida completa'**
  String get taskTemplateCookFullMeal;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Poner la mesa'**
  String get taskTemplateSetTable;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Levantar la mesa'**
  String get taskTemplateClearTable;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar mesada y superficies'**
  String get taskTemplateCleanCounters;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar cocina completa'**
  String get taskTemplateCleanFullKitchen;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar heladera'**
  String get taskTemplateCleanFridge;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar horno'**
  String get taskTemplateCleanOven;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Organizar despensa'**
  String get taskTemplateOrganizePantry;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Hacer la cama'**
  String get taskTemplateMakeBed;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ordenar habitación'**
  String get taskTemplateTidyBedroom;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cambiar sábanas'**
  String get taskTemplateChangeSheets;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ordenar placard'**
  String get taskTemplateOrganizeCloset;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpieza general del dormitorio'**
  String get taskTemplateBedroomGeneralClean;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar inodoro'**
  String get taskTemplateCleanToilet;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar lavamanos'**
  String get taskTemplateCleanSink;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar espejo'**
  String get taskTemplateCleanMirror;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar ducha / bañera'**
  String get taskTemplateCleanShowerTub;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Reponer papel higiénico o jabón'**
  String get taskTemplateRestockBathroomSupplies;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpieza completa del baño'**
  String get taskTemplateCleanFullBathroom;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ordenar sala / living'**
  String get taskTemplateTidyLivingRoom;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar muebles'**
  String get taskTemplateCleanFurniture;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar sillones'**
  String get taskTemplateCleanSofas;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar mesa del comedor'**
  String get taskTemplateCleanDiningTable;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Aspirar o limpiar área común'**
  String get taskTemplateCleanCommonArea;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Lavar ropa'**
  String get taskTemplateWashLaundry;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Tender ropa'**
  String get taskTemplateHangLaundry;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Usar secadora'**
  String get taskTemplateUseDryer;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Doblar y guardar ropa'**
  String get taskTemplateFoldPutAwayLaundry;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Planchar ropa'**
  String get taskTemplateIronClothes;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cambiar toallas'**
  String get taskTemplateChangeTowels;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Organizar placard'**
  String get taskTemplateOrganizeWardrobe;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Sacar la basura'**
  String get taskTemplateTakeOutTrash;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Separar reciclaje'**
  String get taskTemplateSortRecycling;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Llevar reciclaje'**
  String get taskTemplateTakeRecycling;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Hacer lista de compras'**
  String get taskTemplateMakeShoppingList;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ir al supermercado'**
  String get taskTemplateGoGroceryShopping;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Guardar compras'**
  String get taskTemplatePutAwayGroceries;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Planificar menú semanal'**
  String get taskTemplatePlanWeeklyMenu;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Dar de comer a la mascota'**
  String get taskTemplateFeedPet;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Pasear mascota'**
  String get taskTemplateWalkPet;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar arenero / área'**
  String get taskTemplateCleanPetArea;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Bañar mascota'**
  String get taskTemplateBathePet;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpieza general de zona de mascota'**
  String get taskTemplatePetAreaGeneralClean;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Regar plantas'**
  String get taskTemplateWaterPlants;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar patio / terraza'**
  String get taskTemplateCleanPatioTerrace;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Juntar hojas'**
  String get taskTemplateRakeLeaves;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cortar césped'**
  String get taskTemplateMowLawn;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ordenar jardín'**
  String get taskTemplateTidyGarden;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cambiar bombillas'**
  String get taskTemplateChangeLightBulbs;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Pequeño arreglo del hogar'**
  String get taskTemplateSmallHomeRepair;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Revisión de filtros'**
  String get taskTemplateCheckFilters;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Desatascar desagües'**
  String get taskTemplateUnclogDrains;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Arreglo mediano'**
  String get taskTemplateMediumRepair;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Arreglo grande'**
  String get taskTemplateLargeRepair;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ordenar juguetes'**
  String get taskTemplateTidyToys;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Dar de comer'**
  String get taskTemplateFeedKids;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Ayudar con tareas escolares'**
  String get taskTemplateHelpWithHomework;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Llevar o buscar del colegio'**
  String get taskTemplateSchoolPickupDropoff;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Bañar niños'**
  String get taskTemplateBatheKids;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Pagar facturas'**
  String get taskTemplatePayBills;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Revisar gastos del hogar'**
  String get taskTemplateReviewHouseholdExpenses;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Organizar documentos'**
  String get taskTemplateOrganizeDocuments;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Planificar tareas del hogar'**
  String get taskTemplatePlanHouseholdTasks;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Limpiar microondas'**
  String get taskTemplateCleanMicrowave;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Lavar el auto'**
  String get taskTemplateWashCar;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Lavar tachos de basura'**
  String get taskTemplateCleanTrashBins;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Preparar mochila del colegio'**
  String get taskTemplatePackSchoolBag;

  /// Localized task template title from the system catalog.
  ///
  /// In es, this message translates to:
  /// **'Cambiar agua de la mascota'**
  String get taskTemplateGivePetWater;

  /// Snackbar shown after adding a suggested task template.
  ///
  /// In es, this message translates to:
  /// **'\"{title}\" añadida'**
  String addTaskOptionsAddedSnack(String title);

  /// Error amigable al intentar agregar una tarea sugerida.
  ///
  /// In es, this message translates to:
  /// **'No pudimos agregar la tarea.'**
  String get addTaskOptionsAddError;

  /// Error amigable al intentar editar una tarea.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar los cambios.'**
  String get editTaskSaveError;

  /// Error amigable al intentar eliminar una tarea.
  ///
  /// In es, this message translates to:
  /// **'No pudimos eliminar la tarea.'**
  String get editTaskDeleteError;

  /// Error amigable al guardar un gasto o ingreso recurrente.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar este registro recurrente.'**
  String get recurringExpenseSaveError;

  /// Error al cargar integrantes requeridos por el formulario recurrente.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los integrantes del hogar.'**
  String get recurringExpenseMembersLoadError;

  /// No description provided for @recurringExpenseValidationTitleAmount.
  ///
  /// In es, this message translates to:
  /// **'Completá título y monto válido.'**
  String get recurringExpenseValidationTitleAmount;

  /// No description provided for @recurringExpenseValidationPayer.
  ///
  /// In es, this message translates to:
  /// **'Elegí quién suele abonarla para dejarla lista.'**
  String get recurringExpenseValidationPayer;

  /// No description provided for @recurringExpenseDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar suscripción?'**
  String get recurringExpenseDeleteTitle;

  /// No description provided for @recurringExpenseDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Dejará de aparecer en futuros meses.'**
  String get recurringExpenseDeleteBody;

  /// No description provided for @recurringExpenseDetailEyebrow.
  ///
  /// In es, this message translates to:
  /// **'DETALLE'**
  String get recurringExpenseDetailEyebrow;

  /// No description provided for @recurringExpenseDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Qué se renueva cada mes'**
  String get recurringExpenseDetailTitle;

  /// No description provided for @recurringExpenseDetailSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Definí el nombre y el monto para reconocerla rápido.'**
  String get recurringExpenseDetailSubtitle;

  /// No description provided for @recurringExpenseCalendarEyebrow.
  ///
  /// In es, this message translates to:
  /// **'CALENDARIO'**
  String get recurringExpenseCalendarEyebrow;

  /// No description provided for @recurringExpenseCalendarTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuándo se registra'**
  String get recurringExpenseCalendarTitle;

  /// No description provided for @recurringExpenseCalendarSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegimos el día habitual para programarla sola.'**
  String get recurringExpenseCalendarSubtitle;

  /// No description provided for @recurringExpenseCategoryEyebrow.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get recurringExpenseCategoryEyebrow;

  /// No description provided for @recurringExpenseCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Dónde encaja mejor'**
  String get recurringExpenseCategoryTitle;

  /// No description provided for @recurringExpenseCategorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ayuda a ordenar Finanzas y mantener la lectura clara.'**
  String get recurringExpenseCategorySubtitle;

  /// No description provided for @recurringExpenseSplitEyebrow.
  ///
  /// In es, this message translates to:
  /// **'REPARTO'**
  String get recurringExpenseSplitEyebrow;

  /// No description provided for @recurringExpenseSplitTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo se reparte'**
  String get recurringExpenseSplitTitle;

  /// No description provided for @recurringExpenseSplitSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Definí si se comparte en el hogar o si queda como personal.'**
  String get recurringExpenseSplitSubtitle;

  /// No description provided for @recurringExpensePayerEyebrow.
  ///
  /// In es, this message translates to:
  /// **'PAGADOR'**
  String get recurringExpensePayerEyebrow;

  /// No description provided for @recurringExpensePayerTitle.
  ///
  /// In es, this message translates to:
  /// **'Quién suele abonarla'**
  String get recurringExpensePayerTitle;

  /// No description provided for @recurringExpensePayerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Esto deja una sugerencia lista para los próximos meses.'**
  String get recurringExpensePayerSubtitle;

  /// No description provided for @recurringExpenseHeaderEditIncome.
  ///
  /// In es, this message translates to:
  /// **'Editar ingreso'**
  String get recurringExpenseHeaderEditIncome;

  /// No description provided for @recurringExpenseHeaderEditSubscription.
  ///
  /// In es, this message translates to:
  /// **'Editar suscripción'**
  String get recurringExpenseHeaderEditSubscription;

  /// No description provided for @recurringExpenseHeaderNewIncome.
  ///
  /// In es, this message translates to:
  /// **'Nuevo ingreso fijo'**
  String get recurringExpenseHeaderNewIncome;

  /// No description provided for @recurringExpenseHeaderNewSubscription.
  ///
  /// In es, this message translates to:
  /// **'Nueva suscripción'**
  String get recurringExpenseHeaderNewSubscription;

  /// No description provided for @recurringExpenseHeaderEditSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustá monto, categoría y reparto para mantenerlo al día.'**
  String get recurringExpenseHeaderEditSubtitle;

  /// No description provided for @recurringExpenseHeaderNewIncomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Se sumará automáticamente a tu balance cada mes.'**
  String get recurringExpenseHeaderNewIncomeSubtitle;

  /// No description provided for @recurringExpenseHeaderNewSubscriptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Dejala configurada y lista para que se registre sola todos los meses.'**
  String get recurringExpenseHeaderNewSubscriptionSubtitle;

  /// No description provided for @recurringExpenseDeleteIncome.
  ///
  /// In es, this message translates to:
  /// **'Eliminar ingreso'**
  String get recurringExpenseDeleteIncome;

  /// No description provided for @recurringExpenseDeleteSubscription.
  ///
  /// In es, this message translates to:
  /// **'Eliminar suscripción'**
  String get recurringExpenseDeleteSubscription;

  /// No description provided for @recurringExpenseNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribí un nombre para reconocerla.'**
  String get recurringExpenseNameRequired;

  /// No description provided for @recurringExpenseNameMinLength.
  ///
  /// In es, this message translates to:
  /// **'Usá al menos 3 caracteres.'**
  String get recurringExpenseNameMinLength;

  /// No description provided for @recurringExpenseNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get recurringExpenseNameLabel;

  /// No description provided for @recurringExpenseNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Netflix, alquiler o internet'**
  String get recurringExpenseNameHint;

  /// No description provided for @recurringExpenseAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto por defecto'**
  String get recurringExpenseAmountLabel;

  /// No description provided for @recurringExpenseSaveIncome.
  ///
  /// In es, this message translates to:
  /// **'Guardar ingreso'**
  String get recurringExpenseSaveIncome;

  /// No description provided for @recurringExpenseSaveSubscription.
  ///
  /// In es, this message translates to:
  /// **'Guardar suscripción'**
  String get recurringExpenseSaveSubscription;

  /// No description provided for @recurringExpenseCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría:'**
  String get recurringExpenseCategoryLabel;

  /// No description provided for @recurringExpenseSplitLabel.
  ///
  /// In es, this message translates to:
  /// **'Reparto de gasto:'**
  String get recurringExpenseSplitLabel;

  /// No description provided for @recurringExpenseAmountInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un monto válido.'**
  String get recurringExpenseAmountInvalid;

  /// No description provided for @recurringExpenseAmountPositive.
  ///
  /// In es, this message translates to:
  /// **'El monto debe ser mayor a cero.'**
  String get recurringExpenseAmountPositive;

  /// No description provided for @recurringExpenseDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Se cobra el día:'**
  String get recurringExpenseDayLabel;

  /// No description provided for @recurringExpenseRegularPayerLabel.
  ///
  /// In es, this message translates to:
  /// **'Pagador habitual:'**
  String get recurringExpenseRegularPayerLabel;

  /// No description provided for @expensesNewItemsAddedCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto agregado a la lista} other{{count} productos agregados a la lista}}'**
  String expensesNewItemsAddedCount(int count);

  /// No description provided for @expensesNewItemsDetectedTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevos para tu lista'**
  String get expensesNewItemsDetectedTitle;

  /// No description provided for @expensesNewItemsDetectedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Los agregamos a la lista para la próxima?'**
  String get expensesNewItemsDetectedSubtitle;

  /// No description provided for @expensesNewItemsIgnore.
  ///
  /// In es, this message translates to:
  /// **'Ignorar'**
  String get expensesNewItemsIgnore;

  /// No description provided for @expensesNewItemsAddToList.
  ///
  /// In es, this message translates to:
  /// **'Agregar {count} a lista'**
  String expensesNewItemsAddToList(int count);

  /// Error shown after a partial or failed attempt to add receipt suggestions to Shopping.
  ///
  /// In es, this message translates to:
  /// **'No pudimos agregar todos los productos. Reintentá los que quedaron.'**
  String get expensesNewItemsAddError;

  /// Recoverable error shown when recurring expense templates cannot be loaded.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus gastos recurrentes.'**
  String get expensesRecurringLoadError;

  /// Inline error shown when saving an expense or income fails without exposing technical details.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el movimiento. Intentá de nuevo.'**
  String get expensesFormSaveError;

  /// Recoverable error shown when household members cannot be loaded in the expense form.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los integrantes.'**
  String get expensesFormMembersLoadError;

  /// Snackbar shown when deleting an expense fails after the form closes.
  ///
  /// In es, this message translates to:
  /// **'No pudimos eliminar el movimiento. Intentá de nuevo.'**
  String get expensesDeleteError;

  /// No description provided for @expensesPlannedPaymentTitle.
  ///
  /// In es, this message translates to:
  /// **'{type, select, income{Confirmar cobro} other{Confirmar pago}}'**
  String expensesPlannedPaymentTitle(String type);

  /// No description provided for @expensesPlannedPaymentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{type, select, income{Vas a marcar \"{title}\" como cobrado.} other{Vas a marcar \"{title}\" como pagado.}}'**
  String expensesPlannedPaymentSubtitle(String type, String title);

  /// No description provided for @expensesPlannedPaymentAmountEyebrow.
  ///
  /// In es, this message translates to:
  /// **'MONTO EFECTIVO'**
  String get expensesPlannedPaymentAmountEyebrow;

  /// No description provided for @expensesPlannedPaymentDateEyebrow.
  ///
  /// In es, this message translates to:
  /// **'{type, select, income{FECHA DE COBRO} other{FECHA DE PAGO}}'**
  String expensesPlannedPaymentDateEyebrow(String type);

  /// No description provided for @expensesDetailHeaderIncome.
  ///
  /// In es, this message translates to:
  /// **'Detalle de ingreso'**
  String get expensesDetailHeaderIncome;

  /// No description provided for @expensesDetailHeaderSettlement.
  ///
  /// In es, this message translates to:
  /// **'Detalle de liquidación de balance'**
  String get expensesDetailHeaderSettlement;

  /// No description provided for @expensesDetailHeaderExpense.
  ///
  /// In es, this message translates to:
  /// **'Detalle de gasto'**
  String get expensesDetailHeaderExpense;

  /// No description provided for @expensesDetailPaidBy.
  ///
  /// In es, this message translates to:
  /// **'Pagó {name}'**
  String expensesDetailPaidBy(String name);

  /// No description provided for @expensesDetailNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota:'**
  String get expensesDetailNoteLabel;

  /// No description provided for @expensesDetailPurchasedItems.
  ///
  /// In es, this message translates to:
  /// **'Ítems comprados'**
  String get expensesDetailPurchasedItems;

  /// No description provided for @expensesDetailLabel.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get expensesDetailLabel;

  /// No description provided for @expensesDetailSplitLabel.
  ///
  /// In es, this message translates to:
  /// **'División'**
  String get expensesDetailSplitLabel;

  /// No description provided for @expensesDetailPaidLabel.
  ///
  /// In es, this message translates to:
  /// **'Pagó'**
  String get expensesDetailPaidLabel;

  /// No description provided for @expensesDetailTheirPartLabel.
  ///
  /// In es, this message translates to:
  /// **'Su parte'**
  String get expensesDetailTheirPartLabel;

  /// No description provided for @expensesDetailSplitEqual.
  ///
  /// In es, this message translates to:
  /// **'Dividido equitativamente'**
  String get expensesDetailSplitEqual;

  /// No description provided for @expensesDetailSplitPersonal.
  ///
  /// In es, this message translates to:
  /// **'Gasto solo'**
  String get expensesDetailSplitPersonal;

  /// No description provided for @expensesRecurrentesDayOfMonth.
  ///
  /// In es, this message translates to:
  /// **'Día {day} de cada mes'**
  String expensesRecurrentesDayOfMonth(int day);

  /// No description provided for @expensesRecurrentesPremiumTitle.
  ///
  /// In es, this message translates to:
  /// **'Pagos recurrentes'**
  String get expensesRecurrentesPremiumTitle;

  /// No description provided for @expensesRecurrentesPremiumSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestioná tus suscripciones, alquileres y servicios de forma automática con HomeSync Premium.'**
  String get expensesRecurrentesPremiumSubtitle;

  /// No description provided for @expensesRecurrentesPremiumCta.
  ///
  /// In es, this message translates to:
  /// **'SABER MÁS'**
  String get expensesRecurrentesPremiumCta;

  /// First benefit bullet on the recurring payments premium teaser.
  ///
  /// In es, this message translates to:
  /// **'Alquiler, servicios y suscripciones se registran solos cada mes.'**
  String get expensesRecurrentesPremiumBullet1;

  /// Second benefit bullet on the recurring payments premium teaser.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios antes del vencimiento para que nada se pase.'**
  String get expensesRecurrentesPremiumBullet2;

  /// Third benefit bullet on the recurring payments premium teaser.
  ///
  /// In es, this message translates to:
  /// **'Todos ven qué viene y cuánto falta pagar.'**
  String get expensesRecurrentesPremiumBullet3;

  /// No description provided for @expensesRecurringEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin recurrentes'**
  String get expensesRecurringEmptyTitle;

  /// No description provided for @expensesRecurringEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Creá plantillas para tus suscripciones, alquileres o ingresos fijos.'**
  String get expensesRecurringEmptySubtitle;

  /// No description provided for @expensesRecurringIncomeSection.
  ///
  /// In es, this message translates to:
  /// **'INGRESOS FIJOS'**
  String get expensesRecurringIncomeSection;

  /// No description provided for @expensesRecurringExpenseSection.
  ///
  /// In es, this message translates to:
  /// **'GASTOS FIJOS'**
  String get expensesRecurringExpenseSection;

  /// No description provided for @financeTitleSupermarket.
  ///
  /// In es, this message translates to:
  /// **'Supermercado'**
  String get financeTitleSupermarket;

  /// No description provided for @financeTitleOnlineShopping.
  ///
  /// In es, this message translates to:
  /// **'Compras online'**
  String get financeTitleOnlineShopping;

  /// No description provided for @financeTitleBalanceSettlement.
  ///
  /// In es, this message translates to:
  /// **'Liquidación de balance'**
  String get financeTitleBalanceSettlement;

  /// No description provided for @financeTitlePartnerSettlement.
  ///
  /// In es, this message translates to:
  /// **'Liquidación de pareja'**
  String get financeTitlePartnerSettlement;

  /// No description provided for @financeTitleSalary.
  ///
  /// In es, this message translates to:
  /// **'Sueldo'**
  String get financeTitleSalary;

  /// No description provided for @financeTitleRent.
  ///
  /// In es, this message translates to:
  /// **'Alquiler'**
  String get financeTitleRent;

  /// No description provided for @financeTitleBuildingFees.
  ///
  /// In es, this message translates to:
  /// **'Expensas'**
  String get financeTitleBuildingFees;

  /// No description provided for @financeTitleGas.
  ///
  /// In es, this message translates to:
  /// **'Gas'**
  String get financeTitleGas;

  /// No description provided for @financeTitleElectricity.
  ///
  /// In es, this message translates to:
  /// **'Luz'**
  String get financeTitleElectricity;

  /// No description provided for @financeTitleWater.
  ///
  /// In es, this message translates to:
  /// **'Agua'**
  String get financeTitleWater;

  /// No description provided for @financeTitleInternet.
  ///
  /// In es, this message translates to:
  /// **'Internet'**
  String get financeTitleInternet;

  /// No description provided for @financeTitleNetflix.
  ///
  /// In es, this message translates to:
  /// **'Netflix'**
  String get financeTitleNetflix;

  /// No description provided for @financeTitleMovies.
  ///
  /// In es, this message translates to:
  /// **'Películas'**
  String get financeTitleMovies;

  /// No description provided for @financeTitleInsurance.
  ///
  /// In es, this message translates to:
  /// **'Seguro'**
  String get financeTitleInsurance;

  /// No description provided for @financeTitlePhone.
  ///
  /// In es, this message translates to:
  /// **'Celular'**
  String get financeTitlePhone;

  /// No description provided for @expensesSavingsGoalNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get expensesSavingsGoalNameLabel;

  /// No description provided for @expensesSavingsGoalNameHint.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu objetivo?'**
  String get expensesSavingsGoalNameHint;

  /// No description provided for @expensesSavingsGoalAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto objetivo'**
  String get expensesSavingsGoalAmountLabel;

  /// No description provided for @expensesSavingsGoalAmountHint.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto quieren juntar?'**
  String get expensesSavingsGoalAmountHint;

  /// Error message shown when savings goals fail to load.
  ///
  /// In es, this message translates to:
  /// **'Error: {details}'**
  String savingsLoadError(String details);

  /// Title for the empty state when there are no savings goals.
  ///
  /// In es, this message translates to:
  /// **'No hay metas activas aún'**
  String get savingsEmptyTitle;

  /// Subtitle for the empty state encouraging the user to create a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Empezá a guardar para algo que de verdad les entusiasme.'**
  String get savingsEmptySubtitle;

  /// Generic fallback subtitle for an empty finances/savings state.
  ///
  /// In es, this message translates to:
  /// **'Empezá hoy mismo a organizar tus finanzas del hogar.'**
  String get savingsEmptyFallbackSubtitle;

  /// Label on a savings goal card showing the target amount.
  ///
  /// In es, this message translates to:
  /// **'Meta: {amount}'**
  String savingsGoalTarget(String amount);

  /// Caption under the progress percentage on a savings goal card.
  ///
  /// In es, this message translates to:
  /// **'objetivo'**
  String get savingsGoalProgressCaption;

  /// Label on a savings goal card showing how much has been saved so far.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado: {amount}'**
  String savingsGoalSaved(String amount);

  /// Caption under the saved amount on an active savings goal card.
  ///
  /// In es, this message translates to:
  /// **'ahorrados de {amount}'**
  String savingsGoalSavedOf(String amount);

  /// Button on a savings goal card to add money to the goal.
  ///
  /// In es, this message translates to:
  /// **'Aportar'**
  String get savingsGoalContributeAction;

  /// Title of the new savings goal sheet.
  ///
  /// In es, this message translates to:
  /// **'Nueva Meta'**
  String get savingsNewGoalTitle;

  /// Subtitle of the new savings goal sheet explaining what a goal is. Mode-aware by household type.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, solo{Definí qué querés lograr y cuánto necesitás juntar para hacerlo realidad.} family{Definí qué quiere lograr la familia y cuánto necesitan juntar para hacerlo realidad.} friends{Definan qué quieren lograr y cuánto necesitan juntar para hacerlo realidad.} other{Definí qué quieren lograr en pareja y cuánto necesitan juntar para hacerlo realidad.}}'**
  String savingsNewGoalSubtitle(String mode);

  /// Section header (uppercase eyebrow) for the goal detail fields.
  ///
  /// In es, this message translates to:
  /// **'DETALLE'**
  String get savingsSectionDetail;

  /// Section title for the goal detail fields (name and amount). Mode-aware by household type.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, solo{Qué querés alcanzar} family{Qué quiere alcanzar la familia} friends{Qué quieren alcanzar} other{Qué quieren alcanzar}}'**
  String savingsSectionDetailTitle(String mode);

  /// Section header (uppercase eyebrow) for the goal personalization fields.
  ///
  /// In es, this message translates to:
  /// **'PERSONALIZACIÓN'**
  String get savingsSectionPersonalization;

  /// Section title for the goal personalization fields (emoji and color).
  ///
  /// In es, this message translates to:
  /// **'Dale personalidad'**
  String get savingsSectionPersonalizationTitle;

  /// Label for the emoji picker field when creating a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Emoji'**
  String get savingsFieldEmoji;

  /// Label for the color picker field when creating a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get savingsFieldColor;

  /// Title of the picker sheet for choosing a savings goal emoji/icon.
  ///
  /// In es, this message translates to:
  /// **'Elegí un ícono'**
  String get savingsPickIconTitle;

  /// Title of the picker sheet for choosing a savings goal color.
  ///
  /// In es, this message translates to:
  /// **'Elegí un color'**
  String get savingsPickColorTitle;

  /// Primary button to create a new savings goal.
  ///
  /// In es, this message translates to:
  /// **'Crear Meta'**
  String get savingsCreateGoalAction;

  /// Eyebrow above the goal title in the contribution sheet.
  ///
  /// In es, this message translates to:
  /// **'Ingresar dinero a'**
  String get savingsContributeTo;

  /// Primary button to confirm adding money to a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Aporte'**
  String get savingsConfirmContribution;

  /// Label above the total saved amount in the savings header card.
  ///
  /// In es, this message translates to:
  /// **'Ahorro Total'**
  String get savingsTotalLabel;

  /// Stat label for the number of active savings goals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get savingsStatGoals;

  /// Stat label for the number of completed savings goals.
  ///
  /// In es, this message translates to:
  /// **'Cumplidas'**
  String get savingsStatCompleted;

  /// Section header for the contribution history on a goal card.
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL DE APORTES'**
  String get savingsHistoryTitle;

  /// Section header for completed savings goals.
  ///
  /// In es, this message translates to:
  /// **'Historial de metas'**
  String get savingsCompletedGoalsHistoryTitle;

  /// A single contribution row: who added how much.
  ///
  /// In es, this message translates to:
  /// **'{name} sumó {amount}'**
  String savingsContributionLine(String name, String amount);

  /// A contribution row for a shared savings contribution with multiple participants.
  ///
  /// In es, this message translates to:
  /// **'{names} aportaron {amount}'**
  String savingsSharedContributionLine(String names, String amount);

  /// Fallback name when a contributor's name is unknown.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get savingsContributionSomeone;

  /// Badge shown on a savings goal that reached its target.
  ///
  /// In es, this message translates to:
  /// **'¡Cumplida!'**
  String get savingsCompletedBadge;

  /// Small chip showing a goal's target date.
  ///
  /// In es, this message translates to:
  /// **'Para el {date}'**
  String savingsDeadlineChip(String date);

  /// Overflow menu action to edit a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Editar meta'**
  String get savingsEditAction;

  /// Overflow menu action / confirm button to delete a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get savingsDeleteAction;

  /// Title of the delete-goal confirmation dialog.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar meta?'**
  String get savingsDeleteConfirmTitle;

  /// Body of the delete-goal confirmation dialog.
  ///
  /// In es, this message translates to:
  /// **'Se perderá el registro de \"{title}\".'**
  String savingsDeleteConfirmBody(String title);

  /// Action to archive a completed savings goal.
  ///
  /// In es, this message translates to:
  /// **'Archivar'**
  String get savingsArchiveAction;

  /// Title of the archive-goal confirmation dialog.
  ///
  /// In es, this message translates to:
  /// **'¿Archivar meta cumplida?'**
  String get savingsArchiveConfirmTitle;

  /// Body of the archive-goal confirmation dialog.
  ///
  /// In es, this message translates to:
  /// **'La meta se guardará como cumplida y dejará de aparecer en la lista.'**
  String get savingsArchiveConfirmBody;

  /// Title of the edit savings goal sheet.
  ///
  /// In es, this message translates to:
  /// **'Editar Meta'**
  String get savingsEditGoalTitle;

  /// Primary button to save edits to a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get savingsSaveChangesAction;

  /// Eyebrow above the contribution split selector.
  ///
  /// In es, this message translates to:
  /// **'¿CÓMO REGISTRAR EL APORTE?'**
  String get savingsContributeSplitTitle;

  /// Split option: the contribution comes only from the current user (a gift).
  ///
  /// In es, this message translates to:
  /// **'Solo yo'**
  String get savingsContributeSoloLabel;

  /// Description of the 'solo yo' contribution split option.
  ///
  /// In es, this message translates to:
  /// **'Sale de tu bolsillo, como un regalo.'**
  String get savingsContributeSoloDesc;

  /// Split option: the contribution is shared. Mode-aware by household type.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, family{En familia} friends{Entre todos} solo{Entre todos} other{En pareja}}'**
  String savingsContributeSharedLabel(String mode);

  /// Description of the shared contribution split option. Mode-aware by household type.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, family{Se reparte entre los adultos del hogar.} friends{Se reparte entre quienes conviven.} solo{Se reparte según la economía del hogar.} other{Se reparte entre vos y tu pareja.}}'**
  String savingsContributeSharedDesc(String mode);

  /// Label for the optional note field in the contribution sheet.
  ///
  /// In es, this message translates to:
  /// **'Nota (opcional)'**
  String get savingsNoteLabel;

  /// Hint for the optional note field in the contribution sheet.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué es este aporte?'**
  String get savingsNoteHint;

  /// Label for the optional target date field on a savings goal.
  ///
  /// In es, this message translates to:
  /// **'Fecha objetivo (opcional)'**
  String get savingsTargetDateLabel;

  /// Placeholder shown when a savings goal has no target date.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha límite'**
  String get savingsTargetDateClear;

  /// Surplus-based savings suggestion message.
  ///
  /// In es, this message translates to:
  /// **'Según tu plan, podrías ahorrar {amount} extra este mes. ¡Adelantarías un {percent}% tu meta \"{goal}\"!'**
  String savingsSuggesterMessage(String amount, String percent, String goal);

  /// Call to action on the savings suggestion card.
  ///
  /// In es, this message translates to:
  /// **'Aportar ahora'**
  String get savingsSuggesterCta;

  /// Title of the celebration dialog shown when a goal is reached.
  ///
  /// In es, this message translates to:
  /// **'¡Meta cumplida! 🎉'**
  String get savingsCompletedCelebrationTitle;

  /// Body of the celebration dialog shown when a goal is reached.
  ///
  /// In es, this message translates to:
  /// **'Juntaron todo para \"{title}\". ¡Felicitaciones!'**
  String savingsCompletedCelebrationBody(String title);

  /// Dismiss button on the goal-completed celebration dialog.
  ///
  /// In es, this message translates to:
  /// **'¡Genial!'**
  String get savingsCelebrationDismiss;

  /// Section header for the user's earned badges in the achievements tab.
  ///
  /// In es, this message translates to:
  /// **'Tus Medallas'**
  String get achievementsBadgesSection;

  /// Section header for couple challenge achievements.
  ///
  /// In es, this message translates to:
  /// **'Desafíos de Pareja'**
  String get achievementsCoupleChallengesSection;

  /// Section header for special 'iconic moment' achievements.
  ///
  /// In es, this message translates to:
  /// **'Momentos Icónicos'**
  String get achievementsIconicMomentsSection;

  /// Achievement title for completing the first task as a couple.
  ///
  /// In es, this message translates to:
  /// **'Primeros Pasos'**
  String get achievementsFirstStepsTitle;

  /// Achievement description for completing the first task as a couple.
  ///
  /// In es, this message translates to:
  /// **'Completaste tu primera tarea en pareja.'**
  String get achievementsFirstStepsDesc;

  /// Achievement title for completing 50 tasks together.
  ///
  /// In es, this message translates to:
  /// **'Equipo Imparable'**
  String get achievementsUnstoppableTitle;

  /// Achievement description for completing 50 tasks together.
  ///
  /// In es, this message translates to:
  /// **'Completaron 50 tareas juntos.'**
  String get achievementsUnstoppableDesc;

  /// Achievement title for reaching 5000 accumulated XP.
  ///
  /// In es, this message translates to:
  /// **'Maestros del Hogar'**
  String get achievementsHomeMastersTitle;

  /// Achievement description for reaching 5000 accumulated XP.
  ///
  /// In es, this message translates to:
  /// **'Llegaron a los 5000 XP acumulados.'**
  String get achievementsHomeMastersDesc;

  /// Achievement title for completing 7 special couple challenges.
  ///
  /// In es, this message translates to:
  /// **'Coleccionista de Citas'**
  String get achievementsCollectorTitle;

  /// Achievement title for completing 15 special couple challenges.
  ///
  /// In es, this message translates to:
  /// **'Amor en Movimiento'**
  String get achievementsLoveInMotionTitle;

  /// Achievement title for completing 30 special couple challenges.
  ///
  /// In es, this message translates to:
  /// **'Conexión Profunda'**
  String get achievementsDeepConnectionTitle;

  /// Achievement title for completing all 50 yearly couple challenges.
  ///
  /// In es, this message translates to:
  /// **'Leyendas del Romance'**
  String get achievementsRomanceLegendsTitle;

  /// Achievement description for completing all 50 yearly couple challenges.
  ///
  /// In es, this message translates to:
  /// **'¡Completaron los 50 desafíos del año!'**
  String get achievementsRomanceLegendsDesc;

  /// Achievement description for completing a number of special couple challenges.
  ///
  /// In es, this message translates to:
  /// **'Completaron {count} desafíos especiales.'**
  String achievementsSpecialChallengesDesc(int count);

  /// Iconic moment achievement title for recreating the first date.
  ///
  /// In es, this message translates to:
  /// **'Raíces del Amor'**
  String get achievementsLoveRootsTitle;

  /// Iconic moment achievement description for recreating the first date.
  ///
  /// In es, this message translates to:
  /// **'Recrearon su primera cita.'**
  String get achievementsLoveRootsDesc;

  /// Iconic moment achievement title for a blind/sensory dinner date.
  ///
  /// In es, this message translates to:
  /// **'Cita a Ciegas'**
  String get achievementsBlindDateTitle;

  /// Iconic moment achievement description for a blind/sensory dinner date.
  ///
  /// In es, this message translates to:
  /// **'Completaron una cena a ciegas o sensorial.'**
  String get achievementsBlindDateDesc;

  /// Iconic moment achievement title for designing a shared goals list.
  ///
  /// In es, this message translates to:
  /// **'Arquitectos de Sueños'**
  String get achievementsDreamArchitectsTitle;

  /// Iconic moment achievement description for designing a shared goals list.
  ///
  /// In es, this message translates to:
  /// **'Diseñaron su lista de metas compartidas.'**
  String get achievementsDreamArchitectsDesc;

  /// No description provided for @achievementsSoloMilestonesSection.
  ///
  /// In es, this message translates to:
  /// **'Tus hitos'**
  String get achievementsSoloMilestonesSection;

  /// No description provided for @achievementsSoloFirstStepTitle.
  ///
  /// In es, this message translates to:
  /// **'Primer paso'**
  String get achievementsSoloFirstStepTitle;

  /// No description provided for @achievementsSoloFirstStepDesc.
  ///
  /// In es, this message translates to:
  /// **'Completaste tu primera tarea en tu espacio.'**
  String get achievementsSoloFirstStepDesc;

  /// No description provided for @achievementsSoloRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Rutina en marcha'**
  String get achievementsSoloRoutineTitle;

  /// No description provided for @achievementsSoloRoutineDesc.
  ///
  /// In es, this message translates to:
  /// **'Completaste 50 tareas personales.'**
  String get achievementsSoloRoutineDesc;

  /// No description provided for @achievementsSoloHomeClearTitle.
  ///
  /// In es, this message translates to:
  /// **'Casa más clara'**
  String get achievementsSoloHomeClearTitle;

  /// No description provided for @achievementsSoloHomeClearDesc.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a 5000 XP construyendo tu ritmo.'**
  String get achievementsSoloHomeClearDesc;

  /// No description provided for @achievementsSoloNextSection.
  ///
  /// In es, this message translates to:
  /// **'Próximos hitos'**
  String get achievementsSoloNextSection;

  /// No description provided for @achievementsSoloWeekTitle.
  ///
  /// In es, this message translates to:
  /// **'Semana activa'**
  String get achievementsSoloWeekTitle;

  /// No description provided for @achievementsSoloWeekDesc.
  ///
  /// In es, this message translates to:
  /// **'Sostuviste varias acciones en tu hogar.'**
  String get achievementsSoloWeekDesc;

  /// No description provided for @achievementsSoloRhythmTitle.
  ///
  /// In es, this message translates to:
  /// **'Ritmo propio'**
  String get achievementsSoloRhythmTitle;

  /// No description provided for @achievementsSoloRhythmDesc.
  ///
  /// In es, this message translates to:
  /// **'Tu rutina ya empieza a tener continuidad.'**
  String get achievementsSoloRhythmDesc;

  /// No description provided for @achievementsSoloOwnSpaceTitle.
  ///
  /// In es, this message translates to:
  /// **'Espacio propio'**
  String get achievementsSoloOwnSpaceTitle;

  /// No description provided for @achievementsSoloOwnSpaceDesc.
  ///
  /// In es, this message translates to:
  /// **'Tu progreso personal ya tiene identidad.'**
  String get achievementsSoloOwnSpaceDesc;

  /// Title of the schedule task bottom sheet.
  ///
  /// In es, this message translates to:
  /// **'Programar tarea'**
  String get scheduleTitle;

  /// Subtitle of the schedule task sheet.
  ///
  /// In es, this message translates to:
  /// **'Elegí cómo se repite y quién queda a cargo.'**
  String get scheduleSubtitle;

  /// Uppercase section header for the repetition options.
  ///
  /// In es, this message translates to:
  /// **'REPETICIÓN'**
  String get scheduleSectionRepeat;

  /// Uppercase section header for the assignee selector.
  ///
  /// In es, this message translates to:
  /// **'RESPONSABLE'**
  String get scheduleSectionResponsible;

  /// Repeat mode chip: no repetition.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get scheduleRepeatNone;

  /// Repeat mode chip: daily.
  ///
  /// In es, this message translates to:
  /// **'Diaria'**
  String get scheduleRepeatDaily;

  /// Repeat mode chip: weekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get scheduleRepeatWeekly;

  /// Repeat mode chip: monthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get scheduleRepeatMonthly;

  /// Repeat mode chip: custom recurrence.
  ///
  /// In es, this message translates to:
  /// **'Personalizada'**
  String get scheduleRepeatCustom;

  /// Title for the weekly day picker.
  ///
  /// In es, this message translates to:
  /// **'Elegí el día de la semana'**
  String get scheduleWeeklyTitle;

  /// Helper text for the weekly day picker.
  ///
  /// In es, this message translates to:
  /// **'La tarea se repetirá cada semana en ese día.'**
  String get scheduleWeeklySubtitle;

  /// Title for the monthly day picker.
  ///
  /// In es, this message translates to:
  /// **'Elegí el día del mes'**
  String get scheduleMonthlyTitle;

  /// Helper text for the monthly day picker.
  ///
  /// In es, this message translates to:
  /// **'La tarea se repetirá todos los meses en esa fecha.'**
  String get scheduleMonthlySubtitle;

  /// Custom recurrence tab for selecting weekdays.
  ///
  /// In es, this message translates to:
  /// **'Días'**
  String get scheduleCustomTabDays;

  /// Custom recurrence tab for selecting a day interval.
  ///
  /// In es, this message translates to:
  /// **'Intervalo'**
  String get scheduleCustomTabInterval;

  /// Custom recurrence tab for selecting month days.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get scheduleCustomTabDate;

  /// Prefix before the interval number, e.g. 'Every 3 days'.
  ///
  /// In es, this message translates to:
  /// **'Cada'**
  String get scheduleIntervalEvery;

  /// Tooltip for the button that decreases the interval.
  ///
  /// In es, this message translates to:
  /// **'Disminuir'**
  String get scheduleIntervalDecrease;

  /// Tooltip for the button that increases the interval.
  ///
  /// In es, this message translates to:
  /// **'Aumentar'**
  String get scheduleIntervalIncrease;

  /// Day/days unit shown after the interval number.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{día} other{días}}'**
  String scheduleIntervalDays(int count);

  /// Assignee option meaning the task is open to anyone.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera'**
  String get scheduleAssigneeAnyone;

  /// Subtitle for the 'Anyone' assignee option.
  ///
  /// In es, this message translates to:
  /// **'Queda abierta para quien la quiera hacer.'**
  String get scheduleAssigneeAnyoneSubtitle;

  /// Subtitle for a specific member assignee option.
  ///
  /// In es, this message translates to:
  /// **'Responsable principal de esta tarea.'**
  String get scheduleAssigneeMemberSubtitle;

  /// Fallback name when a household member has no name or email.
  ///
  /// In es, this message translates to:
  /// **'Miembro'**
  String get scheduleAssigneeMemberFallback;

  /// Validation error when no weekday is selected for custom recurrence.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos un día para la repetición personalizada.'**
  String get scheduleErrorPickWeekday;

  /// Validation error when no month day is selected for custom recurrence.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos una fecha para repetir la tarea.'**
  String get scheduleErrorPickMonthDay;

  /// Title of the household invitation sheet.
  ///
  /// In es, this message translates to:
  /// **'Invitar al hogar'**
  String get invitationTitle;

  /// Invitation sheet subtitle for family households.
  ///
  /// In es, this message translates to:
  /// **'Compartí este código con tu familia.'**
  String get invitationSubtitleFamily;

  /// Invitation sheet subtitle for friends/roommates households.
  ///
  /// In es, this message translates to:
  /// **'Compartí este código con quienes viven con vos.'**
  String get invitationSubtitleFriends;

  /// Invitation sheet subtitle for couple/default households.
  ///
  /// In es, this message translates to:
  /// **'Compartí este código para que alguien se sume a tu hogar.'**
  String get invitationSubtitleDefault;

  /// Hint below the invitation code telling the user they can tap to copy it.
  ///
  /// In es, this message translates to:
  /// **'Tocá para copiar'**
  String get invitationTapToCopy;

  /// Snackbar shown when the invitation code is copied to the clipboard.
  ///
  /// In es, this message translates to:
  /// **'Código copiado al portapapeles'**
  String get invitationCopied;

  /// Button label to share the invitation code via WhatsApp.
  ///
  /// In es, this message translates to:
  /// **'Compartir por WhatsApp'**
  String get invitationShareWhatsApp;

  /// Button to retry generating an invitation code after a failure.
  ///
  /// In es, this message translates to:
  /// **'Reintentar generar código'**
  String get invitationRetry;

  /// WhatsApp invitation intro line for couple households.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Sumate conmigo a HomeSync así organizamos las tareas y los gastos de la casa.'**
  String get invitationIntroCouple;

  /// WhatsApp invitation intro line for family households.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Te invito a sumarte a nuestro hogar familiar en HomeSync.'**
  String get invitationIntroFamily;

  /// WhatsApp invitation intro line for friends/roommates households.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Sumate a nuestra convivencia en HomeSync así organizamos mejor la casa.'**
  String get invitationIntroFriends;

  /// Default WhatsApp invitation intro line.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Te invito a sumarte a nuestro hogar en HomeSync.'**
  String get invitationIntroDefault;

  /// Title of the avatar picker bottom sheet.
  ///
  /// In es, this message translates to:
  /// **'Tu Identidad Visual'**
  String get avatarPickerTitle;

  /// Subtitle of the avatar picker sheet.
  ///
  /// In es, this message translates to:
  /// **'Elegí un avatar de la colección o creá el tuyo propio'**
  String get avatarPickerSubtitle;

  /// Snackbar shown when the avatar is updated successfully.
  ///
  /// In es, this message translates to:
  /// **'Avatar actualizado con exito'**
  String get avatarPickerUpdated;

  /// Snackbar shown when updating the avatar fails.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar avatar: {error}'**
  String avatarPickerUpdateError(String error);

  /// Section header for premium avatars.
  ///
  /// In es, this message translates to:
  /// **'Avatares premium'**
  String get avatarPickerPremiumSection;

  /// Section header for the user's AI-generated custom avatars.
  ///
  /// In es, this message translates to:
  /// **'Tus personalizados'**
  String get avatarPickerYourCustomSection;

  /// Hint explaining only the last 6 AI avatars are kept.
  ///
  /// In es, this message translates to:
  /// **'Guardamos los últimos 6 generados por IA.'**
  String get avatarPickerCustomKeepHint;

  /// Label shown under a custom AI-generated avatar.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get avatarPickerCustomName;

  /// Tooltip/action label for deleting a custom AI-generated avatar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar avatar personalizado'**
  String get avatarPickerDeleteCustom;

  /// Title of the confirmation dialog for deleting a custom avatar.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar avatar?'**
  String get avatarPickerDeleteCustomTitle;

  /// Body of the confirmation dialog for deleting a custom avatar.
  ///
  /// In es, this message translates to:
  /// **'Vas a eliminar este avatar personalizado. Si lo estás usando, volvemos al avatar básico.'**
  String get avatarPickerDeleteCustomBody;

  /// Snackbar shown after deleting a custom avatar.
  ///
  /// In es, this message translates to:
  /// **'Avatar personalizado eliminado'**
  String get avatarPickerCustomDeleted;

  /// Snackbar shown when deleting a custom avatar fails.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el avatar: {error}'**
  String avatarPickerCustomDeleteError(String error);

  /// Button for premium users to create a custom avatar (1 per month).
  ///
  /// In es, this message translates to:
  /// **'Crear avatar personalizado (1 por mes)'**
  String get avatarPickerCreateCustom;

  /// Button for non-premium users to unlock custom avatar creation.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear avatar personalizado'**
  String get avatarPickerUnlockCustom;

  /// Title of the AI custom avatar creation card.
  ///
  /// In es, this message translates to:
  /// **'Tu avatar con IA'**
  String get avatarPickerAiCardTitle;

  /// Body of the AI custom avatar creation card explaining the feature and monthly limit.
  ///
  /// In es, this message translates to:
  /// **'Convertí una foto en un avatar ilustrado al estilo HomeSync. Tenés 1 creación por mes.'**
  String get avatarPickerAiCardBody;

  /// Button to start creating an AI custom avatar.
  ///
  /// In es, this message translates to:
  /// **'Crear mi avatar'**
  String get avatarPickerAiCreateButton;

  /// Shown when the monthly AI avatar creation was already used; date is when it becomes available again.
  ///
  /// In es, this message translates to:
  /// **'Ya creaste tu avatar de este mes. Vas a poder crear otro el {date}.'**
  String avatarPickerAiUsedThisMonth(String date);

  /// Title of the option to use the Google account photo as avatar.
  ///
  /// In es, this message translates to:
  /// **'Foto de Google'**
  String get avatarPickerGooglePhotoTitle;

  /// Subtitle of the Google photo avatar option.
  ///
  /// In es, this message translates to:
  /// **'Usá la imagen de tu cuenta de Google como avatar.'**
  String get avatarPickerGooglePhotoSubtitle;

  /// Title of the custom avatar source selection sheet.
  ///
  /// In es, this message translates to:
  /// **'Avatar personalizado'**
  String get avatarPickerCustomSheetTitle;

  /// Explanation of the custom avatar creation limits and premium behavior.
  ///
  /// In es, this message translates to:
  /// **'Tenés 1 creación por mes. Se guarda como avatar nuevo y conservamos tus últimos 6 personalizados. Si dejás Premium, quedan guardados pero bloqueados.'**
  String get avatarPickerCustomSheetBody;

  /// Button to take a photo with the camera for a custom avatar.
  ///
  /// In es, this message translates to:
  /// **'Sacar foto'**
  String get avatarPickerTakePhoto;

  /// Button to choose a photo from the gallery for a custom avatar.
  ///
  /// In es, this message translates to:
  /// **'Elegir de galería'**
  String get avatarPickerChooseFromGallery;

  /// Loading dialog title while generating a custom avatar.
  ///
  /// In es, this message translates to:
  /// **'Creando tu avatar...'**
  String get avatarPickerCreatingTitle;

  /// Loading dialog subtitle while generating a custom avatar.
  ///
  /// In es, this message translates to:
  /// **'Puede tardar unos segundos.'**
  String get avatarPickerCreatingSubtitle;

  /// Snackbar confirming a member was removed from the household.
  ///
  /// In es, this message translates to:
  /// **'✅ {name} ha sido quitado del hogar'**
  String settingsMemberRemoved(String name);

  /// No description provided for @rewardCategoryTreats.
  ///
  /// In es, this message translates to:
  /// **'Mimos'**
  String get rewardCategoryTreats;

  /// No description provided for @rewardCategoryMoments.
  ///
  /// In es, this message translates to:
  /// **'Momentos'**
  String get rewardCategoryMoments;

  /// No description provided for @rewardCategoryPerks.
  ///
  /// In es, this message translates to:
  /// **'Libertades'**
  String get rewardCategoryPerks;

  /// No description provided for @rewardCategoryExperiences.
  ///
  /// In es, this message translates to:
  /// **'Experiencias'**
  String get rewardCategoryExperiences;

  /// No description provided for @rewardCategoryFamily.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get rewardCategoryFamily;

  /// No description provided for @rewardCategoryOther.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get rewardCategoryOther;

  /// No description provided for @rewardTemplateCoffeeMatePrepared.
  ///
  /// In es, this message translates to:
  /// **'Café o mate preparado'**
  String get rewardTemplateCoffeeMatePrepared;

  /// No description provided for @rewardTemplateCoffeeMatePreparedDescription.
  ///
  /// In es, this message translates to:
  /// **'Una pausa rica preparada con cariño'**
  String get rewardTemplateCoffeeMatePreparedDescription;

  /// No description provided for @rewardTemplateSurpriseSnack.
  ///
  /// In es, this message translates to:
  /// **'Snack sorpresa'**
  String get rewardTemplateSurpriseSnack;

  /// No description provided for @rewardTemplateSurpriseSnackDescription.
  ///
  /// In es, this message translates to:
  /// **'Un antojo inesperado para alegrar el día'**
  String get rewardTemplateSurpriseSnackDescription;

  /// No description provided for @rewardTemplateMiniRomanticNote.
  ///
  /// In es, this message translates to:
  /// **'Mini nota romántica'**
  String get rewardTemplateMiniRomanticNote;

  /// No description provided for @rewardTemplateMiniRomanticNoteDescription.
  ///
  /// In es, this message translates to:
  /// **'Un mensaje corto para sonreír'**
  String get rewardTemplateMiniRomanticNoteDescription;

  /// No description provided for @rewardTemplateMassage15Minutes.
  ///
  /// In es, this message translates to:
  /// **'15 minutos de masajes'**
  String get rewardTemplateMassage15Minutes;

  /// No description provided for @rewardTemplateMassage15MinutesDescription.
  ///
  /// In es, this message translates to:
  /// **'Masaje relajante de 15 minutos'**
  String get rewardTemplateMassage15MinutesDescription;

  /// No description provided for @rewardTemplateIceCreamChoice.
  ///
  /// In es, this message translates to:
  /// **'Helado de tu elección'**
  String get rewardTemplateIceCreamChoice;

  /// No description provided for @rewardTemplateIceCreamChoiceDescription.
  ///
  /// In es, this message translates to:
  /// **'Un postre frío para celebrar'**
  String get rewardTemplateIceCreamChoiceDescription;

  /// No description provided for @rewardTemplateMovieNightHome.
  ///
  /// In es, this message translates to:
  /// **'Noche de cine en casa'**
  String get rewardTemplateMovieNightHome;

  /// No description provided for @rewardTemplateMovieNightHomeDescription.
  ///
  /// In es, this message translates to:
  /// **'Película y ambiente especial en casa'**
  String get rewardTemplateMovieNightHomeDescription;

  /// No description provided for @rewardTemplateGamingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Tarde de gaming'**
  String get rewardTemplateGamingAfternoon;

  /// No description provided for @rewardTemplateGamingAfternoonDescription.
  ///
  /// In es, this message translates to:
  /// **'Partida juntos con snacks incluidos'**
  String get rewardTemplateGamingAfternoonDescription;

  /// No description provided for @rewardTemplateBoardGameNight.
  ///
  /// In es, this message translates to:
  /// **'Noche de juegos de mesa'**
  String get rewardTemplateBoardGameNight;

  /// No description provided for @rewardTemplateBoardGameNightDescription.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de juego y risas'**
  String get rewardTemplateBoardGameNightDescription;

  /// No description provided for @rewardTemplateSpecialHomemadeDinner.
  ///
  /// In es, this message translates to:
  /// **'Cena casera especial'**
  String get rewardTemplateSpecialHomemadeDinner;

  /// No description provided for @rewardTemplateSpecialHomemadeDinnerDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu comida favorita hecha en casa'**
  String get rewardTemplateSpecialHomemadeDinnerDescription;

  /// No description provided for @rewardTemplateHomePicnic.
  ///
  /// In es, this message translates to:
  /// **'Picnic en casa'**
  String get rewardTemplateHomePicnic;

  /// No description provided for @rewardTemplateHomePicnicDescription.
  ///
  /// In es, this message translates to:
  /// **'Manta, algo rico y desconexión'**
  String get rewardTemplateHomePicnicDescription;

  /// No description provided for @rewardTemplateNoScreensNight.
  ///
  /// In es, this message translates to:
  /// **'Noche sin pantallas'**
  String get rewardTemplateNoScreensNight;

  /// No description provided for @rewardTemplateNoScreensNightDescription.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de charla y conexión'**
  String get rewardTemplateNoScreensNightDescription;

  /// No description provided for @rewardTemplateEpisodeMarathonChoice.
  ///
  /// In es, this message translates to:
  /// **'Maratón de episodios a elección'**
  String get rewardTemplateEpisodeMarathonChoice;

  /// No description provided for @rewardTemplateEpisodeMarathonChoiceDescription.
  ///
  /// In es, this message translates to:
  /// **'Vos elegís la serie y el ritmo'**
  String get rewardTemplateEpisodeMarathonChoiceDescription;

  /// No description provided for @rewardTemplateNoDishesVoucher.
  ///
  /// In es, this message translates to:
  /// **'Vale por no lavar los platos'**
  String get rewardTemplateNoDishesVoucher;

  /// No description provided for @rewardTemplateNoDishesVoucherDescription.
  ///
  /// In es, this message translates to:
  /// **'Hoy te salvás de esa tarea'**
  String get rewardTemplateNoDishesVoucherDescription;

  /// No description provided for @rewardTemplateChooseMovieVoucher.
  ///
  /// In es, this message translates to:
  /// **'Vale por elegir la peli'**
  String get rewardTemplateChooseMovieVoucher;

  /// No description provided for @rewardTemplateChooseMovieVoucherDescription.
  ///
  /// In es, this message translates to:
  /// **'Vos elegís qué ver'**
  String get rewardTemplateChooseMovieVoucherDescription;

  /// No description provided for @rewardTemplateChooseSeriesWeekVoucher.
  ///
  /// In es, this message translates to:
  /// **'Vale por elegir la serie una semana'**
  String get rewardTemplateChooseSeriesWeekVoucher;

  /// No description provided for @rewardTemplateChooseSeriesWeekVoucherDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu serie, tus reglas por 7 días'**
  String get rewardTemplateChooseSeriesWeekVoucherDescription;

  /// No description provided for @rewardTemplateWeekendPlanVoucher.
  ///
  /// In es, this message translates to:
  /// **'Vale por decidir el plan del finde'**
  String get rewardTemplateWeekendPlanVoucher;

  /// No description provided for @rewardTemplateWeekendPlanVoucherDescription.
  ///
  /// In es, this message translates to:
  /// **'Vos elegís el plan principal'**
  String get rewardTemplateWeekendPlanVoucherDescription;

  /// No description provided for @rewardTemplateSkipOneChoreVoucher.
  ///
  /// In es, this message translates to:
  /// **'Vale por no hacer una tarea puntual'**
  String get rewardTemplateSkipOneChoreVoucher;

  /// No description provided for @rewardTemplateSkipOneChoreVoucherDescription.
  ///
  /// In es, this message translates to:
  /// **'Elegís una tarea para delegar'**
  String get rewardTemplateSkipOneChoreVoucherDescription;

  /// No description provided for @rewardTemplateYesToAnyPlanVoucher.
  ///
  /// In es, this message translates to:
  /// **'Vale por “sí a cualquier plan”'**
  String get rewardTemplateYesToAnyPlanVoucher;

  /// No description provided for @rewardTemplateYesToAnyPlanVoucherDescription.
  ///
  /// In es, this message translates to:
  /// **'Hoy tu idea se cumple'**
  String get rewardTemplateYesToAnyPlanVoucherDescription;

  /// No description provided for @rewardTemplateDinnerOut.
  ///
  /// In es, this message translates to:
  /// **'Cena afuera'**
  String get rewardTemplateDinnerOut;

  /// No description provided for @rewardTemplateDinnerOutDescription.
  ///
  /// In es, this message translates to:
  /// **'Salida a cenar a un lugar especial'**
  String get rewardTemplateDinnerOutDescription;

  /// No description provided for @rewardTemplatePlannedDate.
  ///
  /// In es, this message translates to:
  /// **'Cita planeada completa'**
  String get rewardTemplatePlannedDate;

  /// No description provided for @rewardTemplatePlannedDateDescription.
  ///
  /// In es, this message translates to:
  /// **'Plan completo organizado de principio a fin'**
  String get rewardTemplatePlannedDateDescription;

  /// No description provided for @rewardTemplateChoreFreeDay.
  ///
  /// In es, this message translates to:
  /// **'Día libre de tareas'**
  String get rewardTemplateChoreFreeDay;

  /// No description provided for @rewardTemplateChoreFreeDayDescription.
  ///
  /// In es, this message translates to:
  /// **'Cero obligaciones por todo el día'**
  String get rewardTemplateChoreFreeDayDescription;

  /// No description provided for @rewardTemplateExtraScreen15Minutes.
  ///
  /// In es, this message translates to:
  /// **'15 minutos extra de pantalla'**
  String get rewardTemplateExtraScreen15Minutes;

  /// No description provided for @rewardTemplateExtraScreen15MinutesDescription.
  ///
  /// In es, this message translates to:
  /// **'Un ratito más para jugar o mirar algo.'**
  String get rewardTemplateExtraScreen15MinutesDescription;

  /// No description provided for @rewardTemplateChooseDinner.
  ///
  /// In es, this message translates to:
  /// **'Elegir la cena'**
  String get rewardTemplateChooseDinner;

  /// No description provided for @rewardTemplateChooseDinnerDescription.
  ///
  /// In es, this message translates to:
  /// **'Decidir el menú de una noche en casa.'**
  String get rewardTemplateChooseDinnerDescription;

  /// No description provided for @rewardTemplateIceCreamForEveryone.
  ///
  /// In es, this message translates to:
  /// **'Helado para todos'**
  String get rewardTemplateIceCreamForEveryone;

  /// No description provided for @rewardTemplateIceCreamForEveryoneDescription.
  ///
  /// In es, this message translates to:
  /// **'Salida o pedido de helado familiar.'**
  String get rewardTemplateIceCreamForEveryoneDescription;

  /// No description provided for @rewardTemplateSmallToyPrize.
  ///
  /// In es, this message translates to:
  /// **'Juguete o premio pequeño'**
  String get rewardTemplateSmallToyPrize;

  /// No description provided for @rewardTemplateSmallToyPrizeDescription.
  ///
  /// In es, this message translates to:
  /// **'Canje por algo simple elegido con un adulto.'**
  String get rewardTemplateSmallToyPrizeDescription;

  /// No description provided for @rewardTemplateFamilyMovieNight.
  ///
  /// In es, this message translates to:
  /// **'Noche de peli'**
  String get rewardTemplateFamilyMovieNight;

  /// No description provided for @rewardTemplateFamilyMovieNightDescription.
  ///
  /// In es, this message translates to:
  /// **'Plan simple para disfrutar todos juntos.'**
  String get rewardTemplateFamilyMovieNightDescription;

  /// No description provided for @rewardTemplateOrderTakeout.
  ///
  /// In es, this message translates to:
  /// **'Pedir comida'**
  String get rewardTemplateOrderTakeout;

  /// No description provided for @rewardTemplateOrderTakeoutDescription.
  ///
  /// In es, this message translates to:
  /// **'Una noche sin cocinar para toda la familia.'**
  String get rewardTemplateOrderTakeoutDescription;

  /// No description provided for @rewardTemplateWeekendFamilyPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan del fin de semana'**
  String get rewardTemplateWeekendFamilyPlan;

  /// No description provided for @rewardTemplateWeekendFamilyPlanDescription.
  ///
  /// In es, this message translates to:
  /// **'Elegir una salida o actividad para hacer juntos.'**
  String get rewardTemplateWeekendFamilyPlanDescription;

  /// No description provided for @rewardTemplateSpecialDessert.
  ///
  /// In es, this message translates to:
  /// **'Postre especial'**
  String get rewardTemplateSpecialDessert;

  /// No description provided for @rewardTemplateSpecialDessertDescription.
  ///
  /// In es, this message translates to:
  /// **'Elegir un postre favorito para después de cenar.'**
  String get rewardTemplateSpecialDessertDescription;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Probá de nuevo en un momento.'**
  String get errorGeneric;

  /// No description provided for @errorOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Verificá tu red e intentá de nuevo.'**
  String get errorOffline;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In es, this message translates to:
  /// **'Demasiadas solicitudes. Reintentá en un momento.'**
  String get errorTooManyRequests;

  /// No description provided for @errorServerUnreachable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar con el servidor. Verificá tu red.'**
  String get errorServerUnreachable;

  /// No description provided for @errorTimeout.
  ///
  /// In es, this message translates to:
  /// **'La operación tardó demasiado. Probá de nuevo.'**
  String get errorTimeout;

  /// No description provided for @errorNetworkCheckConnection.
  ///
  /// In es, this message translates to:
  /// **'Error de red: revisá tu conexión'**
  String get errorNetworkCheckConnection;

  /// No description provided for @errorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un error inesperado'**
  String get errorUnexpected;

  /// No description provided for @errorOfflineQueued.
  ///
  /// In es, this message translates to:
  /// **'Estás offline. Acción guardada para luego.'**
  String get errorOfflineQueued;

  /// No description provided for @errorNotAuthenticated.
  ///
  /// In es, this message translates to:
  /// **'Usuario no autenticado'**
  String get errorNotAuthenticated;

  /// No description provided for @errorHouseholdNotFound.
  ///
  /// In es, this message translates to:
  /// **'Hogar no encontrado'**
  String get errorHouseholdNotFound;

  /// No description provided for @avatarErrorImageTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La imagen es demasiado grande. Probá con otra foto.'**
  String get avatarErrorImageTooLarge;

  /// No description provided for @avatarErrorSessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Sesión expirada. Iniciá sesión nuevamente.'**
  String get avatarErrorSessionExpired;

  /// No description provided for @avatarErrorTimeout.
  ///
  /// In es, this message translates to:
  /// **'La generación tardó demasiado. Probá de nuevo en un momento.'**
  String get avatarErrorTimeout;

  /// No description provided for @avatarErrorMonthlyLimit.
  ///
  /// In es, this message translates to:
  /// **'Ya usaste tu creación de avatar de este mes. Vas a poder crear otro el mes que viene.'**
  String get avatarErrorMonthlyLimit;

  /// No description provided for @avatarErrorPremiumRequired.
  ///
  /// In es, this message translates to:
  /// **'Esta función es para usuarios Premium.'**
  String get avatarErrorPremiumRequired;

  /// No description provided for @avatarErrorCreateFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el avatar. Probá de nuevo.'**
  String get avatarErrorCreateFailed;

  /// No description provided for @avatarErrorInvalidResult.
  ///
  /// In es, this message translates to:
  /// **'El generador no devolvió un avatar válido.'**
  String get avatarErrorInvalidResult;

  /// No description provided for @avatarErrorDeleteFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el avatar. Probá de nuevo.'**
  String get avatarErrorDeleteFailed;

  /// No description provided for @avatarErrorSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el avatar generado.'**
  String get avatarErrorSaveFailed;

  /// No description provided for @editTaskDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se va a eliminar \"{title}\" y no se puede deshacer.'**
  String editTaskDeleteBody(String title);

  /// No description provided for @notifTaskAssignedTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea asignada'**
  String get notifTaskAssignedTitle;

  /// No description provided for @notifTaskAssignedBody.
  ///
  /// In es, this message translates to:
  /// **'{actor} te asignó la tarea: {task}'**
  String notifTaskAssignedBody(String actor, String task);

  /// No description provided for @notifTaskCompletedTitle.
  ///
  /// In es, this message translates to:
  /// **'Tarea completada'**
  String get notifTaskCompletedTitle;

  /// No description provided for @notifTaskCompletedBody.
  ///
  /// In es, this message translates to:
  /// **'{actor} completó: {task}'**
  String notifTaskCompletedBody(String actor, String task);

  /// No description provided for @notifTaskPendingApprovalTitle.
  ///
  /// In es, this message translates to:
  /// **'Tarea pendiente de aprobación'**
  String get notifTaskPendingApprovalTitle;

  /// No description provided for @notifTaskPendingApprovalBody.
  ///
  /// In es, this message translates to:
  /// **'{actor} completó \"{task}\"'**
  String notifTaskPendingApprovalBody(String actor, String task);

  /// No description provided for @notifTaskApprovedTitle.
  ///
  /// In es, this message translates to:
  /// **'Tarea aprobada'**
  String get notifTaskApprovedTitle;

  /// No description provided for @notifTaskApprovedBody.
  ///
  /// In es, this message translates to:
  /// **'\"{task}\" fue aprobada. Ganaste {coins} coins.'**
  String notifTaskApprovedBody(String task, int coins);

  /// No description provided for @notifTaskRejectedTitle.
  ///
  /// In es, this message translates to:
  /// **'Tarea no aprobada'**
  String get notifTaskRejectedTitle;

  /// No description provided for @notifTaskRejectedBody.
  ///
  /// In es, this message translates to:
  /// **'Tu tarea \"{task}\" necesita ajustes.'**
  String notifTaskRejectedBody(String task);

  /// No description provided for @notifExpenseAddedTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo movimiento'**
  String get notifExpenseAddedTitle;

  /// No description provided for @notifExpenseAddedBody.
  ///
  /// In es, this message translates to:
  /// **'{actor} {kind, select, groceries{compró en} other{gastó en}} {title} ({amount})'**
  String notifExpenseAddedBody(
      String actor, String kind, String title, String amount);

  /// No description provided for @notifSettlementTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Deuda saldada!'**
  String get notifSettlementTitle;

  /// No description provided for @notifSettlementBody.
  ///
  /// In es, this message translates to:
  /// **'{actor} saldó su deuda de {amount}'**
  String notifSettlementBody(String actor, String amount);

  /// No description provided for @notifWeeklySummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu resumen semanal está listo'**
  String get notifWeeklySummaryTitle;

  /// No description provided for @notifWeeklySummaryBody.
  ///
  /// In es, this message translates to:
  /// **'Mirá cómo cerró la semana del hogar: cumplimiento, MVP y gastos.'**
  String get notifWeeklySummaryBody;

  /// No description provided for @notifPlannedUpcomingTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago próximo: {title}'**
  String notifPlannedUpcomingTitle(String title);

  /// No description provided for @notifPlannedUpcomingBody.
  ///
  /// In es, this message translates to:
  /// **'Vence el {date} - {amount}'**
  String notifPlannedUpcomingBody(String date, String amount);

  /// No description provided for @notifPlannedDueTitle.
  ///
  /// In es, this message translates to:
  /// **'Vence hoy: {title}'**
  String notifPlannedDueTitle(String title);

  /// No description provided for @notifPlannedDueBody.
  ///
  /// In es, this message translates to:
  /// **'Registralo desde Finanzas cuando lo pagues - {amount}'**
  String notifPlannedDueBody(String amount);

  /// No description provided for @financeOnlyConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cambio'**
  String get financeOnlyConfirmTitle;

  /// No description provided for @financeOnlyConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Al {action, select, enable{activar} other{desactivar}} el modo \"Solo finanzas\", TODOS los miembros del hogar verán solo funcionalidades financieras (sin tareas, compras, etc.). Esta configuración se aplica a todo el hogar.'**
  String financeOnlyConfirmBody(String action);

  /// No description provided for @activityFallbackTitle.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get activityFallbackTitle;

  /// No description provided for @activitySettlementTitle.
  ///
  /// In es, this message translates to:
  /// **'Balance equilibrado'**
  String get activitySettlementTitle;

  /// No description provided for @activityTimeNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get activityTimeNow;

  /// No description provided for @activityTimeMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes}m'**
  String activityTimeMinutesAgo(int minutes);

  /// No description provided for @activityTimeHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours}h'**
  String activityTimeHoursAgo(int hours);

  /// No description provided for @activityTimeDoneYesterday.
  ///
  /// In es, this message translates to:
  /// **'Hecha ayer'**
  String get activityTimeDoneYesterday;

  /// No description provided for @activityTimeDoneDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hecha hace {days} días'**
  String activityTimeDoneDaysAgo(int days);

  /// No description provided for @homeLoadingStart.
  ///
  /// In es, this message translates to:
  /// **'Cargando inicio...'**
  String get homeLoadingStart;

  /// No description provided for @homeLoadingHousehold.
  ///
  /// In es, this message translates to:
  /// **'Cargando hogar...'**
  String get homeLoadingHousehold;

  /// No description provided for @homeErrorLoadHousehold.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu hogar.'**
  String get homeErrorLoadHousehold;

  /// No description provided for @homeNoHouseholdTitle.
  ///
  /// In es, this message translates to:
  /// **'No perteneces a un hogar todavía'**
  String get homeNoHouseholdTitle;

  /// No description provided for @homeNoHouseholdSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Creá o unite a un hogar para comenzar.'**
  String get homeNoHouseholdSubtitle;

  /// No description provided for @mainIdentityLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error de carga de identidad. Intentá salir de la app y volver a entrar:'**
  String get mainIdentityLoadError;

  /// No description provided for @notifLoveNoteTitle.
  ///
  /// In es, this message translates to:
  /// **'💌 Tenés una nota especial'**
  String get notifLoveNoteTitle;

  /// No description provided for @notifLoveNoteBody.
  ///
  /// In es, this message translates to:
  /// **'Tu pareja te mandó una nota de amor ❤️'**
  String get notifLoveNoteBody;

  /// No description provided for @contributionTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo se repartió'**
  String get contributionTitle;

  /// No description provided for @contributionEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay tareas completadas esta semana.'**
  String get contributionEmpty;

  /// No description provided for @contributionRhythmLabel.
  ///
  /// In es, this message translates to:
  /// **'Ritmo del hogar'**
  String get contributionRhythmLabel;

  /// Ritmo: semanas activas sobre la ventana. Nunca 'racha'.
  ///
  /// In es, this message translates to:
  /// **'{weeks} de las últimas {window} semanas'**
  String contributionRhythmValue(int weeks, int window);

  /// No description provided for @contributionTasksLabel.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{sin tareas} =1{1 tarea} other{{count} tareas}}'**
  String contributionTasksLabel(int count);

  /// No description provided for @contributionDemandingLabel.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{ninguna de las pesadas} =1{1 de las pesadas} other{{count} de las pesadas}}'**
  String contributionDemandingLabel(int count);

  /// Encabezado de la pestaña Pareja con el lunes de la semana en curso.
  ///
  /// In es, this message translates to:
  /// **'Semana del {date}'**
  String coupleWeekOf(String date);

  /// No description provided for @coupleWeekYou.
  ///
  /// In es, this message translates to:
  /// **'Vos'**
  String get coupleWeekYou;

  /// No description provided for @coupleWeekSplitSemantics.
  ///
  /// In es, this message translates to:
  /// **'Reparto de la semana: vos {mine}, {name} {theirs}.'**
  String coupleWeekSplitSemantics(int mine, String name, int theirs);

  /// No description provided for @coupleWeekReadingBalanced.
  ///
  /// In es, this message translates to:
  /// **'Viene parejo: se repartieron bien la semana.'**
  String get coupleWeekReadingBalanced;

  /// Lectura accionable, nunca un reproche.
  ///
  /// In es, this message translates to:
  /// **'{category}: esta semana lo hizo casi todo {name}.'**
  String coupleWeekReadingCategoryPartner(String category, String name);

  /// No description provided for @coupleWeekReadingCategoryMe.
  ///
  /// In es, this message translates to:
  /// **'{category}: esta semana lo hiciste casi todo vos.'**
  String coupleWeekReadingCategoryMe(String category);

  /// No description provided for @coupleWeekReadingOverallPartner.
  ///
  /// In es, this message translates to:
  /// **'Esta semana la mayoría de las tareas las hizo {name}.'**
  String coupleWeekReadingOverallPartner(String name);

  /// No description provided for @coupleWeekReadingOverallMe.
  ///
  /// In es, this message translates to:
  /// **'Esta semana la mayoría de las tareas las hiciste vos.'**
  String get coupleWeekReadingOverallMe;

  /// No description provided for @coupleWeekProposeTurns.
  ///
  /// In es, this message translates to:
  /// **'Proponer turnarse'**
  String get coupleWeekProposeTurns;

  /// No description provided for @coupleWeekOfferHand.
  ///
  /// In es, this message translates to:
  /// **'Ofrecer una mano'**
  String get coupleWeekOfferHand;

  /// Propuesta pre-redactada; la persona la puede editar antes de mandarla.
  ///
  /// In es, this message translates to:
  /// **'¿Nos turnamos con {category}?'**
  String coupleWeekTurnsProposalTitle(String category);

  /// No description provided for @coupleWeekOfferProposalTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta semana me encargo yo de {category}'**
  String coupleWeekOfferProposalTitle(String category);

  /// No description provided for @coupleWeekTurnsProposalTitleGeneral.
  ///
  /// In es, this message translates to:
  /// **'¿Nos repartimos mejor las tareas de la semana?'**
  String get coupleWeekTurnsProposalTitleGeneral;

  /// No description provided for @coupleWeekOfferProposalTitleGeneral.
  ///
  /// In es, this message translates to:
  /// **'Esta semana me pongo con más tareas'**
  String get coupleWeekOfferProposalTitleGeneral;

  /// No description provided for @coupleWeekSeeTasks.
  ///
  /// In es, this message translates to:
  /// **'Ver tareas'**
  String get coupleWeekSeeTasks;

  /// No description provided for @coupleWeekRemaining.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{No queda nada pendiente esta semana} =1{Queda 1 tarea para esta semana} other{Quedan {count} tareas para esta semana}}'**
  String coupleWeekRemaining(int count);

  /// No description provided for @coupleWeekOverdue.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 vencida} other{{count} vencidas}}'**
  String coupleWeekOverdue(int count);

  /// No description provided for @coupleWeekMoneyTitle.
  ///
  /// In es, this message translates to:
  /// **'La plata'**
  String get coupleWeekMoneyTitle;

  /// No description provided for @coupleWeekMoneySeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver movimientos'**
  String get coupleWeekMoneySeeAll;

  /// No description provided for @coupleWeekMoneyEven.
  ///
  /// In es, this message translates to:
  /// **'Están a mano.'**
  String get coupleWeekMoneyEven;

  /// No description provided for @coupleWeekMoneyYouOwe.
  ///
  /// In es, this message translates to:
  /// **'Le debés {amount} a {name}.'**
  String coupleWeekMoneyYouOwe(String amount, String name);

  /// No description provided for @coupleWeekMoneyTheyOwe.
  ///
  /// In es, this message translates to:
  /// **'{name} te debe {amount}.'**
  String coupleWeekMoneyTheyOwe(String name, String amount);

  /// No description provided for @coupleWeekMoneyPaid.
  ///
  /// In es, this message translates to:
  /// **'Este mes pusiste {mine} y {name} puso {theirs} en gastos compartidos.'**
  String coupleWeekMoneyPaid(String mine, String name, String theirs);

  /// No description provided for @coupleWeekMoneyNoExpenses.
  ///
  /// In es, this message translates to:
  /// **'Todavía no cargaron gastos compartidos este mes.'**
  String get coupleWeekMoneyNoExpenses;

  /// No description provided for @coupleWeekMoneySharedTotal.
  ///
  /// In es, this message translates to:
  /// **'Este mes gastaron {amount} entre los dos.'**
  String coupleWeekMoneySharedTotal(String amount);

  /// No description provided for @coupleWeekMoneySharedPaid.
  ///
  /// In es, this message translates to:
  /// **'Pagaste {mine} · {name} pagó {theirs}'**
  String coupleWeekMoneySharedPaid(String mine, String name, String theirs);

  /// No description provided for @coupleWeekMoneySettle.
  ///
  /// In es, this message translates to:
  /// **'Saldar'**
  String get coupleWeekMoneySettle;

  /// No description provided for @coupleWeekMoneyRecordPayment.
  ///
  /// In es, this message translates to:
  /// **'Registrar pago'**
  String get coupleWeekMoneyRecordPayment;

  /// No description provided for @coupleWeekMoneyError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la plata de este mes.'**
  String get coupleWeekMoneyError;

  /// No description provided for @coupleWeekAsksTitle.
  ///
  /// In es, this message translates to:
  /// **'Entre ustedes'**
  String get coupleWeekAsksTitle;

  /// No description provided for @coupleWeekAsksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Planes, pedidos y charlas pendientes. Siempre se puede decir “ahora no”.'**
  String get coupleWeekAsksSubtitle;

  /// No description provided for @coupleWeekAsksEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nada pendiente entre ustedes.'**
  String get coupleWeekAsksEmpty;

  /// No description provided for @coupleWeekAsksEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Para pedir una mano o proponer un plan, tocá “{action}”.'**
  String coupleWeekAsksEmptyHint(String action);

  /// No description provided for @coupleWeekAskToAnswer.
  ///
  /// In es, this message translates to:
  /// **'Te toca responder'**
  String get coupleWeekAskToAnswer;

  /// No description provided for @coupleWeekAskWaiting.
  ///
  /// In es, this message translates to:
  /// **'Esperando a {name}'**
  String coupleWeekAskWaiting(String name);

  /// No description provided for @coupleWeekAskFrom.
  ///
  /// In es, this message translates to:
  /// **'De {name} · {when}'**
  String coupleWeekAskFrom(String name, String when);

  /// No description provided for @coupleWeekAskFromYou.
  ///
  /// In es, this message translates to:
  /// **'Tuya · {when}'**
  String coupleWeekAskFromYou(String when);

  /// No description provided for @coupleWeekNoteTitle.
  ///
  /// In es, this message translates to:
  /// **'Una nota para {name}'**
  String coupleWeekNoteTitle(String name);

  /// No description provided for @coupleWeekNoteBody.
  ///
  /// In es, this message translates to:
  /// **'Le llega como un sobre al inicio de su app.'**
  String get coupleWeekNoteBody;

  /// No description provided for @coupleProposalPushTitle.
  ///
  /// In es, this message translates to:
  /// **'{name} te propuso algo'**
  String coupleProposalPushTitle(String name);

  /// No description provided for @coupleProposalAnsweredPushTitle.
  ///
  /// In es, this message translates to:
  /// **'{name} respondió tu propuesta'**
  String coupleProposalAnsweredPushTitle(String name);

  /// No description provided for @coupleProposalAnsweredPushBody.
  ///
  /// In es, this message translates to:
  /// **'{answer}: {title}'**
  String coupleProposalAnsweredPushBody(String answer, String title);

  /// No description provided for @loveNotePushTitle.
  ///
  /// In es, this message translates to:
  /// **'💌 {name} te dejó una nota'**
  String loveNotePushTitle(String name);

  /// No description provided for @loveNotePushBody.
  ///
  /// In es, this message translates to:
  /// **'Abrí HomeSync para leerla.'**
  String get loveNotePushBody;

  /// No description provided for @loveNoteEnvelopeFrom.
  ///
  /// In es, this message translates to:
  /// **'{name} te escribió'**
  String loveNoteEnvelopeFrom(String name);

  /// No description provided for @loveNoteEnvelopeSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardada en el hogar'**
  String get loveNoteEnvelopeSaved;

  /// No description provided for @partnerInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'Esto se disfruta de a dos'**
  String get partnerInviteTitle;

  /// No description provided for @partnerInviteBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando se sume tu pareja, acá van a ver cómo se repartió la semana, la plata entre ustedes y lo que se proponen.'**
  String get partnerInviteBody;

  /// No description provided for @partnerInviteCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código para tu pareja'**
  String get partnerInviteCodeLabel;

  /// No description provided for @partnerInviteCodeSemantics.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación {code}. Tocá para copiarlo.'**
  String partnerInviteCodeSemantics(String code);

  /// No description provided for @partnerInviteShare.
  ///
  /// In es, this message translates to:
  /// **'Invitar por WhatsApp'**
  String get partnerInviteShare;

  /// No description provided for @partnerInviteShareOther.
  ///
  /// In es, this message translates to:
  /// **'Compartir por otra app'**
  String get partnerInviteShareOther;

  /// No description provided for @partnerInviteCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get partnerInviteCopy;

  /// No description provided for @partnerInviteMessageCopied.
  ///
  /// In es, this message translates to:
  /// **'Copiamos la invitación: pegala donde quieras.'**
  String get partnerInviteMessageCopied;

  /// No description provided for @partnerInviteHint.
  ///
  /// In es, this message translates to:
  /// **'Tiene que bajar HomeSync, tocar “Tengo un código” y poner este.'**
  String get partnerInviteHint;

  /// No description provided for @partnerInviteHomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Falta que se sume tu pareja'**
  String get partnerInviteHomeTitle;

  /// No description provided for @partnerInviteHomeBody.
  ///
  /// In es, this message translates to:
  /// **'Mandale el código y empiecen a repartir tareas y gastos.'**
  String get partnerInviteHomeBody;

  /// No description provided for @partnerInviteHomeAction.
  ///
  /// In es, this message translates to:
  /// **'Invitar'**
  String get partnerInviteHomeAction;

  /// Mensaje completo de invitación para WhatsApp u otras apps. Incluye el link a la tienda.
  ///
  /// In es, this message translates to:
  /// **'{intro}\n\n1. Bajate HomeSync: {link}\n2. Tocá “Tengo un código” y poné: *{code}*'**
  String invitationShareMessage(String intro, String link, String code);

  /// No description provided for @setupStartTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas y gastos de la casa, parejos.'**
  String get setupStartTitle;

  /// No description provided for @setupStartBody.
  ///
  /// In es, this message translates to:
  /// **'Repartan las tareas, anoten quién pagó qué y vean cómo quedan, sin planillas ni discusiones.'**
  String get setupStartBody;

  /// No description provided for @setupStartBulletTasks.
  ///
  /// In es, this message translates to:
  /// **'Las tareas de la casa, a la vista de los dos'**
  String get setupStartBulletTasks;

  /// No description provided for @setupStartBulletMoney.
  ///
  /// In es, this message translates to:
  /// **'Gastos compartidos y el saldo siempre al día'**
  String get setupStartBulletMoney;

  /// No description provided for @setupStartBulletWeek.
  ///
  /// In es, this message translates to:
  /// **'Un repaso semanal de cómo se repartieron'**
  String get setupStartBulletWeek;

  /// No description provided for @setupStartCreate.
  ///
  /// In es, this message translates to:
  /// **'Empezar mi hogar'**
  String get setupStartCreate;

  /// No description provided for @setupStartJoin.
  ///
  /// In es, this message translates to:
  /// **'Tengo un código'**
  String get setupStartJoin;

  /// No description provided for @setupStartJoinTitle.
  ///
  /// In es, this message translates to:
  /// **'Unirte a un hogar'**
  String get setupStartJoinTitle;

  /// No description provided for @setupStartJoinBody.
  ///
  /// In es, this message translates to:
  /// **'Poné el código de 6 caracteres que te mandaron.'**
  String get setupStartJoinBody;

  /// No description provided for @setupStartJoinNameLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamás?'**
  String get setupStartJoinNameLabel;

  /// No description provided for @setupStartJoinCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get setupStartJoinCodeLabel;

  /// No description provided for @setupStartJoinButton.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get setupStartJoinButton;

  /// No description provided for @setupStartTime.
  ///
  /// In es, this message translates to:
  /// **'Te lleva menos de un minuto.'**
  String get setupStartTime;

  /// No description provided for @setupHouseholdTitle.
  ///
  /// In es, this message translates to:
  /// **'Contanos de tu casa'**
  String get setupHouseholdTitle;

  /// No description provided for @setupHouseholdSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Con esto adaptamos la app a cómo viven.'**
  String get setupHouseholdSubtitle;

  /// No description provided for @setupHouseholdModeLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Con quién compartís la casa?'**
  String get setupHouseholdModeLabel;

  /// No description provided for @setupHouseholdNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get setupHouseholdNameLabel;

  /// No description provided for @setupHouseholdFinanceNote.
  ///
  /// In es, this message translates to:
  /// **'Arrancan dividiendo los gastos 50/50. Lo pueden cambiar cuando quieran en Ajustes.'**
  String get setupHouseholdFinanceNote;

  /// No description provided for @setupFamilyHouseholdNameFor.
  ///
  /// In es, this message translates to:
  /// **'{name} y familia'**
  String setupFamilyHouseholdNameFor(String name);

  /// No description provided for @setupInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{Sumá a tu pareja} family{Sumá a tu familia} friends{Sumá a quienes viven con vos} other{Sumá a alguien más}}'**
  String setupInviteTitle(String mode);

  /// No description provided for @setupInviteBody.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, couple{HomeSync funciona de a dos: cuando se sume, van a ver las tareas, la plata y el repaso de la semana juntos.} family{Cuando se sumen, cada uno va a ver lo que le toca y lo que se comparte.} friends{Cuando se sumen, van a tener las tareas y las cuentas claras entre todos.} other{Compartí el código para que se sumen a tu hogar.}}'**
  String setupInviteBody(String mode);

  /// No description provided for @setupInviteCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu código de invitación'**
  String get setupInviteCodeLabel;

  /// No description provided for @setupInviteHint.
  ///
  /// In es, this message translates to:
  /// **'{mode, select, family{Tienen que bajar HomeSync, tocar “Tengo un código” y poner este.} friends{Tienen que bajar HomeSync, tocar “Tengo un código” y poner este.} other{Tiene que bajar HomeSync, tocar “Tengo un código” y poner este.}}'**
  String setupInviteHint(String mode);

  /// No description provided for @setupInviteLater.
  ///
  /// In es, this message translates to:
  /// **'Lo hago después'**
  String get setupInviteLater;

  /// No description provided for @setupInviteDone.
  ///
  /// In es, this message translates to:
  /// **'Listo, ya lo mandé'**
  String get setupInviteDone;

  /// No description provided for @homeNextStepExpenseTitle.
  ///
  /// In es, this message translates to:
  /// **'Carguen el primer gasto compartido'**
  String get homeNextStepExpenseTitle;

  /// No description provided for @homeNextStepExpenseBody.
  ///
  /// In es, this message translates to:
  /// **'Así la app lleva la cuenta de quién puso qué.'**
  String get homeNextStepExpenseBody;

  /// No description provided for @homeNextStepExpenseAction.
  ///
  /// In es, this message translates to:
  /// **'Cargar'**
  String get homeNextStepExpenseAction;

  /// No description provided for @premiumProductsUnavailableTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los planes'**
  String get premiumProductsUnavailableTitle;

  /// No description provided for @premiumProductsUnavailableBody.
  ///
  /// In es, this message translates to:
  /// **'Revisá tu conexión y probá de nuevo. Si ya pagaste, restaurá tu compra.'**
  String get premiumProductsUnavailableBody;

  /// No description provided for @premiumRestoreNothing.
  ///
  /// In es, this message translates to:
  /// **'No encontramos compras para restaurar.'**
  String get premiumRestoreNothing;

  /// No description provided for @premiumRestoreError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos restaurar la compra. Probá de nuevo.'**
  String get premiumRestoreError;

  /// Reading on the couple week card when only a few tasks (1-3) were done this week, too few to judge the split. Never a reproach.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Va 1 tarea esta semana: es temprano para leer el reparto.} other{Van {count} tareas esta semana: es temprano para leer el reparto.}}'**
  String coupleWeekReadingEarly(int count);

  /// Action on the couple Home balance card when the partner owes the current user: records that the partner already paid them back.
  ///
  /// In es, this message translates to:
  /// **'Registrar pago'**
  String get balanceCardRecordPaymentButton;

  /// Inline error on the couple Home when the recent activity feed fails to load. Shown next to a Retry button.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la actividad.'**
  String get homeActivityLoadError;

  /// Inline error on the Finances tab when the monthly summary card fails to load. Shown next to a Retry button.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el resumen del mes.'**
  String get expensesSummaryLoadError;

  /// Inline error on the Finances tab when the transactions list fails to load. Shown next to a Retry button.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los movimientos.'**
  String get expensesFeedLoadError;

  /// Premium benefit title on the paywall: per-category budgets plus the end-of-month recap. Replaced the old 'Advanced stats' benefit, which had no Premium feature behind it.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos y resumen del mes'**
  String get premiumBenefitBudgetsRecap;

  /// Premium benefit description on the paywall for budgets and the monthly recap.
  ///
  /// In es, this message translates to:
  /// **'Poné topes por categoría y mirá el cierre de cada mes: en qué se fue la plata y quién puso qué.'**
  String get premiumBenefitBudgetsRecapDesc;

  /// Currency name in the Settings currency picker (ARS).
  ///
  /// In es, this message translates to:
  /// **'Peso argentino'**
  String get currencyNameArs;

  /// Currency name in the Settings currency picker (USD).
  ///
  /// In es, this message translates to:
  /// **'Dólar estadounidense'**
  String get currencyNameUsd;

  /// Currency name in the Settings currency picker (EUR).
  ///
  /// In es, this message translates to:
  /// **'Euro'**
  String get currencyNameEur;

  /// Currency name in the Settings currency picker (BRL).
  ///
  /// In es, this message translates to:
  /// **'Real brasileño'**
  String get currencyNameBrl;

  /// Currency name in the Settings currency picker (CLP).
  ///
  /// In es, this message translates to:
  /// **'Peso chileno'**
  String get currencyNameClp;

  /// Currency name in the Settings currency picker (UYU).
  ///
  /// In es, this message translates to:
  /// **'Peso uruguayo'**
  String get currencyNameUyu;

  /// Generic household category label for tasks or activity without a specific category.
  ///
  /// In es, this message translates to:
  /// **'Hogar'**
  String get categoryLabelHome;

  /// Fallback category label when an item has no known category.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get categoryLabelOther;

  /// Weekly family summary hero subtitle: tasks done out of tasks planned this week.
  ///
  /// In es, this message translates to:
  /// **'{planned, plural, =1{{done} de 1 tarea completada.} other{{done} de {planned} tareas completadas.}}'**
  String weeklySummaryTasksDoneBody(int planned, int done);

  /// Weekly family summary completion card title: tasks done, tasks planned and completion percentage.
  ///
  /// In es, this message translates to:
  /// **'{planned, plural, =1{{done} de 1 tarea · {pct}%} other{{done} de {planned} tareas · {pct}%}}'**
  String weeklySummaryCompletionTitle(int planned, int done, int pct);

  /// Change in completed tasks versus the previous week. {delta} is a signed number such as +2 or -1.
  ///
  /// In es, this message translates to:
  /// **'{delta} vs. la semana anterior'**
  String weeklySummaryVsLastWeek(String delta);

  /// Weekly family summary spending card title. {amount} is the formatted shared spending.
  ///
  /// In es, this message translates to:
  /// **'{amount} esta semana'**
  String weeklySummaryExpensesThisWeek(String amount);

  /// Weekly family summary top category card subtitle: total spent and number of expenses in that category.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{amount} en 1 gasto.} other{{amount} en {count} gastos.}}'**
  String weeklySummaryTopCategoryBody(int count, String amount);

  /// Botón para salir del tour guiado (coachmarks) del inicio.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get coachmarkSkip;

  /// Etiqueta chica arriba de una burbuja de gasto en 'Movimientos del hogar' del inicio.
  ///
  /// In es, this message translates to:
  /// **'Gasto del hogar'**
  String get activityBubbleHouseholdExpense;

  /// Etiqueta chica arriba de una burbuja de liquidación (saldar deuda) en 'Movimientos del hogar'.
  ///
  /// In es, this message translates to:
  /// **'Equilibrio'**
  String get activityBubbleSettlement;

  /// Sugerencia de ahorro cuando el sobrante del mes alcanza para terminar la meta. {amount} es lo que le falta a la meta, ya formateado.
  ///
  /// In es, this message translates to:
  /// **'Según tu plan, este mes te sobra plata: con {amount} completás tu meta \"{goal}\".'**
  String savingsSuggesterCompleteMessage(String amount, String goal);

  /// Snackbar al guardar un gasto dividido sin nadie elegido.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos una persona para dividir el gasto.'**
  String get expenseSplitErrorNoMembers;

  /// Snackbar cuando los montos fijos del reparto no suman el total. {amount} ya viene formateado con la moneda.
  ///
  /// In es, this message translates to:
  /// **'Los montos del reparto tienen que sumar el total ({amount}).'**
  String expenseSplitErrorFixedTotal(String amount);

  /// Tarjeta de tarea (familia/amigos): alguien la marcó como hecha y espera revisión.
  ///
  /// In es, this message translates to:
  /// **'{name} la marcó como hecha'**
  String familyTaskCardMarkedDoneBy(String name);

  /// Tarjeta de tarea: pendiente de revisión, vista por quien puede aprobar.
  ///
  /// In es, this message translates to:
  /// **'Lista para revisar'**
  String get familyTaskCardReadyToReview;

  /// Tarjeta de tarea en vista de niño: espera que un adulto la apruebe.
  ///
  /// In es, this message translates to:
  /// **'Esperando aprobación'**
  String get familyTaskCardAwaitingApproval;

  /// Tarjeta de tarea: espera revisión de un adulto.
  ///
  /// In es, this message translates to:
  /// **'Esperando que un adulto la revise'**
  String get familyTaskCardAwaitingAdult;

  /// Tarjeta de tarea sin responsable y vencida.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de coordinar'**
  String get familyTaskCardUnassignedOverdue;

  /// Tarjeta de tarea sin responsable para hoy.
  ///
  /// In es, this message translates to:
  /// **'A coordinar'**
  String get familyTaskCardUnassignedToday;

  /// Tarjeta de tarea en vista de niño: su tarea, vencida.
  ///
  /// In es, this message translates to:
  /// **'Tu misión pendiente'**
  String get familyTaskCardMyMissionOverdue;

  /// Tarjeta de tarea en vista de niño: su tarea.
  ///
  /// In es, this message translates to:
  /// **'Tu misión'**
  String get familyTaskCardMyMission;

  /// Tarjeta de tarea: la tarea es del usuario y está vencida.
  ///
  /// In es, this message translates to:
  /// **'Te quedó pendiente'**
  String get familyTaskCardMineOverdue;

  /// Tarjeta de tarea: la tarea es del usuario, para hoy.
  ///
  /// In es, this message translates to:
  /// **'Te toca hoy'**
  String get familyTaskCardMineToday;

  /// Tarjeta de tarea vencida de otro integrante sin nombre conocido.
  ///
  /// In es, this message translates to:
  /// **'Le quedó a otro integrante'**
  String get familyTaskCardOtherOverdue;

  /// Tarjeta de tarea de otro integrante sin nombre conocido.
  ///
  /// In es, this message translates to:
  /// **'Para otro integrante'**
  String get familyTaskCardOther;

  /// Tarjeta de tarea vencida de otro integrante.
  ///
  /// In es, this message translates to:
  /// **'Le quedó a {name}'**
  String familyTaskCardNamedOverdue(String name);

  /// Tarjeta de tarea de otro integrante.
  ///
  /// In es, this message translates to:
  /// **'Para {name}'**
  String familyTaskCardNamed(String name);

  /// Píldora de urgencia: el usuario puede aprobar la tarea.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get familyTaskCardUrgencyReview;

  /// Píldora de urgencia: la tarea espera revisión.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get familyTaskCardUrgencyInReview;

  /// Píldora de urgencia: tarea vencida.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get familyTaskCardUrgencyOverdue;

  /// Píldora de urgencia: tarea para hoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get familyTaskCardUrgencyToday;

  /// Píldora de urgencia: tarea con fecha futura.
  ///
  /// In es, this message translates to:
  /// **'Próxima'**
  String get familyTaskCardUrgencyUpcoming;

  /// Píldora: la tarea rota entre {count} integrantes.
  ///
  /// In es, this message translates to:
  /// **'Rota entre {count}'**
  String familyTaskCardRotation(int count);

  /// Feed del hogar (familia): alguien saldó una deuda.
  ///
  /// In es, this message translates to:
  /// **'{name} equilibró la cuenta'**
  String familyFeedSettled(String name);

  /// Feed del hogar (familia): alguien terminó una tarea que espera revisión. Sigue el nombre de la tarea.
  ///
  /// In es, this message translates to:
  /// **'{name} dejó lista'**
  String familyFeedLeftReady(String name);

  /// Feed del hogar (familia): alguien completó una tarea. Sigue el nombre de la tarea.
  ///
  /// In es, this message translates to:
  /// **'{name} completó'**
  String familyFeedCompleted(String name);

  /// Feed del hogar (familia): alguien cargó un gasto.
  ///
  /// In es, this message translates to:
  /// **'{name} registró un gasto'**
  String familyFeedAddedExpense(String name);

  /// Feed del hogar (familia): evento sin tipo conocido.
  ///
  /// In es, this message translates to:
  /// **'{name} hizo algo en el hogar'**
  String familyFeedDidSomething(String name);

  /// Feed del hogar: nombre de respaldo cuando no hay nombre.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get familyFeedSomeone;

  /// Feed del hogar: alguien espera que revisen su tarea. Sigue el nombre de la tarea.
  ///
  /// In es, this message translates to:
  /// **'{name} espera revisión de'**
  String familyFeedWaitingReview(String name);

  /// Snackbar al aprobar o devolver una tarea que ya no existe.
  ///
  /// In es, this message translates to:
  /// **'No encontramos esa tarea para revisar.'**
  String get familyFeedTaskNotFound;

  /// Snackbar cuando falla aprobar una tarea.
  ///
  /// In es, this message translates to:
  /// **'No pudimos aprobar la tarea.'**
  String get familyFeedApproveFailed;

  /// Snackbar al aprobar una tarea.
  ///
  /// In es, this message translates to:
  /// **'Tarea aprobada.'**
  String get familyFeedApproved;

  /// Snackbar cuando falla devolver una tarea.
  ///
  /// In es, this message translates to:
  /// **'No pudimos devolver la tarea.'**
  String get familyFeedReturnFailed;

  /// Snackbar al devolver una tarea para que la corrijan.
  ///
  /// In es, this message translates to:
  /// **'La tarea volvió para corregir.'**
  String get familyFeedReturned;

  /// Botón del feed: devolver la tarea para corregir.
  ///
  /// In es, this message translates to:
  /// **'Devolver'**
  String get familyFeedReturn;

  /// Botón del feed: aprobar la tarea.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get familyFeedApprove;

  /// Píldora del feed con las coins que da una tarea.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 coin} other{{count} coins}}'**
  String familyFeedCoins(int count);

  /// Aviso al pie de la lista de tareas del inicio familiar cuando hay más atrasadas que las que se muestran.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Hay 1 tarea atrasada más.} other{Hay {count} tareas atrasadas más.}}'**
  String familyTasksMoreOverdue(int count);

  /// Feed del hogar (familia): alguien canjeó un premio de la tienda con sus coins. El nombre del premio va debajo.
  ///
  /// In es, this message translates to:
  /// **'{name} canjeó un premio'**
  String familyFeedRedeemedReward(String name);

  /// Nombre del color de tema naranja (el original). Lo lee el lector de pantalla en el selector de color de Configuración.
  ///
  /// In es, this message translates to:
  /// **'Naranja'**
  String get settingsPaletteOrange;

  /// Nombre del color de tema casi negro, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsPaletteDark;

  /// Nombre del color de tema índigo, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Índigo'**
  String get settingsPaletteIndigo;

  /// Nombre del color de tema rosa, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Rosa'**
  String get settingsPaletteRose;

  /// Nombre del color de tema verde esmeralda, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Esmeralda'**
  String get settingsPaletteEmerald;

  /// Nombre del color de tema violeta, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Violeta'**
  String get settingsPaletteViolet;

  /// Nombre del color de tema ámbar, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Ámbar'**
  String get settingsPaletteAmber;

  /// Nombre del color de tema cian, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Cian'**
  String get settingsPaletteCyan;

  /// Lectura del lector de pantalla para un color de tema bloqueado sin Premium. name = nombre del color.
  ///
  /// In es, this message translates to:
  /// **'{name}, requiere Premium'**
  String settingsPaletteLocked(String name);

  /// Etiqueta sobre el monto grande del formulario de gasto o ingreso.
  ///
  /// In es, this message translates to:
  /// **'Monto total'**
  String get expensesFormAmountTotalLabel;

  /// Título de la hoja para cargar un ingreso mensual estimado (no crea movimientos, solo sirve para calcular el balance).
  ///
  /// In es, this message translates to:
  /// **'Ingreso mensual estimado'**
  String get estimatedIncomeSheetTitle;

  /// Aclaración bajo el título de la hoja de ingreso estimado.
  ///
  /// In es, this message translates to:
  /// **'Solo para calcular tu balance. No crea movimientos.'**
  String get estimatedIncomeSheetSubtitle;

  /// Etiqueta en mayúsculas sobre el campo del monto del ingreso estimado.
  ///
  /// In es, this message translates to:
  /// **'MONTO NETO MENSUAL'**
  String get estimatedIncomeSheetAmountEyebrow;

  /// Etiqueta en mayúsculas sobre el selector del día del mes en que se cobra.
  ///
  /// In es, this message translates to:
  /// **'DÍA DE COBRO'**
  String get estimatedIncomeSheetPaydayEyebrow;

  /// Botón secundario para borrar el ingreso estimado cargado.
  ///
  /// In es, this message translates to:
  /// **'Quitar ingreso estimado'**
  String get estimatedIncomeSheetRemove;

  /// Lectura del lector de pantalla para cada día del selector de día de cobro.
  ///
  /// In es, this message translates to:
  /// **'Día {day}'**
  String estimatedIncomeSheetDayLabel(int day);

  /// Error en la sección de actividad reciente del inicio familiar, junto a un botón Reintentar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la actividad del hogar.'**
  String get homeFamilyActivityErrorBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
