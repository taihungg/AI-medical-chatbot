import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../state/app_state.dart';
import '../widgets/role_switcher.dart';
import 'patient/home_dashboard.dart'; 
import 'patient/symptom_flow.dart';
import 'patient/medication_catalog.dart';
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
                          color: GlassTheme.cyan.withOpacity(0.4),
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
                
                // 1. Patient / Seeker Option
                _buildRoleCard(
                  context,
                  title: "Người Dùng & Bệnh Nhân",
                  subtitle: "Khám triệu chứng AI, đặt lịch phòng khám, tủ thuốc & tư vấn telehealth trực tuyến.",
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
        borderColor: color.withOpacity(0.35),
        borderWidth: 1.2,
        opacity: 0.7,
        child: Row(
          children: [
            // Circular Glowing Icon Wrapper
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 1),
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
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.6), size: 12),
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
  // Navigation for Patient/Seeker is separate from Specialist/Manager
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
          child: Scaffold(
          body: Stack(
            children: [
              // Dynamic view based on Active Role
              _buildRoleScreen(appState.currentRole),

              // Always visible floating debugger Role Console
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IgnorePointer(
                          ignoring: false,
                          child: const RoleSwitcher(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),);
      },
    );
  }

  Widget _buildRoleScreen(UserRole role) {
    // We import and render appropriate screens here
    switch (role) {
      case UserRole.patient:
      case UserRole.seeker:
        return _buildPatientSeekerShell(role);
      case UserRole.doctor:
      case UserRole.specialist:
        return const DoctorSpecialistShell();
      case UserRole.manager:
        return const ClinicManagerShell();
    }
  }

  Widget _buildPatientSeekerShell(UserRole role) {
    // Shell managing bottom navigation bar for Patient/Seeker
    final pages = [
      const PatientHomeDashboard(),
      const SymptomFlowScreen(),
      const MedicationCatalogScreen(),
      const PatientHistoryScreen(),
    ];

    final items = [
      GlassNavItem(icon: Icons.home_outlined, label: "Trang chủ"),
      GlassNavItem(icon: Icons.chat_bubble_outline, label: "Khám AI"),
      GlassNavItem(icon: Icons.medical_services_outlined, label: "Nhà thuốc"),
      GlassNavItem(icon: Icons.history_outlined, label: "Lịch sử"),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_patientNavIndex],
      bottomNavigationBar: GlassNavigationBar(
        selectedIndex: _patientNavIndex,
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

// Mock Shells for Specialist and Manager (We will implement the real screens later)
class DoctorSpecialistShell extends StatelessWidget {
  const DoctorSpecialistShell({super.key});

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

// Temporary empty screens until implemented
class PatientHistoryScreen extends StatelessWidget {
  const PatientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final doneAppts = appState.appointments;
        
        return Scaffold(
          appBar: const GlassAppBar(title: "Lịch Sử Khám Bệnh"),
          body: GlassBackground(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Hồ Sơ Y Khoa Của Bạn",
                  style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  "Xem tất cả lịch hẹn tư vấn và kết luận từ bác sĩ chuyên khoa.",
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                if (doneAppts.isEmpty)
                  const GlassCard(
                    child: Center(
                      child: Text("Không có lịch sử khám bệnh."),
                    ),
                  )
                else
                  ...doneAppts.map((appt) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: appt.status == 'Hoàn thành'
                                      ? Colors.green.withOpacity(0.12)
                                      : Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appt.status,
                                  style: GlassTheme.labelCaps(
                                    color: appt.status == 'Hoàn thành' ? Colors.green : Colors.amber[800]!,
                                  ),
                                ),
                              ),
                              Text(
                                appt.id,
                                style: GlassTheme.labelCaps(color: GlassTheme.outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            appt.doctorName,
                            style: GlassTheme.h3(),
                          ),
                          Text(
                            "${appt.specialty} • ${appt.branchName}",
                            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white38),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: GlassTheme.oceanBlue),
                              const SizedBox(width: 6),
                              Text(
                                "${appt.dateTime.day}/${appt.dateTime.month}/${appt.dateTime.year} - ${appt.timeSlot}",
                                style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Triệu chứng: ${appt.symptomSummary}",
                            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                          ),
                          if (appt.clinicalNotes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Chẩn đoán từ bác sĩ:",
                                    style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appt.clinicalNotes,
                                    style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (appt.prescriptionSigned && appt.prescriptionList.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.assignment_turned_in, size: 16, color: Colors.green),
                                const SizedBox(width: 6),
                                Text(
                                  "Đơn thuốc đã ký điện tử",
                                  style: GlassTheme.labelCaps(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}
