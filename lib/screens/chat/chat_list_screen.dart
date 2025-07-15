import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/websocket_service.dart';
import '/../models/chat.dart';
import '/../models/message.dart';
import '/../screens/chat/chat_screen.dart';
import '/../services/api_service.dart';
import '/../themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  List<Chat> chats = [];
  List<Message> messages = [];
  int? currentUserId;
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  String _searchQuery = '';

  late final WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {});
      if (!_focusNode.hasFocus) {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
        });
      }
    });

    _loadInitialData();

    _webSocketService = WebSocketService();

    _webSocketService.connect(
      0,
      (Message msg) {
        // Здесь можно оставить пустым
      },
      onNewChat: (Chat newChat) {
        setState(() {
          if (!chats.any((c) => c.id == newChat.id)) {
            chats.add(newChat);
            _sortChatsByLastMessage();
          }
        });
      },
    );

    // 📌 Слушай обновления чатов по WebSocket
    _webSocketService.listenChatUpdates((Chat updatedChat) {
      setState(() {
        final index = chats.indexWhere((c) => c.id == updatedChat.id);
        if (index != -1) {
          chats[index] = updatedChat;
          _loadLatestMessages();
        } else {
          chats.add(updatedChat);
          _loadLatestMessages();
        }
        _sortChatsByLastMessage();
      });
    });
  }

  void _sortChatsByLastMessage() {
    chats.sort((a, b) {
      final aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
  }

  Future<void> _loadInitialData() async {
    await _loadCachedLastMessages();
    await _loadCurrentUserId();
    await _loadChats();
    await _loadLatestMessages();
  }

  Future<void> _loadCachedLastMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('last_messages');
    if (jsonString == null) return;

    final Map<String, dynamic> cached = jsonDecode(jsonString);
    for (var chat in chats) {
      final cachedData = cached[chat.id.toString()];
      if (cachedData != null) {
        chat.lastMessage = cachedData['content'];
        chat.lastSenderName = cachedData['senderName'];
        chat.lastMessageTime = DateTime.tryParse(cachedData['createdAt'] ?? '');
      }
    }
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

  Future<void> _loadLatestMessages() async {
    try {
      final responses = await Future.wait(
        chats.map((chat) async {
          try {
            final response = await ApiService.getMessages(chat.id);
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);

              // data — это список сообщений
              final messages = (data as List)
                  .map((j) => Message.fromJson(j))
                  .toList();

              if (messages.isNotEmpty) {
                final latest = messages.last;

                return {'chatId': chat.id, 'message': latest};
              }
            }
          } catch (_) {}
          return null;
        }),
      );

      if (!mounted) return;

      setState(() {
        for (var result in responses.whereType<Map>()) {
          final chat = chats.firstWhere((c) => c.id == result['chatId']);
          final message = result['message'] as Message;
          chat.lastMessage = message.content;
          chat.lastMessageTime = message.createdAt;
        }

        chats.sort((a, b) {
          final aTime =
              a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime =
              b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
      });
    } catch (e) {
      debugPrint('❌ Ошибка при загрузке сообщений: $e');
    }
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.day}.${time.month}.${time.year}";
    }
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    final filteredChats = chats.where((chat) {
      final otherUser = chat.users.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () =>
            chat.users.isNotEmpty ? chat.users.first : User(id: 0, name: '?'),
      );
      final name = otherUser.name?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.sendButton),
            tooltip: 'Создать чат',
            onPressed: () => _showCreateChatDialog(context),
          ),
        ],
      ),
      backgroundColor: theme.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 48,
              child: Stack(
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.chat_inputPanel_panelBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: theme.textPrimary),
                  ),

                  // Иконка — лежит НАД TextField
                  Positioned.fill(
                    child: IgnorePointer(
                      // не перехватывает клики
                      child: AnimatedAlign(
                        alignment: _focusNode.hasFocus
                            ? Alignment.centerLeft
                            : Alignment.center,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.search,
                            color: theme.sendButton,
                          ), // Красная, чтобы ты её точно увидел
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: filteredChats.isEmpty
                ? Center(
                    child: Text(
                      'Пока нет чатов',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.textSecondary.withOpacity(0.2),
                    ),
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = filteredChats[index];

                      final otherUser = chat.users.firstWhere(
                        (user) => user.id != currentUserId,
                        orElse: () => chat.users.isNotEmpty
                            ? chat.users.first
                            : User(id: 0, name: '?'),
                      );

                      final displayName = otherUser.name ?? '?';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading:
                            otherUser.photoUrl != null &&
                                otherUser.photoUrl!.isNotEmpty
                            ? CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  otherUser.photoUrl!,
                                ),
                                backgroundColor: Colors.transparent,
                              )
                            : CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.sendButton,
                                child: Text(
                                  displayName.isNotEmpty
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
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.lastMessage!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: theme.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (chat.lastMessageTime != null)
                                    Text(
                                      _formatTime(chat.lastMessageTime!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textSecondary.withOpacity(
                                          0.6,
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chat: chat,
                                chat_name: displayName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
