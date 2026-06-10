import 'package:flutter/material.dart';
import 'symptom_flow.dart';

/// Full-screen guest consultation — no bottom navigation bar.
class GuestConsultationShell extends StatelessWidget {
  const GuestConsultationShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SymptomFlowScreen(mode: SymptomFlowMode.guestConsultation);
  }
}
