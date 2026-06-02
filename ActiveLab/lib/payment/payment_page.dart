import 'dart:async';
import 'package:activelab/config/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:intl/intl.dart';
import '../services/payment_service.dart';
import '../home/home_page.dart';

class PaymentPage extends StatefulWidget {
  final int membershipId;
  final String transactionType; // 'new', 'renew', 'upgrade'
  final int? userMembershipId;

  const PaymentPage({
    super.key,
    required this.membershipId,
    this.transactionType = 'new',
    this.userMembershipId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentResult? _paymentResult;
  String _paymentStatus = 'pending'; // pending / success / failed / expired
  bool _isCreatingPayment = true;
  Timer? _pollingTimer;

  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _createPayment();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _createPayment() async {
    try {
      final result = await PaymentService.createPayment(
        membershipId: widget.membershipId,
        transactionType: widget.transactionType,
        userMembershipId: widget.userMembershipId,
      );
      setState(() {
        _paymentResult = result;
        _isCreatingPayment = false;
      });
      // Mulai polling setiap 3 detik
      _startPolling(result.orderId);
    } catch (e) {
      setState(() {
        _isCreatingPayment = false;
        _paymentStatus = 'failed';
      });
    }
  }

  void _startPolling(String orderId) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) { timer.cancel(); return; }
      final status = await PaymentService.checkStatus(orderId);
      if (!mounted) { timer.cancel(); return; }

      if (status == 'success') {
        timer.cancel();
        setState(() => _paymentStatus = 'success');
        // Tunggu 2 detik lalu navigasi ke home
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        final userData = await UserSession.getUserData();
        final name = userData['name'] as String? ?? '';
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage(userName: name)),
          (route) => false,
        );
      } else if (status == 'expired' || status == 'failed') {
        timer.cancel();
        setState(() => _paymentStatus = status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── Loading saat buat transaksi ────────────────────────────
    if (_isCreatingPayment) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4285F4)),
              SizedBox(height: 20),
              Text("Membuat transaksi...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // ── Gagal buat transaksi ───────────────────────────────────
    if (_paymentResult == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 15),
              const Text("Gagal membuat transaksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () { setState(() => _isCreatingPayment = true); _createPayment(); },
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    // ── Tampilan utama ─────────────────────────────────────────
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _pollingTimer?.cancel();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Pembayaran QRIS",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildPaymentBody(),
    );
  }

  Widget _buildPaymentBody() {
    // ── STATUS SUCCESS ─────────────────────────────────────────
    if (_paymentStatus == 'success') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pembayaran Berhasil!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 10),
            Text(
              _paymentResult!.membershipName,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Text(
              "Mengarahkan ke halaman utama...",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // ── STATUS EXPIRED / FAILED ────────────────────────────────
    if (_paymentStatus == 'expired' || _paymentStatus == 'failed') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 70),
            const SizedBox(height: 20),
            Text(
              _paymentStatus == 'expired' ? "QR Code Kadaluarsa" : "Pembayaran Gagal",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { setState(() { _isCreatingPayment = true; _paymentStatus = 'pending'; }); _createPayment(); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4)),
              child: const Text("Buat QR Baru", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // ── STATUS PENDING — tampilkan QR ─────────────────────────
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          // Info membership
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  _paymentResult!.membershipName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _paymentResult!.branchName,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  formatter.format(_paymentResult!.amount),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // QR Code
          const Text(
            "Scan QR Code ini untuk membayar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "QR Code berlaku 30 menit",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // PERUBAHAN: Menampilkan Gambar QR URL Langsung dari Server Midtrans
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: _paymentResult!.qrImageUrl != null
                ? Image.network(
                    _paymentResult!.qrImageUrl!,
                    width: 250.0,
                    height: 250.0,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 250,
                        height: 250,
                        child: Center(
                          child: Text(
                            "Gagal memuat gambar QR",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 250,
                        height: 250,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  )
                : const SizedBox(
                    width: 250,
                    height: 250,
                    child: Center(child: Text("Link QR tidak tersedia")),
                  ),
          ),
          const SizedBox(height: 20),

          // Indikator polling
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4285F4)),
              ),
              SizedBox(width: 10),
              Text("Menunggu pembayaran...", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),

          // Link simulator untuk testing sandbox
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9800)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Mode Testing Sandbox",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF9800)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Gunakan Midtrans QRIS Simulator untuk test pembayaran:",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  _paymentResult!.simulatorUrl,
                  style: const TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 15), 
                
                // Kumpulan tombol aksi testing
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    // Tombol Salin String Lama
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _paymentResult!.qrString));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('QR String berhasil disalin!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text("Salin String", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    // PERUBAHAN: Tombol Baru untuk menyalin URL Gambar QR Code (Sangat ampuh untuk Simulator V2)
                    if (_paymentResult!.qrImageUrl != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _paymentResult!.qrImageUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('URL Gambar QR berhasil disalin!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.link, size: 14),
                        label: const Text("Salin URL QR", style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}