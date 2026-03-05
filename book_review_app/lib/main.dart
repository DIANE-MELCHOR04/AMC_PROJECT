// This is the main entry point for the book review & recommendation app.
// It wires together services, theme management, and the core navigation.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'pages.dart';
import 'services.dart';
import 'theme_notifier.dart';

/// SharedPreferences key used to store the last selected theme.
const String _kThemeKey = 'selected_theme';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the last-selected theme from local storage, if any.
  final prefs = await SharedPreferences.getInstance();
  final savedThemeKey = prefs.getString(_kThemeKey);
  final initialTheme = themeTypeFromKey(savedThemeKey);

  runApp(
    MultiProvider(
      providers: [
        // Provides a simple ChangeNotifier to broadcast theme changes.
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(initialTheme),
        ),
        // Provides shared in-memory services for authentication, books, and social features.
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => BookService()),
        Provider(create: (_) => SocialService()),
        Provider.value(value: prefs),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget that reacts to theme changes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'Book Review & Recommendations',
      theme: themeNotifier.currentTheme,
      home: const RootSwitcher(),
    );
  }
}

/// Decides whether to show the authentication flow or the main home UI.
class RootSwitcher extends StatefulWidget {
  const RootSwitcher({super.key});

  @override
  State<RootSwitcher> createState() => _RootSwitcherState();
}

class _RootSwitcherState extends State<RootSwitcher> {
  AppUser? _user;

  /// Saves the selected theme key to disk and updates the user's profile.
  Future<void> _updateThemeForUser(
    AppUser user,
    AppThemeType type,
  ) async {
    final prefs = context.read<SharedPreferences>();
    final themeNotifier = context.read<ThemeNotifier>();
    final auth = context.read<AuthService>();

    // Update global theme.
    themeNotifier.setTheme(type);
    await prefs.setString(_kThemeKey, themeTypeToKey(type));

    // Persist inside the user profile in the in-memory auth service.
    final updated = user.copyWith(preferredTheme: type);
    auth.updateProfile(updated);

    setState(() {
      _user = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final bookService = context.read<BookService>();
    final socialService = context.read<SocialService>();

    if (_user == null) {
      // Show the login/sign-up screen when there is no authenticated user yet.
      return AuthPage(
        authService: auth,
        onAuthenticated: (user) async {
          // When a user logs in, apply their preferred theme if it differs.
          await _updateThemeForUser(user, user.preferredTheme);
        },
      );
    }

    // When authenticated, show the main home page with navigation.
    return HomePage(
      user: _user!,
      authService: auth,
      bookService: bookService,
      socialService: socialService,
      onLoggedOut: () {
        setState(() {
          _user = null;
        });
      },
    );
  }
}

