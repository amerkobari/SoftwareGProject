import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String currentUserName;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.currentUserName,
    required this.otherUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mark all messages as read for the current user
  void markMessagesAsRead() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot unreadMessages = await firestore
        .collection('Chatrooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .where('receiver', isEqualTo: widget.currentUserName)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markMessagesAsRead();
    });
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('Chatrooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'senderName': widget.currentUserName,
        'receiver': widget.otherUserName,
        'message': messageController.text,
        'isRead': false, // Set new message as unread
        'timestamp': FieldValue.serverTimestamp(),
      });

      FirebaseFirestore.instance
          .collection('Chatrooms')
          .doc(widget.chatRoomId)
          .update({
        'lastMessage': messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      messageController.clear();

      // Auto-scroll to the bottom
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget buildMessageBubble(String message, bool isMe, Timestamp? timestamp) {
    final time = timestamp != null
        ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
        : "--:--";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Color.fromARGB(255, 254, 111, 103)
                          .withOpacity(
                              .6) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 12 : 0),
            topRight: Radius.circular(isMe ? 0 : 12),
            bottomLeft: const Radius.circular(12),
            bottomRight: const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sendMessage,
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 254, 111, 103),
              radius: 25,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: Color.fromARGB(255, 254, 111, 103),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chatrooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message['senderName'] == widget.currentUserName;
                    return buildMessageBubble(
                      message['message'],
                      isMe,
                      message['timestamp'],
                    );
                  },
                );
              },
            ),
          ),
          buildMessageInput(),
        ],
      ),
    );
  }
}
