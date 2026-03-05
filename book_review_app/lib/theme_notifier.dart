// This file contains a ChangeNotifier that manages the active theme.
// It also exposes helpers to update the theme when the user changes it
// from the settings screen.

import 'package:flutter/material.dart';

import 'models.dart';
import 'theme.dart';

/// Simple helper to convert an [AppThemeType] to a string key for persistence.
String themeTypeToKey(AppThemeType type) => type.name;

/// Parses a string key back into an [AppThemeType] with a safe fallback.
AppThemeType themeTypeFromKey(String? key) {
  if (key == null) return AppThemeType.light;
  return AppThemeType.values.firstWhere(
    (t) => t.name == key,
    orElse: () => AppThemeType.light,
  );
}

/// Notifier that holds the current theme and notifies listeners when it changes.
class ThemeNotifier extends ChangeNotifier {
  AppThemeType _currentType;

  ThemeNotifier(this._currentType);

  AppThemeType get currentType => _currentType;

  ThemeData get currentTheme => appThemes[_currentType] ?? defaultAppTheme;

  /// Sets the current theme type and notifies listeners.
  void setTheme(AppThemeType type) {
    if (type == _currentType) return;
    _currentType = type;
    notifyListeners();
  }
}

