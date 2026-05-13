import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';
import 'package:ocean_rent/pages/home/pages/customer/widgets/license_detail_section.dart';
import 'package:ocean_rent/providers/auth_providers.dart';
import 'package:ocean_rent/providers/booking_providers.dart';
import 'package:ocean_rent/widgets/app_navigator.dart';
import 'package:table_calendar/table_calendar.dart';

// Pantalla de detalle para el cliente.
// Recibe el barco seleccionado desde el listado y muestra su información completa.
class CustomerBoatDetailPage extends ConsumerStatefulWidget {
  final BoatModel boat;

  const CustomerBoatDetailPage({super.key, required this.boat});

  @override
  ConsumerState<CustomerBoatDetailPage> createState() =>
      _CustomerBoatDetailPageState();
}

class _CustomerBoatDetailPageState
    extends ConsumerState<CustomerBoatDetailPage> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();
  int _crewCount = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider).loadUnavailableDates(widget.boat.id);
    });
  }

  Future<void> _handleBooking() async {
    final user = ref.read(authNotifierProvider).currentUser;

    if (user == null) {
      AppNavigator.goToLogin(context);
      return;
    }

    final startDate = _rangeStart;
    final endDate = _rangeEnd ?? _rangeStart;

    if (startDate == null || endDate == null) {
      _showSnackBar('Selecciona una fecha para reservar.');
      return;
    }

    final bookingNotifier = ref.read(bookingNotifierProvider);

    if (_rangeHasUnavailableDates(
      startDate,
      endDate,
      bookingNotifier.unavailableDates,
    )) {
      _showSnackBar('El rango contiene fechas no disponibles.');
      return;
    }

    final success = await bookingNotifier.createBooking(
      boatId: widget.boat.id,
      userId: user.uid,
      startDate: startDate,
      endDate: endDate,
      crewCount: _crewCount,
      depositAmount: widget.boat.depositAmount,
    );

    if (!context.mounted) return;

    if (success) {
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
        _crewCount = 1;
      });

      _showSnackBar('Reserva creada correctamente. Estado: pendiente.');
      return;
    }

    _showSnackBar(
      bookingNotifier.errorMessage ?? 'No se pudo crear la reserva.',
    );
  }

  bool _isUnavailable(DateTime day, Set<DateTime> unavailableDates) {
    final normalizedDay = _startOfDay(day);

    return unavailableDates.any(
      (date) => isSameDay(_startOfDay(date), normalizedDay),
    );
  }

  bool _rangeHasUnavailableDates(
    DateTime start,
    DateTime end,
    Set<DateTime> unavailableDates,
  ) {
    DateTime current = _startOfDay(start);
    final normalizedEnd = _startOfDay(end);

    while (current.isBefore(normalizedEnd) ||
        isSameDay(current, normalizedEnd)) {
      if (_isUnavailable(current, unavailableDates)) {
        return true;
      }

      current = current.add(const Duration(days: 1));
    }

    return false;
  }

  int _selectedDaysCount() {
    final startDate = _rangeStart;
    final endDate = _rangeEnd ?? _rangeStart;

    if (startDate == null || endDate == null) {
      return 0;
    }

    return _startOfDay(endDate).difference(_startOfDay(startDate)).inDays + 1;
  }

  double _totalRentalAmount() {
    return _selectedDaysCount() * widget.boat.pricePerDay;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final boat = widget.boat;
    final bookingState = ref.watch(bookingNotifierProvider);
    final user = ref.watch(authNotifierProvider).currentUser;
    final isAnonymous = user == null;
    final maxCrew = boat.capacity <= 0 ? 1 : boat.capacity;
    final canReserve = _rangeStart != null && !bookingState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(boat.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            boat.imageUrl.isNotEmpty
                ? Image.network(
                    boat.imageUrl,
                    height: AppTheme.detailImageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _DetailImagePlaceholder(),
                  )
                : const _DetailImagePlaceholder(),

            Padding(
              padding: AppTheme.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(boat.name,style: AppTheme.headlineMedium.copyWith(color: AppTheme.deepNavy)
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _BoatDetailInfoItem(
                    icon: Icons.directions_boat_outlined,
                    label: _formatBoatCategory(boat.category),
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _BoatDetailInfoItem(
                    icon: Icons.payments_outlined,
                    label: '${boat.pricePerDay.toStringAsFixed(0)} €/día',
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _BoatDetailInfoItem(
                    icon: Icons.people_outline,
                    label: 'Capacidad: ${boat.capacity} personas',
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _BoatDetailInfoItem(
                    icon: Icons.anchor_outlined,
                    label: boat.portName.isEmpty
                        ? 'Puerto no indicado'
                        : boat.portName,
                  ),
                  if (boat.requiredLicense.toLowerCase() != 'none') ...[
                    const SizedBox(height: AppTheme.spacing16),
                    LicenseDetailSection(license: boat.requiredLicense),
                  ],
                  const SizedBox(height: AppTheme.spacing24),
                  Text('Descripción',style: AppTheme.titleMedium.copyWith(color: AppTheme.deepNavy)
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    boat.description.isEmpty? 'Sin descripción disponible.' : boat.description,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted, height: AppTheme.lineHeightInfo,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  Text('Disponibilidad', style: AppTheme.titleMedium.copyWith(color: AppTheme.deepNavy)
                  ),
                  const SizedBox(height: AppTheme.spacing8),

                  if (bookingState.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.spacing12,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: AppTheme.loadingSize,
                            height: AppTheme.loadingSize,
                            child: CircularProgressIndicator(
                              strokeWidth: AppTheme.progressStrokeWidth,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing10),
                          Text(
                            'Cargando disponibilidad...',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                  TableCalendar(
                    locale: 'es_ES',
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    rangeSelectionMode: RangeSelectionMode.toggledOn,
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    enabledDayPredicate: (day) =>
                        !_isUnavailable(day, bookingState.unavailableDates),
                    onRangeSelected: (start, end, focusedDay) {
                      final selectedEnd = end ?? start;

                      if (start != null &&
                          selectedEnd != null &&
                          _rangeHasUnavailableDates(
                            start,
                            selectedEnd,
                            bookingState.unavailableDates,
                          )) {
                        _showSnackBar(
                          'El rango contiene fechas no disponibles.',
                        );
                        return;
                      }

                      setState(() {
                        _rangeStart = start;
                        _rangeEnd = end;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      disabledBuilder: (context, day, focusedDay) {
                        if (_isUnavailable(
                          day,
                          bookingState.unavailableDates,
                        )) {
                          return Container(
                            margin: const EdgeInsets.all(6),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppTheme.alertRed,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: AppTheme.pearlWhite,
                              ),
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.all(6),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppTheme.backgroundDim,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                    headerStyle: AppTheme.calendarHeaderStyle,
                    daysOfWeekStyle: AppTheme.calendarDaysOfWeekStyle,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppTheme.oceanBlue.withValues(
                          alpha: AppTheme.alphaOverlay,
                        ),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: AppTheme.deepNavy),
                      selectedDecoration: const BoxDecoration(
                        color: AppTheme.oceanBlue,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: AppTheme.pearlWhite,
                      ),
                      disabledDecoration: const BoxDecoration(
                        color: AppTheme.backgroundDim,
                        shape: BoxShape.circle,
                      ),
                      disabledTextStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      rangeStartDecoration: const BoxDecoration(
                        color: AppTheme.oceanBlue,
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: AppTheme.oceanBlue,
                        shape: BoxShape.circle,
                      ),
                      withinRangeDecoration: BoxDecoration(
                        color: AppTheme.sunsetGold.withValues(
                          alpha: AppTheme.alphaMedium,
                        ),
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: const TextStyle(
                        color: AppTheme.deepNavy,
                      ),
                      weekendDecoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: AppTheme.oceanBlue,
                      ),
                      outsideDaysVisible: false,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  _CrewSelector(
                    crewCount: _crewCount,
                    maxCrew: maxCrew,
                    onDecrease: _crewCount <= 1
                        ? null
                        : () {
                            setState(() {
                              _crewCount--;
                            });
                          },
                    onIncrease: _crewCount >= maxCrew
                        ? null
                        : () {
                            setState(() {
                              _crewCount++;
                            });
                          },
                  ),

                  if (_rangeStart != null) ...[
                    const SizedBox(height: AppTheme.spacing16),
                    _BookingSummaryCard(
                      startDate: _formatDate(_rangeStart!),
                      endDate: _formatDate(_rangeEnd ?? _rangeStart!),
                      daysCount: _selectedDaysCount(),
                      rentalAmount: _totalRentalAmount(),
                      depositAmount: boat.depositAmount,
                    ),
                  ],

                  const SizedBox(height: AppTheme.spacing24),

                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton(
                      onPressed: canReserve ? _handleBooking : null,
                      style: AppTheme.accentButtonStyle,
                      child: bookingState.isLoading
                          ? const SizedBox(
                              width: AppTheme.loadingSize,
                              height: AppTheme.loadingSize,
                              child: CircularProgressIndicator(
                                strokeWidth: AppTheme.progressStrokeWidth,
                                color: AppTheme.pearlWhite,
                              ),
                            )
                          : Text(
                              isAnonymous
                                  ? 'Inicia sesión para reservar'
                                  : 'Reservar',
                              style: AppTheme.buttonTextStyle.copyWith(
                                color: AppTheme.pearlWhite,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatBoatCategory(String category) {
  final normalizedCategory = category.trim().toLowerCase();

  switch (normalizedCategory) {
    case 'lancha':
      return 'Lancha';
    case 'semirigida':
      return 'Semirrígida';
    case 'velero':
      return 'Velero';
    case 'yate':
      return 'Yate';
    case 'catamaran':
      return 'Catamarán';
    case 'jetski':
      return 'Jet Ski';
    default:
      return category.trim().isEmpty ? 'Sin categoría' : category.trim();
  }
}

class _BoatDetailInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BoatDetailInfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppTheme.iconSizeLarge, color: AppTheme.oceanBlue),
        const SizedBox(width: AppTheme.spacing8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}

class _CrewSelector extends StatelessWidget {
  final int crewCount;
  final int maxCrew;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const _CrewSelector({
    required this.crewCount,
    required this.maxCrew,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.compactCardPadding,
      decoration: AppTheme.simpleCardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.groups_2_outlined,
            color: AppTheme.oceanBlue,
            size: AppTheme.iconSizeLarge,
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tripulantes',
                  style: AppTheme.titleSmall.copyWith(color: AppTheme.deepNavy),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Máximo permitido: $maxCrew',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.deepNavy,
          ),
          Text(
            '$crewCount',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.deepNavy),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.oceanBlue,
          ),
        ],
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final String startDate;
  final String endDate;
  final int daysCount;
  final double rentalAmount;
  final double depositAmount;

  const _BookingSummaryCard({
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.rentalAmount,
    required this.depositAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.compactCardPadding,
      decoration: AppTheme.infoBannerDecoration(AppTheme.oceanBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de la reserva',
            style: AppTheme.titleSmall.copyWith(color: AppTheme.deepNavy),
          ),
          const SizedBox(height: AppTheme.spacing10),
          _SummaryRow(label: 'Inicio', value: startDate),
          _SummaryRow(label: 'Fin', value: endDate),
          _SummaryRow(label: 'Días', value: '$daysCount'),
          _SummaryRow(
            label: 'Alquiler',
            value: '${rentalAmount.toStringAsFixed(2)} €',
          ),
          _SummaryRow(
            label: 'Fianza',
            value: '${depositAmount.toStringAsFixed(2)} €',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

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

// Placeholder reutilizado cuando no existe imagen o la URL no carga correctamente.
class _DetailImagePlaceholder extends StatelessWidget {
  const _DetailImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.detailImageHeight,
      width: double.infinity,
      color: AppTheme.deepNavy.withValues(alpha: AppTheme.alphaSoft),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_boat_filled_outlined,
            size: AppTheme.detailPlaceholderIconSize,
            color: AppTheme.deepNavy,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Imagen no disponible',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.deepNavy),
          ),
        ],
      ),
    );
  }
}
