1. Cấu trúc Thẻ (Card Layout) tốn diện tích: Một màn hình chỉ hiển thị được 2-3 lịch hẹn. Trải nghiệm cuộn dọc liên tục sẽ khiến nhân viên điều phối dễ bỏ sót thông tin và mệt mỏi.

Đề xuất Thiết kế Mới: Chuyển đổi sang dạng Bảng dữ liệu (Data Table) hoặc cấu trúc danh sách lưới nén (Compact List) để hiển thị được 10-15 lịch hẹn trên cùng một màn hình.

Nguyên lý UI/UX áp dụng (Theo tài liệu SOICT): Giảm tải bộ nhớ ngắn hạn (Reduce short-term memory load): Con người chỉ có thể xử lý 7 ± 2 mẩu thông tin cùng lúc. Việc sử dụng bảng giúp người dùng không phải ghi nhớ thông tin khi cuộn trang, dễ dàng so sánh các lịch hẹn với nhau.

2. Thiếu Thanh tìm kiếm và Bộ lọc Thời gian: Không có công cụ để tìm nhanh một bệnh nhân hoặc lọc lịch hẹn theo một ngày/tuần cụ thể.

Đề xuất Thiết kế Mới: Bổ sung Thanh tìm kiếm và Bộ chọn ngày (Date Picker) ngay phía trên danh sách.

Nguyên lý UI/UX áp dụng (Theo tài liệu SOICT): Khả năng kiểm soát hệ thống (Internal locus of control): Thiết kế cần hỗ trợ người dùng chủ động tìm kiếm và kiểm soát dữ liệu mong muốn thay vì bị động lướt qua danh sách.

3. Nút Filter nổi (FAB) gây cản trở: Có một nút màu xanh lơ lửng ở góc dưới phải, đè lên các nút chức năng "Từ chối/Phê duyệt" của thẻ.

Đề xuất Thiết kế Mới: Loại bỏ hoàn toàn nút Filter nổi. Tích hợp mọi bộ lọc (Theo khoa, theo loại hình khám) lên thanh công cụ (Toolbar) trên cùng.

Nguyên lý UI/UX áp dụng (Theo tài liệu SOICT): Ràng buộc vật lý (Physical Constraints) & Tính Trực quan (Visibility): Các thành phần giao diện không được che khuất nhau, gây khó khăn cho thao tác vật lý (fat-finger error).

4. Sự dư thừa thông tin (Redundancy): Đang ở Tab "Chờ duyệt", nhưng mỗi thẻ bên dưới đều lặp lại tag "Chờ duyệt" ở góc phải.

Đề xuất Thiết kế Mới: Loại bỏ tag "Chờ duyệt" bên trong các hàng dữ liệu khi người dùng đang đứng ở Tab này.

Nguyên lý UI/UX áp dụng (Theo tài liệu SOICT): Nguyên tắc Tiết kiệm (Economy) và Đơn giản: Người dùng làm được nhiều nhất với ít các dấu hiệu và yếu tố thị giác nhất. Loại bỏ các phần tử không chuyển tải thêm thông điệp chức năng.