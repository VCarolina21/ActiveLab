import 'dart:convert';
import 'package:activelab/config/services/user_session.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class UserMembershipModel {
  final int id;
  final String status;
  final String expireDate;
  final String? freezeStart;
  final int daysRemaining;
  final int membershipId;
  final String membershipName;
  final double price;
  final int activeDays;
  final int level;
  final String? description;
  final int branchId;
  final String branchName;
  final String? branchAddress;
  final String? branchPhoto;
  final List<Map<String, dynamic>> benefits;

  UserMembershipModel({
    required this.id,
    required this.status,
    required this.expireDate,
    this.freezeStart,
    required this.daysRemaining,
    required this.membershipId,
    required this.membershipName,
    required this.price,
    required this.activeDays,
    required this.level,
    this.description,
    required this.branchId,
    required this.branchName,
    this.branchAddress,
    this.branchPhoto,
    required this.benefits,
  });

  bool get isFrozen => status == 'frozen';

  factory UserMembershipModel.fromJson(Map<String, dynamic> json) =>
    UserMembershipModel(
      id:             json['id'] as int,
      status:         json['status'] as String,
      expireDate:     json['expire_date'] as String,
      freezeStart:    json['freeze_start'] as String?,
      daysRemaining:  json['days_remaining'] as int? ?? 0,
      membershipId:   json['membership_id'] as int,
      membershipName: json['membership_name'] as String,
      price:          double.tryParse(json['price'].toString()) ?? 0,
      activeDays:     json['active_days'] as int,
      level:          json['level'] as int,
      description:    json['description'] as String?,
      branchId:       json['branch_id'] as int,
      branchName:     json['branch_name'] as String,
      branchAddress:  json['branch_address'] as String?,
      branchPhoto:    json['branch_photo'] as String?,
      benefits:       (json['benefits'] as List<dynamic>?)
                        ?.map((b) => Map<String, dynamic>.from(b as Map))
                        .toList() ?? [],
    );
}

class MembershipApiService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await UserSession.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<UserMembershipModel>> getUserMemberships() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users/memberships'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    return (data['data'] as List)
        .map((m) => UserMembershipModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  static Future<void> freeze(int userMembershipId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/users/memberships/$userMembershipId/freeze'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
  }

  static Future<void> unfreeze(int userMembershipId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/users/memberships/$userMembershipId/unfreeze'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
  }

  static Future<List<Map<String, dynamic>>> getUpgradeOptions(int userMembershipId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users/memberships/$userMembershipId/upgrade-options'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    return (data['data'] as List).map((m) => Map<String, dynamic>.from(m as Map)).toList();
  }

  static Future<List<Map<String, dynamic>>> getDowngradeOptions(int userMembershipId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users/memberships/$userMembershipId/downgrade-options'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    return (data['data'] as List).map((m) => Map<String, dynamic>.from(m as Map)).toList();
  }

  static Future<void> downgrade(int userMembershipId, int newMembershipId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/users/memberships/$userMembershipId/downgrade'),
      headers: await _authHeaders(),
      body: jsonEncode({'new_membership_id': newMembershipId}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
  }

  static Future<void> cancelMembership(int userMembershipId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/users/memberships/$userMembershipId/cancel'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
  }
}