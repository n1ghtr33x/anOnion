import 'package:flutter/material.dart';
import 'package:flutter_messenger/themes/CutomTheme.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../themes/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    final provider = context.read<ThemeProvider>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appearanceTitle),
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.sendButton, size: 28.0),
          onPressed: () => Navigator.pop(context),
          highlightColor: Colors.transparent, // Убираем подсветку
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent, // Убираем эффект "всплеска"
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 28),
                SizedBox(
                  height: 200.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    physics: const BouncingScrollPhysics(),
                    children: provider.allThemes.map((item) {
                      return _chatImage(
                        context,
                        item.bubbleMine,
                        item.bubbleOther,
                        [
                          item.background.withOpacity(0.8),
                          item.chat_inputPanel_panelBg,
                        ],
                        item.name,
                        selected: item == theme,
                        tap: () => provider.setTheme(item),
                        theme: item,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _chatImage(
  BuildContext context,
  Color bubbleMine,
  Color bubbleOther,
  List<Color> background,
  String name, {
  required void Function() tap,
  required bool selected,
  required CustomTheme theme,
}) {
  return GestureDetector(
    onTap: tap,
    child: Container(
      width: 150.0,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [background[0], background[1]],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: selected ? Border.all(color: Colors.blue, width: 2.0) : null,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Верхняя часть (поле для сообщения)
          Container(
            height: 20.0,
            width: 80,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bubbleMine,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Container(
            height: 20.0,
            width: 50,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bubbleOther,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Container(
            height: 20.0,
            width: 30,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bubbleMine,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Container(
            height: 20.0,
            width: 120,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bubbleOther,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Container(
            height: 20.0,
            width: 100,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bubbleMine,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Container(
            height: 20.0,
            width: 70,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bubbleOther,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(name, style: TextStyle(color: theme.textPrimary)),
          ),
        ],
      ),
    ),
  );
}
