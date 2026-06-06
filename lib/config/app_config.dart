class AppConfig {
  // Menggunakan IP Wi-Fi laptop agar bisa diakses oleh HP fisik
  static const String _host = '10.187.236.184:5000';

  static const String baseUrl = 'http://$_host/api';
  static const String uploadsBaseUrl = 'http://$_host/uploads';

  /// Bangun URL lengkap foto profil user dari nama file
  /// Input: "user_1_1234567890.jpg"
  /// Output: "http://10.187.236.184:5000/uploads/users/user_1_1234567890.jpg"
  static String? buildUserPhotoUrl(String? filename) {
    if (filename == null || filename.isEmpty) return null;
    if (filename.startsWith('http')) return filename;
    return '$uploadsBaseUrl/users/$filename';
  }
}