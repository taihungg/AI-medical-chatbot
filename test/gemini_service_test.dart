import 'dart:convert';

import 'package:ai_care_bridge/services/gemini_service.dart';
import 'package:ai_care_bridge/state/chat_directive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBotReplyJson', () {
    test('parses a report summary directive', () {
      final reply = parseBotReplyJson(jsonEncode({
        'text': 'Tôi đã tổng hợp tình trạng của bạn.',
        'setRiskLevel': 'Trung bình',
        'setSymptomsText': 'Triệu chứng chính: Đau đầu. Kèm theo: Buồn nôn.',
        'directive': {
          'type': 'reportSummary',
          'directiveId': 'report',
          'report': {
            'chiefComplaint': 'Đau đầu',
            'associated': ['Buồn nôn'],
            'severity': 6,
            'duration': '1 - 3 ngày',
            'riskLevel': 'Trung bình',
            'recommendation': 'Nên đặt lịch khám để đánh giá kỹ hơn.',
            'suggestedSpecialty': 'Khoa Thần kinh',
          },
        },
      }));

      expect(reply.text, contains('tổng hợp'));
      expect(reply.setRiskLevel, 'Trung bình');
      expect(reply.directive?.type, ChatComponentType.reportSummary);
      expect(reply.directive?.report?.suggestedSpecialty, 'Khoa Thần kinh');
    });

    test('parses a severity slider directive', () {
      final reply = parseBotReplyJson(jsonEncode({
        'text': 'Bạn đánh giá mức độ đau hiện tại là bao nhiêu?',
        'directive': {
          'type': 'severitySlider',
          'directiveId': 'severity',
          'prompt': 'Kéo thanh 1-10',
          'slider': {
            'min': 1,
            'max': 10,
            'divisions': 9,
            'minLabel': 'Nhẹ',
            'maxLabel': 'Rất nặng',
            'unitSuffix': '/10',
          },
        },
      }));

      expect(reply.directive?.type, ChatComponentType.severitySlider);
      expect(reply.directive?.slider?.max, 10);
    });

    test('rejects invalid directive shape', () {
      expect(
        () => parseBotReplyJson(jsonEncode({
          'text': 'Bạn chọn triệu chứng chính nhé.',
          'directive': {
            'type': 'quickPickChips',
            'directiveId': 'main_symptom',
            'options': [],
          },
        })),
        throwsA(isA<GeminiServiceException>()),
      );
    });
  });
}
