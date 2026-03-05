// This file defines all visual themes used in the app
// and exposes helpers to convert between the enum and ThemeData.

import 'package:flutter/material.dart';

import 'models.dart';

/// Map linking each [AppThemeType] to a concrete [ThemeData] instance.
final Map<AppThemeType, ThemeData> appThemes = {
  AppThemeType.light: _buildModernTheme(Colors.blueGrey, Brightness.light),
  AppThemeType.dark: _buildModernTheme(Colors.deepPurple, Brightness.dark),
  AppThemeType.ocean: _buildModernTheme(Colors.blue, Brightness.light),
  AppThemeType.forest: _buildModernTheme(Colors.green, Brightness.light),
  AppThemeType.sunset: _buildModernTheme(Colors.deepOrange, Brightness.light),
  AppThemeType.lavender: _buildModernTheme(const Color(0xFF9C27B0), Brightness.light),
  AppThemeType.midnight: _buildModernTheme(Colors.indigo, Brightness.dark),
  AppThemeType.rose: _buildModernTheme(Colors.pink, Brightness.light),
  AppThemeType.lemon: _buildModernTheme(Colors.amber, Brightness.light),
  AppThemeType.plum: _buildModernTheme(const Color(0xFFF1A7C4), Brightness.dark, scaffold: const Color(0xFF302430)),
};

/// Helper to build a modern, vibrant theme where the colors actually show up.
ThemeData _buildModernTheme(Color seedColor, Brightness brightness, {Color? scaffold}) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    primary: seedColor,
    surface: isDark ? (scaffold ?? const Color(0xFF121212)) : Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    scaffoldBackgroundColor: scaffold ?? (isDark 
        ? const Color(0xFF121212) 
        : Color.alphaBlend(colorScheme.primary.withOpacity(0.02), const Color(0xFFF8F9FA))),
    
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      centerTitle: true,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      titleTextStyle: TextStyle(
        color: colorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? (scaffold?.withOpacity(0.8) ?? const Color(0xFF1E1E1E)) : Colors.white,
      selectedItemColor: isDark && seedColor.computeLuminance() < 0.5 ? Colors.white : colorScheme.primary,
      unselectedItemColor: isDark ? Colors.white60 : Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    drawerTheme: DrawerThemeData(
      backgroundColor: isDark ? (scaffold ?? const Color(0xFF1E1E1E)) : Colors.white,
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
      ),
      color: isDark ? (scaffold?.withOpacity(0.9) ?? const Color(0xFF1E1E1E)) : Colors.white,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    textTheme: TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isDark ? Colors.white : Colors.black),
      titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black),
      bodyLarge: TextStyle(fontSize: 16, color: isDark ? Colors.white.withOpacity(0.9) : Colors.black),
      bodyMedium: TextStyle(color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87),
    ),
  );
}

/// Fallback theme used when a theme key is missing from [appThemes].
ThemeData get defaultAppTheme => appThemes[AppThemeType.plum]!;
