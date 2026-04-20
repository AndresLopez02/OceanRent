import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return false;
    }

    final data = doc.data();
    if (data == null) {
      return false;
    }

    final role = data['role']?.toString().trim().toLowerCase();
    return role == 'admin';
  }
}
