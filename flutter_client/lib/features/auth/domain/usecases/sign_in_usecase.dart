import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Either<Failure, void>> execute(
      {required String email, required String password}) async {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
