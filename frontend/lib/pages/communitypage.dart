import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/login.dart';
import 'package:untitled/pages/postdetail.dart';

class CommunityPage extends StatefulWidget {
  final String currentUsername;

  CommunityPage({required this.currentUsername});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();
  List<File> _selectedImages = [];

  // Pick Multiple Images
  void _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Upload Multiple Images to Firebase Storage
Future<List<String>> _uploadImagesToStorage(List<File> images) async {
  List<String> imageUrls = [];

  // Reference to your specific bucket
  final FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: 'hardwarebazaar24-uploads',
  );

  for (var image in images) {
    try {
      // Unique filename using timestamp and file path
      String fileName =
          'posts/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

      // Reference to the file location in the bucket
      final ref = storage.ref().child(fileName);

      // Start upload task
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Fetch download URL and add to the list
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);

      print('Image uploaded: $downloadUrl'); // Log the URL
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  return imageUrls;
}






void _addPost(BuildContext context) async {
  if (_postController.text.isEmpty && _selectedImages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post content or images required.')),
    );
    return;
  }

  List<String> imageUrls = [];
  if (_selectedImages.isNotEmpty) {
    imageUrls = await _uploadImagesToStorage(_selectedImages);
  }

  if (imageUrls.isEmpty && _postController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No valid content to post.')),
    );
    return;
  }

  final newPost = {
    'content': _postController.text,
    'images': imageUrls, // Store multiple image URLs
    'username': widget.currentUsername,
    'likes': [],
    'timestamp': FieldValue.serverTimestamp(),
  };

  await FirebaseFirestore.instance.collection('posts').add(newPost);
  _postController.clear();
  setState(() {
    _selectedImages = [];
  });
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Post added!')),
  );
}

  // Show Login Prompt for Guests
  void _showLoginPrompt(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Posts List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No posts yet.'));
              }

              final posts = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index].data() as Map<String, dynamic>;
                  final postId = posts[index].id;
                  final likes = post['likes'] is List
                      ? List<String>.from(post['likes'])
                      : [];
                  final timestamp = post['timestamp'] as Timestamp?;
                  final images = post['images'] as List<dynamic>?;

                  String formattedDate = timestamp != null
                      ? DateFormat.yMMMd().format(timestamp.toDate())
                      : 'Unknown Date';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(
                            postId: postId,
                            currentUsername: widget.currentUsername,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username and Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                post['username'] ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Post Content
                          if (post['content'] != null &&
                              post['content'].isNotEmpty)
                            Text(
                              post['content'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),

                          // Display Images (if exists)
                          if (images != null && images.isNotEmpty)
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        images[index],
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 10),

                          // Likes and Comments
                          Row(
                            children: [
                              // Like Button
                              IconButton(
                                icon: Icon(
                                  likes.contains(widget.currentUsername)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  if (widget.currentUsername == 'Guest') {
                                    _showLoginPrompt(context);
                                    return;
                                  }
                                  FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(postId)
                                      .update({
                                    'likes': likes.contains(widget.currentUsername)
                                        ? FieldValue.arrayRemove(
                                            [widget.currentUsername])
                                        : FieldValue.arrayUnion(
                                            [widget.currentUsername]),
                                  });
                                },
                              ),
                              Text(
                                likes.length.toString(),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(width: 10),

                              // Comment Icon with Count
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId)
                                    .collection('comments')
                                    .snapshots(),
                                builder: (context, commentSnapshot) {
                                  if (!commentSnapshot.hasData) {
                                    return Row(
                                      children: const [
                                        Icon(Icons.comment,
                                            color: Colors.blueGrey, size: 20),
                                        SizedBox(width: 4),
                                        Text(
                                          '0',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    );
                                  }
                                  final commentCount =
                                      commentSnapshot.data!.docs.length;
                                  return Row(
                                    children: [
                                      const Icon(Icons.comment,
                                          color: Colors.blueGrey, size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        commentCount.toString(),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Input Section (Only for Logged-In Users)
          if (widget.currentUsername != 'Guest')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImages[index],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.blueGrey),
                        onPressed: _pickImages,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _postController,
                          decoration: InputDecoration(
                            hintText: 'Write something...',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.black87),
                        onPressed: () => _addPost(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
