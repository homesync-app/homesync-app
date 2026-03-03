import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<Either<Failure, void>> execute() async {
    return _repository.signOut();
  }
}
