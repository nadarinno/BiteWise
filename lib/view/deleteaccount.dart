import 'package:bitewise/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bitewise/view/login.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password is required")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
  await AuthService().reauthenticateAndDeleteAccount(password);

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => LoginScreen(),
    ),
    (route) => false,
  );
} on FirebaseAuthException catch (e) {
  if (!mounted) return;

  String message = "Something went wrong";

  if (e.code == "invalid-credential" || e.code == "wrong-password") {
    message = "Incorrect password";
  } else if (e.code == "requires-recent-login") {
    message = "Please try again";
  }

  setState(() {
    isLoading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
} catch (e) {
  if (!mounted) return;

  setState(() {
    isLoading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error: $e")),
  );
}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Delete Account",
          style: theme.textTheme.titleLarge,
        ),
      ),
     body: SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    children: [
      const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 70,
      ),

      const SizedBox(height: 20),

      Text(
        "This will permanently delete your account and all your data.",
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge,
      ),

      const SizedBox(height: 12),

      Text(
        email,
        style: theme.textTheme.bodyMedium,
      ),

      const SizedBox(height: 30),

      TextField(
        controller: passwordController,
        obscureText: true,
        style: theme.textTheme.bodyLarge,
        decoration: const InputDecoration(
          hintText: "Enter your password",
          prefixIcon: Icon(Icons.lock),
        ),
      ),

      const SizedBox(height: 24),

      isLoading
          ? const CircularProgressIndicator()
          : OutlinedButton(
              onPressed: _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                "Delete Account Permanently",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    ],
  ),
),
    );
  }
}