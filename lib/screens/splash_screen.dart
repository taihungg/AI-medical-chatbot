import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/brand_mark.dart';
import '../widgets/role_gateway_card.dart';
import '../state/app_state.dart';
import 'patient/symptom_flow.dart';
import 'patient/appointment_booking_tab.dart';
import 'patient/patient_history_screen.dart';
import 'patient/patient_hub_screen.dart';
import 'doctor/specialist_dashboard.dart';
import 'manager/clinic_management_dashboard.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _heartAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  Future<void> _onRoleTap(BuildContext context, UserRole role) async {
    final appState = AppState.instance;

    if (appState.currentRole != role) {
      await appState.logout();
    }

    if (!context.mounted) return;

    if (role == UserRole.patient) {
      appState.setRole(UserRole.patient);
      if (appState.isPatientSession) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MainFramework(initialPatientTab: 0),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PatientHubScreen()),
        );
      }
      return;
    }

    if (!appState.isAuthenticated) {
      final success = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => LoginScreen(expectedRole: role)),
      );
      if (success != true) return;
    }

    appState.setRole(role);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainFramework()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _heartAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GlassTheme.cyan.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const BrandMark(size: 140),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "HỆ THỐNG AI CHATBOT Y TẾ",
                  style: GlassTheme.labelCaps(
                    color: GlassTheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  "BẮT ĐẦU TRẢI NGHIỆM (CHỌN VAI TRÒ)",
                  style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)
                      .copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                RoleGatewayCard(
                  title: "Bệnh nhân",
                  subtitle:
                      "Khám triệu chứng AI, đặt lịch phòng khám và tư vấn trực tuyến.",
                  icon: Icons.person_outline,
                  color: GlassTheme.oceanBlue,
                  onTap: () => _onRoleTap(context, UserRole.patient),
                ),
                const SizedBox(height: 12),
                RoleGatewayCard(
                  title: "Bác sĩ",
                  subtitle:
                      "Hàng đợi khám lâm sàng, phòng tư vấn video live.",
                  icon: Icons.medical_services_outlined,
                  color: Colors.teal,
                  onTap: () => _onRoleTap(context, UserRole.doctor),
                ),
                const SizedBox(height: 12),
                RoleGatewayCard(
                  title: "Quản lý phòng khám",
                  subtitle:
                      "Dashboard chỉ số bento thời gian thực, biểu đồ giờ cao điểm & nhật ký live toàn hệ thống.",
                  icon: Icons.analytics_outlined,
                  color: Colors.deepPurple,
                  onTap: () => _onRoleTap(context, UserRole.manager),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainFramework extends StatefulWidget {
  final int initialPatientTab;
  const MainFramework({super.key, this.initialPatientTab = 0});

  @override
  State<MainFramework> createState() => _MainFrameworkState();
}

class _MainFrameworkState extends State<MainFramework> {
  @override
  void initState() {
    super.initState();
    AppState.instance.setPatientNavIndex(widget.initialPatientTab);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: _buildRoleScreen(appState.currentRole),
          ),
        );
      },
    );
  }

  Widget _buildRoleScreen(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return _buildPatientShell();
      case UserRole.doctor:
        return const DoctorShell();
      case UserRole.manager:
        return const ClinicManagerShell();
    }
  }

  Widget _buildPatientShell() {
    final appState = AppState.instance;
    final activeIndex = appState.patientNavIndex;

    const pages = [
      SymptomFlowScreen(mode: SymptomFlowMode.inShell),
      AppointmentBookingTab(),
      PatientHistoryScreen(),
    ];

    final items = [
      GlassNavItem(icon: Icons.chat_bubble_outline, label: "Tư vấn AI"),
      GlassNavItem(icon: Icons.edit_calendar, label: "Đặt khám"),
      GlassNavItem(icon: Icons.history, label: "Lịch sử"),
    ];

    if (appState.pendingBookingFromAI && activeIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          appState.setPatientNavIndex(1);
          appState.consumeBookingTrigger();
        }
      });
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: activeIndex,
        children: pages,
      ),
      bottomNavigationBar: GlassNavigationBar(
        selectedIndex: activeIndex,
        onTap: appState.setPatientNavIndex,
        items: items,
      ),
    );
  }
}

class DoctorShell extends StatelessWidget {
  const DoctorShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorSpecialistDashboard();
  }
}

class ClinicManagerShell extends StatelessWidget {
  const ClinicManagerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClinicManagerDashboard();
  }
}
