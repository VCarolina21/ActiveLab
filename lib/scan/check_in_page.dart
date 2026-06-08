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
      final pending = all.where((b) {
        if (!b.isPending) return false;
        final expires = b.checkinQrExpiresAt;
        if (expires == null) return true; 
        return expires.isAfter(now);
      }).toList();
      setState(() => _pendingBookings = pending);
    } catch (_) {
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
      backgroundColor: const Color(0xFFF4F8FF),
      body: Column(
        children: [

          _buildModernHeader(),


          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menunggu Check-in',
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
                    color: const Color(0xFFDEEEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_pendingBookings.length} booking',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A6FD4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),


          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A6FD4),
                            strokeWidth: 2.5,
                          ),
                        )
                      : _pendingBookings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _pendingBookings.length,
                          itemBuilder: (_, i) =>
                              _buildBookingCard(_pendingBookings[i]),
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
        color: Color(0xFF1A6FD4),
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
                        'Check - in',
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
              // Date info card
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
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hari ini',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.dateString,
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
              color: const Color(0xFFE8F2FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Color(0xFF1A6FD4),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada booking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada booking yang\nmenunggu check-in',
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
            true,
            () {},
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
            false,
            () {
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
            },
          ),
        ],
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
        expiryText = h > 0
            ? "Expired dalam ${h}j ${m}m"
            : "Expired dalam ${m}m";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A6FD4).withValues(alpha: 0.06),
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
              // Accent bar kiri
              Container(width: 5, color: const Color(0xFF1A6FD4)),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama layanan + badge expiry
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
                          if (expiryText.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                expiryText,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Divider
                      Container(height: 1, color: const Color(0xFFF0F4FB)),
                      const SizedBox(height: 10),
                      // Tanggal & waktu
                      _infoRow(
                        Icons.calendar_today_rounded,
                        "${sch['date']}  •  ${sch['start_time']} - ${sch['end_time']} ${sch['timezone']}",
                      ),
                      const SizedBox(height: 6),
                      // Room
                      _infoRow(
                        Icons.meeting_room_outlined,
                        "${sch['room_type_name']} - ${sch['room_name_name']}",
                      ),
                      const SizedBox(height: 6),
                      // Cabang
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Color(0xFF1A6FD4),
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
                      const SizedBox(height: 14),
                      // Tombol Check In
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CheckinDetailPage(booking: booking),
                              ),
                            ).then((_) => _loadBookings());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A6FD4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Check-In',
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


  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }



  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomAction(
          context,
          Icons.login_rounded,
          "Check - In",
          true,
          () {},
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
          false,
          () {
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
          },
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
          color: isActive ? const Color(0xFF1A6FD4) : Colors.transparent,
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
