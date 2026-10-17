import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';
import '../models/booking_status.dart';

import 'package:firebase_auth/firebase_auth.dart';

class BookingFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to book a driver.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('drunkDriveBookings');

  Future<String> createBooking(Map<String, dynamic> bookingData) async {
    final document = _bookings.doc();

    await document.set({
      ...bookingData,
      'passengerId': currentUserId,
      'driverId': null,
      'status': 'searchingDriver',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    final snapshot = await _bookings
        .where('passengerId', isEqualTo: currentUserId)
        .get();

    final bookings = snapshot.docs.map((doc) {
      return {...doc.data(), 'id': doc.id};
    }).toList();

    bookings.sort((a, b) {
      final aDate = a['createdAt'] as Timestamp?;
      final bDate = b['createdAt'] as Timestamp?;

      if (aDate == null || bDate == null) return 0;

      return bDate.compareTo(aDate);
    });

    return bookings;
  }

  Future<String> createBookingModel(BookingModel booking) async {
    if (booking.passengerId != currentUserId) {
      throw StateError('You can only create your own bookings.');
    }

    if (booking.vehicle.ownerId != currentUserId) {
      throw StateError('You can only book using your own vehicle.');
    }

    final document = _bookings.doc();

    await document.set({
      ...booking.toMap(),
      'passengerId': currentUserId,
      'driverId': null,
      'tripPin': null,
      'status': 'searchingDriver',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<List<BookingModel>> getMyBookingModels() async {
    final snapshot = await _bookings
        .where('passengerId', isEqualTo: currentUserId)
        .get();

    final bookings = snapshot.docs.map((doc) {
      return BookingModel.fromMap(doc.id, doc.data());
    }).toList();

    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return bookings;
  }

  Stream<List<BookingModel>> watchMyBookingModels() {
    return _bookings
        .where('passengerId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
              .toList();

          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return bookings;
        });
  }

  Stream<BookingModel?> watchBooking(String bookingId) {
    return _bookings.doc(bookingId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null) return null;

      if (data['passengerId'] != currentUserId) {
        throw StateError('You do not have access to this booking.');
      }

      return BookingModel.fromMap(snapshot.id, data);
    });
  }

  Future<BookingModel?> cancelBookingByPassenger(String bookingId) async {
    final bookingRef = _bookings.doc(bookingId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null || data['passengerId'] != currentUserId) {
        return null;
      }

      final booking = BookingModel.fromMap(snapshot.id, data);

      const cancellableStatuses = {
        BookingStatus.requested,
        BookingStatus.searchingDriver,
        BookingStatus.driverAssigned,
        BookingStatus.driverAccepted,
        BookingStatus.driverArriving,
        BookingStatus.driverArrived,
        BookingStatus.verification,
      };

      if (!cancellableStatuses.contains(booking.status)) {
        return null;
      }

      transaction.update(bookingRef, {
        'status': BookingStatus.cancelledByUser.name,
      });

      return BookingModel.fromMap(snapshot.id, {
        ...data,
        'status': BookingStatus.cancelledByUser.name,
      });
    });
  }

  Future<BookingModel?> retryDriverSearch(String bookingId) async {
    final bookingRef = _bookings.doc(bookingId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null || data['passengerId'] != currentUserId) {
        return null;
      }

      final booking = BookingModel.fromMap(snapshot.id, data);

      if (booking.status != BookingStatus.driverNotFound) {
        return null;
      }

      transaction.update(bookingRef, {
        'status': BookingStatus.searchingDriver.name,
        'driverId': null,
      });

      return BookingModel.fromMap(snapshot.id, {
        ...data,
        'status': BookingStatus.searchingDriver.name,
        'driverId': null,
      });
    });
  }

  Future<BookingModel?> markDriverNotFound(String bookingId) async {
    final bookingRef = _bookings.doc(bookingId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null || data['passengerId'] != currentUserId) {
        return null;
      }

      final booking = BookingModel.fromMap(snapshot.id, data);

      if (booking.status != BookingStatus.searchingDriver ||
          booking.driverId != null) {
        return null;
      }

      transaction.update(bookingRef, {
        'status': BookingStatus.driverNotFound.name,
      });

      return BookingModel.fromMap(snapshot.id, {
        ...data,
        'status': BookingStatus.driverNotFound.name,
      });
    });
  }
}
