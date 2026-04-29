import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_rent/models/rental_request.dart';

class RentalRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // guarda una solicitud de alquiler en la colección rental_requests.
  Future<void> createRentalRequest(RentalRequest request) async {
    await _firestore
        .collection('rental_requests')
        .add(request.toMap());
  }
}
  
