import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Đã khám':
        color = Colors.green;
        break;
      case 'Đang khám':
        color = Colors.orange;
        break;
      default:
        color = GlassTheme.oceanBlue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GlassTheme.labelCaps(color: color).copyWith(fontSize: 9),
      ),
    );
  }
}
