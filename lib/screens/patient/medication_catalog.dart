import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../widgets/glass_widgets.dart';

class MedicationCatalogScreen extends StatefulWidget {
  const MedicationCatalogScreen({super.key});

  @override
  State<MedicationCatalogScreen> createState() =>
      _MedicationCatalogScreenState();
}

class _MedicationCatalogScreenState extends State<MedicationCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeCategory = "Tất cả";
  String _searchQuery = "";

  final List<String> _categories = [
    "Tất cả",
    "Hô hấp",
    "Tim mạch",
    "Tiêu hóa",
    "Giảm đau"
  ];


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Medication> _getFilteredMeds() {
    return DatabaseService.instance.medications.where((med) {
      final matchCat =
          _activeCategory == "Tất cả" || med.category == _activeCategory;
      final matchQuery =
          med.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              med.usage.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      appBar: const GlassAppBar(title: "Nhà Thuốc & Đơn Thuốc", showBrandMark: false),
      body: GlassBackground(
        child: Scrollbar(
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            children: [
              // 1. Certified Prescriptions Section (if signed by Doctor in another role)
              ListenableBuilder(
                listenable: appState,
                builder: (context, child) {
                  final signedAppts = appState.appointments
                      .where((appt) =>
                          appt.prescriptionSigned &&
                          appt.prescriptionList.isNotEmpty)
                      .toList();

                  if (signedAppts.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment_turned_in,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "Đơn Thuốc Đã Cấp Điện Tử",
                            style: GlassTheme.h2(color: Colors.green)
                                .copyWith(fontSize: 16),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        appt.id,
                                        style: GlassTheme.labelCaps(
                                            color: GlassTheme.outline),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.verified,
                                                size: 10, color: Colors.green),
                                            const SizedBox(width: 4),
                                            Text(
                                              "ĐÃ KÝ ĐIỆN TỬ",
                                              style: GlassTheme.labelCaps(
                                                      color: Colors.green)
                                                  .copyWith(fontSize: 8),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Bác sĩ kê: ${appt.doctorName}",
                                    style: GlassTheme.h3().copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${appt.specialty} • ${appt.branchName}",
                                    style: GlassTheme.bodyMd(
                                            color: GlassTheme.onSurfaceVariant)
                                        .copyWith(fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Danh mục dược phẩm:",
                                          style: GlassTheme.labelCaps(
                                                  color: GlassTheme
                                                      .onSurfaceVariant)
                                              .copyWith(fontSize: 9),
                                        ),
                                        const SizedBox(height: 6),
                                        ...appt.prescriptionList.map((med) =>
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("• ",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Expanded(
                                                    child: Text(
                                                      med,
                                                      style: GlassTheme.bodyMd()
                                                          .copyWith(
                                                              fontSize: 12,
                                                              height: 1.3),
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
                                      style: GlassTheme.bodyMd(
                                              color:
                                                  GlassTheme.onSurfaceVariant)
                                          .copyWith(fontSize: 11),
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
                style: GlassTheme.h2(color: GlassTheme.oceanBlue)
                    .copyWith(fontSize: 18),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.4),
                        selectedColor:
                            GlassTheme.oceanBlue.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: active ? GlassTheme.oceanBlue : Colors.white30,
                          width: active ? 1.5 : 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        label: Text(
                          cat,
                          style: GlassTheme.bodyMd(
                            color: active
                                ? GlassTheme.oceanBlue
                                : GlassTheme.onSurfaceVariant,
                          ).copyWith(
                            fontWeight:
                                active ? FontWeight.bold : FontWeight.normal,
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
                                  med.name,
                                  style: GlassTheme.h3().copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: GlassTheme.oceanBlue
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    med.category,
                                    style: GlassTheme.labelCaps(
                                            color: GlassTheme.oceanBlue)
                                        .copyWith(fontSize: 8),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Chỉ định: ${med.usage}",
                              style: GlassTheme.bodyMd().copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Liều lượng: ${med.usage}",
                              style: GlassTheme.bodyMd(
                                      color: GlassTheme.onSurfaceVariant)
                                  .copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Colors.white30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Quy cách: ${med.type}",
                                  style: GlassTheme.labelCaps(
                                          color: GlassTheme.outline)
                                      .copyWith(fontSize: 9),
                                ),
                                Text(
                                  "Miễn kê đơn",
                                  style:
                                      GlassTheme.labelCaps(color: Colors.green)
                                          .copyWith(fontSize: 9),
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
