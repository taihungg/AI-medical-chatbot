import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await DatabaseService.instance.init();

  await AppState.instance.restoreSession();

  AppState.instance.startVitalsSimulation();

  runApp(const AICareBridgeApp());
}

class AICareBridgeApp extends StatelessWidget {
  const AICareBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          primary: const Color(0xFF0077B6),
          secondary: const Color(0xFF50D9FE),
          error: const Color(0xFFBA1A1A),
        ),
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
      home: const AppEntry(),
    );
  }
}

/// Routes to patient shell when session exists, otherwise role gateway.
class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    if (appState.isPatientSession) {
      return const MainFramework(initialPatientTab: 0);
    }
    return const SplashScreen();
  }
}
