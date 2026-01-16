# VocaMaster - Ứng dụng Học Từ vựng Tiếng Anh

VocaMaster là một ứng dụng di động được xây dựng bằng Flutter giúp người dùng học từ vựng tiếng Anh một cách hiệu quả thông qua các phương pháp học tập tương tác.

##  Tính năng chính

###  Trang chủ
- Chào mừng người dùng: Hiển thị thông tin chào mừng cá nhân hóa với tên người dùng
- Theo dõi tiến độ học tập: Hiển thị số ngày liên tục học tập (streak)
- Thống kê học tập: Hiển thị tổng số từ đã học và thời gian học tập
- Bảng 12 thì trong tiếng Anh: Cung cấp cấu trúc và ví dụ cho 12 thì cơ bản

###  Học với Flashcards
- Thẻ học tập tương tác: Học từ vựng với các thẻ flashcard có thể lật
- Phát âm từ vựng: Tích hợp Text-to-Speech để phát âm chuẩn
- Đánh dấu từ đã học: Lưu trữ tiến độ học tập của người dùng
- Điều hướng dễ dàng: Vuốt trái/phải để chuyển giữa các thẻ

###  Kiểm tra từ vựng (Quiz)
- Câu hỏi trắc nghiệm: Kiểm tra kiến thức từ vựng qua các câu hỏi trắc nghiệm
- Hẹn giờ cho mỗi câu hỏi: Thử thách người dùng trả lời trong giới hạn thời gian
- Kết quả chi tiết: Hiển thị điểm số và câu trả lời đúng/sai
- Lưu lịch sử làm bài: Lưu trữ kết quả quiz vào Firestore

###  Trò chuyện với AI Tutor
- Hỗ trợ học tập 24/7: Tích hợp Chatbot sử dụng Google Gemini API
- Trợ lý tiếng Anh: Hỗ trợ trả lời các câu hỏi về ngữ pháp, từ vựng
- Giao diện thân thiện: Giao diện chat hiện đại với bong bóng trò chuyện

###  Quản lý tài khoản
- Đăng nhập bằng Google: Xác thực người dùng qua tài khoản Google
- Lưu trữ hồ sơ cá nhân: Lưu thông tin người dùng và tiến độ học tập
- Đăng xuất an toàn: Đăng xuất khỏi tài khoản một cách an toàn

###  Quản trị viên (Admin Panel)
- Quản lý từ vựng: Thêm, sửa, xóa từ vựng trong cơ sở dữ liệu
- Quản lý người dùng: Xem danh sách người dùng và quản lý tài khoản
- Phân trang danh sách: Hiển thị danh sách từ vựng với phân trang
- Tìm kiếm người dùng: Tìm kiếm người dùng theo email

##  Công nghệ sử dụng

### Frontend
- Flutter: Framework phát triển ứng dụng đa nền tảng
- Dart: Ngôn ngữ lập trình chính

### Backend & Database
- Firebase Authentication: Xác thực người dùng
- Cloud Firestore: Cơ sở dữ liệu NoSQL để lưu trữ dữ liệu
- Google Sign-In: Đăng nhập qua tài khoản Google

### APIs & Services
- Google Gemini API: Chatbot AI trợ giúp học tập
- Flutter TTS: Text-to-Speech để phát âm từ vựng

##  Giao diện người dùng

- Thiết kế Material Design: Giao diện hiện đại, trực quan
- Responsive Design: Tương thích với nhiều kích thước màn hình
- Animation & Transitions: Hiệu ứng chuyển động mượt mà
- Color Scheme: Bảng màu hài hòa, dễ nhìn

##  Cách cài đặt và chạy ứng dụng

### Yêu cầu
- Flutter SDK (phiên bản 3.9.2 trở lên)
- Android Studio / VS Code với Flutter extension
- Thiết bị Android/iOS hoặc emulator

### Các bước thực hiện

1. Clone repository
   ```bash
   git clone [repository-url]
   cd DA/ielts_listening_web
   ```

2. Cài đặt dependencies
   ```bash
   flutter pub get
   ```

3. Cấu hình Firebase
   - Tạo dự án mới trên [Firebase Console](https://console.firebase.google.com/)
   - Thêm ứng dụng Android/iOS
   - Tải file cấu hình (google-services.json cho Android, GoogleService-Info.plist cho iOS)
   - Đặt file vào thư mục tương ứng trong project

4. Cấu hình Google Gemini API
   - Lấy API key từ [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Thay thế API key trong file `lib/screens/chat_bot_screen.dart`

5. Chạy ứng dụng
   ```bash
   flutter run
   ```

##  Cấu trúc dự án

```
ielts_listening_web/
├── lib/
│   ├── models/           # Models dữ liệu
│   │   ├── vocabulary.dart
│   │   ├── user.dart
│   │   ├── progress.dart
│   │   └── streak_helper.dart
│   ├── screens/          # Các màn hình ứng dụng
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── flashcard_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── vocabulary_detail_screen.dart
│   │   ├── chat_bot_screen.dart
│   │   ├── profile_screen.dart
│   │   └── admin_screen.dart
│   ├── main.dart         # Điểm khởi chạy ứng dụng
│   └── firebase_options.dart # Cấu hình Firebase
├── android/              # Code Android
├── ios/                  # Code iOS
└── pubspec.yaml          # Dependencies của project
```

