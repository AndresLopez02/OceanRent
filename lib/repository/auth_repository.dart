import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_rent/services/firebase_auth_service.dart';

class AuthRepository {
  AuthRepository(this._firebaseAuthService);

  final FirebaseAuthService _firebaseAuthService;

  Stream<User?> get authStateChanges => _firebaseAuthService.authStateChanges;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuthService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() {
    return _firebaseAuthService.signInWithGoogle();
  }

  Future<void> signOut() {
    return _firebaseAuthService.signOut();
  }
}
