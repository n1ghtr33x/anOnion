// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/cashe_service.dart';
import '/../scripts/send_photo.dart';
import '/../themes/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../widgets/telegram_popup_menu.dart';
import 'dart:async';

import '../../services/websocket_service.dart';
import '../../widgets/message_bubble.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../l10n/app_localizations.dart';
import 'user_info_screen.dart'; // импорт локализации

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
    try {
      final res = await ApiService.getMessages(widget.chat.id);
      if (res.statusCode == 200) {
        final List jsonList = jsonDecode(res.body);
        final fetchedMessages = jsonList
            .map((m) => Message.fromJson(m))
            .toList();

        if (!mounted) return;

        setState(() {
          messages = fetchedMessages;
        });

        // Сохраняем сообщения в кеш
        await CacheService.saveMessages(widget.chat.id, fetchedMessages);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки сообщений с сервера: $e');

      // При ошибке — загружаем из кеша
      final cachedMessages = await CacheService.loadMessages(widget.chat.id);
      if (!mounted) return;
      setState(() {
        messages = cachedMessages;
      });
    }

    _scrollToBottom();
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

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    await showSendPhotoWithTextDialog(
      context,
      photoFile: file,
      onSend: (text) async {
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

        _webSocketService.sendImageWithText(
          userId: currentUserId,
          base64Image: base64Image,
          mimeType: mimeType,
          text: text.trim(),
        );
      },
    );
  }

  void _loadCurrentUser() async {
    final res = await ApiService.getProfile();
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (!mounted) return;
      setState(() {
        currentUserId = json['id'];
      });
    }
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    _webSocketService.sendMessage(currentUserId, content);
    _controller.clear();
    _focusNode.requestFocus();
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
        title: Text(AppLocalizations.of(context)!.chatEditMessage),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.chatNewText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.chatCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _editMessage(message.id, controller.text);
              _loadMessages();
            },
            child: Text(AppLocalizations.of(context)!.chatSave),
          ),
        ],
      ),
    );
  }

  Future<void> _editMessage(int messageId, String content) async {
    _webSocketService.editMessage(currentUserId, content, messageId);
  }

  Future<void> _deleteMessage(int messageId) async {
    _webSocketService.deleteMessage(currentUserId, messageId);
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
            label: AppLocalizations.of(context)!.chatEdit,
            onTap: () => _showEditMessageDialog(message),
          ),
          TelegramPopupItem(
            icon: Icons.delete,
            label: AppLocalizations.of(context)!.chatDelete,
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserInfoScreen(user: otherUser),
              ),
            );
          },
          child: Container(
            color: theme.background,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Центр
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Text(
                      widget.chat_name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Назад
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: theme.sendButton,
                          size: 28.0,
                        ),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: theme.sendButton,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Аватар
                Align(
                  alignment: Alignment.centerRight,
                  child: CircleAvatar(
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(theme.chatBackgroundPath, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.03)),
          ),
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
                          isPhoto: m.isPhoto,
                          imageUrl: m.imageUrl,
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
                constraints: const BoxConstraints(
                  minHeight: 60,
                  maxHeight: 120,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo, color: theme.sendButton),
                        onPressed: _sendImage,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.inputBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textPrimary,
                            ),
                            controller: _controller,
                            focusNode: _focusNode,
                            cursorColor: theme.textPrimary,
                            textAlignVertical: TextAlignVertical.center,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.chatMessage,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: theme.textSecondary,
                              ),
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
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
