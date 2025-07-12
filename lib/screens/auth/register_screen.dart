import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/main_screen.dart';
import 'package:flutter_messenger/services/api_service.dart';
import 'package:provider/provider.dart';

import '../../themes/theme_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  void _register() async {
    final email = _email.text.trim();
    final username = _username.text.trim();
    final name = _name.text.trim();
    final password = _password.text;

    final response = await ApiService.register({
      "email": email,
      "username": username,
      "name": name,
      "password": password,
    });

    if (!mounted) return;

    if (response.statusCode == 200) {
      // Автоматический вход после регистрации
      final loginResponse = await ApiService.login(username, password);

      if (loginResponse.statusCode == 200) {
        if (!mounted) return;
        _login();
      } else {
        setState(() => _error = "Регистрация прошла, но вход не удался");
      }
    } else {
      setState(() => _error = "Ошибка регистрации");
    }
  }

  void _login() async {
    try {
      final res = await ApiService.login(
        _username.text,
        _password.text,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Icon(
                Icons.person_add_alt,
                size: 80,
                color: theme.sendButton,
              ),
              const SizedBox(height: 24),
              Text(
                "Создание аккаунта",
                textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.errorAccent,
                    ),
                  ),
                ),
              _buildTextField(_email, "Email"),
              const SizedBox(height: 12),
              _buildTextField(_username, "Логин"),
              const SizedBox(height: 12),
              _buildTextField(_name, "Имя"),
              const SizedBox(height: 12),
              _buildTextField(_password, "Пароль", obscure: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: theme.intro_accentText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Зарегистрироваться",
                  style: TextStyle(color: theme.intro_buttonText),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Уже есть аккаунт? Войти",
                  style: TextStyle(color: theme.intro_primaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    final theme = context.watch<ThemeProvider>().theme;

    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.bubbleOther,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(color: theme.textSecondary)
      ),
    );
  }
}
