import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../state/app_state.dart';
import 'account/account_management_screen.dart';
import 'patient/symptom_flow.dart';
import 'patient/appointment_booking_tab.dart';
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
                  "DrAI", 
                  style: GlassTheme.h1(color: GlassTheme.oceanBlue),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
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

                // 1. Patient / Seeker Option
                _buildRoleCard(
                  context,
                  title: "Bệnh nhân",
                  subtitle:
                      "Khám triệu chứng AI, đặt lịch phòng khám và tư vấn trực tuyến.",
                  icon: Icons.person_outline,
                  role: UserRole.patient,
                  color: GlassTheme.oceanBlue,
                ),
                const SizedBox(height: 12),

                // 2. Doctor Option
                _buildRoleCard(
                  context,
                  title: "Bác sĩ",
                  subtitle:
                      "Hàng đợi khám lâm sàng, phòng tư vấn video live.",
                  icon: Icons.medical_services_outlined,
                  role: UserRole.doctor,
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),

                // 3. Manager Option
                _buildRoleCard(
                  context,
                  title: "Quản lý phòng khám",
                  subtitle:
                      "Dashboard chỉ số bento thời gian thực, biểu đồ giờ cao điểm & nhật ký live toàn hệ thống.",
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
      onTap: () async {
        final appState = AppState.instance;

        if (appState.currentRole != role) {
          appState.logout();
        }

        // Force login for Doctor and Manager if not authenticated
        if (role != UserRole.patient && !appState.isAuthenticated) {
          final success = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => LoginScreen(expectedRole: role)),
          );
          if (success != true) return; // Login cancelled or failed
        }

        appState.setRole(role);
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainFramework()),
          );
        }
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
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
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
                    style: GlassTheme.h3(
                      color: color,
                    ).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GlassTheme.bodyMd(
                      color: GlassTheme.onSurfaceVariant,
                    ).copyWith(fontSize: 11.5, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Forward arrow indicator
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.6),
              size: 12,
            ),
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
            child: _buildRoleScreen(appState.currentRole),
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
    final appState = AppState.instance;
    final activeIndex = appState.patientNavIndex;

    final pages = [
      const SymptomFlowScreen(),
      appState.isAuthenticated ? const AppointmentBookingTab() : const PatientLoginRequiredScreen(title: "Đặt lịch khám"),
      appState.isAuthenticated ? const PatientHistoryScreen() : const PatientLoginRequiredScreen(title: "Lịch sử y khoa"),
    ];

    final items = [
      GlassNavItem(icon: Icons.chat_bubble_outline, label: "Tư vấn AI"),
      GlassNavItem(icon: Icons.edit_calendar, label: "Đặt lịch"),
      GlassNavItem(icon: Icons.history, label: "Lịch sử"),
    ];

    // Auto-switch to booking tab when AI triggers it
    if (appState.pendingBookingFromAI && activeIndex != 1) {
      // Schedule the tab switch after the current frame to avoid build-during-build
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
          appBar: GlassAppBar(
            title: "Lịch Sử Khám Bệnh",
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: GlassTheme.oceanBlue),
                tooltip: "Menu",
                offset: const Offset(0, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'ai_chat') {
                    appState.setPatientNavIndex(0);
                  } else if (value == 'booking') {
                    appState.setPatientNavIndex(1);
                  } else if (value == 'history') {
                    appState.setPatientNavIndex(2);
                  } else if (value == 'account') {
                    if (!appState.isAuthenticated) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen(expectedRole: UserRole.patient)));
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountManagementScreen()),
                    );
                  } else if (value == 'settings') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chức năng Cài đặt đang được phát triển.")),
                    );
                  } else if (value == 'logout') {
                    appState.logout();
                  } else if (value == 'switch_role') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'ai_chat',
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 20, color: GlassTheme.oceanBlue),
                        SizedBox(width: 12),
                        Text("Tư vấn AI"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'booking',
                    child: Row(
                      children: [
                        Icon(Icons.edit_calendar,
                            size: 20, color: GlassTheme.oceanBlue),
                        SizedBox(width: 12),
                        Text("Đặt lịch"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history,
                            size: 20, color: GlassTheme.oceanBlue),
                        SizedBox(width: 12),
                        Text("Lịch sử"),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'account',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text("Quản lý tài khoản"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text("Cài đặt"),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'switch_role',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horizontal_circle_outlined, size: 20, color: Colors.orange),
                        SizedBox(width: 12),
                        Text("Đổi vai trò (Demo)", style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: GlassBackground(
            child: !appState.isAuthenticated
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.login, size: 64, color: GlassTheme.oceanBlue),
                            const SizedBox(height: 24),
                            Text(
                              "Yêu cầu Đăng Nhập",
                              style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Bạn cần đăng nhập với tài khoản Bệnh nhân để xem lịch sử khám bệnh.",
                              textAlign: TextAlign.center,
                              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: GlassButton(
                                text: "Đăng Nhập",
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(
                                        expectedRole: UserRole.patient,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),
                if (doneAppts.isEmpty)
                  const GlassCard(
                    child: Center(child: Text("Không có lịch sử khám bệnh.")),
                  )
                else
                  ...doneAppts.map(
                    (appt) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appt.status == 'Hoàn thành'
                                        ? Colors.green.withValues(alpha: 0.12)
                                        : Colors.amber.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    appt.status,
                                    style: GlassTheme.labelCaps(
                                      color: appt.status == 'Hoàn thành'
                                          ? Colors.green
                                          : Colors.amber[800]!,
                                    ),
                                  ),
                                ),
                                Text(
                                  appt.id,
                                  style: GlassTheme.labelCaps(
                                    color: GlassTheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(appt.doctorName, style: GlassTheme.h3()),
                            Text(
                              "${appt.specialty} • ${appt.branchName}",
                              style: GlassTheme.bodyMd(
                                color: GlassTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Colors.white38),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: GlassTheme.oceanBlue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${appt.dateTime.day}/${appt.dateTime.month}/${appt.dateTime.year} - ${appt.timeSlot}",
                                  style: GlassTheme.bodyMd().copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Triệu chứng: ${appt.symptomSummary}",
                              style: GlassTheme.bodyMd(
                                color: GlassTheme.onSurfaceVariant,
                              ),
                            ),
                            if (appt.clinicalNotes.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Chẩn đoán từ bác sĩ:",
                                      style: GlassTheme.bodyMd().copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      appt.clinicalNotes,
                                      style: GlassTheme.bodyMd(
                                        color: GlassTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (appt.prescriptionSigned &&
                                appt.prescriptionList.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.assignment_turned_in,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Đơn thuốc đã ký điện tử",
                                    style: GlassTheme.labelCaps(
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PatientLoginRequiredScreen extends StatelessWidget {
  final String title;
  const PatientLoginRequiredScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    return Scaffold(
      appBar: GlassAppBar(
        title: title,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: GlassTheme.oceanBlue),
            tooltip: "Menu",
            offset: const Offset(0, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'ai_chat') {
                appState.setPatientNavIndex(0);
              } else if (value == 'booking') {
                appState.setPatientNavIndex(1);
              } else if (value == 'history') {
                appState.setPatientNavIndex(2);
              } else if (value == 'account') {
                if (!appState.isAuthenticated) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginScreen(expectedRole: UserRole.patient)));
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountManagementScreen()));
              } else if (value == 'logout') {
                appState.logout();
              } else if (value == 'switch_role') {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SplashScreen()));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ai_chat', child: Row(children: [Icon(Icons.chat_bubble_outline, size: 20, color: GlassTheme.oceanBlue), SizedBox(width: 12), Text("Tư vấn AI")])),
              const PopupMenuItem(value: 'booking', child: Row(children: [Icon(Icons.edit_calendar, size: 20, color: GlassTheme.oceanBlue), SizedBox(width: 12), Text("Đặt lịch")])),
              const PopupMenuItem(value: 'history', child: Row(children: [Icon(Icons.history, size: 20, color: GlassTheme.oceanBlue), SizedBox(width: 12), Text("Lịch sử")])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'account', child: Row(children: [Icon(Icons.person_outline, size: 20, color: Colors.black54), SizedBox(width: 12), Text("Quản lý tài khoản")])),
              const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings_outlined, size: 20, color: Colors.black54), SizedBox(width: 12), Text("Cài đặt")])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'switch_role', child: Row(children: [Icon(Icons.swap_horizontal_circle_outlined, size: 20, color: Colors.orange), SizedBox(width: 12), Text("Đổi vai trò (Demo)", style: TextStyle(color: Colors.orange))])),
            ],
          )
        ],
      ),
      body: GlassBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: GlassTheme.oceanBlue),
              const SizedBox(height: 16),
              Text("Yêu cầu đăng nhập", style: GlassTheme.h2()),
              const SizedBox(height: 8),
              Text("Bạn cần đăng nhập để sử dụng chức năng này.", style: GlassTheme.bodyMd()),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: GlassButton(
                  text: "ĐĂNG NHẬP",
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LoginScreen(expectedRole: UserRole.patient)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
