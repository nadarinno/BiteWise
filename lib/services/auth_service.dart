
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return result.user;
  }


Future<User?> register(String email, String password) async {
  try {
    final cleanEmail = email.trim();

    final result = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password.trim(),
    );

    final user = result.user;

    if (user == null) {
      throw Exception("User not created");
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "uid": user.uid,
      "email": cleanEmail,
      "createdAt": FieldValue.serverTimestamp(),
      "profileComplete": false,
    }, SetOptions(merge: true));

    return user;
  } on FirebaseAuthException catch (e) {
    throw Exception(e.message);
  } catch (e) {
    throw Exception("Register error: $e");
  }
}


Future<void> reauthenticateAndDeleteAccount(String password) async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception("User not found.");
  }

  if (user.email == null) {
    throw Exception("User email not found.");
  }

  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: password,
  );

  await user.reauthenticateWithCredential(credential);

  await deleteAccountCompletely();
}

Future<void> deleteAccountCompletely() async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception("User not logged in.");
  }

  final uid = user.uid;
  final firestore = FirebaseFirestore.instance;

  final userRef = firestore.collection("users").doc(uid);

  // Delete meals
  final mealsSnapshot = await userRef.collection("meals").get();

  for (final meal in mealsSnapshot.docs) {
    final data = meal.data();

    final image = data["image"];
    if (image != null && image.toString().isNotEmpty) {
      await _safeDeleteStorageFile(image.toString());
    }

    await meal.reference.delete();
  }

  // Delete plans
  final plansSnapshot = await userRef.collection("plans").get();
  for (final doc in plansSnapshot.docs) {
    await doc.reference.delete();
  }

  // Delete chats
  final chatsSnapshot = await userRef.collection("chats").get();
  for (final doc in chatsSnapshot.docs) {
    await doc.reference.delete();
  }

  //  Delete profile image
  final userDoc = await userRef.get();

final profileImage = userDoc.data()?["profileImage"];

if (profileImage != null &&
    profileImage.toString().isNotEmpty) {
  await _safeDeleteStorageFile(profileImage.toString());
}

  // Delete user document
  await userRef.delete();

  // Delete Authentication account
  await user.delete();
}

Future<void> _safeDeleteStorageFile(String urlOrPath) async {
  try {
    if (urlOrPath.startsWith("http")) {
      await FirebaseStorage.instance.refFromURL(urlOrPath).delete();
    } else {
      await FirebaseStorage.instance.ref(urlOrPath).delete();
    }
  } on FirebaseException {
    return;
  } catch (_) {
    return;
  }
}

  Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
}

  Future<void> sendResetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  User? get currentUser => _auth.currentUser;
}