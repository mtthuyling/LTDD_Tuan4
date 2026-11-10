# Ghi chú để nhìn code và tự viết tay

**Bạn chỉ cần học chép `lib/main.dart`**; file `pubspec.yaml` để khai báo ảnh.

## Phần cơ bản

| Code / Hàm | Dùng để làm gì? | Ví dụ ngay trong bài |
|---|---|---|
| `main()` | Điểm bắt đầu chương trình | `runApp(...)` cho ứng dụng chạy |
| `MaterialApp` | Bọc toàn bộ ứng dụng theo kiểu Material | `home: SmartTasks()` |
| `StatefulWidget` | Màn hình có dữ liệu thay đổi | Khi bấm Next, đổi `manHinh` |
| `build()` | Vẽ giao diện mỗi lần Flutter cần | `return Scaffold(...)` |
| `setState(() { ... });` | Sửa dữ liệu và vẽ lại | `setState(() { manHinh = 1; });` |
| `TextEditingController` | Lấy nội dung người dùng gõ | `emailCtrl.text` lấy email |
| `.trim()` | Xóa dấu cách đầu và cuối | `' abc@uth.vn '.trim()` thành `'abc@uth.vn'` |
| `if` | Kiểm tra điều kiện | Email thiếu `@` thì báo lỗi |
| `return` | Dừng hàm ở đây | Email sai thì không được Next |
| `Column` | Xếp các widget từ trên xuống | Logo -> tiêu đề -> ô nhập -> nút |
| `Row` | Xếp widget từ trái qua phải | 5 ô nhập OTP |
| `SizedBox(height: 25)` | Tạo khoảng trống chiều dọc 25 | Khoảng cách giữa ô nhập và nút |
| `Padding` | Tạo khoảng cách **bên trong** | Cách mép trái phải của ô 12 |
| `Container` | Tạo khung, nền, kích thước | Hộp xanh nhận dữ liệu ở màn đầu |
| `Expanded` | Chiếm khoảng còn lại trong Row/Column | 5 ô OTP chia đều bề ngang |
| `TextField` | Ô cho phép gõ chữ | Email, password, OTP |
| `obscureText` | Che ký tự mật khẩu khi true | Bật/tắt icon con mắt |
| `onPressed` / `onTap` | Gọi hàm khi bấm | `onPressed: kiemTraOTP` |
| `SingleChildScrollView` | Cho màn hình cuộn | Bàn phím hiện vẫn kéo xuống được |
| `dispose()` | Giải phóng controller | `emailCtrl.dispose()` |

## Các hàm tự viết trong file main.dart

- `tiepTuEmail()`: lấy `emailCtrl.text`, kiểm tra có `@` và dấu `.`, rồi chuyển `manHinh = 1`.
- `kiemTraOTP()`: ghép 5 ô `otpCtrls` thành một chuỗi, so với `12345`. Đúng thì `manHinh = 2`.
- `kiemTraMatKhau()`: kiểm tra dài từ 6 ký tự và 2 ô giống nhau, rồi `manHinh = 3`.
- `xacNhan()`: đánh dấu đã xong và quay về `manHinh = 0`; hộp xanh cho thấy dữ liệu đã quay về.
- `quayLai()`: giảm `manHinh--` để trở về bước trước.
- `noiDung()`: chọn `manEmail()`, `manOTP()`, `manMatKhau()` hay `manXacNhan()` để vẽ.
- `thanhTrangThai()`: vẽ 9:41, sóng, Wi-Fi và pin trên khung điện thoại máy tính.
- `tieuDe()`: một hàm tạo tiêu đề chung, tránh viết bốn lần.
- `oNhap()`: một hàm tạo TextField chung; `laMatKhau: true` thì có nút mắt.
- `nut()`: một hàm tạo nút xanh dùng lại trên cả bốn màn hình.
- `hienLoi()`: in dòng chữ đỏ nếu chuỗi `loi` khác rỗng.
- `dongThongTin()`: ô chỉ đọc để xem email, OTP, mật khẩu ở màn Confirm.

## Vì sao dùng dấu `!` ở đây?

```dart
obscureText: laMatKhau && !hienMatKhau,
```

- `laMatKhau = true`: ô này là ô mật khẩu.
- `hienMatKhau = false`: người dùng đang **không** yêu cầu hiện mật khẩu.
- `!false` = `true`: mật khẩu được che.
- Bấm nút mắt chạy: `hienMatKhau = !hienMatKhau` để đổi qua lại true/false.

## Chú ý khi viết tay

Trong `main.dart`, có thể đọc từ trên xuống: **biến → hàm xử lý → build → widget dùng chung → 4 màn hình**. Các dòng `// ...` là giải thích, không ảnh hưởng khi chạy. Nếu thầy/cô yêu cầu code tối giản, bạn vẫn có thể giữ toàn bộ chú thích để trình bày.
