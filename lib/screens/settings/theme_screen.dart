import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/setting_item.dart';
import '../../themes/theme_provider.dart';
import '../../widgets/settings_list_item.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    final loc = AppLocalizations.of(context)!;

    final List<SettingItem> group1 = [
      SettingItem(
        icon: Icons.palette,
        iconColor: theme.sendButton, // Цвет иконки как на фото
        title: loc.settingsThemeChoice,
        titleStyle: theme.textPrimary,
        trailingText: '${loc.settingsCurrent}: ${theme.name}',
        onTap: () => _showThemeDialog(context),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appearanceTitle),
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 24),
                _buildSettingsGroup(context, group1, theme),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSettingsGroup(
  BuildContext context,
  List<SettingItem> items,
  theme,
) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16.0), // Отступы по бокам
    decoration: BoxDecoration(
      color: theme.settingsListItemBackground, // Темный фон для группы
      borderRadius: BorderRadius.circular(
        10,
      ), // Скругленные углы для всей группы
    ),
    child: Column(
      children: items.map((item) {
        // Для каждого элемента создаем SettingsListItem
        // И добавляем Divider между элементами, кроме последнего
        return Column(
          children: [
            SettingsListItem(item: item),
            if (item !=
                items
                    .last) // Если это не последний элемент в группе, добавляем разделитель
              Divider(
                height: 1,
                color: theme.textPrimary.withOpacity(0.2),
                indent: 60, // Отступ слева (ширина иконки + пробел)
                endIndent: 0,
              ),
          ],
        );
      }).toList(),
    ),
  );
}

void _showThemeDialog(BuildContext context) {
  final provider = context.read<ThemeProvider>();
  final theme = provider.theme;
  final allThemes = provider.allThemes;
  final loc = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        loc.settingsChooseTheme, // "Выберите тему"
        style: TextStyle(color: theme.textPrimary),
      ),
      backgroundColor: theme.background,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: allThemes.map((t) {
          return RadioListTile(
            title: Text(t.name, style: TextStyle(color: theme.textPrimary)),
            value: t.name,
            groupValue: theme.name,
            onChanged: (_) {
              provider.setTheme(t);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    ),
  );
}
