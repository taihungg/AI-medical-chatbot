import 'dart:async';
import 'package:flutter/material.dart';
import '../splash_screen.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';



// ---------------- SELF CARE ADVICE SCREEN ----------------
class SelfCareScreen extends StatelessWidget {
  const SelfCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlassAppBar(title: "Cẩm Nang Tự Chăm Sóc", showBrandMark: false),
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
              "Các bác sĩ DrAI đề xuất một số biện pháp hỗ trợ giảm nhẹ triệu chứng tại nhà.",
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
