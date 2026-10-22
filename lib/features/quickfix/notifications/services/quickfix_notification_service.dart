
import 'package:cloud_firestore/cloud_firestore.dart';

class QuickFixNotificationService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getNotifications(String userId) {
    return _firestore
        .collection('quickfix_notifications')
        .where('receiverId', isEqualTo: userId)
        .snapshots();
  }

  Stream<int> getUnreadCount(String userId) {
    return getNotifications(userId).map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data()['isRead'] == false)
          .length;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('quickfix_notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
