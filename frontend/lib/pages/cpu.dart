import 'package:flutter/material.dart';

class CPUPage extends StatelessWidget {
  const CPUPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CPU',
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
      body: const Center(child: Text('Welcome to the CPU Page!')),
    );
  }
}

// Similarly, create GPUPage, RAMPage, HardDiskPage, etc.
