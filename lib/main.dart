import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-initialize and start any simulation background loops if needed
  AppState.instance.startVitalsSimulation();

  runApp(const AICareBridgeApp());
}

class AICareBridgeApp extends StatelessWidget {
  const AICareBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Care Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6), // Ocean Blue
          primary: const Color(0xFF0077B6),
          secondary: const Color(0xFF50D9FE), // Cyan
          error: const Color(0xFFBA1A1A),
        ),
        // Apply Inter font as the global body text theme
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF191C1E),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF191C1E),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
