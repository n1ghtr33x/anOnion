import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/services/api_service.dart';
import 'package:flutter_messenger/themes/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  String name = '';
  String status = '';
  File? _avatarFile;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getProfile();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          username = data['username'] ?? '';
          email = data['email'] ?? '';
          name = data['name'] ?? '';
          status = data['status'] ?? '';
          _avatarUrl = data['photo_url'];
          _nameController.text = name;
        });
      }
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == name) {
      setState(() {
        _isEditingName = false;
      });
      return;
    }

    // Здесь вызови ApiService для обновления имени, если есть такой метод
    // await ApiService.updateProfile({"name": newName});

    setState(() {
      name = newName;
      _isEditingName = false;
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return; // отмена

      setState(() {
        _avatarFile = File(pickedFile.path);
      });

      final res = await ApiService.uploadAvatar(_avatarFile!);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _avatarUrl =
              data['url']; // ссылка на сервере, например "/avatars/uuid.jpg"
        });
        // Можно сразу обновить профиль в ApiService, если есть метод
      } else {
        // Ошибка загрузки
        debugPrint("Ошибка загрузки аватара: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Ошибка выбора/загрузки аватара: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text("Профиль"),
        backgroundColor: theme.inputBackground,
        foregroundColor: theme.textPrimary,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadAvatar,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.sendButton,
                  backgroundImage: _avatarFile != null
                      ? FileImage(_avatarFile!)
                      : (_avatarUrl != null
                            ? NetworkImage(
                                    'http://109.173.168.29:8001$_avatarUrl',
                                  )
                                  as ImageProvider
                            : null),
                  child: (_avatarFile == null && _avatarUrl == null)
                      ? Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 48,
                            color: theme.intro_buttonText,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Имя (редактируемое)
              _isEditingName
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _nameController,
                            autofocus: true,
                            style: TextStyle(color: theme.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Введите имя',
                              hintStyle: TextStyle(color: theme.textSecondary),
                            ),
                            onSubmitted: (_) => _saveName(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: _saveName,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _isEditingName = false;
                              _nameController.text = name;
                            });
                          },
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _isEditingName = true),
                      child: Text(
                        name.isNotEmpty ? name : 'Нет имени',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),

              const SizedBox(height: 8),

              // Username
              Text(
                '@$username',
                style: TextStyle(fontSize: 16, color: theme.textSecondary),
              ),

              const SizedBox(height: 24),

              // Статус
              if (status.isNotEmpty)
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    color: theme.textSecondary,
                  ),
                ),

              const SizedBox(height: 32),

              // Email
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
