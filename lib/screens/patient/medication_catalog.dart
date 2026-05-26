import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

class MedicationCatalogScreen extends StatefulWidget {
  const MedicationCatalogScreen({super.key});

  @override
  State<MedicationCatalogScreen> createState() => _MedicationCatalogScreenState();
}

class _MedicationCatalogScreenState extends State<MedicationCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeCategory = "Tất cả";
  String _searchQuery = "";

  final List<String> _categories = ["Tất cả", "Hô hấp", "Tim mạch", "Tiêu hóa", "Giảm đau"];

  final List<Map<String, String>> _medications = [
    {
      "name": "Paracetamol (Panadol) 500mg",
      "cat": "Giảm đau",
      "use": "Hạ sốt nhanh, giảm các cơn đau đầu từ nhẹ đến trung bình.",
      "dose": "Uống 1-2 viên mỗi 4-6 giờ khi có triệu chứng đau sốt.",
      "pack": "Vỉ 10 viên"
    },
    {
      "name": "Decolgen Forte",
      "cat": "Hô hấp",
      "use": "Điều trị nghẹt mũi, sổ mũi, cảm cúm, hắt hơi kèm sốt nhẹ.",
      "dose": "Uống ngày 3 lần, mỗi lần 1 viên sau ăn.",
      "pack": "Vỉ 4 viên"
    },
    {
      "name": "Siro Ho Thảo Dược Prospan",
      "cat": "Hô hấp",
      "use": "Giảm ho khan, ho có đờm, làm sạch phế quản và chống viêm phế quản.",
      "dose": "Uống ngày 3 lần, mỗi lần 5ml sau ăn.",
      "pack": "Chai 100ml"
    },
    {
      "name": "Oresol (Điện giải bù nước)",
      "cat": "Tiêu hóa",
      "use": "Bù nước và muối điện giải do sốt cao, tiêu chảy hoặc vận động mạnh.",
      "dose": "Hòa tan 1 gói với 1 lít nước đun sôi để nguội. Uống rải rác.",
      "pack": "Gói bột sủi"
    },
    {
      "name": "Smecta 3g",
      "cat": "Tiêu hóa",
      "use": "Hỗ trợ bao niêm mạc ruột trong điều trị tiêu chảy cấp và trào ngược dạ dày.",
      "dose": "Hòa tan ngày 2-3 gói với nước ấm, uống trước ăn.",
      "pack": "Hộp 30 gói"
    },
    {
      "name": "Amlodipine 5mg",
      "cat": "Tim mạch",
      "use": "Kiểm soát tăng huyết áp mãn tính và ngăn ngừa cơn đau thắt ngực ổn định.",
      "dose": "Uống duy nhất 1 viên vào khung giờ cố định buổi sáng.",
      "pack": "Vỉ 10 viên"
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getFilteredMeds() {
    return _medications.where((med) {
      final matchCat = _activeCategory == "Tất cả" || med["cat"] == _activeCategory;
      final matchQuery = med["name"]!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          med["use"]!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      appBar: const GlassAppBar(title: "Nhà Thuốc & Đơn Thuốc"),
      body: GlassBackground(
        child: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            children: [
              // 1. Certified Prescriptions Section (if signed by Doctor in another role)
              ListenableBuilder(
                listenable: appState,
                builder: (context, child) {
                  final signedAppts = appState.appointments
                      .where((appt) => appt.prescriptionSigned && appt.prescriptionList.isNotEmpty)
                      .toList();

                  if (signedAppts.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment_turned_in, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "Đơn Thuốc Đã Cấp Điện Tử",
                            style: GlassTheme.h2(color: Colors.green).copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...signedAppts.map((appt) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GlassCard(
                          borderColor: Colors.green,
                          borderWidth: 1.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    appt.id,
                                    style: GlassTheme.labelCaps(color: GlassTheme.outline),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.verified, size: 10, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text(
                                          "ĐÃ KÝ ĐIỆN TỬ",
                                          style: GlassTheme.labelCaps(color: Colors.green).copyWith(fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Bác sĩ kê: ${appt.doctorName}",
                                style: GlassTheme.h3().copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${appt.specialty} • ${appt.branchName}",
                                style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Danh mục dược phẩm:",
                                      style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 9),
                                    ),
                                    const SizedBox(height: 6),
                                    ...appt.prescriptionList.map((med) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("• ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                          Expanded(
                                            child: Text(
                                              med,
                                              style: GlassTheme.bodyMd().copyWith(fontSize: 12, height: 1.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              if (appt.clinicalNotes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Ghi chú: ${appt.clinicalNotes}",
                                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white38),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

              // 2. Generic Medication Catalog
              Text(
                "Tra Cứu Dược Phẩm Gia Đình",
                style: GlassTheme.h2(color: GlassTheme.oceanBlue).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),

              // Search bar
              GlassTextField(
                controller: _searchController,
                label: "",
                hint: "Nhập tên thuốc hoặc triệu chứng...",
                prefixIcon: Icons.search,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Category tabs
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (ctx, index) {
                    final cat = _categories[index];
                    final active = _activeCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        backgroundColor: Colors.white.withOpacity(0.4),
                        selectedColor: GlassTheme.oceanBlue.withOpacity(0.15),
                        side: BorderSide(
                          color: active ? GlassTheme.oceanBlue : Colors.white30,
                          width: active ? 1.5 : 1.0,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        label: Text(
                          cat,
                          style: GlassTheme.bodyMd(
                            color: active ? GlassTheme.oceanBlue : GlassTheme.onSurfaceVariant,
                          ).copyWith(
                            fontWeight: active ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        selected: active,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _activeCategory = cat;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Catalog list
              if (_getFilteredMeds().isEmpty)
                const GlassCard(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text("Không tìm thấy sản phẩm dược nào phù hợp."),
                  ),
                )
              else
                ..._getFilteredMeds().map((med) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              med["name"]!,
                              style: GlassTheme.h3().copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: GlassTheme.oceanBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                med["cat"]!,
                                style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue).copyWith(fontSize: 8),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Chỉ định: ${med["use"]!}",
                          style: GlassTheme.bodyMd().copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Liều lượng: ${med["dose"]!}",
                          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: Colors.white30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Quy cách: ${med["pack"]!}",
                              style: GlassTheme.labelCaps(color: GlassTheme.outline).copyWith(fontSize: 9),
                            ),
                            Text(
                              "Miễn kê đơn",
                              style: GlassTheme.labelCaps(color: Colors.green).copyWith(fontSize: 9),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
