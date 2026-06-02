import 'package:flutter/material.dart';

import 'splash_screen.dart'; 

void main() {
  runApp(const ActiveLabApp());
}

class ActiveLabApp extends StatelessWidget {
  const ActiveLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}