import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_rent/models/user_model.dart';
import 'package:ocean_rent/services/firebase_auth_service.dart';

class AuthRepository {
  AuthRepository(this._firebaseAuthService);

  final FirebaseAuthService _firebaseAuthService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuthService.authStateChanges;

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await _fetchUserModel(credential.user!.uid);
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String surname,
    required DateTime birthDate,
  }) async {
    final credential = await _firebaseAuthService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      email: email,
      name: name,
      surname: surname,
      role: UserRole.customer,
      nauticalLicense: const NauticalLicense(
        type: 'none', 
        documentUrl: '', 
        status: 'Verified'
      )
    );

    await _db.collection('users').doc(user.uid).set(user.toMap());

    return user;
  }

  Future<UserModel> signInWithGoogle() async {
    final credential = await _firebaseAuthService.signInWithGoogle();
    final uid = credential.user!.uid;

    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      final user = UserModel(
        uid: uid,
        email: credential.user!.email ?? '',
        name: credential.user!.displayName ?? '',
        surname: '',
        role: UserRole.customer,
        nauticalLicense: const NauticalLicense(
        type: 'none', 
        documentUrl: '', 
        status: 'Verified'
      )
      );
      await _db.collection('users').doc(uid).set(user.toMap());
      return user;
    }

    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuthService.currentUser;
    if (firebaseUser == null) return null;
    return await _fetchUserModel(firebaseUser.uid);
  }

  Future<void> signOut() => _firebaseAuthService.signOut();

  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Perfil no encontrado en Firestore.');
    return UserModel.fromMap(doc.data()!, uid);
  }
}