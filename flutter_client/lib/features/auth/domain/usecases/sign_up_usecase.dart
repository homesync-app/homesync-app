import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return _repository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
