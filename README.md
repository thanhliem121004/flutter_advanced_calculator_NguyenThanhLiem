# Máy Tính Nâng Cao - Flutter Advanced Calculator

## Thông Tin Sinh Viên

- **Họ tên:** Nguyễn Thanh Liêm
- **MSSV:** 2224802010267
- **Lớp:** CNTT-K26

---

## Mô Tả Dự Án

Đây là ứng dụng máy tính nâng cao được xây dựng bằng Flutter, hỗ trợ ba chế độ tính toán: Cơ Bản, Khoa Học, và Lập Trình Viên. Dự án sử dụng Provider cho quản lý trạng thái, SharedPreferences cho lưu trữ dữ liệu, và có đầy đủ các bài test đơn vị.

---

## Tính Năng Chính

### Chế Độ Máy Tính

1. **Chế Độ Cơ Bản** - Các phép tính + - × ÷ %, hỗ trợ dấu ngoặc, đổi dấu, xóa ký tự
2. **Chế Độ Khoa Học** - Tròn, Log, căn, lũy thừa, giai thừa, hằng số π và e
3. **Chế Độ Lập Trình Viên** - Chuyển đổi cơ số (BIN/OCT/DEC/HEX), phép toán bitwise (AND, OR, XOR, NOT, dịch bit)

### Tính Năng Nâng Cao

- **Bộ nhớ (M+, M-, MR, MC)** - Lưu và sử dụng giá trị trong bộ nhớ
- **Lịch sử tính toán** - Lưu 50 phép tính gần nhất, có thể xóa từng mục hoặc xóa tất cả
- **Chế độ DEG/RAD** - Chuyển đổi đơn vị góc cho các phép tính lượng giác
- **Độ chính xác thập phân** - Từ 2 đến 10 chữ số thập phân
- **Hỗ trợ Dark/Light Theme** - Chuyển đổi giữa hai chế độ giao diện

---

## Cấu Trúc Dự Án

```
lib/
├── main.dart                     # Entry point, cấu hình Provider
├── models/
│   ├── calculator_mode.dart     # Enum chế độ máy tính
│   ├── calculator_settings.dart  # Cấu hình người dùng
│   └── calculation_history.dart # Bản ghi lịch sử
├── providers/
│   ├── calculator_provider.dart  # Logic tính toán, state management
│   ├── history_provider.dart     # Quản lý lịch sử tính toán
│   └── theme_provider.dart       # Quản lý giao diện (Dark/Light)
├── screens/
│   ├── calculator_screen.dart    # Màn hình chính
│   ├── history_screen.dart       # Màn hình lịch sử
│   └── settings_screen.dart      # Màn hình cấu hình
├── services/
│   └── storage_service.dart      # Lưu trữ SharedPreferences
├── utils/
│   ├── calculator_logic.dart     # Các hàm tính toán cơ bản
│   ├── constants.dart            # Hằng số: màu sắc, font, kích thước
│   └── expression_parser.dart    # Xử lý biểu thức toán học
└── widgets/
    ├── button_grid.dart          # Lưới nút bấm
    ├── calculator_button.dart    # Nút bấm đơn lẻ
    ├── display_area.dart         # Khung hiển thị kết quả
    └── mode_selector.dart        # Bộ chọn chế độ
```

---

## Bảng Màu Thiết Kế

| Thuộc tính   | Light Theme | Dark Theme |
|--------------|-------------|------------|
| Background   | #F5F5F5     | #0D0D0D    |
| Surface      | #FFFFFF     | #1E1E1E    |
| Accent       | #FF6B6B     | #4ECDC4    |
| Text         | #1E1E1E     | #FFFFFF    |

---

## Tài Khoản Test

### Test Phép Tính Cơ Bản

- `5 + 3 = 8`
- `10 - 4 = 6`
- `6 × 7 = 42`
- `20 ÷ 4 = 5`
- `(5 + 3) × 2 - 4 ÷ 2 = 14`

### Test Khoa Học

- `sin(45°) + cos(45°) ≈ 1.414`
- `2 × π × √9 ≈ 18.85`
- `log(100) = 2`
- `5! = 120`

### Test Luận Lý

- `5 + 3 + 2 + 1 = 11`
- `((2 + 3) × (4 - 1)) ÷ 5 = 3`

---

## Hướng Dẫn Cài Đặt

### Yêu Cầu

- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Android SDK (cho build Android)

### Các Bước Cài Đặt

1. **Clone repository:**
```bash
git clone https://github.com/username/flutter_advanced_calculator_thanhliem.git
cd flutter_advanced_calculator_thanhliem
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

## Hướng Dẫn Test

### Chạy tất cả bài test:
```bash
flutter test
```

### Chỉ chạy test tính toán:
```bash
flutter test test/expression_parser_test.dart
flutter test test/calculator_logic_test.dart
```

### Chỉ chạy test model:
```bash
flutter test test/models_test.dart
```

---

## Hạn Chế

- Chế độ programmer chỉ hỗ trợ số nguyên (không phải số thực)
- Không hỗ trợ số phức
- Hàm nghịch đảo lượng giác (asin, acos, atan) cần cập nhật thêm trong provider

---

## Hướng Phát Triển

- Hỗ trợ nhập biểu thức dạng chuỗi
- Vẽ đồ thị hàm số y = f(x)
- Xuất lịch sử ra file CSV/PDF
- Thêm âm thanh và haptic feedback tùy chọn

---

## Ghi Chú Thêm

- Sinh viên tự làm, không sử dụng code từ internet
- Bài tập nộp đúng deadline: 11:59 PM - 24/04/2026
- Repository GitHub: flutter_advanced_calculator_thanhliem

---

## License

Dự án học tập - Không dùng cho mục đích thương mại.
