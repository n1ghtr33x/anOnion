import 'package:flutter/material.dart';

class SettingItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleStyle;
  final String?
  trailingText; // Опциональный текст справа (например, счетчик "5")
  final VoidCallback? onTap;
  final bool arrow;
  final bool check;

  SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleStyle,
    this.trailingText,
    this.onTap,
    this.arrow = true,
    this.check = false,
  });
}
