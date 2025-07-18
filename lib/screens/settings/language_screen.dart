import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/setting_item.dart';
import '../../scripts/locale_provider.dart';
import '../../themes/theme_provider.dart';
import '../../widgets/settings_list_item.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    final loc = AppLocalizations.of(context)!;

    final List<SettingItem> group1 = [
      SettingItem(
        icon: Icons.language,
        iconColor: theme.sendButton, // Цвет иконки как на фото
        title: 'English',
        titleStyle: theme.textPrimary,
        onTap: () {
          context.read<LocaleProvider>().setLocale(Locale('en'));
        },
        arrow: false,
        check: context.read<LocaleProvider>().locale.languageCode == 'en'
            ? true
            : false,
      ),
      SettingItem(
        icon: Icons.language,
        iconColor: theme.sendButton, // Цвет иконки как на фото
        title: 'Russian',
        titleStyle: theme.textPrimary,
        onTap: () {
          context.read<LocaleProvider>().setLocale(Locale('ru'));
        },
        arrow: false,
        check: context.read<LocaleProvider>().locale.languageCode == 'ru'
            ? true
            : false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.languageTitle),
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    loc.settingsLanguage,
                    style: TextStyle(fontSize: 10, color: theme.textPrimary),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingsGroup(context, group1, theme),
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
