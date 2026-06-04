# AI Care Bridge — Mô tả dự án & Định hướng phát triển

> Tài liệu tổng quan kiến trúc và lộ trình. Cập nhật lần cuối: 2026-06.

---

## 1. Tổng quan

**AI Care Bridge** — ứng dụng **cầu nối y tế thông minh** viết bằng **Flutter** (iOS/Android/web/desktop), giao diện tiếng Việt, phong cách **glassmorphism** (kính mờ, gradient ocean-blue/cyan).

**3 vai trò người dùng** (chọn ở màn splash):
- **Người dùng & Bệnh nhân** — chat với AI, đặt lịch khám, lịch sử y khoa.
- **Bác sĩ & Chuyên gia lâm sàng** — hàng đợi khám, workspace lâm sàng (SOAP), ký đơn thuốc số.
- **Ban điều hành & Quản lý** — dashboard thống kê, quản lý bác sĩ / lịch hẹn / hồ sơ.

**Quản lý state:** singleton `AppState extends ChangeNotifier` (`lib/state/app_state.dart`). Không dùng package state-management ngoài; dữ liệu mô phỏng in-memory.

**Theme dùng chung:** `lib/widgets/glass_widgets.dart` — `GlassTheme`, `GlassCard`, `GlassButton`, `GlassTextField`, `GlassAppBar`, `GlassNavigationBar`, `GlassBackground`.

---

## 2. Màn hình Bệnh nhân — 3 tab

Điều hướng dưới cùng: **Tư vấn AI** | **Đặt lịch** | **Lịch sử**.

### 2.1. Triết lý thiết kế chatbot

> **App đơn giản là chat với chatbot; khi cần thì đặt lịch khám.**

Đã **bỏ luồng đánh giá cứng nhiều bước** cũ (thanh tiến trình khảo sát, card duration/severity tĩnh, overlay "AI đang phân tích", màn phân loại nguy cơ riêng).

Điểm khác biệt so với chat Gemini thuần: **chatbot tự sinh component tương tác động** ngay trong khung chat (bot điều phối UI):
- Hỏi "đang bị sao?" → hiện **chips** ("Đau đầu", "Đau bụng", "Đau ngực"…).
- Chọn "Đau đầu" → sinh **lựa chọn con** liên quan (multi-select triệu chứng kèm theo).
- Hỏi mức độ → hiện **slider 1–10**. Hỏi thời gian → **bộ chọn khoảng thời gian**.
- Người dùng **vẫn gõ tin nhắn tự do bất cứ lúc nào**.

Đủ thông tin → bot tạo **báo cáo có cấu trúc** + nút **"Đặt lịch khám"** → nhảy sang tab Đặt lịch, điền sẵn + tự chọn chuyên khoa.

### 2.2. Kiến trúc "AI sinh UI" (sẵn sàng cho Gemini)

Thiết kế để **swap sang Gemini mà không sửa UI**:

```
User (tap chip / kéo slider / gõ text)
   │
   ▼  AppState.sendChatMessage()  HOẶC  AppState.respondToDirective()
   ▼
_generateBotReply(ChatTurnContext) → BotReply        ◄── SEAM DUY NHẤT
   │     (MVP: ConversationEngine scripted; sau: GeminiService)
   ▼
ChatMessage{ text, directive } → notifyListeners()
   ▼
UI: directive.type → widget tương tác
```

| File | Vai trò |
|------|---------|
| `lib/state/chat_directive.dart` | Models: `ChatComponentType`, `ChatOption`, `ChatUiDirective`, `SliderSpec`, `ReportData`, `BotReply`, `ChatTurnContext` — kèm `fromJson/toJson` (đúng JSON Gemini sẽ trả về). |
| `lib/state/conversation_graph.dart` | `ConversationEngine` — cây hội thoại dạng **dữ liệu** (decision tree). Bộ não mô phỏng tạm thời. |
| `lib/widgets/chat_directives.dart` | 7 widget render component. |
| `lib/screens/patient/symptom_flow.dart` | Màn chat — thin shell: render message + dispatch directive, forward đáp án về AppState. |

**7 loại component:** `quickPickChips`, `multiSelectChips`, `severitySlider`, `timeRangePicker`, `yesNo`, `bodyPartPicker`, `reportSummary`.

### 2.3. Tab Đặt lịch — `appointment_booking_tab.dart`
3 bước: hình thức (trực tiếp/trực tuyến) & cơ sở → ngày giờ → xác nhận. Tự nhận `selectedSymptomsText` + `currentRiskLevel` từ chatbot, điền sẵn, tự phân khoa theo từ khóa. Banner "AI Khuyến Nghị Đặt Lịch" + badge nguy cơ.

### 2.4. Màn cấp cứu — `emergency_screens.dart`
`SOSEmergencyAlertScreen` (đếm ngược gọi 115, nút hủy) + `SelfCareScreen`. Truy cập qua nút SOS trên AppBar màn chat, hoặc khi bot phát hiện khẩn cấp.

---

## 3. Định hướng phát triển

1. **Tích hợp Gemini API** — bước lớn tiếp theo. Chỉ thay thân `_generateBotReply()`: gọi Gemini với lịch sử hội thoại, prompt trả JSON đúng schema `chat_directive.dart`. **UI / widget / luồng tab không đổi** — `fromJson` đã sẵn.
2. **Pipeline chatbot hoàn chỉnh** — AI hiểu tình trạng, khuyên đúng lúc, tự quyết định sinh component nào & khi nào khuyên khám.
3. **AI tự tạo component linh hoạt** (không kịch bản cố định) — có thể mở rộng loại component mới; data shape đã chuẩn hóa.
4. **MVP chạy được trên iPhone simulator** — ưu tiên luồng chính trước.

---

## 4. Cấu trúc thư mục `lib/`

```
lib/
├── main.dart                       # entry, theme, home: SplashScreen
├── state/
│   ├── app_state.dart              # singleton state + seam _generateBotReply
│   ├── chat_directive.dart         # models directive (Gemini-ready)
│   └── conversation_graph.dart     # ConversationEngine (scripted brain)
├── widgets/
│   ├── glass_widgets.dart          # design system
│   ├── chat_directives.dart        # 7 widget component tương tác
│   └── role_switcher.dart          # overlay đổi vai trò
└── screens/
    ├── splash_screen.dart          # chọn vai trò + MainFramework (shell 3 tab)
    ├── patient/
    │   ├── symptom_flow.dart        # tab Tư vấn AI (chat)
    │   ├── appointment_booking_tab.dart  # tab Đặt lịch
    │   ├── patient_history_screen.dart   # tab Lịch sử
    │   ├── emergency_screens.dart   # SOS + tự chăm sóc
    │   └── medication_catalog.dart  # tủ thuốc (phụ)
    ├── doctor/
    │   ├── specialist_dashboard.dart     # dashboard bác sĩ
    │   ├── clinical_workspace.dart       # workspace lâm sàng (SOAP)
    │   ├── doctor_components.dart
    │   ├── doctor_timetable_screen.dart
    │   └── recording_visualizer.dart
    └── manager/
        ├── clinic_management_dashboard.dart
        ├── doctor_management_screen.dart
        ├── master_appointment_screen.dart
        └── patient_records_screen.dart
```

---

## 5. Quy ước

- **Ngôn ngữ UI:** tiếng Việt.
- **Màu nguy cơ:** Thấp = xanh lá · Trung bình = ocean-blue · Cao = cam · Khẩn cấp = đỏ.
- **Mức độ nguy cơ:** `'Thấp' | 'Trung bình' | 'Cao' | 'Khẩn cấp'`.
- **Khi thêm loại component mới:** thêm vào `ChatComponentType`, cập nhật `fromJson/toJson`, thêm widget trong `chat_directives.dart`, thêm nhánh dispatch trong `symptom_flow.dart`.
- **Khi tích hợp Gemini:** chỉ sửa `_generateBotReply()` trong `app_state.dart`; giữ nguyên schema directive.
