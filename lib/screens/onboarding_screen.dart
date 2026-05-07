import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichat/api/api.dart';
import 'package:hichat/bottom_navigator_handler.dart';
import 'package:hichat/helper/dialogs.dart';
import 'package:hichat/widgets/my_button.dart';
import 'package:hichat/widgets/my_containr.dart';
import 'package:hichat/widgets/my_textfield.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = Api.auth.currentUser?.displayName ?? '';
    _emailController.text = Api.auth.currentUser?.email ?? '';
    Api.getSelfInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername(String username) async {
    if (username.isEmpty) {
      setState(() {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });

    final available = await Api.isUsernameAvailable(username);

    if (mounted) {
      setState(() {
        _isUsernameAvailable = available;
        _isCheckingUsername = false;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty) {
      Dialogs.showSnackbar(context, 'Name is required');
      return;
    }

    if (username.isEmpty) {
      Dialogs.showSnackbar(context, 'Unique ID is required');
      return;
    }

    if (!_isUsernameAvailable) {
      Dialogs.showSnackbar(context, 'Username is already taken');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Api.getSelfInfo();
      Api.me.name = name;
      Api.me.username = username;

      await Api.updateUserInfo();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const BottomNavigatorHandler()),
        );
      }
    } catch (e) {
      log('Error during onboarding: $e');
      if (mounted) {
        Dialogs.showSnackbar(
          context,
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Just a few more details to get started',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                MyTextField(
                  hintText: 'Email',
                  icon: Icons.email_rounded,
                  controller: _emailController,
                  readOnly: true,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Full Name *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                MyTextField(
                  hintText: 'Enter your name',
                  icon: Icons.person_rounded,
                  controller: _nameController,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Unique ID (Username) *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                MyTextField(
                  hintText: 'e.g. john_doe',
                  icon: Icons.alternate_email_rounded,
                  controller: _usernameController,
                  onChanged: (val) => _checkUsername(val),
                ),

                if (_usernameController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Row(
                      children: [
                        if (_isCheckingUsername)
                          const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey,
                            ),
                          )
                        else
                          Icon(
                            _isUsernameAvailable
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 16,
                            color: _isUsernameAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isCheckingUsername
                              ? 'Checking availability...'
                              : (_isUsernameAvailable
                                    ? 'Username is available'
                                    : 'Username is taken'),
                          style: TextStyle(
                            fontSize: 12,
                            color: _isCheckingUsername
                                ? Colors.grey
                                : (_isUsernameAvailable
                                      ? Colors.green
                                      : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                MyButton(
                  text: 'Continue',
                  loading: _isLoading,
                  onPressed: _submit,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
