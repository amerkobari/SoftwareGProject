import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:untitled/pages/itempage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();


  // OpenAI API Call
  Future<String> _callOpenAI(String message) async {
    const String apiKey = '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'; // Replace with your OpenAI API key.
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': message},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: ${response.statusCode} ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: Unable to fetch response from OpenAI.';
    }
  }

  // Database Search API Call
 Future<String> _callDatabaseAPI(String query) async {
  const String searchApiUrl = 'http://10.0.2.2:3000/api/auth/search'; // Replace with your API URL

  try {
    // Pass the full query as a parameter
    final response = await http.get(
      Uri.parse('$searchApiUrl?keyword=${Uri.encodeComponent(query)}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      if (data.isEmpty) {
        return 'No items found for your query.';
      }

      // Format results as a list
      return jsonEncode(data);
    } else {
      return 'Error: ${response.statusCode} ${response.reasonPhrase}';
    }
  } catch (e) {
    return 'Error: Unable to fetch data from the database.';
  }
}


  // Determine which API to call
  Future<String> _getResponse(String message) async {
    if (message.toLowerCase().startsWith('search')) {
      // User wants to search for items
      final query = message.substring(7).trim();
      return await _callDatabaseAPI(query);
    } else {
      // Default to OpenAI chatbot
      return await _callOpenAI(message);
    }
  }

void _sendMessage() async {
  if (_controller.text.isEmpty) return;

  setState(() {
    _messages.add({'role': 'user', 'content': _controller.text});
    _isLoading = true;
  });

  // Unfocus the TextField
  _focusNode.unfocus();

  final response = await _getResponse(_controller.text);

  setState(() {
    _messages.add({'role': 'bot', 'content': response});
    _isLoading = false;
  });

  _controller.clear();
}


  void _onItemTap(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemPage(itemId: item['_id']),
      ),
    );
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final isChatbotResponse = !message['content']!.startsWith('['); // Check for JSON array format

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
              bottomLeft: Radius.circular(12.0),
            ),
          ),
          child: Text(
            message['content']!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (isChatbotResponse) {
      // OpenAI Chatbot Response
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple, width: 2.0),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/chatbot.png', // Replace with the correct path to your chatbot icon
                  fit: BoxFit.cover,
                  width: 36,
                  height: 36,
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              child: Text(
                message['content']!,
                style: const TextStyle(color: Colors.black, fontSize: 16.0),
              ),
            ),
          ),
        ],
      );
    } else {
      // Database Search Response
      final List<dynamic> items = jsonDecode(message['content']!);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return GestureDetector(
            onTap: () => _onItemTap(item),
            child: Card(
              color: const Color.fromARGB(255, 243, 243, 243),
              shadowColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title: ${item['title']}',
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text('Description: ${item['description']}'),
                    const SizedBox(height: 4.0),
                    Text('Price: ₪${item['price']}'),
                    const SizedBox(height: 4.0),
                    Text('Location: ${item['location']}'),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ByteBuddy'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:Stack(
        children: [
          // Background Image
          Positioned.fill(
              child: Opacity(
            opacity: 0.5, // Adjust this value between 0.0 (fully transparent) and 1.0 (fully opaque)
            child: Image.asset(
              'assets/icons/chatbotBG.jpg', // Replace with your image path
              fit: BoxFit.cover,
          ),
              ),
          ),
          // Chat Content 
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
  controller: _controller,
  focusNode: _focusNode, // Attach the FocusNode here
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.0),
      borderSide: BorderSide.none,
    ),
    hintText: '(Use "search" to query the database)',
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
  ),
),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
  );
  }
}
