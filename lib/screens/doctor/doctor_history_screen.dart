import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

class DoctorHistoryScreen extends StatefulWidget {
  const DoctorHistoryScreen({super.key});

  @override
  State<DoctorHistoryScreen> createState() => _DoctorHistoryScreenState();
}

class _DoctorHistoryScreenState extends State<DoctorHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    
    // Lọc lịch sử khám (chỉ những ca đã khám)
    final history = appState.appointments.where((appt) {
      if (appt.status != 'Đã khám') return false;
      if (_searchQuery.isNotEmpty) {
        return appt.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
               appt.id.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
    
    // Sort by date descending
    history.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: const GlassAppBar(
        title: "Lịch sử ca khám",
        automaticallyImplyLeading: false,
      ),
      body: GlassBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassTextField(
                controller: TextEditingController(text: _searchQuery),
                label: "Tìm kiếm",
                hint: "Tìm theo tên hoặc ID bệnh nhân...",
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: history.isEmpty
                    ? const Center(
                        child: Text(
                          "Chưa có lịch sử ca khám nào.",
                          style: TextStyle(color: GlassTheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final appt = history[index];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Material(
                              color: Colors.transparent,
                              child: ExpansionTile(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: GlassTheme.oceanBlue,
                                    child: Text(
                                      appt.patientName[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${appt.patientName} (Mã ca: ${appt.id})",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${appt.dateTime.day}/${appt.dateTime.month}/${appt.dateTime.year} - ${appt.timeSlot}",
                                          style: const TextStyle(fontSize: 12, color: GlassTheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text("Đã khám", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                  )
                                ],
                              ),
                              children: [
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle("Triệu chứng ban đầu:"),
                                      Text(appt.symptomSummary),
                                      const SizedBox(height: 12),
                                      _buildSectionTitle("Ghi chú SOAP:"),
                                      Text(appt.clinicalNotes.isEmpty ? "Không có ghi chú" : appt.clinicalNotes),
                                      const SizedBox(height: 12),
                                      _buildSectionTitle("Đơn thuốc (E-Prescription):"),
                                      if (appt.prescriptionList.isEmpty)
                                        const Text("Không kê đơn")
                                      else
                                        ...appt.prescriptionList.map((med) => Text("- $med")),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: GlassTheme.oceanBlue),
      ),
    );
  }
}
