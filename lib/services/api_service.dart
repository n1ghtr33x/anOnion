import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '/../main.dart';
import '/../screens/auth/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://anonion.nextlayer.site/api";

class ApiService {
  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) return token;

    final success = await refreshToken();
    if (success) {
      return prefs.getString('access_token');
    } else {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return null;
  }

  static Future<http.Response> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['access_token'], data['refresh_token']);
    }

    return response;
  }

  static Future<http.Response> register(Map<String, String> body) {
    return http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> uploadAvatar(File file) async {
    final token = await getAccessToken();
    if (token == null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      throw Exception('Unauthorized');
    }

    var uri = Uri.parse('$baseUrl/upload-avatar');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> getChats() async {
    final token = await getAccessToken();

    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/chats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return response;
  }

  static Future<http.Response> getMessages(int chatId) async {
    final token = await getAccessToken();

    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/chats/$chatId/messages'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return response;
  }

  static Future<http.Response> sendMessage(int chatId, String content) async {
    final token = await getAccessToken();

    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/chats/$chatId/messages?content=$content'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return response;
  }

  static Future<http.Response> createPrivateChat(String otherUsername) async {
    final token = await getAccessToken();
    final uri = Uri.parse(
      '$baseUrl/chats/create_with_user?other_username=$otherUsername',
    );
    return http.post(uri, headers: {'Authorization': 'Bearer $token'});
  }

  static Future<http.Response> createChat(String name) async {
    final token = await getAccessToken();
    return http.post(
      Uri.parse('$baseUrl/chats/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );
  }

  static Future<http.Response> getProfile() async {
    final token = await getAccessToken();

    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return response;
  }

  static Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');

    if (refresh == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Authorization': 'Bearer $refresh'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['access_token'], data['refresh_token']);
      return true;
    } else {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return false;
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<http.Response> editMessage(
    int messageId,
    String content,
  ) async {
    final headers = await getAuthHeaders();
    return http.put(
      Uri.parse('$baseUrl/messages/$messageId?content=$content'),
      headers: headers,
    );
  }

  static Future<http.Response> deleteMessage(int messageId) async {
    final headers = await getAuthHeaders();
    return http.delete(
      Uri.parse('$baseUrl/messages/$messageId'),
      headers: headers,
    );
  }
}
