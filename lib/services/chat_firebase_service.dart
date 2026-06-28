import 'package:bitewise/model/chatmessages_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatFirebaseService {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveMessage(ChatMessage msg) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("chats")
        .add(msg.toJson());
  }

  Stream<List<ChatMessage>> getMessages() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("chats")
        .orderBy("time")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data()))
            .toList());
  }

  Future<List<ChatMessage>> getLastMessagesOnce() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("chats")
        .orderBy("time", descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromJson(doc.data()))
        .toList()
        .reversed
        .toList();
  }
}