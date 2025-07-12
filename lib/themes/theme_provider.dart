import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/../themes/CutomTheme.dart';

class ThemeProvider with ChangeNotifier {
  CustomTheme _theme;
  final List<CustomTheme> allThemes;

  ThemeProvider(this._theme, this.allThemes);

  CustomTheme get theme => _theme;

  void setTheme(CustomTheme newTheme) async {
    _theme = newTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', newTheme.name);
    notifyListeners();
  }
}
