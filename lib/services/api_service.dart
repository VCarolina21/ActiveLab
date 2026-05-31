import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api"; 
  
  // Variabel untuk "Mengingat" siapa yang lagi login malam ini
  static String? currentUserId;
  static String? currentUserName;

  // ─── 1. FUNGSI LOGIN ───
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/auth/login'),
        headers: { "Content-Type": "application/json" },
        body: jsonEncode({ "email": email, "password": password }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Simpan data user ke memori
        currentUserId = data['user']['id'].toString();
        currentUserName = data['user']['name'];
        print("✅ Login Sukses! Selamat datang, $currentUserName");
        return true;
      } else {
        print("❌ Login Gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Server error: $e");
      return false;
    }
  }

  // ─── 2. FUNGSI REGISTER ───
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/auth/register'),
        headers: { "Content-Type": "application/json" },
        body: jsonEncode({ "name": name, "email": email, "password": password }),
      );

      if (response.statusCode == 201) {
        print("✅ Registrasi Sukses!");
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error Register: $e");
      return false;
    }
  }

  // ─── 3. FUNGSI BOOKING (Update sedikit) ───
  static Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      // Kita selipkan user_id dari user yang lagi login!
      if (currentUserId != null) {
        bookingData['user_id'] = currentUserId;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/booking'),
        headers: { "Content-Type": "application/json" },
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}