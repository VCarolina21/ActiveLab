import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  final String serviceName;

  const SchedulePage({super.key, required this.serviceName});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // PERBAIKAN: Mengubah nama layanan menjadi Service Name A, B, C, D
  final List<String> _services = [
    "Service Name A",
    "Service Name B",
    "Service Name C",
    "Service Name D",
  ];
  late String _selectedService;

  int _selectedDayIndex = 0;
  final ScrollController _mainScrollController = ScrollController();

  // Menyiapkan 7 GlobalKey untuk fitur auto-scroll per hari
  final List<GlobalKey> _dayKeys = List.generate(7, (index) => GlobalKey());
  final List<Map<String, dynamic>> _weeklySchedule = [];

  @override
  void initState() {
    super.initState();
    // Menyesuaikan service default yang dipilih dari halaman sebelumnya jika ada cocokan
    _selectedService = _services.contains(widget.serviceName)
        ? widget.serviceName
        : _services.first;

    _generateDummyData();
  }

  // Membuat ulang data dummy setiap kali service atau hari diubah
  void _generateDummyData() {
    _weeklySchedule.clear();
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      _weeklySchedule.add({
        "date": targetDate,
        "classes": [
          {
            "time": "08:00 AM",
            "duration": "50 mins",
            "title": "Basic $_selectedService Session",
            "staff": "Dr. Aris Setiawan",
            "location": "Fite Studio - Central Hub",
          },
          {
            "time": "11:30 AM",
            "duration": "60 mins",
            "title": "Intensive $_selectedService Care",
            "staff": "Coach Linda Utama",
            "location": "Fite Studio - Executive Room",
          },
          {
            "time": "04:00 PM",
            "duration": "55 mins",
            "title": "Advance $_selectedService Treatment",
            "staff": "Coach Intan Permata",
            "location": "Fite Indonesia - Bogor Studio",
          },
        ],
      });
    }
  }

  // Fungsi auto-scroll menuju target hari
  void _scrollToDay(int index) {
    setState(() {
      _selectedDayIndex = index;
    });

    final targetContext = _dayKeys[index].currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Book a $_selectedService",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. SELECTION BAR SERVICE NAME (BAGIAN ATAS) ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _services.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final service = _services[index];
                final isCurrentService = _selectedService == service;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedService = service;
                      _generateDummyData(); // Refresh isi data dummy sesuai nama service baru
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 2,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrentService
                          ? const Color(0xFF4285F4).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isCurrentService
                            ? const Color(0xFF4285F4)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      service,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrentService
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isCurrentService
                            ? const Color(0xFF4285F4)
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Divider tipis pembatas
          Container(height: 1, color: const Color(0xFFF1F5F9)),

          // --- 2. HORIZONTAL CALENDAR (7 HARI KE DEPAN) ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final dateItem = _weeklySchedule[index]["date"] as DateTime;
                final isSelected = _selectedDayIndex == index;

                final dayName = DateFormat('E').format(dateItem);
                final dayNumber = DateFormat('d').format(dateItem);

                return GestureDetector(
                  onTap: () => _scrollToDay(index),
                  child: Container(
                    width: 58,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4285F4)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF4285F4,
                                ).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayNumber,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // --- 3. LIST JADWAL UTAMA ---
          Expanded(
            child: SingleChildScrollView(
              controller: _mainScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: List.generate(7, (dayIndex) {
                  final dayData = _weeklySchedule[dayIndex];
                  final DateTime date = dayData["date"];
                  final List<Map<String, String>> classes =
                      List<Map<String, String>>.from(dayData["classes"]);

                  return Column(
                    key: _dayKeys[dayIndex],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 4,
                        ),
                        child: Text(
                          DateFormat('EEEE, d MMM').format(date),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),

                      ...classes.map(
                        (cls) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_filled,
                                          color: Color(0xFF4285F4),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          cls["time"]!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        cls["duration"]!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 0.6),
                                Text(
                                  cls["title"]!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cls["staff"]!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        cls["location"]!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Aksi tombol book now
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4285F4),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Book Now",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
