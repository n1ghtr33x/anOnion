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
    background: const Color(0xFF18222D), // chatList_bg
    textPrimary: const Color(0xFFFFFFFF), // list_primaryText
    textSecondary: const Color.fromARGB(
      255,
      175,
      175,
      175,
    ),
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
    settingsListItemBackground: const Color.fromARGB(
      255,
      25,
      36,
      49,
    ),
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
}
