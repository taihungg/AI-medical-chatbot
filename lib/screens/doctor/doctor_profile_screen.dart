import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      appBar: const GlassAppBar(
        title: "Hồ sơ Bác sĩ",
        automaticallyImplyLeading: false,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildSettingsCard(appState),
              const SizedBox(height: 24),
              _buildStatsCard(appState),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to splash or login
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: GlassTheme.oceanBlue,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.edit, size: 20, color: GlassTheme.oceanBlue),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text("BS. Trần Anh Tuấn", style: GlassTheme.h2()),
          const SizedBox(height: 4),
          const Text("Khoa Nội Tổng Hợp - BV Bạch Mai", style: TextStyle(color: GlassTheme.onSurfaceVariant, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(AppState appState) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Cài đặt chung", style: GlassTheme.h3()),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.do_not_disturb_on_outlined, color: Colors.red),
              title: const Text("Chế độ Đang bận"),
              subtitle: const Text("Tạm ngưng nhận bệnh nhân mới"),
              trailing: Switch(
                value: appState.isDoctorBusy,
                onChanged: (val) {
                  setState(() {
                    appState.toggleDoctorBusy();
                  });
                },
                activeThumbColor: Colors.red,
              ),
            ),
          ),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined, color: GlassTheme.oceanBlue),
              title: const Text("Thông báo đẩy"),
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeThumbColor: GlassTheme.oceanBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AppState appState) {
    final completedCount = appState.appointments.where((a) => a.status == 'Đã khám').length;
    final totalCount = appState.appointments.length;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thống kê hoạt động", style: GlassTheme.h3()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem("Tổng ca khám", totalCount.toString(), Icons.people_outline, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem("Đã hoàn thành", completedCount.toString(), Icons.check_circle_outline, Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}
