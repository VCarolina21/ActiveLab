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
        final schedEnd = b.schedule['end_time'] as String? ?? '';
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
        final schedEnd = b.schedule['end_time'] as String? ?? '';
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
      backgroundColor: const Color(0xFFF4F8FF),
      body: Column(
        children: [
          // ── Header modern ──────────────────────────────────
          _buildModernHeader(),

          // ── Section label ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menunggu Check-out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEF7EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_checkedInBookings.length} sesi aktif',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F6E56),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── LIST BOOKING ───────────────────────────────────
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0F6E56),
                            strokeWidth: 2.5,
                          ),
                        )
                      : _checkedInBookings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _checkedInBookings.length,
                          itemBuilder: (_, i) =>
                              _buildBookingCard(_checkedInBookings[i]),
                        ),
                ),

                // ── Tombol Check-In / History / Check-Out ──
                _buildModernBottomNav(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F6E56),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              // App bar row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Check - out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _loadBookings,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Info card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesi Aktif',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_checkedInBookings.length} booking menunggu checkout',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFDEF7EC),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.exit_to_app_rounded,
              color: Color(0xFF0F6E56),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada sesi aktif',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada sesi yang\nmenunggu check-out',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomAction(
            context,
            Icons.login_rounded,
            "Check - In",
            false,
            () {
              Navigator.pop(context);
            },
          ),
          _buildBottomAction(
            context,
            Icons.history_rounded,
            "History",
            false,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          _buildBottomAction(
            context,
            Icons.logout_rounded,
            "Check - Out",
            true,
            () {},
          ),
        ],
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
        deadlineText = h > 0
            ? "Expired dalam ${h}j ${m}m"
            : "Expired dalam ${m}m";
      }
    } else {
      // Hitung dari schedule
      final schedDate = sch['date'] as String? ?? '';
      final schedEnd = sch['end_time'] as String? ?? '';
      if (schedDate.isNotEmpty && schedEnd.isNotEmpty) {
        try {
          final endDateTime = DateTime.parse("${schedDate}T$schedEnd:00");
          final deadline = endDateTime.add(const Duration(hours: 1));
          final diff = deadline.difference(DateTime.now());
          if (!diff.isNegative) {
            final h = diff.inHours;
            final m = diff.inMinutes % 60;
            deadlineText = h > 0
                ? "Checkout sebelum ${h}j ${m}m lagi"
                : "Checkout sebelum ${m}m lagi";
          }
        } catch (_) {}
      }
    }

    // Waktu check-in dilakukan
    final checkinTime = booking.checkinAt;
    final checkinStr = checkinTime != null
        ? "${checkinTime.hour.toString().padLeft(2, '0')}:${checkinTime.minute.toString().padLeft(2, '0')}"
        : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4F3EE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F6E56).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Accent bar kiri (hijau untuk checkout)
              Container(width: 5, color: const Color(0xFF0F6E56)),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama layanan + badge Checked In
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${sch['service_type_name']} - ${sch['service_name_name']}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEF7EC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFF0F6E56,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'Checked In',
                              style: TextStyle(
                                color: Color(0xFF0F6E56),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Divider
                      Container(height: 1, color: const Color(0xFFF0F4FB)),
                      const SizedBox(height: 10),
                      // Tanggal & waktu sesi
                      _infoRow(
                        Icons.calendar_today_rounded,
                        "${sch['date']}  •  ${sch['start_time']} - ${sch['end_time']} ${sch['timezone']}",
                      ),
                      const SizedBox(height: 6),
                      // Waktu check-in
                      _infoRow(
                        Icons.login_rounded,
                        'Check-in pukul $checkinStr',
                      ),
                      const SizedBox(height: 6),
                      // Cabang
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Color(0xFF0F6E56),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              booking.branch['name'] as String? ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Deadline checkout
                      if (deadlineText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              deadlineText,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      // Tombol Check Out
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CheckoutDetailPage(booking: booking),
                              ),
                            ).then((_) => _loadBookings());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F6E56),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Check-Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper info row ─────────────────────────────────────
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ── 3 Tombol bawah ───────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomAction(
          context,
          Icons.login_rounded,
          "Check - In",
          false,
          () {
            Navigator.pop(context);
          },
        ),
        _buildBottomAction(
          context,
          Icons.history_rounded,
          "History",
          false,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          },
        ),
        _buildBottomAction(
          context,
          Icons.logout_rounded,
          "Check - Out",
          true,
          () {},
        ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F6E56) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF8A97B0),
              size: 22,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF8A97B0),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
