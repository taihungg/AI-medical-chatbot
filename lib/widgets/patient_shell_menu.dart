import 'package:flutter/material.dart';
import '../screens/account/account_management_screen.dart';
import '../screens/patient/patient_navigation.dart';
import '../screens/splash_screen.dart';

/// Hamburger menu for logged-in patient tabs (nav is handled by bottom bar).
class PatientShellMenu {
  PatientShellMenu._();

  static List<PopupMenuEntry<String>> items() => const [
        PopupMenuItem(
          value: 'account',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: Colors.black54),
              SizedBox(width: 12),
              Text("Quản lý tài khoản"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 20, color: Colors.black54),
              SizedBox(width: 12),
              Text("Cài đặt"),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'switch_role',
          child: Row(
            children: [
              Icon(Icons.swap_horizontal_circle_outlined,
                  size: 20, color: Colors.orange),
              SizedBox(width: 12),
              Text("Đổi vai trò (Demo)",
                  style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
      ];

  static void handleSelection(BuildContext context, String value) {
    switch (value) {
      case 'account':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccountManagementScreen()),
        );
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Chức năng Cài đặt đang được phát triển."),
          ),
        );
      case 'logout':
        logoutAndGoToSplash(context);
      case 'switch_role':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
    }
  }
}
