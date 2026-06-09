import 'dart:convert';
import 'dart:io';
import 'package:activelab/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'user_session.dart';

class UserApiService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await UserSession.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
      }),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) {
      throw Exception(data['message'] ?? 'Login gagal');
    }
    return data;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users/profile'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) {
      throw Exception(data['message'] ?? 'Gagal memuat profil');
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? gender,
    File? photoFile,
  }) async {
    final token = await UserSession.getToken();
    final uri = Uri.parse('${AppConfig.baseUrl}/users/profile');

    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name;

    if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
    if (gender != null && gender.isNotEmpty) request.fields['gender'] = gender;

    if (photoFile != null) {
      final bytes = await photoFile.readAsBytes();
      final extension = photoFile.path.split('.').last.toLowerCase();
      final subType = extension == 'png' ? 'png' : 'jpeg';

      request.files.add(http.MultipartFile.fromBytes(
        'user_photo',
        bytes,
        filename: 'profile.$extension',
        contentType: MediaType('image', subType),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (!data['success']) {
      throw Exception(data['message'] ?? 'Gagal memperbarui profil');
    }
    return data;
  }

  static Future<void> deleteAccount() async {
    final res = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/users/me'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) {
      throw Exception(data['message'] ?? 'Gagal menghapus akun');
    }
  }
}