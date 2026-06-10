# Phân tích UI/UX - Phân hệ Manager

## 1. Màn hình Quản lý Bác sĩ (doctor_management_screen.dart)

### Áp dụng nguyên tắc Don Norman & Ben Shneiderman:
- **Đồng bộ Concept (Consistency):**
  - Màn hình sử dụng `GlassBackground` bao phủ toàn bộ Scaffold, kết hợp với `AppBar` có `backgroundColor: Colors.transparent` và `elevation: 0` để đảm bảo nền Glassmorphism chạy mượt mà từ trên xuống dưới, không bị đường phân cách cứng của AppBar truyền thống.
  - Các phần tử như thanh tìm kiếm, bộ lọc và thẻ danh sách bác sĩ đều được bọc bởi `GlassCard` và `GlassTextField` từ hệ thống Design Token `glass_widgets.dart`.
  
- **Reduce short-term memory load (Giảm tải trí nhớ ngắn hạn):**
  - Cung cấp ô tìm kiếm (Tìm theo tên hoặc ID) và Dropdown lọc chuyên khoa ngay trên đầu trang. Người dùng không cần phải ghi nhớ hay lướt tìm trong danh sách dài.
  - Ô tìm kiếm có nút **Clear (Icon X)** tự động xuất hiện khi có chữ, giúp xóa nhanh cụm từ vừa nhập mà không cần bôi đen xóa tay (Affordance & Efficiency).

- **Visibility & Affordances (Khả năng hiển thị và Cung cấp gợi ý):**
  - Nút thêm bác sĩ sử dụng `FloatingActionButton.extended` có cả Icon (`Icons.add`) và Label (`Thêm Bác sĩ`), được đổ màu `oceanBlue` nổi bật. Nó cung cấp lời mời gọi hành động (Call-to-Action) rất rõ ràng thay vì chỉ dùng 1 nút dấu cộng (+) đơn điệu.
  - Trạng thái bác sĩ (Hoạt động / Nghỉ phép) được thiết kế đi kèm Icon và màu sắc tương ứng (Xanh lá / Cam), giúp Manager quét mắt (scan) qua danh sách cực kỳ nhanh.
  
- **Feedback (Phản hồi hệ thống):**
  - Mọi thao tác đều có phản hồi. Khi nhấn **Xóa bác sĩ**, một `Snackbar` nổi lên (với màu Teal nhẹ nhàng của GlassTheme) để thông báo "Đã xóa bác sĩ... thành công" kèm theo icon tick xanh. 
  - Khi gõ phím tìm kiếm, danh sách bên dưới lập tức cập nhật (Real-time feedback).

---

## 2. Màn hình Quản lý Bệnh nhân & Hồ sơ (patient_records_screen.dart)

### Áp dụng nguyên tắc Don Norman & Ben Shneiderman:
- **Đồng bộ Concept (Consistency):**
  - Tiếp tục sử dụng chung các component từ `GlassTheme`: `GlassBackground`, `GlassCard`, `GlassTextField`. Điều này tạo ra sự quen thuộc ngay lập tức cho Manager khi chuyển từ tab Bác sĩ sang tab Bệnh nhân.
  
- **Reduce short-term memory load (Giảm tải trí nhớ ngắn hạn):**
  - **Thông tin thẻ bệnh nhân:** Thay vì giấu thông tin bên trong trang chi tiết, thẻ hiển thị ngay ra ngoài các thông tin thiết yếu nhất (Mã BN, Giới tính, Tuổi, Ngày khám gần nhất). Manager không cần phải nhớ hay phải bấm vào mới xem được.
  - **Filter Chips:** Ngay dưới ô search là một hàng `ChoiceChip` (Tất cả, Bệnh nhân mới, Đang điều trị...). Nhờ trải ra theo chiều ngang, người dùng nhìn thấy ngay toàn bộ các bộ lọc khả dụng mà không phải "đoán" xem hệ thống có những trạng thái nào (tốt hơn việc giấu vào trong Dropdown).

- **Visibility & Affordances (Khả năng hiển thị và Cung cấp gợi ý):**
  - Nút **"Chi tiết"** trên mỗi thẻ bệnh nhân được thiết kế kết hợp với Icon mũi tên hướng sang phải (`Icons.chevron_right`). Theo tâm lý học UI, mũi tên hướng sang phải ngầm định (Affordance) một hành động đi tiếp, chuyển trang, thôi thúc người dùng click vào để khám phá thông tin chi tiết.

- **Feedback & Error Prevention (Phản hồi & Ngăn ngừa lỗi):**
  - **Trạng thái trống (Empty State):** Khi tìm kiếm một từ khóa không tồn tại (vd: "abc"), thay vì hiển thị một màn hình trắng trơn làm người dùng tưởng app bị treo (Error), hệ thống ngay lập tức hiển thị một Empty State thân thiện kèm Icon `search_off` lớn và dòng text giải thích rõ ràng: *"Từ khóa không khớp... Bạn thử kiểm tra lại mã BN hoặc lỗi chính tả"*. Điều này giúp điều hướng cảm xúc người dùng (Feedback tích cực).

---

## 3. Màn hình Lịch hẹn Tổng (master_appointment_screen.dart)

### Áp dụng nguyên tắc Don Norman & Ben Shneiderman:
- **Reduce short-term memory load (Giảm tải trí nhớ ngắn hạn qua TabBar):**
  - Sử dụng `DefaultTabController` kết hợp `TabBar` với 3 tab: Chờ duyệt, Đã xác nhận, Lịch sử. Việc này giúp phân mảnh dữ liệu (chunking) hợp lý, người dùng không bị "ngợp" trước hàng dài lịch hẹn lộn xộn. Họ không phải vất vả nhớ xem lịch nào đã duyệt, lịch nào chưa.

- **Constraints & Error Prevention (Ràng buộc & Ngăn chặn lỗi):**
  - **Trạng thái nút bấm:** Chỉ trong tab "Chờ duyệt" thì 2 nút hành động (Phê duyệt và Từ chối) mới được hiển thị. Ở các tab khác, các nút này bị ẩn đi bằng điều kiện `if (isPending)` trong code. Điều này ngăn chặn triệt để (Constraint) việc Manager vô tình bấm duyệt 2 lần hoặc hủy nhầm một lịch hẹn đã qua (Error Prevention).

- **Permit easy reversal of actions (Cho phép đảo ngược/hoàn tác dễ dàng):**
  - Hành động phá hủy (Từ chối/Hủy lịch) luôn đi kèm với một `AlertDialog` để hỏi lại (Xác nhận). Nút đóng/hủy trong dialog đóng vai trò như một lối thoát an toàn (Easy Reversal), giúp người dùng không bao giờ rơi vào tình trạng lỡ tay xóa mất lịch của bệnh nhân mà không thể khôi phục.

- **Feedback & Đồng bộ Concept:**
  - Hệ thống lập tức trả về `Snackbar` thông báo (Feedback) sau mỗi lần nhấn Phê duyệt hoặc Hủy thành công.
  - Các thẻ lịch hẹn tiếp tục sử dụng `GlassCard` với độ bo góc (BorderRadius = 20) và màu nền trong suốt mờ ảo, đồng bộ chuẩn xác với bộ mã thiết kế trong `GlassTheme`. Màu sắc của các nhãn trạng thái (Label) cũng được ánh xạ logic: Chờ duyệt (Cam), Đã xác nhận (Xanh lá), Đã hủy (Đỏ), giúp quy trình quét thông tin trực quan hơn rất nhiều.
