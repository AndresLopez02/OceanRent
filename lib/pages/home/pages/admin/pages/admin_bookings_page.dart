import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/booking_model.dart';
import 'package:ocean_rent/providers/boat_providers.dart';
import 'package:ocean_rent/providers/booking_providers.dart';

class AdminBookingsPage extends ConsumerWidget {
  const AdminBookingsPage({super.key});

  Future<void> _confirmBooking(
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
        title: Text('Confirmar reserva', style: AppTheme.titleMedium),
        content: Text(
          '¿Quieres confirmar esta reserva?',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref
        .read(bookingNotifierProvider)
        .confirmBooking(booking.id);

    if (!context.mounted) return;

    final message = success
        ? 'Reserva confirmada correctamente.'
        : ref.read(bookingNotifierProvider).errorMessage ??
              'No se pudo confirmar la reserva.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
    final bookingsAsync = ref.watch(bookingsStreamProvider);
    final boatsAsync = ref.watch(boatsStreamProvider);

    final boatNames = boatsAsync.maybeWhen(
      data: (boats) => {for (final boat in boats) boat.id: boat.name},
      orElse: () => <String, String>{},
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Reservas')),
      body: bookingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.oceanBlue),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: AppTheme.screenPadding,
            child: Text(
              'Error cargando reservas:\n$error',
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
                  'Todavía no hay reservas registradas.',
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

              return _AdminBookingCard(
                booking: booking,
                boatName: boatName,
                onConfirm: booking.status == BookingModel.statusPending
                    ? () => _confirmBooking(context, ref, booking)
                    : null,
                onCancel: booking.status == BookingModel.statusCancelled
                    ? null
                    : () => _cancelBooking(context, ref, booking),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  final BookingModel booking;
  final String boatName;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _AdminBookingCard({
    required this.booking,
    required this.boatName,
    required this.onConfirm,
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
                Icons.event_available_outlined,
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
          _InfoRow(
            label: 'Fianza',
            value: '${booking.depositAmount.toStringAsFixed(2)} €',
          ),
          _InfoRow(label: 'Estado fianza', value: booking.depositStatus),
          const SizedBox(height: AppTheme.spacing14),
          Row(
            children: [
              if (onConfirm != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    style: AppTheme.accentButtonStyle,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar'),
                  ),
                ),
              if (onConfirm != null && onCancel != null)
                const SizedBox(width: AppTheme.spacing10),
              if (onCancel != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCancel,
                    style: AppTheme.destructiveButtonStyle,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                  ),
                ),
            ],
          ),
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
