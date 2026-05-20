import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String boatId;
  final String bookingId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.boatId,
    required this.bookingId,
    required this.userId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      id: doc.id,
      boatId: data['boat_id'] ?? '',
      bookingId: data['booking_id'] ?? '',
      userId: data['user_id'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: _nullableDateFromTimestamp(data['created_at']),
      updatedAt: _nullableDateFromTimestamp(data['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'boat_id': boatId,
      'booking_id': bookingId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? boatId,
    String? bookingId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      boatId: boatId ?? this.boatId,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _nullableDateFromTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}