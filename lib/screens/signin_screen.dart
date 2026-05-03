import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichat/bottom_navigator_handler.dart';
import 'package:hichat/screens/signup_screen.dart';
import 'package:hichat/helper/dialogs.dart';
import 'package:hichat/widgets/my_textfield.dart';
import 'package:hichat/widgets/my_containr.dart';
import 'package:hichat/widgets/my_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email == "" || password == "") {
      Dialogs.showSnackbar(context, 'Please fill all fields!');
    } else {
      Dialogs.showProgressBar(context);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (mounted) Navigator.pop(context);

        if (userCredential.user != null) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => BottomNavigatorHandler()),
          );
        }
      } on FirebaseAuthException catch (ex) {
        if (mounted) Navigator.pop(context);

        String errorMessage = "An error occurred";
        if (ex.code == 'user-not-found') {
          errorMessage = "No user found for that email.";
        } else if (ex.code == 'wrong-password') {
          errorMessage = "Wrong password provided.";
        } else if (ex.code == 'network-request-failed') {
          errorMessage = "No internet connection.";
        } else if (ex.code == 'invalid-email') {
          errorMessage = "Invalid email address.";
        }

        Dialogs.showSnackbar(context, errorMessage, color: Colors.redAccent);
        log(ex.code.toString());
      } catch (e) {
        if (mounted) Navigator.pop(context);
        Dialogs.showSnackbar(
          context,
          "Something went wrong",
          color: Colors.redAccent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyContainer(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue your conversations',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  MyTextField(
                    hintText: 'Email Address',
                    icon: Icons.email_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    hintText: 'Password',
                    icon: Icons.lock_rounded,
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  MyButton(
                    text: 'Sign In',
                    onPressed: () {
                      _signin();
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
