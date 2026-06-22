import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

// Global Notifier to instantly rebuild the app when the theme changes.
final ValueNotifier<String> appThemeNotifier = ValueNotifier<String>('fun');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedTheme = await StorageService.getAppTheme();
  appThemeNotifier.value = savedTheme;
  runApp(const IndianBabyCalculatorApp());
}

class AppThemes {
  // ---------------------------------------------------------
  // STANDARD THEME (The original, clinical/professional theme)
  // ---------------------------------------------------------
  static final ThemeData standardTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00B4D8),
      surface: const Color(0xFFF8F9FA),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF00B4D8)),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0xFFEEEEEE)),
      ),
      color: Colors.white,
    ),
  );

  // ---------------------------------------------------------
  // FUN & PLAYFUL THEME (Soft UI, Bouncy, Modern Adult)
  // ---------------------------------------------------------
  static final ThemeData funTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C5CE7), // Punchy Violet Primary
      primary: const Color(0xFF6C5CE7),
      secondary: const Color(0xFF00CEC9), // Vibrant Teal Accent
      tertiary: const Color(0xFFFF7675),  // Soft Salmon Red for alerts
      surface: const Color(0xFFF4F6F9), // Very soft, cool blue-grey background
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto', // Will use heavy weights to make it look friendly

    // Bouncy, bold AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF6C5CE7), size: 32),
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.w900,
          color: Color(0xFF2D3436), // Dark slate text for better contrast
          fontSize: 24,
          letterSpacing: -0.5
      ),
    ),

    // Ultra-rounded cards with smooth, thick borders instead of drop shadows
    cardTheme: CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(32)), // Extreme rounding
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 2.5), // Thick soft border
      ),
      color: Colors.white,
    ),

    // Pill-shaped, chunky buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Flat design
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    ),

    // Friendly, rounded text inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2), // Visible unfocused border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 3), // Thick focused border
      ),
      labelStyle: const TextStyle(color: Color(0xFF636E72), fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: Color(0xFFB2BEC3), fontWeight: FontWeight.w500),
    ),

    // Smooth floating snackbars
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF2D3436), // Dark slate floating pill
      contentTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15),
      elevation: 4,
    ),

    // Highly rounded dialog boxes
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(36))),
      backgroundColor: Colors.white,
      elevation: 0.0,
    ),

    // Bottom sheets with extreme top rounding
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
    ),
  );
}

class IndianBabyCalculatorApp extends StatelessWidget {
  const IndianBabyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appThemeNotifier,
      builder: (context, themeName, child) {
        return MaterialApp(
          title: 'Indian Baby Height Weight Calculator',
          debugShowCheckedModeBanner: false,
          theme: themeName == 'fun' ? AppThemes.funTheme : AppThemes.standardTheme,
          home: const GrowthCalculatorScreen(),
        );
      },
    );
  }
}