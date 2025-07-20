import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/settings/theme_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/setting_item.dart';
import '../../services/api_service.dart';
import '../../widgets/settings_list_item.dart';
import '/../screens/auth/login_screen.dart';
import '/../themes/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import 'language_screen.dart'; // импорт локализации

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username = '';
  String name = '';
  String? _avatarUrl;
  bool _expanded = false;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getProfile();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          username = data['username'] ?? '';
          name = data['name'] ?? '';
          _avatarUrl = data['photo_url'];
        });
      }
    } catch (e) {
      // Игнорируем ошибки загрузки
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    final loc = AppLocalizations.of(context)!;

    final double collapsedSize = 120;
    final double expandedSize = MediaQuery.of(context).size.height * 0.5;

    final List<SettingItem> group1 = [
      SettingItem(
        icon: Icons.palette,
        iconColor: theme.sendButton, // Цвет иконки как на фото
        title: loc.appearanceTitle,
        titleStyle: theme.textPrimary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThemeScreen()),
          );
        },
      ),
      SettingItem(
        icon: Icons.language,
        iconColor: Colors.purpleAccent,
        title: loc.languageTitle,
        titleStyle: theme.textPrimary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LanguageScreen()),
          );
        },
      ),
      SettingItem(
        icon: Icons.info_outline,
        iconColor: theme.sendButton, // Цвет иконки как на фото
        title: loc.settingsAboutApp,
        titleStyle: theme.textPrimary,
        onTap: () => _showCustomAboutDialog(context),
      ),
      SettingItem(
        icon: Icons.logout,
        iconColor: theme.errorAccent, // Цвет иконки как на фото
        title: loc.settingsLogout,
        titleStyle: theme.textPrimary,
        onTap: () => _logout(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle),
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Изм.', style: TextStyle(color: theme.sendButton)),
          ),
        ],
      ),
      backgroundColor: theme.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                GestureDetector(
                  onTap: _toggleExpand,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: _expanded ? expandedSize : collapsedSize,
                    height: _expanded ? expandedSize : collapsedSize,
                    margin: EdgeInsets.only(
                      top: 20,
                      bottom: _expanded ? 20 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.sendButton,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(
                        _expanded ? 20 : collapsedSize / 2,
                      ),
                      image: _avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(
                                'http://109.173.168.29:8001$_avatarUrl',
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (_avatarUrl == null)
                          Center(
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: _expanded ? 64 : 32,
                                color: theme.intro_buttonText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          bottom: _expanded ? 20 : 10,
                          left: _expanded ? 20 : 0,
                          right: _expanded ? null : 0,
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 400),
                            alignment: _expanded
                                ? Alignment.bottomLeft
                                : Alignment.center,
                            child: Text(
                              name.isNotEmpty ? name : username,
                              style: TextStyle(
                                fontSize: _expanded ? 28 : 22,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                _buildSettingsGroup(context, group1, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    List<SettingItem> items,
    theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.settingsListItemBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              SettingsListItem(item: item),
              if (item != items.last)
                Divider(
                  height: 1,
                  color: theme.textPrimary.withOpacity(0.2),
                  indent: 60,
                  endIndent: 0,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showCustomAboutDialog(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).theme;
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) => Dialog(
        backgroundColor: theme.inputBackground.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.message_rounded, size: 48, color: theme.sendButton),
              const SizedBox(height: 12),
              Text(
                "anOnion",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loc.settingsAppVersion,
                style: TextStyle(fontSize: 14, color: theme.textSecondary),
              ),
              const SizedBox(height: 12),
              Divider(color: theme.textSecondary.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text(
                loc.settingsAppAuthor,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: theme.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.sendButton.withOpacity(0.1),
                    foregroundColor: theme.sendButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    loc.settingsClose,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
