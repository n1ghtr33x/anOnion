import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '/../screens/auth/login_screen.dart';
import '/../screens/main_screen.dart';
import '/../themes/CutomTheme.dart';
import '/../themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme') ?? 'Тёмная';

  // Пример твоего списка тем
  final customThemes = [
    CustomTheme.dark(),
    CustomTheme.light(),
  ];

  final initialTheme = customThemes.firstWhere(
    (theme) => theme.name == savedTheme,
    orElse: () => customThemes.first,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialTheme, customThemes),
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = context.watch<ThemeProvider>().theme;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: customTheme.background,
        useMaterial3: true,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: customTheme.textPrimary),
        ),
        iconTheme: IconThemeData(color: customTheme.textPrimary),
      ),
      home: FutureBuilder(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
            return snapshot.data as Widget;
          } else {
            return const MainScreen();
          }
        },
      ),
    );
  }
}
