import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/booking_api_service.dart';
import '../scan/checkin_detail_page.dart';
import '../scan/checkout_detail_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await BookingApiService.getUserBookings();
      setState(() => _bookings = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel(BookingModel booking) async {
    final confirmed = await _showCancelDialog(booking);
    if (!confirmed) return;
    try {
      await BookingApiService.cancelBooking(booking.id);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking berhasil dibatalkan"), backgroundColor: Colors.orange),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _showCancelDialog(BookingModel booking) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 4)),
                child: const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.redAccent),
              ),
              const SizedBox(height: 20),
              const Text("Cancel Booking?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                "Yakin ingin membatalkan booking\n${booking.schedule['service_name_name']} pada ${booking.schedule['date']}?",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF303F9F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Kembali", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5), Color(0xFFB3E5FC), Colors.white],
            stops: [0.0, 0.25, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text("My Bookings",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _load,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
                  : _bookings.isEmpty
                    ? const Center(child: Text("Belum ada booking aktif.",
                        style: TextStyle(color: Colors.white70, fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _bookings.length,
                      itemBuilder: (_, i) => _buildBookingCard(_bookings[i]),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final sch = booking.schedule;
    final statusColor = booking.isPending ? Colors.orange
        : booking.isCheckedIn ? Colors.green
        : Colors.grey;
    final statusText = booking.isPending ? "Pending"
        : booking.isCheckedIn ? "Checked In" : booking.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nama service + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${sch['service_type_name']} - ${sch['service_name_name']}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(statusText,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Tanggal & waktu
            Row(children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${sch['date']}  ${sch['start_time']} - ${sch['end_time']} ${sch['timezone']}",
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(child: Text(booking.branch['name'] as String? ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 13))),
            ]),
            const SizedBox(height: 14),

            // Action buttons
            Row(children: [
              if (booking.isPending) ...[
                Expanded(
                  child: _actionBtn("Cancel", Colors.red, () => _cancel(booking)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionBtn("Check In", const Color(0xFF4285F4), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CheckinDetailPage(booking: booking)),
                    ).then((_) => _load());
                  }),
                ),
              ] else if (booking.isCheckedIn) ...[
                Expanded(
                  child: _actionBtn("Check Out", Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CheckoutDetailPage(booking: booking)),
                    ).then((_) => _load());
                  }),
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }
}