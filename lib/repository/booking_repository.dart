import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_rent/models/booking_model.dart';

class BookingRepository {
  BookingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const List<String> _activeBookingStatuses = [
    BookingModel.statusPending,
    BookingModel.statusConfirmed,
  ];

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _maintenanceBlocksCollection =>
      _firestore.collection('maintenance_blocks');

  CollectionReference<Map<String, dynamic>> get _bookingDateLocksCollection =>
      _firestore.collection('booking_date_locks');

  Stream<List<BookingModel>> watchBookings() {
    return _bookingsCollection.snapshots().map(_mapBookingSnapshot);
  }

  Stream<List<BookingModel>> watchBookingsByUser(String userId) {
    return _bookingsCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map(_mapBookingSnapshot);
  }

  List<BookingModel> _mapBookingSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final bookings = snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList();

    bookings.sort((a, b) {
      final firstDate = a.createdAt ?? a.startDate;
      final secondDate = b.createdAt ?? b.startDate;

      return secondDate.compareTo(firstDate);
    });

    return bookings;
  }

  Future<BookingModel> createBooking({
    required String boatId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required int crewCount,
    required double depositAmount,
  }) async {
    final normalizedStartDate = _startOfDay(startDate);
    final normalizedEndDate = _startOfDay(endDate);

    if (normalizedEndDate.isBefore(normalizedStartDate)) {
      throw Exception('La fecha final no puede ser anterior a la inicial.');
    }

    if (crewCount <= 0) {
      throw Exception('El número de tripulantes debe ser mayor que 0.');
    }

    final hasBookingOverlap = await _hasActiveBookingOverlap(
      boatId: boatId,
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
    );

    if (hasBookingOverlap) {
      throw Exception('El barco ya tiene una reserva en ese rango de fechas.');
    }

    final hasMaintenanceOverlap = await _hasMaintenanceOverlap(
      boatId: boatId,
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
    );

    if (hasMaintenanceOverlap) {
      throw Exception(
        'El barco no está disponible por mantenimiento en ese rango de fechas.',
      );
    }

    final bookingRef = _bookingsCollection.doc();
    final selectedDates = _datesInRange(normalizedStartDate, normalizedEndDate);

    return _firestore.runTransaction<BookingModel>((transaction) async {
      final lockRefs = selectedDates
          .map((date) => _bookingDateLocksCollection.doc(_lockId(boatId, date)))
          .toList();

      final lockSnapshots = await Future.wait(lockRefs.map(transaction.get));

      final hasLockedDate = lockSnapshots.any((snapshot) => snapshot.exists);

      if (hasLockedDate) {
        throw Exception(
          'El barco acaba de ser reservado en alguna de las fechas seleccionadas.',
        );
      }

      final booking = BookingModel(
        id: bookingRef.id,
        boatId: boatId,
        userId: userId,
        startDate: normalizedStartDate,
        endDate: normalizedEndDate,
        crewCount: crewCount,
        status: BookingModel.statusPending,
        depositAmount: depositAmount,
        depositPaymentIntentId: '',
        depositStatus: BookingModel.depositStatusHeld,
        rentalPaymentIntentId: '',
      );

      transaction.set(bookingRef, {...booking.toMap(), 'id': bookingRef.id});

      for (int i = 0; i < lockRefs.length; i++) {
        transaction.set(lockRefs[i], {
          'booking_id': bookingRef.id,
          'boat_id': boatId,
          'date': Timestamp.fromDate(selectedDates[i]),
          'date_key': _dateKey(selectedDates[i]),
          'status': BookingModel.statusPending,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return booking;
    });
  }

  Future<void> confirmBooking(String bookingId) async {
    final bookingRef = _bookingsCollection.doc(bookingId);

    await _firestore.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists) {
        throw Exception('La reserva no existe.');
      }

      final booking = BookingModel.fromFirestore(bookingSnapshot);

      if (booking.status == BookingModel.statusCancelled) {
        throw Exception('No se puede confirmar una reserva cancelada.');
      }

      final selectedDates = _datesInRange(booking.startDate, booking.endDate);

      transaction.update(bookingRef, {
        'status': BookingModel.statusConfirmed,
        'updated_at': FieldValue.serverTimestamp(),
      });

      for (final date in selectedDates) {
        final lockRef = _bookingDateLocksCollection.doc(
          _lockId(booking.boatId, date),
        );

        transaction.set(lockRef, {
          'booking_id': booking.id,
          'boat_id': booking.boatId,
          'date': Timestamp.fromDate(date),
          'date_key': _dateKey(date),
          'status': BookingModel.statusConfirmed,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    final bookingRef = _bookingsCollection.doc(bookingId);

    await _firestore.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists) {
        throw Exception('La reserva no existe.');
      }

      final booking = BookingModel.fromFirestore(bookingSnapshot);

      if (booking.status == BookingModel.statusCancelled) {
        return;
      }

      final selectedDates = _datesInRange(booking.startDate, booking.endDate);

      transaction.update(bookingRef, {
        'status': BookingModel.statusCancelled,
        'deposit_status': BookingModel.depositStatusReleased,
        'updated_at': FieldValue.serverTimestamp(),
      });

      for (final date in selectedDates) {
        final lockRef = _bookingDateLocksCollection.doc(
          _lockId(booking.boatId, date),
        );

        transaction.delete(lockRef);
      }
    });
  }

  Future<bool> isBoatAvailable({
    required String boatId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStartDate = _startOfDay(startDate);
    final normalizedEndDate = _startOfDay(endDate);

    final hasBookingOverlap = await _hasActiveBookingOverlap(
      boatId: boatId,
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
    );

    if (hasBookingOverlap) {
      return false;
    }

    final hasMaintenanceOverlap = await _hasMaintenanceOverlap(
      boatId: boatId,
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
    );

    return !hasMaintenanceOverlap;
  }

  Future<Set<DateTime>> getUnavailableDates(String boatId) async {
    final unavailableDates = <DateTime>{};

    final bookingSnapshot = await _bookingsCollection
        .where('boat_id', isEqualTo: boatId)
        .get();

    for (final doc in bookingSnapshot.docs) {
      final booking = BookingModel.fromFirestore(doc);

      if (!_activeBookingStatuses.contains(booking.status)) {
        continue;
      }

      unavailableDates.addAll(
        _datesInRange(booking.startDate, booking.endDate),
      );
    }

    final maintenanceSnapshot = await _maintenanceBlocksCollection
        .where('boat_id', isEqualTo: boatId)
        .get();

    for (final doc in maintenanceSnapshot.docs) {
      final data = doc.data();

      final startDate = _dateFromTimestamp(data['start_date']);
      final endDate = _dateFromTimestamp(data['end_date']);

      if (startDate == null || endDate == null) {
        continue;
      }

      unavailableDates.addAll(_datesInRange(startDate, endDate));
    }

    return unavailableDates;
  }

  Future<bool> _hasActiveBookingOverlap({
    required String boatId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _bookingsCollection
        .where('boat_id', isEqualTo: boatId)
        .get();

    for (final doc in snapshot.docs) {
      final booking = BookingModel.fromFirestore(doc);

      if (!_activeBookingStatuses.contains(booking.status)) {
        continue;
      }

      if (_rangesOverlap(
        startA: startDate,
        endA: endDate,
        startB: booking.startDate,
        endB: booking.endDate,
      )) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _hasMaintenanceOverlap({
    required String boatId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _maintenanceBlocksCollection
        .where('boat_id', isEqualTo: boatId)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final maintenanceStartDate = _dateFromTimestamp(data['start_date']);
      final maintenanceEndDate = _dateFromTimestamp(data['end_date']);

      if (maintenanceStartDate == null || maintenanceEndDate == null) {
        continue;
      }

      if (_rangesOverlap(
        startA: startDate,
        endA: endDate,
        startB: maintenanceStartDate,
        endB: maintenanceEndDate,
      )) {
        return true;
      }
    }

    return false;
  }

  bool _rangesOverlap({
    required DateTime startA,
    required DateTime endA,
    required DateTime startB,
    required DateTime endB,
  }) {
    final normalizedStartA = _startOfDay(startA);
    final normalizedEndA = _startOfDay(endA);
    final normalizedStartB = _startOfDay(startB);
    final normalizedEndB = _startOfDay(endB);

    return !normalizedEndA.isBefore(normalizedStartB) &&
        !normalizedStartA.isAfter(normalizedEndB);
  }

  List<DateTime> _datesInRange(DateTime startDate, DateTime endDate) {
    final normalizedStartDate = _startOfDay(startDate);
    final normalizedEndDate = _startOfDay(endDate);

    final totalDays = normalizedEndDate.difference(normalizedStartDate).inDays;

    return List.generate(
      totalDays + 1,
      (index) => normalizedStartDate.add(Duration(days: index)),
    );
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _dateFromTimestamp(dynamic value) {
    if (value is Timestamp) {
      return _startOfDay(value.toDate());
    }

    return null;
  }

  String _lockId(String boatId, DateTime date) {
    return '${boatId}_${_dateKey(date)}';
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year$month$day';
  }
}
