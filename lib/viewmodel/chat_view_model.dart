
import 'package:bitewise/model/chatmessages_model.dart';
import 'package:bitewise/services/chat_firebase_service.dart';
import 'package:bitewise/services/chat_service.dart';
import 'package:bitewise/services/user_service.dart';
import 'package:flutter/foundation.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _ai = ChatService();
  final ChatFirebaseService _db = ChatFirebaseService();

  List<ChatMessage> messages = [];
  bool isLoading = false;

  Stream<List<ChatMessage>> getMessages() => _db.getMessages();
Future<void> send(String text) async {
  if (text.trim().isEmpty) return;

  try {
    
    final isComplete = await UserService().isProfileComplete();

    if (!isComplete) {
      final msg = ChatMessage(
        text: "⚠️ Please complete your profile first",
        isUser: false,
        time: DateTime.now(),
      );

      await _db.saveMessage(msg);
      return;
    }

   
    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      time: DateTime.now(),
    );

    await _db.saveMessage(userMsg);

    isLoading = true;
    notifyListeners();

    // GET USER DATA
    final userData = await UserService().getUserData();

    final int age = userData["age"];
    final double weight = (userData["weight"]).toDouble();
    final double height = (userData["height"]).toDouble();
    final String disease = userData["disease"] ?? "";

    //  history
    final history = await _db.getLastMessagesOnce();

    //  AI
    final reply = await _ai.sendMessage(
      history: history,
      newMessage: text,
      age: age,
      weight: weight,
      height: height,
      disease: disease,
    );

    final aiMsg = ChatMessage(
      text: reply,
      isUser: false,
      time: DateTime.now(),
    );

    await _db.saveMessage(aiMsg);

  } catch (e) {
    final errorMsg = ChatMessage(
      text: "Something went wrong",
      isUser: false,
      time: DateTime.now(),
    );

    await _db.saveMessage(errorMsg);
  }

  isLoading = false;
  notifyListeners();
}
}