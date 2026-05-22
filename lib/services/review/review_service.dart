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
    final existingReview = await _reviewsCollection
        .where('booking_id', isEqualTo: review.bookingId)
        .limit(1)
        .get();

    if (existingReview.docs.isNotEmpty) {
      throw Exception('Ya existe una reseña para esta reserva.');
    }

    final reviewRef = _reviewsCollection.doc();
    final boatRef = _firestore.collection('boats').doc(review.boatId);

    await _firestore.runTransaction((transaction) async {
      final boatSnapshot = await transaction.get(boatRef);
      final boatData = boatSnapshot.data() ?? {};

      final currentAvg = (boatData['rating_avg'] ?? 0).toDouble();
      final currentCount = (boatData['rating_count'] ?? 0) as int;

      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + review.rating) / newCount;

      transaction.set(reviewRef, {
        ...review.copyWith(id: reviewRef.id).toMap(),
        'id': reviewRef.id,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      transaction.update(boatRef, {
        'rating_avg': newAvg,
        'rating_count': newCount,
      });
    });
  }

  // Permite escuchar en tiempo real la reseña asociada a una reserva específica.
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

  // Permite escuchar en tiempo real todas las reseñas, ordenadas por fecha de creación (de más reciente a más antigua).
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

  // Permite al administrador actualizar la respuesta a una reseña específica.
  Future<void> updateAdminReply({
    required String reviewId,
    required String adminReply,
  }) async {
    if (reviewId.trim().isEmpty) {
      throw Exception('No se pudo identificar la reseña.');
    }

    if (adminReply.trim().isEmpty) {
      throw Exception('La respuesta no puede estar vacía.');
    }

    await _reviewsCollection.doc(reviewId).update({
      'admin_reply': adminReply.trim(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
