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
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList();

          reviews.sort((a, b) {
            final firstDate =
                a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final secondDate =
                b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return secondDate.compareTo(firstDate);
          });

          return reviews;
        });
  }

  Future<void> createReview(ReviewModel review) async {
    final reviewRef = _reviewsCollection.doc(review.bookingId);
    final bookingRef = _firestore.collection('bookings').doc(review.bookingId);

    await _firestore.runTransaction((transaction) async {
      final reviewSnapshot = await transaction.get(reviewRef);

      if (reviewSnapshot.exists) {
        throw Exception('Ya existe una resena para esta reserva.');
      }

      final bookingSnapshot = await transaction.get(bookingRef);
      final bookingData = bookingSnapshot.data();

      if (bookingData == null ||
          bookingData['user_id'] != review.userId ||
          bookingData['boat_id'] != review.boatId ||
          bookingData['status'] != 'confirmada') {
        throw Exception('La reserva no permite crear una resena.');
      }

      transaction.set(reviewRef, {
        ...review.copyWith(id: review.bookingId).toMap(),
        'id': reviewRef.id,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<ReviewModel?> watchReviewByBooking(String bookingId) {
    return _reviewsCollection
        .where('booking_id', isEqualTo: bookingId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          return ReviewModel.fromFirestore(snapshot.docs.first);
        });
  }

  Stream<List<ReviewModel>> watchAllReviews() {
    return _reviewsCollection.snapshots().map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      reviews.sort((a, b) {
        final firstDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return secondDate.compareTo(firstDate);
      });

      return reviews;
    });
  }
// Prueba
  Future<void> updateAdminReply({
    required String reviewId,
    required String adminReply,
  }) async {
    if (reviewId.trim().isEmpty) {
      throw Exception('No se pudo identificar la resena.');
    }

    if (adminReply.trim().isEmpty) {
      throw Exception('La respuesta no puede estar vacia.');
    }

    await _reviewsCollection.doc(reviewId).update({
      'admin_reply': adminReply.trim(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
