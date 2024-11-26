import 'package:flutter/material.dart';
class MonitorsPage extends StatelessWidget {
  const MonitorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monitors',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: const Center(child: Text('Welcome to the Monitors Page!')),
    );
  }
}