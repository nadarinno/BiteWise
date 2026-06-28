class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "isUser": isUser,
      "time": time.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json["text"],
      isUser: json["isUser"],
      time: DateTime.parse(json["time"]),
    );
  }
}