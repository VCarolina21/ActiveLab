import 'dart:async';
import 'package:activelab/config/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/booking_api_service.dart';
import '../home/home_page.dart';

class CheckoutDetailPage extends StatefulWidget {
  final BookingModel booking;

  const CheckoutDetailPage({super.key, required this.booking});

  @override
  State<CheckoutDetailPage> createState() => _CheckoutDetailPageState();
}

class _CheckoutDetailPageState extends State<CheckoutDetailPage> {
  CodeData? _codeData;
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCode() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final code = await BookingApiService.getCheckoutCode(widget.booking.id);
      setState(() {
        _codeData = code;
        _remaining = code.expiresAt.difference(DateTime.now());
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
      final r = _codeData!.expiresAt.difference(DateTime.now());
      setState(() => _remaining = r.isNegative ? Duration.zero : r);
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      try {
        final updated = await BookingApiService.getBookingById(widget.booking.id);
        if (!mounted) return;
        if (updated.isCheckedOut) {
          _pollingTimer?.cancel();
          _countdownTimer?.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Check-out berhasil!"), backgroundColor: Colors.green),
          );
          final userData = await UserSession.getUserData();
          final name = userData['name'] as String? ?? '';
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomePage(userName: name)),
            (route) => false,
          );
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
        title: const Text("Check Out", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : _error != null
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 15),
              Text(_error!, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loadCode, child: const Text("Coba Lagi")),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                // Info jadwal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF5F7F9), borderRadius: BorderRadius.circular(15)),
                  child: Column(children: [
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
                    Text(
                      widget.booking.branch['name'] as String? ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ]),
                ),
                const SizedBox(height: 30),

                const Text("Tunjukkan kode ini ke Admin untuk Check Out",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 8),

                // Countdown
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.timer, color: _remaining.inMinutes < 5 ? Colors.red : Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Text("Expired dalam: $_timeString",
                    style: TextStyle(
                      color: _remaining.inMinutes < 5 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    )),
                ]),
                const SizedBox(height: 30),

                // ── Kode Unik (BESAR, Gradient Hijau) ────────────────
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _codeData!.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kode disalin"), duration: Duration(seconds: 1)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade400],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 20, offset: const Offset(0, 8),
                      )],
                    ),
                    child: Column(children: [
                      const Text("KODE CHECK-OUT",
                        style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Text(
                        _codeData!.code,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 48,
                          fontWeight: FontWeight.bold, letterSpacing: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.copy, color: Colors.white54, size: 14),
                        SizedBox(width: 4),
                        Text("Tap untuk salin", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Polling indicator
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green)),
                  SizedBox(width: 10),
                  Text("Menunggu konfirmasi admin...", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ]),
              ]),
            ),
    );
  }
}