import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// CHẠY ỨNG DỤNG: Điểm bắt đầu của chương trình Flutter.
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, // Ẩn nhãn DEBUG ở góc phải màn hình.
    title: 'UTH SmartTasks',
    home: SmartTasks(),
  ));
}

// Giữ alias MyApp phòng trường hợp file test hoặc tab cũ gọi MyApp().
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTH SmartTasks',
      home: SmartTasks(),
    );
  }
}

// ==================== MODEL DỮ LIỆU CÔNG VIỆC (TỪ API) ====================
class SubTaskItem {
  int id;
  String title;
  bool done;

  SubTaskItem({
    required this.id,
    required this.title,
    this.done = false,
  });

  factory SubTaskItem.fromJson(Map<String, dynamic> json) {
    return SubTaskItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      done: json['done'] == true,
    );
  }
}

class TaskItem {
  int id;
  String title;
  String note;
  String category; // 'study' (Học tập) hoặc 'life' (Cuộc sống)
  String date; // Ví dụ: '2026-10-20'
  String time; // Ví dụ: '06:30'
  String priority; // 'low', 'medium', 'high'
  bool remind;
  bool done;
  List<SubTaskItem> subtasks;

  TaskItem({
    required this.id,
    required this.title,
    this.note = '',
    required this.category,
    required this.date,
    required this.time,
    this.priority = 'medium',
    this.remind = true,
    this.done = false,
    List<SubTaskItem>? subtasks,
  }) : subtasks = subtasks ?? [];

  // Chuyển JSON từ API GET /mock/teach/tasks sang đối tượng TaskItem.
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final rawSubtasks = json['subtasks'];
    final List<SubTaskItem> parsedSubtasks = [];
    if (rawSubtasks is List) {
      for (final item in rawSubtasks) {
        if (item is Map<String, dynamic>) {
          parsedSubtasks.add(SubTaskItem.fromJson(item));
        }
      }
    }
    return TaskItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      category: (json['category'] ?? 'study').toString(),
      date: (json['date'] ?? '2026-10-20').toString(),
      time: (json['time'] ?? '08:00').toString(),
      priority: (json['priority'] ?? 'medium').toString(),
      remind: json['remind'] == true,
      done: json['done'] == true,
      subtasks: parsedSubtasks,
    );
  }

  // Nhãn hiển thị tiếng Việt của danh mục.
  String get tenDanhMuc => category == 'life' ? 'Cuộc sống' : 'Học tập';

  // Nhãn hiển thị tiếng Việt của độ ưu tiên.
  String get tenUuTien {
    switch (priority) {
      case 'high':
        return 'Cao';
      case 'low':
        return 'Thấp';
      default:
        return 'Trung bình';
    }
  }
}

// ==================== DỮ LIỆU MẪU CHUẨN THEO PROTOTYPE API ====================
List<TaskItem> layDuLieuMau() {
  const jsonMau = '''
[
  {
    "id": 6,
    "title": "Tập thể dục 30 phút",
    "note": "Chạy bộ quanh công viên hoặc tập giãn cơ tại nhà.",
    "category": "life",
    "date": "2026-10-20",
    "time": "06:30",
    "priority": "medium",
    "remind": true,
    "done": true,
    "subtasks": []
  },
  {
    "id": 1,
    "title": "Nộp bài tập Lập trình di động",
    "note": "Nộp file .zip lên hệ thống của trường. Nhớ kèm ảnh chụp màn hình app.",
    "category": "study",
    "date": "2026-10-20",
    "time": "09:00",
    "priority": "high",
    "remind": true,
    "done": true,
    "subtasks": [
      {"id": 101, "title": "Hoàn thiện Flow Trang chủ (UI + API)", "done": true},
      {"id": 102, "title": "Đẩy toàn bộ mã nguồn lên GitHub", "done": true}
    ]
  },
  {
    "id": 2,
    "title": "Ôn chương 3 - Cấu trúc dữ liệu",
    "note": "Ôn tập cây nhị phân tìm kiếm (BST), bảng băm và làm bài tập cuối chương.",
    "category": "study",
    "date": "2026-10-20",
    "time": "14:00",
    "priority": "high",
    "remind": true,
    "done": false,
    "subtasks": [
      {"id": 201, "title": "Đọc lý thuyết Cây nhị phân", "done": true},
      {"id": 202, "title": "Code thử bài duyệt cây NLR, LNR", "done": false}
    ]
  },
  {
    "id": 3,
    "title": "Đi chợ mua đồ cho tuần",
    "note": "Mua rau xanh, ức gà, trứng, sữa tươi và trái cây.",
    "category": "life",
    "date": "2026-10-20",
    "time": "17:30",
    "priority": "medium",
    "remind": false,
    "done": false,
    "subtasks": [
      {"id": 301, "title": "Mua rau củ và trái cây", "done": false},
      {"id": 302, "title": "Mua trứng và sữa tươi", "done": false}
    ]
  },
  {
    "id": 4,
    "title": "Đọc tài liệu RESTful API & JSON",
    "note": "Tìm hiểu cách dùng package http trong Flutter với async/await.",
    "category": "study",
    "date": "2026-10-21",
    "time": "08:30",
    "priority": "medium",
    "remind": true,
    "done": false,
    "subtasks": []
  },
  {
    "id": 5,
    "title": "Dọn dẹp góc học tập cuối tuần",
    "note": "Sắp xếp lại kệ sách, lau màn hình máy tính.",
    "category": "life",
    "date": "2026-10-21",
    "time": "16:00",
    "priority": "low",
    "remind": false,
    "done": false,
    "subtasks": []
  }
]
''';
  final List<dynamic> decoded = jsonDecode(jsonMau) as List<dynamic>;
  return decoded
      .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

// ==================== MÀN HÌNH CHÍNH SMARTTASKS ====================
class SmartTasks extends StatefulWidget {
  const SmartTasks({super.key});

  @override
  State<SmartTasks> createState() => _SmartTasksState();
}

class _SmartTasksState extends State<SmartTasks> {
  // 0: Trang chủ; 1: Danh sách; 2: Thông báo; 3: Cài đặt; 4: Luồng Quên mật khẩu (Tuần trước)
  int tabChinh = 0;

  // Chế độ giao diện Tối / Sáng (Gợi ý số 4 trong đề bài)
  bool giaoDienToi = false;

  // Trạng thái gọi API
  static const String apiUrl = 'https://share.tryapps.store/mock/teach/tasks';
  String apiToken = 'BEARER_API_TOKEN';
  bool dangTaiApi = false;
  String trangThaiApi = 'Đã tải dữ liệu từ Mock API (/mock/teach/tasks)';
  List<TaskItem> danhSachViec = [];

  // Bộ lọc ở màn Danh sách ('all', 'study', 'life', 'done', 'pending')
  String boLocDanhSach = 'all';
  String tuKhoaTimKiem = '';

  // ----- Biến của Luồng Quên mật khẩu (giữ nguyên tính năng bài cũ) -----
  int manHinhQuenMK = 0; // 0: Email, 1: OTP, 2: Mật khẩu mới, 3: Xác nhận
  String loiQuenMK = '';
  bool daHoanTatQuenMK = false;
  bool hienMatKhau = false;
  final emailCtrl = TextEditingController();
  final matKhauCtrl = TextEditingController();
  final nhapLaiCtrl = TextEditingController();
  final otpCtrls = List.generate(5, (_) => TextEditingController());

  // Màu sắc chủ đạo theo thiết kế UTH Todo
  static const mauXanhDam = Color(0xFF3456D1);
  static const mauXanhUTH = Color(0xFF4999EC);

  @override
  void initState() {
    super.initState();
    // Khởi tạo trước dữ liệu mẫu để hiển thị tức thì và gọi API cập nhật
    danhSachViec = layDuLieuMau();
    taiDanhSachCongViecTuApi();
  }

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

  // ==================== HÀM GỌI API GET /mock/teach/tasks ====================
  Future<void> taiDanhSachCongViecTuApi({bool hienThongBao = false}) async {
    setState(() {
      dangTaiApi = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $apiToken',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> listJson = body is List
            ? body
            : (body is Map && body['data'] is List ? body['data'] as List : []);
        if (listJson.isNotEmpty) {
          setState(() {
            danhSachViec = listJson
                .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
                .toList();
            trangThaiApi = '200 OK — Đã tải từ API /mock/teach/tasks';
            dangTaiApi = false;
          });
          if (hienThongBao && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã tải dữ liệu trực tiếp từ API!')),
            );
          }
          return;
        }
      }
      // Nếu server trả về 401 (chưa cấu hình token riêng) hoặc lỗi khác -> dùng sample chuẩn của API
      setState(() {
        if (danhSachViec.isEmpty) {
          danhSachViec = layDuLieuMau();
        }
        trangThaiApi =
            'API (${response.statusCode}) → Đang dùng Sample Response /mock/teach/tasks';
        dangTaiApi = false;
      });
    } catch (_) {
      // Khi chạy trên Web bị chặn CORS hoặc mất mạng -> dùng dữ liệu mẫu từ response sample
      setState(() {
        if (danhSachViec.isEmpty) {
          danhSachViec = layDuLieuMau();
        }
        trangThaiApi = 'Sample 200 OK — GET /mock/teach/tasks';
        dangTaiApi = false;
      });
    }
  }

  void datLaiDuLieuMau() {
    setState(() {
      danhSachViec = layDuLieuMau();
      trangThaiApi = 'Đã khôi phục dữ liệu mẫu ban đầu (2/4 việc hôm nay)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đặt lại dữ liệu mẫu thành công!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ==================== THỐNG KÊ TIẾN ĐỘ & DANH MỤC ====================
  // Các việc trong ngày hôm nay (2026-10-20 theo thiết kế)
  List<TaskItem> get viecHomNay {
    final homNay = danhSachViec.where((t) => t.date == '2026-10-20').toList();
    return homNay.isNotEmpty ? homNay : danhSachViec;
  }

  int get soViecHomNayHoanThanh => viecHomNay.where((t) => t.done).length;
  int get tongSoViecHomNay => viecHomNay.length;

  double get tiLeHoanThanhHomNay =>
      tongSoViecHomNay == 0 ? 0 : soViecHomNayHoanThanh / tongSoViecHomNay;

  int get phanTramHomNay => (tiLeHoanThanhHomNay * 100).round();

  String get loiDongVienHomNay {
    if (tongSoViecHomNay == 0) return 'Chưa có công việc nào hôm nay.';
    if (phanTramHomNay == 100) return 'Xuất sắc! Bạn đã hoàn thành hết việc hôm nay!';
    if (phanTramHomNay >= 50) return 'Đã hơn nửa chặng, cố lên!';
    if (phanTramHomNay > 0) return 'Khởi đầu tốt đẹp, tiếp tục nhé!';
    return 'Hãy bắt đầu công việc đầu tiên trong ngày!';
  }

  int demViecConLaiTheoDanhMuc(String cat) {
    return danhSachViec.where((t) => t.category == cat && !t.done).length;
  }

  // Đảo trạng thái hoàn thành khi bấm vào ô tích tròn
  void doiTrangThaiXong(TaskItem task) {
    setState(() {
      task.done = !task.done;
    });
  }

  // ==================== BỐ CỤC KHUNG ĐIỆN THOẠI ====================
  @override
  Widget build(BuildContext context) {
    final mauNenTrang =
        giaoDienToi ? const Color(0xFF12151E) : const Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor:
          giaoDienToi ? const Color(0xFF0B0D13) : const Color(0xFFEDEFF5),
      body: LayoutBuilder(
        builder: (context, khung) {
          // Màn hình máy tính / Web: Chỉ hiển thị khung điện thoại ở chính giữa
          if (khung.maxWidth > 500) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: khungDienThoaiGiaLap(mauNenTrang),
              ),
            );
          }

          // Khi chạy trên điện thoại thật: Hiển thị toàn màn hình
          return ColoredBox(
            color: mauNenTrang,
            child: SafeArea(child: noiDungChinhDienThoai(false)),
          );
        },
      ),
    );
  }

  Widget khungDienThoaiGiaLap(Color mauNenTrang) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: 380,
        height: 800,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(48),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(39),
          child: ColoredBox(
            color: mauNenTrang,
            child: noiDungChinhDienThoai(true),
          ),
        ),
      ),
    );
  }

  // ==================== NỘI DUNG BÊN TRONG ĐIỆN THOẠI ====================
  Widget noiDungChinhDienThoai(bool coThanhTrangThai) {
    return Column(
      children: [
        if (coThanhTrangThai) thanhTrangThai(),
        Expanded(
          child: IndexedStack(
            index: tabChinh,
            children: [
              manHinhTrangChu(),
              manHinhDanhSach(),
              manHinhThongBao(),
              manHinhCaiDat(),
              manHinhLuogQuenMatKhauCu(),
            ],
          ),
        ),
        thanhDieuHuongDuoi(),
      ],
    );
  }

  // Thanh giờ 9:41, sóng, Wi-Fi, pin
  Widget thanhTrangThai() {
    final mauChu = giaoDienToi ? Colors.white70 : Colors.black87;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: mauChu,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 15, color: mauChu),
              const SizedBox(width: 4),
              Icon(Icons.wifi, size: 15, color: mauChu),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, size: 17, color: mauChu),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MÀN HÌNH 1: TRANG CHỦ (UI + API + THỐNG KÊ) ====================
  Widget manHinhTrangChu() {
    final chuChinh = giaoDienToi ? Colors.white : const Color(0xFF1B202B);
    final chuPhu = giaoDienToi ? Colors.white60 : const Color(0xFF777E90);
    final nenThe = giaoDienToi ? const Color(0xFF1E2330) : Colors.white;

    return RefreshIndicator(
      onRefresh: () => taiDanhSachCongViecTuApi(hienThongBao: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Avatar chữ K, Thứ Ba 20 tháng 10 / Chào bạn! + nút Chuông thông báo
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: giaoDienToi
                        ? const Color(0xFF28324E)
                        : const Color(0xFFE7EEFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'K',
                    style: TextStyle(
                      color: mauXanhDam,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thứ Ba, 20 tháng 10',
                        style: TextStyle(fontSize: 11.5, color: chuPhu),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chào bạn!',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: chuChinh,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => tabChinh = 2),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: nenThe,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!giaoDienToi)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: chuChinh,
                          size: 22,
                        ),
                        Positioned(
                          top: 9,
                          right: 10,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 2. Thẻ Tiến độ hôm nay (Màu xanh đậm + Vòng tròn phần trăm)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3355D4), Color(0xFF4368E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3355D4).withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tiến độ hôm nay',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$soViecHomNayHoanThanh/$tongSoViecHomNay việc',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          loiDongVienHomNay,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 66,
                    height: 66,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 62,
                          height: 62,
                          child: CircularProgressIndicator(
                            value: tiLeHoanThanhHomNay,
                            strokeWidth: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '$phanTramHomNay%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Hai thẻ thống kê danh mục: Học tập & Cuộc sống
            Row(
              children: [
                Expanded(
                  child: theThongKeDanhMuc(
                    tieuDe: 'Học tập',
                    soViecConLai: demViecConLaiTheoDanhMuc('study'),
                    icon: Icons.school_outlined,
                    mauIcon: const Color(0xFF3959D6),
                    mauNenIcon: const Color(0xFFE9EFFF),
                    khiBam: () {
                      setState(() {
                        boLocDanhSach = 'study';
                        tabChinh = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: theThongKeDanhMuc(
                    tieuDe: 'Cuộc sống',
                    soViecConLai: demViecConLaiTheoDanhMuc('life'),
                    icon: Icons.home_outlined,
                    mauIcon: const Color(0xFFD97706),
                    mauNenIcon: const Color(0xFFFEF3C7),
                    khiBam: () {
                      setState(() {
                        boLocDanhSach = 'life';
                        tabChinh = 1;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Tiêu đề "Việc hôm nay" + nút "Xem tất cả"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Việc hôm nay',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: chuChinh,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      boLocDanhSach = 'all';
                      tabChinh = 1;
                    });
                  },
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: mauXanhDam,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (dangTaiApi && danhSachViec.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (viecHomNay.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    'Hôm nay chưa có công việc nào.',
                    style: TextStyle(color: chuPhu, fontSize: 13),
                  ),
                ),
              )
            else
              ...viecHomNay.map((task) => theCongViecItem(task)),
          ],
        ),
      ),
    );
  }

  // Thẻ thống kê danh mục (Học tập / Cuộc sống)
  Widget theThongKeDanhMuc({
    required String tieuDe,
    required int soViecConLai,
    required IconData icon,
    required Color mauIcon,
    required Color mauNenIcon,
    required VoidCallback khiBam,
  }) {
    final nenThe = giaoDienToi ? const Color(0xFF1E2330) : Colors.white;
    final chuChinh = giaoDienToi ? Colors.white : const Color(0xFF1B202B);
    final chuPhu = giaoDienToi ? Colors.white60 : const Color(0xFF777E90);

    return InkWell(
      onTap: khiBam,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: nenThe,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!giaoDienToi)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: giaoDienToi ? mauIcon.withValues(alpha: 0.2) : mauNenIcon,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: mauIcon, size: 19),
            ),
            const SizedBox(height: 10),
            Text(
              tieuDe,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: chuChinh,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$soViecConLai việc còn lại',
              style: TextStyle(fontSize: 11.5, color: chuPhu),
            ),
          ],
        ),
      ),
    );
  }

  // Một thẻ công việc trong danh sách (giống hệt ảnh mẫu)
  Widget theCongViecItem(TaskItem task) {
    final nenThe = giaoDienToi ? const Color(0xFF1E2330) : Colors.white;
    final chuChinh = giaoDienToi ? Colors.white : const Color(0xFF1B202B);
    final chuMo = giaoDienToi ? Colors.white38 : const Color(0xFF9AA1B2);

    final laCuocSong = task.category == 'life';
    final mauNhan =
        laCuocSong ? const Color(0xFFB45309) : const Color(0xFF3456D1);
    final mauNenNhan =
        laCuocSong ? const Color(0xFFFEF3C7) : const Color(0xFFE8EFFF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: nenThe,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => moChiTietCongViec(task),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: giaoDienToi ? Colors.white10 : const Color(0xFFEDF0F7),
              ),
            ),
            child: Row(
              children: [
                // Nút tròn tích hoàn thành
                GestureDetector(
                  onTap: () => doiTrangThaiXong(task),
                  child: Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      color: task.done ? mauXanhDam : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.done
                            ? mauXanhDam
                            : const Color(0xFFC5CAD6),
                        width: 1.8,
                      ),
                    ),
                    child: task.done
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Tiêu đề + nhãn danh mục + giờ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: task.done ? chuMo : chuChinh,
                          decoration: task.done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: giaoDienToi
                                  ? mauNhan.withValues(alpha: 0.22)
                                  : mauNenNhan,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.tenDanhMuc,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: mauNhan,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.time,
                            style: TextStyle(fontSize: 11, color: chuMo),
                          ),
                          if (task.subtasks.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.checklist, size: 12, color: chuMo),
                            const SizedBox(width: 2),
                            Text(
                              '${task.subtasks.where((s) => s.done).length}/${task.subtasks.length}',
                              style: TextStyle(fontSize: 10.5, color: chuMo),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: chuMo, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MÀN HÌNH 2: DANH SÁCH CÔNG VIỆC ĐẦY ĐỦ ====================
  Widget manHinhDanhSach() {
    final chuChinh = giaoDienToi ? Colors.white : const Color(0xFF1B202B);
    final chuPhu = giaoDienToi ? Colors.white60 : const Color(0xFF777E90);
    final nenO = giaoDienToi ? const Color(0xFF1E2330) : Colors.white;

    final danhSachLoc = danhSachViec.where((t) {
      if (boLocDanhSach == 'study' && t.category != 'study') return false;
      if (boLocDanhSach == 'life' && t.category != 'life') return false;
      if (boLocDanhSach == 'done' && !t.done) return false;
      if (boLocDanhSach == 'pending' && t.done) return false;
      if (tuKhoaTimKiem.trim().isNotEmpty &&
          !t.title.toLowerCase().contains(tuKhoaTimKiem.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách công việc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: chuChinh,
                ),
              ),
              Text(
                '${danhSachLoc.length} việc',
                style: TextStyle(fontSize: 12, color: chuPhu),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Ô tìm kiếm
          TextField(
            style: TextStyle(color: chuChinh, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm công việc...',
              hintStyle: TextStyle(color: chuPhu, fontSize: 12.5),
              prefixIcon: Icon(Icons.search, size: 18, color: chuPhu),
              filled: true,
              fillColor: nenO,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => tuKhoaTimKiem = v),
          ),
          const SizedBox(height: 10),
          // Các chip lọc danh mục
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chipBoLoc('Tất cả', 'all'),
                const SizedBox(width: 6),
                chipBoLoc('Học tập', 'study'),
                const SizedBox(width: 6),
                chipBoLoc('Cuộc sống', 'life'),
                const SizedBox(width: 6),
                chipBoLoc('Chưa xong', 'pending'),
                const SizedBox(width: 6),
                chipBoLoc('Đã xong', 'done'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: danhSachLoc.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy công việc phù hợp.',
                      style: TextStyle(color: chuPhu, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: danhSachLoc.length,
                    itemBuilder: (context, i) =>
                        theCongViecItem(danhSachLoc[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget chipBoLoc(String nhan, String ma) {
    final dangChon = boLocDanhSach == ma;
    return InkWell(
      onTap: () => setState(() => boLocDanhSach = ma),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: dangChon
              ? mauXanhDam
              : (giaoDienToi ? const Color(0xFF1E2330) : Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          nhan,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: dangChon
                ? Colors.white
                : (giaoDienToi ? Colors.white70 : const Color(0xFF4A5060)),
          ),
        ),
      ),
    );
  }

  // ==================== MÀN HÌNH 3: THÔNG BÁO ====================
  Widget manHinhThongBao() {
    final chuChinh = giaoDienToi ? Colors.white : const Color(0xFF1B202B);
    final chuPhu = giaoDienToi ? Colors.white60 : const Color(0xFF777E90);
    final nenThe = giaoDienToi ? const Color(0xFF1E2330) : Colors.white;

    final cacViecNhac = danhSachViec.where((t) => t.remind).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông báo & Nhắc hẹn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: chuChinh,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Các công việc có bật chế độ nhắc nhở (remind: true)',
            style: TextStyle(fontSize: 12, color: chuPhu),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: cacViecNhac.length,
              itemBuilder: (context, index) {
                final t = cacViecNhac[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: nenThe,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: mauXanhDam,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: chuChinh,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Nhắc lúc ${t.time} • Ngày ${t.date} (${t.tenDanhMuc})',
                              style: TextStyle(fontSize: 11, color: chuPhu),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MÀN HÌNH 4: CÀI ĐẶT (ĐỔI GIAO DIỆN TỐI, ĐẶT LẠI DỮ LIỆU) ====================
  Widget manHinhCaiDat() {
    final chuChinh = giaoDienToi ? Colors.white : const Color(0xFF1B202B);
    final chuPhu = giaoDienToi ? Colors.white60 : const Color(0xFF777E90);
    final nenThe = giaoDienToi ? const Color(0xFF1E2330) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt & Hồ sơ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: chuChinh,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: nenThe,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Image.asset('assets/logo_uth.png', width: 48, height: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sinh viên UTH',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: chuChinh,
                        ),
                      ),
                      Text(
                        'UTH SmartTasks — Lập trình di động',
                        style: TextStyle(fontSize: 11.5, color: chuPhu),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: nenThe,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Giao diện Tối (Dark Mode)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: chuChinh,
                    ),
                  ),
                  subtitle: Text(
                    'Chuyển đổi màu nền sáng/tối toàn ứng dụng',
                    style: TextStyle(fontSize: 11, color: chuPhu),
                  ),
                  value: giaoDienToi,
                  activeThumbColor: mauXanhDam,
                  onChanged: (v) => setState(() => giaoDienToi = v),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync, color: mauXanhDam),
                  title: Text(
                    'Tải lại từ API (/mock/teach/tasks)',
                    style: TextStyle(fontSize: 13, color: chuChinh),
                  ),
                  subtitle: Text(
                    trangThaiApi,
                    style: TextStyle(fontSize: 11, color: chuPhu),
                  ),
                  onTap: () => taiDanhSachCongViecTuApi(hienThongBao: true),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.orange),
                  title: Text(
                    'Đặt lại dữ liệu mẫu ban đầu',
                    style: TextStyle(fontSize: 13, color: chuChinh),
                  ),
                  onTap: datLaiDuLieuMau,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Colors.teal),
                  title: Text(
                    'Mở luồng Quên mật khẩu (Bài tập trước)',
                    style: TextStyle(fontSize: 13, color: chuChinh),
                  ),
                  subtitle: Text(
                    'Forget Password → OTP → Create Password → Confirm',
                    style: TextStyle(fontSize: 11, color: chuPhu),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => tabChinh = 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CHI TIẾT CÔNG VIỆC & VIỆC NHỎ (SUBTASKS) ====================
  void moChiTietCongViec(TaskItem task) {
    final subtaskCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          giaoDienToi ? const Color(0xFF1B202E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final chuChinh =
                giaoDienToi ? Colors.white : const Color(0xFF1B202B);
            final chuPhu =
                giaoDienToi ? Colors.white60 : const Color(0xFF6B7280);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: chuChinh,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              danhSachViec.removeWhere((e) => e.id == task.id);
                            });
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Xóa công việc',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            task.tenDanhMuc,
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        Chip(
                          label: Text(
                            '⏰ ${task.time} • ${task.date}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        Chip(
                          label: Text(
                            'Ưu tiên: ${task.tenUuTien}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    if (task.note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.note,
                        style: TextStyle(fontSize: 12.5, color: chuPhu),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Đã hoàn thành công việc này',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: chuChinh,
                        ),
                      ),
                      value: task.done,
                      activeThumbColor: mauXanhDam,
                      onChanged: (val) {
                        setState(() => task.done = val);
                        setModalState(() {});
                      },
                    ),
                    const Divider(),
                    Text(
                      'Việc nhỏ (Subtasks: ${task.subtasks.length})',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: chuChinh,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...task.subtasks.map(
                      (sub) => Row(
                        children: [
                          Checkbox(
                            value: sub.done,
                            activeColor: mauXanhDam,
                            onChanged: (v) {
                              setState(() => sub.done = v ?? false);
                              setModalState(() {});
                            },
                          ),
                          Expanded(
                            child: Text(
                              sub.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: chuChinh,
                                decoration: sub.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 17),
                            onPressed: () {
                              setState(() => task.subtasks.remove(sub));
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: subtaskCtrl,
                            style: TextStyle(color: chuChinh, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Nhập thêm việc nhỏ...',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final text = subtaskCtrl.text.trim();
                            if (text.isEmpty) return;
                            setState(() {
                              task.subtasks.add(
                                SubTaskItem(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  title: text,
                                ),
                              );
                            });
                            subtaskCtrl.clear();
                            setModalState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mauXanhDam,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Thêm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== HỘP THOẠI THÊM VIỆC MỚI (NÚT +) ====================
  void moHopThoaiThemViec() {
    final tieuDeCtrl = TextEditingController();
    final ghiChuCtrl = TextEditingController();
    final gioCtrl = TextEditingController(text: '19:30');
    String danhMucChon = 'study';
    String uuTienChon = 'medium';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: giaoDienToi ? const Color(0xFF1B202E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final chuChinh =
                giaoDienToi ? Colors.white : const Color(0xFF1B202B);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thêm công việc mới',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: chuChinh,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: tieuDeCtrl,
                    style: TextStyle(color: chuChinh),
                    decoration: const InputDecoration(
                      labelText: 'Tên công việc *',
                      hintText: 'Ví dụ: Hoàn thành báo cáo thực hành',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ghiChuCtrl,
                    style: TextStyle(color: chuChinh),
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: danhMucChon,
                          decoration: const InputDecoration(
                            labelText: 'Danh mục',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'study',
                              child: Text('Học tập'),
                            ),
                            DropdownMenuItem(
                              value: 'life',
                              child: Text('Cuộc sống'),
                            ),
                          ],
                          onChanged: (v) => setModalState(
                            () => danhMucChon = v ?? 'study',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: gioCtrl,
                          style: TextStyle(color: chuChinh),
                          decoration: const InputDecoration(
                            labelText: 'Giờ (HH:mm)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final ten = tieuDeCtrl.text.trim();
                        if (ten.isEmpty) return;
                        setState(() {
                          danhSachViec.insert(
                            0,
                            TaskItem(
                              id: DateTime.now().millisecondsSinceEpoch,
                              title: ten,
                              note: ghiChuCtrl.text.trim(),
                              category: danhMucChon,
                              date: '2026-10-20',
                              time: gioCtrl.text.trim().isEmpty
                                  ? '08:00'
                                  : gioCtrl.text.trim(),
                              priority: uuTienChon,
                              remind: true,
                              done: false,
                            ),
                          );
                          tabChinh = 0;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mauXanhDam,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Lưu công việc'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== THANH ĐIỀU HƯỚNG DƯỚI CÙNG (CÓ NÚT + Ở GIỮA) ====================
  Widget thanhDieuHuongDuoi() {
    final nenThanh = giaoDienToi ? const Color(0xFF1A1F2C) : Colors.white;
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: nenThanh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          mucDieuHuong(Icons.home_outlined, 'Trang chủ', 0),
          mucDieuHuong(Icons.format_list_bulleted_rounded, 'Danh sách', 1),
          // Nút tròn dấu + màu xanh nổi bật ở chính giữa
          GestureDetector(
            onTap: moHopThoaiThemViec,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: mauXanhDam,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mauXanhDam.withValues(alpha: 0.38),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
          ),
          mucDieuHuong(Icons.notifications_none_rounded, 'Thông báo', 2),
          mucDieuHuong(Icons.tune_rounded, 'Cài đặt', 3),
        ],
      ),
    );
  }

  Widget mucDieuHuong(IconData icon, String nhan, int viTri) {
    final dangChon = tabChinh == viTri;
    final mau = dangChon
        ? mauXanhDam
        : (giaoDienToi ? Colors.white54 : const Color(0xFF8A91A4));
    return InkWell(
      onTap: () => setState(() => tabChinh = viTri),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: mau, size: 22),
            const SizedBox(height: 3),
            Text(
              nhan,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
                color: mau,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== LUỒNG 4 MÀN HÌNH QUÊN MẬT KHẨU (TÍCH HỢP TỪ BÀI TRƯỚC) ====================
  void tiepTuEmail() {
    final email = emailCtrl.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => loiQuenMK = 'Hãy nhập địa chỉ email hợp lệ.');
      return;
    }
    for (final o in otpCtrls) {
      o.clear();
    }
    matKhauCtrl.clear();
    nhapLaiCtrl.clear();
    setState(() {
      loiQuenMK = '';
      daHoanTatQuenMK = false;
      manHinhQuenMK = 1;
    });
  }

  void kiemTraOTP() {
    final otp = otpCtrls.map((o) => o.text).join();
    if (otp != '12345') {
      setState(() => loiQuenMK = 'Mã OTP sai. Mã demo là 12345.');
      return;
    }
    setState(() {
      loiQuenMK = '';
      manHinhQuenMK = 2;
    });
  }

  void kiemTraMatKhau() {
    if (matKhauCtrl.text.length < 6) {
      setState(() => loiQuenMK = 'Mật khẩu cần ít nhất 6 ký tự.');
      return;
    }
    if (matKhauCtrl.text != nhapLaiCtrl.text) {
      setState(() => loiQuenMK = 'Hai mật khẩu chưa trùng nhau.');
      return;
    }
    setState(() {
      loiQuenMK = '';
      manHinhQuenMK = 3;
    });
  }

  void xacNhanQuenMK() {
    setState(() {
      loiQuenMK = '';
      daHoanTatQuenMK = true;
      manHinhQuenMK = 0;
    });
  }

  Widget manHinhLuogQuenMatKhauCu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (manHinhQuenMK > 0)
                IconButton(
                  onPressed: () => setState(() {
                    manHinhQuenMK--;
                    loiQuenMK = '';
                  }),
                  icon: const Icon(Icons.arrow_back_ios_new, color: mauXanhUTH),
                )
              else
                const SizedBox(width: 40),
              TextButton.icon(
                onPressed: () => setState(() => tabChinh = 0),
                icon: const Icon(Icons.home_outlined, size: 16),
                label: const Text('Về Trang chủ Todo'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Image.asset('assets/logo_uth.png', width: 85, height: 58),
          const SizedBox(height: 6),
          const Text(
            'SmartTasks',
            style: TextStyle(
              color: mauXanhUTH,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          if (manHinhQuenMK == 0) ...[
            const Text(
              'Forget Password?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Email, we will send you a verification code.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                hintText: 'Your Email',
                prefixIcon: Icon(Icons.mail_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: tiepTuEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauXanhUTH,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ),
            if (daHoanTatQuenMK) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEAFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Đã xác nhận thành công!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16704E),
                      ),
                    ),
                    Text('Email: ${emailCtrl.text}'),
                    Text('OTP: ${otpCtrls.map((o) => o.text).join()}'),
                  ],
                ),
              ),
            ],
          ],
          if (manHinhQuenMK == 1) ...[
            const Text(
              'Verify Code',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the code we just sent you on your registered Email (Demo: 12345)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(
                5,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: otpCtrls[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 4) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: kiemTraOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauXanhUTH,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ),
          ],
          if (manHinhQuenMK == 2) ...[
            const Text(
              'Create new password',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: matKhauCtrl,
              obscureText: !hienMatKhau,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    hienMatKhau ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => hienMatKhau = !hienMatKhau),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nhapLaiCtrl,
              obscureText: !hienMatKhau,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: kiemTraMatKhau,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauXanhUTH,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ),
          ],
          if (manHinhQuenMK == 3) ...[
            const Text(
              'Confirm',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(emailCtrl.text),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(otpCtrls.map((o) => o.text).join()),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(List.filled(matKhauCtrl.text.length, '*').join()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: xacNhanQuenMK,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mauXanhUTH,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
          if (loiQuenMK.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                loiQuenMK,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
