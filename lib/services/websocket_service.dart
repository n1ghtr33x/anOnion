import 'dart:convert';
import 'package:flutter/material.dart';
import '/../models/message.dart';
import '/../models/chat.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_service.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  late WebSocketChannel _edit;
  void Function(Chat updatedChat)? _onChatUpdate;
  late WebSocketChannel _chats;

  /// Добавляем параметр [onNewChat] для уведомления о новых чатах
  Future<void> connect(
    int chatId,
    void Function(Message) onMessage, {
    void Function(Chat)? onNewChat,
  }) async {
    final token = await ApiService.getAccessToken();

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://109.173.168.29:8001/ws/chat/$chatId?token=$token'),
    );

    _edit = WebSocketChannel.connect(
      Uri.parse('ws://109.173.168.29:8001/ws/chat/edit/$chatId?token=$token'),
    );

    _chats = WebSocketChannel.connect(
      Uri.parse(
        'ws://109.173.168.29:8001/ws/chats?token=$token',
      ), // твой сервер
    );

    // Обработка новых сообщений
    _channel.stream.listen((data) {
      try {
        debugPrint('📥 NEW message: $data');
        final jsonData = jsonDecode(data);
        final message = Message.fromJson(jsonData);
        onMessage(message);
      } catch (e, st) {
        debugPrint('❌ Ошибка в _channel.stream: $e\n$st');
      }
    });

    // Обработка редактирования сообщений
    _edit.stream.listen((data) {
      try {
        debugPrint('✏️ EDIT message: $data');
        final jsonData = jsonDecode(data);
        final message = Message.fromJson(jsonData);
        onMessage(message);
      } catch (e, st) {
        debugPrint('❌ Ошибка в _edit.stream: $e\n$st');
      }
    });

    // Обработка новых чатов
    _chats.stream.listen((data) {
      try {
        final jsonData = jsonDecode(data);

        // новый чат
        if (jsonData['event'] == 'new_chat' && onNewChat != null) {
          final newChat = Chat.fromJson(jsonData['chat']);
          onNewChat(newChat);
        }

        // обновление чата
        if (jsonData['event'] == 'chat_updated' && _onChatUpdate != null) {
          final updatedChat = Chat.fromJson(jsonData['chat']);
          _onChatUpdate!(updatedChat);
        }
      } catch (e, st) {
        debugPrint('❌ Ошибка в _chats.stream: $e\n$st');
      }
    });
  }

  void sendMessage(int userId, String content) {
    final msg = {"user_id": userId, "content": content};
    _channel.sink.add(jsonEncode(msg));
  }

  void editMessage(int userId, String content, int messageId) {
    final msg = {
      "user_id": userId,
      "content": content,
      "message_id": messageId,
      "edited": true,
      "deleted": false,
    };
    _edit.sink.add(jsonEncode(msg));
  }

  void sendImageBase64(int userId, String base64Data, String mimeType) {
    final msg = {
      "user_id": userId,
      "image_base64": base64Data,
      "mime_type": mimeType,
    };
    _channel.sink.add(jsonEncode(msg));
  }

  void sendImageWithText({
    required int userId,
    required String base64Image,
    required String mimeType,
    required String text,
  }) {
    final data = {
      'user_id': userId,
      'image_base64': base64Image,
      'mime_type': mimeType,
      'content': text,
    };
    _channel.sink.add(jsonEncode(data));
  }

  void deleteMessage(int userId, int messageId) {
    final msg = {
      "user_id": userId,
      "message_id": messageId,
      "content": "",
      "edited": false,
      "deleted": true,
    };
    _edit.sink.add(jsonEncode(msg));
  }

  /// Закрываем все соединения
  void disconnect() {
    _channel.sink.close();
    _edit.sink.close();
    _chats.sink.close();
  }

  void listenChatUpdates(void Function(Chat updatedChat) callback) {
    _onChatUpdate = callback;
  }
}
