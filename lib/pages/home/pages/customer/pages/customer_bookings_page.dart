import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/booking_model.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/providers/boat_providers.dart';
import 'package:ocean_rent/providers/booking_providers.dart';

class CustomerBookingsPage extends ConsumerWidget {
  const CustomerBookingsPage({super.key});

  Future<void> _cancelBooking(
    BuildContext context,
    WidgetRef ref,
    BookingModel booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadiusCard,
        ),
        title: Text('Cancelar reserva', style: AppTheme.titleMedium),
        content: Text(
          '¿Seguro que quieres cancelar esta reserva?',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cancelar reserva',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.alertRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref
        .read(bookingNotifierProvider)
        .cancelBooking(booking.id);

    if (!context.mounted) return;

    final message = success
        ? 'Reserva cancelada correctamente.'
        : ref.read(bookingNotifierProvider).errorMessage ??
              'No se pudo cancelar la reserva.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).currentUser;

    if (user == null) {
      return Center(
        child: Padding(
          padding: AppTheme.screenPadding,
          child: Text(
            'Inicia sesión para ver tus reservas.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final bookingsAsync = ref.watch(userBookingsStreamProvider(user.uid));
    final boatsAsync = ref.watch(boatsStreamProvider);

    final boatNames = boatsAsync.maybeWhen(
      data: (boats) => {for (final boat in boats) boat.id: boat.name},
      orElse: () => <String, String>{},
    );

    return bookingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.oceanBlue),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: AppTheme.screenPadding,
          child: Text(
            'Error cargando tus reservas:\n$error',
            textAlign: TextAlign.center,
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.alertRed),
          ),
        ),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Padding(
              padding: AppTheme.screenPadding,
              child: Text(
                'Todavía no tienes reservas.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: AppTheme.listPadding,
          itemCount: bookings.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppTheme.spacing12),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final boatName = boatNames[booking.boatId] ?? booking.boatId;

            return _CustomerBookingCard(
              booking: booking,
              boatName: boatName,
              onCancel: booking.status == BookingModel.statusCancelled
                  ? null
                  : () => _cancelBooking(context, ref, booking),
            );
          },
        );
      },
    );
  }
}

class _CustomerBookingCard extends StatelessWidget {
  final BookingModel booking;
  final String boatName;
  final VoidCallback? onCancel;

  const _CustomerBookingCard({
    required this.booking,
    required this.boatName,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);

    return Container(
      padding: AppTheme.compactCardPadding,
      decoration: AppTheme.cardDecoration(
        color: AppTheme.surface,
        border: Border.all(
          color: AppTheme.deepNavy.withValues(alpha: AppTheme.alphaSoft),
        ),
        boxShadow: AppTheme.softShadow(alpha: AppTheme.alphaUltraSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_boat_outlined,
                color: AppTheme.oceanBlue,
                size: AppTheme.iconSizeLarge,
              ),
              const SizedBox(width: AppTheme.spacing10),
              Expanded(
                child: Text(
                  boatName,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.deepNavy,
                  ),
                ),
              ),
              _StatusBadge(status: booking.status, color: statusColor),
            ],
          ),
          const SizedBox(height: AppTheme.spacing14),
          _InfoRow(label: 'Inicio', value: _formatDate(booking.startDate)),
          _InfoRow(label: 'Fin', value: _formatDate(booking.endDate)),
          _InfoRow(label: 'Tripulantes', value: '${booking.crewCount}'),
          _InfoRow(label: 'Estado fianza', value: booking.depositStatus),
          if (onCancel != null) ...[
            const SizedBox(height: AppTheme.spacing14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCancel,
                style: AppTheme.destructiveButtonStyle,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar reserva'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.licenseStatusBadgePadding,
      decoration: AppTheme.badgeDecoration(color: color),
      child: Text(
        status,
        style: AppTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case BookingModel.statusConfirmed:
      return AppTheme.oceanBlue;
    case BookingModel.statusCancelled:
      return AppTheme.alertRed;
    case BookingModel.statusPending:
    default:
      return AppTheme.sunsetGold;
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}
