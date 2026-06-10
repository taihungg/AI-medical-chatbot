import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../splash_screen.dart';
import 'doctor_management_screen.dart';
import 'patient_records_screen.dart';
import 'master_appointment_screen.dart';

// MÀU SẮC GIAO DIỆN PHẲNG (FLAT DESIGN)
const Color primaryColor = Color(0xFF1E88E5);
const Color successColor = Color(0xFF43A047);
const Color alertColor = Color(0xFFE53935);
const Color disabledColor = Color(0xFF9E9E9E);
const Color backgroundColor = Color(0xFFF4F6F8);
const Color surfaceColor = Colors.white;
const Color textColor = Color(0xFF212121);
const Color subtitleColor = Color(0xFF757575);

class ClinicManagerDashboard extends StatefulWidget {
  const ClinicManagerDashboard({super.key});

  @override
  State<ClinicManagerDashboard> createState() => _ClinicManagerDashboardState();
}

class _ClinicManagerDashboardState extends State<ClinicManagerDashboard> {
  int _selectedMenuIndex = 0;
  bool _isLoading = false;
  String _timeFilter = "Hôm nay";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'title': 'Tổng quan'},
    {'icon': Icons.medical_services, 'title': 'Bác sĩ'},
    {'icon': Icons.people, 'title': 'Bệnh nhân'},
    {'icon': Icons.event, 'title': 'Lịch hẹn'},
  ];

  void _onMenuTapped(int index) {
    // Nếu đang mở drawer trên mobile thì đóng lại
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    
    // Đổi tab nội dung thay vì chuyển trang hoàn toàn (Navigator.push)
    setState(() {
      _selectedMenuIndex = index;
    });
  }

  Future<void> _handleFilterChange(String? newValue) async {
    if (newValue == null) return;
    setState(() {
      _isLoading = true;
      _timeFilter = newValue;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận thiết lập lại"),
        content: const Text("Bạn có chắc chắn muốn xóa bộ lọc và tải lại dữ liệu mặc định không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: alertColor),
            onPressed: () {
              Navigator.pop(ctx);
              _handleFilterChange("Hôm nay");
            },
            child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600 && !isDesktop;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: isDesktop ? null : Drawer(child: _buildSidebarContent()),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị Sidebar cố định trên Desktop
          if (isDesktop) 
            SizedBox(
              width: 260,
              child: _buildSidebarContent(),
            ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopHeader(isDesktop),
                
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: primaryColor))
                    : _buildBodyContent(isDesktop, isTablet),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(bool isDesktop, bool isTablet) {
    switch (_selectedMenuIndex) {
      case 1:
        return const DoctorManagementScreen();
      case 2:
        return const PatientRecordsScreen();
      case 3:
        return const MasterAppointmentScreen();
      case 0:
      default:
        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKPISection(isDesktop, isTablet),
              const SizedBox(height: 24),
              _buildChartsSection(isDesktop),
              const SizedBox(height: 24),
              _buildDataTable(),
            ],
          ),
        );
    }
  }

  Widget _buildSidebarContent() {
    return Container(
      color: surfaceColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.local_hospital, color: primaryColor, size: 32),
                SizedBox(width: 12),
                Text("MedAdmin", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedMenuIndex == index;
                final item = _menuItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: InkWell(
                    onTap: () => _onMenuTapped(index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(item['icon'], color: isSelected ? primaryColor : subtitleColor, size: 22),
                          const SizedBox(width: 16),
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? primaryColor : subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: alertColor),
            title: const Text("Đăng xuất", style: TextStyle(color: alertColor)),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTopHeader(bool isDesktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Nút mở menu trên Mobile
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: textColor),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          if (!isDesktop) const SizedBox(width: 8),

          Expanded(
            flex: isDesktop ? 2 : 1,
            child: TextField(
              decoration: InputDecoration(
                hintText: isDesktop ? "Tìm kiếm thông minh..." : "Tìm...",
                prefixIcon: const Icon(Icons.search, color: subtitleColor),
                filled: true,
                fillColor: backgroundColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
                setState(() { _isLoading = true; });
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (mounted) setState(() => _isLoading = false);
                });
              },
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: textColor),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: alertColor, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text(
                    "3",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundColor: primaryColor,
            child: Text("HQ", style: TextStyle(color: Colors.white)),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 8),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Trần Quốc Hùng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Quản trị viên", style: TextStyle(color: subtitleColor, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: subtitleColor),
          ]
        ],
      ),
    );
  }

  Widget _buildKPISection(bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _buildKPICard("Tổng Doanh Thu", "450.2M", Icons.attach_money, successColor, "+12.5%")),
          const SizedBox(width: 16),
          Expanded(child: _buildKPICard("Số Người Dùng", "1,245", Icons.people, primaryColor, "+4.2%")),
          const SizedBox(width: 16),
          Expanded(child: _buildKPICard("Tỷ Lệ Chuyển Đổi", "68%", Icons.trending_up, successColor, "+2.1%")),
          const SizedBox(width: 16),
          Expanded(child: _buildKPICard("Lỗi Giao Dịch", "12", Icons.error_outline, alertColor, "-1.5%")),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildKPICard("Tổng Doanh Thu", "450.2M", Icons.attach_money, successColor, "+12.5%")),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard("Số Người Dùng", "1,245", Icons.people, primaryColor, "+4.2%")),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildKPICard("Tỷ Lệ Chuyển Đổi", "68%", Icons.trending_up, successColor, "+2.1%")),
              const SizedBox(width: 16),
              Expanded(child: _buildKPICard("Lỗi Giao Dịch", "12", Icons.error_outline, alertColor, "-1.5%")),
            ],
          ),
        ],
      );
    } else {
      // Mobile
      return Column(
        children: [
          _buildKPICard("Tổng Doanh Thu", "450.2M", Icons.attach_money, successColor, "+12.5%"),
          const SizedBox(height: 12),
          _buildKPICard("Số Người Dùng", "1,245", Icons.people, primaryColor, "+4.2%"),
          const SizedBox(height: 12),
          _buildKPICard("Tỷ Lệ Chuyển Đổi", "68%", Icons.trending_up, successColor, "+2.1%"),
          const SizedBox(height: 12),
          _buildKPICard("Lỗi Giao Dịch", "12", Icons.error_outline, alertColor, "-1.5%"),
        ],
      );
    }
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color trendColor, String trendValue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: subtitleColor, fontSize: 14, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: trendColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: trendColor, size: 20),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(trendValue.startsWith("+") ? Icons.arrow_upward : Icons.arrow_downward, color: trendColor, size: 14),
              const SizedBox(width: 4),
              Text(trendValue, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 4),
              const Expanded(
                child: Text("so với tuần trước", style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.ellipsis),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartsSection(bool isDesktop) {
    final lineChart = Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 250),
        painter: FlatLineChartPainter(),
      ),
    );

    final barChart = Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 250),
        painter: FlatBarChartPainter(),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Phân Tích Tăng Trưởng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildChartFilters(),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Phân Tích Tăng Trưởng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildChartFilters(),
              ],
            ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: lineChart),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: barChart),
              ],
            )
          else
            Column(
              children: [
                lineChart,
                const SizedBox(height: 16),
                barChart,
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChartFilters() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _timeFilter,
            underline: const SizedBox(),
            items: ["Hôm nay", "Tuần này", "Tháng này", "Năm nay"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: _handleFilterChange,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: disabledColor, elevation: 0),
          onPressed: _showResetConfirmation,
          icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
          label: const Text("Reset", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hoạt Động Gần Đây", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Sử dụng LayoutBuilder để ép bảng chiếm trọn chiều ngang (Full width)
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(backgroundColor),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Tên Khách Hàng", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Dịch Vụ", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Ngày Tạo", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Trạng Thái", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Hành Động", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List.generate(5, (index) {
                      final isSuccess = index % 2 == 0;
                      return DataRow(cells: [
                        DataCell(Text("#${1000 + index}")),
                        DataCell(Text("Bệnh nhân ${index + 1}")),
                        const DataCell(Text("Khám tổng quát")),
                        DataCell(Text("10/06/2026 10:0${index}")),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSuccess ? successColor.withOpacity(0.1) : alertColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isSuccess ? "Thành công" : "Lỗi",
                              style: TextStyle(color: isSuccess ? successColor : alertColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: alertColor, size: 18),
                            tooltip: "Xóa bản ghi",
                            onPressed: _showResetConfirmation,
                          ),
                        ),
                      ]);
                    }),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: disabledColor), onPressed: () {}),
              const Text("1 / 5", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.chevron_right, color: primaryColor), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }
}

// =======================
// CUSTOM PAINTERS CHO BIỂU ĐỒ PHẲNG
// =======================

class FlatLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.4, size.width, size.height * 0.2);

    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1.0;
    
    for (int i = 1; i < 5; i++) {
      double y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlatBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final heights = [0.4, 0.7, 0.5, 0.9, 0.6];
    final colors = [primaryColor, successColor, Colors.orange, alertColor, Colors.purple];
    
    final double barWidth = size.width / (heights.length * 2);
    final double spacing = barWidth;
    
    for (int i = 0; i < heights.length; i++) {
      final double h = heights[i] * size.height * 0.8;
      final double x = (i * (barWidth + spacing)) + spacing / 2;
      final double y = size.height - h;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(4),
      );
      
      final paint = Paint()..color = colors[i];
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
