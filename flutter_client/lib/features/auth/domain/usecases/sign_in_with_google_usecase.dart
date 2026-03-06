import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

import 'package:homesync_client/core/services/logger_service.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<Either<Failure, bool>> execute() async {
    log.i('SignInWithGoogleUseCase: Iniciando ejecución...');
    final result = await _repository.signInWithGoogle();
    log.i('SignInWithGoogleUseCase: Ejecución finalizada.');
    return result;
  }
}
