import 'package:flutter/material.dart';
import 'package:hichat/screens/signin_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HiChat',
      debugShowCheckedModeBanner: false,
      home: SigninScreen(),
    );
  }
}
