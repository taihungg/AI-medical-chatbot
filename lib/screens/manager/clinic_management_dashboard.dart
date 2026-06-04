import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import 'doctor_management_screen.dart';
import 'patient_records_screen.dart';
import 'master_appointment_screen.dart';
import '../account/account_management_screen.dart';
import '../splash_screen.dart';

class ClinicManagerDashboard extends StatefulWidget {
  const ClinicManagerDashboard({super.key});

  @override
  State<ClinicManagerDashboard> createState() => _ClinicManagerDashboardState();
}

class _ClinicManagerDashboardState extends State<ClinicManagerDashboard> {
  int _selectedBranchIndex =
      0; // 0: Chi nhánh A, 1: Chi nhánh B, 2: Chi nhánh C, 3: Chi nhánh D
  final List<String> _branches = [
    "Bệnh viện Đa Khoa Trung Ương",
    "Phòng khám Đa khoa Quốc tế",
    "Cơ sở C - Hải Châu, Đà Nẵng",
    "Cơ sở D - Ninh Kiều, Cần Thơ"
  ];

  // Simulated metrics per branch
  final List<Map<String, double>> _branchMetrics = [
    {
      'patients': 148,
      'doctors': 12,
      'occupancy': 85.0,
      'wait': 14.5,
    },
    {
      'patients': 98,
      'doctors': 8,
      'occupancy': 70.0,
      'wait': 18.0,
    },
    {
      'patients': 64,
      'doctors': 5,
      'occupancy': 60.0,
      'wait': 11.2,
    },
    {
      'patients': 45,
      'doctors': 4,
      'occupancy': 50.0,
      'wait': 8.5,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        // Fetch current active branch metrics
        final metrics = _branchMetrics[_selectedBranchIndex];

        // Count total appointments in app state
        final apptCount = appState.appointments.length;

        return Scaffold(
          appBar: GlassAppBar(
            title: "Bảng Điều Hành Phòng Khám",
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: GlassTheme.oceanBlue),
                offset: const Offset(0, 56),
                tooltip: "Menu Quản lý",
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'logout') {
                    appState.logout();
                  } else if (value == 'account') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountManagementScreen()),
                    );
                  } else if (value == 'settings') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chức năng Cài đặt đang được phát triển.")),
                    );
                  } else if (value == 'switch_role') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'info',
                    enabled: false,
                    child: Text(
                      appState.currentUserProfile?.name ?? "Trần Quốc Hùng",
                      style: GlassTheme.bodyLg().copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black87),
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
                        Icon(Icons.logout, color: Colors.red, size: 20),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Branch Tab Selector Drawer (Glass Row)
                  GlassCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    borderRadius: 20,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_branches.length, (idx) {
                          final isSelected = _selectedBranchIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedBranchIndex = idx;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? GlassTheme.primaryGradient
                                      : null,
                                  color: isSelected ? null : Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.white30,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_hospital_outlined,
                                      color: isSelected
                                          ? Colors.white
                                          : GlassTheme.oceanBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _branches[idx].split(" - ")[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : GlassTheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Branch description
                  Text(
                    _branches[_selectedBranchIndex],
                    style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Theo dõi thời gian thực các chỉ số hoạt động, hiệu suất và hoạt động lâm sàng.",
                    style: TextStyle(
                        fontSize: 12, color: GlassTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),

                  // 2. Metrics Bento Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      // Metric 1: Total Patients
                      _buildMetricCard(
                        "TỔNG BỆNH NHÂN",
                        "${(metrics['patients']! + apptCount).toInt()}",
                        Icons.people,
                        Colors.blue,
                        "+14% hôm nay",
                      ),
                      // Metric 2: Online Doctors
                      _buildMetricCard(
                        "BÁC SĨ TRỰC TUYẾN",
                        "${metrics['doctors']!.toInt()} / 15",
                        Icons.medical_services,
                        Colors.teal,
                        "Hỗ trợ HD Live",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorManagementScreen()),
                          );
                        },
                      ),
                      // Metric 3: Occupancy Rate
                      _buildMetricCard(
                        "LẤP ĐẦY PHÒNG KHÁM",
                        "${metrics['occupancy']!.toInt()}%",
                        Icons.door_sliding,
                        Colors.orange,
                        "Mức tối ưu: 80%",
                      ),
                      // Metric 4: Avg Waiting Time
                      _buildMetricCard(
                        "CHỜ TRUNG BÌNH",
                        "${metrics['wait']!.toStringAsFixed(1)} phút",
                        Icons.hourglass_empty,
                        GlassTheme.error,
                        "Giảm 2.4 phút",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Middle Section: Chart & Live Auditing Logs (Double column layout if wide)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Operational Charts
                          Expanded(
                            flex: isWide ? 6 : 10,
                            child: GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Biểu Đồ Hiệu Suất Giờ Cao Điểm",
                                          style: GlassTheme.h3().copyWith(
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.bar_chart,
                                          color: GlassTheme.cyan),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Số lượng bệnh nhân phân bổ theo khung giờ khám hôm nay.",
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: GlassTheme.outline),
                                  ),
                                  const SizedBox(height: 24),

                                  // Beautiful Custom Painted Chart
                                  SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: CustomPaint(
                                      painter: OperationsChartPainter(
                                        branchIndex: _selectedBranchIndex,
                                        appointmentsAdded: apptCount,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildLegendItem(
                                          "08h-10h", GlassTheme.oceanBlue),
                                      _buildLegendItem(
                                          "10h-12h", GlassTheme.cyan),
                                      _buildLegendItem(
                                          "14h-16h", Colors.purple),
                                      _buildLegendItem("16h-18h", Colors.teal),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Spacing if wide
                          if (isWide) const SizedBox(width: 16),

                          // Live transaction logs
                          Expanded(
                            flex: isWide ? 4 : 10,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: isWide ? 0.0 : 16.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Nhật Ký Hệ Thống Live",
                                          style: GlassTheme.h3().copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Luồng dữ liệu hoạt động thời gian thực từ ứng dụng.",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: GlassTheme.outline),
                                    ),
                                    const SizedBox(height: 16),

                                    // Log terminal listing
                                    Container(
                                      height: 212,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        border:
                                            Border.all(color: Colors.white24),
                                      ),
                                      child: ListView.builder(
                                        itemCount: appState.auditLogs.length,
                                        itemBuilder: (ctx, idx) {
                                          final log = appState.auditLogs[idx];
                                          // Stylize specific logs
                                          Color logColor = Colors.white70;
                                          if (log.contains("BS đã ký")) {
                                            logColor = Colors.green;
                                          } else if (log
                                              .contains("đã đặt lịch")) {
                                            logColor = GlassTheme.cyan;
                                          } else if (log
                                              .contains("[Hệ thống]")) {
                                            logColor = Colors.amber;
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6.0),
                                            child: Text(
                                              log,
                                              style: TextStyle(
                                                fontFamily: 'Courier',
                                                fontSize: 10,
                                                color: logColor,
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
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          bottomNavigationBar: GlassNavigationBar(
            selectedIndex: 0,
            onTap: (idx) {
              if (idx == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DoctorManagementScreen()),
                );
              } else if (idx == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PatientRecordsScreen()),
                );
              } else if (idx == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MasterAppointmentScreen()),
                );
              }
            },
            items: [
              GlassNavItem(icon: Icons.dashboard, label: 'Tổng quan'),
              GlassNavItem(icon: Icons.medical_services, label: 'Bác sĩ'),
              GlassNavItem(icon: Icons.people, label: 'Bệnh nhân'),
              GlassNavItem(icon: Icons.event, label: 'Lịch hẹn'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GlassTheme.labelCaps(color: GlassTheme.outline)
                  .copyWith(fontSize: 9),
            ),
            Icon(icon, color: color, size: 20),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: GlassTheme.h1(color: color)
              .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style:
              const TextStyle(fontSize: 9, color: GlassTheme.onSurfaceVariant),
        ),
      ],
    );

    if (onTap != null) {
      return GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: content,
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: GlassTheme.onSurfaceVariant)),
      ],
    );
  }
}

// Custom Painter to render glowing 3D-styled glass column charts
class OperationsChartPainter extends CustomPainter {
  final int branchIndex;
  final int appointmentsAdded;

  OperationsChartPainter(
      {required this.branchIndex, required this.appointmentsAdded});

  @override
  void paint(Canvas canvas, Size size) {
    // Generate heights dynamically based on branch and added appointments
    final baseHeights = [
      [0.65, 0.85, 0.45, 0.55], // Branch A
      [0.45, 0.60, 0.50, 0.35], // Branch B
      [0.35, 0.45, 0.55, 0.25], // Branch C
      [0.25, 0.35, 0.40, 0.20] // Branch D
    ];

    final heights = List<double>.from(baseHeights[branchIndex]);

    // Add dynamically based on appointments booked (increments bars)
    if (appointmentsAdded > 0) {
      heights[1] = min(1.0, heights[1] + (appointmentsAdded * 0.05));
      heights[2] = min(1.0, heights[2] + (appointmentsAdded * 0.03));
    }

    final barColors = [
      GlassTheme.oceanBlue,
      GlassTheme.cyan,
      Colors.purple,
      Colors.teal,
    ];

    // Paint axis line grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    // Draw horizontal grids
    for (int i = 0; i < 4; i++) {
      final double y = size.height - (i * size.height / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double barWidth = 32.0;
    final double spacing =
        (size.width - (heights.length * barWidth)) / (heights.length + 1);

    for (int i = 0; i < heights.length; i++) {
      final double x = spacing + i * (barWidth + spacing);
      final double h =
          heights[i] * (size.height - 20); // leave 20px padding at top
      final double y = size.height - h;

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(8),
      );

      // Create neon glass glow effect
      final glowPaint = Paint()
        ..color = barColors[i].withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawRRect(barRect, glowPaint);

      // Draw solid column
      final columnPaint = Paint()
        ..shader = LinearGradient(
          colors: [barColors[i], barColors[i].withValues(alpha: 0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, barWidth, h));

      canvas.drawRRect(barRect, columnPaint);

      // Draw top glowing highlight line
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(barRect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OperationsChartPainter oldDelegate) {
    return oldDelegate.branchIndex != branchIndex ||
        oldDelegate.appointmentsAdded != appointmentsAdded;
  }
}
