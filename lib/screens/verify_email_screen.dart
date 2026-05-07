import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hichat/helper/dialogs.dart';
import 'package:hichat/widgets/my_button.dart';
import 'package:hichat/widgets/my_containr.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        Dialogs.showSnackbar(context, e.toString(), color: Colors.redAccent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? Scaffold(
            body: MyContainer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Colors.green,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Email Verified!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Redirecting you...',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(height: 32),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            body: MyContainer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 100,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Verify your email',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A verification email has been sent to:\n${FirebaseAuth.instance.currentUser?.email}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      MyButton(
                        text: 'Resend Email',
                        onPressed: canResendEmail
                            ? sendVerificationEmail
                            : () {},
                        color: canResendEmail ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text(
                          'Cancel / Sign Out',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
