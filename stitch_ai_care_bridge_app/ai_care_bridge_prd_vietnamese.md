# PRD: AI Care Bridge - Hệ Thống Cầu Nối Y Tế Thông Minh

## 1. Tổng quan dự án (Project Overview)
**AI Care Bridge** là một ứng dụng y tế MVP được thiết kế theo phong cách Glassmorphism hiện đại, nhằm mục đích cung cấp giải pháp đánh giá triệu chứng ban đầu thông qua trí tuệ nhân tạo (AI) và kết nối người dùng với các dịch vụ y tế chuyên nghiệp.

### Tầm nhìn
Xây dựng niềm tin thông qua công nghệ, giúp người dùng bớt lo lắng về các triệu chứng sức khỏe và đưa ra quyết định thăm khám đúng lúc, đúng chỗ.

### Mục tiêu MVP
- Cung cấp luồng đánh giá triệu chứng bằng chatbot AI (không chẩn đoán, không kê đơn).
- Phân loại mức độ nghiêm trọng: Theo dõi tại nhà, Tư vấn trực tuyến, Khám tại phòng khám, hoặc Cấp cứu.
- Hỗ trợ đặt lịch hẹn tại 4 chi nhánh phòng khám (A, B, C, D).
- Cung cấp giao diện quản lý cho Bác sĩ, Chuyên gia và Quản lý phòng khám.

---

## 2. Đối tượng người dùng (User Roles)
1. **Bệnh nhân:** Người cần đánh giá sức khỏe và đặt lịch khám.
2. **Người dùng cần tư vấn nhanh:** Người muốn trò chuyện trực tuyến với bác sĩ.
3. **Bác sĩ:** Người trực tiếp tư vấn và quản lý bệnh nhân.
4. **Chuyên gia:** Quản lý hồ sơ bệnh án chuyên sâu và yêu cầu tư vấn.
5. **Quản lý phòng khám:** Theo dõi hiệu suất vận hành của các chi nhánh.

---

## 3. Các tính năng chính (Core Features)

### A. Đánh giá triệu chứng AI (AI Symptom Assessment)
- Chatbot hội thoại tự nhiên để thu thập triệu chứng.
- Chỉ báo tiến trình (Progress indicators) để giảm bớt sự mệt mỏi cho người dùng.
- Tuyên bố miễn trừ trách nhiệm y tế (Medical Disclaimer) rõ ràng.

### B. Kết quả & Đề xuất (Recommendation Results)
- Hiển thị kết luận dựa trên phân loại mức độ (Thấp/Trung bình/Cao/Khẩn cấp).
- Các nút hành động lớn (CTA) dẫn đến bước tiếp theo (Đặt lịch/Tư vấn/Cấp cứu).

### C. Đặt lịch hẹn (Appointment Booking)
- Lựa chọn chi nhánh (Phòng khám A, B, C, D).
- Lựa chọn bác sĩ chuyên khoa đã xác minh.
- Chọn ngày và giờ thông qua lịch tương tác.

### D. Tư vấn Bác sĩ (Doctor Consultation)
- Giao diện gọi video/chat trực tiếp.
- Xem chỉ số sinh tồn (Vitals) ngay trong phiên tư vấn.
- Gửi tin nhắn và tài liệu y tế bảo mật.

### E. Dashboard quản lý (Management Dashboards)
- **Bác sĩ/Chuyên gia:** Danh sách lịch hẹn, yêu cầu tư vấn mới, xem hồ sơ bệnh án.
- **Quản lý:** Thống kê tổng số bệnh nhân, số bác sĩ sẵn sàng, và hiệu suất vận hành (%).

---

## 4. Ngôn ngữ thiết kế (Design System)

### Phong cách (Aesthetic)
- **Glassmorphism:** Sử dụng hiệu ứng kính mờ (frosted glass), độ trong suốt linh hoạt, đổ bóng mềm mại và các góc bo tròn lớn.
- **Tâm lý học:** Tạo cảm giác trấn an, sạch sẽ và đáng tin cậy.

### Bảng màu (Color Palette)
- **Ocean Blue & Cyan:** Màu chủ đạo tạo sự tin tưởng và chuyên nghiệp.
- **Teal & White:** Màu bổ trợ cho sự sạch sẽ và tinh tế.

### Hệ thống chữ (Typography)
- **Poppins:** Sử dụng cho tiêu đề (Headlines) để tạo sự hiện đại, mạnh mẽ.
- **Inter:** Sử dụng cho nội dung (Body text) để tối ưu khả năng đọc trên thiết bị di động.

---

## 5. Danh sách màn hình (Screen List)
1. **Splash Screen:** Màn hình khởi động với thương hiệu.
2. **Home Dashboard:** Trung tâm điều hướng cho người dùng.
3. **AI Symptom Assessment:** Luồng trò chuyện với AI.
4. **Recommendation Result:** Kết quả phân loại triệu chứng.
5. **Appointment Booking:** Quy trình đặt lịch khám.
6. **Doctor Consultation:** Giao diện tư vấn trực tuyến.
7. **Specialist Dashboard:** Giao diện cho chuyên gia y tế.
8. **Clinic Management Dashboard:** Giao diện cho quản lý phòng khám.
