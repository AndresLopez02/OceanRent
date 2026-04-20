import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_rent/models/boat.dart';

class BoatService {
  BoatService._();

  static final BoatService instance = BoatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _boatsCollection =>
      _firestore.collection('boats');

  Stream<List<Boat>> getBoatsStream() {
    return _boatsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Boat.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> createBoat({
    required String name,
    required String type,
    required int capacity,
    required double pricePerDay,
    required String description,
    required String imageUrl,
  }) async {
    final DateTime now = DateTime.now();

    await _boatsCollection.add({
      'name': name.trim(),
      'type': type.trim(),
      'capacity': capacity,
      'pricePerDay': pricePerDay,
      'description': description.trim(),
      'imageUrl': imageUrl.trim(),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> updateBoat({
    required String id,
    required String name,
    required String type,
    required int capacity,
    required double pricePerDay,
    required String description,
    required String imageUrl,
  }) async {
    await _boatsCollection.doc(id).update({
      'name': name.trim(),
      'type': type.trim(),
      'capacity': capacity,
      'pricePerDay': pricePerDay,
      'description': description.trim(),
      'imageUrl': imageUrl.trim(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteBoat(String id) async {
    await _boatsCollection.doc(id).delete();
  }
}
