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
  String get settingsCurrencyTitle => 'Currency';

  @override
  String get settingsCurrencySubtitle => 'Choose how Finance amounts are shown';

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
  String get offlineDisconnectedMessage =>
      'No connection · Changes will be saved when you\'re back online';

  @override
  String get offlineSyncingMessage => 'Syncing changes...';

  @override
  String offlinePendingShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending',
      one: '1 pending',
    );
    return '$_temp0';
  }

  @override
  String offlinePendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes pending sync',
      one: '1 change pending sync',
    );
    return '$_temp0';
  }

  @override
  String get offlineSyncedMessage => 'Synced';

  @override
  String offlineSyncButton(int count) {
    return 'Sync ($count)';
  }

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
        'couple':
            'Your week, the money between you and what you plan together.',
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
  String get settingsPremiumActiveSubtitle => 'Manage plan';

  @override
  String get settingsPremiumInactiveSubtitle => 'Advanced features';

  @override
  String get settingsPremiumFeedbackRewardNote =>
      'Report bugs or suggest useful improvements and you may earn free Premium months.';

  @override
  String get settingsPremiumFeatureShoppingFinanceSync =>
      'Shopping → Finance sync';

  @override
  String get settingsPremiumFeatureRecurringPayments =>
      'Recurring payments (subscriptions)';

  @override
  String get settingsPremiumFeatureExclusiveAvatars => 'Exclusive avatars';

  @override
  String get settingsMinorPremiumSnack =>
      'This is a premium feature 🌟 Ask an adult in your home to turn on the plan.';

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
  String get settingsAccountResetError => 'Couldn\'t reset your account.';

  @override
  String get settingsLinkOpenError => 'Couldn\'t open the link';

  @override
  String get settingsProfileNameFallback => 'User';

  @override
  String get settingsProfileAvatarAction => 'Avatar';

  @override
  String get settingsProfileNameAction => 'Name';

  @override
  String get settingsRenameProfileTitle => 'Change name';

  @override
  String get settingsRenameProfileLabel => 'Name';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsFaqTitle => 'FAQ';

  @override
  String get settingsLogoutButton => 'Sign out';

  @override
  String get settingsDangerZoneEyebrow => 'DANGER ZONE';

  @override
  String get settingsResetAccountButton => 'Reset account data';

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
  String get settingsDeleteAccountButton => 'Delete my account';

  @override
  String get settingsDeleteAccountDialogTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountDialogBody =>
      'This permanently deletes your account and all your data (tasks, expenses, rewards and progress). It can\'t be undone. If you share a household, you\'ll be removed from it.';

  @override
  String get settingsDeleteAccountConfirm => 'Delete permanently';

  @override
  String get settingsDeleteAccountSuccess => 'Account deleted';

  @override
  String get settingsDeleteAccountError =>
      'Couldn\'t delete your account. Please try again.';

  @override
  String get settingsDeleteAccountReauthNeeded =>
      'For your security, sign in again and then delete your account.';

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
  String get authSignInError =>
      'We couldn\'t sign you in. Check your details and try again.';

  @override
  String get authSignUpError => 'We couldn\'t create your account. Try again.';

  @override
  String get authPasswordResetError =>
      'We couldn\'t send the recovery email. Try again.';

  @override
  String get authGoogleSignInError =>
      'We couldn\'t sign you in with Google. Try again.';

  @override
  String get invitationLoadError =>
      'We couldn\'t generate the invitation code.';

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
  String homeTodayProgressLabel(int done, int total) {
    return '$done of $total';
  }

  @override
  String homeTodayProgressSemantic(int done, int total) {
    return 'Today\'s progress: $done of $total tasks completed';
  }

  @override
  String get homeAllDoneToday => 'All done for today';

  @override
  String get homeTaskAddedNoticeTitle => 'Task added';

  @override
  String homeTaskAddedNoticeBody(String taskTitle) {
    return 'Now showing in Today at home: $taskTitle';
  }

  @override
  String get homeFabActions => 'Actions';

  @override
  String get homeFabExpenses => 'Expenses';

  @override
  String get homeFabTasks => 'Tasks';

  @override
  String get balanceCardSettled => 'All settled';

  @override
  String get balanceCardMyBudget => 'My budget';

  @override
  String get balanceCardBalanced => 'Balance settled';

  @override
  String get balanceCardNeedsSettlement => 'Needs settling';

  @override
  String get balanceCardInYourFavor => 'In your favor';

  @override
  String get balanceCardSettleButton => 'I paid';

  @override
  String get balanceCardXpLabel => 'XP';

  @override
  String get balanceCardCoinsLabel => 'coins';

  @override
  String get balanceCardIntegratedTitle => 'Integrated economy';

  @override
  String get balanceCardIntegratedSubtitle => 'Household spending';

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
  String get homeSoloXpCaption => 'Your progress';

  @override
  String get homeSoloLevelEyebrow => 'Level';

  @override
  String get homeSoloTasksTitle => 'Your tasks';

  @override
  String get homeSoloAddTaskButton => 'Add task';

  @override
  String get homeSoloActivityTitle => 'Your activity';

  @override
  String get homeGreetingMorning => 'Good morning,';

  @override
  String get homeGreetingAfternoon => 'Good afternoon,';

  @override
  String get homeGreetingEvening => 'Good evening,';

  @override
  String get homeSoloSpentEmpty => 'No spending yet ✨';

  @override
  String homeSoloSpentDailyAvg(String month, String amount) {
    return '$month · $amount/day';
  }

  @override
  String get soloSpaceEyebrow => 'My space';

  @override
  String soloSpaceLevel(int level) {
    return 'Level $level';
  }

  @override
  String soloSpaceXpToNext(int xp) {
    return '$xp XP to the next level.';
  }

  @override
  String get soloSpaceStageRecentMove => 'Fresh start';

  @override
  String get soloSpaceStageRecentMoveSubtitle =>
      'Your space is starting to take shape. Choose one simple action and build from there.';

  @override
  String get soloSpaceStageInMotion => 'Home in motion';

  @override
  String get soloSpaceStageInMotionSubtitle =>
      'There is movement now: a few routines, expenses, or tasks are starting to organize your days.';

  @override
  String get soloSpaceStageSteadyRoutine => 'Steady routine';

  @override
  String get soloSpaceStageSteadyRoutineSubtitle =>
      'You already have a base; now it is about keeping it going without overthinking it.';

  @override
  String get soloSpaceStageOrganizedHome => 'Organized home';

  @override
  String get soloSpaceStageOrganizedHomeSubtitle =>
      'Your tasks, spending, and activity are starting to read like a clear system.';

  @override
  String get soloSpaceStageOwnRhythm => 'Your space, your rhythm';

  @override
  String get soloSpaceStageOwnRhythmSubtitle =>
      'This is no longer just tracking things: you are building your own way to live at home.';

  @override
  String get soloSpaceSignalsTitle => 'Weekly signals';

  @override
  String get soloSpaceStreakTitle => 'Streak';

  @override
  String soloSpaceStreakMetric(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
      zero: 'No streak',
    );
    return '$_temp0';
  }

  @override
  String soloSpaceActiveDays14(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days active days in 14 days',
      one: '1 active day in 14 days',
      zero: 'No recent active days',
    );
    return '$_temp0';
  }

  @override
  String get soloSpaceWeeklyXpTitle => 'Weekly XP';

  @override
  String get soloSpaceWeeklyTasksTitle => 'Weekly tasks';

  @override
  String soloSpaceDeltaUp(int value) {
    return '+$value vs previous week';
  }

  @override
  String soloSpaceDeltaDown(int value) {
    return '$value vs previous week';
  }

  @override
  String get soloSpaceDeltaSame => 'Same as previous week';

  @override
  String soloSpaceTopTaskCategory(String category) {
    return 'Tasks: $category';
  }

  @override
  String soloSpaceTopExpenseCategory(String category) {
    return 'Spending: $category';
  }

  @override
  String get soloSpaceSignalsSyncing =>
      'Refreshing real signals from your home.';

  @override
  String get soloSpaceDimensionsTitle => 'How your home is doing';

  @override
  String get soloSpaceOrderTitle => 'Order';

  @override
  String get soloSpaceOrderSubtitle =>
      'Tasks, pending items, and closing the day.';

  @override
  String get soloSpaceClarityTitle => 'Clarity';

  @override
  String get soloSpaceClaritySubtitle =>
      'Tracked spending and monthly context.';

  @override
  String get soloSpaceContinuityTitle => 'Continuity';

  @override
  String get soloSpaceContinuitySubtitle =>
      'Recent activity and real consistency.';

  @override
  String get soloSpaceNextTitle => 'Next gesture';

  @override
  String get soloSpaceNextCreateTask => 'Create a base task';

  @override
  String get soloSpaceNextCreateTaskSubtitle =>
      'One small routine is enough to start shaping your space.';

  @override
  String get soloSpaceNextCompleteTask => 'Close a task for today';

  @override
  String get soloSpaceNextCompleteTaskSubtitle =>
      'Reducing pending items is the most direct way to improve Order.';

  @override
  String get soloSpaceNextRegisterExpense =>
      'Track your first expense this month';

  @override
  String get soloSpaceNextRegisterExpenseSubtitle =>
      'With one movement logged, your Clarity starts to have context.';

  @override
  String get soloSpaceNextReviewShopping => 'Review your shopping list';

  @override
  String get soloSpaceNextReviewShoppingSubtitle =>
      'An organized shop keeps noise down and the month lighter.';

  @override
  String get soloSpaceNextKeepGoing => 'Add one simple action';

  @override
  String get soloSpaceNextKeepGoingSubtitle =>
      'One small gesture today keeps your home continuity going.';

  @override
  String get soloSpaceMilestonesTitle => 'Personal milestones';

  @override
  String get soloSpaceMilestoneFirstStep => 'First step';

  @override
  String get soloSpaceMilestoneFirstStepDesc =>
      'You completed your first task.';

  @override
  String get soloSpaceMilestoneWeekInMotion => 'Week in motion';

  @override
  String get soloSpaceMilestoneWeekInMotionDesc =>
      'You had enough recent activity to mark a rhythm.';

  @override
  String get soloSpaceMilestoneClearerHome => 'Clearer home';

  @override
  String get soloSpaceMilestoneClearerHomeDesc =>
      'Your finances already have useful signals this month.';

  @override
  String get soloSpaceMilestoneSteadyRoutine => 'Sustained routine';

  @override
  String get soloSpaceMilestoneSteadyRoutineDesc =>
      'Order and continuity are starting to work together.';

  @override
  String get soloSpaceMilestoneOwnRhythm => 'Own rhythm';

  @override
  String get soloSpaceMilestoneOwnRhythmDesc =>
      'Your progress is already showing a personal identity.';

  @override
  String get soloSpaceFutureHint =>
      'Your space adjusts with your tasks, spending, and weekly rhythm.';

  @override
  String get soloSpaceRitualTitle => 'Weekly review';

  @override
  String soloSpaceRitualProgress(int done, int total) {
    return '$done of $total gestures';
  }

  @override
  String get soloSpaceRitualReviewTasks => 'Review open tasks';

  @override
  String get soloSpaceRitualCheckSpending => 'Check monthly spending';

  @override
  String get soloSpaceRitualPlanShopping => 'Adjust the shopping list';

  @override
  String get soloSpaceRitualChooseNextRoutine => 'Choose one routine to keep';

  @override
  String get soloSpaceInsightsTitle => 'Weekly read';

  @override
  String get soloSpaceInsightNoActivity => 'Starting point';

  @override
  String get soloSpaceInsightNoActivityDesc =>
      'There are no strong signals this week yet. One simple gesture is enough to begin.';

  @override
  String get soloSpaceInsightStreak => 'Streak building';

  @override
  String soloSpaceInsightStreakDesc(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days active days in a row are starting to form a rhythm.',
      one: 'One active day already marks continuity.',
    );
    return '$_temp0';
  }

  @override
  String get soloSpaceInsightWeekImproved => 'Stronger week';

  @override
  String soloSpaceInsightWeekImprovedDesc(int value) {
    return '+$value XP versus the previous week. There is more movement at home.';
  }

  @override
  String get soloSpaceInsightWeekSlowed => 'Quieter week';

  @override
  String get soloSpaceInsightWeekSlowedDesc =>
      'Movement slowed down. Choose one small action and close the day.';

  @override
  String get soloSpaceInsightFinanceVisible => 'Finances with context';

  @override
  String get soloSpaceInsightFinanceVisibleDesc =>
      'There are enough movements now to read the month more clearly.';

  @override
  String get soloSpaceInsightNoFinance => 'Missing finance read';

  @override
  String get soloSpaceInsightNoFinanceDesc =>
      'Tracking one real expense activates better Clarity signals.';

  @override
  String get soloSpaceInsightTaskCategory => 'Task pattern';

  @override
  String soloSpaceInsightTaskCategoryDesc(String category) {
    return '$category is showing up as a strong focus this month.';
  }

  @override
  String get soloSpaceInsightExpenseCategory => 'Spending pattern';

  @override
  String soloSpaceInsightExpenseCategoryDesc(String category) {
    return '$category has the most movement this month.';
  }

  @override
  String get soloSpaceSuggestionsTitle => 'Suggested tools';

  @override
  String get soloSpaceSuggestionRecurringTask =>
      'Turn something into a routine';

  @override
  String get soloSpaceSuggestionRecurringTaskDesc =>
      'A recurring task lowers friction and supports Order.';

  @override
  String get soloSpaceSuggestionClosePending => 'Close what is pending';

  @override
  String get soloSpaceSuggestionClosePendingDesc =>
      'Resolving one task today clears mental space.';

  @override
  String get soloSpaceSuggestionRegisterExpense => 'Track a real expense';

  @override
  String get soloSpaceSuggestionRegisterExpenseDesc =>
      'With one movement, the month no longer reads empty.';

  @override
  String get soloSpaceSuggestionReviewShopping => 'Review shopping';

  @override
  String get soloSpaceSuggestionReviewShoppingDesc =>
      'A clear list avoids duplicate or last-minute purchases.';

  @override
  String get soloSpaceSuggestionProtectStreak => 'Protect the streak';

  @override
  String get soloSpaceSuggestionProtectStreakDesc =>
      'One small action today keeps continuity alive.';

  @override
  String get soloSpaceSuggestionWeeklyReview => 'Run the weekly review';

  @override
  String get soloSpaceSuggestionWeeklyReviewDesc =>
      'Check the ritual gestures and leave the week organized.';

  @override
  String get soloSpaceUnlocksTitle => 'Soft unlocks';

  @override
  String get soloSpaceUnlockActive => 'Active';

  @override
  String get soloSpaceUnlockNext => 'Next';

  @override
  String get soloSpaceUnlockWeeklyReview => 'Review view';

  @override
  String get soloSpaceUnlockWeeklyReviewDesc =>
      'Available from the start to organize the week without pressure.';

  @override
  String get soloSpaceUnlockRecurringTemplates => 'Recurring templates';

  @override
  String get soloSpaceUnlockRecurringTemplatesDesc =>
      'Appear when there is enough base to repeat routines.';

  @override
  String get soloSpaceUnlockHabitInsights => 'Habit insights';

  @override
  String get soloSpaceUnlockHabitInsightsDesc =>
      'Activate after several days of real activity.';

  @override
  String get soloSpaceUnlockPersonalMedal => 'Personal medal';

  @override
  String get soloSpaceUnlockPersonalMedalDesc =>
      'Recognizes a sustained stage without competing with anyone.';

  @override
  String get soloSpaceUnlockRhythmRecommendations => 'Rhythm recommendations';

  @override
  String get soloSpaceUnlockRhythmRecommendationsDesc =>
      'Connect financial clarity with weekly continuity.';

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
  String get homeFamilyApprovalsTileLabel => 'Approvals';

  @override
  String homeFamilyApprovalsPendingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pending',
      one: 'pending',
    );
    return '$_temp0';
  }

  @override
  String get homeFamilyApprovalsAllClear => 'All clear';

  @override
  String expensesYouAreOwed(String amount) {
    return 'You\'re owed $amount';
  }

  @override
  String expensesYouOwe(String amount) {
    return 'You owe $amount';
  }

  @override
  String expensesDailyAvg(String amount) {
    return '≈ $amount/day';
  }

  @override
  String get homeCoupleHeadlineSecondary => 'of your home';

  @override
  String get homeCoupleHeadlineConnector => 'with';

  @override
  String get homeCouplePartnerFallback => 'your partner';

  @override
  String get homeCoupleShoppingListTitle => 'Current list';

  @override
  String get homeShoppingPreviewOpen => 'Open shopping';

  @override
  String get homeShoppingPreviewEmpty => 'No pending products.';

  @override
  String get homeShoppingPreviewLoadError => 'We couldn\'t load the list.';

  @override
  String homeShoppingPreviewPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending',
      one: '1 pending',
    );
    return '$_temp0';
  }

  @override
  String homeShoppingPreviewMoreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more in the list',
      one: '+1 more in the list',
    );
    return '$_temp0';
  }

  @override
  String get homeCoupleTasksTitle => 'Today at home';

  @override
  String get homeCoupleActivityTitle => 'Today\'s activity';

  @override
  String get homeCoupleActivityEmptyTitle => 'Nothing logged today yet';

  @override
  String get homeCoupleActivityEmptyBody =>
      'Anything you log today shows up here. The full history is in Finance.';

  @override
  String get homeCoupleSettlementErrorNoUser =>
      'We couldn\'t identify your user.';

  @override
  String get homeCoupleSettlementDialogTitle => 'Record settlement';

  @override
  String homeCoupleSettlementDialogDirectionPay(String partnerName) {
    return 'You → $partnerName';
  }

  @override
  String get homeCoupleSettlementDialogBalanceZero =>
      'This will bring the household balance to zero.';

  @override
  String get homeCoupleSettlementDialogCancel => 'Not now';

  @override
  String get homeCoupleSettlementDialogConfirm => 'Record payment';

  @override
  String homeCoupleSettlementDialogTitlePay(String partnerName) {
    return 'Settle up with $partnerName';
  }

  @override
  String get homeCoupleSettlementDialogTitleReceive => 'Record settlement';

  @override
  String homeCoupleSettlementDialogBodyPay(String amount, String partnerName) {
    return 'We\'ll record a payment of $amount to settle the balance with $partnerName.';
  }

  @override
  String homeCoupleSettlementDialogBodyReceive(
      String partnerName, String amount) {
    return 'We\'ll record that $partnerName paid you $amount to settle the balance.';
  }

  @override
  String get homeCoupleSettlementDoneBadge => 'Done';

  @override
  String homeCoupleSettlementSuccessPay(String partnerName) {
    return 'Balance settled with $partnerName.';
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
  String get homeFriendsSettleTitle => 'Settle up';

  @override
  String get homeFriendsSettleSubtitle => 'Who pays whom to get back to zero.';

  @override
  String get homeFriendsBalancesLoadError =>
      'We couldn\'t load the balances. Tap to retry.';

  @override
  String get homeFriendsTasksLoadError =>
      'We couldn\'t load the tasks. Tap to retry.';

  @override
  String get homeFriendsShoppingLoadError =>
      'We couldn\'t load the shopping list. Tap to retry.';

  @override
  String get homeFriendsActivityLoadError =>
      'We couldn\'t load the activity. Tap to retry.';

  @override
  String get balanceCardStatusOwed => 'Time to settle your balance';

  @override
  String get balanceCardStatusFavor => 'In your favor';

  @override
  String get balanceCardStatusShared => 'Shared balance';

  @override
  String get balanceCardBadgeSettled => 'Settled';

  @override
  String get balanceCardBadgeOwes => 'You owe';

  @override
  String get balanceCardBadgeFavor => 'In favor';

  @override
  String balanceCardMovements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movements',
      one: '1 movement',
      zero: '0 movements',
    );
    return '$_temp0';
  }

  @override
  String balanceCardMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Members',
      one: 'Member',
    );
    return '$_temp0';
  }

  @override
  String balanceCardOpenBalances(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Open balances',
      one: 'Open balance',
      zero: 'All settled',
    );
    return '$_temp0';
  }

  @override
  String get balanceCardSingleMemberHint =>
      'Once you add more members, you\'ll see the shared balance here.';

  @override
  String get balanceCardMemberOwes => 'Owes';

  @override
  String get balanceCardMemberFavor => 'In favor';

  @override
  String get balanceCardMemberSettled => 'Settled';

  @override
  String get settleSectionTitle => 'Settle debts';

  @override
  String get settleSectionOnePayment => '1 payment needed to balance';

  @override
  String settleSectionPayments(int count) {
    return '$count payments to balance everything';
  }

  @override
  String get settleAllSettled => 'All balanced. Nobody owes anyone.';

  @override
  String settlePaysTo(String name) {
    return 'pays $name';
  }

  @override
  String get settleConfirmTitle => 'Confirm payment';

  @override
  String settleConfirmBody(String from, String amount, String to) {
    return '$from pays $amount to $to.';
  }

  @override
  String settleSuccess(String amount) {
    return 'Payment of $amount recorded.';
  }

  @override
  String settleError(String error) {
    return 'Couldn\'t record the payment: $error';
  }

  @override
  String get homeFamilyMemberNotFound =>
      'We couldn\'t find your profile in this household.';

  @override
  String get homeFamilyMetricCoins => 'Coins';

  @override
  String get homeFamilyAdultFallbackName => 'Family';

  @override
  String get homeFamilyChildHello => 'Let\'s go, ';

  @override
  String get homeFamilyChildGreetingSuffix => '!';

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
  String get setupProfileAvatarLabel => 'Avatar';

  @override
  String get setupSignOutLink => 'Sign out';

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
  String setupFirstTasksTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'First tasks for the family',
        'solo': 'What do you want to keep on track?',
        'other': 'Which chores do you share?',
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
  String setupCompletionTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Your home is ready!',
        'family': 'Your family home is ready!',
        'friends': 'Your shared home is ready!',
        'solo': 'Your space is ready!',
        'other': 'Your space is ready!',
      },
    );
    return '$_temp0';
  }

  @override
  String setupCompletionMessage(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'You can now organize tasks, expenses and goals together.',
        'family': 'You can now share tasks and coordinate the house.',
        'friends': 'Clear accounts from day one.',
        'solo': 'Everything set to start your routines.',
        'other': 'Everything set to start your routines.',
      },
    );
    return '$_temp0';
  }

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
        'couple': 'Integrated economy or split expenses',
        'other': 'Adjust percentage',
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
  String get settingsHouseholdRenameDialogLabel => 'Name';

  @override
  String get settingsHouseholdFallbackName => 'My home';

  @override
  String get settingsHouseholdCodeGenerated => 'Code generated';

  @override
  String get settingsHouseholdCodeCopied => 'Code copied to clipboard';

  @override
  String get settingsHouseholdCodeGenerateFirst => 'Generate a code first';

  @override
  String get settingsHouseholdWhatsAppFallback =>
      'Couldn\'t open WhatsApp. Code copied.';

  @override
  String get settingsHouseholdJoinSuccess => 'You\'ve joined the household!';

  @override
  String get settingsHouseholdJoinCodeLength =>
      'The code must be 6 characters long';

  @override
  String get settingsHouseholdRoleUpdated => '✅ Role updated';

  @override
  String get settingsHouseholdRenamed => '✅ Home renamed';

  @override
  String get settingsHouseholdTasksEnabledSnack => '✅ Household tasks enabled';

  @override
  String get settingsHouseholdFinanceModeSnack =>
      '✅ Finance & shopping mode enabled';

  @override
  String settingsHouseholdUpdateError(String error) {
    return 'Couldn\'t update the setting: $error';
  }

  @override
  String get settingsAssignRoleTitle => 'Assign role or nickname';

  @override
  String settingsAssignRoleFieldLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Role name (e.g. Partner)',
        'friends': 'Role name (e.g. Roommate)',
        'other': 'Role name (e.g. Mom)',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsAssignRoleSuggestionsLabel => 'Suggestions:';

  @override
  String get settingsRoleSuggestionsCouple =>
      'Partner,Boyfriend,Girlfriend,Husband,Wife';

  @override
  String get settingsRoleSuggestionsFriends =>
      'Roommate,Flatmate,Guest,In charge';

  @override
  String get settingsMemberRoleOwner => 'Owner';

  @override
  String get settingsMemberRoleCouple => 'Partner';

  @override
  String get settingsMemberRoleFriends => 'Roommate';

  @override
  String get settingsMemberRoleDefault => 'Member';

  @override
  String get settingsHouseholdLoadError =>
      'We couldn\'t load your home. Check your connection and try again.';

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
  String get settingsParentModeAllowanceTitle => 'Allowances';

  @override
  String get settingsParentModeAllowanceSubtitle =>
      'Send allowances to teens with personal finances.';

  @override
  String get settingsParentModeAllowanceCta => 'Send allowance';

  @override
  String get settingsParentModePerMemberEmpty =>
      'No other members in the household yet.';

  @override
  String get settingsParentModeSaveError =>
      'We couldn\'t save the change. Try again.';

  @override
  String get settingsParentModeLoadError =>
      'Couldn\'t load the per-member settings.';

  @override
  String get notificationsMarkReadError =>
      'Couldn\'t mark the notification as read.';

  @override
  String get notificationsMarkAllReadError =>
      'Couldn\'t mark all notifications as read.';

  @override
  String get notificationsLoadMoreError =>
      'Couldn\'t load more notifications. Try again.';

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
        'couple': 'Couple finances',
        'other': 'Splitting expenses',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitSavedSnack => 'Settings saved successfully';

  @override
  String get coupleSplitSaveError => 'Couldn\'t save the settings. Try again.';

  @override
  String get setupTemplatesLoadError => 'Couldn\'t load the suggested tasks.';

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
  String coupleSplitModeHowTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'How expenses are recorded',
        'other': 'How you manage money',
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
            'In a family, the usual setup is a shared economy: expenses stay visible to the household but don\'t create debt between adults. If you need it, you can switch to a couple-style split.',
        'other':
            'There are two ways to handle money as a couple. With an integrated economy everything belongs to the household: expenses stay visible but don\'t create debt between you. With a divided economy each expense is split and a balance is tracked.',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitModeSharedTitle => 'Integrated economy';

  @override
  String coupleSplitModeSharedBody(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family':
            'Expenses aren\'t split by percentage and don\'t create balances between adults.',
        'other':
            'It\'s all household money: expenses are logged but don\'t create debt or balances between you. Ideal for couples with unified finances.',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleSplitModeDividedTitle => 'Split expenses';

  @override
  String coupleSplitModeDividedBody(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'family': 'Uses percentages and balances like a couple.',
        'other':
            'Each shared expense is split by the percentage you choose and a balance is tracked between you.',
      },
    );
    return '$_temp0';
  }

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
  String get tasksSectionOverdue => 'Overdue';

  @override
  String get tasksSectionToday => 'Today';

  @override
  String get tasksSectionTomorrow => 'Tomorrow';

  @override
  String get tasksSectionThisWeek => 'This week';

  @override
  String get tasksSectionUpcoming => 'Later';

  @override
  String get tasksSectionNoDate => 'No date';

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
  String get createTaskValidationInterval =>
      'The interval must be at least 1 day.';

  @override
  String get createTaskValidationTitleRequired => 'Title required';

  @override
  String get createTaskValidationNumberRequired => 'Enter a number';

  @override
  String get createTaskValidationNotNegative => 'Can\'t be negative';

  @override
  String get createTaskValidationRewardRange => 'Use 0–50 XP and 0–5 coins.';

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
  String get createTaskRotationMinimumPeople =>
      'Pick at least 2 people to set up the rotation.';

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
  String addTaskOptionsDone(int count) {
    return 'Done ($count)';
  }

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
  String get completeTaskAddPromptTitle => 'Can\'t find the task?';

  @override
  String get completeTaskAddPromptButton => 'Add new task';

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
  String completeTaskMixedApprovalMessage(int count, int xp, int coins) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks pending approval',
      one: '1 task pending approval',
    );
    return '$_temp0, ⭐ $xp XP and $coins Coins!';
  }

  @override
  String completeTaskApprovalOnlyMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks sent for approval',
      one: '1 task sent for approval',
    );
    return '$_temp0';
  }

  @override
  String completeTaskRewardMessage(String verb, int xp, int coins) {
    return '⭐ $verb $xp XP and $coins Coins!';
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
  String get taskDetailUndoSuccess => 'Task moved back to pending.';

  @override
  String get taskDetailUndoError => 'Couldn\'t undo';

  @override
  String get taskDetailNoRecord => 'No record';

  @override
  String get taskDetailExperience => 'Experience';

  @override
  String get taskDetailReward => 'Reward';

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
  String get familyDashboardMonthFilter => 'Month';

  @override
  String familyDashboardProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String familyDashboardStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardPendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending',
      one: '1 pending',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardToApproveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to approve',
      one: '1 to approve',
    );
    return '$_temp0';
  }

  @override
  String familyDashboardActiveMembers(int active, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active of $total members have active tasks.',
      one: '1 of $total member has active tasks.',
    );
    return '$_temp0';
  }

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
  String weeklySummaryMvpTitle(String name) {
    return '$name owned the week';
  }

  @override
  String weeklySummaryMvpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completed $count household tasks.',
      one: 'Completed 1 household task.',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryNeedsBoostTitle(String name) {
    return '$name has pending tasks';
  }

  @override
  String weeklySummaryNeedsBoostSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count overdue tasks. Maybe you can help them get unstuck this week.',
      one: '1 overdue task. Maybe you can help them get unstuck this week.',
    );
    return '$_temp0';
  }

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
  String get weeklySummaryOverdueToday => 'due today';

  @override
  String weeklySummaryOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'overdue by $count days',
      one: 'overdue by 1 day',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryForgottenSubtitle(String overdueLabel) {
    return 'This recurring task slipped through — $overdueLabel.';
  }

  @override
  String weeklySummaryExpensesLess(String amount) {
    return 'You spent $amount less than last week.';
  }

  @override
  String weeklySummaryExpensesMore(String amount) {
    return 'You spent $amount more than last week.';
  }

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
  String pendingApprovalsSubmittedBy(Object name) {
    return 'Submitted by $name';
  }

  @override
  String get pendingApprovalsApproveButton => 'Approve';

  @override
  String get pendingApprovalsRejectButton => 'Reject';

  @override
  String get pendingApprovalsLoadError =>
      'We couldn\'t load pending approvals.';

  @override
  String pendingApprovalsApprovedSnack(Object coins) {
    return 'Approved. $coins coins were credited.';
  }

  @override
  String get pendingApprovalsApproveErrorRetry =>
      'We couldn\'t approve the task. Try again.';

  @override
  String get pendingApprovalsRejectedSnack => 'Task rejected.';

  @override
  String get pendingApprovalsRejectErrorRetry =>
      'We couldn\'t reject the task. Try again.';

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
  String get expensesProjectionOwedToYou => 'Owed to you';

  @override
  String get expensesProjectionYouOwe => 'You owe';

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
  String get budgetsSectionTitle => 'BUDGETS';

  @override
  String get budgetsManageAction => 'Manage';

  @override
  String get budgetsTeaserTitle => 'Category budgets';

  @override
  String get budgetsTeaserSubtitle => 'Set monthly caps and see what\'s left';

  @override
  String get budgetsEmptyCta => 'Create your first budget';

  @override
  String get budgetsManageTitle => 'Budgets';

  @override
  String get budgetsLoadError => 'We couldn\'t load your budgets.';

  @override
  String get budgetsSaveError => 'We couldn\'t save the budget. Try again.';

  @override
  String get budgetsDeleteError => 'We couldn\'t delete the budget. Try again.';

  @override
  String get expensesPlannedPaymentError =>
      'We couldn\'t record the payment. Try again.';

  @override
  String get expensesPlannedPaymentMembersLoadError =>
      'We couldn\'t load the household members.';

  @override
  String get settingsHouseholdCodeGenerateError =>
      'We couldn\'t generate the code. Try again.';

  @override
  String get budgetsManageSubtitleShared =>
      'Household monthly caps, visible to everyone.';

  @override
  String get budgetsManageSubtitlePersonal =>
      'Your monthly caps, based on your share of spending.';

  @override
  String get budgetsManageEmpty => 'No budgets yet.';

  @override
  String get budgetsAddCategory => 'Add category';

  @override
  String get budgetsNewTitle => 'New budget';

  @override
  String get budgetsEditTitle => 'Edit budget';

  @override
  String get budgetsCategoryEyebrow => 'CATEGORY';

  @override
  String get budgetsLimitEyebrow => 'MONTHLY CAP';

  @override
  String get budgetsDeleteTitle => 'Delete budget?';

  @override
  String budgetsDeleteBody(String category) {
    return 'The cap for $category will be removed. Your expenses stay untouched.';
  }

  @override
  String budgetsRemaining(String amount) {
    return '$amount left';
  }

  @override
  String budgetsOverBy(String amount) {
    return '$amount over';
  }

  @override
  String budgetsSpentOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get financeInsightsTitle => 'Insights';

  @override
  String get financeInsightsSubtitle => 'This month\'s trend and budgets';

  @override
  String get financeInsightsTooltip => 'View insights';

  @override
  String get trendTitle => 'TREND · 6 MONTHS';

  @override
  String trendDeltaDown(int pct, String month) {
    return '$pct% less than $month';
  }

  @override
  String trendDeltaUp(int pct, String month) {
    return '$pct% more than $month';
  }

  @override
  String trendDeltaFlat(String month) {
    return 'About the same as $month';
  }

  @override
  String get trendCurrentMonthLabel => 'Spent this month';

  @override
  String get exportCsvTooltip => 'Export month (CSV)';

  @override
  String get exportCsvEmpty => 'No entries this month to export';

  @override
  String exportCsvShareSubject(String month) {
    return '$month finances — HomeSync';
  }

  @override
  String get csvHeaderDate => 'Date';

  @override
  String get csvHeaderType => 'Type';

  @override
  String get csvHeaderTitle => 'Detail';

  @override
  String get csvHeaderCategory => 'Category';

  @override
  String get csvHeaderAmount => 'Amount';

  @override
  String get csvHeaderPayer => 'Paid by';

  @override
  String get csvHeaderSplit => 'Split';

  @override
  String get csvTypeExpense => 'Expense';

  @override
  String get csvTypeIncome => 'Income';

  @override
  String get csvTypeSettlement => 'Settlement';

  @override
  String subsSuggestionTitle(String title) {
    return 'Is \"$title\" a recurring bill?';
  }

  @override
  String subsSuggestionBody(String amount) {
    return 'It repeats every month (~$amount). Turn it into a recurring bill and it schedules itself.';
  }

  @override
  String get subsSuggestionCreate => 'Create recurring';

  @override
  String get subsSuggestionDismiss => 'Not now';

  @override
  String get goalAutoMenuAction => 'Auto contribution';

  @override
  String get goalAutoTitle => 'Auto contribution';

  @override
  String goalAutoSubtitle(String goal) {
    return 'Every month a contribution to \"$goal\" gets scheduled — confirm it with one tap.';
  }

  @override
  String get goalAutoAmountEyebrow => 'MONTHLY CONTRIBUTION';

  @override
  String get goalAutoDayEyebrow => 'DAY OF MONTH';

  @override
  String get goalAutoDisable => 'Turn off';

  @override
  String get goalAutoSavedSnack => 'Auto contribution enabled';

  @override
  String get goalAutoDisabledSnack => 'Auto contribution disabled';

  @override
  String recapBannerTitle(String month) {
    return 'Your $month is ready ✨';
  }

  @override
  String get recapBannerSubtitle =>
      'What was spent, on what, and how much was saved.';

  @override
  String recapSheetTitle(String month) {
    return 'Your $month';
  }

  @override
  String recapMovementsCount(int count) {
    return '$count entries recorded';
  }

  @override
  String get recapTotalLabelShared => 'HOUSEHOLD SPEND';

  @override
  String get recapTotalLabelPersonal => 'YOUR SHARE THIS MONTH';

  @override
  String recapIncomeRow(String amount) {
    return 'Income this month: $amount';
  }

  @override
  String get recapCategoriesTitle => 'WHERE IT WENT';

  @override
  String get recapPayersTitle => 'WHO PAID';

  @override
  String get allowanceRepeatToggle => 'Repeat every month';

  @override
  String allowanceActiveScheduleInfo(String amount, int day) {
    return 'Monthly allowance active: $amount on day $day';
  }

  @override
  String get allowanceScheduleDisable => 'Turn off';

  @override
  String get allowanceScheduleDisabledSnack => 'Monthly allowance turned off';

  @override
  String allowanceScheduledSnack(int day) {
    return 'Allowance sent and scheduled for day $day of every month';
  }

  @override
  String allowanceScheduleError(String details) {
    return 'Couldn\'t schedule the allowance: $details';
  }

  @override
  String get poolsSectionTitle => 'POOLS';

  @override
  String get poolsNewAction => 'New';

  @override
  String get poolsEmptyCta => 'Create a pool (BBQ, trip, gift…)';

  @override
  String get poolsCardSettled => 'Settled ✓';

  @override
  String poolsCardExpenseCount(int count) {
    return '$count entries';
  }

  @override
  String get poolsCreateTitle => 'New pool';

  @override
  String get poolsCreateSubtitle =>
      'Group an event\'s expenses and settle it apart from day-to-day spending.';

  @override
  String get poolsCreateNameHint => 'Saturday BBQ, Córdoba trip…';

  @override
  String get poolsCreateCta => 'Create pool';

  @override
  String get poolsLoadError => 'We couldn\'t load the pools.';

  @override
  String get poolsCreateError => 'We couldn\'t create the pool. Try again.';

  @override
  String get poolsDetailLoadError => 'We couldn\'t load this pool.';

  @override
  String get poolsSettleError => 'We couldn\'t record the payment. Try again.';

  @override
  String get poolsCloseError => 'We couldn\'t close the pool. Try again.';

  @override
  String get poolsDetailNotFound => 'This pool no longer exists';

  @override
  String get poolsDetailTotalLabel => 'POOL TOTAL';

  @override
  String get poolsDetailSettleTitle => 'TO SETTLE THIS POOL';

  @override
  String get poolsDetailAllSettled =>
      'Pool settled — nobody owes anything here.';

  @override
  String poolsDetailDebtRow(String from, String amount, String to) {
    return '$from pays $amount to $to';
  }

  @override
  String get poolsDetailSettleCta => 'Record';

  @override
  String get poolsCloseCta => 'Close pool';

  @override
  String get poolsCloseConfirmTitle => 'Close this pool?';

  @override
  String get poolsCloseConfirmBodySettled =>
      'The pool gets archived and stops showing. Its entries stay in the history.';

  @override
  String get poolsCloseConfirmBodyPending =>
      'There are unsettled debts: they stay alive in the household balance. The pool gets archived anyway.';

  @override
  String poolsClosedSnack(String name) {
    return '\"$name\" closed';
  }

  @override
  String get expensesFormSectionPoolEyebrow => 'POOL';

  @override
  String get expensesFormSectionPoolTitle => 'Part of a pool?';

  @override
  String get expensesFormSectionPoolSubtitle =>
      'Add it to an event to see it grouped and settle it apart.';

  @override
  String get expensesFormPoolNone => 'No pool';

  @override
  String recapSavingsRow(String type, String amount) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'solo': 'You added $amount to your savings goals.',
        'other': 'You added $amount to the savings goals.',
      },
    );
    return '$_temp0';
  }

  @override
  String get expensesPlannedSkip => 'Skip';

  @override
  String expensesPlannedPay(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'Collect',
        'other': 'Pay',
      },
    );
    return '$_temp0';
  }

  @override
  String expensesPlannedPaymentSnack(String type, String title) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'Income \"$title\" recorded',
        'other': 'Payment for \"$title\" recorded',
      },
    );
    return '$_temp0';
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
  String get expensesFormOcrDuplicate =>
      'This receipt was already scanned recently. Make sure you\'re not adding the expense twice.';

  @override
  String get expensesFormOcrLowConfidence =>
      'Receipt hard to read — check the data before saving';

  @override
  String get expensesFormOcrRateLimited =>
      'Too many scans in a row. Wait a few seconds and try again.';

  @override
  String expensesFormOcrImageTooLarge(String sizeMb) {
    return 'The image is too large ($sizeMb MB, max 5 MB). Try another photo or pick one from the gallery.';
  }

  @override
  String get expensesFormOcrSessionExpired =>
      'Session expired. Sign in again to scan.';

  @override
  String get expensesFormOcrTimeout =>
      'The scan took too long. Check your connection and try again.';

  @override
  String get expensesFormOcrFailed =>
      'We couldn\'t read the receipt. Try better lighting with the whole receipt in the photo.';

  @override
  String get expensesFormOcrDailyLimit =>
      'You\'ve reached today\'s scan limit. You can still add the expense manually.';

  @override
  String get expensesFormOcrAmountMismatch =>
      'The total doesn\'t match the sum of the items. Check the amount before saving.';

  @override
  String expensesFormOcrPossibleDuplicate(String title, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'You already added “$title” for this amount on $dateString. Make sure it isn\'t the same expense.';
  }

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
  String get plannedExpensePaymentConfirmButton => 'Confirm and record';

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
  String get expensesFormHeaderEditIncome => 'Edit Income';

  @override
  String get expensesFormHeaderEditExpense => 'Edit Expense';

  @override
  String get expensesFormHeaderNewIncome => 'New Income';

  @override
  String get expensesFormHeaderNewExpense => 'New Expense';

  @override
  String get allowanceEntryTitle => 'Send allowance';

  @override
  String get allowanceSheetTitle => 'Send allowance';

  @override
  String get allowanceSheetSubtitle =>
      'Choose a recipient and amount. It is recorded as personal income.';

  @override
  String get allowanceRecipientLabel => 'To';

  @override
  String get allowanceAmountLabel => 'Amount';

  @override
  String get allowanceNoteHint => 'Optional note, e.g. June allowance';

  @override
  String get allowanceSubmitButton => 'Send allowance';

  @override
  String get allowanceNoRecipients =>
      'There are no teens with personal finances in this household.';

  @override
  String get allowanceRecipientRequired =>
      'Choose who should receive the allowance.';

  @override
  String get allowanceAmountInvalid => 'Enter a valid amount.';

  @override
  String get allowanceSendGenericError => 'We couldn\'t send the allowance.';

  @override
  String get allowanceMembersLoadError => 'We couldn\'t load the recipients.';

  @override
  String get allowanceSentScheduleFailed =>
      'The allowance was sent, but we couldn\'t schedule the monthly repeat.';

  @override
  String get allowanceScheduleDisableError =>
      'We couldn\'t disable the scheduled allowance. Try again.';

  @override
  String get allowanceSentSnack => 'Allowance sent.';

  @override
  String allowanceSendError(String error) {
    return 'Error sending allowance: $error';
  }

  @override
  String get expensesFormSelectCategoryTitle => 'Select category';

  @override
  String get expensesFormAutoTitleSupermarketShopping => 'Grocery shopping';

  @override
  String expensesFormShoppingSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items purchased',
      one: '1 item purchased',
    );
    return '$_temp0';
  }

  @override
  String get expensesFormShoppingDetectedTitle => 'Detected products';

  @override
  String get expensesFormShoppingLinkTitle => 'Link with shopping list';

  @override
  String expensesFormShoppingDetectedSummary(int linkedCount, int newCount) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedCount,
      locale: localeName,
      other: '$linkedCount items',
      one: '1 item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      newCount,
      locale: localeName,
      other: '$newCount new for your list',
      one: '1 new for your list',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get expensesFormShoppingWillMarkBought =>
      'They\'ll be marked as purchased when you save';

  @override
  String get expensesFormShoppingPreparingProducts => 'Preparing products...';

  @override
  String get expensesFormShoppingTapToLink => 'Tap to link items';

  @override
  String get expensesFormShoppingClearAllSemantic => 'Remove all links';

  @override
  String expensesFormShoppingDetectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count detected products',
      one: '1 detected product',
    );
    return '$_temp0';
  }

  @override
  String get expensesFormShoppingBadgeNew => 'new';

  @override
  String get expensesFormShoppingItemsSheetTitle => 'List items';

  @override
  String get expensesFormShoppingSearchHint => 'Search or add product...';

  @override
  String expensesFormShoppingAddQuery(String query) {
    return 'Add \"$query\"';
  }

  @override
  String get expensesFormShoppingCustomProduct => 'Custom product';

  @override
  String get expensesFormShoppingGlobalSuggestions => 'Global suggestions';

  @override
  String get expensesFormCategorySupermarket => 'Supermarket';

  @override
  String get expensesFormCategoryUtilities => 'Utilities';

  @override
  String get expensesFormCategoryRent => 'Rent & home';

  @override
  String get expensesFormCategoryRestaurants => 'Dining out';

  @override
  String get expensesFormCategoryTransport => 'Transport';

  @override
  String get expensesFormCategoryEntertainment => 'Leisure';

  @override
  String get expensesFormCategoryHealth => 'Health';

  @override
  String get expensesFormCategoryFinances => 'Savings & investing';

  @override
  String get expensesFormCategorySettlement => 'Balance settlement';

  @override
  String get expensesFormCategoryOnlineShopping => 'Online shopping';

  @override
  String get expensesFormCategoryPets => 'Pets';

  @override
  String get expensesFormCategoryClothing => 'Clothing & shoes';

  @override
  String get expensesFormCategoryElectronics => 'Technology';

  @override
  String get expensesFormCategoryEducation => 'Education';

  @override
  String get expensesFormCategoryOtherExpenses => 'Other expenses';

  @override
  String get expensesFormIncomeCategorySalary => 'Salary';

  @override
  String get expensesFormIncomeCategoryFreelance => 'Freelance';

  @override
  String get expensesFormIncomeCategorySales => 'Sales';

  @override
  String get expensesFormIncomeCategoryBonus => 'Bonus';

  @override
  String get expensesFormIncomeCategoryRefund => 'Refund';

  @override
  String get expensesFormIncomeCategoryGift => 'Gift';

  @override
  String get expensesFormIncomeCategoryInvestment => 'Investment return';

  @override
  String get expensesFormIncomeCategoryOtherIncome => 'Other income';

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
  String get premiumPaywallEyebrow => 'HomeSync Premium';

  @override
  String premiumPaywallEyebrowFor(String name) {
    return 'Premium · $name';
  }

  @override
  String premiumPaywallCoupleNames(String first, String second) {
    return '$first & $second';
  }

  @override
  String premiumPaywallTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'couple': 'One plan for both of you',
        'family': 'One plan for the whole family',
        'friends': 'One plan for the whole house',
        'other': 'Automate your household without duplicate entry',
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
            'One of you pays, you both get it: payments, shopping and budgets working together.',
        'family':
            'One person pays and the whole family gets it, including anyone who joins later.',
        'friends':
            'One person pays and everyone in the house gets it, including anyone who joins later.',
        'other':
            'Payments, shopping and budgets working together so the balance always stays clear.',
      },
    );
    return '$_temp0';
  }

  @override
  String get premiumBenefitRecurringPayments => 'Recurring payments';

  @override
  String get premiumBenefitRecurringPaymentsDesc =>
      'Schedule subscriptions, services, and installments so they repeat on their own and do not get lost during the month.';

  @override
  String get premiumBenefitShoppingFinanceSync =>
      'Shopping connected to Finance';

  @override
  String get premiumBenefitShoppingFinanceSyncDesc =>
      'Link shopping-list products with real expenses and avoid entering the same purchase twice.';

  @override
  String get premiumBenefitFullCustomization => 'Full customization';

  @override
  String get premiumBenefitFullCustomizationDesc =>
      'Choose colors, themes, and custom avatars so the household feels like yours.';

  @override
  String get premiumRestorePurchases => 'Restore purchases';

  @override
  String get premiumCancelAnytime => 'Cancel anytime';

  @override
  String premiumSavePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get premiumChoosePlanTitle => 'Choose your plan';

  @override
  String get premiumAnnualPlan => 'Annual';

  @override
  String get premiumMonthlyPlan => 'Monthly';

  @override
  String get premiumBestValueBadge => 'Best value';

  @override
  String get premiumBilledAnnually => 'Billed once a year';

  @override
  String get premiumBilledMonthly => 'Renews month to month';

  @override
  String premiumMonthlyEquivalent(String price) {
    return '$price/mo';
  }

  @override
  String premiumActivateAnnualCta(String price) {
    return 'Start Premium · $price/year';
  }

  @override
  String premiumActivateMonthlyCta(String price) {
    return 'Start Premium · $price/month';
  }

  @override
  String get premiumLegalTerms => 'Terms';

  @override
  String get premiumLegalPrivacy => 'Privacy';

  @override
  String get premiumAlreadyActiveTitle => 'Premium is active in your household';

  @override
  String get premiumAlreadyActiveBody =>
      'You\'re all set: premium features are now available for this household.';

  @override
  String get premiumActiveStatusPill => 'Plan active';

  @override
  String get premiumActiveBenefitsTitle => 'Enabled benefits';

  @override
  String get premiumContinueButton => 'Continue';

  @override
  String get premiumDeactivateTesting => 'Deactivate Premium (testing)';

  @override
  String get premiumStoreErrorTitle => 'We couldn\'t reach the store';

  @override
  String get premiumDeveloperModeButton => 'Developer Mode: Activate Premium';

  @override
  String get faqSheetTitle => 'Frequently Asked Questions';

  @override
  String get faqSheetSubtitle => 'Help tailored to your home';

  @override
  String get faqSearchHint => 'Search for a question...';

  @override
  String get faqSearchEmpty =>
      'Nothing matched your search. Try another word or tell us via “Send feedback”.';

  @override
  String faqContextPill(String label) {
    return 'Help for: $label';
  }

  @override
  String get faqCatHousehold => 'Your home';

  @override
  String get faqCatTasks => 'Tasks';

  @override
  String get faqCatRewards => 'Points & rewards';

  @override
  String get faqCatFinances => 'Finances';

  @override
  String get faqCatApp => 'The app & your account';

  @override
  String get faqHowSharedHome => 'How does my home work in HomeSync?';

  @override
  String faqHowSharedHomeAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple':
            'You and your partner share one digital home: tasks, expenses, the shopping list and savings live in one place and sync instantly. Whatever one adds, the other sees right away.',
        'family':
            'The whole family shares one digital home. Every member has a role (father, mother, guardian, teen or kid) and the app adapts what each one sees and can do: adults manage, kids contribute by completing tasks.',
        'friends':
            'Everyone living together shares tasks, expenses and shopping in one place, as equals: no hierarchies and no kid-style prizes, just a clear picture of what each person contributes.',
        'solo':
            'Your home is your personal space: organize your tasks, expenses and shopping list at your own pace. If you ever live with someone, invite them with a code and you\'re set.',
        'other':
            'You share one digital home: tasks, expenses, shopping and savings synced instantly across all members.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqInviteMembers => 'How do I invite someone to my home?';

  @override
  String faqInviteMembersAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family':
            'Your home\'s invitation code is in Settings: share it and, once entered in their app, that person joins with everything synced. Then, from the members list, adults assign their role (father, mother, guardian, teen or kid).',
        'other':
            'Your home\'s invitation code is in Settings: share it with whoever you want to add and, once entered in their app, they join with tasks, expenses and shopping already synced.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqFamilyRoles => 'What do the family roles mean?';

  @override
  String get faqFamilyRolesAnswer =>
      'Father, mother and guardians are the adults: they manage the home, approve tasks, handle shared finances and the rewards store. Teens get more autonomy and their own personal finance space. Kids get the simplest, most playful experience: complete tasks, earn coins and redeem rewards.';

  @override
  String get faqWhoSeesWhat => 'What does each member see?';

  @override
  String get faqWhoSeesWhatAnswer =>
      'Each role sees what belongs to them: adults see everything, shared finances included; teens see their personal finances but not the adults\' shared expenses; and kids don\'t see finances at all — their world is tasks, points and rewards.';

  @override
  String get faqTasksBasics => 'How do tasks work?';

  @override
  String get faqTasksBasicsAnswer =>
      'Create one-time or recurring tasks (daily, weekly, monthly), assign them to someone or leave them open for whoever grabs them. The calendar shows what\'s coming and recurring tasks reschedule themselves. In Couple mode, completing them updates shared progress without XP or coins.';

  @override
  String get faqApprovals => 'How do task approvals work?';

  @override
  String faqApprovalsAnswer(String role) {
    String _temp0 = intl.Intl.selectLogic(
      role,
      {
        'parent':
            'When a kid or teen marks a task as done, it waits for your approval: review it under Approvals and, once you confirm, the XP and coins are credited. Who needs approval is set in the household settings.',
        'teen':
            'Depending on how the home is set up, marking a task as done may leave it pending until an adult confirms it. Only then are your XP and coins credited.',
        'child':
            'When you mark a task as done, an adult reviews and confirms it. As soon as they approve, your XP and coins arrive!',
        'other':
            'Tasks completed by kids and teens may require an adult\'s confirmation before XP and coins are credited, depending on household settings.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqHowEarnXp => 'How do I earn XP and level up?';

  @override
  String get faqHowEarnXpAnswer =>
      'Every completed task earns XP (harder ones pay more). XP levels you up and unlocks achievements: medals for milestones like completing 50 tasks. All your progress lives in Stats.';

  @override
  String get faqWhatCoins => 'What are Coins for?';

  @override
  String faqWhatCoinsAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family':
            'Coins are the home currency: kids earn them by completing tasks and spend them in the rewards store on prizes the adults created — an outing, screen time, their favorite meal.',
        'other':
            'Couple mode doesn\'t use coins: tasks show how household work is shared and proposals are discussed without a price, debt or obligation. Coins are reserved for family dynamics with kids.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqWhatWeeklyDuels => 'Is there a weekly duel in Couple mode?';

  @override
  String get faqWhatWeeklyDuelsAnswer =>
      'No. In Couple mode, the week is viewed as shared effort: you can see how many tasks were completed and how they were shared, with no winner, score or bonus.';

  @override
  String get faqFamilyRanking => 'How does the family ranking work?';

  @override
  String get faqFamilyRankingAnswer =>
      'Every week the family competes in a healthy way: the ranking shows who earned the most XP completing tasks. At week\'s close there\'s a winner with a crown and bonus, and the weekly summary shows how everyone did.';

  @override
  String get faqWhatSpecialEvents => 'What\'s in the Couple tab?';

  @override
  String get faqWhatSpecialEventsAnswer =>
      'Find ideas to enjoy together, save your favorites, and tap “We did it” to collect memories in your shared album. No partner approval needed. You can also leave a note and check your chores and finances.';

  @override
  String get faqContributionBalance => 'What is the contribution balance?';

  @override
  String get faqContributionBalanceAnswer =>
      'It\'s the month\'s neutral snapshot: it combines completed tasks and shared expenses to show how much each person is contributing to the household. No winners or losers — it\'s for talking with data, not competing.';

  @override
  String get faqRewardsStore => 'How does the rewards store work?';

  @override
  String faqRewardsStoreAnswer(String role) {
    String _temp0 = intl.Intl.selectLogic(
      role,
      {
        'parent':
            'You create the rewards (an outing, game time, their favorite dessert) and set a coin price. Kids redeem them with what they earned completing tasks, and you confirm the redemption.',
        'other':
            'The store holds the rewards created by the adults of your home. Earn coins by completing tasks and redeem them when you have enough: the reward stays pending until an adult confirms it.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqHowFinancesWork => 'How do finances work?';

  @override
  String faqHowFinancesWorkAnswer(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'friends':
            'Every shared expense is split the way you configure it (equal parts or percentages). The balance shows who\'s up to date and who owes, and anyone can register a payment to settle up.',
        'family':
            'Shared finances are adult territory: household expenses are split among them. Teens get their own personal finance space, separate from the big accounts.',
        'other':
            'Record real expenses and also plan ones you haven\'t paid yet. Confirmed expenses affect the real balance between you; pending ones work as reminders and projections, but don\'t change the debt until paid.',
      },
    );
    return '$_temp0';
  }

  @override
  String get faqHowRecurringCount =>
      'How do recurring expenses and the estimated balance count?';

  @override
  String get faqHowRecurringCountAnswer =>
      'A new recurring expense starts from its first valid date. If you create it before or on the due date, it can count this month; if you create it after, it starts next cycle. “Your pending share” shows only what corresponds to you per the split, and “Estimated balance” takes your current balance minus that pending share.';

  @override
  String get faqWhoCanPay => 'Who can register a payment?';

  @override
  String get faqWhoCanPayAnswer =>
      'Either side can register a shared payment, even on behalf of the other — handy when one pays and the other logs it. “Paid” and “Pending” always show the household total, so everyone sees the same picture.';

  @override
  String get faqSavingsGoals => 'How do savings goals work?';

  @override
  String get faqSavingsGoalsAnswer =>
      'Create a goal with a target amount (a trip, an emergency fund) and add contributions over time. Progress is crystal clear and, in shared homes, everyone can contribute to the same goal.';

  @override
  String get faqPremium => 'What\'s included in HomeSync Premium?';

  @override
  String get faqPremiumAnswer =>
      'Premium activates for the whole home with a single purchase: animated premium mascots, exclusive theme colors and everything we keep adding. It\'s managed from Settings and only adults can purchase it.';

  @override
  String get faqCustomization => 'Can I customize the app?';

  @override
  String get faqCustomizationAnswer =>
      'Yes: light, dark or system theme, primary color (with Premium), language (Spanish or English) and the currency used to display finances. All under Settings → Appearance.';

  @override
  String get faqNotifications => 'Which notifications will I get?';

  @override
  String get faqNotificationsAnswer =>
      'Updates about your home: tasks assigned to you, expense news and pending approvals. Turn them on or off under Settings → Notifications.';

  @override
  String get faqAccountSafety => 'How do I keep my account and data safe?';

  @override
  String get faqAccountSafetyAnswer =>
      'Your session is personal: sign out anytime from Settings. If you need a fresh start, “Reset data” clears the home\'s content, and “Delete my account” removes it permanently. Your data lives encrypted in the cloud and only your home\'s members see what\'s shared.';

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
  String get feedbackEmailResponseTitle => 'I want to receive a reply by email';

  @override
  String get feedbackEmailResponseSubtitle =>
      'We\'ll write to your email if we need more context or have an update.';

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
  String get membersRoleFather => 'Father';

  @override
  String get membersRoleMother => 'Mother';

  @override
  String get membersRoleDad => 'Dad';

  @override
  String get membersRoleMom => 'Mom';

  @override
  String get membersRoleGuardianMale => 'Guardian';

  @override
  String get membersRoleGuardianFemale => 'Guardian';

  @override
  String get membersRoleSon => 'Son';

  @override
  String get membersRoleDaughter => 'Daughter';

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
  String get membersRoleUpdateError => 'Couldn\'t change the role. Try again.';

  @override
  String get membersRoleUpdated => 'Role updated';

  @override
  String get membersLoadError => 'Couldn\'t load the household members.';

  @override
  String get setupCreateHouseholdError =>
      'Couldn\'t create the household or generate the code. Try again.';

  @override
  String get setupJoinCodeLengthError => 'The code must be 6 characters long.';

  @override
  String get setupJoinHouseholdError =>
      'Couldn\'t join the household. Check the code and try again.';

  @override
  String get setupCompleteError => 'Couldn\'t finish setup. Try again.';

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
      'Your list is empty.\nWhat\'s missing at home?';

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
  String get rewardsPendingRedemptionsTitle => 'Prizes to deliver';

  @override
  String get rewardsPendingRedemptionsSubtitle =>
      'Redeemed prizes still waiting to be delivered.';

  @override
  String rewardsRedeemedByOn(String name, String date) {
    return 'Redeemed by $name · $date';
  }

  @override
  String rewardsRedeemedByYouOn(String date) {
    return 'You redeemed it on $date';
  }

  @override
  String get rewardsWaitingFulfillment => 'On its way';

  @override
  String get rewardsMarkFulfilled => 'Delivered';

  @override
  String get rewardsFulfillConfirmTitle => 'Prize delivered?';

  @override
  String rewardsFulfillConfirmBody(String title, String name) {
    return 'You\'re about to mark \"$title\" as delivered to $name.';
  }

  @override
  String rewardsFulfilledSnack(String title) {
    return 'You marked \"$title\" as delivered.';
  }

  @override
  String get rewardsMemberFallbackName => 'Member';

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
  String get rewardsSeedNothingNew =>
      'This home already has prizes or proposals loaded.';

  @override
  String get rewardsNoteOptionalLabel => 'NOTE (OPTIONAL)';

  @override
  String get rewardsSendProposal => 'Send proposal';

  @override
  String get rewardsCreatePrize => 'Create prize';

  @override
  String get rewardsProposalSentToast => 'Proposal sent.';

  @override
  String get rewardsPrizeCreatedToast => 'Prize created successfully.';

  @override
  String get rewardsEmptyNoChildStore =>
      'There are no prizes in your store yet.';

  @override
  String get rewardsNotYet => 'Not yet';

  @override
  String get rewardsYesWeDid => 'Yes, we did it';

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
      'Treats and rewards meant for the adults of the home.';

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
  String get coupleSpaceTaskEffortEyebrow => 'EFFORT';

  @override
  String get coupleSpaceTaskEffortTitle => 'How demanding is it?';

  @override
  String get coupleSpaceTaskEffortSubtitle =>
      'Difficulty helps you share tasks more fairly; it doesn\'t generate points or coins.';

  @override
  String coupleSpaceTaskCompletionMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks completed. The week moved forward a little more.',
      one: 'Task completed. The week moved forward a little more.',
    );
    return '$_temp0';
  }

  @override
  String get coupleSpacePlansSubtitle =>
      'Free proposals: accept, postpone or withdraw them without consequences.';

  @override
  String get coupleSpaceProposeAction => 'Propose something';

  @override
  String get coupleSpaceProposalAccepted => 'Agreed';

  @override
  String get coupleSpaceProposalDeferred => 'For later';

  @override
  String get coupleSpaceProposalCategoryTalk => 'Let\'s talk';

  @override
  String get coupleSpaceProposalCategoryPlan => 'Plan together';

  @override
  String get coupleSpaceProposalCategoryAffection => 'Affection';

  @override
  String get coupleSpaceProposalCategorySupport => 'Support';

  @override
  String get coupleSpaceNewProposalTitle => 'Propose something';

  @override
  String get coupleSpaceNewProposalBody =>
      'It has no price and creates no obligation. The other person can always say “not now”.';

  @override
  String get coupleSpaceProposalTitleLabel => 'What would you like to propose?';

  @override
  String get coupleSpaceProposalTitleHint => 'E.g. Cook something new together';

  @override
  String get coupleSpaceProposalDescriptionLabel =>
      'Tell them a bit more (optional)';

  @override
  String get coupleSpaceProposalDescriptionHint =>
      'What you have in mind, when it could happen or what you need';

  @override
  String get coupleSpaceProposalCategoryLabel => 'Proposal type';

  @override
  String get coupleSpaceProposalSend => 'Send proposal';

  @override
  String get coupleSpaceProposalTitleValidation =>
      'Enter at least 3 characters.';

  @override
  String get coupleSpaceProposalCreated =>
      'Proposal sent. It doesn\'t create any debt.';

  @override
  String get coupleSpaceProposalResponseTitle => 'Respond to the proposal';

  @override
  String get coupleSpaceProposalResponseBody =>
      'Choose freely. Saying “not now” costs no points and needs no explanation.';

  @override
  String get coupleSpaceProposalAccept => 'Sounds good';

  @override
  String get coupleSpaceProposalDefer => 'For later';

  @override
  String get coupleSpaceProposalDecline => 'Not now';

  @override
  String get coupleSpaceProposalWithdraw => 'Withdraw proposal';

  @override
  String get coupleSpaceProposalArchive => 'Archive';

  @override
  String get coupleSpaceProposalAcceptedToast => 'It\'s now an agreed plan.';

  @override
  String get coupleSpaceProposalDeferredToast =>
      'Saved so you can revisit it whenever you want.';

  @override
  String get coupleSpaceProposalDeclinedToast =>
      'Response saved with no penalties.';

  @override
  String get coupleSpaceProposalWithdrawnToast => 'You withdrew the proposal.';

  @override
  String get coupleSpaceProposalArchivedToast => 'Plan archived.';

  @override
  String get coupleSpaceLoadError => 'We couldn\'t load this space.';

  @override
  String tourStepLabel(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get tourWelcomeEyebrow => 'Welcome';

  @override
  String get tourCtaStart => 'Start';

  @override
  String get tourCtaNext => 'Next';

  @override
  String get tourCtaLater => 'Later';

  @override
  String get tourFinaleTitle => 'All set!';

  @override
  String get tourFinaleCta => 'Start using';

  @override
  String get tourCoupleWelcomeTitle => 'Your home, in 30 seconds';

  @override
  String get tourCoupleWelcomeBody =>
      'A quick look at the essentials: shared tasks, proposals, special moments and expenses.';

  @override
  String tourCoupleWelcomeBodyNamed(String partnerName) {
    return 'A quick look at the essentials to organize everything with $partnerName: shared tasks, proposals, special moments and expenses.';
  }

  @override
  String get tourTasksTitleHas => 'Tasks, shared together';

  @override
  String get tourTasksBodyHas =>
      'Tap ✓ to complete. Weekly progress helps you see what\'s left and share the work more fairly.';

  @override
  String get tourTasksTitleEmpty => 'Today at home is empty';

  @override
  String get tourTasksBodyEmpty =>
      'Your daily tasks will live here. Schedule the first one now and watch it appear — or keep the tour going and do it later.';

  @override
  String get tourTasksCtaCreate => 'Schedule a task';

  @override
  String get tourBalanceTitle => 'The home\'s pulse';

  @override
  String tourBalanceBody(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'shared':
            'You have integrated finances: there are no debts between you here, and you can see what the household spent this month.',
        'other':
            'Here you see what you owe each other for shared expenses. “Settle” squares up real expenses in one tap.',
      },
    );
    return '$_temp0';
  }

  @override
  String get tourBalanceBulletSettle => 'Settle → square up shared expenses';

  @override
  String get tourBalanceBulletMonth => 'Monthly spend → the home\'s pulse';

  @override
  String get tourBalanceBulletXp => 'XP → for the weekly duel';

  @override
  String get tourBalanceBulletCoins => 'Coins → to redeem rewards';

  @override
  String get tourDuelTitle => 'Weekly duel';

  @override
  String get tourDuelBody =>
      'Every week you compete for XP with a hidden score. Sunday reveals the winner. Resets on Mondays.';

  @override
  String get tourRewardsTitle => 'Redeem your coins';

  @override
  String get tourRewardsBody =>
      'Rewards live here: movie night, a massage, a day off. You two build the store and treat each other.';

  @override
  String tourExpensesTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'shared': 'The home\'s finances',
        'other': 'Split your expenses',
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
            'Record the home\'s expenses here: recurring bills, purchases and savings goals, all in one place.',
        'other':
            'Add home expenses and the app calculates who owes whom, using the split you configured.',
      },
    );
    return '$_temp0';
  }

  @override
  String get tourCoupleFinaleBody =>
      'Enjoy your home. If anything comes up, the FAQ adapts to you both.';

  @override
  String get tourFamilyWelcomeTitle => 'Your family, organized';

  @override
  String get tourFamilyWelcomeBody =>
      'A one-minute look at how to manage the whole family\'s tasks, points and rewards.';

  @override
  String get tourFamilyTasksTitleHas => 'The family\'s tasks';

  @override
  String tourFamilyTasksBody(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'approvals':
            'Assign tasks to everyone. When the kids complete theirs, they come to you for approval — only then do they collect their coins.',
        'other':
            'Assign tasks to everyone and follow the whole family\'s progress from here.',
      },
    );
    return '$_temp0';
  }

  @override
  String get tourFamilyFinanceTitle => 'Expenses, adults only';

  @override
  String get tourFamilyFinanceBody =>
      'The home\'s shared expenses are managed here, between adults only. Kids never see them.';

  @override
  String get tourFamilyRankingTitle => 'Weekly ranking';

  @override
  String get tourFamilyRankingBody =>
      'Every week, whoever earns the most XP completing tasks takes the crown. Healthy family competition.';

  @override
  String get tourFamilyRewardsTitle => 'The rewards store';

  @override
  String get tourFamilyRewardsBody =>
      'Create rewards (an outing, screen time, their favorite dessert) and the kids redeem them with the coins they earn.';

  @override
  String get tourFamilyFinaleBody =>
      'Go organize the troop. The FAQ adapts to your role if you need help.';

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
  String statsTasksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tasks',
      one: 'Task',
    );
    return '$_temp0';
  }

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
  String weeklyWinnerHeadline(String name) {
    return '$name won the week';
  }

  @override
  String get weeklyWinnerSubtitle => 'This is how the week closed between you.';

  @override
  String get weeklyWinnerCardSubtitle =>
      'A strong close: more consistency, more points, and more rhythm.';

  @override
  String get weeklyWinnerCoinsReward => '+20 coins';

  @override
  String weeklyWinnerCoinsAwarded(int coins) {
    return '+$coins coins';
  }

  @override
  String get weeklyWinnerSecondPlace => 'Second place';

  @override
  String get weeklyWinnerFinalScore => 'Final score';

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
  String get loveNoteHint => 'Write something tender...';

  @override
  String get loveNoteSent => 'Note sent with love';

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

  @override
  String get statsWeeklyProgressTitle => 'Weekly Progress';

  @override
  String get statsWeeklyProgressSubtitle =>
      'Follow how the week is going, who took the lead and how much rhythm you have together.';

  @override
  String get faceoffWeeklyDuelLabel => 'WEEKLY DUEL';

  @override
  String get faceoffHiddenScoreTitle =>
      'Your partner is playing with a hidden score';

  @override
  String get faceoffHiddenScoreSubtitle =>
      'You can see your own progress. The real result is revealed when the week closes.';

  @override
  String get faceoffYouLabel => 'You';

  @override
  String get faceoffPartnerLabel => 'Partner';

  @override
  String faceoffXpValue(int xp) {
    return '$xp XP';
  }

  @override
  String get faceoffHiddenXp => 'Hidden XP';

  @override
  String get faceoffWeeklyAdvantage => 'Weekly advantage';

  @override
  String get faceoffHiddenScore => 'Hidden score';

  @override
  String faceoffCurrentXpCounts(int xp) {
    return 'Your $xp XP already counts. Your partner\'s XP stays hidden until Sunday.';
  }

  @override
  String get faceoffWeeklyRhythm => 'Weekly rhythm';

  @override
  String get weekDayInitials => 'M,T,W,T,F,S,S';

  @override
  String get faceoffMyWeekLabel => 'Your week';

  @override
  String faceoffPersonalRecordChip(int xp) {
    return 'Best: $xp XP';
  }

  @override
  String faceoffStarterGoalChip(int xp) {
    return 'Goal: $xp XP';
  }

  @override
  String get faceoffNewRecord => 'New personal best!';

  @override
  String get faceoffClosesToday => 'Closes today';

  @override
  String faceoffDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get statsCurrentWeek => 'Current week';

  @override
  String get statsNoDataMessage =>
      'Start completing tasks to see your progress.';

  @override
  String get statsStreak => 'Streak';

  @override
  String statsStreakDays(Object count) {
    return '$count days';
  }

  @override
  String get statsStreakMessage => 'You are rocking it!';

  @override
  String get statsLevel => 'Level';

  @override
  String statsXPToNextLevel(Object count) {
    return '$count XP to go';
  }

  @override
  String get statsNoDataTitle => 'No data yet';

  @override
  String get statsNoDataSubtitle =>
      'Complete some tasks to see your areas of dominance.';

  @override
  String get commonRefresh => 'Refresh data';

  @override
  String get rewardsWaitingResponse => 'waiting for response';

  @override
  String get rewardsTapToApprove => 'tap to approve or remove';

  @override
  String rewardsCostCoins(Object cost) {
    return '$cost coins';
  }

  @override
  String householdSocialHubYourRole(Object role) {
    return 'Your role: $role';
  }

  @override
  String get householdSocialHubRoleFallback =>
      'Roles and rewards ready to organize the week.';

  @override
  String get householdSocialHubRoleMember => 'Member';

  @override
  String get contributionBalanceTitle => 'This month\'s contribution';

  @override
  String get contributionBalanceSubtitle =>
      'How things are split across the place.';

  @override
  String get contributionBalanceEmptyTitle => 'No contributions yet this month';

  @override
  String get contributionBalanceEmptyBody =>
      'Once you complete tasks or add shared expenses, you\'ll see how the split looks here.';

  @override
  String contributionBalanceTasksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '$count task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get contributionBalanceFootnote =>
      'No winners here: this is just to check we\'re even.';

  @override
  String get householdBillsTitle => 'Household bills';

  @override
  String get householdBillsSubtitle =>
      'Fixed expenses split between everyone each month.';

  @override
  String get householdBillsEmptyTitle => 'No fixed bills yet';

  @override
  String get householdBillsEmptyBody =>
      'Add rent, electricity or internet and they\'ll split automatically each month.';

  @override
  String get householdBillsAddButton => 'Add household bill';

  @override
  String get householdBillsPremiumBody =>
      'Fixed bills that split automatically every month are part of Premium.';

  @override
  String get householdBillsPremiumUnlock => 'Unlock with Premium';

  @override
  String householdBillsPerMonth(String amount) {
    return '$amount / mo';
  }

  @override
  String householdBillsDayOfMonth(int day) {
    return 'Day $day';
  }

  @override
  String get householdSettleUpTitle => 'Settle up';

  @override
  String get householdSettleUpSubtitle => 'Who owes who, so everyone\'s even.';

  @override
  String get householdSocialHubStoreButton => 'Store';

  @override
  String get householdSocialHubTrackingTitle => 'Family tracking';

  @override
  String get householdSocialHubTrackingSubtitle =>
      'Progress by member and weekly closing.';

  @override
  String get householdSocialHubShortcutMemberView => 'Member view';

  @override
  String get householdSocialHubShortcutWeeklySummary => 'Weekly summary';

  @override
  String householdSocialHubRankingPoints(Object count) {
    return '$count pts';
  }

  @override
  String get householdSocialHubRankingHidden => 'Hidden';

  @override
  String get householdSocialHubRankingSurprise => 'Surprise';

  @override
  String householdSocialHubRankingLeader(Object name) {
    return '$name is leading the week.';
  }

  @override
  String get householdSocialHubRankingHideHint =>
      'Since Thursday, we hide points to reveal the winner at the closing.';

  @override
  String get householdSocialHubRankingEmpty => 'Complete tasks to earn points';

  @override
  String householdSocialHubRankingEmptyTab(Object tab) {
    return 'No one earned points in $tab yet';
  }

  @override
  String householdSocialHubRankingTasksCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get householdSocialHubMemberFallback => 'Member';

  @override
  String get householdSocialHubLoading => 'Loading ranking...';

  @override
  String get householdSocialHubLoadError => 'We couldn\'t load the ranking.';

  @override
  String get householdSocialHubRetry => 'Retry';

  @override
  String get taskCategoryCleaningGeneral => 'General cleaning';

  @override
  String get taskCategoryKitchen => 'Kitchen';

  @override
  String get taskCategoryBedroom => 'Bedroom';

  @override
  String get taskCategoryBathroom => 'Bathroom';

  @override
  String get taskCategoryCommonSpaces => 'Common spaces';

  @override
  String get taskCategoryLaundry => 'Laundry';

  @override
  String get taskCategoryTrashRecycling => 'Trash / recycling';

  @override
  String get taskCategoryShoppingOrganization => 'Shopping / organization';

  @override
  String get taskCategoryPets => 'Pets';

  @override
  String get taskCategoryOutdoorGarden => 'Outdoor / garden';

  @override
  String get taskCategoryHomeMaintenance => 'Home maintenance';

  @override
  String get taskCategoryKidsCare => 'Kids / care';

  @override
  String get taskCategoryHomeAdmin => 'Home admin';

  @override
  String get taskTemplateSweepFloors => 'Sweep floors';

  @override
  String get taskTemplateVacuumFloorsOrRugs => 'Vacuum floors or rugs';

  @override
  String get taskTemplateMopFloors => 'Mop floors';

  @override
  String get taskTemplateDustFurniture => 'Dust furniture';

  @override
  String get taskTemplateCleanWindows => 'Clean windows';

  @override
  String get taskTemplateGeneralHouseTidying => 'General house tidying';

  @override
  String get taskTemplateDeepCleanGeneral => 'General deep clean';

  @override
  String get taskTemplateWashDishes => 'Wash the dishes';

  @override
  String get taskTemplateEmptyDishwasher => 'Put away / empty dishwasher';

  @override
  String get taskTemplateCookSimpleMeal => 'Cook a simple meal';

  @override
  String get taskTemplateCookFullMeal => 'Cook a full meal';

  @override
  String get taskTemplateSetTable => 'Set the table';

  @override
  String get taskTemplateClearTable => 'Clear the table';

  @override
  String get taskTemplateCleanCounters => 'Clean counters and surfaces';

  @override
  String get taskTemplateCleanFullKitchen => 'Clean the whole kitchen';

  @override
  String get taskTemplateCleanFridge => 'Clean the fridge';

  @override
  String get taskTemplateCleanOven => 'Clean the oven';

  @override
  String get taskTemplateOrganizePantry => 'Organize the pantry';

  @override
  String get taskTemplateMakeBed => 'Make the bed';

  @override
  String get taskTemplateTidyBedroom => 'Tidy the bedroom';

  @override
  String get taskTemplateChangeSheets => 'Change sheets';

  @override
  String get taskTemplateOrganizeCloset => 'Organize the closet';

  @override
  String get taskTemplateBedroomGeneralClean => 'General bedroom cleaning';

  @override
  String get taskTemplateCleanToilet => 'Clean the toilet';

  @override
  String get taskTemplateCleanSink => 'Clean the sink';

  @override
  String get taskTemplateCleanMirror => 'Clean the mirror';

  @override
  String get taskTemplateCleanShowerTub => 'Clean shower / bathtub';

  @override
  String get taskTemplateRestockBathroomSupplies =>
      'Restock toilet paper or soap';

  @override
  String get taskTemplateCleanFullBathroom => 'Clean the whole bathroom';

  @override
  String get taskTemplateTidyLivingRoom => 'Tidy living room';

  @override
  String get taskTemplateCleanFurniture => 'Clean furniture';

  @override
  String get taskTemplateCleanSofas => 'Clean sofas';

  @override
  String get taskTemplateCleanDiningTable => 'Clean dining table';

  @override
  String get taskTemplateCleanCommonArea => 'Vacuum or clean common area';

  @override
  String get taskTemplateWashLaundry => 'Do laundry';

  @override
  String get taskTemplateHangLaundry => 'Hang laundry';

  @override
  String get taskTemplateUseDryer => 'Use dryer';

  @override
  String get taskTemplateFoldPutAwayLaundry => 'Fold and put away laundry';

  @override
  String get taskTemplateIronClothes => 'Iron clothes';

  @override
  String get taskTemplateChangeTowels => 'Change towels';

  @override
  String get taskTemplateOrganizeWardrobe => 'Organize wardrobe';

  @override
  String get taskTemplateTakeOutTrash => 'Take out trash';

  @override
  String get taskTemplateSortRecycling => 'Sort recycling';

  @override
  String get taskTemplateTakeRecycling => 'Take out recycling';

  @override
  String get taskTemplateMakeShoppingList => 'Make shopping list';

  @override
  String get taskTemplateGoGroceryShopping => 'Go grocery shopping';

  @override
  String get taskTemplatePutAwayGroceries => 'Put away groceries';

  @override
  String get taskTemplatePlanWeeklyMenu => 'Plan weekly menu';

  @override
  String get taskTemplateFeedPet => 'Feed the pet';

  @override
  String get taskTemplateWalkPet => 'Walk the pet';

  @override
  String get taskTemplateCleanPetArea => 'Clean litter box / area';

  @override
  String get taskTemplateBathePet => 'Bathe pet';

  @override
  String get taskTemplatePetAreaGeneralClean => 'General pet area cleaning';

  @override
  String get taskTemplateWaterPlants => 'Water plants';

  @override
  String get taskTemplateCleanPatioTerrace => 'Clean patio / terrace';

  @override
  String get taskTemplateRakeLeaves => 'Rake leaves';

  @override
  String get taskTemplateMowLawn => 'Mow lawn';

  @override
  String get taskTemplateTidyGarden => 'Tidy garden';

  @override
  String get taskTemplateChangeLightBulbs => 'Change light bulbs';

  @override
  String get taskTemplateSmallHomeRepair => 'Small home repair';

  @override
  String get taskTemplateCheckFilters => 'Check filters';

  @override
  String get taskTemplateUnclogDrains => 'Unclog drains';

  @override
  String get taskTemplateMediumRepair => 'Medium repair';

  @override
  String get taskTemplateLargeRepair => 'Large repair';

  @override
  String get taskTemplateTidyToys => 'Tidy toys';

  @override
  String get taskTemplateFeedKids => 'Feed kids';

  @override
  String get taskTemplateHelpWithHomework => 'Help with homework';

  @override
  String get taskTemplateSchoolPickupDropoff => 'School pickup or drop-off';

  @override
  String get taskTemplateBatheKids => 'Bathe kids';

  @override
  String get taskTemplatePayBills => 'Pay bills';

  @override
  String get taskTemplateReviewHouseholdExpenses => 'Review household expenses';

  @override
  String get taskTemplateOrganizeDocuments => 'Organize documents';

  @override
  String get taskTemplatePlanHouseholdTasks => 'Plan household tasks';

  @override
  String get taskTemplateCleanMicrowave => 'Clean the microwave';

  @override
  String get taskTemplateWashCar => 'Wash the car';

  @override
  String get taskTemplateCleanTrashBins => 'Clean the trash bins';

  @override
  String get taskTemplatePackSchoolBag => 'Pack the school bag';

  @override
  String get taskTemplateGivePetWater => 'Refresh the pet\'s water';

  @override
  String addTaskOptionsAddedSnack(String title) {
    return '\"$title\" added';
  }

  @override
  String get addTaskOptionsAddError => 'We couldn\'t add the task.';

  @override
  String get editTaskSaveError => 'We couldn\'t save the changes.';

  @override
  String get editTaskDeleteError => 'We couldn\'t delete the task.';

  @override
  String get recurringExpenseSaveError =>
      'We couldn\'t save this recurring item.';

  @override
  String get recurringExpenseMembersLoadError =>
      'We couldn\'t load the household members.';

  @override
  String get recurringExpenseValidationTitleAmount =>
      'Add a title and a valid amount.';

  @override
  String get recurringExpenseValidationPayer =>
      'Choose who usually pays it to finish setup.';

  @override
  String get recurringExpenseDeleteTitle => 'Delete subscription?';

  @override
  String get recurringExpenseDeleteBody =>
      'It will stop appearing in future months.';

  @override
  String get recurringExpenseDetailEyebrow => 'DETAIL';

  @override
  String get recurringExpenseDetailTitle => 'What renews every month';

  @override
  String get recurringExpenseDetailSubtitle =>
      'Set the name and amount so it is easy to recognize.';

  @override
  String get recurringExpenseCalendarEyebrow => 'CALENDAR';

  @override
  String get recurringExpenseCalendarTitle => 'When it is recorded';

  @override
  String get recurringExpenseCalendarSubtitle =>
      'Choose the usual day so it can be scheduled automatically.';

  @override
  String get recurringExpenseCategoryEyebrow => 'CATEGORY';

  @override
  String get recurringExpenseCategoryTitle => 'Where it fits best';

  @override
  String get recurringExpenseCategorySubtitle =>
      'Helps keep Finance organized and easy to read.';

  @override
  String get recurringExpenseSplitEyebrow => 'SPLIT';

  @override
  String get recurringExpenseSplitTitle => 'How it is split';

  @override
  String get recurringExpenseSplitSubtitle =>
      'Decide whether it is shared in the household or stays personal.';

  @override
  String get recurringExpensePayerEyebrow => 'PAYER';

  @override
  String get recurringExpensePayerTitle => 'Who usually pays it';

  @override
  String get recurringExpensePayerSubtitle =>
      'This keeps a suggestion ready for future months.';

  @override
  String get recurringExpenseHeaderEditIncome => 'Edit income';

  @override
  String get recurringExpenseHeaderEditSubscription => 'Edit subscription';

  @override
  String get recurringExpenseHeaderNewIncome => 'New fixed income';

  @override
  String get recurringExpenseHeaderNewSubscription => 'New subscription';

  @override
  String get recurringExpenseHeaderEditSubtitle =>
      'Adjust amount, category, and split to keep it up to date.';

  @override
  String get recurringExpenseHeaderNewIncomeSubtitle =>
      'It will be added to your balance automatically each month.';

  @override
  String get recurringExpenseHeaderNewSubscriptionSubtitle =>
      'Set it up once so it can be recorded automatically every month.';

  @override
  String get recurringExpenseDeleteIncome => 'Delete income';

  @override
  String get recurringExpenseDeleteSubscription => 'Delete subscription';

  @override
  String get recurringExpenseNameRequired =>
      'Add a name so you can recognize it.';

  @override
  String get recurringExpenseNameMinLength => 'Use at least 3 characters.';

  @override
  String get recurringExpenseNameLabel => 'Name';

  @override
  String get recurringExpenseNameHint => 'E.g. Netflix, rent, or internet';

  @override
  String get recurringExpenseAmountLabel => 'Default amount';

  @override
  String get recurringExpenseSaveIncome => 'Save income';

  @override
  String get recurringExpenseSaveSubscription => 'Save subscription';

  @override
  String get recurringExpenseCategoryLabel => 'Category:';

  @override
  String get recurringExpenseSplitLabel => 'Expense split:';

  @override
  String get recurringExpenseAmountInvalid => 'Enter a valid amount.';

  @override
  String get recurringExpenseAmountPositive =>
      'Amount must be greater than zero.';

  @override
  String get recurringExpenseDayLabel => 'Charge day:';

  @override
  String get recurringExpenseRegularPayerLabel => 'Regular payer:';

  @override
  String expensesNewItemsAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products added to the list',
      one: '1 product added to the list',
    );
    return '$_temp0';
  }

  @override
  String get expensesNewItemsDetectedTitle => 'New for your list';

  @override
  String get expensesNewItemsDetectedSubtitle =>
      'Should we add them to the list for next time?';

  @override
  String get expensesNewItemsIgnore => 'Ignore';

  @override
  String expensesNewItemsAddToList(int count) {
    return 'Add $count to list';
  }

  @override
  String get expensesNewItemsAddError =>
      'We couldn\'t add every item. Retry the ones left.';

  @override
  String get expensesRecurringLoadError =>
      'We couldn\'t load your recurring expenses.';

  @override
  String get expensesFormSaveError => 'We couldn\'t save the entry. Try again.';

  @override
  String get expensesFormMembersLoadError =>
      'We couldn\'t load the household members.';

  @override
  String get expensesDeleteError => 'We couldn\'t delete the entry. Try again.';

  @override
  String expensesPlannedPaymentTitle(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'Confirm income',
        'other': 'Confirm payment',
      },
    );
    return '$_temp0';
  }

  @override
  String expensesPlannedPaymentSubtitle(String type, String title) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'You\'ll mark \"$title\" as collected.',
        'other': 'You\'ll mark \"$title\" as paid.',
      },
    );
    return '$_temp0';
  }

  @override
  String get expensesPlannedPaymentAmountEyebrow => 'ACTUAL AMOUNT';

  @override
  String expensesPlannedPaymentDateEyebrow(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'income': 'INCOME DATE',
        'other': 'PAYMENT DATE',
      },
    );
    return '$_temp0';
  }

  @override
  String get expensesDetailHeaderIncome => 'Income detail';

  @override
  String get expensesDetailHeaderSettlement => 'Balance settlement detail';

  @override
  String get expensesDetailHeaderExpense => 'Expense detail';

  @override
  String expensesDetailPaidBy(String name) {
    return 'Paid by $name';
  }

  @override
  String get expensesDetailNoteLabel => 'Note:';

  @override
  String get expensesDetailPurchasedItems => 'Purchased items';

  @override
  String get expensesDetailLabel => 'Detail';

  @override
  String get expensesDetailSplitLabel => 'Split';

  @override
  String get expensesDetailPaidLabel => 'Paid';

  @override
  String get expensesDetailTheirPartLabel => 'Their part';

  @override
  String get expensesDetailSplitEqual => 'Even split';

  @override
  String get expensesDetailSplitPersonal => 'Personal expense';

  @override
  String expensesRecurrentesDayOfMonth(int day) {
    return 'Day $day of each month';
  }

  @override
  String get expensesRecurrentesPremiumTitle => 'Recurring payments';

  @override
  String get expensesRecurrentesPremiumSubtitle =>
      'Manage subscriptions, rent, and services automatically with HomeSync Premium.';

  @override
  String get expensesRecurrentesPremiumCta => 'LEARN MORE';

  @override
  String get expensesRecurrentesPremiumBullet1 =>
      'Rent, utilities and subscriptions log themselves every month.';

  @override
  String get expensesRecurrentesPremiumBullet2 =>
      'Reminders before due dates so nothing slips.';

  @override
  String get expensesRecurrentesPremiumBullet3 =>
      'Everyone sees what\'s coming and what\'s left to pay.';

  @override
  String get expensesRecurringEmptyTitle => 'No recurring items';

  @override
  String get expensesRecurringEmptySubtitle =>
      'Create templates for subscriptions, rent, utilities, or fixed income.';

  @override
  String get expensesRecurringIncomeSection => 'FIXED INCOME';

  @override
  String get expensesRecurringExpenseSection => 'FIXED EXPENSES';

  @override
  String get financeTitleSupermarket => 'Supermarket';

  @override
  String get financeTitleOnlineShopping => 'Online shopping';

  @override
  String get financeTitleBalanceSettlement => 'Balance settlement';

  @override
  String get financeTitlePartnerSettlement => 'Partner settlement';

  @override
  String get financeTitleSalary => 'Salary';

  @override
  String get financeTitleRent => 'Rent';

  @override
  String get financeTitleBuildingFees => 'Building fees';

  @override
  String get financeTitleGas => 'Gas';

  @override
  String get financeTitleElectricity => 'Electricity';

  @override
  String get financeTitleWater => 'Water';

  @override
  String get financeTitleInternet => 'Internet';

  @override
  String get financeTitleNetflix => 'Netflix';

  @override
  String get financeTitleMovies => 'Movies';

  @override
  String get financeTitleInsurance => 'Insurance';

  @override
  String get financeTitlePhone => 'Phone';

  @override
  String get expensesSavingsGoalNameLabel => 'Name';

  @override
  String get expensesSavingsGoalNameHint => 'What\'s your goal?';

  @override
  String get expensesSavingsGoalAmountLabel => 'Target amount';

  @override
  String get expensesSavingsGoalAmountHint => 'How much do you want to save?';

  @override
  String savingsLoadError(String details) {
    return 'Error: $details';
  }

  @override
  String get savingsEmptyTitle => 'No active goals yet';

  @override
  String get savingsEmptySubtitle =>
      'Start saving for something you\'re really excited about.';

  @override
  String get savingsEmptyFallbackSubtitle =>
      'Start organizing your household finances today.';

  @override
  String savingsGoalTarget(String amount) {
    return 'Goal: $amount';
  }

  @override
  String get savingsGoalProgressCaption => 'of goal';

  @override
  String savingsGoalSaved(String amount) {
    return 'Saved: $amount';
  }

  @override
  String savingsGoalSavedOf(String amount) {
    return 'saved of $amount';
  }

  @override
  String get savingsGoalContributeAction => 'Add funds';

  @override
  String get savingsNewGoalTitle => 'New Goal';

  @override
  String savingsNewGoalSubtitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'solo':
            'Define what you want to achieve and how much you need to save to make it happen.',
        'family':
            'Define what your family wants to achieve and how much you need to save together.',
        'friends':
            'Define what you want to achieve and how much you need to save together.',
        'other':
            'Define what you want to achieve together and how much you need to save to make it happen.',
      },
    );
    return '$_temp0';
  }

  @override
  String get savingsSectionDetail => 'DETAILS';

  @override
  String savingsSectionDetailTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'solo': 'What you want to reach',
        'family': 'What your family wants to reach',
        'friends': 'What you want to reach',
        'other': 'What you want to reach',
      },
    );
    return '$_temp0';
  }

  @override
  String get savingsSectionPersonalization => 'PERSONALIZATION';

  @override
  String get savingsSectionPersonalizationTitle => 'Make it yours';

  @override
  String get savingsFieldEmoji => 'Emoji';

  @override
  String get savingsFieldColor => 'Color';

  @override
  String get savingsPickIconTitle => 'Pick an icon';

  @override
  String get savingsPickColorTitle => 'Pick a color';

  @override
  String get savingsCreateGoalAction => 'Create Goal';

  @override
  String get savingsContributeTo => 'Add money to';

  @override
  String get savingsConfirmContribution => 'Confirm Contribution';

  @override
  String get savingsTotalLabel => 'Total Saved';

  @override
  String get savingsStatGoals => 'Goals';

  @override
  String get savingsStatCompleted => 'Completed';

  @override
  String get savingsHistoryTitle => 'CONTRIBUTION HISTORY';

  @override
  String get savingsCompletedGoalsHistoryTitle => 'Completed goals';

  @override
  String savingsContributionLine(String name, String amount) {
    return '$name added $amount';
  }

  @override
  String savingsSharedContributionLine(String names, String amount) {
    return '$names contributed $amount';
  }

  @override
  String get savingsContributionSomeone => 'Someone';

  @override
  String get savingsCompletedBadge => 'Reached!';

  @override
  String savingsDeadlineChip(String date) {
    return 'By $date';
  }

  @override
  String get savingsEditAction => 'Edit goal';

  @override
  String get savingsDeleteAction => 'Delete';

  @override
  String get savingsDeleteConfirmTitle => 'Delete goal?';

  @override
  String savingsDeleteConfirmBody(String title) {
    return 'The record for \"$title\" will be lost.';
  }

  @override
  String get savingsArchiveAction => 'Archive';

  @override
  String get savingsArchiveConfirmTitle => 'Archive completed goal?';

  @override
  String get savingsArchiveConfirmBody =>
      'The goal will be saved as completed and stop showing in the list.';

  @override
  String get savingsEditGoalTitle => 'Edit Goal';

  @override
  String get savingsSaveChangesAction => 'Save changes';

  @override
  String get savingsContributeSplitTitle => 'HOW TO LOG THIS CONTRIBUTION?';

  @override
  String get savingsContributeSoloLabel => 'Just me';

  @override
  String get savingsContributeSoloDesc =>
      'Comes out of your pocket, like a gift.';

  @override
  String savingsContributeSharedLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'As a family',
        'friends': 'Everyone',
        'solo': 'Everyone',
        'other': 'As a couple',
      },
    );
    return '$_temp0';
  }

  @override
  String savingsContributeSharedDesc(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family': 'Split among the household adults.',
        'friends': 'Split among housemates.',
        'solo': 'Split per the household economy.',
        'other': 'Split between you and your partner.',
      },
    );
    return '$_temp0';
  }

  @override
  String get savingsNoteLabel => 'Note (optional)';

  @override
  String get savingsNoteHint => 'What is this contribution for?';

  @override
  String get savingsTargetDateLabel => 'Target date (optional)';

  @override
  String get savingsTargetDateClear => 'No deadline';

  @override
  String savingsSuggesterMessage(String amount, String percent, String goal) {
    return 'Based on your plan, you could save $amount extra this month. That would advance your \"$goal\" goal by $percent%!';
  }

  @override
  String get savingsSuggesterCta => 'Contribute now';

  @override
  String get savingsCompletedCelebrationTitle => 'Goal reached! 🎉';

  @override
  String savingsCompletedCelebrationBody(String title) {
    return 'You saved it all for \"$title\". Congrats!';
  }

  @override
  String get savingsCelebrationDismiss => 'Awesome!';

  @override
  String get achievementsBadgesSection => 'Your Badges';

  @override
  String get achievementsCoupleChallengesSection => 'Couple Challenges';

  @override
  String get achievementsIconicMomentsSection => 'Iconic Moments';

  @override
  String get achievementsFirstStepsTitle => 'First Steps';

  @override
  String get achievementsFirstStepsDesc =>
      'You completed your first task as a couple.';

  @override
  String get achievementsUnstoppableTitle => 'Unstoppable Team';

  @override
  String get achievementsUnstoppableDesc => 'You completed 50 tasks together.';

  @override
  String get achievementsHomeMastersTitle => 'Home Masters';

  @override
  String get achievementsHomeMastersDesc => 'You reached 5000 accumulated XP.';

  @override
  String get achievementsCollectorTitle => 'Date Collector';

  @override
  String get achievementsLoveInMotionTitle => 'Love in Motion';

  @override
  String get achievementsDeepConnectionTitle => 'Deep Connection';

  @override
  String get achievementsRomanceLegendsTitle => 'Romance Legends';

  @override
  String get achievementsRomanceLegendsDesc =>
      'You completed all 50 challenges of the year!';

  @override
  String achievementsSpecialChallengesDesc(int count) {
    return 'You completed $count special challenges.';
  }

  @override
  String get achievementsLoveRootsTitle => 'Roots of Love';

  @override
  String get achievementsLoveRootsDesc => 'You recreated your first date.';

  @override
  String get achievementsBlindDateTitle => 'Blind Date';

  @override
  String get achievementsBlindDateDesc =>
      'You completed a blind or sensory dinner.';

  @override
  String get achievementsDreamArchitectsTitle => 'Dream Architects';

  @override
  String get achievementsDreamArchitectsDesc =>
      'You designed your shared goals list.';

  @override
  String get achievementsSoloMilestonesSection => 'Your milestones';

  @override
  String get achievementsSoloFirstStepTitle => 'First step';

  @override
  String get achievementsSoloFirstStepDesc =>
      'You completed your first task in your space.';

  @override
  String get achievementsSoloRoutineTitle => 'Routine in motion';

  @override
  String get achievementsSoloRoutineDesc => 'You completed 50 personal tasks.';

  @override
  String get achievementsSoloHomeClearTitle => 'Clearer home';

  @override
  String get achievementsSoloHomeClearDesc =>
      'You reached 5000 XP while building your rhythm.';

  @override
  String get achievementsSoloNextSection => 'Next milestones';

  @override
  String get achievementsSoloWeekTitle => 'Active week';

  @override
  String get achievementsSoloWeekDesc =>
      'You sustained several actions in your home.';

  @override
  String get achievementsSoloRhythmTitle => 'Own rhythm';

  @override
  String get achievementsSoloRhythmDesc =>
      'Your routine is starting to have continuity.';

  @override
  String get achievementsSoloOwnSpaceTitle => 'Own space';

  @override
  String get achievementsSoloOwnSpaceDesc =>
      'Your personal progress already has identity.';

  @override
  String get scheduleTitle => 'Schedule task';

  @override
  String get scheduleSubtitle => 'Choose how it repeats and who\'s in charge.';

  @override
  String get scheduleSectionRepeat => 'REPEAT';

  @override
  String get scheduleSectionResponsible => 'ASSIGNEE';

  @override
  String get scheduleRepeatNone => 'None';

  @override
  String get scheduleRepeatDaily => 'Daily';

  @override
  String get scheduleRepeatWeekly => 'Weekly';

  @override
  String get scheduleRepeatMonthly => 'Monthly';

  @override
  String get scheduleRepeatCustom => 'Custom';

  @override
  String get scheduleWeeklyTitle => 'Pick the day of the week';

  @override
  String get scheduleWeeklySubtitle =>
      'The task will repeat every week on that day.';

  @override
  String get scheduleMonthlyTitle => 'Pick the day of the month';

  @override
  String get scheduleMonthlySubtitle =>
      'The task will repeat every month on that date.';

  @override
  String get scheduleCustomTabDays => 'Days';

  @override
  String get scheduleCustomTabInterval => 'Interval';

  @override
  String get scheduleCustomTabDate => 'Date';

  @override
  String get scheduleIntervalEvery => 'Every';

  @override
  String get scheduleIntervalDecrease => 'Decrease';

  @override
  String get scheduleIntervalIncrease => 'Increase';

  @override
  String scheduleIntervalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String get scheduleAssigneeAnyone => 'Anyone';

  @override
  String get scheduleAssigneeAnyoneSubtitle =>
      'Open for whoever wants to do it.';

  @override
  String get scheduleAssigneeMemberSubtitle =>
      'Main person responsible for this task.';

  @override
  String get scheduleAssigneeMemberFallback => 'Member';

  @override
  String get scheduleErrorPickWeekday =>
      'Pick at least one day for the custom recurrence.';

  @override
  String get scheduleErrorPickMonthDay =>
      'Pick at least one date to repeat the task.';

  @override
  String get invitationTitle => 'Invite to household';

  @override
  String get invitationSubtitleFamily => 'Share this code with your family.';

  @override
  String get invitationSubtitleFriends =>
      'Share this code with the people you live with.';

  @override
  String get invitationSubtitleDefault =>
      'Share this code so someone can join your household.';

  @override
  String get invitationTapToCopy => 'Tap to copy';

  @override
  String get invitationCopied => 'Code copied to clipboard';

  @override
  String get invitationShareWhatsApp => 'Share via WhatsApp';

  @override
  String get invitationRetry => 'Retry generating code';

  @override
  String get invitationIntroCouple =>
      'Hi! Join me on HomeSync so we can organize our chores and expenses.';

  @override
  String get invitationIntroFamily =>
      'Hi! I\'m inviting you to join our family household on HomeSync.';

  @override
  String get invitationIntroFriends =>
      'Hi! Join our shared place on HomeSync so we can keep the house organized.';

  @override
  String get invitationIntroDefault =>
      'Hi! I\'m inviting you to join our household on HomeSync.';

  @override
  String get avatarPickerTitle => 'Your Visual Identity';

  @override
  String get avatarPickerSubtitle =>
      'Pick an avatar from the collection or create your own';

  @override
  String get avatarPickerUpdated => 'Avatar updated successfully';

  @override
  String avatarPickerUpdateError(String error) {
    return 'Error updating avatar: $error';
  }

  @override
  String get avatarPickerPremiumSection => 'Premium avatars';

  @override
  String get avatarPickerYourCustomSection => 'Your custom ones';

  @override
  String get avatarPickerCustomKeepHint =>
      'We keep the last 6 generated by AI.';

  @override
  String get avatarPickerCustomName => 'Custom';

  @override
  String get avatarPickerDeleteCustom => 'Delete custom avatar';

  @override
  String get avatarPickerDeleteCustomTitle => 'Delete avatar?';

  @override
  String get avatarPickerDeleteCustomBody =>
      'This custom avatar will be deleted. If you\'re using it, we\'ll switch you back to the basic avatar.';

  @override
  String get avatarPickerCustomDeleted => 'Custom avatar deleted';

  @override
  String avatarPickerCustomDeleteError(String error) {
    return 'Could not delete avatar: $error';
  }

  @override
  String get avatarPickerCreateCustom => 'Create custom avatar (1 per month)';

  @override
  String get avatarPickerUnlockCustom => 'Unlock custom avatar';

  @override
  String get avatarPickerAiCardTitle => 'Your AI avatar';

  @override
  String get avatarPickerAiCardBody =>
      'Turn a photo into an illustrated HomeSync-style avatar. You get 1 creation per month.';

  @override
  String get avatarPickerAiCreateButton => 'Create my avatar';

  @override
  String avatarPickerAiUsedThisMonth(String date) {
    return 'You already created this month\'s avatar. You can create a new one on $date.';
  }

  @override
  String get avatarPickerGooglePhotoTitle => 'Google photo';

  @override
  String get avatarPickerGooglePhotoSubtitle =>
      'Use your Google account picture as your avatar.';

  @override
  String get avatarPickerCustomSheetTitle => 'Custom avatar';

  @override
  String get avatarPickerCustomSheetBody =>
      'You get 1 creation per month. It\'s saved as a new avatar and we keep your last 6 custom ones. If you leave Premium, they stay saved but locked.';

  @override
  String get avatarPickerTakePhoto => 'Take a photo';

  @override
  String get avatarPickerChooseFromGallery => 'Choose from gallery';

  @override
  String get avatarPickerCreatingTitle => 'Creating your avatar...';

  @override
  String get avatarPickerCreatingSubtitle => 'It may take a few seconds.';

  @override
  String settingsMemberRemoved(String name) {
    return '✅ $name has been removed from the household';
  }

  @override
  String get rewardCategoryTreats => 'Treats';

  @override
  String get rewardCategoryMoments => 'Moments';

  @override
  String get rewardCategoryPerks => 'Perks';

  @override
  String get rewardCategoryExperiences => 'Experiences';

  @override
  String get rewardCategoryFamily => 'Family';

  @override
  String get rewardCategoryOther => 'Other';

  @override
  String get rewardTemplateCoffeeMatePrepared => 'Coffee or mate made for you';

  @override
  String get rewardTemplateCoffeeMatePreparedDescription =>
      'A cozy pause made with care';

  @override
  String get rewardTemplateSurpriseSnack => 'Surprise snack';

  @override
  String get rewardTemplateSurpriseSnackDescription =>
      'An unexpected treat to brighten the day';

  @override
  String get rewardTemplateMiniRomanticNote => 'Mini romantic note';

  @override
  String get rewardTemplateMiniRomanticNoteDescription =>
      'A short message to make you smile';

  @override
  String get rewardTemplateMassage15Minutes => '15-minute massage';

  @override
  String get rewardTemplateMassage15MinutesDescription =>
      'A relaxing 15-minute massage';

  @override
  String get rewardTemplateIceCreamChoice => 'Ice cream of your choice';

  @override
  String get rewardTemplateIceCreamChoiceDescription =>
      'A cold dessert to celebrate';

  @override
  String get rewardTemplateMovieNightHome => 'Movie night at home';

  @override
  String get rewardTemplateMovieNightHomeDescription =>
      'A movie and a special at-home mood';

  @override
  String get rewardTemplateGamingAfternoon => 'Gaming afternoon';

  @override
  String get rewardTemplateGamingAfternoonDescription =>
      'Play together with snacks included';

  @override
  String get rewardTemplateBoardGameNight => 'Board game night';

  @override
  String get rewardTemplateBoardGameNightDescription =>
      'Time for games and laughs';

  @override
  String get rewardTemplateSpecialHomemadeDinner => 'Special homemade dinner';

  @override
  String get rewardTemplateSpecialHomemadeDinnerDescription =>
      'Your favorite meal made at home';

  @override
  String get rewardTemplateHomePicnic => 'Picnic at home';

  @override
  String get rewardTemplateHomePicnicDescription =>
      'A blanket, something tasty, and time offline';

  @override
  String get rewardTemplateNoScreensNight => 'No-screens night';

  @override
  String get rewardTemplateNoScreensNightDescription =>
      'Time to talk and reconnect';

  @override
  String get rewardTemplateEpisodeMarathonChoice =>
      'Episode marathon of your choice';

  @override
  String get rewardTemplateEpisodeMarathonChoiceDescription =>
      'You pick the show and the pace';

  @override
  String get rewardTemplateNoDishesVoucher => 'No dishes voucher';

  @override
  String get rewardTemplateNoDishesVoucherDescription =>
      'You get to skip that chore today';

  @override
  String get rewardTemplateChooseMovieVoucher => 'Choose the movie voucher';

  @override
  String get rewardTemplateChooseMovieVoucherDescription =>
      'You pick what to watch';

  @override
  String get rewardTemplateChooseSeriesWeekVoucher =>
      'Choose the series for a week voucher';

  @override
  String get rewardTemplateChooseSeriesWeekVoucherDescription =>
      'Your series, your rules for 7 days';

  @override
  String get rewardTemplateWeekendPlanVoucher =>
      'Choose the weekend plan voucher';

  @override
  String get rewardTemplateWeekendPlanVoucherDescription =>
      'You pick the main plan';

  @override
  String get rewardTemplateSkipOneChoreVoucher => 'Skip one chore voucher';

  @override
  String get rewardTemplateSkipOneChoreVoucherDescription =>
      'Pick one chore to delegate';

  @override
  String get rewardTemplateYesToAnyPlanVoucher => 'Yes to any plan voucher';

  @override
  String get rewardTemplateYesToAnyPlanVoucherDescription =>
      'Your idea happens today';

  @override
  String get rewardTemplateDinnerOut => 'Dinner out';

  @override
  String get rewardTemplateDinnerOutDescription =>
      'Dinner out somewhere special';

  @override
  String get rewardTemplatePlannedDate => 'Fully planned date';

  @override
  String get rewardTemplatePlannedDateDescription =>
      'A full plan organized from start to finish';

  @override
  String get rewardTemplateChoreFreeDay => 'Chore-free day';

  @override
  String get rewardTemplateChoreFreeDayDescription =>
      'Zero obligations for the whole day';

  @override
  String get rewardTemplateExtraScreen15Minutes =>
      '15 extra minutes of screen time';

  @override
  String get rewardTemplateExtraScreen15MinutesDescription =>
      'A little more time to play or watch something.';

  @override
  String get rewardTemplateChooseDinner => 'Choose dinner';

  @override
  String get rewardTemplateChooseDinnerDescription =>
      'Pick the menu for one night at home.';

  @override
  String get rewardTemplateIceCreamForEveryone => 'Ice cream for everyone';

  @override
  String get rewardTemplateIceCreamForEveryoneDescription =>
      'A family ice cream outing or delivery order.';

  @override
  String get rewardTemplateSmallToyPrize => 'Small toy or prize';

  @override
  String get rewardTemplateSmallToyPrizeDescription =>
      'Redeem something simple chosen with an adult.';

  @override
  String get rewardTemplateFamilyMovieNight => 'Family movie night';

  @override
  String get rewardTemplateFamilyMovieNightDescription =>
      'A simple plan to enjoy together.';

  @override
  String get rewardTemplateOrderTakeout => 'Order takeout';

  @override
  String get rewardTemplateOrderTakeoutDescription =>
      'A night without cooking for the whole family.';

  @override
  String get rewardTemplateWeekendFamilyPlan => 'Weekend family plan';

  @override
  String get rewardTemplateWeekendFamilyPlanDescription =>
      'Choose an outing or activity to do together.';

  @override
  String get rewardTemplateSpecialDessert => 'Special dessert';

  @override
  String get rewardTemplateSpecialDessertDescription =>
      'Pick a favorite dessert for after dinner.';

  @override
  String get errorGeneric => 'Something went wrong. Try again in a moment.';

  @override
  String get errorOffline => 'No connection. Check your network and try again.';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Try again in a moment.';

  @override
  String get errorServerUnreachable =>
      'We couldn\'t reach the server. Check your network.';

  @override
  String get errorTimeout => 'The operation took too long. Try again.';

  @override
  String get errorNetworkCheckConnection =>
      'Network error: check your connection';

  @override
  String get errorUnexpected => 'An unexpected error occurred';

  @override
  String get errorOfflineQueued => 'You\'re offline. Action saved for later.';

  @override
  String get errorNotAuthenticated => 'Not signed in';

  @override
  String get errorHouseholdNotFound => 'Household not found';

  @override
  String get avatarErrorImageTooLarge =>
      'That image is too large. Try another photo.';

  @override
  String get avatarErrorSessionExpired =>
      'Session expired. Please sign in again.';

  @override
  String get avatarErrorTimeout =>
      'Generation took too long. Try again in a moment.';

  @override
  String get avatarErrorMonthlyLimit =>
      'You already used this month\'s avatar creation. You can create another one next month.';

  @override
  String get avatarErrorPremiumRequired => 'This feature is for Premium users.';

  @override
  String get avatarErrorCreateFailed =>
      'Couldn\'t create the avatar. Try again.';

  @override
  String get avatarErrorInvalidResult =>
      'The generator didn\'t return a valid avatar.';

  @override
  String get avatarErrorDeleteFailed =>
      'Couldn\'t delete the avatar. Try again.';

  @override
  String get avatarErrorSaveFailed => 'Couldn\'t save the generated avatar.';

  @override
  String editTaskDeleteBody(String title) {
    return '\"$title\" will be deleted and this can\'t be undone.';
  }

  @override
  String get notifTaskAssignedTitle => 'New task assigned';

  @override
  String notifTaskAssignedBody(String actor, String task) {
    return '$actor assigned you the task: $task';
  }

  @override
  String get notifTaskCompletedTitle => 'Task completed';

  @override
  String notifTaskCompletedBody(String actor, String task) {
    return '$actor completed: $task';
  }

  @override
  String get notifTaskPendingApprovalTitle => 'Task awaiting approval';

  @override
  String notifTaskPendingApprovalBody(String actor, String task) {
    return '$actor completed \"$task\"';
  }

  @override
  String get notifTaskApprovedTitle => 'Task approved';

  @override
  String notifTaskApprovedBody(String task, int coins) {
    return '\"$task\" was approved. You earned $coins coins.';
  }

  @override
  String get notifTaskRejectedTitle => 'Task not approved';

  @override
  String notifTaskRejectedBody(String task) {
    return 'Your task \"$task\" needs some changes.';
  }

  @override
  String get notifExpenseAddedTitle => 'New transaction';

  @override
  String notifExpenseAddedBody(
      String actor, String kind, String title, String amount) {
    String _temp0 = intl.Intl.selectLogic(
      kind,
      {
        'groceries': 'shopped at',
        'other': 'spent on',
      },
    );
    return '$actor $_temp0 $title ($amount)';
  }

  @override
  String get notifSettlementTitle => 'Debt settled!';

  @override
  String notifSettlementBody(String actor, String amount) {
    return '$actor settled their debt of $amount';
  }

  @override
  String get notifWeeklySummaryTitle => 'Your weekly summary is ready';

  @override
  String get notifWeeklySummaryBody =>
      'See how the household\'s week went: completion, MVP and spending.';

  @override
  String notifPlannedUpcomingTitle(String title) {
    return 'Upcoming payment: $title';
  }

  @override
  String notifPlannedUpcomingBody(String date, String amount) {
    return 'Due $date - $amount';
  }

  @override
  String notifPlannedDueTitle(String title) {
    return 'Due today: $title';
  }

  @override
  String notifPlannedDueBody(String amount) {
    return 'Log it from Finances once you pay it - $amount';
  }

  @override
  String get financeOnlyConfirmTitle => 'Confirm change';

  @override
  String financeOnlyConfirmBody(String action) {
    String _temp0 = intl.Intl.selectLogic(
      action,
      {
        'enable': 'enable',
        'other': 'disable',
      },
    );
    return 'When you $_temp0 \"Finance only\" mode, ALL household members will see only finance features (no tasks, shopping, etc.). This setting applies to the whole household.';
  }

  @override
  String get activityFallbackTitle => 'Activity';

  @override
  String get activitySettlementTitle => 'Balance settled';

  @override
  String get activityTimeNow => 'Now';

  @override
  String activityTimeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String activityTimeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get activityTimeDoneYesterday => 'Done yesterday';

  @override
  String activityTimeDoneDaysAgo(int days) {
    return 'Done $days days ago';
  }

  @override
  String get homeLoadingStart => 'Loading home...';

  @override
  String get homeLoadingHousehold => 'Loading household...';

  @override
  String get homeErrorLoadHousehold => 'We couldn\'t load your household.';

  @override
  String get homeNoHouseholdTitle => 'You don\'t belong to a household yet';

  @override
  String get homeNoHouseholdSubtitle =>
      'Create or join a household to get started.';

  @override
  String get mainIdentityLoadError =>
      'Identity load error. Try closing and reopening the app:';

  @override
  String get notifLoveNoteTitle => '💌 You have a special note';

  @override
  String get notifLoveNoteBody => 'Your partner sent you a love note ❤️';

  @override
  String get contributionTitle => 'How it was split';

  @override
  String get contributionEmpty => 'No tasks completed this week yet.';

  @override
  String get contributionRhythmLabel => 'Household rhythm';

  @override
  String contributionRhythmValue(int weeks, int window) {
    return '$weeks of the last $window weeks';
  }

  @override
  String contributionTasksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'no tasks',
    );
    return '$_temp0';
  }

  @override
  String contributionDemandingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heavy ones',
      one: '1 heavy one',
      zero: 'none of the heavy ones',
    );
    return '$_temp0';
  }

  @override
  String coupleWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get coupleWeekYou => 'You';

  @override
  String coupleWeekSplitSemantics(int mine, String name, int theirs) {
    return 'This week\'s split: you $mine, $name $theirs.';
  }

  @override
  String get coupleWeekReadingBalanced =>
      'Nicely even: you split the week well.';

  @override
  String coupleWeekReadingCategoryPartner(String category, String name) {
    return '$category: $name did almost all of it this week.';
  }

  @override
  String coupleWeekReadingCategoryMe(String category) {
    return '$category: you did almost all of it this week.';
  }

  @override
  String coupleWeekReadingOverallPartner(String name) {
    return '$name did most of the tasks this week.';
  }

  @override
  String get coupleWeekReadingOverallMe =>
      'You did most of the tasks this week.';

  @override
  String get coupleWeekProposeTurns => 'Suggest taking turns';

  @override
  String get coupleWeekOfferHand => 'Offer a hand';

  @override
  String coupleWeekTurnsProposalTitle(String category) {
    return 'Can we take turns with $category?';
  }

  @override
  String coupleWeekOfferProposalTitle(String category) {
    return 'I\'ll take care of $category this week';
  }

  @override
  String get coupleWeekTurnsProposalTitleGeneral =>
      'Can we split this week\'s tasks more evenly?';

  @override
  String get coupleWeekOfferProposalTitleGeneral =>
      'I\'ll pick up more tasks this week';

  @override
  String get coupleWeekSeeTasks => 'See tasks';

  @override
  String coupleWeekRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks left this week',
      one: '1 task left this week',
      zero: 'Nothing left for this week',
    );
    return '$_temp0';
  }

  @override
  String coupleWeekOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String get coupleWeekMoneyTitle => 'Our finances';

  @override
  String get coupleWeekMoneySeeAll => 'See activity';

  @override
  String get coupleWeekMoneyEven => 'You\'re all square.';

  @override
  String coupleWeekMoneyYouOwe(String amount, String name) {
    return 'You owe $name $amount.';
  }

  @override
  String coupleWeekMoneyTheyOwe(String name, String amount) {
    return '$name owes you $amount.';
  }

  @override
  String get coupleWeekMoneyNoExpenses =>
      'No shared expenses logged this month yet.';

  @override
  String coupleWeekMoneySharedTotal(String amount) {
    return 'You\'ve spent $amount together this month.';
  }

  @override
  String coupleSettleCreditorHint(String name) {
    return 'When $name pays you, they mark it and it settles on its own.';
  }

  @override
  String get coupleWeekMoneySettle => 'I paid';

  @override
  String get coupleWeekMoneyError => 'We couldn\'t load this month\'s money.';

  @override
  String get coupleWeekAsksTitle => 'Between you';

  @override
  String get coupleWeekAsksSubtitle =>
      'Ideas, plans and conversations to share.';

  @override
  String get coupleWeekAsksEmpty => 'Nothing pending between you.';

  @override
  String coupleWeekAsksEmptyHint(String action) {
    return 'Start with one of these ideas or tap “$action”.';
  }

  @override
  String get coupleWeekAskToAnswer => 'Your turn';

  @override
  String coupleWeekAskWaiting(String name) {
    return 'Waiting for $name';
  }

  @override
  String coupleWeekAskFrom(String name, String when) {
    return 'From $name · $when';
  }

  @override
  String coupleWeekAskFromYou(String when) {
    return 'Yours · $when';
  }

  @override
  String coupleWeekNoteTitle(String name) {
    return 'A little love for $name';
  }

  @override
  String get coupleWeekNoteBody => 'Leave a note to brighten their day.';

  @override
  String get coupleWeekDuoTitle => 'At home, together';

  @override
  String get coupleWeekMoneySharedLabel => 'Spent together this month';

  @override
  String coupleWeekMoneyYouOweLabel(String name) {
    return 'You owe $name';
  }

  @override
  String coupleWeekMoneyTheyOweLabel(String name) {
    return '$name owes you';
  }

  @override
  String coupleWeekMoneyPaidCaption(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'shared': 'What each of you paid this month',
        'other': 'What each of you put into shared expenses',
      },
    );
    return '$_temp0';
  }

  @override
  String get coupleWeekIdeaDinnerChip => 'Dinner out';

  @override
  String get coupleWeekIdeaDinnerTitle => 'Dinner out this weekend?';

  @override
  String get coupleWeekIdeaMoviesChip => 'Movie night';

  @override
  String get coupleWeekIdeaMoviesTitle => 'Movie night with phones away?';

  @override
  String get coupleWeekIdeaChoresChip => 'Split the cleaning';

  @override
  String get coupleWeekIdeaChoresTitle =>
      'Shall we split this week\'s cleaning?';

  @override
  String coupleProposalPushTitle(String name) {
    return '$name suggested something';
  }

  @override
  String coupleProposalAnsweredPushTitle(String name) {
    return '$name answered your suggestion';
  }

  @override
  String coupleProposalAnsweredPushBody(String answer, String title) {
    return '$answer: $title';
  }

  @override
  String loveNotePushTitle(String name) {
    return '💌 $name left you a note';
  }

  @override
  String get loveNotePushBody => 'Open HomeSync to read it.';

  @override
  String loveNoteEnvelopeFrom(String name) {
    return '$name wrote to you';
  }

  @override
  String get loveNoteEnvelopeSaved => 'Saved at home';

  @override
  String get partnerInviteTitle => 'This is better with two';

  @override
  String get partnerInviteBody =>
      'Once your partner joins, you\'ll see how the week was split, the money between you and what you plan together.';

  @override
  String get partnerInviteCodeLabel => 'Code for your partner';

  @override
  String partnerInviteCodeSemantics(String code) {
    return 'Invite code $code. Tap to copy it.';
  }

  @override
  String get partnerInviteShare => 'Invite on WhatsApp';

  @override
  String get partnerInviteShareOther => 'Share another way';

  @override
  String get partnerInviteCopy => 'Copy code';

  @override
  String get partnerInviteMessageCopied => 'Invite copied: paste it anywhere.';

  @override
  String get partnerInviteHint =>
      'They download HomeSync, tap “I have a code” and enter this one.';

  @override
  String get partnerInviteHomeTitle => 'Your partner hasn\'t joined yet';

  @override
  String get partnerInviteHomeBody =>
      'Send them the code and start sharing chores and expenses.';

  @override
  String get partnerInviteHomeAction => 'Invite';

  @override
  String invitationShareMessage(String intro, String link, String code) {
    return '$intro\n\n1. Get HomeSync: $link\n2. Tap “I have a code” and enter: *$code*';
  }

  @override
  String get setupStartTitle => 'Chores and expenses, shared evenly.';

  @override
  String get setupStartBody =>
      'Split the chores, log who paid for what and see where you stand. No spreadsheets, no arguments.';

  @override
  String get setupStartBulletTasks =>
      'Household chores, visible to both of you';

  @override
  String get setupStartBulletMoney =>
      'Shared expenses and an up-to-date balance';

  @override
  String get setupStartBulletWeek => 'A weekly look at how things were split';

  @override
  String get setupStartCreate => 'Start my household';

  @override
  String get setupStartJoin => 'I have a code';

  @override
  String get setupStartJoinTitle => 'Join a household';

  @override
  String get setupStartJoinBody => 'Enter the 6-character code you were sent.';

  @override
  String get setupStartJoinNameLabel => 'What\'s your name?';

  @override
  String get setupStartJoinCodeLabel => 'Code';

  @override
  String get setupStartJoinButton => 'Join';

  @override
  String get setupStartTime => 'It takes less than a minute.';

  @override
  String get setupHouseholdTitle => 'Tell us about your home';

  @override
  String get setupHouseholdSubtitle => 'We\'ll tailor the app to how you live.';

  @override
  String get setupHouseholdModeLabel => 'Who do you share your home with?';

  @override
  String get setupHouseholdNameLabel => 'Your name';

  @override
  String get setupHouseholdFinanceNote =>
      'You\'ll start splitting expenses 50/50. You can change it anytime in Settings.';

  @override
  String setupFamilyHouseholdNameFor(String name) {
    return '$name\'s family';
  }

  @override
  String setupInviteTitle(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'couple': 'Invite your partner',
        'family': 'Invite your family',
        'friends': 'Invite your housemates',
        'other': 'Invite someone',
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
            'HomeSync works best with two: once they join, you\'ll see chores, money and your weekly check-in together.',
        'family':
            'Once they join, everyone sees what\'s theirs and what\'s shared.',
        'friends': 'Once they join, chores and money stay clear for everyone.',
        'other': 'Share the code so they can join your household.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupInviteCodeLabel => 'Your invite code';

  @override
  String setupInviteHint(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'family':
            'They download HomeSync, tap “I have a code” and enter this one.',
        'friends':
            'They download HomeSync, tap “I have a code” and enter this one.',
        'other':
            'They download HomeSync, tap “I have a code” and enter this one.',
      },
    );
    return '$_temp0';
  }

  @override
  String get setupInviteLater => 'I\'ll do it later';

  @override
  String get setupInviteDone => 'Done, I sent it';

  @override
  String get homeNextStepExpenseTitle => 'Log your first shared expense';

  @override
  String get homeNextStepExpenseBody =>
      'So the app can keep track of who paid what.';

  @override
  String get homeNextStepExpenseAction => 'Add';

  @override
  String get premiumProductsUnavailableTitle => 'We couldn\'t load the plans';

  @override
  String get premiumProductsUnavailableBody =>
      'Check your connection and try again. If you already paid, restore your purchase.';

  @override
  String get premiumRestoreNothing =>
      'We didn\'t find any purchases to restore.';

  @override
  String get premiumRestoreError =>
      'We couldn\'t restore your purchase. Try again.';

  @override
  String coupleWeekReadingEarly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks so far this week: too early to read the split.',
      one: '1 task so far this week: too early to read the split.',
    );
    return '$_temp0';
  }

  @override
  String get homeActivityLoadError => 'We couldn\'t load the activity.';

  @override
  String get expensesSummaryLoadError =>
      'We couldn\'t load this month\'s summary.';

  @override
  String get expensesFeedLoadError => 'We couldn\'t load your transactions.';

  @override
  String get premiumBenefitBudgetsRecap => 'Budgets and monthly recap';

  @override
  String get premiumBenefitBudgetsRecapDesc =>
      'Set limits per category and see each month\'s wrap-up: where the money went and who paid for what.';

  @override
  String get currencyNameArs => 'Argentine peso';

  @override
  String get currencyNameUsd => 'US dollar';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameBrl => 'Brazilian real';

  @override
  String get currencyNameClp => 'Chilean peso';

  @override
  String get currencyNameUyu => 'Uruguayan peso';

  @override
  String get categoryLabelHome => 'Home';

  @override
  String get categoryLabelOther => 'Other';

  @override
  String weeklySummaryTasksDoneBody(int planned, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      planned,
      locale: localeName,
      other: '$done of $planned tasks done.',
      one: '$done of 1 task done.',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryCompletionTitle(int planned, int done, int pct) {
    String _temp0 = intl.Intl.pluralLogic(
      planned,
      locale: localeName,
      other: '$done of $planned tasks · $pct%',
      one: '$done of 1 task · $pct%',
    );
    return '$_temp0';
  }

  @override
  String weeklySummaryVsLastWeek(String delta) {
    return '$delta vs. last week';
  }

  @override
  String weeklySummaryExpensesThisWeek(String amount) {
    return '$amount this week';
  }

  @override
  String weeklySummaryTopCategoryBody(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount across $count expenses.',
      one: '$amount across 1 expense.',
    );
    return '$_temp0';
  }

  @override
  String get coachmarkSkip => 'Skip';

  @override
  String get activityBubbleHouseholdExpense => 'Household expense';

  @override
  String get activityBubbleSettlement => 'Settle-up';

  @override
  String savingsSuggesterCompleteMessage(String amount, String goal) {
    return 'Based on your plan, you have money left over this month: $amount would complete your \"$goal\" goal.';
  }

  @override
  String get expenseSplitErrorNoMembers =>
      'Choose at least one person to split the expense with.';

  @override
  String expenseSplitErrorFixedTotal(String amount) {
    return 'The split amounts need to add up to the total ($amount).';
  }

  @override
  String familyTaskCardMarkedDoneBy(String name) {
    return '$name marked it done';
  }

  @override
  String get familyTaskCardReadyToReview => 'Ready to review';

  @override
  String get familyTaskCardAwaitingApproval => 'Waiting for approval';

  @override
  String get familyTaskCardAwaitingAdult => 'Waiting for an adult to review it';

  @override
  String get familyTaskCardUnassignedOverdue => 'Still needs someone';

  @override
  String get familyTaskCardUnassignedToday => 'Needs someone';

  @override
  String get familyTaskCardMyMissionOverdue => 'Your pending mission';

  @override
  String get familyTaskCardMyMission => 'Your mission';

  @override
  String get familyTaskCardMineOverdue => 'Still on your list';

  @override
  String get familyTaskCardMineToday => 'Your turn today';

  @override
  String get familyTaskCardOtherOverdue => 'Still pending for someone else';

  @override
  String get familyTaskCardOther => 'For another member';

  @override
  String familyTaskCardNamedOverdue(String name) {
    return 'Still pending for $name';
  }

  @override
  String familyTaskCardNamed(String name) {
    return 'For $name';
  }

  @override
  String get familyTaskCardUrgencyReview => 'Review';

  @override
  String get familyTaskCardUrgencyInReview => 'In review';

  @override
  String get familyTaskCardUrgencyOverdue => 'Overdue';

  @override
  String get familyTaskCardUrgencyToday => 'Today';

  @override
  String get familyTaskCardUrgencyUpcoming => 'Upcoming';

  @override
  String familyTaskCardRotation(int count) {
    return 'Rotates among $count';
  }

  @override
  String familyFeedSettled(String name) {
    return '$name settled up';
  }

  @override
  String familyFeedLeftReady(String name) {
    return '$name finished';
  }

  @override
  String familyFeedCompleted(String name) {
    return '$name completed';
  }

  @override
  String familyFeedAddedExpense(String name) {
    return '$name added an expense';
  }

  @override
  String familyFeedDidSomething(String name) {
    return '$name did something at home';
  }

  @override
  String get familyFeedSomeone => 'Someone';

  @override
  String familyFeedWaitingReview(String name) {
    return '$name is waiting for a review of';
  }

  @override
  String get familyFeedTaskNotFound => 'We couldn\'t find that task to review.';

  @override
  String get familyFeedApproveFailed => 'We couldn\'t approve the task.';

  @override
  String get familyFeedApproved => 'Task approved.';

  @override
  String get familyFeedReturnFailed => 'We couldn\'t send the task back.';

  @override
  String get familyFeedReturned => 'The task was sent back to fix.';

  @override
  String get familyFeedReturn => 'Send back';

  @override
  String get familyFeedApprove => 'Approve';

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
      other: 'There are $count more overdue tasks.',
      one: 'There\'s 1 more overdue task.',
    );
    return '$_temp0';
  }

  @override
  String familyFeedRedeemedReward(String name) {
    return '$name redeemed a reward';
  }

  @override
  String get settingsPaletteOrange => 'Orange';

  @override
  String get settingsPaletteDark => 'Dark';

  @override
  String get settingsPaletteIndigo => 'Indigo';

  @override
  String get settingsPaletteRose => 'Rose';

  @override
  String get settingsPaletteEmerald => 'Emerald';

  @override
  String get settingsPaletteViolet => 'Violet';

  @override
  String get settingsPaletteAmber => 'Amber';

  @override
  String get settingsPaletteCyan => 'Cyan';

  @override
  String settingsPaletteLocked(String name) {
    return '$name, requires Premium';
  }

  @override
  String get expensesFormAmountTotalLabel => 'Total amount';

  @override
  String get estimatedIncomeSheetTitle => 'Estimated monthly income';

  @override
  String get estimatedIncomeSheetSubtitle =>
      'Only used to work out your balance. It doesn\'t add any entries.';

  @override
  String get estimatedIncomeSheetAmountEyebrow => 'NET MONTHLY AMOUNT';

  @override
  String get estimatedIncomeSheetPaydayEyebrow => 'PAYDAY';

  @override
  String get estimatedIncomeSheetRemove => 'Remove estimated income';

  @override
  String estimatedIncomeSheetDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String get homeFamilyActivityErrorBody =>
      'We couldn\'t load the household activity.';

  @override
  String get couplePlansTitle => 'A little time for two';

  @override
  String get couplePlansSubtitle => 'Little plans, lovely memories.';

  @override
  String get couplePlansComplete => 'We did it';

  @override
  String get couplePlansSave => 'Save';

  @override
  String get couplePlansSaved => 'Saved';

  @override
  String get couplePlansNext => 'Another idea';

  @override
  String get couplePlansAlbum => 'Our album';

  @override
  String get couplePlansAlbumHint =>
      'A memory with every plan. At your own pace.';

  @override
  String get couplePlansSavedTitle => 'Saved plans';

  @override
  String get couplePlansSavedEmpty =>
      'Save an idea you like and come back when you feel like it.';

  @override
  String get couplePlansUnlocked => 'One more memory!';

  @override
  String get couplePlansUndo => 'Undo';

  @override
  String get couplePlansCompletedLabel => 'Memory collected';

  @override
  String get couplePlansDiscoverLabel => 'Still to discover';

  @override
  String get couplePlansError => 'We couldn’t load your plans. Try again.';

  @override
  String couplePlansCount(int count, int total) {
    return '$count of $total';
  }

  @override
  String get couplePlanMoviesTitle => 'Movie night at home';

  @override
  String get couplePlanMoviesBody =>
      'Pick a movie and make a snack to share. The best seat is next to each other.';

  @override
  String get couplePlanMoviesDetails => 'At home · About 2 hours';

  @override
  String get couplePlanMoviesStamp => 'Movie night';

  @override
  String get couplePlanCookingTitle => 'A little cooking duo';

  @override
  String get couplePlanCookingBody =>
      'Try a recipe together with what you have at home. It doesn’t have to turn out perfect.';

  @override
  String get couplePlanCookingDetails => 'At home · About 45 minutes';

  @override
  String get couplePlanCookingStamp => 'Made together';

  @override
  String get couplePlanPicnicTitle => 'A little picnic';

  @override
  String get couplePlanPicnicBody =>
      'A blanket and a snack are all you need. Try a park, your balcony, or the living room.';

  @override
  String get couplePlanPicnicDetails => 'Anywhere · About an hour';

  @override
  String get couplePlanPicnicStamp => 'A cozy picnic';

  @override
  String get couplePlanCoffeeTitle => 'Two cups and a pause';

  @override
  String get couplePlanCoffeeBody =>
      'Coffee, tea, or your favorite drink: make a little time to be together, with no rush.';

  @override
  String get couplePlanCoffeeDetails => 'At home · About 20 minutes';

  @override
  String get couplePlanCoffeeStamp => 'Our little break';

  @override
  String get couplePlanWalkTitle => 'A different little route';

  @override
  String get couplePlanWalkBody =>
      'Take a different route and find a new favorite spot. Go as far as you feel like going.';

  @override
  String get couplePlanWalkDetails => 'Outdoors · About 30 minutes';

  @override
  String get couplePlanWalkStamp => 'New paths';
}
