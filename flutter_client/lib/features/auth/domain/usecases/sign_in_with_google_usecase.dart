import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<Either<Failure, bool>> execute() async {
    return _repository.signInWithGoogle();
  }
}
