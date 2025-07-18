// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
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

import '../../l10n/app_localizations.dart'; // импорт локализации

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
      for (var m in messages) {
        print('Msg id=${m.id} isPhoto=${m.isPhoto} imageUrl=${m.imageUrl}');
      }
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo, color: theme.sendButton),
                        onPressed: _sendImage,
                      ),
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
                              hintText: AppLocalizations.of(
                                context,
                              )!.chatMessage,
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
