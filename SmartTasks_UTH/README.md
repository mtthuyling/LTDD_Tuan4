# SmartTasks UTH — Bài tập Flutter 4 màn hình

Dự án làm theo hình tham chiếu: **Forget Password → Verify Code → Create new password → Confirm → quay lại Forget Password**. Logo UTH được cắt từ hình mẫu do người dùng cung cấp.

## Cách chạy dễ nhất trên Windows 10 / VS Code

1. Giải nén ZIP ra một thư mục (ví dụ `D:\Flutter\SmartTasks_UTH`).
2. Mở thư mục bằng VS Code, mở **Terminal**.
3. Gõ lần lượt:

```powershell
flutter create --project-name smart_tasks_uth --platforms=android,web,windows .
flutter pub get
flutter run -d chrome
```

*Bạn cũng có thể nhấp đúp `CHAY_TREN_WINDOWS.bat` để tự động thực hiện các lệnh trên.*

Lệnh `flutter create .` sẽ bổ sung **các file nền tảng Android/Windows** của đúng phiên bản Flutter đang cài trên máy, không xóa `lib/main.dart` và các assets đã có. Flutter SDK phải được cài sẵn. Nếu chạy `flutter run` trên điện thoại Android hoặc giả lập Android, bạn có thể dùng `flutter run -d <device-id>` sau khi `flutter devices`.

## Thử bốn màn hình

1. **Forget Password:** nhập email (ví dụ `uth@gmail.com`) rồi bấm **Next**.
2. **Verify Code:** nhập **1 2 3 4 5** vào năm ô, rồi bấm **Next**.
3. **Create new password:** nhập mật khẩu từ **6 ký tự**, nhập lại giống hệt, bấm **Next**.
4. **Confirm:** xem email, OTP, mật khẩu đã được che; bấm **Submit** để quay về màn hình đầu. Ô xanh ở màn hình đầu nhận lại dữ liệu từ bước xác nhận (mật khẩu vẫn được ẩn).

Bấm mũi tên xanh để lùi về bước trước. Thử email không hợp lệ, OTP sai, hai mật khẩu khác nhau để xem thông báo lỗi.

## Quan trọng: dữ liệu giả lập, không có backend

- Mã OTP **12345** cố định trong code để thực hành luồng chuyển trang; ứng dụng **KHÔNG gửi email thật**.
- Email, OTP và mật khẩu chỉ nằm trong bộ nhớ ứng dụng khi chạy; **KHÔNG được gửi lên server hay lưu vào database**.
- Vì không có thông tin mật khẩu cũ nên không thể xác minh yêu cầu "khác mật khẩu trước" như mô tả trên hình.
- Hình mẫu có **5 ô OTP** nhưng màn hình Confirm minh họa số **123456** (6 chữ số). Mã demo dùng **5 số 12345** để thống nhất đúng với 5 ô của hình.
- Đây là **bài tập UI + điều hướng + truyền dữ liệu**, không phải chức năng đặt lại mật khẩu an toàn dùng trong sản phẩm thật.

## Cấu trúc file

```text
SmartTasks_UTH/
├── lib/
│   └── main.dart          <-- Toàn bộ code (có chú thích trực tiếp).
├── assets/
│   └── logo_uth.png       <-- Logo từ hình đề bài.
├── web/                   <-- File chạy trên Chrome.
├── pubspec.yaml           <-- Cấu hình và khai báo assets.
├── GHI_CHU_HAM.md         <-- Giải thích theo từng hàm + ví dụ.
├── CODE_NGAN_DE_CHEP.txt  <-- Bản code ngắn 233 dòng, chép thay main.dart.
└── CHAY_TREN_WINDOWS.bat  <-- Tự khởi tạo project và chạy Chrome.
```

**Muốn code ngắn để chép tay?** Mở `CODE_NGAN_DE_CHEP.txt` (233 dòng, có chú thích), sao chép toàn bộ vào `lib/main.dart` để chạy bản rút gọn. Bản mặc định trong `lib/main.dart` có giao diện được căn chỉnh giống ảnh hơn và chú thích kỹ hơn. Chỉ dùng **một bản** tại một thời điểm.

**Lưu ý về khung điện thoại:** mở trên máy tính/Chrome sẽ có vỏ điện thoại màu đen và giờ/pin/Wi-Fi minh họa. Mở trên điện thoại hoặc giả lập Android thì nội dung chiếm toàn màn hình và dùng thanh trạng thái của hệ điều hành, tránh "điện thoại lồng điện thoại".
