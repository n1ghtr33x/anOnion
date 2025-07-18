import 'package:flutter/material.dart';
import '/../themes/theme_provider.dart';
import 'package:provider/provider.dart';

import 'full_screen_image_viewer.dart';

class MessageBubble extends StatefulWidget {
  final String content;
  final bool isMine;
  final String senderName;
  final bool edited;
  final bool isPhoto;
  final void Function(Offset)? onLongPressWithPosition;
  final String? imageUrl;
  final DateTime createdAt;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMine,
    required this.senderName,
    this.imageUrl,
    this.edited = false,
    this.isPhoto = false,
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

    final timeText =
        "${widget.createdAt.hour.toString().padLeft(2, '0')}:${widget.createdAt.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onLongPressStart: (details) {
        setState(() => _isPressed = true);
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
                padding: widget.isPhoto
                    ? const EdgeInsets.all(4)
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                child: widget.isPhoto && widget.imageUrl != null
                    ? _buildPhotoWithTextMessage(
                        widget.imageUrl!,
                        widget.content,
                        timeText,
                        customTheme,
                      )
                    : _buildTextMessage(widget.content, timeText, customTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoWithTextMessage(
    String imageUrl,
    String text,
    String timeText,
    dynamic theme,
  ) {
    final String baseUrl = 'http://109.173.168.29:8001';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FullScreenImageViewer(imageUrl: baseUrl + imageUrl),
                ),
              );
            },
            child: Image.network(
              baseUrl + imageUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),
        ),

        if (text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(text, style: TextStyle(fontSize: 16, color: theme.textPrimary)),
        ],
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.edited) ...[
              Icon(Icons.edit, size: 9, color: theme.textSecondary),
              const SizedBox(width: 4),
              Text(
                "изменено",
                style: TextStyle(fontSize: 9, color: theme.textSecondary),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              timeText,
              style: TextStyle(fontSize: 10, color: theme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextMessage(String text, String timeText, dynamic theme) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16, color: theme.textPrimary),
        children: [
          TextSpan(text: '$text '),
          const TextSpan(text: '\u200A'),
          WidgetSpan(
            alignment: PlaceholderAlignment.bottom,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.edited) ...[
                  Icon(Icons.edit, size: 9, color: theme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    "изменено",
                    style: TextStyle(fontSize: 9, color: theme.textSecondary),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  timeText,
                  style: TextStyle(fontSize: 10, color: theme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
