import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Tambahkan ini untuk membaca file gambar

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api"; 
  
  // Variabel untuk "Mengingat" siapa yang lagi login malam ini
  static String? currentUserId;
  static String? currentUserName;
  static String? currentUserEmail; // Tambahkan ini
  static String? currentUserImage; // Tambahkan ini

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
        currentUserEmail = data['user']['email']; // Simpan email
        currentUserImage = data['user']['image']; // Simpan path foto
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

 // ─── 2. FUNGSI REGISTER (Mendukung Gambar) ───
  static Future<String> register(String name, String email, String password, String phone, String gender, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/mobile/auth/register'));

      // Masukkan data teks
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['phone'] = phone;
      request.fields['gender'] = gender;

      // Masukkan data gambar jika ada
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      // Kirim ke backend
      var streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return "SUCCESS";
      } else if (response.statusCode == 409) {
        return "DUPLICATE";
      } else {
        return "SERVER_ERROR";
      }
    } catch (e) {
      print("❌ Error Register: $e");
      return "BACKEND_DEAD";
    }
  }

  // ─── FUNGSI UPDATE INTERESTS ───
  static Future<bool> updateInterests(String email, String interests) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/auth/update-interests'),
        headers: { "Content-Type": "application/json" },
        body: jsonEncode({ "email": email, "interests": interests }),
      );

      if (response.statusCode == 200) {
        print("✅ Interests berhasil disimpan ke database!");
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error Update Interests: $e");
      return false;
    }
  }

  // ─── 3. FUNGSI BOOKING ───
  static Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
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
  // ─── FUNGSI UPDATE FOTO PROFIL ───
  static Future<String?> updateProfilePhoto(String email, File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/mobile/auth/update-photo'));
      request.fields['email'] = email;
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Foto berhasil diupdate!");
        return data['image']; // Mengembalikan path foto yang baru (contoh: /uploads/foto123.jpg)
      }
      return null;
    } catch (e) {
      print("❌ Error Update Photo: $e");
      return null;
    }
  }
}