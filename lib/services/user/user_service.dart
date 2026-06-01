import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_rent/models/user_model.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<UserModel> getUser(String uid) async {
    final adminDoc = await _firestore.collection('admin').doc(uid).get();

    if (adminDoc.exists && adminDoc.data() != null) {
      final data = Map<String, dynamic>.from(adminDoc.data()!);
      data['role'] = 'admin';
      return UserModel.fromMap(data, uid);
    }

    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      throw Exception('Usuario no encontrado: $uid');
    }

    final data = Map<String, dynamic>.from(userDoc.data()!);
    data['role'] = data['role'] ?? 'customer';

    return UserModel.fromMap(data, uid);
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String surname,
  }) async {
    final profileRef = await _profileDocumentRef(uid);

    return profileRef.update({
      'name': name,
      'surname': surname,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNauticalLicense({
    required String uid,
    required String type,
    required String documentUrl,
    required String status,
  }) {
    return _firestore.collection('users').doc(uid).update({
      'nautical_license.type': type,
      'nautical_license.document_url': documentUrl,
      'nautical_license.status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> _profileDocumentRef(
    String uid,
  ) async {
    final adminRef = _firestore.collection('admin').doc(uid);
    final adminDoc = await adminRef.get();

    if (adminDoc.exists) {
      return adminRef;
    }

    return _firestore.collection('users').doc(uid);
  }
}
