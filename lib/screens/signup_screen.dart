import 'package:flutter/material.dart';
import 'package:hichat/widgets/my_textfield.dart';
import 'package:hichat/widgets/my_containr.dart';
import 'package:hichat/widgets/my_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                  const MyTextField(
                    hintText: 'Full Name',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 16),
                  const MyTextField(
                    hintText: 'Email Address',
                    icon: Icons.email_rounded,
                  ),
                  const SizedBox(height: 16),
                  const MyTextField(
                    hintText: 'Password',
                    icon: Icons.lock_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  const MyTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_clock_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  MyButton(
                    text: 'Sign Up',
                    onPressed: () {
                      Navigator.pop(context);
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
