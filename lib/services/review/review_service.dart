import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_rent/models/review_model.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  Stream<List<ReviewModel>> getReviewsByBoat(String boatId) {
    return _reviewsCollection
        .where('boat_id', isEqualTo: boatId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> createReview(ReviewModel review) async {
    final existingReview = await _reviewsCollection
        .where('booking_id', isEqualTo: review.bookingId)
        .where('user_id', isEqualTo: review.userId)
        .limit(1)
        .get();

    if (existingReview.docs.isNotEmpty) {
      throw Exception('Ya existe una reseña para esta reserva.');
    }

    await _reviewsCollection.add(review.toMap());
  }
}