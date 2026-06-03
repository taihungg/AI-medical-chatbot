import 'dart:async';
import 'package:flutter/material.dart';
import '../splash_screen.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

// ---------------- SOS EMERGENCY ALERT SCREEN ----------------
class SOSEmergencyAlertScreen extends StatefulWidget {
  const SOSEmergencyAlertScreen({super.key});

  @override
  State<SOSEmergencyAlertScreen> createState() =>
      _SOSEmergencyAlertScreenState();
}

class _SOSEmergencyAlertScreenState extends State<SOSEmergencyAlertScreen> {
  int _secondsRemaining = 5;
  Timer? _timer;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _secondsRemaining = 0;
          _timer?.cancel();
          _triggerCall();
        }
      });
    });
  }

  void _cancelAlert() {
    setState(() {
      _cancelled = true;
      _timer?.cancel();
    });
    AppState.instance.addAuditLog("Bệnh nhân HỦY cuộc gọi cấp cứu SOS.");
  }

  void _triggerCall() {
    AppState.instance
        .addAuditLog("Hệ thống kích hoạt cuộc gọi khẩn cấp SOS tới 115.");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Đang thực hiện cuộc gọi cấp cứu đến 115..."),
        backgroundColor: GlassTheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF500000), // Deep red theme
      body: GlassBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flashing warning icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.redAccent, width: 3),
                ),
                child: const Icon(
                  Icons.emergency_share,
                  color: Colors.redAccent,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                "KÍCH HOẠT CẤP CỨU 115",
                style:
                    GlassTheme.h1(color: Colors.white).copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                _cancelled
                    ? "Đã hủy cuộc gọi tự động. Vui lòng liên hệ người thân hoặc đến bệnh viện gần nhất nếu có biến cố xảy ra."
                    : "Hệ thống sẽ tự động thực hiện cuộc gọi khẩn cấp đến tổng đài 115 sau:",
                style: GlassTheme.bodyMd(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Giant Countdown Circle
              if (!_cancelled)
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      "$_secondsRemaining",
                      style: GlassTheme.h1(color: Colors.white)
                          .copyWith(fontSize: 64),
                    ),
                  ),
                ),

              const SizedBox(height: 50),

              // SOS Clinic location and actions
              GlassCard(
                opacity: 0.2,
                borderColor: Colors.redAccent,
                borderWidth: 1.5,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bệnh viện gần nhất của bạn:",
                                style:
                                    GlassTheme.labelCaps(color: Colors.white70),
                              ),
                              Text(
                                "Bệnh viện Đa Khoa Chi Nhánh A (Cách 1.8km)",
                                style: GlassTheme.bodyMd(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Địa chỉ: 154 Trần Hưng Đạo, Quận 1, TP. HCM",
                      style: GlassTheme.bodyMd(color: Colors.white70)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              if (!_cancelled && _secondsRemaining > 0)
                GlassButton(
                  text: "HỦY CUỘC GỌI (CANCEL)",
                  onPressed: _cancelAlert,
                  isPrimary: false,
                  height: 56,
                )
              else
                GlassButton(
                  text: "Quay lại",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- SELF CARE ADVICE SCREEN ----------------
class SelfCareScreen extends StatelessWidget {
  const SelfCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlassAppBar(title: "Cẩm Nang Tự Chăm Sóc"),
      body: GlassBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              "Tự Chăm Sóc Cho Nguy Cơ Thấp",
              style: GlassTheme.h2(color: GlassTheme.oceanBlue),
            ),
            const SizedBox(height: 8),
            Text(
              "Các bác sĩ AI Care Bridge đề xuất một số biện pháp hỗ trợ giảm nhẹ triệu chứng tại nhà.",
              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildTipCard(
              "1. Nghỉ ngơi & Tránh lao động nặng",
              "Nghỉ ngơi hoàn toàn từ 1-2 ngày giúp cơ thể hồi phục nhanh. Tránh nâng vật nặng hoặc tập thể thao gắng sức.",
              Icons.king_bed,
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              "2. Bổ sung nước & Điện giải",
              "Uống nhiều nước ấm, nước hoa quả giàu Vitamin C hoặc dung dịch điện giải Oresol nếu có sốt nhẹ hoặc ho mệt.",
              Icons.local_drink,
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              "3. Dinh dưỡng lành mạnh",
              "Ăn cháo loãng, súp nóng dễ tiêu hóa. Bổ sung rau xanh và trái cây tươi để nâng cao sức đề kháng.",
              Icons.restaurant,
            ),
            const SizedBox(height: 16),
            _buildTipCard(
              "4. Theo dõi triệu chứng",
              "Thường xuyên đo nhiệt độ cơ thể và kiểm tra các dấu hiệu đặc biệt. Nếu sốt cao hơn 38.5°C hoặc đau ngực tăng lên, hãy chuyển vai trò sang khám trực tuyến ngay lập tức.",
              Icons.query_stats,
            ),
            const SizedBox(height: 40),
            GlassButton(
              text: "Trở về Trang Tư Vấn AI",
              icon: Icons.chat_bubble_outline,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) =>
                          const MainFramework(initialPatientTab: 0)),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green[700]!, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GlassTheme.h3()
                      .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                      .copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
