import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// Staff Model
class StaffModel {
  final int id;
  final String name;
  final String? contact;
  final String? image;
  final String? description;
  final int branchId;
  final String branchName;

  StaffModel({
    required this.id,
    required this.name,
    this.contact,
    this.image,
    this.description,
    required this.branchId,
    required this.branchName,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
    id: json['id'] as int,
    name: json['name'] as String,
    contact: json['contact'] as String?,
    image: json['image'] as String?,
    description: json['description'] as String?,
    branchId: json['branch_id'] as int,
    branchName: json['branch_name'] as String,
  );

  String? get photoUrl {
    if (image == null || image!.isEmpty) return null;
    return '${AppConfig.uploadsBaseUrl}/staffs/$image';
  }
}

// Explore API Service

class ExploreApiService {
  /// Ambil semua staff dari semua cabang
  static Future<List<StaffModel>> getAllStaff({String? search}) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/public/staff${search != null && search.isNotEmpty ? "?search=$search" : ""}',
    );
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success'])
      throw Exception(data['message'] ?? 'Gagal memuat staff');
    return (data['data'] as List)
        .map((s) => StaffModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }
}
