import 'dart:convert';
import 'package:activelab/config/services/user_session.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';


class BookingModel {
  final int id;
  final int userId;
  final String status;
  final DateTime createdAt;
  final DateTime? checkinAt;
  final DateTime? checkoutAt;
  final DateTime? checkinQrExpiresAt;
  final DateTime? checkoutQrExpiresAt;
  final Map<String, dynamic> schedule;
  final Map<String, dynamic> branch;
  final Map<String, dynamic> user;

  BookingModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.checkinAt,
    this.checkoutAt,
    this.checkinQrExpiresAt,
    this.checkoutQrExpiresAt,
    required this.schedule,
    required this.branch,
    required this.user,
  });

  bool get isPending    => status == 'pending';
  bool get isCheckedIn  => status == 'checked_in';
  bool get isCheckedOut => status == 'checked_out';
  bool get isCancelled  => status == 'cancelled';

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id:          json['id'] as int,
    userId:      json['user_id'] as int,
    status:      json['status'] as String,
    createdAt:   DateTime.parse(json['created_at'] as String),
    checkinAt:   json['checkin_at'] != null ? DateTime.parse(json['checkin_at'] as String) : null,
    checkoutAt:  json['checkout_at'] != null ? DateTime.parse(json['checkout_at'] as String) : null,
    checkinQrExpiresAt: json['checkin_qr_expires_at'] != null
        ? DateTime.parse(json['checkin_qr_expires_at'] as String) : null,
    checkoutQrExpiresAt: json['checkout_qr_expires_at'] != null
        ? DateTime.parse(json['checkout_qr_expires_at'] as String) : null,
    schedule: Map<String, dynamic>.from(json['schedule'] as Map),
    branch:   Map<String, dynamic>.from(json['branch'] as Map),
    user:     Map<String, dynamic>.from(json['user'] as Map),
  );
}

class QrData {
  final String qrToken;
  final String code;
  final DateTime expiresAt;

  QrData({required this.qrToken, required this.code, required this.expiresAt});

  factory QrData.fromJson(Map<String, dynamic> json) => QrData(
    qrToken:   json['qr_token'] as String,
    code:      json['checkin_code'] as String? ?? json['checkout_code'] as String? ?? '',
    expiresAt: DateTime.parse(json['expires_at'] as String),
  );
}

class BookingApiService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await UserSession.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<BookingModel>> getUserBookings() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/bookings'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    return (data['data'] as List)
        .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  static Future<List<BookingModel>> getBookingHistory() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/bookings/history'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    return (data['data'] as List)
        .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  static Future<BookingModel> createBooking(int scheduleId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/bookings'),
      headers: await _authHeaders(),
      body: jsonEncode({'schedule_id': scheduleId}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    return BookingModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  static Future<void> cancelBooking(int bookingId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/bookings/$bookingId/cancel'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
  }

  static Future<void> hideBooking(int bookingId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/bookings/$bookingId/hide'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
  }

  static Future<QrData> getCheckinQr(int bookingId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/bookings/$bookingId/checkin-qr'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    final d = data['data'] as Map<String, dynamic>;
    return QrData(
      qrToken:   d['qr_token'] as String,
      code:      d['checkin_code'] as String? ?? '',
      expiresAt: DateTime.parse(d['expires_at'] as String),
    );
  }

  static Future<QrData> getCheckoutQr(int bookingId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/bookings/$bookingId/checkout-qr'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    final d = data['data'] as Map<String, dynamic>;
    return QrData(
      qrToken:   d['qr_token'] as String,
      code:      d['checkout_code'] as String? ?? '',
      expiresAt: DateTime.parse(d['expires_at'] as String),
    );
  }

  static Future<BookingModel> getBookingById(int bookingId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/bookings/$bookingId'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message']);
    return BookingModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}