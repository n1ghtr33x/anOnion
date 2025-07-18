// lib/widgets/settings_list_item.dart
import 'package:flutter/material.dart';
import '../models/setting_item.dart';
import 'custom_list_item.dart'; // Импортируем наш универсальный виджет

class SettingsListItem extends StatelessWidget {
  final SettingItem item;

  const SettingsListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return CustomListItem(
      onTap: item.onTap,
      child: Row(
        children: [
          // Иконка
          Icon(item.icon, color: item.iconColor),
          const SizedBox(width: 16), // Пространство между иконкой и текстом
          // Заголовок
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 17,
                color: item.titleStyle ?? Colors.white,
              ),
            ),
          ),
          // Опциональный текст справа (например, "5" для устройств)
          if (item.trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                item.trailingText!,
                style: TextStyle(
                  fontSize: 16,
                  color: item.titleStyle ?? Colors.white, // Цвет для счетчика
                ),
              ),
            ),
          // Стрелка ">"
          if (item.arrow)
            Icon(
              Icons.keyboard_arrow_right,
              color: item.titleStyle ?? Colors.white,
            ),
          if (item.check)
            Icon(
              Icons.check,
              color: item.iconColor, // Цвет галочки
            ),
        ],
      ),
    );
  }
}
