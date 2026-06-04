import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/services/user_session.dart';
import '../config/app_config.dart'; // Menarik IP dinamis

class ChatService {
  // Sekarang URL akan otomatis mengikuti settingan app_config.dart
  final String baseUrl = '${AppConfig.baseUrl}/chats';
  final String staffApiUrl = '${AppConfig.baseUrl}/staff';
  final String publicStaffApiUrl = '${AppConfig.baseUrl}/public/staff';

  Future<int> _getCurrentUserId() async {
    try {
      final userData = await UserSession.getUserData();
      if (userData != null) {
        final rawId = userData['id'] ?? userData['user_id'] ?? userData['userId'] ?? userData['ID'];
        if (rawId != null) {
          return int.parse(rawId.toString());
        }
      }
    } catch (e) {
      // Abaikan error
    }
    return 0; 
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
      if (currentUserId == 0) return []; 

      final response = await http.get(Uri.parse('$baseUrl/messages/$currentUserId?staff_id=$staffId'));
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
      if (currentUserId == 0) return false; 

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