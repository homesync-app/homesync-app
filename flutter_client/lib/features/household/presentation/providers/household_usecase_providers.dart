import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/usecases/generate_invitation_code_usecase.dart';
import 'package:homesync_client/features/household/domain/usecases/join_household_usecase.dart';
import 'package:homesync_client/features/household/domain/usecases/update_default_split_ratio_usecase.dart';
import 'package:homesync_client/features/household/domain/usecases/update_finance_settings_usecase.dart';
import 'package:homesync_client/features/household/domain/usecases/update_household_type_usecase.dart';
import 'package:homesync_client/features/household/domain/usecases/update_member_display_role_usecase.dart';

final generateInvitationCodeUseCaseProvider =
    Provider<GenerateInvitationCodeUseCase>((ref) {
  return GenerateInvitationCodeUseCase(ref.read(householdRepositoryProvider));
});

final joinHouseholdUseCaseProvider = Provider<JoinHouseholdUseCase>((ref) {
  return JoinHouseholdUseCase(ref.read(householdRepositoryProvider));
});

final updateDefaultSplitRatioUseCaseProvider =
    Provider<UpdateDefaultSplitRatioUseCase>((ref) {
  return UpdateDefaultSplitRatioUseCase(ref.read(householdRepositoryProvider));
});

final updateFinanceSettingsUseCaseProvider =
    Provider<UpdateFinanceSettingsUseCase>((ref) {
  return UpdateFinanceSettingsUseCase(ref.read(householdRepositoryProvider));
});

final updateHouseholdTypeUseCaseProvider =
    Provider<UpdateHouseholdTypeUseCase>((ref) {
  return UpdateHouseholdTypeUseCase(ref.read(householdRepositoryProvider));
});

final updateMemberDisplayRoleUseCaseProvider =
    Provider<UpdateMemberDisplayRoleUseCase>((ref) {
  return UpdateMemberDisplayRoleUseCase(ref.read(householdRepositoryProvider));
});
