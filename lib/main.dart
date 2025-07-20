import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_messenger/scripts/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/../screens/auth/login_screen.dart';
import '/../screens/main_screen.dart';
import '/../themes/CutomTheme.dart';
import '/../themes/theme_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme') ?? 'Тёмная';
  final customThemes = [CustomTheme.dark(), 
  CustomTheme.light(), 
  CustomTheme.warm(),
  CustomTheme.crimson()];
  final initialTheme = customThemes.firstWhere(
    (theme) => theme.name == savedTheme,
    orElse: () => customThemes.first,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialTheme, customThemes),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
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
    return (token != null && token.isNotEmpty)
        ? const MainScreen()
        : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = context.watch<ThemeProvider>().theme;
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AnOnion',
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        scaffoldBackgroundColor: customTheme.background,
        useMaterial3: true,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: customTheme.textPrimary),
        ),
        iconTheme: IconThemeData(color: customTheme.textPrimary),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: FutureBuilder(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
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
