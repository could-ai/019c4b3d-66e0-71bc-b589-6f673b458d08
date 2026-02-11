import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text, {String? imagePath, Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && imagePath == null && imageBytes == null) return;

    final userMessage = Message(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      imageUrl: imagePath, // Store local path for display
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      String? base64Image;
      if (imageBytes != null) {
         base64Image = base64Encode(imageBytes);
      } else if (imagePath != null) {
        // For mobile/desktop
        final bytes = await File(imagePath).readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final response = await Supabase.instance.functions.invoke(
        'gemini-chat',
        body: {
          'prompt': text,
          'image': base64Image,
        },
      );

      if (response.status == 200) {
        final data = response.data;
        final botText = data['text'] ?? 'No response';
        
        final botMessage = Message(
          id: DateTime.now().toString() + '_bot',
          text: botText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(botMessage);
      } else {
        _addErrorMessage('Error: ${response.status} - ${response.data}');
      }
    } catch (e) {
      _addErrorMessage('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addErrorMessage(String error) {
    _messages.add(Message(
      id: DateTime.now().toString() + '_error',
      text: error,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }
}
