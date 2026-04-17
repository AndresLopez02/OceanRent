import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/repository/auth_repository.dart';
import 'package:ocean_rent/services/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return AuthRepository(authService);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final authNotifierProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthProvider(repository);
});

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e);
      return false;
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error inesperado al iniciar sesión.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e);
      return false;
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error inesperado al registrarte.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.signOut();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e);
    } catch (_) {
      _errorMessage = 'No se pudo cerrar la sesión.';
    } finally {
      _setLoading(false);
    }
  }

  //Iniciar sesion con Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.signInWithGoogle();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e);
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo iniciar sesión con Google.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese correo usando otro método de acceso.';
      default:
        return e.message ?? 'Ha ocurrido un error con Firebase Auth.';
    }
  }
}
