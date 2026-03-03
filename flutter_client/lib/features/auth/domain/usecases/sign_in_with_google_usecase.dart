import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<bool> execute() async {
    return _repository.signInWithGoogle();
  }
}
