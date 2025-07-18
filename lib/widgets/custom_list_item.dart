// lib/widgets/custom_list_item.dart
import 'package:flutter/material.dart';

class CustomListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CustomListItem({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ), // Немного увеличим отступы для настроек
        child: child,
      ),
    );
  }
}
