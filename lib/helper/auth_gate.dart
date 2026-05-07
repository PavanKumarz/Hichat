import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hichat/api/api.dart';
import 'package:hichat/bottom_navigator_handler.dart';
import 'package:hichat/screens/onboarding_screen.dart';
import 'package:hichat/screens/signin_screen.dart';
import 'package:hichat/screens/verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;

          if (!user.emailVerified) {
            return const VerifyEmailScreen();
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: Api.firestore.collection('users').doc(user.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data();
                if (data != null &&
                    data['name'] != '' &&
                    data['username'] != '') {
                  return const BottomNavigatorHandler();
                }
              }

              return const OnboardingScreen();
            },
          );
        } else {
          return const SigninScreen();
        }
      },
    );
  }
}
