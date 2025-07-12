import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/auth/register_screen.dart';
import 'package:flutter_messenger/screens/main_screen.dart';
import 'package:flutter_messenger/services/api_service.dart';
import 'package:provider/provider.dart';

import '../../themes/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? _error;

  void _login() async {
    try {
      final res = await ApiService.login(
        _userController.text,
        _passController.text,
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        setState(() => _error = "Неверный логин или пароль");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Ошибка подключения: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: theme.intro_accentText,
              ),
              const SizedBox(height: 24),
              Text(
                "Вход в аккаунт",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: theme.errorAccent,
                    ),
                  ),
                ),
              TextField(
                controller: _userController,
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Логин',
                  filled: true,
                  fillColor: theme.bubbleOther,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(color: theme.textSecondary)
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  filled: true,
                  fillColor: theme.bubbleOther,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(color: theme.textSecondary)
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: theme.intro_accentText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Войти",
                    style: TextStyle(
                      color: theme.intro_buttonText,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Text(
                  "Регистрация",
                  style: TextStyle(
                    color: theme.intro_primaryText,
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
