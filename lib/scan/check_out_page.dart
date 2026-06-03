import 'dart:async';
import 'package:flutter/material.dart';
import '../services/booking_api_service.dart';
import '../scan/checkout_detail_page.dart';
import 'history_page.dart';

class CheckOutPage extends StatefulWidget {
  final String bookingDates;
  final String roomType;
  final String phoneNumber;

  const CheckOutPage({
    super.key,
    required this.bookingDates,
    required this.roomType,
    required this.phoneNumber,
  });

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  List<BookingModel> _checkedInBookings = [];
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
      final now = DateTime.now();

      // Ambil yang sudah check-in DAN checkout belum expired
      // Expiry checkout = schedule end_time + 1 jam
      // Kita derive dari schedule data
      final checkedIn = all.where((b) {
        if (!b.isCheckedIn) return false;

        // Kalau checkout_qr_expires_at sudah diset, pakai itu
        final checkoutExpiry = b.checkoutQrExpiresAt;
        if (checkoutExpiry != null) {
          return checkoutExpiry.isAfter(now);
        }

        // Kalau belum diset, hitung dari schedule end_time + 1 jam
        final schedDate = b.schedule['date'] as String? ?? '';
        final schedEnd  = b.schedule['end_time'] as String? ?? '';
        if (schedDate.isEmpty || schedEnd.isEmpty) return true;

        try {
          final endDateTime = DateTime.parse("${schedDate}T$schedEnd:00");
          final deadline = endDateTime.add(const Duration(hours: 1));
          return deadline.isAfter(now);
        } catch (_) {
          return true;
        }
      }).toList();

      setState(() => _checkedInBookings = checkedIn);
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
      _checkedInBookings.removeWhere((b) {
        final checkoutExpiry = b.checkoutQrExpiresAt;
        if (checkoutExpiry != null) return checkoutExpiry.isBefore(now);

        // Derive dari schedule
        final schedDate = b.schedule['date'] as String? ?? '';
        final schedEnd  = b.schedule['end_time'] as String? ?? '';
        if (schedDate.isEmpty || schedEnd.isEmpty) return false;
        try {
          final endDateTime = DateTime.parse("${schedDate}T$schedEnd:00");
          final deadline = endDateTime.add(const Duration(hours: 1));
          return deadline.isBefore(now);
        } catch (_) {
          return false;
        }
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
                          "Check - out",
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
                    // List booking yang sudah check-in, menunggu checkout
                    Expanded(
                      child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : _checkedInBookings.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.exit_to_app, color: Colors.white54, size: 60),
                                  SizedBox(height: 12),
                                  Text(
                                    "Tidak ada sesi yang\nmenunggu check-out",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70, fontSize: 15),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _checkedInBookings.length,
                              itemBuilder: (_, i) => _buildBookingCard(_checkedInBookings[i]),
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

  // Card booking yang menunggu checkout
  Widget _buildBookingCard(BookingModel booking) {
    final sch = booking.schedule;

    // Hitung deadline checkout
    String deadlineText = "";
    final checkoutExpiry = booking.checkoutQrExpiresAt;
    if (checkoutExpiry != null) {
      final diff = checkoutExpiry.difference(DateTime.now());
      if (diff.isNegative) {
        deadlineText = "Expired";
      } else {
        final h = diff.inHours;
        final m = diff.inMinutes % 60;
        deadlineText = h > 0 ? "Expired dalam ${h}j ${m}m" : "Expired dalam ${m}m";
      }
    } else {
      // Hitung dari schedule
      final schedDate = sch['date'] as String? ?? '';
      final schedEnd  = sch['end_time'] as String? ?? '';
      if (schedDate.isNotEmpty && schedEnd.isNotEmpty) {
        try {
          final endDateTime = DateTime.parse("${schedDate}T$schedEnd:00");
          final deadline = endDateTime.add(const Duration(hours: 1));
          final diff = deadline.difference(DateTime.now());
          if (!diff.isNegative) {
            final h = diff.inHours;
            final m = diff.inMinutes % 60;
            deadlineText = h > 0 ? "Checkout sebelum ${h}j ${m}m lagi" : "Checkout sebelum ${m}m lagi";
          }
        } catch (_) {}
      }
    }

    // Waktu check-in dilakukan
    final checkinTime = booking.checkinAt;
    final checkinStr = checkinTime != null
      ? "${checkinTime.hour.toString().padLeft(2,'0')}:${checkinTime.minute.toString().padLeft(2,'0')}"
      : "-";

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
            // Nama layanan + badge checked-in
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${sch['service_type_name']} - ${sch['service_name_name']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Text("Checked In",
                    style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tanggal & waktu sesi
            Row(children: [
              const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                "${sch['date']}  •  ${sch['start_time']} - ${sch['end_time']} ${sch['timezone']}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ]),
            const SizedBox(height: 4),
            // Waktu check-in
            Row(children: [
              const Icon(Icons.login, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text("Check-in pukul $checkinStr",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
            // Deadline checkout
            if (deadlineText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.timer_outlined, size: 13, color: Colors.orange),
                const SizedBox(width: 5),
                Text(deadlineText,
                  style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500)),
              ]),
            ],
            const SizedBox(height: 12),
            // Tombol Check Out
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutDetailPage(booking: booking),
                    ),
                  ).then((_) => _loadBookings());
                },
                label: const Text("Check-Out",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
        _buildBottomAction(context, Icons.login, "Check - In", false, () {
          Navigator.pop(context);
        }),
        _buildBottomAction(context, Icons.history, "History", false, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryPage()),
          );
        }),
        _buildBottomAction(context, Icons.logout, "Check - Out", true, () {}),
      ],
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
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