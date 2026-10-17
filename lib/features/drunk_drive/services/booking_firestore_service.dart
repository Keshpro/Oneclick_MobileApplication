import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

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

  Stream<List<BookingModel>> watchAvailableRequests() {
    return _bookings
        .where(
          'status',
          whereIn: [
            BookingStatus.requested.name,
            BookingStatus.searchingDriver.name,
          ],
        )
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
              .where(
                (booking) =>
                    booking.driverId == null &&
                    booking.passengerId != currentUserId,
              )
              .toList();

          requests.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return requests;
        });
  }

  Future<BookingModel?> acceptBookingByDriver(String bookingId) async {
    final driverId = currentUserId;
    final bookingRef = _bookings.doc(bookingId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null) return null;

      // A driver cannot accept their own passenger booking.
      if (data['passengerId'] == driverId) return null;

      // Reject bookings that another driver has already accepted.
      if (data['driverId'] != null) return null;

      final booking = BookingModel.fromMap(snapshot.id, data);

      if (booking.status != BookingStatus.requested &&
          booking.status != BookingStatus.searchingDriver) {
        return null;
      }

      transaction.update(bookingRef, {
        'driverId': driverId,
        'status': BookingStatus.driverAssigned.name,
      });

      return BookingModel.fromMap(snapshot.id, {
        ...data,
        'driverId': driverId,
        'status': BookingStatus.driverAssigned.name,
      });
    });
  }

  Stream<BookingModel?> watchMyActiveDriverBooking() {
    return _bookings
        .where('driverId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final activeBookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
              .where(
                (booking) => !{
                  BookingStatus.completed,
                  BookingStatus.cancelledByUser,
                  BookingStatus.cancelledByDriver,
                  BookingStatus.driverNotFound,
                }.contains(booking.status),
              )
              .toList();

          activeBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return activeBookings.isEmpty ? null : activeBookings.first;
        });
  }

  Future<BookingModel?> startHeadingToCustomer(String bookingId) async {
    final driverId = currentUserId;
    final bookingRef = _bookings.doc(bookingId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null || data['driverId'] != driverId) {
        return null;
      }

      final booking = BookingModel.fromMap(snapshot.id, data);

      if (booking.status != BookingStatus.driverAssigned) {
        return null;
      }

      transaction.update(bookingRef, {
        'status': BookingStatus.driverArriving.name,
      });

      return BookingModel.fromMap(snapshot.id, {
        ...data,
        'status': BookingStatus.driverArriving.name,
      });
    });
  }

  Future<BookingModel?> markDriverArrived(String bookingId) async {
    final driverId = currentUserId;
    final bookingRef = _bookings.doc(bookingId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) return null;

      final data = snapshot.data();

      if (data == null || data['driverId'] != driverId) {
        return null;
      }

      final booking = BookingModel.fromMap(snapshot.id, data);

      if (booking.status != BookingStatus.driverArriving) {
        return null;
      }

      transaction.update(bookingRef, {
        'status': BookingStatus.driverArrived.name,
      });

      return BookingModel.fromMap(snapshot.id, {
        ...data,
        'status': BookingStatus.driverArrived.name,
      });
    });
  }

  Future<BookingModel?> beginVerification(String bookingId) async {
    final driverId = currentUserId;
    final bookingRef = _bookings.doc(bookingId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) return null;

      final data = snapshot.data();

      if (data == null || data['driverId'] != driverId) {
        return null;
      }

      final booking = BookingModel.fromMap(snapshot.id, data);

      if (booking.status != BookingStatus.driverArrived) {
        return null;
      }

      transaction.update(bookingRef, {
        'status': BookingStatus.verification.name,
      });

      return BookingModel.fromMap(snapshot.id, {
        ...data,
        'status': BookingStatus.verification.name,
      });
    });
  }

  String generateTripPin() {
    final random = Random.secure();

    return List.generate(4, (_) => random.nextInt(10)).join();
  }
  Future<BookingModel?> cancelBookingByDriver(String bookingId) async {
  final driverId = currentUserId;
  final bookingRef = _bookings.doc(bookingId);

  return _firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(bookingRef);

    if (!snapshot.exists) return null;

    final data = snapshot.data();

    if (data == null || data['driverId'] != driverId) {
      return null;
    }

    final booking = BookingModel.fromMap(snapshot.id, data);

    const cancellableStatuses = {
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
      'status': BookingStatus.cancelledByDriver.name,
    });

    return BookingModel.fromMap(snapshot.id, {
      ...data,
      'status': BookingStatus.cancelledByDriver.name,
    });
  });
}
}
