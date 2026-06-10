import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../login_screen.dart';
import '../splash_screen.dart';

/// Opens login then routes to full patient framework on the booking tab.
Future<void> openPatientLoginThenBooking(BuildContext context) async {
  final success = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => const LoginScreen(expectedRole: UserRole.patient),
    ),
  );
  if (success == true && context.mounted) {
    AppState.instance.setRole(UserRole.patient);
    AppState.instance.setPatientNavIndex(1);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainFramework(initialPatientTab: 1),
      ),
    );
  }
}

/// Clears session and returns to the multi-role gateway.
Future<void> logoutAndGoToSplash(BuildContext context) async {
  await AppState.instance.logout();
  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
    );
  }
}
