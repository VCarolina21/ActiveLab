import 'package:flutter/material.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  static final List<Map<String, String>> notifications = <Map<String, String>>[];

  static void addNotification(String title, String date, String month, String year, String time, {String status = "Pending"}) {
    notifications.add({
      "title": title,
      "date": date,
      "month": month,
      "year": year,
      "time": time,
      "status": status,
    });
  }

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: NotifPage.notifications.isEmpty
                    ? const Center(
                        child: Text(
                          "No notifications yet",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: NotifPage.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = NotifPage.notifications[index];
                          bool isCanceled = notif["status"] == "Canceled";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isCanceled ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD),
                                  child: Icon(
                                    isCanceled ? Icons.cancel_rounded : Icons.calendar_today,
                                    color: isCanceled ? Colors.redAccent : const Color(0xFF4285F4),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif["title"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      if (isCanceled) ...[
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                            children: [
                                              const TextSpan(
                                                text: "Canceled",
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: " for ${notif["date"] ?? ""} ${notif["month"] ?? ""} ${notif["year"] ?? ""} at ${notif["time"] ?? ""}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          "Booked for ${notif["date"] ?? ""} ${notif["month"] ?? ""} ${notif["year"] ?? ""} at ${notif["time"] ?? ""}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}