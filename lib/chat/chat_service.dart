import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/services/user_session.dart'; // Menarik data session user yang sedang login

class ChatService {
  final String baseUrl = 'http://10.0.2.2:5000/api/chats';
  final String staffApiUrl = 'http://10.0.2.2:5000/api/staff';
  final String publicStaffApiUrl = 'http://10.0.2.2:5000/api/public/staff';

  // Fungsi untuk mengambil ID User asli secara dinamis
  Future<int> _getCurrentUserId() async {
    final userData = await UserSession.getUserData();
    if (userData != null && userData['id'] != null) {
      return int.tryParse(userData['id'].toString()) ?? 99;
    }
    return 99; // Fallback darurat jika session gagal terbaca
  }

  Future<List<dynamic>> fetchStaffList() async {
    try {
      var response = await http.get(Uri.parse(staffApiUrl));
      if (response.statusCode != 200) {
        response = await http.get(Uri.parse(publicStaffApiUrl));
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? data ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> fetchMessages(int staffId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      // URL sekarang menembak menggunakan ID User asli, bukan 99
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$currentUserId?staff_id=$staffId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage(int staffId, String message) async {
    try {
      final currentUserId = await _getCurrentUserId();
      final response = await http.post(
        Uri.parse('$baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': currentUserId,
          'receiver_id': staffId,
          'message': message,
          'is_admin': false,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
