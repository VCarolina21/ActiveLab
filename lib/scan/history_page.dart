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
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await BookingApiService.getBookingHistory();
      setState(() => _history = data);
    } catch (_) {} finally {
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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("History Booking", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.black), onPressed: _load)],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4285F4)))
        : _history.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.history, size: 60, color: Colors.grey),
              SizedBox(height: 15),
              Text("Belum ada history booking", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _history.length,
              itemBuilder: (_, i) {
                final b = _history[i];
                final statusColor = b.isCheckedOut ? Colors.green : Colors.red;
                final statusText = b.isCheckedOut ? "Selesai" : "Dibatalkan";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Status indicator
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                          margin: const EdgeInsets.only(right: 12),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${b.schedule['service_type_name']} - ${b.schedule['service_name_name']}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text("${b.schedule['date']}  ${b.schedule['start_time']} - ${b.schedule['end_time']}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(b.branch['name'] as String? ?? '',
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _delete(b),
                              child: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}