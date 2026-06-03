import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'glass_widgets.dart';
import '../screens/splash_screen.dart';

class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _getRoleNameVi(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return "Bệnh nhân";
      case UserRole.doctor:
        return "Bác sĩ";
      case UserRole.manager:
        return "Quản lý phòng khám";
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Icons.person;
      case UserRole.doctor:
        return Icons.medical_services;
      case UserRole.manager:
        return Icons.dashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [

            Positioned(
              bottom: 84, // Sits comfortably above bottom bar
              right: 16,
              child: SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 24,
                    opacity: 0.9,
                    borderColor: GlassTheme.oceanBlue,
                    borderWidth: 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.swap_horizontal_circle, color: GlassTheme.oceanBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Bảng Chọn Vai Trò",
                              style: GlassTheme.h3(color: GlassTheme.oceanBlue).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(height: 16, color: Colors.white38),
                        ...UserRole.values.map((role) {
                          final isSelected = appState.currentRole == role;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: InkWell(
                              onTap: () {
                                appState.setRole(role);
                                _toggleExpanded();
                                // Overlay short dynamic banner
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Đã chuyển sang: ${_getRoleNameVi(role)}"),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: GlassTheme.oceanBlue,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: isSelected
                                    ? BoxDecoration(
                                        color: GlassTheme.oceanBlue.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                    : null,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getRoleIcon(role),
                                      size: 18,
                                      color: isSelected ? GlassTheme.oceanBlue : GlassTheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _getRoleNameVi(role),
                                        style: GlassTheme.bodyMd(
                                          color: isSelected ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                                        ).copyWith(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check, size: 14, color: GlassTheme.oceanBlue),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const Divider(height: 16, color: Colors.white38),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: InkWell(
                            onTap: () {
                              _toggleExpanded();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const SplashScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: GlassTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    size: 16,
                                    color: GlassTheme.error,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Quay lại màn hình chính",
                                      style: TextStyle(
                                        color: GlassTheme.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 10, color: GlassTheme.error),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating Switcher Button
            Positioned(
              bottom: 96,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _toggleExpanded,
                backgroundColor: GlassTheme.oceanBlue,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.tune,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
