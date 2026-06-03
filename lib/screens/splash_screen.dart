import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../state/app_state.dart';
import '../widgets/role_switcher.dart';
import 'patient/symptom_flow.dart';
import 'patient/appointment_booking_tab.dart';
import 'patient/patient_history_screen.dart';
import 'doctor/specialist_dashboard.dart';
import 'manager/clinic_management_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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
                // Glowing Heart Logo Container
                ScaleTransition(
                  scale: _heartAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
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
                    child: const GlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 70,
                      opacity: 0.8,
                      borderColor: Colors.white,
                      borderWidth: 1.5,
                      child: Center(
                        child: Icon(
                          Icons.favorite,
                          color: GlassTheme.error,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Titles
                Text(
                  "AI Care Bridge",
                  style: GlassTheme.h1(color: GlassTheme.oceanBlue),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "HỆ THỐNG CẦU NỐI Y TẾ THÔNG MINH",
                  style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  "BẮT ĐẦU TRẢI NGHIỆM PROTOTYPE (CHỌN VAI TRÒ)",
                  style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // 1. Patient Option
                _buildRoleCard(
                  context,
                  title: "Người Dùng & Bệnh Nhân",
                  subtitle: "Tư vấn triệu chứng AI, đặt lịch khám trực tuyến hoặc trực tiếp tại phòng khám.",
                  icon: Icons.person_outline,
                  role: UserRole.patient,
                  color: GlassTheme.oceanBlue,
                ),
                const SizedBox(height: 12),
                
                // 2. Doctor Option
                _buildRoleCard(
                  context,
                  title: "Bác Sĩ & Chuyên Gia Lâm Sàng",
                  subtitle: "Hàng đợi khám lâm sàng, phòng tư vấn video live, ghi chú giọng nói AI & ký số đơn thuốc.",
                  icon: Icons.medical_services_outlined,
                  role: UserRole.doctor,
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                
                // 3. Manager Option
                _buildRoleCard(
                  context,
                  title: "Ban Điều Hành & Quản Lý",
                  subtitle: "Dashboard chỉ số bento thời gian thực, biểu đồ giờ cao điểm & nhật ký live toàn hệ thống.",
                  icon: Icons.analytics_outlined,
                  role: UserRole.manager,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required UserRole role,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        AppState.instance.setRole(role);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainFramework()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 20,
        borderColor: color.withValues(alpha: 0.35),
        borderWidth: 1.2,
        opacity: 0.7,
        child: Row(
          children: [
            // Circular Glowing Icon Wrapper
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            // Text Info block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GlassTheme.h3(color: color).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Forward arrow indicator
            Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.6), size: 12),
          ],
        ),
      ),
    );
  }
}

// Global Main Framework Screen that handles Switching Roles on the fly
class MainFramework extends StatefulWidget {
  final int initialPatientTab;
  const MainFramework({super.key, this.initialPatientTab = 0});

  @override
  State<MainFramework> createState() => _MainFrameworkState();
}

class _MainFrameworkState extends State<MainFramework> {
  // Navigation index for Patient bottom tabs
  late int _patientNavIndex;

  @override
  void initState() {
    super.initState();
    _patientNavIndex = widget.initialPatientTab;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        // Dynamically select layout based on the active role selected in the floating switcher
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Dynamic view based on Active Role
                _buildRoleScreen(appState.currentRole),

                // Always visible floating debugger Role Console.
                // Positioned.fill gives the RoleSwitcher's internal Stack a
                // bounded size (it positions its own children via bottom/right).
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Stack(
                      children: const [
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: false,
                            child: RoleSwitcher(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleScreen(UserRole role) {
    // We import and render appropriate screens here
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
    // Shell managing bottom navigation bar for Patient
    // Tab 0: AI Chatbot (SymptomFlowScreen)
    // Tab 1: Đặt lịch khám (AppointmentBookingTab)
    // Tab 2: Lịch sử y khoa (PatientHistoryScreen)
    final pages = [
      const SymptomFlowScreen(),
      const AppointmentBookingTab(),
      const PatientHistoryScreen(),
    ];

    final items = [
      GlassNavItem(icon: Icons.chat_bubble_outline, label: "Tư vấn AI"),
      GlassNavItem(icon: Icons.edit_calendar, label: "Đặt lịch"),
      GlassNavItem(icon: Icons.history, label: "Lịch sử"),
    ];

    final activeIndex = _patientNavIndex >= pages.length ? 0 : _patientNavIndex;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // Auto-switch to booking tab when AI triggers it
    final appState = AppState.instance;
    if (appState.pendingBookingFromAI && _patientNavIndex != 1) {
      // Schedule the tab switch after the current frame to avoid build-during-build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _patientNavIndex = 1;
          });
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
      bottomNavigationBar: isKeyboardOpen
          ? null
          : GlassNavigationBar(
              selectedIndex: activeIndex,
              onTap: (index) {
                setState(() {
                  _patientNavIndex = index;
                });
              },
              items: items,
            ),
    );
  }
}

// Shells for Doctor and Manager
class DoctorShell extends StatelessWidget {
  const DoctorShell({super.key});

  @override
  Widget build(BuildContext context) {
    // We will render Doctor Dashboard
    return const DoctorSpecialistDashboard();
  }
}

class ClinicManagerShell extends StatelessWidget {
  const ClinicManagerShell({super.key});

  @override
  Widget build(BuildContext context) {
    // We will render Manager Dashboard
    return const ClinicManagerDashboard();
  }
}

