import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hichat/firebase_options.dart';
import 'package:hichat/helper/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HiChat',
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
