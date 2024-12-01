import 'package:flutter/material.dart';
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
      //  home: const OwnerShopPage(shopId: '674c6c9c2443e4779d0f8c14',),
      home: const HomePage(username: 'Guest'), // Set HomePage as the initial screen
    );
  }
}
