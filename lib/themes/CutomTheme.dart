import 'package:flutter/material.dart';

class CustomTheme {
  final String name;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color inputBackground;
  final Color bubbleMine;
  final Color bubbleOther;
  final Color sendButton;
  final Color bubleMineOther;
  final Color chat_inputPanel_panelBg;
  final Color intro_statusBar;
  final Color errorAccent;
  final Color intro_primaryText;
  final Color intro_accentText;
  final Color intro_buttonText;
  final String chatBackgroundPath;
  final Color settingsListItemBackground;

  CustomTheme({
    required this.name,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.inputBackground,
    required this.bubbleMine,
    required this.bubbleOther,
    required this.sendButton,
    required this.bubleMineOther,
    required this.chat_inputPanel_panelBg,
    required this.errorAccent,
    required this.chatBackgroundPath,
    required this.intro_statusBar,
    required this.intro_primaryText,
    required this.intro_accentText,
    required this.intro_buttonText,
    required this.settingsListItemBackground,
  });

  static CustomTheme dark() => CustomTheme(
    name: 'Тёмная',
    background: const Color(0xFF18222D),
    textPrimary: const Color(0xFFFFFFFF),
    textSecondary: const Color.fromARGB(255, 175, 175, 175),
    inputBackground: const Color(0xFF131C26),
    bubbleMine: const Color(0xFF5D7F93),
    bubbleOther: const Color(0xFF21303F),
    bubleMineOther: const Color(0xFF2D3B49),
    sendButton: const Color(0xFF2EA5FF),
    chat_inputPanel_panelBg: const Color(0xFF21303F),
    errorAccent: Colors.redAccent,
    chatBackgroundPath: 'assets/dark_wallpaper.png',
    intro_statusBar: const Color(0xFFFFFFFF),
    intro_primaryText: const Color(0xFFFFFFFF),
    intro_buttonText: const Color(0xFFFFFFFF),
    intro_accentText: const Color(0xFF2EA5FF),
    settingsListItemBackground: const Color.fromARGB(255, 25, 36, 49),
  );

  static CustomTheme light() => CustomTheme(
    name: 'Светлая',
    background: const Color(0xFFF1F1F1),
    textPrimary: const Color(0xFF000000),
    textSecondary: const Color(0x8A525252),
    inputBackground: const Color(0xFFFFFFFF),
    bubbleMine: const Color(0xFFE1FFC7),
    bubbleOther: const Color(0xFFFFFFFF),
    bubleMineOther: const Color(0xFFD9F4FF),
    sendButton: const Color(0xFF007AFF),
    chat_inputPanel_panelBg: const Color(0xF2F2F2E5),
    errorAccent: Colors.redAccent,
    chatBackgroundPath: 'assets/white_wallpaper.png',
    intro_statusBar: const Color(0xFF000000),
    intro_primaryText: const Color(0xFF000000),
    intro_buttonText: const Color(0xFFFFFFFF),
    intro_accentText: const Color(0xFF2EA5FF),
    settingsListItemBackground: Colors.white,
  );

  static CustomTheme warm() => CustomTheme(
    name: 'Теплая',
    background: const Color(0xFFF5E8D3),
    textPrimary: const Color(0xFF3C2F2F),
    textSecondary: const Color(0x8A6B4E31),
    inputBackground: const Color(0xFFFDFAF6),
    bubbleMine: const Color(0xFFFFDAB9),
    bubbleOther: const Color(0xFFF0E6DC),
    bubleMineOther: const Color(0xFFE8C4A0),
    sendButton: const Color(0xFFFF8C42),
    chat_inputPanel_panelBg: const Color(0xFFEDE0D4),
    errorAccent: Colors.redAccent,
    chatBackgroundPath: 'assets/warm_wallpaper.png',
    intro_statusBar: const Color(0xFF3C2F2F),
    intro_primaryText: const Color(0xFF3C2F2F),
    intro_buttonText: const Color(0xFFFFFFFF),
    intro_accentText: const Color(0xFFFF8C42),
    settingsListItemBackground: const Color(0xFFF9F1E7),
  );

  static CustomTheme crimson() => CustomTheme(
    name: 'Бордовый',
    background: const Color(0xFF2C1F2A),
    textPrimary: const Color(0xFFD8A7B1),
    textSecondary: const Color(0x8A9B6F7A),
    inputBackground: const Color(0xFF3A2C36),
    bubbleMine: const Color(0xFF7A4A52),
    bubbleOther: const Color(0xFF9B5F67), 
    bubleMineOther: const Color(0xFF3A2C36),
    sendButton: const Color(0xFFC0392B),
    chat_inputPanel_panelBg: const Color(0xFF2F2430),
    errorAccent: Colors.redAccent,
    chatBackgroundPath: 'assets/crimson_wallpaper.png',
    intro_statusBar: const Color(0xFFD8A7B1),
    intro_primaryText: const Color(0xFFD8A7B1),
    intro_buttonText: const Color(0xFFFFFFFF),
    intro_accentText: const Color(0xFFC0392B),
    settingsListItemBackground: const Color(0xFF362A34),
  );
}
