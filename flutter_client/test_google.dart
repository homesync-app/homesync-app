import 'package:google_sign_in/google_sign_in.dart';
void main() {
  try {
    print('Checking GoogleSignIn fields...');
    // Verificamos si existe .instance
    // Verificamos si existe .authenticate()
    final g = GoogleSignIn();
    print('Instance created: $g');
  } catch (e) {
    print('Error: $e');
  }
}
