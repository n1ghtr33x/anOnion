import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/../screens/auth/login_screen.dart';
import '/../themes/CutomTheme.dart';
import '/../themes/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showCustomAboutDialog(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).theme;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          color: theme.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.message_rounded, size: 60, color: theme.sendButton),
              const SizedBox(height: 16),
              Text(
                "Flutter Messenger",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Версия 0.0.1\n\n"
                "\n"
                "Автор: dima_luts\n"
                "© 2025 Все права защищены.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: theme.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.sendButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text("Закрыть", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCard(
              theme,
              child: ListTile(
                leading: Icon(Icons.palette, color: theme.sendButton),
                title: Text(
                  "Выбор темы",
                  style: TextStyle(color: theme.textPrimary),
                ),
                subtitle: Text(
                  "Текущая: ${theme.name}",
                  style: TextStyle(color: theme.textSecondary),
                ),
                onTap: () => _showThemeDialog(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildCard(
              theme,
              child: ListTile(
                leading: Icon(Icons.logout, color: theme.sendButton),
                title: Text(
                  "Выйти из аккаунта",
                  style: TextStyle(color: theme.textPrimary),
                ),
                onTap: _logout,
              ),
            ),
            const SizedBox(height: 12),
            _buildCard(
              theme,
              child: ListTile(
                leading: Icon(Icons.info_outline, color: theme.sendButton),
                title: Text(
                  "О приложении",
                  style: TextStyle(color: theme.textPrimary),
                ),
                onTap: () => _showCustomAboutDialog(context),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: theme.background,
    );
  }

  Widget _buildCard(CustomTheme theme, {required Widget child}) {
    return Card(
      color: theme.inputBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: child,
    );
  }

  void _showThemeDialog(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    final theme = provider.theme;
    final allThemes = provider.allThemes;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Выберите тему',
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
}
