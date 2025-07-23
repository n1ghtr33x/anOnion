import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_messenger/models/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message.dart';

class CacheService {
  static const _chatsKey = 'cached_chats';

  static Future<void> saveChats(List<Chat> chats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = chats.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_chatsKey, jsonList);
  }

  static Future<List<Chat>> loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_chatsKey);
    if (jsonList == null) return [];
    return jsonList.map((e) => Chat.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveLastMessages(Map<int, String> lastMessages) async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, String> jsonMap = lastMessages.map(
      (key, message) => MapEntry(key.toString(), message),
    );

    await prefs.setString('last_messages', jsonEncode(jsonMap));
  }

  static Future<Map<int, String>> loadLastMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('last_messages');
    if (jsonString == null) return {};

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map(
      (key, value) => MapEntry(int.parse(key), value as String),
    );
  }

  static Future<void> saveMessages(int chatId, List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => m.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString('chat_messages_$chatId', jsonString);
  }

  static Future<List<Message>> loadMessages(int chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('chat_messages_$chatId');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatsKey);
    await prefs.remove('last_messages');
    final keys = prefs.getKeys().where(
      (key) => key.startsWith('chat_messages_'),
    );
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<void> saveProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future<String> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  static Future<String> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }
}
