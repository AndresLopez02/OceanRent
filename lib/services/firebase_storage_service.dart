import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? firebaseStorage})
    : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseStorage _firebaseStorage;

  Future<String> uploadBoatImage({
    required String boatId,
    required XFile image,
  }) async {
    final file = File(image.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

    final ref = _firebaseStorage.ref().child('boats/$boatId/$fileName');

    await ref.putFile(file);

    return ref.getDownloadURL();
  }
}