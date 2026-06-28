
import 'dart:convert';
import 'package:bitewise/model/chatmessages_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatService {

  Future<String> sendMessage({
    required List<ChatMessage> history,
    required String newMessage,
    required int age,
    required double weight,
    required double height,
    required String disease,
  }) async {

    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null) {
      throw Exception("API key not found");
    }

    // BMI
    double bmi = weight / ((height / 100) * (height / 100));

    String bmiCategory;
    if (bmi < 18.5) {
      bmiCategory = "Underweight";
    } else if (bmi < 25) {bmiCategory = "Normal";}
    else if (bmi < 30) {bmiCategory = "Overweight";}
    else { bmiCategory = "Obese";}

    final messages = [
      {
        "role": "system",
        "content": """
You are a professional Nutrition Coach AI.

User Info:
- Age: $age
- Weight: $weight kg
- Height: $height cm
- BMI: ${bmi.toStringAsFixed(1)} ($bmiCategory)
- Disease: ${disease.isEmpty ? "None" : disease}

Rules:
- Give personalized advice
- Suggest meals when relevant
- Keep answers short and clear
- Do NOT give medical diagnosis
- Use simple language
"""
      },

      ...history.map((m) => {
        "role": m.isUser ? "user" : "assistant",
        "content": m.text,
      }),

      
      {
        "role": "user",
        "content": newMessage,
      }
    ];

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages,
      }),
    );

    
    if (response.statusCode != 200) {
      throw Exception("API Error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"];
  }
}