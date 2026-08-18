import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modules/mathos_chat_module.dart';

class LocalStorageService {
  static const String _messagesKey = 'chat_messages_history';

  // Save messages to SharedPreferences
  Future<void> saveMessages(List<MathosMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sadece son 50 mesajı kaydet (Performans için)
    final messagesToSave = messages.length > 50 
        ? messages.sublist(messages.length - 50) 
        : messages;

    final jsonList = messagesToSave.map((m) => {
      'id': m.id,
      'text': m.text,
      'sender': m.sender.name,
      'imagePath': m.imageFile?.path, 
      'createdAt': m.createdAt.toIso8601String(),
    }).toList();

    await prefs.setString(_messagesKey, jsonEncode(jsonList));
  }

  // Load messages from SharedPreferences
  Future<List<MathosMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_messagesKey);
    
    if (jsonStr == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((json) {
        return MathosMessage(
          id: json['id'],
          text: json['text'],
          sender: json['sender'] == 'user' ? MessageSender.user : MessageSender.ai,
          imageFile: json['imagePath'] != null ? File(json['imagePath']) : null,
          createdAt: DateTime.parse(json['createdAt']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Clear history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey);
  }
}
