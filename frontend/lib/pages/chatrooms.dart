import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/chatscreen.dart';
import 'package:untitled/services/chat_service.dart';
import 'package:untitled/pages/login.dart'; // Import the login page

class MessagesPage extends StatefulWidget {
  final String currentUserName;

  const MessagesPage({super.key, required this.currentUserName});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatService chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    // If current user is Guest, show the login dialog
    if (widget.currentUserName == "Guest") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginAlert(context);
      });
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     "Messages",
      //     style: TextStyle(
      //       color: Colors.white,
      //       fontSize: 22,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   backgroundColor: Colors.redAccent,
      //   centerTitle: true,
      // ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getChatRooms(widget.currentUserName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No messages yet."));
          }

          final chatRooms = snapshot.data!;

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
              thickness: 0.5, // Thin line between chatrooms
              height: 0.5,
            ),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final List<dynamic> userNames = chatRoom['userNames'];
              final otherUserName = userNames.firstWhere(
                (name) => name != widget.currentUserName,
              );

              return FutureBuilder<int>(
                future: _fetchUnreadCount(chatRoom['id'], widget.currentUserName),
                builder: (context, unreadSnapshot) {
                  final unreadCount = unreadSnapshot.data ?? 0;

                  return ListTile(
                    leading: const Icon(Icons.account_circle,
                        size: 40, color: Colors.grey), // Account icon
                    title: Text(
                      otherUserName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chatRoom['lastMessage'] ?? 'No messages yet',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Last message time
                        Text(
                          _formatTimestamp(chatRoom['timestamp']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Unread message count
                        if (unreadCount > 0)
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () async {
                      await _markMessagesAsRead(chatRoom['id']);

                      // Refresh UI immediately after marking messages as read
                      setState(() {});

                      // Navigate to the chatroom
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoomId: chatRoom['id'],
                            currentUserName: widget.currentUserName,
                            otherUserName: otherUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Show alert dialog for guest users
  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text("You need to log in to start messaging."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fetch unread message count
  Future<int> _fetchUnreadCount(String chatRoomId, String currentUserName) async {
    QuerySnapshot unreadMessages = await FirebaseFirestore.instance
        .collection('Chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiver', isEqualTo: currentUserName)
        .where('isRead', isEqualTo: false)
        .get();

    return unreadMessages.docs.length;
  }

  // Mark messages as read
  Future<void> _markMessagesAsRead(String chatRoomId) async {
    QuerySnapshot unreadMessages = await FirebaseFirestore.instance
        .collection('Chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    for (var message in unreadMessages.docs) {
      await message.reference.update({'isRead': true});
    }
  }

  // Format timestamp to HH:mm
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '--:--';
    final dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
