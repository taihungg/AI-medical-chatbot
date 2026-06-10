import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

import 'doctor_dashboard_screen.dart';
import 'doctor_timetable_screen.dart';
import 'clinical_workspace.dart';
import 'doctor_history_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DoctorDashboardScreen(),
    const DoctorTimetableScreen(),
    const DoctorHistoryScreen(),
    const DoctorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        // Build floating banner if there's an active consultation
        Widget? floatingBanner;
        if (appState.activeConsultation != null) {
          final appt = appState.activeConsultation!;
          floatingBanner = Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ClinicalWorkspace(
                      appointmentId: appt.id,
                      onClosed: () {},
                    ),
                  ),
                );
              },
              child: GlassCard(
                borderColor: appt.isOnline ? Colors.purple : Colors.orange,
                borderWidth: 1.5,
                child: Row(
                  children: [
                    Icon(
                      appt.isOnline ? Icons.language : Icons.local_hospital,
                      color: appt.isOnline ? Colors.purple : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Đang khám: ${appt.patientName}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(appt.isOnline ? "Tư vấn trực tuyến" : "Khám trực tiếp",
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
              if (floatingBanner != null) floatingBanner,
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: GlassTheme.oceanBlue,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: "Ca hôm nay",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month),
                    label: "Lịch",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    activeIcon: Icon(Icons.history),
                    label: "Lịch sử",
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        const Icon(Icons.person_outline),
                        if (appState.isDoctorBusy)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    activeIcon: Stack(
                      children: [
                        const Icon(Icons.person),
                        if (appState.isDoctorBusy)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: "Hồ sơ",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
