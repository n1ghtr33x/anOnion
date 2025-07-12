import 'package:flutter/material.dart';

class TelegramPopupMenu extends StatefulWidget {
  final Offset position;
  final List<TelegramPopupItem> items;
  final VoidCallback onDismiss;

  const TelegramPopupMenu({
    super.key,
    required this.position,
    required this.items,
    required this.onDismiss,
  });

  @override
  State<TelegramPopupMenu> createState() => _TelegramPopupMenuState();
}

class _TelegramPopupMenuState extends State<TelegramPopupMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;

    return Stack(
      children: [
        GestureDetector(
          onTap: _close,
          child: Container(
            color: Colors.black.withOpacity(0.15),
          ),
        ),
        Positioned(
          left: position.dx - 160,
          top: position.dy,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // стрелочка
                  Transform.translate(
                    offset: const Offset(140, 0),
                    child: CustomPaint(
                      painter: _ArrowPainter(),
                      child: const SizedBox(width: 20, height: 10),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 23, 33, 43),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((item) {
                        return InkWell(
                          onTap: () {
                            item.onTap();
                            _close();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.icon, size: 20),
                                const SizedBox(width: 8),
                                Text(item.label,
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TelegramPopupItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  TelegramPopupItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
