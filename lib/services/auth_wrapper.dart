
import 'package:bitewise/services/user_service.dart';
import 'package:bitewise/view/home.dart';
import 'package:bitewise/view/login.dart';
import 'package:bitewise/view/profilesetup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return LoginScreen();
        }

        return ProfileCheckScreen(key: ValueKey(user.uid));
      },
    );
  }
}

class ProfileCheckScreen extends StatelessWidget {
  const ProfileCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: UserService().isProfileComplete(),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (profileSnapshot.hasError) {
          return ProfileSetupScreen();
        }

        if (profileSnapshot.data == true) {
          return const HomeScreen();
        }

        return ProfileSetupScreen();
      },
    );
  }
}