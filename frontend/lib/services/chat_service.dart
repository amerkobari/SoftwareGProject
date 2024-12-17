import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch chat rooms for the current username
  Stream<List<Map<String, dynamic>>> getChatRooms(String currentUserName) {
    return _firestore
        .collection('Chatrooms')
        .where('userNames', arrayContains: currentUserName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
