import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hichat/helper/dialogs.dart';
import 'package:hichat/helper/my_regex.dart';
import 'package:hichat/widgets/my_textfield.dart';
import 'package:hichat/widgets/my_containr.dart';
import 'package:hichat/widgets/my_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();
    super.dispose();
  }

  void _signup() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String cpassword = _cpasswordController.text.trim();

    if (email == "" || password == "" || cpassword == "") {
      Dialogs.showSnackbar(context, "Please fill all details");
    } else if (!MyRegex.isValidPassword(password)) {
      Dialogs.showSnackbar(
        context,
        "Password must be at least 8 characters long and contain both letters and numbers",
        color: Colors.redAccent,
      );
    } else if (password != cpassword) {
      Dialogs.showSnackbar(
        context,
        "Passwords do not match",
        color: Colors.redAccent,
      );
    } else {
      Dialogs.showProgressBar(context);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        if (mounted) Navigator.pop(context);

        if (userCredential.user != null) {
          await userCredential.user!.sendEmailVerification();

          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
            Dialogs.showSnackbar(
              context,
              "Account created! Please verify your email.",
              color: Colors.green,
            );
          }
        }
      } on FirebaseAuthException catch (ex) {
        if (mounted) Navigator.pop(context);

        String errorMessage = "An error occurred";
        if (ex.code == 'email-already-in-use') {
          errorMessage = "The email address is already in use.";
        } else if (ex.code == 'weak-password') {
          errorMessage = "The password provided is too weak.";
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: Colors.black87,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join HiChat and start connecting',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  MyTextField(
                    hintText: 'Email Address',
                    icon: Icons.email_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    hintText: 'Password',
                    icon: Icons.lock_rounded,
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_clock_rounded,
                    isPassword: true,
                    controller: _cpasswordController,
                  ),
                  const SizedBox(height: 32),
                  MyButton(
                    text: 'Sign Up',
                    onPressed: () {
                      _signup();
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Sign In',
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
