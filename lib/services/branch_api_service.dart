import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// ─── Models ───────────────────────────────────────────────────────────────

class BranchModel {
  final int id;
  final String name;
  final String address;
  final String contact;
  final String? photo;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    this.photo,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
    id:      json['id'] as int,
    name:    json['name'] as String,
    address: json['address'] as String? ?? '',
    contact: json['contact'] as String? ?? '',
    photo:   json['photo'] as String?,
  );

  String? get photoUrl {
    if (photo == null || photo!.isEmpty) return null;
    return '${AppConfig.uploadsBaseUrl}/branches/$photo';
  }
}

class MembershipModel {
  final int id;
  final String name;
  final double price;
  final int activeDays;
  final String? description;
  final int level;
  final List<Map<String, dynamic>> benefits;

  MembershipModel({
    required this.id,
    required this.name,
    required this.price,
    required this.activeDays,
    this.description,
    required this.level,
    required this.benefits,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) => MembershipModel(
    id:          json['id'] as int,
    name:        json['name'] as String,
    price:       double.tryParse(json['price'].toString()) ?? 0,
    activeDays:  json['active_days'] as int,
    description: json['description'] as String?,
    level:       json['level'] as int,
    benefits:    (json['benefits'] as List<dynamic>?)
                   ?.map((b) => Map<String, dynamic>.from(b as Map))
                   .toList() ?? [],
  );
}

class ServiceNameModel {
  final int id;
  final String name;

  ServiceNameModel({required this.id, required this.name});

  factory ServiceNameModel.fromJson(Map<String, dynamic> json) =>
    ServiceNameModel(id: json['id'] as int, name: json['name'] as String);
}

class ServiceTypeModel {
  final int id;
  final String name;
  final List<ServiceNameModel> serviceNames;

  ServiceTypeModel({
    required this.id, 
    required this.name, 
    required this.serviceNames
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) => ServiceTypeModel(
    id:           json['id'] as int,
    name:         json['name'] as String,
    serviceNames: (json['service_names'] as List<dynamic>?)
                    ?.map((sn) => ServiceNameModel.fromJson(sn as Map<String, dynamic>))
                    .toList() ?? [],
  );
}

// ─── API Service ──────────────────────────────────────────────────────────

class BranchApiService {
  static Future<Map<String, dynamic>> getBranches({int page = 1, int limit = 10}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/public/branches?page=$page&limit=$limit');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message'] ?? 'Gagal memuat cabang');
    return data;
  }

  static Future<Map<String, dynamic>> getBranchDetail(int branchId) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/public/branches/$branchId');
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message'] ?? 'Gagal memuat detail');
    return data;
  }
}