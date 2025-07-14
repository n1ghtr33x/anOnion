import 'package:flutter/material.dart';
import 'package:flutter_messenger/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatefulWidget {
  final String content;
  final bool isMine;
  final String senderName;
  final bool edited;
  final void Function(Offset)? onLongPressWithPosition;
  final DateTime createdAt;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMine,
    required this.senderName,
    this.edited = false,
    this.onLongPressWithPosition,
    required this.createdAt,
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
          alignment: widget.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
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
                      color: customTheme.textPrimary,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
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
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: customTheme.textPrimary,
                    ),
                    children: [
                      TextSpan(text: '${widget.content} '),
                      const TextSpan(
                        text: '\u200A',
                      ), // немного пространства перед временем
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.edited) ...[
                              Icon(
                                Icons.edit,
                                size: 9,
                                color: customTheme.textSecondary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "изменено",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: customTheme.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              "${widget.createdAt.hour.toString().padLeft(2, '0')}:${widget.createdAt.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: 10,
                                color: customTheme.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
