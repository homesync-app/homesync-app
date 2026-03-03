import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<void> execute({required String email, required String password}) async {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
