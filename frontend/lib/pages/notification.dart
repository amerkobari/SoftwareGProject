import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/postdetail.dart';

class NotificationsPopup extends StatefulWidget {
  const NotificationsPopup({super.key});

  @override
  _NotificationsPopupState createState() => _NotificationsPopupState();
}

class _NotificationsPopupState extends State<NotificationsPopup> {
  final AuthController _authController = AuthController();
  String username = '';

  @override
  void initState() {
    super.initState();
    setUsername();
  }

  Future<String> getUsername() async {
    String token = await _authController.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['username'] ?? 'Guest';
  }

  Future<void> setUsername() async {
    String fetchedUsername = await getUsername();
    setState(() {
      username = fetchedUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 200),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: username.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('postOwner', isEqualTo: username)
                          // .orderBy('type', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No notifications available.'));
                        }

                        return ListView(
                          children: snapshot.data!.docs.map((doc) {
                            final notification = NotificationModel.fromFirestore(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                            return ListTile(
  leading: _getNotificationIcon(notification.type),
  title: Text(notification.message),
  subtitle: Text(notification.time),
  onTap: () {
    print('Notification ID: ${notification.id}');
    print(username);
    Navigator.of(context).pop(); // Close the popup
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostDetailPage(
          postId: notification.postId,
          currentUsername: username,
        ), // Navigate to the post detail page
      ),
    );
  },
);

                    }).toList(),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Icon _getNotificationIcon(String type) {
  switch (type) {
    case 'like':
      return Icon(Icons.favorite, color: Colors.red); // Heart icon for likes
    case 'comment':
      return Icon(Icons.comment, color: Colors.blue); // Comment icon for comments
    case 'follow':
      return Icon(Icons.person_add, color: Colors.green); // Person icon for follows
    case 'mention':
      return Icon(Icons.alternate_email, color: Colors.orange); // Mention icon
    default:
      return Icon(Icons.notifications, color: Colors.grey); // Default notification icon
  }
}

}

class NotificationModel {
  final String id;
  final String type; // "comment" or "like"
  final String message;
  final String time;
  final bool isRead; // New field
  final String postId; // Associated post ID

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.time,
    required this.isRead,
    required this.postId,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    String formattedTime = 'No time';
    if (data['time'] is Timestamp) {
      final timestamp = data['time'] as Timestamp;
      final date = timestamp.toDate();
      formattedTime = '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}';
    }

    return NotificationModel(
      id: documentId,
      type: data['type'] ?? 'unknown',
      message: data['message'] ?? 'No message',
      time: formattedTime, // Use the formatted time
      isRead: data['isRead'] ?? false, // Default to false if missing
      postId: data['postId'] ?? '', // Pass postId directly
    );
  }
}