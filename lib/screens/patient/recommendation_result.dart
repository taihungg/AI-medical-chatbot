import 'dart:async';
import 'package:flutter/material.dart';
import '../splash_screen.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import 'appointment_booking.dart';
import 'doctor_consultation.dart';

class RecommendationResultScreen extends StatelessWidget {
  final String symptoms;
  final String risk; // Thấp | Trung bình | Cao | Khẩn cấp

  const RecommendationResultScreen({
    super.key,
    required this.symptoms,
    required this.risk,
  });

  Color _getRiskColor() {
    switch (risk) {
      case "Khẩn cấp": return GlassTheme.error;
      case "Cao": return Colors.orange[800]!;
      case "Trung bình": return GlassTheme.oceanBlue;
      default: return Colors.green[700]!;
    }
  }

  String _getRiskIcon() {
    switch (risk) {
      case "Khẩn cấp": return "🆘";
      case "Cao": return "⚠️";
      case "Trung bình": return "ℹ️";
      default: return "✅";
    }
  }

  String _getRecommendationText() {
    switch (risk) {
      case "Khẩn cấp":
        return "Các triệu chứng của bạn rất nghiêm trọng và cần được chăm sóc y tế ngay lập tức. Vui lòng kích hoạt SOS cấp cứu hoặc đến phòng khám gần nhất.";
      case "Cao":
        return "Bạn nên đặt lịch khám trực tiếp với bác sĩ chuyên khoa trong vòng 24 giờ tới để được làm xét nghiệm lâm sàng đầy đủ.";
      case "Trung bình":
        return "Khuyên dùng dịch vụ tư vấn trực tuyến (Telemedicine Video Call) ngay để bác sĩ đánh giá chi tiết hơn hoặc kê đơn thuốc nhẹ.";
      default:
        return "Triệu chứng ở mức nguy cơ thấp. Bạn có thể tự chăm sóc tại nhà, bổ sung nước, dinh dưỡng và tra cứu đơn thuốc phù hợp.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appState.addAuditLog("Bệnh nhân xem kết quả AI với nguy cơ: $risk");
    });

    return Scaffold(
      appBar: const GlassAppBar(title: "Kết Quả Khám AI"),
      body: GlassBackground(
        child: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Risk Badge Icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getRiskColor().withOpacity(0.12),
                    border: Border.all(color: _getRiskColor(), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _getRiskIcon(),
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Severity Level display
              Center(
                child: Column(
                  children: [
                    Text(
                      "MỨC ĐỘ NGUY CƠ: $risk",
                      style: GlassTheme.h1(color: _getRiskColor()).copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mã hồ sơ: ASSESSMENT-${DateTime.now().millisecond}",
                      style: GlassTheme.labelCaps(color: GlassTheme.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Symptoms summary card
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tóm Tắt Khảo Sát Triệu Chứng",
                      style: GlassTheme.h3().copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      symptoms.isEmpty ? "Khảo sát triệu chứng sức khỏe tổng quát." : symptoms,
                      style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detailed medical guidance
              GlassCard(
                borderColor: _getRiskColor(),
                borderWidth: 1.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: _getRiskColor()),
                        const SizedBox(width: 8),
                        Text(
                          "Khuyên Nghị Y Tế AI",
                          style: GlassTheme.h3(color: _getRiskColor()).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getRecommendationText(),
                      style: GlassTheme.bodyMd(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ACTION BUTTONS SECTION (CTA)
              if (risk == "Khẩn cấp") ...[
                // SOS Pulsing alert
                _buildSOSTriggerCard(context),
              ] else if (risk == "Cao") ...[
                // Main: Book Clinic Appointment
                GlassButton(
                  text: "Đặt Lịch Khám Cơ Sở",
                  icon: Icons.edit_calendar,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AppointmentBookingScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Sub: Quick Video call
                GlassButton(
                  text: "Tư Vấn Trực Tuyến Tức Thì",
                  isPrimary: false,
                  icon: Icons.video_call,
                  onPressed: () {
                    _navigateToQuickConsult(context);
                  },
                ),
              ] else if (risk == "Trung bình") ...[
                // Main: Telemedicine Video call
                GlassButton(
                  text: "Tư Vấn Bác Sĩ Trực Tuyến",
                  icon: Icons.video_call,
                  onPressed: () {
                    _navigateToQuickConsult(context);
                  },
                ),
                const SizedBox(height: 12),
                // Sub: Book appointment
                GlassButton(
                  text: "Đặt Lịch Trực Tiếp",
                  isPrimary: false,
                  icon: Icons.edit_calendar,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AppointmentBookingScreen()),
                    );
                  },
                ),
              ] else ...[
                // Low risk: Self-care guide & Pharmacy
                GlassButton(
                  text: "Tìm Kiếm Dược Phẩm Phù Hợp",
                  icon: Icons.local_pharmacy,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainFramework(initialPatientTab: 2)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Sub: Self-care details
                GlassButton(
                  text: "Xem Cẩm Nang Tự Chăm Sóc",
                  isPrimary: false,
                  icon: Icons.menu_book,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SelfCareScreen()),
                    );
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Back to Home
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainFramework(initialPatientTab: 0)),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: GlassTheme.oceanBlue),
                    const SizedBox(width: 8),
                    Text("Trở về Trang chủ", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQuickConsult(BuildContext context) {
    final appState = AppState.instance;
    final simulatedAppt = AppAppointment(
      id: "APT-TELE-${DateTime.now().millisecond}",
      patientName: "Nguyễn Minh Anh",
      branchName: "Phòng khám A - Trực tuyến",
      doctorName: "BS. Nguyễn Văn An",
      specialty: "Khoa Nội tim mạch",
      dateTime: DateTime.now(),
      timeSlot: "Ngay bây giờ",
      symptomSummary: symptoms.isEmpty ? "Đăng ký tư vấn trực tuyến" : symptoms,
      riskLevel: risk,
      status: "Đang khám",
    );

    appState.setActiveConsultation(simulatedAppt);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DoctorConsultationScreen(appointment: simulatedAppt)),
    );
  }

  Widget _buildSOSTriggerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GlassTheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GlassTheme.error.withOpacity(0.3), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Cảnh Báo Cấp Cứu Sức Khỏe",
            style: GlassTheme.h3(color: GlassTheme.error).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Hệ thống khuyên bạn kích hoạt cuộc gọi khẩn cấp đến tổng đài 115 ngay.",
            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassTheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: GlassTheme.error.withOpacity(0.5),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SOSEmergencyAlertScreen()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "KÍCH HOẠT SOS CẤP CỨU",
                  style: GlassTheme.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ---------------- SOS EMERGENCY ALERT SCREEN ----------------
class SOSEmergencyAlertScreen extends StatefulWidget {
  const SOSEmergencyAlertScreen({super.key});

  @override
  State<SOSEmergencyAlertScreen> createState() => _SOSEmergencyAlertScreenState();
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
    AppState.instance.addAuditLog("Hệ thống kích hoạt cuộc gọi khẩn cấp SOS tới 115.");
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
                  color: Colors.red.withOpacity(0.15),
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
                style: GlassTheme.h1(color: Colors.white).copyWith(fontSize: 26),
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
                      style: GlassTheme.h1(color: Colors.white).copyWith(fontSize: 64),
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
                                style: GlassTheme.labelCaps(color: Colors.white70),
                              ),
                              Text(
                                "Bệnh viện Đa Khoa Chi Nhánh A (Cách 1.8km)",
                                style: GlassTheme.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Địa chỉ: 154 Trần Hưng Đạo, Quận 1, TP. HCM",
                      style: GlassTheme.bodyMd(color: Colors.white70).copyWith(fontSize: 12),
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
              text: "Xem danh mục thuốc gia đình",
              icon: Icons.local_pharmacy,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainFramework(initialPatientTab: 2)),
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
              color: Colors.green.withOpacity(0.12),
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
                  style: GlassTheme.h3().copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
