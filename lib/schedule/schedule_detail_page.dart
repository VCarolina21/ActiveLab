import 'package:activelab/config/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/schedule_api_service.dart';
import '../services/booking_api_service.dart';
import '../sign_in/sign_page.dart';
import '../profile/booking_page.dart';

class ScheduleDetailPage extends StatefulWidget {
  final ScheduleModel schedule;
  final int branchId;
  final String branchName;
  final String branchAddress;

  const ScheduleDetailPage({
    super.key,
    required this.schedule,
    required this.branchId,
    required this.branchName,
    required this.branchAddress,
  });

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  bool _isBooking = false;
  final formatter = NumberFormat('###,###', 'id_ID');

  Future<void> _handleBookNow() async {
    final isLoggedIn = await UserSession.isLoggedIn();
    if (!mounted) return;

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu")),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignPage()));
      return;
    }

    setState(() => _isBooking = true);
    try {
      await BookingApiService.createBooking(widget.schedule.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Booking berhasil! Cek My Bookings untuk detail."),
          backgroundColor: Colors.green,
        ),
      );
      // Navigasi ke booking page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BookingPage()),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sch = widget.schedule;
    final dateFormatted = DateFormat('EEEE, d MMMM yyyy').format(DateTime.parse(sch.date));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Jadwal", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header gradient ─────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${sch.serviceType['name']} - ${sch.serviceName['name']}",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.branchName,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Icon(Icons.access_time, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text("${sch.startTime} - ${sch.endTime} ${sch.timezone}",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text("${sch.durationMinutes} menit",
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 16),
                    Icon(Icons.people, color: sch.isFull ? Colors.redAccent : Colors.greenAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "${sch.availableSlots}/${sch.totalSlots} slot",
                      style: TextStyle(color: sch.isFull ? Colors.redAccent : Colors.greenAccent, fontSize: 13),
                    ),
                  ]),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailSection("Informasi Jadwal", [
                    _detailRow(Icons.calendar_today, "Tanggal", dateFormatted),
                    _detailRow(Icons.access_time, "Waktu", "${sch.startTime} - ${sch.endTime} ${sch.timezone}"),
                    _detailRow(Icons.timer, "Durasi", "${sch.durationMinutes} menit"),
                    _detailRow(Icons.spa_outlined, "Tipe Layanan", sch.serviceType['name'] as String),
                    _detailRow(Icons.star_outline, "Nama Layanan", sch.serviceName['name'] as String),
                  ]),
                  const SizedBox(height: 20),
                  _detailSection("Ruangan", [
                    _detailRow(Icons.category_outlined, "Tipe Ruangan", sch.roomType['name'] as String),
                    _detailRow(Icons.meeting_room_outlined, "Nama Ruangan", sch.roomName['name'] as String),
                  ]),
                  const SizedBox(height: 20),
                  if (sch.staffs.isNotEmpty) ...[
                    _detailSection("Staff", sch.staffs.map((s) =>
                      _detailRow(Icons.person_outline, "Staff", s['name'] as String)
                    ).toList()),
                    const SizedBox(height: 20),
                  ],
                  _detailSection("Lokasi", [
                    _detailRow(Icons.location_on_outlined, "Cabang", widget.branchName),
                    _detailRow(Icons.map_outlined, "Alamat", widget.branchAddress),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: (sch.isFull || _isBooking) ? null : _handleBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: sch.isFull ? Colors.grey : const Color(0xFF4285F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isBooking
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text(
                    sch.isFull ? "Jadwal Penuh" : "Book Now",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4285F4), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}