import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../splash_screen.dart';

class PatientMenuScreen extends StatelessWidget {
  const PatientMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(
        title: "Menu",
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile section
            GlassCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: GlassTheme.cyan.withOpacity(0.2),
                    child: Text(
                      state.currentUserProfile?.name.substring(0, 1) ?? "B",
                      style: GlassTheme.h1(color: GlassTheme.oceanBlue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.currentUserProfile?.name ?? "Bệnh nhân", style: GlassTheme.h2()),
                        Text(state.currentUserProfile?.phone ?? "", style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Menu Items
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, "Quản lý tài khoản"),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.lock_outline, "Đổi mật khẩu"),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.language, "Ngôn ngữ", trailing: "Tiếng Việt"),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.description_outlined, "Điều khoản và Điều kiện"),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(Icons.contact_support_outlined, "Liên hệ với quản lý phòng khám"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.switch_account_outlined, 
                    "Đổi vai trò",
                    onTap: () {
                      state.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    }
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    Icons.logout, 
                    "Đăng xuất", 
                    color: GlassTheme.error,
                    onTap: () {
                      state.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? trailing, VoidCallback? onTap, Color? color}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: color ?? GlassTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: GlassTheme.bodyLg(color: color ?? GlassTheme.onSurface)),
            ),
            if (trailing != null)
              Text(trailing, style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: GlassTheme.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
