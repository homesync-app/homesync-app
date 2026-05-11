// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'HomeSync';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app\'s language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAccept => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonNoConnection => 'No internet connection';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSend => 'Send';

  @override
  String get mainTabHome => 'Home';

  @override
  String get mainTabTasks => 'Tasks';

  @override
  String get mainTabExpenses => 'Finance';

  @override
  String get mainTabProgress => 'Progress';

  @override
  String get mainTabShopping => 'Shopping';

  @override
  String get mainTabShoppingChild => 'Store';

  @override
  String householdSocialTabLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Partner',
        'family': 'Family',
        'friends': 'Group',
        'solo': 'My space',
        'other': 'My space',
      },
    );
    return '$_temp0';
  }

  @override
  String householdSocialHubTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Partner',
        'family': 'Family hub',
        'friends': 'Group hub',
        'solo': 'My space',
        'other': 'My space',
      },
    );
    return '$_temp0';
  }

  @override
  String householdSocialHubSubtitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Challenges, prizes, and little rewards to share.',
        'family':
            'Coordination, members, and household agreements for the whole family.',
        'friends':
            'Organization, shared living, and clear splits for your place.',
        'solo': 'All your personal progress in one place.',
        'other': 'All your personal progress in one place.',
      },
    );
    return '$_temp0';
  }

  @override
  String householdDashboardGreeting(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Our Home',
        'family': 'Family Home',
        'friends': 'Our Place',
        'solo': 'My Progress',
        'other': 'My Progress',
      },
    );
    return '$_temp0';
  }

  @override
  String householdBalanceMessage(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'solo': 'Spent this month',
        'other': 'Running balance',
      },
    );
    return '$_temp0';
  }

  @override
  String householdEmptyTasksSubtitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'solo': 'Add your first task to plan your day.',
        'other': 'Add your first task to organize your home.',
      },
    );
    return '$_temp0';
  }

  @override
  String householdMemberLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'Partner',
        'family': 'Family',
        'friends': 'Housemates',
        'solo': 'Me',
        'other': 'Me',
      },
    );
    return '$_temp0';
  }

  @override
  String householdActionMemberLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'with your partner',
        'family': 'with your family',
        'friends': 'with your housemates',
        'solo': 'by myself',
        'other': 'by myself',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsAppBarTitle => 'Settings';

  @override
  String get settingsBackTooltip => 'Back';

  @override
  String get settingsSectionProfileEyebrow => 'PROFILE';

  @override
  String get settingsSectionProfileTitle => 'Your space';

  @override
  String get settingsSectionProfileSubtitle =>
      'Avatar, name, and your account\'s basic info.';

  @override
  String get settingsSectionHouseholdEyebrow => 'HOUSEHOLD';

  @override
  String get settingsSectionHouseholdTitle => 'Shared home';

  @override
  String get settingsSectionHouseholdSubtitle =>
      'Members, invitations, and household rules.';

  @override
  String get settingsSectionAppEyebrow => 'APP';

  @override
  String get settingsSectionAppTitle => 'Preferences';

  @override
  String get settingsSectionAppSubtitle =>
      'Theme, notifications, help, and feedback.';

  @override
  String get settingsSectionAccountEyebrow => 'ACCOUNT';

  @override
  String get settingsSectionAccountTitle => 'Session and security';

  @override
  String get settingsSectionAccountSubtitle =>
      'Sign out or reset your data if you need to.';

  @override
  String get settingsSectionLegalEyebrow => 'LEGAL';

  @override
  String get settingsSectionLegalTitle => 'Privacy';

  @override
  String get settingsSectionLegalSubtitle => 'Privacy policy and terms of use.';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Choose the app\'s visual theme';

  @override
  String get settingsThemeModeTitle => 'Theme mode';

  @override
  String get settingsThemeModeLight => 'Light';

  @override
  String get settingsThemeModeDark => 'Dark';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get settingsThemePaletteTitle => 'Theme color';

  @override
  String get settingsPremiumBadge => 'PREMIUM';

  @override
  String get settingsPremiumTitle => 'HomeSync Premium';

  @override
  String get settingsPremiumActiveSubtitle => 'Premium active';

  @override
  String get settingsPremiumInactiveSubtitle => 'Advanced features';

  @override
  String get settingsPremiumFeatureShoppingFinanceSync =>
      'Shopping → Finance sync';

  @override
  String get settingsPremiumFeatureRecurringPayments =>
      'Recurring payments (subscriptions)';

  @override
  String get settingsPremiumFeatureLoveNotes => 'Love notes on dashboard';

  @override
  String get settingsPremiumFeatureExclusiveAvatars => 'Exclusive avatars';

  @override
  String get settingsMinorPremiumTitle => 'Premium features';

  @override
  String get settingsMinorPremiumChildBody =>
      'Ask your parents to turn on the plan to unlock exclusive avatars, colors, and more 🌟';

  @override
  String get settingsMinorPremiumAdultBody =>
      'The adults in this household can activate the premium plan to unlock extra features.';

  @override
  String get settingsReplayTourTitle => 'Replay walkthrough';

  @override
  String get settingsReplayTourSubtitle => 'Go through the home intro again';

  @override
  String get settingsFeedbackTitle => 'Send feedback';

  @override
  String get settingsFeedbackSubtitle =>
      'Report a bug or suggest an improvement';

  @override
  String get settingsLegalPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsLegalTermsOfUse => 'Terms of Use';

  @override
  String get settingsNotificationsEnabled => '🔔 Notifications on';

  @override
  String get settingsNotificationsDisabled => '🔕 Notifications off';

  @override
  String get settingsProfileNameUpdated => '✅ Name updated';

  @override
  String get settingsAccountReset => '✅ Data reset and household released';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Get alerts for expenses and tasks';

  @override
  String get settingsFaqTitle => 'FAQ';

  @override
  String get settingsFaqSubtitle => 'Learn how HomeSync works';

  @override
  String get settingsLogoutButton => 'Sign out';

  @override
  String get settingsDangerZoneEyebrow => 'DANGER ZONE';

  @override
  String get settingsResetAccountButton => 'Reset account data';

  @override
  String get settingsFeedbackBugTitle => 'Report a bug';

  @override
  String get settingsFeedbackBugSubtitle =>
      'Something not working? Let us know';

  @override
  String get settingsFeedbackSuggestionTitle => 'Suggest an improvement';

  @override
  String get settingsFeedbackSuggestionSubtitle =>
      'Got an idea? We\'d love to hear it';

  @override
  String get settingsLogoutDialogTitle => 'Sign out?';

  @override
  String get settingsLogoutDialogBody =>
      'You\'ll need to sign in again to access your household.';

  @override
  String get settingsLogoutDialogConfirm => 'Sign out';

  @override
  String get settingsResetDialogTitle => 'Reset everything?';

  @override
  String get settingsResetDialogBody =>
      'This will permanently erase all your tasks, expenses, and progress, and remove you from your current household so you can set up a new one or join another.';

  @override
  String get settingsResetDialogConfirm => 'Reset';

  @override
  String get splashLoadingMessage => 'Setting up your shared home.';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String get authSignUpTitle => 'Set up your home';

  @override
  String get authWelcomeSubtitle =>
      'Sign in to your home and keep everything on track.';

  @override
  String get authSignUpSubtitle =>
      'Create your account to start organizing your home.';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authEmailFullHint => 'Email address';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authPasswordHintWithMin => 'Password (min 6 characters)';

  @override
  String get authNameHint => 'Your name or nickname';

  @override
  String get authValidationRequired => 'Required';

  @override
  String get authValidationInvalidEmail => 'Invalid';

  @override
  String get authValidationInvalidPassword => 'Invalid';

  @override
  String get authForgotPasswordLink => 'Forgot your password?';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authTermsAcceptance =>
      'By creating an account you accept our terms and privacy policy.';

  @override
  String get authShowPasswordTooltip => 'Show password';

  @override
  String get authHidePasswordTooltip => 'Hide password';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get authToggleHasAccount => 'Already have an account?';

  @override
  String get authToggleNewToApp => 'New to HomeSync?';

  @override
  String get authToggleSignInLink => 'Sign in';

  @override
  String get authToggleSignUpLink => 'Sign up';

  @override
  String get authForgotDialogTitle => 'Reset password';

  @override
  String get authForgotDialogBody =>
      'We\'ll send you a link to reset your password.';

  @override
  String get authForgotDialogSendButton => 'Send link';

  @override
  String get authForgotInvalidEmail => 'Enter a valid email';

  @override
  String get authForgotEmailSent => 'Check your email to reset your password!';

  @override
  String get authSignUpEmailSent => 'Check your email to confirm your account!';

  @override
  String commonErrorWithDetails(String message) {
    return 'Error: $message';
  }

  @override
  String get commonUserFallback => 'User';

  @override
  String get homeWelcomeMasculine => 'Welcome';

  @override
  String get homeWelcomeFeminine => 'Welcome';

  @override
  String get homeViewWeekButton => 'View week';

  @override
  String get homeAllDoneToday => 'All done for today';

  @override
  String get homeNoActivityYet => 'No activity yet';

  @override
  String get homeHeadlinePrimary => 'Everything important';

  @override
  String get homeSoloHeadlineSecondary => 'in your day';

  @override
  String get homeSoloFocusToday => 'Focus on your goals today 🚀';

  @override
  String get homeSoloBalanceLabel => 'Spent this month';

  @override
  String get homeSoloTasksTitle => 'Your tasks';

  @override
  String get homeSoloAddTaskButton => 'Add task';

  @override
  String get homeSoloActivityTitle => 'Your activity';

  @override
  String get homeCoupleHeadlineSecondary => 'of your home';

  @override
  String get homeCoupleHeadlineConnector => 'with';

  @override
  String get homeCouplePartnerFallback => 'your partner';

  @override
  String get homeCoupleShoppingListTitle => 'Current list';

  @override
  String get homeCoupleTasksTitle => 'Today at home';

  @override
  String get homeCoupleActivityTitle => 'Home activity';

  @override
  String get homeCoupleActivityEmptyTitle => 'No activity yet';

  @override
  String get homeCoupleActivityEmptyBody =>
      'When there\'s a new task or expense, it\'ll show up here.';

  @override
  String get homeCoupleSettlementErrorNoUser =>
      'We couldn\'t identify your user.';

  @override
  String homeCoupleSettlementDialogTitlePay(String partnerName) {
    return 'Settle up with $partnerName';
  }

  @override
  String get homeCoupleSettlementDialogTitleReceive => 'Record settlement';

  @override
  String homeCoupleSettlementDialogBodyPay(String amount, String partnerName) {
    return 'We\'ll record a payment of \$ $amount to settle the balance with $partnerName.';
  }

  @override
  String homeCoupleSettlementDialogBodyReceive(
      String partnerName, String amount) {
    return 'We\'ll record that $partnerName paid you \$ $amount to settle the balance.';
  }

  @override
  String get homeCoupleSettlementDoneBadge => 'Done';

  @override
  String homeCoupleSettlementSuccessPay(String partnerName) {
    return 'Balance settled with $partnerName.';
  }

  @override
  String homeCoupleSettlementSuccessReceive(String partnerName) {
    return 'Settlement recorded with $partnerName.';
  }

  @override
  String homeCoupleSettlementError(String message) {
    return 'Couldn\'t settle the balance: $message';
  }

  @override
  String get commonGreetingMorning => 'Good morning';

  @override
  String get commonGreetingAfternoon => 'Good afternoon';

  @override
  String get commonGreetingEvening => 'Good evening';

  @override
  String get homeViewAllButton => 'See all';

  @override
  String get homeViewListButton => 'View list';

  @override
  String get homeFriendsHeaderSubtitle => 'How the place is doing today.';

  @override
  String get homeFriendsMemberNotFound =>
      'We couldn\'t find your profile in this group.';

  @override
  String get homeFriendsBalancesTitle => 'Group balances';

  @override
  String get homeFriendsBalancesEmptyTitle => 'No balances to show yet.';

  @override
  String get homeFriendsBalancesEmptyBody =>
      'When shared expenses are recorded, you\'ll see each member\'s net balance here.';

  @override
  String get homeFriendsBalanceCardTitle => 'Balance status';

  @override
  String get homeFriendsTasksTitle => 'Group tasks';

  @override
  String get homeFriendsTasksSubtitle =>
      'What\'s still pending to keep things in order.';

  @override
  String get homeFriendsTaskCompleteError =>
      'We couldn\'t complete the task. Try again.';

  @override
  String get homeFriendsShoppingTitle => 'Group shopping';

  @override
  String get homeFriendsShoppingSubtitle => 'What\'s left to buy this week.';

  @override
  String get homeFriendsAllCleanTitle => 'All clean!';

  @override
  String get homeFriendsActivityTitle => 'Group activity';

  @override
  String get homeFriendsActivitySubtitle =>
      'The latest shared activity in the household.';

  @override
  String get homeFriendsActivityEmpty => 'No shared activity yet.';

  @override
  String get homeFamilyMemberNotFound =>
      'We couldn\'t find your profile in this household.';

  @override
  String get homeFamilyMetricCoins => 'Coins';

  @override
  String get homeFamilyAdultFallbackName => 'Family';

  @override
  String get homeFamilyChildHello => 'Hi, ';

  @override
  String get homeFamilyChildFallbackName => 'champ';

  @override
  String get homeFamilyChildHeroTitle => 'Today\'s adventure';

  @override
  String homeFamilyChildHeroBody(String firstName) {
    return '$firstName, every approved mission earns coins for the store.';
  }

  @override
  String get homeFamilyChildRewardsPrompt => 'See what prizes you can earn.';

  @override
  String get homeFamilyChildActivityTitle => 'My achievements';

  @override
  String get homeFamilyActivityTitle => 'Home activity';

  @override
  String get homeFamilyActivityTitleDefault => 'Recent activity';

  @override
  String get homeFamilyActivityEmptyTitle => 'No recent activity yet';

  @override
  String get homeFamilyActivityEmptyBody =>
      'Tasks, expenses, and shopping will show up here.';

  @override
  String get homeFamilyShoppingTitle => 'Household shopping';

  @override
  String get homeFamilyShoppingAllDone => 'List up to date';

  @override
  String homeFamilyShoppingMoreItems(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString more items in the list',
      one: '1 more item in the list',
    );
    return '$_temp0';
  }

  @override
  String get homeFamilyFinanceTitle => 'Family finance';

  @override
  String get homeFamilyFinanceLoadError =>
      'We couldn\'t load the household finances right now.';

  @override
  String get homeFamilyFinanceViewAll => 'See all';

  @override
  String get homeFamilyFinanceMonthSpent => 'Shared spending this month';

  @override
  String get homeFamilyFinanceMonthEmpty => 'No expenses this month';

  @override
  String get familyTasksTitleChild => 'My missions';

  @override
  String get familyTasksTitleTeen => 'Household tasks';

  @override
  String get familyTasksEmptyTitle => 'All caught up';

  @override
  String get familyTasksEmptyChildSubtitle =>
      'You can rest today or check the store.';

  @override
  String get familyTasksEmptyOtherSubtitle => 'No tasks scheduled for today.';

  @override
  String get familyTasksMarkTitle => 'Mark task';

  @override
  String familyTasksMarkBodyApproval(String taskTitle, String actorName) {
    return 'We\'ll mark \"$taskTitle\" as done by $actorName and send it for review.';
  }

  @override
  String familyTasksMarkBodyDirect(String taskTitle, String actorName) {
    return 'We\'ll mark \"$taskTitle\" as done by $actorName.';
  }

  @override
  String get familyTasksActorFallback => 'you';

  @override
  String get familyTasksTakeoverTitle => 'Complete task';

  @override
  String familyTasksTakeoverBody(String ownerName) {
    return 'This task was assigned to $ownerName. If you continue, it\'ll be marked as done by you.';
  }

  @override
  String get familyTasksTakeoverConfirm => 'Complete';

  @override
  String get familyTasksTakeoverOwnerFallback => 'another member';

  @override
  String familyTasksLockedMessage(String ownerName) {
    return 'This task is for $ownerName.';
  }

  @override
  String get familyTasksLockedOwnerFallback => 'someone else';

  @override
  String get familyTasksSubmittedSnack => 'Sent for an adult to review.';

  @override
  String familyTasksSubmitError(String message) {
    return 'We couldn\'t submit the task: $message';
  }

  @override
  String get familyTasksReviewTitle => 'Review task';

  @override
  String familyTasksReviewBody(String performerName, String taskTitle) {
    return '$performerName marked \"$taskTitle\" as done.';
  }

  @override
  String get familyTasksReviewPerformerFallback => 'this member';

  @override
  String get familyTasksReviewApprove => 'Approve task';

  @override
  String get familyTasksReviewReject => 'Send back to fix';

  @override
  String get familyTasksApproveError => 'We couldn\'t approve the task.';

  @override
  String get familyTasksApproveSuccess => 'Task approved.';

  @override
  String familyTasksApproveErrorWithDetails(String message) {
    return 'We couldn\'t approve the task: $message';
  }

  @override
  String get familyTasksRejectSuccess => 'The task is pending again.';

  @override
  String familyTasksRejectError(String message) {
    return 'We couldn\'t send the task back: $message';
  }

  @override
  String get familyWeeklyTitle => 'This week at home';

  @override
  String get familyWeeklyMetricPoints => 'Total points';

  @override
  String get familyWeeklyMetricTasks => 'Tasks closed';

  @override
  String get familyWeeklyMetricStatus => 'Status';

  @override
  String get familyWeeklyStatusActive => 'Active';

  @override
  String get familyWeeklyStatusCalm => 'Calm';

  @override
  String get familyWeeklyRankingTitle => 'Weekly ranking';

  @override
  String get familyWeeklyRankingSubtitle => 'This week';

  @override
  String get familyWeeklyRankingTabAll => 'All';

  @override
  String get familyWeeklyRankingTabAdults => 'Adults';

  @override
  String get familyWeeklyRankingTabKids => 'Kids';

  @override
  String get familyWeeklyRankingMemberFallback => 'Member';

  @override
  String get familyWeeklyRankingEmptyMessage => 'Complete tasks to earn points';

  @override
  String familyWeeklyRankingTabEmptyMessage(String tabLabel) {
    return 'Nobody has earned points in $tabLabel yet';
  }

  @override
  String setupModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Couple',
        'family': 'Family',
        'friends': 'Roommates',
        'solo': 'Just me',
        'other': 'Just me',
      },
    );
    return '$_temp0';
  }

  @override
  String setupModeDescription(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Shared expenses and tasks',
        'family': 'Tasks, shopping, and family tracking',
        'friends': 'Clear accounts between roommates',
        'solo': 'Personal routines and to-dos',
        'other': 'Personal routines and to-dos',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupValuePropEyebrow => 'Your home, in sync';

  @override
  String get setupValuePropTagline => 'The best-organized home starts here.';

  @override
  String get setupValuePropStartButton => 'Get started';

  @override
  String get setupValuePropTimeHint => 'Takes less than 2 minutes';

  @override
  String get setupFeatureTasksTitle => 'Shared tasks';

  @override
  String get setupFeatureTasksDesc =>
      'Organize household tasks and split responsibilities without friction.';

  @override
  String get setupFeatureExpensesTitle => 'Expenses as a team';

  @override
  String get setupFeatureExpensesDesc =>
      'Log expenses, split bills, and keep the balance crystal clear.';

  @override
  String get setupFeatureGamificationTitle => 'Real gamification';

  @override
  String get setupFeatureGamificationDesc =>
      'Turn daily organization into progress, rewards, and motivation.';

  @override
  String get setupFeatureShoppingTitle => 'Synced shopping';

  @override
  String get setupFeatureShoppingDesc =>
      'Real-time shared lists so nobody buys the same thing twice.';

  @override
  String get setupWelcomeTitle => 'Welcome!';

  @override
  String get setupWelcomeBody =>
      'Let\'s get your home ready to start with shared tasks, expenses, and shopping from day one.';

  @override
  String get setupWelcomeBulletQuick => 'Quick setup, under 1 minute.';

  @override
  String get setupWelcomeBulletJoin =>
      'Create a new home or join with an invite code.';

  @override
  String get setupWelcomeStartButton => 'Set up my home';

  @override
  String get setupProfileEyebrow => 'Your profile';

  @override
  String get setupProfileTitle => 'What\'s your name?';

  @override
  String get setupProfileSubtitle =>
      'Customize your profile so your team can recognize you.';

  @override
  String get setupProfileGoogleAvatarHint =>
      'We\'re using your Google photo as a starting point. You can swap it for one of our avatars if you want.';

  @override
  String get setupProfileEmptyAvatarHint =>
      'Pick an avatar and a name to start with a clear identity in your home.';

  @override
  String get setupProfileAvatarLabel => 'Avatar';

  @override
  String get setupModePickerEyebrow => 'Household type';

  @override
  String get setupModePickerTitle => 'Let\'s begin!';

  @override
  String get setupModePickerSubtitle =>
      'How are you going to organize your home?';

  @override
  String get setupSignOutLink => 'Sign out';

  @override
  String get setupSeeFeaturesLink => 'See features';

  @override
  String get setupHouseholdDefaultName => 'My Home';

  @override
  String get setupFamilyDefaultName => 'My family';

  @override
  String get setupSnackJoinedHousehold => 'You joined the household!';

  @override
  String get setupSnackPickAtLeastOneTask => 'Pick at least one task';

  @override
  String get setupSnackUnknownError => 'Unknown error';

  @override
  String get setupSnackOnboardingFailed =>
      'Couldn\'t finish onboarding. Try again.';

  @override
  String get setupSnackCodeCopied => 'Code copied to clipboard! 📋';

  @override
  String get setupSnackWhatsappFailed =>
      'Couldn\'t open WhatsApp. Code copied.';

  @override
  String get setupJoinCodeTitle => 'Enter the code';

  @override
  String get setupConnectEyebrow => 'Connect your home';

  @override
  String get setupConnectTitle => 'Connect your home';

  @override
  String get setupConnectSubtitle =>
      'Create a new team or join with an invite code.';

  @override
  String get setupConnectCreateTitle => 'Create a new home';

  @override
  String get setupConnectCreateDesc =>
      'Generate a code to invite the people you share this place with.';

  @override
  String get setupConnectJoinTitle => 'I have a code';

  @override
  String get setupConnectJoinDesc => 'Enter the code to join the household.';

  @override
  String get setupConnectCodeInputLabel => 'Enter the code';

  @override
  String get setupConnectCreateButton => 'Create my home';

  @override
  String get setupConnectJoinButton => 'Join now';

  @override
  String get setupConnectBackButton => 'Go back';

  @override
  String get setupInvitationEyebrow => 'Invitation';

  @override
  String setupInvitationTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Family created',
        'friends': 'Family created',
        'couple': 'Home created',
        'solo': 'Home created',
        'other': 'Home created',
      },
    );
    return '$_temp0';
  }

  @override
  String setupInvitationSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Share this code with everyone who\'s part of the household.',
        'friends':
            'Share this code with everyone who\'s part of the household.',
        'couple': 'Share this code to invite the other person.',
        'solo': 'Share this code to invite the other person.',
        'other': 'Share this code to invite the other person.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupInvitationCodeEyebrow => 'INVITATION CODE';

  @override
  String get setupInvitationFooter =>
      'You can copy or share it now. You\'ll also find it later in settings.';

  @override
  String get setupInvitationCopyButton => 'Copy';

  @override
  String get setupInvitationShareButton => 'Share';

  @override
  String get setupFamilyBaseEyebrow => 'Family base';

  @override
  String get setupFamilyBaseTitle => 'Family household basics';

  @override
  String get setupFamilyBaseSubtitle =>
      'Before we start, let\'s define how this family is organized.';

  @override
  String get setupFamilyHouseholdNameLabel => 'Household name';

  @override
  String get setupFamilyHouseholdNameHint => 'E.g.: The Smith House';

  @override
  String get setupFamilyRoleLabel => 'Your visible role';

  @override
  String get setupFamilyRoleFather => 'Father';

  @override
  String get setupFamilyRoleMother => 'Mother';

  @override
  String get setupFamilyRoleGuardian => 'Guardian';

  @override
  String get setupFamilyRoleTeen => 'Teen';

  @override
  String get setupSaveAndContinue => 'Save and continue';

  @override
  String get setupConfigureLater => 'Set up later';

  @override
  String get setupExpensesEyebrow => 'Household expenses';

  @override
  String get setupExpensesTitle => 'Splitting expenses';

  @override
  String get setupFriendsExpensesSubtitle =>
      'In a shared place, the simplest approach is splitting everything evenly.';

  @override
  String get setupFriendsExpensesCardTitle => 'Equal split';

  @override
  String get setupFriendsExpensesCardBody =>
      'Each housemate pays the same share. You can adjust individual expenses later.';

  @override
  String get setupFriendsExpensesTipTitle => 'Equal by default';

  @override
  String get setupFriendsExpensesTipDesc =>
      'Best for housemates sharing place-related expenses.';

  @override
  String setupCoupleFamilyExpensesSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple':
            'Let\'s set up a simple base for splitting expenses as a couple.',
        'other': 'Let\'s set up a simple base for splitting shared expenses.',
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
            'You can change this later in settings. We\'re starting with a 50/50 split as a baseline.',
        'other':
            'You can change this later in settings. We\'re starting with an equal split as a baseline.',
      },
    );
    return '$_temp0';
  }

  @override
  String setupCoupleFamilyExpensesSplitLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'YOU / PARTNER',
        'other': 'YOU / OTHERS',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupCoupleFamilyTipEqualTitle => 'Equal (50/50)';

  @override
  String get setupCoupleFamilyTipEqualDescCouple =>
      'Best for similar incomes and responsibilities.';

  @override
  String get setupCoupleFamilyTipEqualDescOther =>
      'Best for households where expenses split evenly.';

  @override
  String get setupCoupleFamilyTipProportionalTitle => 'Proportional';

  @override
  String get setupCoupleFamilyTipProportionalDesc =>
      'Adjusted to what each person can contribute.';

  @override
  String get setupFirstTasksEyebrow => 'First tasks';

  @override
  String setupFirstTasksTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'First tasks for the family',
        'other': 'Customize your home',
      },
    );
    return '$_temp0';
  }

  @override
  String setupFirstTasksSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Pick starter tasks to coordinate the home from day one.',
        'other':
            'Pick the first tasks. We\'ve left a few suggestions to get you started.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupFinishButton => 'Finish setup';

  @override
  String get settingsHouseholdEmptyTitle => 'Start your team!';

  @override
  String get settingsHouseholdEmptyBody =>
      'Join an existing team with an invite code to start sharing tasks and expenses.';

  @override
  String get settingsHouseholdJoinWithCodeButton => 'Join with a code';

  @override
  String get settingsHouseholdTasksToggleTitle => 'Household tasks';

  @override
  String get settingsHouseholdTasksToggleOnSubtitle =>
      'Show tasks, progress, and quick shortcuts.';

  @override
  String get settingsHouseholdTasksToggleOffSubtitle =>
      'Hide tasks and keep only finance and shopping.';

  @override
  String get settingsHouseholdMembersEyebrow => 'MEMBERS';

  @override
  String settingsHouseholdMembersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get settingsHouseholdMemberFallbackName => 'Member';

  @override
  String get settingsHouseholdMemberSelfChip => 'You';

  @override
  String get settingsHouseholdMemberAdminChip => 'Admin';

  @override
  String get settingsHouseholdMemberMenuTooltip => 'Member options';

  @override
  String get settingsHouseholdMemberMenuEditRole => 'Edit role';

  @override
  String get settingsHouseholdMemberMenuRemove => 'Remove from household';

  @override
  String get settingsHouseholdMemberMenuDeleteDummyQa => 'Delete QA dummy';

  @override
  String get settingsHouseholdJoinDialogTitle => 'Join a household';

  @override
  String get settingsHouseholdJoinDialogBody =>
      'Enter the invitation code you were given to join the household:';

  @override
  String get settingsHouseholdJoinDialogConfirm => 'Join';

  @override
  String get settingsHouseholdEditMenuRenameTitle => 'Edit name';

  @override
  String get settingsHouseholdEditMenuRenameSubtitle =>
      'Change your household\'s name';

  @override
  String get settingsHouseholdEditMenuInviteTitle => 'Invitation code';

  @override
  String get settingsHouseholdEditMenuInviteSubtitleExisting =>
      'Share or generate a new code';

  @override
  String get settingsHouseholdEditMenuInviteSubtitleNone =>
      'Generate a code to invite';

  @override
  String settingsHouseholdEditMenuSplitTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Family finances',
        'other': 'Splitting expenses',
      },
    );
    return '$_temp0';
  }

  @override
  String settingsHouseholdEditMenuSplitSubtitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Choose shared or split economy',
        'other': 'Adjust couple percentage',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsHouseholdInviteSheetTitle => 'Invitation code';

  @override
  String get settingsHouseholdInviteSheetSubtitle =>
      'Share this code so others can join your household';

  @override
  String get settingsHouseholdInviteSheetCopyTooltip => 'Copy code';

  @override
  String get settingsHouseholdInviteSheetEmpty => 'No active code';

  @override
  String get settingsHouseholdInviteSheetGenerate => 'Generate code';

  @override
  String get settingsHouseholdInviteSheetRegenerate => 'Generate new code';

  @override
  String get settingsHouseholdRemoveMemberTitle => 'Remove member';

  @override
  String settingsHouseholdRemoveMemberBody(String memberName) {
    return 'Are you sure you want to remove $memberName from this household?';
  }

  @override
  String get settingsHouseholdRemoveMemberConfirm => 'Remove';

  @override
  String get settingsHouseholdDeleteDummyTitle => 'Delete QA dummy';

  @override
  String settingsHouseholdDeleteDummyBody(String memberName) {
    return 'This will remove $memberName as a QA dummy user. If they don\'t belong to another QA household, their technical identity will also be deleted.';
  }

  @override
  String get settingsHouseholdDeleteDummyConfirm => 'Delete dummy';

  @override
  String get settingsHouseholdRenameDialogTitle => 'Household name';

  @override
  String get settingsHouseholdRenameDialogLabel => 'Your name';

  @override
  String get settingsParentModeTitle => 'Parent Mode';

  @override
  String get settingsParentModeSubtitle =>
      'You coordinate, they follow through.';

  @override
  String get settingsParentModeBulletApproval =>
      'Approve tasks before paying out coins.';

  @override
  String get settingsParentModeBulletPerMember =>
      'Per-member view and weekly family summary.';

  @override
  String get settingsParentModeBulletRotation =>
      'Automatic task rotation across members.';

  @override
  String get settingsParentModeUnlockButton => 'Activate Parent Mode';

  @override
  String get settingsParentModeApprovalSectionTitle => 'Task approval';

  @override
  String get settingsParentModeApprovalSectionSubtitle =>
      'When a member completes a task, it stays pending until you approve it.';

  @override
  String get settingsParentModeApprovalOffTitle => 'Off';

  @override
  String get settingsParentModeApprovalOffSubtitle =>
      'Tasks are credited as soon as they\'re completed.';

  @override
  String get settingsParentModeApprovalChildrenOnlyTitle =>
      'Kids and teens only';

  @override
  String get settingsParentModeApprovalChildrenOnlySubtitle =>
      'Adults complete directly; everyone else needs approval.';

  @override
  String get settingsParentModeApprovalAllTitle => 'All members';

  @override
  String get settingsParentModeApprovalAllSubtitle =>
      'Every completion goes through your OK before paying coins.';

  @override
  String get settingsParentModeApprovalPerMemberTitle => 'Per member';

  @override
  String get settingsParentModeApprovalPerMemberSubtitle =>
      'You pick exactly who needs approval in the list below.';

  @override
  String get settingsParentModeInboxIdle => 'Approval inbox';

  @override
  String settingsParentModeInboxWithCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Approval inbox — $countString pending',
      one: 'Approval inbox — 1 pending',
    );
    return '$_temp0';
  }

  @override
  String get settingsParentModeMemberView => 'Per-member view';

  @override
  String get settingsParentModeWeeklySummary => 'Weekly summary';

  @override
  String get settingsParentModePerMemberEmpty =>
      'No other members in the household yet.';

  @override
  String settingsParentModeSaveError(String message) {
    return 'We couldn\'t save the change: $message';
  }

  @override
  String get settingsParentModeMemberTypeChild => 'Child';

  @override
  String get settingsParentModeMemberTypeTeen => 'Teen';

  @override
  String get settingsParentModeMemberTypeAdult => 'Adult';

  @override
  String get settingsParentModeMemberTypeGuardian => 'Guardian';

  @override
  String get settingsParentModeRoleOwnerSuffix => 'Owner';

  @override
  String get settingsParentModeRoleAdminSuffix => 'Admin';

  @override
  String get memberOnboardingWelcomeTitle => 'Welcome to the household!';

  @override
  String get memberOnboardingWelcomeSubtitle =>
      'Pick your role to get started.';

  @override
  String get memberOnboardingEyebrow => 'Household role';

  @override
  String get memberOnboardingTitle => 'Who are you?';

  @override
  String get memberOnboardingSubtitle => 'Pick your role in the household.';

  @override
  String get memberOnboardingFinishButton => 'All set!';

  @override
  String get memberOnboardingSaveError => 'Couldn\'t save. Try again.';

  @override
  String get memberOnboardingRoleDescAdult =>
      'Responsible for the household. Manages expenses and tasks.';

  @override
  String get memberOnboardingRoleDescTeen =>
      'Personal management of expenses and tasks.';

  @override
  String get memberOnboardingRoleDescChild =>
      'Joins in on tasks and can earn rewards.';

  @override
  String get memberOnboardingRoleDescDefault => 'Household member.';

  @override
  String coupleSplitTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Family finances',
        'other': 'Splitting expenses',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitSavedSnack => 'Settings saved successfully';

  @override
  String coupleSplitSaveError(String message) {
    return 'Save failed: $message';
  }

  @override
  String get coupleSplitFamilyHowTitle => 'How expenses are recorded';

  @override
  String get coupleSplitFamilyHowBody =>
      'In a family, the usual setup is a shared economy: expenses stay visible to the household but don\'t create debt between adults. If you need it, you can switch to a couple-style split.';

  @override
  String get coupleSplitFamilySharedTitle => 'Shared economy';

  @override
  String get coupleSplitFamilySharedBody =>
      'Expenses aren\'t split by percentage and don\'t create balances between adults.';

  @override
  String get coupleSplitFamilyDividedTitle => 'Split expenses';

  @override
  String get coupleSplitFamilyDividedBody =>
      'Uses percentages and balances like a couple.';

  @override
  String get coupleSplitInfoTitle => 'How to split expenses?';

  @override
  String get coupleSplitInfoBody =>
      'There\'s no single right way. Every couple is different — the best strategy is whichever gives you both peace of mind.';

  @override
  String get coupleSplitStrategiesTitle => 'Common strategies';

  @override
  String get coupleSplitStrategy5050Title => '50% / 50% (Equal)';

  @override
  String get coupleSplitStrategy5050Body =>
      'Best when both have similar incomes. Each contributes half of shared expenses.';

  @override
  String get coupleSplitStrategy6040Title => '60% / 40% (Proportional)';

  @override
  String get coupleSplitStrategy6040Body =>
      'If there\'s an income gap, whoever earns more contributes a proportionally larger share.';

  @override
  String get coupleSplitCustomTitle => 'Custom setup';

  @override
  String get coupleSplitCustomBody =>
      'Adjust the percentage you\'ll contribute by default.';

  @override
  String get coupleSplitVisualizerYou => 'YOU';

  @override
  String get coupleSplitVisualizerPartner => 'YOUR PARTNER';

  @override
  String get coupleSplitSaveButton => 'Save settings';

  @override
  String get tasksTabList => 'List';

  @override
  String get tasksTabCalendar => 'Calendar';

  @override
  String get tasksFabNew => 'New task';

  @override
  String get tasksLoadingMessage => 'Loading tasks...';

  @override
  String get tasksLoadError => 'We couldn\'t load tasks.';

  @override
  String get tasksLoadMore => 'Load more tasks';

  @override
  String get tasksFilterAll => 'All';

  @override
  String get tasksSearchHint => 'Search task or routine';

  @override
  String get tasksSearchClearTooltip => 'Clear search';

  @override
  String get tasksSearchActiveLabel => 'Searching';

  @override
  String get tasksSearchIdleLabel => 'Search';

  @override
  String get tasksEmptyTitle => 'No tasks set up';

  @override
  String get tasksEmptyFilteredTitle => 'No tasks match those filters';

  @override
  String get tasksEmptySoloSubtitle =>
      'Add your first task to start organizing your home.';

  @override
  String get tasksEmptySharedSubtitle =>
      'Add your first task or turn on a category to start organizing.';

  @override
  String get tasksEmptyFilteredSubtitle =>
      'Try changing the category or creating a new task.';

  @override
  String get tasksPillNoDate => 'No date';

  @override
  String get tasksPillOverdue => 'Overdue';

  @override
  String get tasksPillInReview => 'In review';

  @override
  String get tasksActionSchedule => 'Schedule';

  @override
  String get tasksActionComplete => 'Complete';

  @override
  String get tasksActionCompleting => 'Completing...';

  @override
  String get tasksActionSendForReview => 'Send for review';

  @override
  String get tasksActionSending => 'Sending...';

  @override
  String get tasksStatusWaitingForAdult => 'Waiting for an adult to review.';

  @override
  String get tasksStatusWaitingReview => 'Waiting for review.';

  @override
  String tasksStatusBelongsTo(String ownerName) {
    return 'Belongs to $ownerName.';
  }

  @override
  String tasksTakeoverHeading(String ownerName) {
    return 'This task belongs to $ownerName';
  }

  @override
  String get tasksTakeoverPrompt =>
      'Want to lend a hand and complete it anyway?';

  @override
  String get tasksTakeoverConfirm => 'Complete anyway';

  @override
  String get tasksSnackFrequencyUpdated => 'Frequency updated';

  @override
  String get tasksSnackCompleted => 'Task completed.';

  @override
  String get tasksSnackCompleteError => 'We couldn\'t complete the task.';

  @override
  String get createTaskDifficultyEasy => 'Easy';

  @override
  String get createTaskDifficultyMedium => 'Medium';

  @override
  String get createTaskDifficultyHard => 'Hard';

  @override
  String get createTaskRecurrenceDaily => 'Daily';

  @override
  String get createTaskRecurrenceWeekly => 'Weekly';

  @override
  String get createTaskRecurrenceMonthly => 'Monthly';

  @override
  String get createTaskRecurrenceNone => 'No repeat';

  @override
  String get createTaskRecurrenceCustom => 'Custom';

  @override
  String get createTaskValidationCustomDays =>
      'Pick at least one day for the custom repeat.';

  @override
  String get createTaskValidationCustomMonthDates =>
      'Pick at least one date in the month.';

  @override
  String get createTaskValidationTitleRequired => 'Title required';

  @override
  String get createTaskValidationNumberRequired => 'Enter a number';

  @override
  String get createTaskValidationNotNegative => 'Can\'t be negative';

  @override
  String get createTaskSnackCategoryNotReady =>
      'Hold on a moment and pick a category.';

  @override
  String get createTaskSnackDuplicate =>
      'An identical active task already exists';

  @override
  String get createTaskSnackCreated => 'Task created';

  @override
  String get createTaskHeaderTitle => 'New task';

  @override
  String get createTaskSectionDetailEyebrow => 'DETAILS';

  @override
  String get createTaskSectionDetailTitle => 'What needs to be done';

  @override
  String get createTaskSectionDetailSubtitle =>
      'Give it a clear name so it\'s understood at a glance.';

  @override
  String get createTaskFieldTitleLabel => 'What needs to be done';

  @override
  String get createTaskFieldNotesLabel => 'Notes (optional)';

  @override
  String get createTaskSectionCategoryEyebrow => 'CATEGORY';

  @override
  String get createTaskSectionCategoryTitle => 'Where it fits';

  @override
  String get createTaskSectionCategorySubtitle =>
      'Pick a household area so it shows up organized.';

  @override
  String get createTaskSectionFrequencyEyebrow => 'FREQUENCY';

  @override
  String get createTaskSectionFrequencyTitle => 'When it repeats';

  @override
  String get createTaskSectionFrequencySubtitle =>
      'It can be one-time, recurring, or follow its own pattern.';

  @override
  String get createTaskSectionAssigneeEyebrow => 'ASSIGNEE';

  @override
  String get createTaskSectionAssigneeTitle => 'Who can do it';

  @override
  String get createTaskSectionAssigneeSubtitle =>
      'Leave it open or assign it to someone in particular.';

  @override
  String get createTaskAssigneeAnyone => 'Anyone';

  @override
  String get createTaskSectionValueEyebrow => 'VALUE';

  @override
  String get createTaskSectionValueTitle => 'What it\'s worth';

  @override
  String get createTaskSectionValueSubtitle =>
      'Difficulty quickly sets the points and coins.';

  @override
  String get createTaskRewardsTitle => 'Rewards';

  @override
  String get createTaskCustomizeRewards => 'Customize';

  @override
  String get createTaskFieldCoinsLabel => 'Coins';

  @override
  String get createTaskSectionRotationEyebrow => 'ROTATION';

  @override
  String get createTaskSectionRotationTitle => 'Members take turns';

  @override
  String get createTaskSectionRotationSubtitle =>
      'Pick at least two. Each completion shifts to the next person.';

  @override
  String get createTaskCustomTabWeekdays => 'By day';

  @override
  String get createTaskCustomTabInterval => 'Interval';

  @override
  String get createTaskCustomTabMonthDays => 'Date';

  @override
  String get createTaskCustomRepeatEvery => 'Repeat every';

  @override
  String get createTaskCustomDecreaseTooltip => 'Decrease';

  @override
  String get createTaskCustomIncreaseTooltip => 'Increase';

  @override
  String get createTaskCustomMonthDaysHelp => 'Pick the days of the month';

  @override
  String get createTaskWeekdayMonday => 'M';

  @override
  String get createTaskWeekdayTuesday => 'T';

  @override
  String get createTaskWeekdayWednesday => 'W';

  @override
  String get createTaskWeekdayThursday => 'T';

  @override
  String get createTaskWeekdayFriday => 'F';

  @override
  String get createTaskWeekdaySaturday => 'S';

  @override
  String get createTaskWeekdaySunday => 'S';

  @override
  String get createTaskCreateButton => 'Create task';

  @override
  String get addTaskOptionsHeaderTitle => 'New task';

  @override
  String get addTaskOptionsCustomChip => 'Custom';

  @override
  String get addTaskOptionsAddTooltip => 'Add task';

  @override
  String get addTaskOptionsAllSuggestedDone =>
      'You\'ve added all the suggested ones';

  @override
  String get addTaskOptionsCreateCustomBelow => 'Create a custom task below.';

  @override
  String get addTaskOptionsLoadMore => 'Load more';

  @override
  String get completeTaskSnackPickAtLeastOne =>
      'Pick at least one task to complete.';

  @override
  String get completeTaskSnackPickWho => 'Pick who did it before continuing.';

  @override
  String get completeTaskSnackFutureDate =>
      'The completion date can\'t be in the future.';

  @override
  String get completeTaskSnackTasksMissing =>
      'We couldn\'t find every task you picked. Refresh and try again.';

  @override
  String get completeTaskHeaderTitle => 'Complete tasks';

  @override
  String get completeTaskHeaderSubtitle =>
      'Mark what\'s already done and credit it in one step.';

  @override
  String get completeTaskWhoTitle => 'Who did it?';

  @override
  String get completeTaskWhoSubtitle => 'Pick who helped';

  @override
  String get completeTaskWhenTitle => 'When?';

  @override
  String get completeTaskWhenSubtitle => 'Pick when it was finished';

  @override
  String get completeTaskTimeNow => 'Now';

  @override
  String get completeTaskTimeBefore => 'Before';

  @override
  String get completeTaskTasksTitle => 'Pick tasks';

  @override
  String get completeTaskTasksSubtitle => 'Search and pick what\'s done';

  @override
  String get completeTaskSearchHint => 'Search task...';

  @override
  String get completeTaskNoTasksAvailable => 'No tasks available';

  @override
  String completeTaskRewardVerb(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Earned',
      one: 'Earned',
    );
    return '$_temp0';
  }

  @override
  String get editTaskHeaderTitle => 'Edit task';

  @override
  String get editTaskHeaderSubtitle =>
      'Update this task\'s name, category, and reward.';

  @override
  String get editTaskFieldNameHint => 'Task name';

  @override
  String get editTaskSectionDetailEyebrow => 'DETAILS';

  @override
  String get editTaskSectionCategoryEyebrow => 'CATEGORY';

  @override
  String get editTaskSectionRewardEyebrow => 'REWARD';

  @override
  String get editTaskSnackNameRequired => 'Please enter a name for the task';

  @override
  String get editTaskSaveChanges => 'Save changes';

  @override
  String get editTaskCompleteButton => 'Complete task';

  @override
  String get editTaskSubmitForReviewButton => 'Send for review';

  @override
  String get editTaskSnackSentForReview => 'Task sent for review.';

  @override
  String get editTaskDeleteTitle => 'Delete task';

  @override
  String get editTaskDeleteConfirm => 'Delete';

  @override
  String get taskDetailHeaderTitle => 'Task detail';

  @override
  String get taskDetailFallbackUser => 'Someone';

  @override
  String get taskDetailStatusCompleted => 'Completed';

  @override
  String get taskDetailStatusDisputed => 'Disputed';

  @override
  String get taskDetailStatusPending => 'Pending';

  @override
  String get taskDetailUndoButton => 'Undo';

  @override
  String get taskDetailUndoErrorNotFound => 'Can\'t undo: activity not found';

  @override
  String get taskDetailUndoError => 'Couldn\'t undo';

  @override
  String get taskDetailNoRecord => 'No record';

  @override
  String get taskDetailExperience => 'Experience';

  @override
  String get taskDetailReward => 'Reward';

  @override
  String get taskDetailCompletedBy => 'Completed by';

  @override
  String get taskDetailAssignedTo => 'Assigned to';

  @override
  String get taskDetailComment => 'Comment';

  @override
  String get familyDashboardAppBarTitle => 'Family';

  @override
  String get familyDashboardTitle => 'Per-member view';

  @override
  String get familyDashboardLockedNotice =>
      'This view is for family-household admins.';

  @override
  String get familyDashboardWeekFilter => 'Week';

  @override
  String get familyDashboardEmptyWeek => 'No tasks this week';

  @override
  String get familyDashboardEmptyMonth => 'No tasks this month';

  @override
  String get familyDashboardNoStreak => 'No streak';

  @override
  String get familyDashboardTopCategoriesWeek => 'Top categories this week';

  @override
  String get familyDashboardTopCategoriesMonth => 'Top categories this month';

  @override
  String get familyDashboardStateNoTasks => 'No tasks';

  @override
  String get familyDashboardStateAttention => 'Attention';

  @override
  String get familyDashboardStateToReview => 'To review';

  @override
  String get familyDashboardTrackingWeekly => 'Weekly tracking';

  @override
  String get familyDashboardTrackingMonthly => 'Monthly tracking';

  @override
  String get familyDashboardEmptySubtitleWeek => 'No tasks for this week yet.';

  @override
  String get familyDashboardEmptySubtitleMonth =>
      'No tasks for this month yet.';

  @override
  String get familyDashboardLabelDone => 'Done';

  @override
  String get familyDashboardLabelPending => 'Pending';

  @override
  String get familyDashboardLabelOverdue => 'Overdue';

  @override
  String get familyDashboardLabelToReview => 'To review';

  @override
  String get familyDashboardLockedTitle => 'Per-member view';

  @override
  String get familyDashboardLockedBody =>
      'Turn on Parent Mode to see each family member\'s progress in one place.';

  @override
  String get familyDashboardEmptyTitle => 'No data yet';

  @override
  String get familyDashboardEmptyBody =>
      'When members complete tasks or earn coins, you\'ll see them here.';

  @override
  String get weeklySummaryAppBarTitle => 'Weekly summary';

  @override
  String get weeklySummaryLockedNotice =>
      'This section is for family-household admins.';

  @override
  String get weeklySummaryHeaderTitle => 'Weekly summary';

  @override
  String get weeklySummaryTitleAttention => 'Week needs a closer look';

  @override
  String get weeklySummaryTitleGood => 'Good coordination';

  @override
  String get weeklySummaryTitleQuietWithExpenses => 'Quiet week with expenses';

  @override
  String get weeklySummaryTitleQuiet => 'Quiet week';

  @override
  String get weeklySummaryBodyExpensesNoTasks =>
      'There were shared expenses, but no planned tasks yet.';

  @override
  String get weeklySummaryBodyNoActivity =>
      'Not enough activity yet for a full wrap-up.';

  @override
  String get weeklySummaryNoData => 'No data';

  @override
  String get weeklySummaryMetricTasks => 'Tasks';

  @override
  String get weeklySummaryMetricExpenses => 'Expenses';

  @override
  String get weeklySummaryMetricCompletion => 'Compl.';

  @override
  String get weeklySummaryEyebrowCompletion => 'Completion';

  @override
  String get weeklySummaryEyebrowNeedsBoost => 'Needs a boost';

  @override
  String get weeklySummaryEyebrowMostForgotten => 'Most forgotten';

  @override
  String get weeklySummaryEyebrowExpenses => 'Shared expenses';

  @override
  String get weeklySummaryEyebrowTopCategory => 'Top category';

  @override
  String get weeklySummaryCompletionEmpty => 'No tasks this week';

  @override
  String get weeklySummaryCompletionGoodPace =>
      'Good pace: the week wrapped up on track.';

  @override
  String get weeklySummaryCompletionLockedBody =>
      'When tasks are assigned, you\'ll see real completion and a weekly comparison here.';

  @override
  String get weeklySummaryExpensesNone => 'No shared expenses this week.';

  @override
  String get weeklySummaryExpensesFirst => 'First week with shared expenses.';

  @override
  String get weeklySummaryExpensesSame => 'Same spending as last week.';

  @override
  String get weeklySummaryEmptyTitle => 'Your first summary is on the way';

  @override
  String get weeklySummaryEmptyBody =>
      'Once you start completing tasks and logging expenses we\'ll generate the week\'s report automatically.';

  @override
  String get weeklySummaryLockedTitle => 'Weekly summary';

  @override
  String get weeklySummaryLockedBody =>
      'Turn on Parent Mode to get the week\'s wrap-up with completion, MVP, and expenses.';

  @override
  String get calendarWeekOf => 'Week of';

  @override
  String get calendarNoTasksScheduled => 'No tasks scheduled';

  @override
  String get pendingApprovalsAppBarShortTitle => 'Approvals';

  @override
  String get pendingApprovalsAppBarTitle => 'Pending approvals';

  @override
  String get pendingApprovalsLockedNotice =>
      'This section is for family-household admins.';

  @override
  String get pendingApprovalsApproveButton => 'Approve';

  @override
  String get pendingApprovalsRejectButton => 'Reject';

  @override
  String get pendingApprovalsApproveErrorRetry =>
      'We couldn\'t approve the task. Try again.';

  @override
  String get pendingApprovalsRejectedSnack => 'Task rejected.';

  @override
  String get pendingApprovalsRejectDialogTitle => 'Reason for rejection';

  @override
  String get pendingApprovalsRejectDialogHint =>
      'Why isn\'t it approved (optional)';

  @override
  String get pendingApprovalsEmptyTitle => 'Nothing pending right now';

  @override
  String get pendingApprovalsEmptyBody =>
      'When someone completes a task, it\'ll show up here for you to review.';

  @override
  String get pendingApprovalsLockedTitle => 'Task approvals';

  @override
  String get pendingApprovalsLockedBody =>
      'Turn on Parent Mode to review and approve what each household member completes before crediting coins.';

  @override
  String get expensesTabMovements => 'Activity';

  @override
  String get expensesTabRecurring => 'Recurring';

  @override
  String get expensesTabGoals => 'Goals';

  @override
  String get expensesFabMovement => 'Entry';

  @override
  String get expensesFabNewSubscription => 'New subscription';

  @override
  String get expensesFabNewGoal => 'New goal';

  @override
  String get expensesActivityRecentEyebrow => 'RECENT ACTIVITY';

  @override
  String get expensesActivityEmpty => 'No recent activity';

  @override
  String get expensesDateToday => 'TODAY';

  @override
  String get expensesDateYesterday => 'YESTERDAY';

  @override
  String get expensesDateTomorrow => 'TOMORROW';

  @override
  String get expensesSummaryMainBalance => 'YOUR CURRENT BALANCE';

  @override
  String get expensesSummaryMainProjected => 'MONTH PROJECTED TOTAL';

  @override
  String get expensesSummaryMainExpenses => 'MONTH EXPENSES';

  @override
  String get expensesStatTileEstimatedIncome => 'Estimated income';

  @override
  String get expensesStatTileIncomes => 'Income';

  @override
  String get expensesStatTilePaid => 'Paid';

  @override
  String get expensesStatTileExpenses => 'Expenses';

  @override
  String get expensesStatTilePending => 'Pending';

  @override
  String get expensesProjectionPendingShare => 'Your pending share';

  @override
  String get expensesProjectionEstimated => 'Estimated close';

  @override
  String get expensesProjectionTitle => 'Projection breakdown';

  @override
  String get expensesProjectionSubtitle =>
      'Here\'s how we arrive at your end-of-month estimate.';

  @override
  String get expensesProjectionRowBalance => 'Your current balance';

  @override
  String get expensesProjectionRowEstimated => 'Your estimated close';

  @override
  String get expensesPendingDetailsEyebrow => 'PENDING DETAILS';

  @override
  String get expensesGotIt => 'Got it';

  @override
  String get expensesIncomeBreakdownTitle => 'Income breakdown';

  @override
  String get expensesIncomeBreakdownSubtitle =>
      'Your income recorded this month.';

  @override
  String get expensesExpensesBreakdownTitle => 'Expenses breakdown';

  @override
  String get expensesExpensesBreakdownSubtitle =>
      'Your expenses paid this month.';

  @override
  String get expensesPendingBreakdownTitle => 'Your Pending Share';

  @override
  String get expensesPendingBreakdownSubtitle =>
      'What you owe on this month\'s planned expenses.';

  @override
  String get expensesPendingBreakdownTotalLabel => 'Your total pending';

  @override
  String get expensesBreakdownTotalLabel => 'Month total';

  @override
  String get expensesBreakdownEmpty => 'No entries recorded';

  @override
  String get expensesBreakdownMovementsEyebrow => 'ENTRIES';

  @override
  String get expensesPlannedSkip => 'Skip';

  @override
  String get expensesPlannedPay => 'Pay';

  @override
  String expensesPlannedPaymentSnack(String title) {
    return 'Payment for \"$title\" recorded';
  }

  @override
  String get expensesPlannedBadgeUpcoming => 'UPCOMING';

  @override
  String get expensesPlannedBadgePending => 'PENDING';

  @override
  String get expensesPlannedBadgeDueToday => 'DUE TODAY';

  @override
  String get expensesPlannedBadgeTomorrow => 'TOMORROW';

  @override
  String get expensesPlannedBadgeSoon => 'DUE SOON';

  @override
  String get expensesDeleteDialogTitle => 'Delete entry?';

  @override
  String get expensesDeleteDialogBody => 'This action can\'t be undone.';

  @override
  String get expensesDeletedSnack => 'Entry deleted';

  @override
  String get expensesTypeBadgeGift => 'Gift';

  @override
  String get expensesTypeBadgeShared => 'Shared';

  @override
  String get expensesTypeBadgePersonal => 'Personal';

  @override
  String get expensesSettlementCardTitle => 'Balance settlement';

  @override
  String expensesSettlementCardBody(String name) {
    return '$name settled the balance';
  }

  @override
  String get expensesEmptyDefaultSubtitle =>
      'Start organizing your household finances today.';

  @override
  String expensesFormOcrError(String error) {
    return 'Couldn\'t read the receipt: $error';
  }

  @override
  String get expensesFormOcrLowConfidence =>
      'Receipt hard to read — check the data before saving';

  @override
  String get expensesFormValidationAmountRequired => 'Enter a valid amount.';

  @override
  String get expensesFormValidationNoHousehold =>
      'You don\'t belong to a household';

  @override
  String get expensesFormSavedIncome => 'Income saved';

  @override
  String get expensesFormSavedExpense => 'Expense saved';

  @override
  String get expensesFormUpdatedExpense => 'Updated';

  @override
  String get expensesFormDeleteDialogTitle => 'Delete expense?';

  @override
  String get expensesFormDeleteDialogBody => 'This action can\'t be undone.';

  @override
  String get expensesFormSectionDetailEyebrow => 'DETAILS';

  @override
  String get expensesFormSectionDetailTitleIncome => 'Where did it come from?';

  @override
  String get expensesFormSectionDetailTitleExpense => 'What are you logging?';

  @override
  String get expensesFormSectionDetailSubtitleIncome =>
      'Give it a clear name so you can recognize this income faster.';

  @override
  String get expensesFormSectionDetailSubtitleExpense =>
      'Give it a simple name to find this expense at a glance.';

  @override
  String get expensesFormSectionContextEyebrow => 'CONTEXT';

  @override
  String get expensesFormSectionContextTitleIncome =>
      'When and who received it';

  @override
  String get expensesFormSectionContextTitleExpense => 'When and who paid';

  @override
  String get expensesFormSectionContextSubtitle =>
      'This data organizes the movement within the household.';

  @override
  String get expensesFormSectionCategoryEyebrow => 'CATEGORY';

  @override
  String get expensesFormSectionCategoryTitleIncome =>
      'How do you want to classify it';

  @override
  String get expensesFormSectionCategoryTitleExpense =>
      'Where does this expense go';

  @override
  String get expensesFormSectionCategorySubtitle =>
      'You can pick one, but we also suggest it automatically based on how you describe it.';

  @override
  String get expensesFormSectionSplitEyebrow => 'SPLIT';

  @override
  String get expensesFormSectionSplitTitleIncome => 'How is this income split';

  @override
  String get expensesFormSectionSplitTitleExpense =>
      'How is this expense split';

  @override
  String get expensesFormSectionSplitSubtitle =>
      'Define if it\'s shared, fixed, a gift, or personal.';

  @override
  String get expensesFormFieldDate => 'Date';

  @override
  String get expensesFormFieldPayer => 'Paid by';

  @override
  String get expensesFormFieldCategory => 'Category';

  @override
  String get expensesFormShoppingUnlinkedSnack => 'Linkages removed';

  @override
  String get expensesFormShoppingUnlinkedUndo => 'Undo';

  @override
  String get expensesFormSplitShared => 'Shared';

  @override
  String get expensesFormSplit5050 => '50/50';

  @override
  String get expensesFormSplitFixed => 'Fixed';

  @override
  String get expensesFormSplitGift => 'Gift';

  @override
  String get expensesFormSplitPersonal => 'Just me';

  @override
  String expensesFormInfoBoxGift(String memberLabel) {
    return 'This expense won\'t affect the balance $memberLabel.';
  }

  @override
  String get expensesFormInfoBoxPersonal => 'Recorded as a personal expense.';

  @override
  String get expensesFormSaveButtonUpdated => 'Updated';

  @override
  String get expensesFormSaveButtonSaveIncome => 'Save Income';

  @override
  String get expensesFormSaveButtonSaveExpense => 'Save Expense';

  @override
  String get expensesFormMembersEmpty =>
      'No members available to record expenses.';

  @override
  String get expensesFormTitleHintIncome =>
      'What is this income for? (Optional)';

  @override
  String get expensesFormTitleHintExpense => 'What did you buy? (Optional)';

  @override
  String get expensesFormTypeExpense => 'Expense';

  @override
  String get expensesFormTypeIncome => 'Income';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllReadTooltip => 'Mark all as read';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptySubtitle => 'You\'re all caught up';

  @override
  String get notificationsErrorTitle => 'We couldn\'t load your notifications';

  @override
  String get notificationsErrorSubtitle => 'Swipe down to retry';

  @override
  String get premiumPaywallCloseTooltip => 'Close';

  @override
  String get premiumPaywallTitle => 'Take your home\\nto the next level';

  @override
  String get premiumPaywallSubtitle =>
      'Unlock all pro features and simplify your team life.';

  @override
  String get premiumBenefitAdvancedStats => 'Advanced Statistics';

  @override
  String get premiumBenefitAdvancedStatsDesc =>
      'Analyze your expenses and tasks by category with detailed charts.';

  @override
  String get premiumBenefitUnlimitedHouseholds => 'Unlimited Households';

  @override
  String get premiumBenefitUnlimitedHouseholdsDesc =>
      'Create multiple households for your partner, family, friends, or projects.';

  @override
  String get premiumBenefitFullCustomization => 'Full Customization';

  @override
  String get premiumBenefitFullCustomizationDesc =>
      'Access premium themes, unique colors, and custom widgets.';

  @override
  String get premiumRestorePurchases => 'Restore purchases';

  @override
  String get premiumFreeTrialAvailable => 'Free Trial Available';

  @override
  String get premiumActivateButton => 'Activate Premium';

  @override
  String get premiumTestingModeLabel => 'Testing mode · no charge';

  @override
  String get premiumSavePercent => 'Save 20%';

  @override
  String get premiumAlreadyActiveTitle => 'You\'re already Premium!';

  @override
  String get premiumAlreadyActiveBody =>
      'Thanks for supporting HomeSync development.';

  @override
  String get premiumContinueButton => 'Continue';

  @override
  String get premiumDeactivateTesting => 'Deactivate Premium (testing)';

  @override
  String get premiumStoreErrorTitle => 'Error connecting to store';

  @override
  String get premiumDeveloperModeButton => 'Developer Mode: Activate Premium';

  @override
  String get faqSheetTitle => 'FAQ';

  @override
  String get faqSheetSubtitle => 'Everything you need to know about HomeSync';

  @override
  String get faqHowSharedHome => 'How does the shared home work?';

  @override
  String get faqHowSharedHomeAnswer =>
      'HomeSync is designed for couples and people living together. When you join a household with a code, you both share the same task list, expenses, and savings. Everything one person does is reflected for the other.';

  @override
  String get faqWhatCoins => 'What are Coins for?';

  @override
  String get faqWhatCoinsAnswer =>
      'Coins are the reward for completing tasks. You can use them in the rewards section to redeem vouchers created by your partner, like a romantic dinner or a day of relaxation.';

  @override
  String get faqWhatWeeklyDuels => 'What are Weekly Duels?';

  @override
  String get faqWhatWeeklyDuelsAnswer =>
      'Each week a new XP duel begins. The member who completes more tasks and earns more experience points will be the winner. It\'s a fun way to motivate each other.';

  @override
  String get faqHowEarnXp => 'How do I earn XP?';

  @override
  String get faqHowEarnXpAnswer =>
      'You earn XP every time you complete a task. Harder or more important tasks usually give more XP. Leveling up shows your progress within the household.';

  @override
  String get faqHowFinancesWork => 'How do finances work?';

  @override
  String get faqHowFinancesWorkAnswer =>
      'In HomeSync you can record real expenses and also anticipate expenses you haven\'t paid yet. Confirmed expenses are the ones that affect the actual balance between you. Pending ones serve as a reminder and projection, but they don\'t change the debt until they\'re paid.';

  @override
  String get faqHowRecurringCount =>
      'How do recurring expenses and the estimated balance count?';

  @override
  String get faqHowRecurringCountAnswer =>
      'A new recurring expense starts from its first valid date. If you create it before or on the due date, it may count this month. If you create it after, it starts on the next cycle. \"Your pending share\" shows only what corresponds to you according to the split, and \"Estimated balance\" uses your current balance minus that pending share.';

  @override
  String get faqWhatSpecialEvents => 'What are Special Events?';

  @override
  String get faqWhatSpecialEventsAnswer =>
      'Each week a couple challenge appears in the store. They\'re activities designed to strengthen the relationship. When you complete them, both receive Coins and unlock medals on their achievements profile.';

  @override
  String get faqLevelsAndAchievements => 'Levels and achievements?';

  @override
  String get faqLevelsAndAchievementsAnswer =>
      'As you earn XP, you level up. In the statistics section you can see your achievements, which are medals for milestones reached, like completing 50 tasks or beating weekly challenges.';

  @override
  String get feedbackThanksBug => 'Thanks for reporting it!';

  @override
  String get feedbackThanksSuggestion => 'Thanks for the idea!';

  @override
  String get feedbackReviewBug => 'We\'ll look into it shortly.';

  @override
  String get feedbackConsiderSuggestion => 'We\'ll keep it in mind.';

  @override
  String get feedbackSendError => 'Couldn\'t send. Try again.';

  @override
  String get feedbackBugTitlePlaceholder => 'What happened?';

  @override
  String get feedbackSuggestionTitlePlaceholder => 'What would you improve?';

  @override
  String get feedbackBugHint => 'E.g.: The expenses screen doesn\'t load';

  @override
  String get feedbackSuggestionHint => 'E.g.: Filter tasks by week';

  @override
  String get feedbackBugDescHint =>
      'Optional description: steps to reproduce, what you expected to see...';

  @override
  String get feedbackSuggestionDescHint =>
      'Optional description: context, why would it be useful...';

  @override
  String get feedbackSendBugReport => 'Send report';

  @override
  String get feedbackSendSuggestion => 'Send suggestion';

  @override
  String get feedbackReportErrorOption => 'Report error';

  @override
  String get feedbackSuggestImprovementOption => 'Suggest improvement';

  @override
  String get membersTitle => 'Members';

  @override
  String membersSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people in your household',
      one: '1 person in your household',
    );
    return '$_temp0';
  }

  @override
  String get membersAdminBadge => 'Admin';

  @override
  String membersRolePickerTitle(String memberName) {
    return '$memberName\'s role';
  }

  @override
  String get membersRolePickerSubtitle =>
      'Parents and guardians can approve tasks. Teens and kids submit their tasks for review.';

  @override
  String get membersRoleParent => 'Parent';

  @override
  String get membersRoleGuardian => 'Guardian';

  @override
  String get membersRoleTeen => 'Teen';

  @override
  String get membersRoleChild => 'Child';

  @override
  String get membersRoleParentGuardianDesc =>
      'Approves tasks, manages the household.';

  @override
  String get membersRoleTeenDesc =>
      'Creates their own tasks, but completes them under review.';

  @override
  String get membersRoleChildDesc =>
      'Only completes their tasks, always under review.';

  @override
  String membersRoleUpdateError(String message) {
    return 'Couldn\'t change the role: $message';
  }

  @override
  String get membersRoleUpdated => 'Role updated';

  @override
  String get membersInviteTitle => 'Invite member';

  @override
  String get membersInviteSubtitle =>
      'Add another person to the household with an invitation code.';

  @override
  String get shoppingSearchHint => 'I need...';

  @override
  String get shoppingListTitle => 'Current list';

  @override
  String get shoppingAllDone => 'All sorted';

  @override
  String get shoppingListResolved => 'List resolved';

  @override
  String get shoppingEmptyFirstLineDone =>
      'Fridge is stocked.\nNeed anything today?';

  @override
  String get shoppingEmptyFirstLineBought =>
      'All done.\nWant to add something else?';

  @override
  String get shoppingEmptyHint =>
      'Add products using the categories\nor the search bar below.';

  @override
  String get shoppingRecentSection => 'Buy again';

  @override
  String get shoppingCategoriesSection => 'Categories';

  @override
  String shoppingProductsBought(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items bought',
      one: '1 item bought',
    );
    return '$_temp0';
  }

  @override
  String get shoppingScanReceipt => 'Scan receipt and log expense';

  @override
  String get shoppingItemNameHint => 'Product name';

  @override
  String get shoppingDeleteTooltip => 'Delete';

  @override
  String get shoppingCategoryLabel => 'Category';

  @override
  String get shoppingAddToList => 'Add to list';

  @override
  String get shoppingSaveChanges => 'Save changes';

  @override
  String get rewardsTabDuel => 'Duel';

  @override
  String get rewardsTabPrizes => 'Prizes';

  @override
  String get rewardsLoadMore => 'Load more';

  @override
  String get rewardsLoading => 'Loading prizes...';

  @override
  String rewardsLoadError(String error) {
    return 'Couldn\'t load prizes.\n$error';
  }

  @override
  String get rewardsProposalsSection => 'Proposals';

  @override
  String get rewardsPendingApproval =>
      'Wishes pending approval. Tap a proposal to review it.';

  @override
  String get rewardsStatusPending => 'Pending';

  @override
  String get rewardsStatusReview => 'Review';

  @override
  String get rewardsWaitingPartnerDecision =>
      'Waiting for your partner\'s decision.';

  @override
  String rewardsCoinsAvailable(int count) {
    return '$count coins available';
  }

  @override
  String rewardsCoinsAvailableShort(int count) {
    return '$count coins';
  }

  @override
  String get rewardsCoinsAvailableToRedeem => 'Available to redeem now';

  @override
  String get rewardsBalance => 'Balance';

  @override
  String get rewardsDeleteTooltip => 'Delete reward';

  @override
  String get rewardsEmptyBoutique => 'Empty boutique';

  @override
  String get rewardsEmptyNoPrizes => 'No prizes loaded in this house yet.';

  @override
  String get rewardsLoadSuggested => 'Load suggested prizes';

  @override
  String get rewardsOrCreateCustom => 'Or create a custom prize';

  @override
  String get rewardsAddNewDesirePrompt => 'Want to add a new wish?';

  @override
  String get rewardsAddNewDesireHint =>
      'Propose it and your partner can approve it to appear in the store.';

  @override
  String get rewardsSuggestNewDesire => 'Propose a new wish';

  @override
  String get rewardsChallengeCompletePrompt =>
      'Did you complete the challenge?';

  @override
  String rewardsChallengeCompleteBody(int count) {
    return 'What joy! By confirming, both of you will receive $count coins.';
  }

  @override
  String get rewardsNotYet => 'Not yet';

  @override
  String get rewardsYesWeDid => 'Yes, we did it';

  @override
  String rewardsChallengeTitle(String title) {
    return 'Challenge: $title';
  }

  @override
  String get rewardsChallengeCompleted => 'Challenge completed';

  @override
  String rewardsChallengeCompletedBody(int count) {
    return 'Both earned $count coins. Keep nurturing your connection.';
  }

  @override
  String rewardsChallengeError(String error) {
    return 'Error completing the challenge: $error';
  }

  @override
  String get rewardsDeletePrompt => 'Delete prize?';

  @override
  String rewardsDeleteBody(String title) {
    return '\"$title\" will be removed from the boutique.';
  }

  @override
  String get rewardsInsufficientCoins =>
      'Not enough coins. Complete more tasks.';

  @override
  String get rewardsRedeemPrompt => 'Redeem this prize?';

  @override
  String get rewardsRedeem => 'Redeem';

  @override
  String get rewardsRedeemed => 'Prize redeemed';

  @override
  String rewardsRedeemedBody(String title) {
    return 'Enjoy \"$title\". Love also lives in the little details.';
  }

  @override
  String get rewardsApprovalReason => 'Reason to approve it';

  @override
  String rewardsCostLabel(int cost) {
    return 'Cost: $cost coins';
  }

  @override
  String get rewardsSuggestTitle => 'Propose a wish';

  @override
  String get rewardsNewHouseReward => 'New house prize';

  @override
  String get rewardsTitleLabel => 'TITLE';

  @override
  String get rewardsReasonLabel => 'WHY SHOULD IT BE APPROVED';

  @override
  String get rewardsDescriptionLabel => 'DESCRIPTION';

  @override
  String get rewardsCostFieldLabel => 'COST';

  @override
  String get rewardsCategoryFieldLabel => 'CATEGORY';

  @override
  String get rewardsCostHint => 'Cost in coins';

  @override
  String get rewardsPendingReview => 'Pending approval';

  @override
  String get rewardsPendingReviewSubtitle =>
      'Proposed prizes that still need a decision.';

  @override
  String get rewardsForKids => 'Prizes for kids';

  @override
  String get rewardsForKidsSubtitle =>
      'Rewards designed to motivate and celebrate progress.';

  @override
  String get rewardsForAdults => 'Prizes for adults';

  @override
  String get rewardsForAdultsSubtitle =>
      'Takes the visual and emotional language of the couple boutique.';

  @override
  String get rewardsFamilyPlans => 'Family plans';

  @override
  String get rewardsFamilyPlansSubtitle =>
      'Prizes and outings to enjoy together.';

  @override
  String get rewardsForYou => 'Prizes for you';

  @override
  String get rewardsForYouSubtitle =>
      'Choose what you want to earn with your coins.';

  @override
  String get rewardsPlansTogether => 'Plans together';

  @override
  String get rewardsPlansTogetherSubtitle => 'Prizes to enjoy as a family.';

  @override
  String get rewardsChildStoreTitle => 'My store';

  @override
  String get rewardsFamilyStoreTitle => 'Household store';

  @override
  String get rewardsNewPrizeLabel => 'New prize';

  @override
  String get rewardsEmptyNoChildPrizes => 'No prizes in your store yet.';

  @override
  String get rewardsEmptyNoAdultPrizes => 'No prizes for adults yet.';

  @override
  String get rewardsEmptyNoFamilyPlans => 'No family plans loaded yet.';

  @override
  String get rewardsEmptyNoFamilyPlansChild => 'No family plans available yet.';

  @override
  String get rewardsEditPrize => 'Edit prize';

  @override
  String get rewardsNewFamilyPrize => 'New family prize';

  @override
  String get rewardsPrizeTitleField => 'Prize title';

  @override
  String get rewardsPrizeDescriptionField => 'Short description';

  @override
  String get rewardsCostInCoinsField => 'Cost in coins';

  @override
  String get rewardsTargetAudience => 'Targeted to';

  @override
  String get rewardsWholeFamily => 'Whole family';

  @override
  String get rewardsAdults => 'Adults';

  @override
  String get rewardsKids => 'Kids';

  @override
  String get rewardsIconLabel => 'Icon';

  @override
  String get rewardsSaveChanges => 'Save changes';

  @override
  String get rewardsSavePrize => 'Save prize';

  @override
  String rewardsApprovedSnack(String title) {
    return '\"$title\" was approved.';
  }

  @override
  String get rewardsDeleteDialogTitle => 'Delete prize';

  @override
  String rewardsDeleteDialogBody(String title) {
    return '\"$title\" will be removed from the store.';
  }

  @override
  String rewardsPrizeCostCoins(int cost) {
    return '$cost coins';
  }

  @override
  String get rewardsRemovePrize => 'Remove prize';

  @override
  String get rewardsNotEnoughCoins => 'You don\'t have enough coins yet.';

  @override
  String get rewardsRedeemDialogTitle => 'Redeem prize';

  @override
  String rewardsRedeemDialogBody(String title, int cost) {
    return 'Do you want to redeem \"$title\" for $cost coins?';
  }

  @override
  String rewardsRedeemedSnack(String title) {
    return 'You redeemed \"$title\".';
  }

  @override
  String get rewardsChildCoinPurse => 'Your coin purse';

  @override
  String get rewardsCurrentBalance => 'Current balance';

  @override
  String get rewardsYourCoins => 'Your coins';

  @override
  String rewardsBalanceAmount(int balance) {
    return '$balance coins';
  }

  @override
  String get rewardsChildBalanceHint =>
      'It grows when an adult approves your missions.';

  @override
  String get rewardsEmptyBoutiqueAdmin =>
      'Load suggested prizes or create the household\'s first catalog.';

  @override
  String get rewardsEmptyBoutiqueNonAdmin =>
      'No prizes available in the household store yet.';

  @override
  String get rewardsLoadInitialCatalog => 'Load initial catalog';

  @override
  String get rewardsReviewPill => 'Review';

  @override
  String get rewardsRemove => 'Remove';

  @override
  String get rewardsApprove => 'Approve';

  @override
  String rewardsProposalStatusWaiting(int count) {
    return '$count coins · waiting for response';
  }

  @override
  String rewardsProposalStatusAction(int count) {
    return '$count coins · tap to approve or remove';
  }

  @override
  String coupleChallengeWeeklyPill(int number, int total) {
    return 'Weekly special $number of $total';
  }

  @override
  String get coupleChallengeExpandTooltip => 'Expand';

  @override
  String get coupleChallengeShowLess => 'Show less';

  @override
  String get coupleChallengeShowMore => 'See full details';

  @override
  String get coupleChallengeSharedReward => 'Shared reward';

  @override
  String coupleChallengeSharedRewardBody(int count) {
    return 'If you complete it, both receive $count coins.';
  }

  @override
  String get coupleChallengeWeDidIt => 'We did it';

  @override
  String get familyRewardsCoinsLabel => 'coins';

  @override
  String get statsTabWeek => 'Week';

  @override
  String get statsTabEvolution => 'Evolution';

  @override
  String get statsTabAchievements => 'Achievements';

  @override
  String get statsRetry => 'Retry';

  @override
  String get statsHouseholdSummary => 'Household summary';

  @override
  String get statsTasks => 'Tasks';

  @override
  String get statsXP => 'XP';

  @override
  String get statsCoins => 'Coins';

  @override
  String get statsWeeklyHistory => 'Weekly history';

  @override
  String get statsVictoryHistory => 'Victory history';

  @override
  String get statsPrivacyMessage =>
      'Stats are private to your household. Only you and your partner can see this data.';

  @override
  String get statsPrivacyDetailed =>
      'Your progress data is private and only you can see this detailed history.';

  @override
  String get statsPrivacyFull =>
      'Stats are totally private to your household. Only you and your partner can see this data.';

  @override
  String get statsWeeklyDuel => 'Weekly duel';

  @override
  String get statsEmptyTitle => 'No data yet';

  @override
  String get statsEmptySubtitle =>
      'Complete some tasks to see your areas of dominance.';

  @override
  String get statsRefreshButton => 'Refresh data';

  @override
  String get weeklyWinnerEmptyTitle => 'No weekly winner yet';

  @override
  String get weeklyWinnerEmptyBody =>
      'Complete tasks this week and the duel will start to take shape.';

  @override
  String get weeklyWinnerWeeklyClose => 'WEEKLY CLOSE';

  @override
  String get weeklyWinnerTitle => 'Weekly winner';

  @override
  String get weeklyWinnerSubtitle =>
      'This is how the weekly duel ended between you.';

  @override
  String get weeklyWinnerCardSubtitle =>
      'Finished ahead in XP and took the weekly close.';

  @override
  String get weeklyWinnerCoinsReward => '+20 coins';

  @override
  String get weeklyWinnerSecondPlace => 'Second place';

  @override
  String get weeklyWinnerRankingTitle => 'Weekly ranking';

  @override
  String get weeklyWinnerFallbackWinner => 'Winner';

  @override
  String get weeklyWinnerFallbackLoser => 'Loser';

  @override
  String get weeklyWinnerFallbackParticipant => 'Participant';

  @override
  String get weeklyWinnerFallbackPlayer => 'Player';

  @override
  String get weeklyWinnerClose => 'Close';

  @override
  String get weeklyWinnerContinue => 'Continue';

  @override
  String get loveNoteDialogTitle => 'New love note';

  @override
  String get loveNoteHint => 'Write something tender...';

  @override
  String get loveNoteSent => 'Note sent with love';

  @override
  String get loveNoteSendMessageTitle => 'Send message to your partner';

  @override
  String get loveNotePremiumHintActive => 'Surprise with a special note today.';

  @override
  String get loveNotePremiumHintInactive =>
      'Premium feature. Unlock it to send notes.';

  @override
  String get weeklyProgressTitle => 'Weekly progress';

  @override
  String get weeklyProgressSubtitle =>
      'Follow how the week is going, who\'s taken the lead, and how much rhythm you have together.';

  @override
  String weeklyProgressWeekLabel(String weekRange) {
    return 'Current week · $weekRange';
  }

  @override
  String get personalEvolutionTitle => 'Your personal evolution';

  @override
  String get streakLabel => 'Streak';

  @override
  String streakDaysValue(int days) {
    return '$days days';
  }

  @override
  String get streakSubtitle => 'You\'re going strong!';

  @override
  String get levelLabel => 'Level';

  @override
  String levelXpToNext(int xp) {
    return '$xp XP to level up';
  }

  @override
  String get progressEmptyTitle =>
      'Start completing tasks to see your progress.';

  @override
  String get categoriesDominance => 'Category dominance';

  @override
  String get categoriesBreakdown => 'Detailed breakdown';

  @override
  String get categoriesBalanceTip =>
      'Balancing categories helps keep a more harmonious and fun household.';

  @override
  String get categoriesImpactDistribution => 'IMPACT DISTRIBUTION';

  @override
  String categoriesTasksCount(int count) {
    return '$count TASKS';
  }

  @override
  String categoriesCompletedCount(int count) {
    return '$count completed';
  }

  @override
  String get categoriesXpTotal => 'TOTAL XP';

  @override
  String get achievementsTitle => 'Your medals';

  @override
  String get achievementsCoupleChallenges => 'Couple challenges';

  @override
  String get achievementsIconicMoments => 'Iconic moments';

  @override
  String get duelHistoryLastWeek => 'Last week';

  @override
  String get duelVsText => ' vs ';

  @override
  String get rewardsTitleRequiredError => 'Write the name of the wish.';

  @override
  String get rewardsTitleMinLengthError => 'Use at least 3 characters.';

  @override
  String get rewardsTitleHint => 'E.g.: 20-minute massage';

  @override
  String get rewardsTargetTypeAdult => 'Adults';

  @override
  String get rewardsTargetTypeChild => 'Kids';

  @override
  String get rewardsTargetTypeFamily => 'Family';

  @override
  String get rewardsCostValidationInvalid => 'Enter a valid cost.';

  @override
  String get rewardsCostValidationMin => 'It must cost at least 1 coin.';

  @override
  String get rewardsDescriptionSuggestionHint =>
      'Explain why your partner should approve this wish.';

  @override
  String get rewardsDescriptionPrizeHint =>
      'A short detail to describe the prize.';

  @override
  String get rewardsValidationMinLength =>
      'Tell us a bit more so it\'s easy to evaluate.';
}
