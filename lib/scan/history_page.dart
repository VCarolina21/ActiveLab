import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final List<Map<String, dynamic>> _weeklySummaryData = const [
    {
      "day": "Mon",
      "date": "18 May 2026",
      "title": "CoreFit Gym - Weightlifting Area",
      "duration": "60 Mins",
      "status": "Completed",
      "icon": Icons.fitness_center,
      "color": Colors.blue
    },
    {
      "day": "Tue",
      "date": "19 May 2026",
      "title": "FlexFit Yoga - Morning Flow",
      "duration": "45 Mins",
      "status": "Completed",
      "icon": Icons.self_improvement,
      "color": Colors.green
    },
    {
      "day": "Wed",
      "date": "20 May 2026",
      "title": "CoreFit Pilates - Private Session",
      "duration": "50 Mins",
      "status": "Completed",
      "icon": Icons.accessibility_new,
      "color": Colors.purple
    },
    {
      "day": "Thu",
      "date": "21 May 2026",
      "title": "MoveFit HIIT - Cardio Blast",
      "duration": "40 Mins",
      "status": "Completed",
      "icon": Icons.bolt,
      "color": Colors.orange
    },
    {
      "day": "Fri",
      "date": "22 May 2026",
      "title": "ActiveFit Physiotherapy - Back Therapy",
      "duration": "60 Mins",
      "status": "Completed",
      "icon": Icons.healing,
      "color": Colors.teal
    },
    {
      "day": "Sat",
      "date": "23 May 2026",
      "title": "CoreFit Spa - Full Body Massage",
      "duration": "90 Mins",
      "status": "Completed",
      "icon": Icons.spa,
      "color": Colors.pink
    },
    {
      "day": "Sun",
      "date": "24 May 2026",
      "title": "Rest Day - Active Recovery",
      "duration": "0 Mins",
      "status": "Completed",
      "icon": Icons.king_bed,
      "color": Colors.grey
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weekly History Summary",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF42A5F5),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
          itemCount: _weeklySummaryData.length,
          itemBuilder: (context, index) {
            final item = _weeklySummaryData[index];
            final Color itemColor = item["color"] as Color;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: itemColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item["icon"] as IconData,
                    color: itemColor,
                    size: 26,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${item["day"]}, ${item["date"]}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item["status"].toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"].toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            item["duration"].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}