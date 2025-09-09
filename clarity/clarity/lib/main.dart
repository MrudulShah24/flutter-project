import 'package:flutter/material.dart';
import 'package:clarity/features/auth/screens/landing_screen.dart';
import 'package:clarity/features/q_and_a/screens/home_feed_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check the login state before running the app
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(ClarityApp(isLoggedIn: isLoggedIn));
}

class ClarityApp extends StatelessWidget {
  // Receive the login state
  final bool isLoggedIn;

  const ClarityApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF00B0FF);
    const Color darkBackground = Color(0xFF121212);
    const Color surfaceColor = Color(0xFF1E1E1E);
    const Color lightText = Color(0xFFE0E0E0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clarity App',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: primaryBlue,
          secondary: primaryBlue,
          surface: darkBackground,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: lightText,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontWeight: FontWeight.bold),
        ).apply(fontFamily: 'Poppins', displayColor: lightText, bodyColor: lightText),
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          elevation: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          prefixIconColor: Colors.grey[400],
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.black,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
          ),
        ),
        useMaterial3: true,
      ),
      // Use the isLoggedIn flag to choose the starting screen
      home: isLoggedIn ? const HomeFeedScreen() : const LandingScreen(),
    );
  }
}