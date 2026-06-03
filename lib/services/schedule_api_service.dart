import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ScheduleModel {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String timezone;
  final int totalSlots;
  final int availableSlots;
  final Map<String, dynamic> serviceType;
  final Map<String, dynamic> serviceName;
  final Map<String, dynamic> roomType;
  final Map<String, dynamic> roomName;
  final List<Map<String, dynamic>> staffs;

  ScheduleModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.timezone,
    required this.totalSlots,
    required this.availableSlots,
    required this.serviceType,
    required this.serviceName,
    required this.roomType,
    required this.roomName,
    required this.staffs,
  });

  bool get isFull => availableSlots <= 0;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id:               json['id'] as int,
    date:             json['date'] as String,
    startTime:        json['start_time'] as String,
    endTime:          json['end_time'] as String,
    durationMinutes:  json['duration_minutes'] as int,
    timezone:         json['timezone'] as String? ?? 'WIB',
    totalSlots:       json['total_slots'] as int? ?? 0,
    availableSlots:   json['available_slots'] as int? ?? 0,
    serviceType:      Map<String, dynamic>.from(json['service_type'] as Map),
    serviceName:      Map<String, dynamic>.from(json['service_name'] as Map),
    roomType:         Map<String, dynamic>.from(json['room_type'] as Map),
    roomName:         Map<String, dynamic>.from(json['room_name'] as Map),
    staffs:           (json['staffs'] as List<dynamic>?)
                        ?.map((s) => Map<String, dynamic>.from(s as Map))
                        .toList() ?? [],
  );
}

class ScheduleApiService {
  static Future<Map<String, List<ScheduleModel>>> getSchedules({
    required int branchId,
    required int serviceNameId,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/public/schedules?branch_id=$branchId&service_name_id=$serviceNameId',
    );
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message'] ?? 'Gagal memuat jadwal');

    final raw = data['data'] as Map<String, dynamic>;
    final result = <String, List<ScheduleModel>>{};
    for (final entry in raw.entries) {
      result[entry.key] = (entry.value as List)
          .map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    return result;
  }
}