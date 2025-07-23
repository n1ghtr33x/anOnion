import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat.dart';
import '../../themes/theme_provider.dart';

class UserInfoScreen extends StatefulWidget {
  final User user;
  const UserInfoScreen({super.key, required this.user});

  @override
  State<UserInfoScreen> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfoScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Info',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 25,
            color: theme.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.background,
        foregroundColor: theme.textPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.sendButton, size: 28.0),
          onPressed: () => Navigator.pop(context),
          highlightColor: Colors.transparent, // Убираем подсветку
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent, // Убираем эффект "всплеска"
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: AlignmentDirectional.topStart,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: widget.user.photoUrl != null
                            ? NetworkImage(widget.user.photoUrl!)
                            : null,
                        backgroundColor: theme.sendButton,
                        child: widget.user.photoUrl == null
                            ? Text(
                                (widget.user.name ?? '?').isNotEmpty
                                    ? widget.user.name![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          widget.user.name ?? '?',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
