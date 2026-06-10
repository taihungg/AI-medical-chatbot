import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/role_gateway_card.dart';
import '../splash_screen.dart';
import 'guest_consultation_shell.dart';
import 'patient_navigation.dart';

/// Intermediate screen for guests choosing consultation vs clinical intent.
class PatientHubScreen extends StatelessWidget {
  const PatientHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: GlassTheme.oceanBlue),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const SplashScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const BrandMark(size: 100),
                  const SizedBox(height: 20),
                  Text(
                    "Bạn cần hỗ trợ gì?",
                    style: GlassTheme.h1(color: GlassTheme.oceanBlue),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "CHỌN HÀNH TRÌNH PHÙ HỢP",
                    style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant)
                        .copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  RoleGatewayCard(
                    title: "Tôi cần tư vấn AI",
                    subtitle:
                        "Hỏi AI về triệu chứng, nhận hướng dẫn tự chăm sóc. Không cần đăng nhập.",
                    icon: Icons.chat_bubble_outline,
                    color: GlassTheme.oceanBlue,
                    onTap: () {
                      AppState.instance.setRole(UserRole.patient);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const GuestConsultationShell(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  RoleGatewayCard(
                    title: "Tôi cần khám bệnh",
                    subtitle:
                        "Đặt lịch khám trực tiếp với bác sĩ. Đăng nhập để tiếp tục.",
                    icon: Icons.edit_calendar_outlined,
                    color: Colors.teal,
                    onTap: () => openPatientLoginThenBooking(context),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
