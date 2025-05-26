import 'package:flutter/material.dart';

/// Extension methods on BuildContext for easier access to common properties
extension AppContextExtension on BuildContext {
  /// Returns the screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Returns the screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns the current theme
  ThemeData get theme => Theme.of(this);

  /// Returns the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Returns the primary color from the theme
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Returns true if the device is in dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Shows a snackbar with the given message
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  /// Returns true if the device is in landscape orientation
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Returns the padding to avoid UI overlaps (like notches and keyboard)
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Returns the height of the screen minus the status bar and bottom padding
  double get safeHeight => screenHeight - padding.top - padding.bottom;

  /// Returns the error color from the theme
  Color get getErrorColor => Theme.of(this).colorScheme.error;
}
