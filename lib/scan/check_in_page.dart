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
    _expireTimer = null;
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final all = await BookingApiService.getUserBookings();
      if (!mounted) return;

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
      if (!mounted) return;
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
    return const Center(
      child: Text('Tidak ada booking'),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomAction(context, Icons.login_rounded, "Check - In", true, () {}),
          _buildBottomAction(context, Icons.history_rounded, "History", false, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
          }),
          _buildBottomAction(context, Icons.logout_rounded, "Check - Out", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CheckOutPage(
                  bookingDates: widget.bookingDates,
                  roomType: widget.roomType,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return ListTile(
      title: Text(booking.schedule['service_name_name']),
      subtitle: Text(booking.branch['name'] ?? ''),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CheckinDetailPage(booking: booking)),
          ).then((_) {
            if (mounted) {
              _loadBookings();
            }
          });
        },
        child: const Text('Check-In'),
      ),
    );
  }
}