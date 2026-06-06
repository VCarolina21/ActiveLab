import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/booking_api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BookingModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await BookingApiService.getBookingHistory();
      setState(() => _history = data);
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(BookingModel booking) async {
    try {
      await BookingApiService.hideBooking(booking.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A6FD4),
                      strokeWidth: 2.5,
                    ),
                  )
                : _history.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: _history.length,
                    itemBuilder: (_, i) => _buildHistoryCard(_history[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A3A5C),
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
                        color: Colors.white.withValues(alpha: 0.15),
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
                        'History Booking',
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
                    onTap: _load,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
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
              // Summary card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Riwayat',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_history.length} booking',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Mini stats
                    _miniStat(
                      label: 'Selesai',
                      count: _history.where((b) => b.isCheckedOut).length,
                      color: const Color(0xFF5DCAA5),
                    ),
                    const SizedBox(width: 12),
                    _miniStat(
                      label: 'Batal',
                      count: _history.where((b) => !b.isCheckedOut).length,
                      color: const Color(0xFFF09595),
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

  Widget _miniStat({
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              color: const Color(0xFFE8EEF8),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Color(0xFF1A3A5C),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Riwayat booking kamu\nakan muncul di sini',
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

  Widget _buildHistoryCard(BookingModel b) {
    final isSelesai = b.isCheckedOut;
    final statusText = isSelesai ? 'Selesai' : 'Dibatalkan';

    // Warna per status
    final accentColor = isSelesai
        ? const Color(0xFF0F6E56)
        : const Color(0xFFA32D2D);
    final bgColor = isSelesai
        ? const Color(0xFFDEF7EC)
        : const Color(0xFFFCEBEB);
    final textColor = isSelesai
        ? const Color(0xFF0F6E56)
        : const Color(0xFFA32D2D);
    final iconColor = isSelesai
        ? const Color(0xFF0F6E56)
        : const Color(0xFFA32D2D);

    // Format tanggal lebih rapi jika memungkinkan
    String dateStr = b.schedule['date'] as String? ?? '';
    try {
      final parsed = DateTime.parse(dateStr);
      dateStr = DateFormat('d MMM yyyy', 'id_ID').format(parsed);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A5C).withValues(alpha: 0.05),
            blurRadius: 14,
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
              Container(width: 5, color: accentColor),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama layanan + badge status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${b.schedule['service_type_name']} - ${b.schedule['service_name_name']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF1A1A2E),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelesai
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.cancel_outlined,
                                  size: 11,
                                  color: iconColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Divider
                      Container(height: 1, color: const Color(0xFFF0F4FB)),
                      const SizedBox(height: 10),
                      // Tanggal & jam
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$dateStr  •  ${b.schedule['start_time']} - ${b.schedule['end_time']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Cabang
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: accentColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              b.branch['name'] as String? ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Tombol hapus
                          GestureDetector(
                            onTap: () => _delete(b),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F8FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFF8A97B0),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
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
}
