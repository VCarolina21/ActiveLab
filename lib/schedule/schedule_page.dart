import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/schedule_api_service.dart';
import '../services/branch_api_service.dart';
import 'schedule_detail_page.dart';

class SchedulePage extends StatefulWidget {
  final int branchId;
  final String branchName;
  final String branchAddress;
  final ServiceTypeModel serviceType;

  const SchedulePage({
    super.key,
    required this.branchId,
    required this.branchName,
    required this.branchAddress,
    required this.serviceType,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late ServiceNameModel _selectedServiceName;
  int _selectedDayIndex = 0;

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _dayKeys = List.generate(7, (_) => GlobalKey());

  // Schedule data grouped by date
  Map<String, List<ScheduleModel>> _scheduleData = {};
  bool _isLoading = false;
  String? _error;

  // 7 dates (today + 6 days)
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(7, (i) => now.add(Duration(days: i)));
    _selectedServiceName = widget.serviceType.serviceNames.isNotEmpty
        ? widget.serviceType.serviceNames.first
        : ServiceNameModel(id: 0, name: '');
    if (_selectedServiceName.id != 0) _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    if (_selectedServiceName.id == 0) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ScheduleApiService.getSchedules(
        branchId: widget.branchId,
        serviceNameId: _selectedServiceName.id,
      );
      setState(() => _scheduleData = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToDay(int index) {
    setState(() => _selectedDayIndex = index);
    final ctx = _dayKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Book a ${widget.serviceType.name}",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Service name tabs ──────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.serviceType.serviceNames.length,
              itemBuilder: (_, i) {
                final sn = widget.serviceType.serviceNames[i];
                final isSelected = _selectedServiceName.id == sn.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedServiceName = sn);
                    _fetchSchedules();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4285F4).withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      sn.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF4285F4) : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(height: 1, color: const Color(0xFFF1F5F9)),

          // ── 7-day date picker ─────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (_, index) {
                final date = _dates[index];
                final isSelected = _selectedDayIndex == index;
                return GestureDetector(
                  onTap: () => _scrollToDay(index),
                  child: Container(
                    width: 58,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFF4285F4).withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 3))]
                        : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E').format(date),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white70 : Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(DateFormat('d').format(date),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── Schedule list ─────────────────────────────────────
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4285F4)))
              : _error != null
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: _fetchSchedules, child: const Text("Coba Lagi")),
                    ],
                  ))
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: List.generate(7, (dayIndex) {
                      final date = _dates[dayIndex];
                      final dateStr = DateFormat('yyyy-MM-dd').format(date);
                      final daySchedules = _scheduleData[dateStr] ?? [];

                      return Column(
                        key: _dayKeys[dayIndex],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text(
                              DateFormat('EEEE, d MMM').format(date),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                          ),
                          if (daySchedules.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16, left: 4),
                              child: Text("Tidak ada jadwal tersedia", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            )
                          else
                            ...daySchedules.map((sch) => _buildScheduleCard(sch)),
                        ],
                      );
                    }),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel sch) {
    final isFull = sch.isFull;

    return GestureDetector(
      onTap: isFull
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleDetailPage(
                  schedule: sch,
                  branchId: widget.branchId,
                  branchName: widget.branchName,
                  branchAddress: widget.branchAddress,
                ),
              ),
            ).then((_) => _fetchSchedules()); // Refresh setelah booking
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Waktu & durasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.access_time_filled, color: Color(0xFF4285F4), size: 18),
                    const SizedBox(width: 6),
                    Text("${sch.startTime} - ${sch.endTime} ${sch.timezone}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                    child: Text("${sch.durationMinutes} menit",
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 0.6),

              // Nama service
              Text("${sch.serviceType['name']} - ${sch.serviceName['name']}",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),

              // Staff
              if (sch.staffs.isNotEmpty)
                Row(children: [
                  const Icon(Icons.person_outline, color: Colors.grey, size: 16),
                  const SizedBox(width: 6),
                  Text(sch.staffs.map((s) => s['name']).join(', '),
                    style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ]),
              const SizedBox(height: 6),

              // Room
              Row(children: [
                const Icon(Icons.meeting_room_outlined, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Text("${sch.roomType['name']} - ${sch.roomName['name']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ]),
              const SizedBox(height: 6),

              // Slot
              Row(children: [
                Icon(Icons.people_outline, color: isFull ? Colors.red : Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  "${sch.availableSlots}/${sch.totalSlots} slot tersedia",
                  style: TextStyle(color: isFull ? Colors.red : Colors.green, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ]),

              const SizedBox(height: 14),

              // Book button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: isFull ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScheduleDetailPage(
                          schedule: sch,
                          branchId: widget.branchId,
                          branchName: widget.branchName,
                          branchAddress: widget.branchAddress,
                        ),
                      ),
                    ).then((_) => _fetchSchedules());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFull ? Colors.grey[400] : const Color(0xFF4285F4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isFull ? "Full" : "Book Now",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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