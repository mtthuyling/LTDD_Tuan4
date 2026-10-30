import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CHẠY ỨNG DỤNG: Flutter bắt đầu chạy từ hàm main().
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, // Bỏ chữ DEBUG ở góc màn hình.
    home: SmartTasks(), // Màn hình chính của ứng dụng.
  ));
}

// StatefulWidget: giao diện có thể thay đổi khi bấm nút, nhập dữ liệu.
class SmartTasks extends StatefulWidget {
  const SmartTasks({super.key});

  @override
  State<SmartTasks> createState() => _SmartTasksState();
}

class _SmartTasksState extends State<SmartTasks> {
  // 0: Quên mật khẩu; 1: Nhập OTP; 2: Mật khẩu mới; 3: Xác nhận.
  int manHinh = 0;
  String loi = ''; // Lưu lỗi để hiển thị ngay dưới nút.
  bool daHoanTat = false;
  bool hienMatKhau = false;

  // Controller lấy chữ người dùng gõ trong ô nhập.
  final emailCtrl = TextEditingController();
  final matKhauCtrl = TextEditingController();
  final nhapLaiCtrl = TextEditingController();

  // Tạo 5 ô nhập OTP, mỗi ô giữ một chữ số.
  final otpCtrls = List.generate(5, (_) => TextEditingController());

  static const xanh = Color(0xFF4999EC);
  static const nenO = Color(0xFFF8F8FB);
  static const xam = Color(0xFF8E919B);

  // dispose(): đóng controller khi rời ứng dụng để tránh tốn bộ nhớ.
  @override
  void dispose() {
    emailCtrl.dispose();
    matKhauCtrl.dispose();
    nhapLaiCtrl.dispose();
    for (final o in otpCtrls) {
      o.dispose();
    }
    super.dispose();
  }

  // setState(): báo Flutter vẽ lại giao diện sau khi thay đổi dữ liệu.
  void tiepTuEmail() {
    final email = emailCtrl.text.trim(); // .trim() xóa khoảng trắng hai đầu.
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => loi = 'Hãy nhập địa chỉ email hợp lệ.');
      return; // Sai email thì KHÔNG chuyển màn hình.
    }

    for (final o in otpCtrls) {
      o.clear(); // Email mới thì xóa mã OTP cũ.
    }
    matKhauCtrl.clear();
    nhapLaiCtrl.clear();
    setState(() {
      loi = '';
      daHoanTat = false;
      manHinh = 1; // Chuyển sang màn hình nhập OTP.
    });
  }

  // Bài tập DEMO: mã OTP cố định 12345, không gửi email thật.
  void kiemTraOTP() {
    final otp = otpCtrls.map((o) => o.text).join(); // Ghép 5 ô thành 1 mã.
    if (otp != '12345') {
      setState(() => loi = 'Mã OTP sai. Mã demo là 12345.');
      return;
    }
    setState(() {
      loi = '';
      manHinh = 2; // OTP đúng -> mở màn hình tạo mật khẩu.
    });
  }

  // Kiểm tra mật khẩu dài ít nhất 6 ký tự và hai ô phải giống nhau.
  void kiemTraMatKhau() {
    if (matKhauCtrl.text.length < 6) {
      setState(() => loi = 'Mật khẩu cần ít nhất 6 ký tự.');
      return;
    }
    if (matKhauCtrl.text != nhapLaiCtrl.text) {
      setState(() => loi = 'Hai mật khẩu chưa trùng nhau.');
      return;
    }
    setState(() {
      loi = '';
      manHinh = 3; // Đúng -> mở trang xác nhận.
    });
  }

  // Nút Submit: chuyển về màn hình đầu, vẫn giữ email/OTP/mật khẩu.
  void xacNhan() {
    setState(() {
      loi = '';
      daHoanTat = true;
      manHinh = 0; // Thể hiện luồng dữ liệu quay lại màn hình 1.
    });
  }

  // Nút mũi tên: trở về bước ngay trước đó.
  void quayLai() {
    if (manHinh > 0) {
      setState(() {
        manHinh--;
        loi = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F6),
      body: LayoutBuilder(
        builder: (context, khung) {
          // Màn hình máy tính: thêm vỏ điện thoại ở chính giữa.
          if (khung.maxWidth > 500) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FittedBox(
                  fit: BoxFit.contain, // Thu nhỏ cả điện thoại nếu cửa sổ bé.
                  child: Container(
                    width: 376,
                    height: 790,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 20),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(39),
                      child: ColoredBox(
                        color: Colors.white,
                        child: noiDung(true), // Có giờ, Wi-Fi, pin giả lập.
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          // Khi chạy trên điện thoại thật: dùng toàn màn hình, không lồng vỏ.
          return ColoredBox(
            color: Colors.white,
            child: SafeArea(child: noiDung(false)),
          );
        },
      ),
    );
  }

  // Cột chứa thanh trạng thái và 1 trong 4 màn hình.
  Widget noiDung(bool coThanhTrangThai) {
    return Column(
      children: [
        if (coThanhTrangThai) thanhTrangThai(),
        Expanded(
          child: SingleChildScrollView(
            // Cuộn được nếu màn hình nhỏ hoặc bàn phím che ô nhập.
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 88),
                    Image.asset('assets/logo_uth.png', width: 90, height: 62),
                    const SizedBox(height: 8),
                    const Text(
                      'SmartTasks',
                      style: TextStyle(
                        color: xanh, fontSize: 19, fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (manHinh == 0) manEmail(),
                    if (manHinh == 1) manOTP(),
                    if (manHinh == 2) manMatKhau(),
                    if (manHinh == 3) manXacNhan(),
                  ],
                ),
                if (manHinh > 0)
                  Positioned(
                    top: 24,
                    left: 0,
                    child: InkWell(
                      onTap: quayLai, // Khi bấm gọi hàm quayLai().
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF50B5EA),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Thanh 9:41, cột sóng, Wi-Fi, pin: chỉ là hình minh họa trên desktop.
  Widget thanhTrangThai() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 13, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41', style: TextStyle(fontSize: 12)),
          Row(children: [
            Icon(Icons.signal_cellular_alt, size: 15),
            SizedBox(width: 3),
            Icon(Icons.wifi, size: 15),
            SizedBox(width: 3),
            Icon(Icons.battery_full, size: 18),
          ]),
        ],
      ),
    );
  }

  // Hàm dùng chung để vẽ tiêu đề và dòng giải thích.
  Widget tieuDe(String ten, String moTa) {
    return Column(
      children: [
        Text(ten,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold,
                color: Color(0xFF252A31))),
        const SizedBox(height: 9),
        Text(moTa,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: xam, height: 1.45)),
      ],
    );
  }

  // Hàm dùng chung để vẽ ô nhập Email hoặc Mật khẩu.
  Widget oNhap(String goiY, IconData icon, TextEditingController ctrl,
      {bool laMatKhau = false}) {
    return TextField(
      controller: ctrl, // Lấy hoặc đặt nội dung ô nhập bằng ctrl.text.
      obscureText: laMatKhau && !hienMatKhau, // true = ẩn mật khẩu.
      keyboardType:
          laMatKhau ? TextInputType.visiblePassword : TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: goiY,
        hintStyle: const TextStyle(fontSize: 12, color: xam),
        prefixIcon: Icon(icon, size: 18, color: xam),
        suffixIcon: laMatKhau
            ? IconButton(
                icon: Icon(hienMatKhau ? Icons.visibility : Icons.visibility_off,
                    size: 18, color: xam),
                onPressed: () => setState(() => hienMatKhau = !hienMatKhau),
              )
            : null,
        filled: true,
        fillColor: nenO,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFDADAE0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFDADAE0))),
      ),
    );
  }

  // Hàm dùng chung cho mọi nút màu xanh.
  Widget nut(String chu, VoidCallback hamKhiBam) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: hamKhiBam, // Bấm nút => gọi hàm được truyền vào.
        style: ElevatedButton.styleFrom(
          backgroundColor: xanh,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(chu, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  // Hiện thông báo lỗi màu đỏ khi nhập sai.
  Widget hienLoi() {
    if (loi.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(loi,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 12)),
    );
  }

  // MÀN HÌNH 1: nhập Email -> bấm Next -> màn hình OTP.
  Widget manEmail() {
    return Column(
      children: [
        tieuDe('Forget Password?',
            'Enter your Email, we will send you a verification code.'),
        const SizedBox(height: 26),
        oNhap('Your Email', Icons.mail_outline, emailCtrl),
        const SizedBox(height: 25),
        nut('Next', tiepTuEmail),
        hienLoi(),
        const SizedBox(height: 43),
        Container(
          width: 275,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xFFDCEAFF),
            borderRadius: BorderRadius.circular(28),
          ),
          child: daHoanTat
              ? Column(children: [
                  const Text('Đã xác nhận thành công (demo)!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF16704E), fontSize: 14)),
                  const SizedBox(height: 12),
                  Text('Email: ${emailCtrl.text}',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  Text('OTP: ${otpCtrls.map((o) => o.text).join()}',
                      style: const TextStyle(fontSize: 12)),
                  const Text('Mật khẩu: đã nhận (được ẩn)',
                      style: TextStyle(fontSize: 12)),
                ])
              : const Text(
                  'email\notp\npass\n(từ màn hình 4)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Color(0xFFD6382E)),
                ),
        ),
      ],
    );
  }

  // MÀN HÌNH 2: nhập 5 chữ số OTP -> bấm Next.
  Widget manOTP() {
    return Column(
      children: [
        tieuDe('Verify Code',
            'Enter the code\nwe just sent you on your registered Email'),
        const SizedBox(height: 25),
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: otpCtrls[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1, // Một ô chỉ nhận một số.
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '', // Ẩn chữ đếm 0/1 bên dưới ô.
                    filled: true,
                    fillColor: nenO,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E5)),
                    ),
                  ),
                  onChanged: (chu) {
                    // Gõ xong một số -> nhảy sang ô tiếp theo.
                    if (chu.isNotEmpty && i < 4) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 25),
        nut('Next', kiemTraOTP),
        hienLoi(),
        const SizedBox(height: 15),
        const Text('Bản demo: mã OTP là 12345 (không gửi email thật)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: xam)),
      ],
    );
  }

  // MÀN HÌNH 3: nhập mật khẩu mới và nhập lại -> bấm Next.
  Widget manMatKhau() {
    return Column(
      children: [
        tieuDe('Create new password',
            'Your new password must be different from\npreviously used password'),
        const SizedBox(height: 26),
        oNhap('Password', Icons.lock_outline, matKhauCtrl, laMatKhau: true),
        const SizedBox(height: 14),
        oNhap('Confirm Password', Icons.lock_outline, nhapLaiCtrl,
            laMatKhau: true),
        const SizedBox(height: 25),
        nut('Next', kiemTraMatKhau),
        hienLoi(),
      ],
    );
  }

  // Hiện dữ liệu chỉ đọc, không cho sửa tại màn hình xác nhận.
  Widget dongThongTin(IconData icon, String giaTri) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: nenO,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFDADAE0)),
      ),
      child: Row(children: [
        Icon(icon, color: xam, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(giaTri,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF3A3A3A))),
        ),
      ]),
    );
  }

  // MÀN HÌNH 4: dữ liệu lấy từ ba màn hình trước, không viết cố định.
  Widget manXacNhan() {
    final otp = otpCtrls.map((o) => o.text).join();
    final matKhauAn = List.filled(matKhauCtrl.text.length, '*').join();
    return Column(
      children: [
        tieuDe('Confirm', 'We are here to help you!'),
        const SizedBox(height: 26),
        dongThongTin(Icons.person_outline, emailCtrl.text.trim()),
        const SizedBox(height: 13),
        dongThongTin(Icons.mail_outline, otp),
        const SizedBox(height: 13),
        dongThongTin(Icons.lock_outline, matKhauAn),
        const SizedBox(height: 25),
        nut('Submit', xacNhan),
      ],
    );
  }
}
