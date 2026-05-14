import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';

class CustomerBoatReviewsPage extends StatefulWidget {
  final BoatModel boat;

  const CustomerBoatReviewsPage({super.key, required this.boat});

  @override
  State<CustomerBoatReviewsPage> createState() =>
      _CustomerBoatReviewsPageState();
}

class _CustomerBoatReviewsPageState extends State<CustomerBoatReviewsPage> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  final List<_ReviewItem> _reviews = [
    _ReviewItem(
      userName: 'María G.',
      rating: 5,
      comment: 'Barco muy cómodo y experiencia muy recomendable.',
    ),
    _ReviewItem(
      userName: 'Carlos R.',
      rating: 5,
      comment: 'Todo correcto, buena comunicación y embarcación en buen estado.',
    ),
    _ReviewItem(
      userName: 'Laura M.',
      rating: 4,
      comment: 'Buena experiencia general. Repetiría otro día.',
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendReview() {
    final comment = _commentController.text.trim();

    if (_selectedRating == 0 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una valoración y escribe un comentario.'),
        ),
      );
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        _ReviewItem(
          userName: 'Tú',
          rating: _selectedRating,
          comment: comment,
        ),
      );
      _selectedRating = 0;
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reseña enviada correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas de ${widget.boat.name}'),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewSummaryCard(reviews: _reviews),
            const SizedBox(height: AppTheme.spacing20),
            _ReviewFormCard(
              selectedRating: _selectedRating,
              commentController: _commentController,
              onRatingSelected: (rating) {
                setState(() {
                  _selectedRating = rating;
                });
              },
              onSendReview: _sendReview,
            ),
            const SizedBox(height: AppTheme.spacing20),
            Text(
              'Todas las reseñas',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            ..._reviews.map((review) => _ReviewCard(review: review)),
          ],
        ),
      ),
    );
  }
}

class _ReviewSummaryCard extends StatelessWidget {
  final List<_ReviewItem> reviews;

  const _ReviewSummaryCard({required this.reviews});

  double get averageRating {
    if (reviews.isEmpty) return 0;

    final total = reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.compactCardPadding,
      decoration: AppTheme.simpleCardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: AppTheme.sunsetGold,
            size: AppTheme.iconSizeLarge,
          ),
          const SizedBox(width: AppTheme.spacing10),
          Text(
            '${averageRating.toStringAsFixed(1)} · ${reviews.length} reseñas',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewFormCard extends StatelessWidget {
  final int selectedRating;
  final TextEditingController commentController;
  final ValueChanged<int> onRatingSelected;
  final VoidCallback onSendReview;

  const _ReviewFormCard({
    required this.selectedRating,
    required this.commentController,
    required this.onRatingSelected,
    required this.onSendReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.compactCardPadding,
      decoration: AppTheme.simpleCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escribir reseña',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacing10),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;

              return IconButton(
                onPressed: () => onRatingSelected(rating),
                icon: Icon(
                  rating <= selectedRating ? Icons.star : Icons.star_border,
                  color: AppTheme.sunsetGold,
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.spacing10),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comentario',
              hintText: 'Cuenta cómo ha sido tu experiencia...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSendReview,
              style: AppTheme.accentButtonStyle,
              child: Text(
                'Enviar reseña',
                style: AppTheme.buttonTextStyle.copyWith(
                  color: AppTheme.pearlWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _ReviewItem review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: AppTheme.compactCardPadding,
      decoration: AppTheme.simpleCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.userName,
            style: AppTheme.titleSmall.copyWith(
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: AppTheme.spacing6),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: AppTheme.sunsetGold,
                size: AppTheme.iconSizeSmall,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            review.comment,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textMuted,
              height: AppTheme.lineHeightInfo,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String userName;
  final int rating;
  final String comment;

  const _ReviewItem({
    required this.userName,
    required this.rating,
    required this.comment,
  });
}