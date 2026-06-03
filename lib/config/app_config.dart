class AppConfig {
  // Android Emulator → 10.0.2.2 (alias untuk localhost komputer)
  // iOS Simulator    → 127.0.0.1
  // Physical Device  → ganti dengan IP komputer Anda (cek dengan ipconfig/ifconfig)
  static const String _host = '10.0.2.2:5000';

  static const String baseUrl = 'http://$_host/api';
  static const String uploadsBaseUrl = 'http://$_host/uploads';

  /// Bangun URL lengkap foto profil user dari nama file
  /// Input: "user_1_1234567890.jpg"
  /// Output: "http://10.0.2.2:5000/uploads/users/user_1_1234567890.jpg"
  static String? buildUserPhotoUrl(String? filename) {
    if (filename == null || filename.isEmpty) return null;
    if (filename.startsWith('http')) return filename;
    return '$uploadsBaseUrl/users/$filename';
  }
}