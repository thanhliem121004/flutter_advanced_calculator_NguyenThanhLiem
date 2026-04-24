# Máy Tính Nâng Cao - Flutter Advanced Calculator

## Thông Tin Sinh Viên

- **Họ tên:** Nguyễn Thanh Liêm
- **MSSV:** 2224802010267
- **Lớp:** CNTT-K26

---

## Mô Tả Dự Án

Đây là ứng dụng máy tính nâng cao được xây dựng bằng Flutter, hỗ trợ ba chế độ tính toán: Cơ Bản, Khoa Học, và Lập Trình Viên. Dự án sử dụng Provider cho quản lý trạng thái, SharedPreferences cho lưu trữ dữ liệu.

---

## Tính Năng Chính

### Chế Độ Máy Tính

1. **Chế Độ Cơ Bản** - Các phép tính + - × ÷ %, hỗ trợ dấu ngoặc, đổi dấu, xóa ký tự
2. **Chế Độ Khoa Học** - sin, cos, tan, asin, acos, atan, log, ln, sqrt, cbrt, lũy thừa, giai thừa, hằng số π và e
3. **Chế Độ Lập Trình Viên** - Chuyển đổi cơ số (BIN/OCT/DEC/HEX), phép toán bitwise (AND, OR, XOR, NOT, SHL, SHR)

### Tính Năng Nâng Cao

- **Bộ nhớ (M+, M-, MR, MC)** - Lưu và sử dụng giá trị trong bộ nhớ
- **Lịch sử tính toán** - Lưu tối đa 100 phép tính gần nhất, có thể xóa từng mục hoặc xóa tất cả
- **Chế độ DEG/RAD** - Chuyển đổi đơn vị góc cho các phép tính lượng giác
- **Độ chính xác thập phân** - Từ 2 đến 10 chữ số thập phân
- **Hỗ trợ Dark/Light Theme** - Chuyển đổi giữa hai chế độ giao diện
- **Haptic Feedback & Âm thanh** - Bật/tắt trong cài đặt
- **Vuốt xóa ký tự** - Vuốt phải để xóa
- **Zoom thu phóng** - Chụm để thay đổi cỡ chữ
- **Hoạt ảnh rung** - Khi có lỗi tính toán

---

## Cấu Trúc Dự Án

```
lib/
├── main.dart                          # Entry point, cấu hình Provider
├── models/
│   ├── calculator_mode.dart           # Enum chế độ máy tính
│   ├── calculator_settings.dart        # Cấu hình người dùng
│   └── calculation_history.dart       # Bản ghi lịch sử
├── providers/
│   ├── calculator_provider.dart       # Logic tính toán, state management
│   ├── history_provider.dart          # Quản lý lịch sử tính toán
│   └── theme_provider.dart            # Quản lý giao diện (Dark/Light)
├── screens/
│   ├── calculator_screen.dart         # Màn hình chính
│   ├── history_screen.dart            # Màn hình lịch sử
│   └── settings_screen.dart           # Màn hình cài đặt
├── services/
│   └── storage_service.dart          # Lưu trữ SharedPreferences
├── utils/
│   ├── calculator_logic.dart         # Các hàm tính toán cơ bản
│   ├── constants.dart                # Hằng số: màu sắc, font, kích thước
│   └── expression_parser.dart        # Xử lý biểu thức toán học (recursive descent parser)
└── widgets/
    ├── button_grid.dart              # Lưới nút bấm
    ├── calculator_button.dart        # Nút bấm đơn lẻ với animation
    ├── display_area.dart             # Khung hiển thị kết quả
    └── mode_selector.dart            # Bộ chọn chế độ
```

---

## Bảng Màu Thiết Kế

| Thuộc tính   | Light Theme | Dark Theme  |
|--------------|-------------|------------|
| Background   | #F5F5F5     | #0D0D0D    |
| Surface      | #FFFFFF     | #1E1E1E    |
| Accent       | #FF6B6B     | #4ECDC4    |
| Text         | #1E1E1E     | #FFFFFF    |

---

## Hướng Dẫn Cài Đặt

### Yêu Cầu

- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Android SDK (cho build Android)

### Các Bước Cài Đặt

1. **Clone repository:**
```bash
git clone https://github.com/thanhliem121004/flutter_advanced_calculator_NguyenThanhLiem.git
cd flutter_advanced_calculator_NguyenThanhLiem
```

2. **Cài đặt dependencies:**
```bash
flutter pub get
```

3. **Chạy ứng dụng:**
```bash
flutter run
```

4. **Build APK:**
```bash
flutter build apk --debug
```

---

## Hạn Chế

- Chế độ programmer chỉ hỗ trợ số nguyên
- Không hỗ trợ số phức

---

## License

Dự án học tập - Không dùng cho mục đích thương mại.
