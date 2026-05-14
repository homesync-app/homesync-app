import 'package:homesync_client/features/rewards/domain/models/reward_model.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

String localizedRewardTitle(AppLocalizations t, RewardModel reward) {
  return localizedRewardTitleByKey(t, reward.titleKey, reward.title);
}

String? localizedRewardDescription(AppLocalizations t, RewardModel reward) {
  final description = localizedRewardDescriptionByKey(
    t,
    reward.descriptionKey,
    reward.description,
  );
  if (description == null || description.trim().isEmpty) return null;
  return description;
}

String localizedRewardCategory(AppLocalizations t, RewardModel reward) {
  return localizedRewardCategoryByKey(t, reward.categoryKey, reward.category);
}

String localizedRewardCategoryByKey(
  AppLocalizations t,
  String? key,
  String? fallback,
) {
  switch (key ?? _categoryKeyForFallback(fallback)) {
    case 'rewardCategoryTreats':
      return t.rewardCategoryTreats;
    case 'rewardCategoryMoments':
      return t.rewardCategoryMoments;
    case 'rewardCategoryPerks':
      return t.rewardCategoryPerks;
    case 'rewardCategoryExperiences':
      return t.rewardCategoryExperiences;
    case 'rewardCategoryFamily':
      return t.rewardCategoryFamily;
    case 'rewardCategoryOther':
      return t.rewardCategoryOther;
  }
  return fallback ?? t.rewardCategoryOther;
}

String localizedRewardTitleByKey(
  AppLocalizations t,
  String? key,
  String fallback,
) {
  switch (key) {
    case 'rewardTemplateCoffeeMatePrepared':
      return t.rewardTemplateCoffeeMatePrepared;
    case 'rewardTemplateSurpriseSnack':
      return t.rewardTemplateSurpriseSnack;
    case 'rewardTemplateMiniRomanticNote':
      return t.rewardTemplateMiniRomanticNote;
    case 'rewardTemplateMassage15Minutes':
      return t.rewardTemplateMassage15Minutes;
    case 'rewardTemplateIceCreamChoice':
      return t.rewardTemplateIceCreamChoice;
    case 'rewardTemplateMovieNightHome':
      return t.rewardTemplateMovieNightHome;
    case 'rewardTemplateGamingAfternoon':
      return t.rewardTemplateGamingAfternoon;
    case 'rewardTemplateBoardGameNight':
      return t.rewardTemplateBoardGameNight;
    case 'rewardTemplateSpecialHomemadeDinner':
      return t.rewardTemplateSpecialHomemadeDinner;
    case 'rewardTemplateHomePicnic':
      return t.rewardTemplateHomePicnic;
    case 'rewardTemplateNoScreensNight':
      return t.rewardTemplateNoScreensNight;
    case 'rewardTemplateEpisodeMarathonChoice':
      return t.rewardTemplateEpisodeMarathonChoice;
    case 'rewardTemplateNoDishesVoucher':
      return t.rewardTemplateNoDishesVoucher;
    case 'rewardTemplateChooseMovieVoucher':
      return t.rewardTemplateChooseMovieVoucher;
    case 'rewardTemplateChooseSeriesWeekVoucher':
      return t.rewardTemplateChooseSeriesWeekVoucher;
    case 'rewardTemplateWeekendPlanVoucher':
      return t.rewardTemplateWeekendPlanVoucher;
    case 'rewardTemplateSkipOneChoreVoucher':
      return t.rewardTemplateSkipOneChoreVoucher;
    case 'rewardTemplateYesToAnyPlanVoucher':
      return t.rewardTemplateYesToAnyPlanVoucher;
    case 'rewardTemplateDinnerOut':
      return t.rewardTemplateDinnerOut;
    case 'rewardTemplatePlannedDate':
      return t.rewardTemplatePlannedDate;
    case 'rewardTemplateChoreFreeDay':
      return t.rewardTemplateChoreFreeDay;
    case 'rewardTemplateExtraScreen15Minutes':
      return t.rewardTemplateExtraScreen15Minutes;
    case 'rewardTemplateChooseDinner':
      return t.rewardTemplateChooseDinner;
    case 'rewardTemplateIceCreamForEveryone':
      return t.rewardTemplateIceCreamForEveryone;
    case 'rewardTemplateSmallToyPrize':
      return t.rewardTemplateSmallToyPrize;
    case 'rewardTemplateFamilyMovieNight':
      return t.rewardTemplateFamilyMovieNight;
    case 'rewardTemplateOrderTakeout':
      return t.rewardTemplateOrderTakeout;
    case 'rewardTemplateWeekendFamilyPlan':
      return t.rewardTemplateWeekendFamilyPlan;
    case 'rewardTemplateSpecialDessert':
      return t.rewardTemplateSpecialDessert;
  }
  return fallback;
}

String? localizedRewardDescriptionByKey(
  AppLocalizations t,
  String? key,
  String? fallback,
) {
  switch (key) {
    case 'rewardTemplateCoffeeMatePreparedDescription':
      return t.rewardTemplateCoffeeMatePreparedDescription;
    case 'rewardTemplateSurpriseSnackDescription':
      return t.rewardTemplateSurpriseSnackDescription;
    case 'rewardTemplateMiniRomanticNoteDescription':
      return t.rewardTemplateMiniRomanticNoteDescription;
    case 'rewardTemplateMassage15MinutesDescription':
      return t.rewardTemplateMassage15MinutesDescription;
    case 'rewardTemplateIceCreamChoiceDescription':
      return t.rewardTemplateIceCreamChoiceDescription;
    case 'rewardTemplateMovieNightHomeDescription':
      return t.rewardTemplateMovieNightHomeDescription;
    case 'rewardTemplateGamingAfternoonDescription':
      return t.rewardTemplateGamingAfternoonDescription;
    case 'rewardTemplateBoardGameNightDescription':
      return t.rewardTemplateBoardGameNightDescription;
    case 'rewardTemplateSpecialHomemadeDinnerDescription':
      return t.rewardTemplateSpecialHomemadeDinnerDescription;
    case 'rewardTemplateHomePicnicDescription':
      return t.rewardTemplateHomePicnicDescription;
    case 'rewardTemplateNoScreensNightDescription':
      return t.rewardTemplateNoScreensNightDescription;
    case 'rewardTemplateEpisodeMarathonChoiceDescription':
      return t.rewardTemplateEpisodeMarathonChoiceDescription;
    case 'rewardTemplateNoDishesVoucherDescription':
      return t.rewardTemplateNoDishesVoucherDescription;
    case 'rewardTemplateChooseMovieVoucherDescription':
      return t.rewardTemplateChooseMovieVoucherDescription;
    case 'rewardTemplateChooseSeriesWeekVoucherDescription':
      return t.rewardTemplateChooseSeriesWeekVoucherDescription;
    case 'rewardTemplateWeekendPlanVoucherDescription':
      return t.rewardTemplateWeekendPlanVoucherDescription;
    case 'rewardTemplateSkipOneChoreVoucherDescription':
      return t.rewardTemplateSkipOneChoreVoucherDescription;
    case 'rewardTemplateYesToAnyPlanVoucherDescription':
      return t.rewardTemplateYesToAnyPlanVoucherDescription;
    case 'rewardTemplateDinnerOutDescription':
      return t.rewardTemplateDinnerOutDescription;
    case 'rewardTemplatePlannedDateDescription':
      return t.rewardTemplatePlannedDateDescription;
    case 'rewardTemplateChoreFreeDayDescription':
      return t.rewardTemplateChoreFreeDayDescription;
    case 'rewardTemplateExtraScreen15MinutesDescription':
      return t.rewardTemplateExtraScreen15MinutesDescription;
    case 'rewardTemplateChooseDinnerDescription':
      return t.rewardTemplateChooseDinnerDescription;
    case 'rewardTemplateIceCreamForEveryoneDescription':
      return t.rewardTemplateIceCreamForEveryoneDescription;
    case 'rewardTemplateSmallToyPrizeDescription':
      return t.rewardTemplateSmallToyPrizeDescription;
    case 'rewardTemplateFamilyMovieNightDescription':
      return t.rewardTemplateFamilyMovieNightDescription;
    case 'rewardTemplateOrderTakeoutDescription':
      return t.rewardTemplateOrderTakeoutDescription;
    case 'rewardTemplateWeekendFamilyPlanDescription':
      return t.rewardTemplateWeekendFamilyPlanDescription;
    case 'rewardTemplateSpecialDessertDescription':
      return t.rewardTemplateSpecialDessertDescription;
  }
  return fallback;
}

String? _categoryKeyForFallback(String? category) {
  final normalized = category?.trim().toLowerCase();
  switch (normalized) {
    case 'mimos':
      return 'rewardCategoryTreats';
    case 'momentos':
    case 'momentos juntos':
      return 'rewardCategoryMoments';
    case 'libertades':
      return 'rewardCategoryPerks';
    case 'experiencias':
    case 'experiencias mas grandes':
    case 'experiencias más grandes':
      return 'rewardCategoryExperiences';
    case 'familia':
      return 'rewardCategoryFamily';
    case 'otros':
      return 'rewardCategoryOther';
  }
  return null;
}
