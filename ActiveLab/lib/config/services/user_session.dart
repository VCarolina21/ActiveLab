import 'package:shared_preferences/shared_preferences.dart';

/// Mengelola data session user yang tersimpan di SharedPreferences
/// Digunakan oleh semua halaman untuk baca/tulis data user yang sedang login
class UserSession {
  static const String _keyToken     = 'user_token';
  static const String _keyId        = 'user_id';
  static const String _keyName      = 'user_name';
  static const String _keyEmail     = 'user_email';
  static const String _keyPhone     = 'user_phone';
  static const String _keyGender    = 'user_gender';
  static const String _keyPhoto     = 'user_photo';

  /// Simpan data setelah login / register berhasil
  static Future<void> saveSession({
    required String token,
    required int id,
    required String name,
    required String email,
    String? phone,
    String? gender,
    String? photo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    if (phone != null) await prefs.setString(_keyPhone, phone);
    if (gender != null) await prefs.setString(_keyGender, gender);
    if (photo != null) await prefs.setString(_keyPhoto, photo);
  }

  /// Ambil token untuk dikirim ke API
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Ambil semua data user yang tersimpan
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id':     prefs.getInt(_keyId),
      'name':   prefs.getString(_keyName) ?? '',
      'email':  prefs.getString(_keyEmail) ?? '',
      'phone':  prefs.getString(_keyPhone) ?? '',
      'gender': prefs.getString(_keyGender) ?? '',
      'photo':  prefs.getString(_keyPhoto) ?? '',
    };
  }

  /// Update data tertentu setelah edit profil
  static Future<void> updateUserData({
    String? name,
    String? phone,
    String? gender,
    String? photo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null)   await prefs.setString(_keyName, name);
    if (phone != null)  await prefs.setString(_keyPhone, phone);
    if (gender != null) await prefs.setString(_keyGender, gender);
    if (photo != null)  await prefs.setString(_keyPhoto, photo);
  }

  /// Hapus semua data session (logout / hapus akun)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyGender);
    await prefs.remove(_keyPhoto);
  }
}