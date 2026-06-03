import 'dart:async';
import 'package:flutter/material.dart';
import '../services/booking_api_service.dart';
import '../scan/checkin_detail_page.dart';
import 'history_page.dart';
import 'check_out_page.dart';

class CheckInPage extends StatefulWidget {
  final String dateString;
  final String gymName;
  final String location;
  final double rating;
  final String imagePath;
  final String bookingDates;
  final String roomType;
  final String phoneNumber;
  final String status;
  final String? guestInfo;

  const CheckInPage({
    super.key,
    required this.dateString,
    required this.gymName,
    required this.location,
    required this.rating,
    required this.imagePath,
    required this.bookingDates,
    required this.roomType,
    required this.phoneNumber,
    required this.status,
    this.guestInfo,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<BookingModel> _pendingBookings = [];
  bool _isLoading = true;
  Timer? _expireTimer;

  @override
  void initState() {
    super.initState();
    _loadBookings();
    // Cek expiry setiap menit
    _expireTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _removeExpired();
    });
  }

  @override
  void dispose() {
    _expireTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final all = await BookingApiService.getUserBookings();
      // Ambil hanya yang pending DAN belum expired check-in
      final now = DateTime.now();
      final pending = all.where((b) {
        if (!b.isPending) return false;
        // checkin_qr_expires_at = schedule end time (expiry check-in)
        final expires = b.checkinQrExpiresAt;
        if (expires == null) return true; // belum ada expiry → masih valid
        return expires.isAfter(now);
      }).toList();
      setState(() => _pendingBookings = pending);
    } catch (_) {
      // Gagal load → tampilkan kosong
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeExpired() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _pendingBookings.removeWhere((b) {
        final expires = b.checkinQrExpiresAt;
        return expires != null && expires.isBefore(now);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF42A5F5),
              Color(0xFFB3E5FC),
              Colors.white,
            ],
            stops: [0.0, 0.25, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ── Header (TIDAK DIUBAH) ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Check - in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Tombol refresh
                    GestureDetector(
                      onTap: _loadBookings,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── LIST BOOKING (BARU) ──────────────────────────
              Expanded(
                child: Column(
                  children: [
                    // List booking pending
                    Expanded(
                      child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : _pendingBookings.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_available, color: Colors.white54, size: 60),
                                  SizedBox(height: 12),
                                  Text(
                                    "Tidak ada booking\nyang menunggu check-in",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70, fontSize: 15),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _pendingBookings.length,
                              itemBuilder: (_, i) => _buildBookingCard(_pendingBookings[i]),
                            ),
                    ),

                    // ── Tombol Check-In / History / Check-Out (TIDAK DIUBAH) ─
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: _buildActionButtons(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card setiap booking yang belum check-in
  Widget _buildBookingCard(BookingModel booking) {
    final sch = booking.schedule;

    // Hitung sisa waktu check-in
    final expires = booking.checkinQrExpiresAt;
    String expiryText = "";
    if (expires != null) {
      final diff = expires.difference(DateTime.now());
      if (diff.isNegative) {
        expiryText = "Expired";
      } else {
        final h = diff.inHours;
        final m = diff.inMinutes % 60;
        expiryText = h > 0 ? "Expired dalam ${h}j ${m}m" : "Expired dalam ${m}m";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama layanan + expired info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${sch['service_type_name']} - ${sch['service_name_name']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                if (expiryText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      expiryText,
                      style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Tanggal & waktu
            Row(children: [
              const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                "${sch['date']}  •  ${sch['start_time']} - ${sch['end_time']} ${sch['timezone']}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ]),
            const SizedBox(height: 4),
            // Room
            Row(children: [
              const Icon(Icons.meeting_room_outlined, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                "${sch['room_type_name']} - ${sch['room_name_name']}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ]),
            const SizedBox(height: 4),
            // Cabang
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  booking.branch['name'] as String? ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Tombol Check In
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckinDetailPage(booking: booking),
                    ),
                  ).then((_) => _loadBookings());
                },
                label: const Text("Check-In",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42A5F5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3 Tombol bawah (TIDAK DIUBAH SAMA SEKALI) ────────────────

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomAction(context, Icons.login, "Check - In", true, () {}),
        _buildBottomAction(context, Icons.history, "History", false, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryPage()),
          );
        }),
        _buildBottomAction(context, Icons.logout, "Check - Out", false, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckOutPage(
                bookingDates: widget.bookingDates,
                roomType: widget.roomType,
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomAction(
      BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF42A5F5) : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.black),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}