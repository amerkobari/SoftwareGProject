import 'package:flutter/material.dart';
import 'package:untitled/pages/addnewitem.dart';
import 'package:untitled/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: AddItemPage(),
      // home: const HomePage(username: 'Guest'), // Set HomePage as the initial screen
    );
  }
}
