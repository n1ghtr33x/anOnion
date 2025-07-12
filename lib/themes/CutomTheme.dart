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
  });

  static CustomTheme dark() => CustomTheme(
        name: 'Тёмная',
        background: const Color(0xFF1C3144),
        textPrimary: Colors.white,
        textSecondary: Colors.grey,
        inputBackground: const Color(0xFF263645),
        bubbleMine: const Color(0xFF3A6073),
        bubleMineOther: const Color.fromARGB(255, 22, 8, 61),
        bubbleOther: const Color(0xFF2C5364),
        sendButton: const Color(0xFF5288C1),
      );

  static CustomTheme light() => CustomTheme(
        name: 'Светлая',
        background: Colors.white,
        textPrimary: Colors.black,
        textSecondary: Colors.grey.shade700,
        inputBackground: Colors.grey.shade200,
        bubbleMine: Colors.blue.shade100,
        bubleMineOther: const Color(0xFF3A6073),
        bubbleOther: Colors.grey.shade300,
        sendButton: Colors.blue,
      );
}
