import 'package:flutter/material.dart';
import 'package:flutter_messenger/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatefulWidget {
  final String content;
  final bool isMine;
  final String senderName;
  final bool edited;
  final void Function(Offset)? onLongPressWithPosition;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMine,
    required this.senderName,
    this.edited = false,
    this.onLongPressWithPosition,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final customTheme = context.watch<ThemeProvider>().theme;

    return GestureDetector(
      onLongPressStart: (details) {
        setState(() {
          _isPressed = true;
        });
        widget.onLongPressWithPosition?.call(details.globalPosition);
      },
      onLongPressEnd: (_) => setState(() => _isPressed = false),
      onLongPressCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: widget.isMine ? 50 : 8,
            right: widget.isMine ? 8 : 50,
          ),
          alignment:
              widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: widget.isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!widget.isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      color: customTheme.textSecondary,
                    ),
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isMine
                      ? customTheme.bubbleMine
                      : customTheme.bubleMineOther,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(widget.isMine ? 16 : 0),
                    bottomRight: Radius.circular(widget.isMine ? 0 : 16),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content,
                      style: TextStyle(
                        color: customTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.edited)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit,
                                size: 12, color: customTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Изменено',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: customTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
