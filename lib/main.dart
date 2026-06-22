import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IndianBabyCalculatorApp());
}

class IndianBabyCalculatorApp extends StatelessWidget {
  const IndianBabyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indian Baby Height Weight Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B4D8),
          surface: const Color(0xFFF8F9FA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFEEEEEE)),
          ),
          color: Colors.white,
        ),
      ),
      home: const GrowthCalculatorScreen(),
    );
  }
}