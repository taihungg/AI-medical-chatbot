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

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
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
                  _buildProfileHeader(appState),
                  const SizedBox(height: 24),
                  _buildSettingsCard(appState),
                  const SizedBox(height: 24),
                  _buildStatsCard(appState),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        appState.logout();
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
    );
  }

  Widget _buildProfileHeader(AppState appState) {
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
          Text(appState.currentUserProfile?.name ?? "BS. Trần Anh Tuấn", style: GlassTheme.h2()),
          const SizedBox(height: 4),
          const Text("Khoa Nội Tổng Hợp - BV Bạch Mai", style: TextStyle(color: GlassTheme.onSurfaceVariant, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(AppState appState) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionItem(Icons.person_outline, "Thông tin cá nhân", onTap: () => _showEditProfileDialog(appState)),
          const Divider(height: 1, indent: 56),
          _buildOptionItem(Icons.lock_outline, "Đổi mật khẩu", onTap: () => _showChangePasswordDialog()),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: GlassTheme.oceanBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(labelText: "Mật khẩu cũ"), obscureText: true),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: "Mật khẩu mới"), obscureText: true),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: "Xác nhận mật khẩu mới"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã đổi mật khẩu thành công!")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.oceanBlue),
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(AppState appState) {
    final nameController = TextEditingController(text: appState.currentUserProfile?.name ?? "");
    final phoneController = TextEditingController(text: appState.currentUserProfile?.phone ?? "");
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sửa thông tin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Họ và tên")),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Số điện thoại")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (appState.currentUserProfile != null) {
                final newProfile = appState.currentUserProfile!.clone();
                newProfile.name = nameController.text;
                newProfile.phone = phoneController.text;
                appState.updateUserProfile(newProfile);
              }
              Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
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
