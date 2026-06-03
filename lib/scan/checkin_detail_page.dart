import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/booking_api_service.dart';

class CheckinDetailPage extends StatefulWidget {
  final BookingModel booking;

  const CheckinDetailPage({super.key, required this.booking});

  @override
  State<CheckinDetailPage> createState() => _CheckinDetailPageState();
}

class _CheckinDetailPageState extends State<CheckinDetailPage> {
  QrData? _qrData;
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQr() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final qr = await BookingApiService.getCheckinQr(widget.booking.id);
      setState(() {
        _qrData = qr;
        _remaining = qr.expiresAt.difference(DateTime.now());
      });
      _startCountdown();
      _startPolling();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _qrData!.expiresAt.difference(DateTime.now());
      if (remaining.isNegative) {
        setState(() => _remaining = Duration.zero);
        _countdownTimer?.cancel();
      } else {
        setState(() => _remaining = remaining);
      }
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      try {
        final updated = await BookingApiService.getBookingById(widget.booking.id);
        if (!mounted) return;
        if (updated.isCheckedIn) {
          _pollingTimer?.cancel();
          _countdownTimer?.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Check-in berhasil!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Return true = success
        }
      } catch (_) {}
    });
  }

  String get _timeString {
    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () { _pollingTimer?.cancel(); Navigator.pop(context); },
        ),
        title: const Text("Check In", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4285F4)))
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 15),
                  Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 15), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _loadQr, child: const Text("Coba Lagi")),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Info jadwal
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${widget.booking.schedule['service_type_name']} - ${widget.booking.schedule['service_name_name']}",
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${widget.booking.schedule['date']}  •  ${widget.booking.schedule['start_time']} - ${widget.booking.schedule['end_time']}",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.booking.branch['name'] as String? ?? '',
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Tunjukkan QR ini ke Admin",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  // Countdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, color: _remaining.inMinutes < 5 ? Colors.red : Colors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text("Expired dalam: $_timeString",
                        style: TextStyle(
                          color: _remaining.inMinutes < 5 ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.bold,
                        )),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))],
                    ),
                    child: QrImageView(
                      data: _qrData!.qrToken,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kode manual
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4285F4), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text("Kode Manual Check-in",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(
                          _qrData!.code,
                          style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold,
                            color: Color(0xFF4285F4), letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("(Berikan ke admin jika QR tidak bisa di-scan)",
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Polling indicator
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4285F4))),
                      SizedBox(width: 10),
                      Text("Menunggu konfirmasi admin...", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}