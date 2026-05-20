import 'package:ocean_rent/models/review_model.dart';
import 'package:ocean_rent/services/review/review_service.dart';

class ReviewRepository {
  ReviewRepository(this._reviewService);

  final ReviewService _reviewService;

  Stream<List<ReviewModel>> watchReviewsByBoat(String boatId) {
    return _reviewService.getReviewsByBoat(boatId);
  }

  Future<void> createReview(ReviewModel review) {
    return _reviewService.createReview(review);
  }
}