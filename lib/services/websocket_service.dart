import 'dart:convert';
import 'package:flutter_messenger/models/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_service.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  late WebSocketChannel _edit;

  Future<void> connect(int chatId, void Function(Message) onMessage) async {
    final token = await ApiService.getAccessToken();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://109.173.168.29:8001/ws/chat/$chatId?token=$token'),
    );

    _edit = WebSocketChannel.connect(
      Uri.parse('ws://109.173.168.29:8001/ws/chat/edit/$chatId?token=$token'),
    );

    _channel.stream.listen((data) {
      try {
        print('📥 NEW message: $data');
        final jsonData = jsonDecode(data);
        final message = Message.fromJson(jsonData);
        onMessage(message);
      } catch (e, st) {
        print('❌ Ошибка в _channel.stream: $e\n$st');
      }
    });

    _edit.stream.listen((data) {
      try {
        print('✏️ EDIT message: $data');
        final jsonData = jsonDecode(data);
        final message = Message.fromJson(jsonData);
        onMessage(message);
      } catch (e, st) {
        print('❌ Ошибка в _edit.stream: $e\n$st');
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

  void disconnect() {
    _channel.sink.close();
    _edit.sink.close();
  }
}
