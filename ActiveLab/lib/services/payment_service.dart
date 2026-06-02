import 'dart:convert';
import 'package:activelab/config/services/user_session.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PaymentResult {
  final String orderId;
  final String qrString;
  final String? qrImageUrl; // 1. Tambahkan properti ini (nullable karena bisa saja null)
  final int amount;
  final String membershipName;
  final String branchName;
  final String? expiryTime;
  final String simulatorUrl;
  // Untuk renew/upgrade, pass userMembershipId
  final int? userMembershipId;

  PaymentResult({
    required this.orderId,
    required this.qrString,
    this.qrImageUrl, // 2. Tambahkan di constructor
    required this.amount,
    required this.membershipName,
    required this.branchName,
    this.expiryTime,
    required this.simulatorUrl,
    this.userMembershipId,
  });
}

class PaymentService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await UserSession.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Buat transaksi pembayaran QRIS
  static Future<PaymentResult> createPayment({
    required int membershipId,
    String transactionType = 'new',
    int? userMembershipId,
  }) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/payments/create'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'membership_id': membershipId,
        'transaction_type': transactionType,
        if (userMembershipId != null) 'user_membership_id': userMembershipId,
      }),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) throw Exception(data['message'] ?? 'Gagal membuat pembayaran');

    final d = data['data'] as Map<String, dynamic>;
    return PaymentResult(
      orderId:          d['order_id'] as String,
      qrString:         d['qr_string'] as String,
      qrImageUrl:       d['qr_image_url'] as String?, // 3. Ambil data qr_image_url dari JSON backend
      amount:           d['amount'] as int,
      membershipName:   (d['membership'] as Map<String, dynamic>)['name'] as String,
      branchName:       (d['membership'] as Map<String, dynamic>)['branch_name'] as String,
      expiryTime:       d['expiry_time'] as String?,
      simulatorUrl:     d['simulator_url'] as String,
      userMembershipId: userMembershipId,
    );
  }

  /// Poll status pembayaran
  /// Return: 'pending' | 'success' | 'failed' | 'expired'
  static Future<String> checkStatus(String orderId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/payments/status/$orderId'),
      headers: await _authHeaders(),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data['success']) return 'failed';
    return (data['data'] as Map<String, dynamic>)['status'] as String? ?? 'pending';
  }
}