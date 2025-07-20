import 'dart:convert';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '/../screens/chat/chat_list_screen.dart';
import '/../screens/settings/settings_screen.dart';
import '/../themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  String? _avatarUrl;
  String username = '';

  final List<Widget> _screens = [
    const ChatListScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getProfile();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          _avatarUrl = data['photo_url'];
          username = data['username'] ?? '';
        });
      }
    } catch (e) {
      // ignore errors
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Плавный переход на нужную страницу
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: SizedBox(
        height: 65,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: theme.sendButton,
          unselectedItemColor: theme.textSecondary,
          backgroundColor: theme.inputBackground,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          onTap: _onTap,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: AppLocalizations.of(context)!.mainChats,
            ),
            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: _currentIndex == 1
                      ? Border.all(color: theme.sendButton, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.sendButton,
                  backgroundImage: _avatarUrl != null
                      ? NetworkImage('http://109.173.168.29:8001$_avatarUrl')
                      : null,
                  child: (_avatarUrl == null)
                      ? Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.intro_buttonText,
                          ),
                        )
                      : null,
                ),
              ),
              label: AppLocalizations.of(context)!.mainSettings,
            ),
          ],
        ),
      ),
      backgroundColor: theme.background,
    );
  }
}
