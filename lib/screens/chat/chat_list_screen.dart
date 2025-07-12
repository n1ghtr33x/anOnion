import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/models/chat.dart';
import 'package:flutter_messenger/screens/chat/chat_screen.dart';
import 'package:flutter_messenger/services/api_service.dart';
import 'package:flutter_messenger/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Chat> chats = [];
  Timer? _timer;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadChats();
    _startChatPolling();
  }

  void _startChatPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkNewChats();
    });
  }

  Future<void> _loadCurrentUserId() async {
    final response = await ApiService.getProfile();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final int id = data['id'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', id);
      if (!mounted) return;
      setState(() {
        currentUserId = id;
      });
    } else {
      debugPrint('Ошибка получения профиля: ${response.statusCode}');
    }
  }

  Future<void> _checkNewChats() async {
    final response = await ApiService.getChats();
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final List<Chat> fetchedChats = data
          .map((json) => Chat.fromJson(json))
          .toList();

      final newChats = fetchedChats
          .where(
            (fetchedChat) =>
                !chats.any((existingChat) => existingChat.id == fetchedChat.id),
          )
          .toList();

      if (newChats.isNotEmpty) {
        setState(() {
          chats.addAll(newChats);
        });
      }
    }
  }

  Future<void> _loadChats() async {
    try {
      final response = await ApiService.getChats();
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          chats = data.map((json) => Chat.fromJson(json)).toList();
        });
      }
    } catch (_) {}
  }

  void _showCreateChatDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final theme = context.read<ThemeProvider>().theme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Создать чат по username'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Введите username',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              if (username.isEmpty) return;
              Navigator.of(ctx).pop();

              final response = await ApiService.createPrivateChat(username);
              if (!mounted) return;

              if (response.statusCode == 200 || response.statusCode == 201) {
                final chatJson = jsonDecode(response.body);
                final newChat = Chat.fromJson(chatJson);

                final otherUser = newChat.users.firstWhere(
                  (user) => user.id != currentUserId,
                  orElse: () => newChat.users.isNotEmpty
                      ? newChat.users.first
                      : User(id: 0, name: '?'),
                );

                final displayName = otherUser.name ?? otherUser.name;
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chat: newChat,
                        chat_name: displayName ?? 'Неизвестно..',
                      ),
                    ),
                  );
                }

                _loadChats();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ошибка создания чата: ${response.statusCode}',
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.sendButton,
              foregroundColor: Colors.white,
            ),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.sendButton),
            tooltip: 'Создать чат',
            onPressed: () => _showCreateChatDialog(context),
          ),
        ],
      ),
      backgroundColor: theme.background,
      body: chats.isEmpty
          ? Center(
              child: Text(
                'Пока нет чатов',
                style: TextStyle(color: theme.textSecondary, fontSize: 16),
              ),
            )
          : ListView.separated(
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: theme.textSecondary.withOpacity(0.2),
              ),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];

                final otherUser = chat.users.firstWhere(
                  (user) => user.id != currentUserId,
                  orElse: () => chat.users.isNotEmpty
                      ? chat.users.first
                      : User(id: 0, name: '?'),
                );

                final displayName = otherUser.name ?? otherUser.name;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.sendButton,
                    child: Text(
                      displayName!.isNotEmpty
                          ? displayName.toUpperCase()[0]
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: chat.lastMessage != null
                      ? Text(
                          chat.lastMessage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 14,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(chat: chat, chat_name: displayName),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
