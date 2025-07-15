// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../widgets/telegram_popup_menu.dart';
import 'dart:async';

import '../../services/websocket_service.dart';
import '../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  final String chat_name;
  const ChatScreen({super.key, required this.chat, required this.chat_name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  int currentUserId = 1;
  List<Message> messages = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  late final WebSocketService _webSocketService;
  late final User otherUser;

  Timer? _timer;

  Future<void> _loadMessages() async {
    final res = await ApiService.getMessages(widget.chat.id);
    if (res.statusCode == 200) {
      final List jsonList = jsonDecode(res.body);
      if (!mounted) return;
      setState(() {
        messages = jsonList.map((m) => Message.fromJson(m)).toList();
        if (messages.isNotEmpty) {}
      });
      _scrollToBottom();
    }
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _loadCurrentUser() async {
    final res = await ApiService.getProfile();
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (!mounted) return;
      setState(() {
        currentUserId = json['id']; // или User.fromJson(json).id
      });
    } else {}
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    _webSocketService.sendMessage(currentUserId, content);
    _controller.clear();
    _focusNode
        .requestFocus(); // <-- вот тут возвращаем фокус обратно в TextField
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    otherUser = widget.chat.users.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => widget.chat.users.first,
    );
    _loadMessages().then((_) {
      _webSocketService = WebSocketService();
      _webSocketService.connect(widget.chat.id, (msg) {
        if (!mounted) return;

        setState(() {
          final index = messages.indexWhere((m) => m.id == msg.id);
          if (index != -1) {
            if (msg.deleted) {
              messages.removeAt(index);
            } else {
              messages[index] = msg;
            }
          } else {
            messages.add(msg);
          }
        });

        _scrollToBottom();
      });
    });
  }

  void _showEditMessageDialog(Message message) {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редактировать сообщение'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Введите новый текст'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _editMessage(message.id, controller.text);
              _loadMessages();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _editMessage(int messageId, String content) async {
    _webSocketService.editMessage(currentUserId, content, messageId);
    // final res = await ApiService.editMessage(messageId, content);
    // if (res.statusCode != 200) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Ошибка редактирования')));
    // }
  }

  Future<void> _deleteMessage(int messageId) async {
    _webSocketService.deleteMessage(currentUserId, messageId);
    // final res = await ApiService.deleteMessage(messageId);
    // if (res.statusCode == 200) {
    //   setState(() {
    //     messages.removeWhere((m) => m.id == messageId);
    //   });
    // } else {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text('Ошибка удаления')));
    // }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _removePopupMenu();
    super.dispose();
    _focusNode.dispose();
    _webSocketService.disconnect();
  }

  void _showPopupMenu(Message message, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => TelegramPopupMenu(
        position: position,
        onDismiss: () => entry.remove(),
        items: [
          TelegramPopupItem(
            icon: Icons.edit,
            label: 'Редактировать',
            onTap: () => _showEditMessageDialog(message),
          ),
          TelegramPopupItem(
            icon: Icons.delete,
            label: 'Удалить',
            onTap: () => _deleteMessage(message.id),
          ),
        ],
      ),
    );

    overlay.insert(entry);
  }

  void _removePopupMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: otherUser.photoUrl != null
                  ? NetworkImage(otherUser.photoUrl!)
                  : null,
              backgroundColor: theme.sendButton,
              child: otherUser.photoUrl == null
                  ? Text(
                      (otherUser.name ?? '?').isNotEmpty
                          ? otherUser.name![0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.chat_name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Фон
          Positioned.fill(
            child: Image.asset(theme.chatBackgroundPath, fit: BoxFit.cover),
          ),

          // Затемнение (опционально, можно убрать)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.03)),
          ),

          // Основной контент
          Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  children: messages
                      .where((m) => !m.deleted)
                      .map(
                        (m) => MessageBubble(
                          content: m.content ?? '',
                          isMine: m.userId == currentUserId,
                          senderName: m.sender.name,
                          edited: m.edited,
                          createdAt: m.createdAt,
                          onLongPressWithPosition: m.userId == currentUserId
                              ? (pos) => _showPopupMenu(m, pos)
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
              Container(
                color: theme.chat_inputPanel_panelBg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.inputBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 15,
                              color: theme.textPrimary,
                            ),
                            controller: _controller,
                            focusNode: _focusNode,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'Сообщение',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: theme.textSecondary,
                              ),
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.send, color: theme.sendButton),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
