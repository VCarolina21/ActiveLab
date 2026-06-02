import 'package:flutter/material.dart';
import 'notif_page.dart';

class WeeklyTargetPage extends StatefulWidget {
  const WeeklyTargetPage({super.key});

  @override
  State<WeeklyTargetPage> createState() => _WeeklyTargetPageState();
}

class _WeeklyTargetPageState extends State<WeeklyTargetPage> {
  DateTime _currentLiveDateTime = DateTime.now();
  late DateTime _focusedDateTime;

  final List<String> _monthsIndoNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final List<String> _weekDaysHeader = ["S", "M", "T", "W", "T", "F", "S"];

  @override
  void initState() {
    super.initState();
    _currentLiveDateTime = DateTime.now();
    _focusedDateTime = DateTime(_currentLiveDateTime.year, _currentLiveDateTime.month, 1);
  }

  void _moveToPreviousMonth() {
    setState(() {
      _focusedDateTime = DateTime(_focusedDateTime.year, _focusedDateTime.month - 1, 1);
    });
  }

  void _moveToNextMonth() {
    setState(() {
      _focusedDateTime = DateTime(_focusedDateTime.year, _focusedDateTime.month + 1, 1);
    });
  }

  int _getTotalDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getWeekdayOffset(int year, int month) {
    int weekday = DateTime(year, month, 1).weekday;
    if (weekday == 7) {
      return 0;
    }
    return weekday;
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = _getTotalDaysInMonth(_focusedDateTime.year, _focusedDateTime.month);
    int startOffset = _getWeekdayOffset(_focusedDateTime.year, _focusedDateTime.month);

    final List<Map<String, dynamic>> contextFilteredBookings = [];
    final Set<int> activeHighlightedDays = {};

    final List<Map<String, dynamic>> rawParsedItems = [];

    for (int i = 0; i < NotifPage.notifications.length; i++) {
      final item = NotifPage.notifications[i];
      String rawDate = item["date"] ?? "";
      String rawMonth = item["month"] ?? "";
      String rawYear = item["year"] ?? "";
      String rawStatus = item["status"] ?? "Pending";
      String rawTitle = item["title"] ?? "";
      String rawTime = item["time"] ?? "";

      int? parsedDay = int.tryParse(rawDate);
      int? parsedYear = int.tryParse(rawYear);
      
      int parsedMonthIndex = 5;
      String lowerMonth = rawMonth.toLowerCase();
      
      if (lowerMonth.contains("jan")) {
        parsedMonthIndex = 1;
      } else if (lowerMonth.contains("feb")) {
        parsedMonthIndex = 2;
      } else if (lowerMonth.contains("mar")) {
        parsedMonthIndex = 3;
      } else if (lowerMonth.contains("apr")) {
        parsedMonthIndex = 4;
      } else if (lowerMonth.contains("may") || lowerMonth.contains("mei")) {
        parsedMonthIndex = 5;
      } else if (lowerMonth.contains("jun")) {
        parsedMonthIndex = 6;
      } else if (lowerMonth.contains("jul")) {
        parsedMonthIndex = 7;
      } else if (lowerMonth.contains("aug") || lowerMonth.contains("agu")) {
        parsedMonthIndex = 8;
      } else if (lowerMonth.contains("sep")) {
        parsedMonthIndex = 9;
      } else if (lowerMonth.contains("oct") || lowerMonth.contains("okt")) {
        parsedMonthIndex = 10;
      } else if (lowerMonth.contains("nov")) {
        parsedMonthIndex = 11;
      } else if (lowerMonth.contains("dec") || lowerMonth.contains("des")) {
        parsedMonthIndex = 12;
      }

      if (parsedDay != null && parsedYear != null) {
        if (parsedYear == _focusedDateTime.year && parsedMonthIndex == _focusedDateTime.month) {
          
          String absoluteDisplayStatus = "Pending";
          if (rawStatus == "Canceled" || rawStatus == "Cancelled") {
            absoluteDisplayStatus = "Canceled";
          } else {
            DateTime itemTargetDate = DateTime(parsedYear, parsedMonthIndex, parsedDay);
            DateTime checkLiveDayOnly = DateTime(_currentLiveDateTime.year, _currentLiveDateTime.month, _currentLiveDateTime.day);
            if (itemTargetDate.isBefore(checkLiveDayOnly)) {
              absoluteDisplayStatus = "Completed";
            } else {
              absoluteDisplayStatus = "Pending";
            }
          }

          rawParsedItems.add({
            "day": parsedDay,
            "title": rawTitle,
            "time": rawTime,
            "status": absoluteDisplayStatus,
            "data": item,
          });
        }
      }
    }

    final Map<String, Map<String, dynamic>> uniqueBookingMap = {};
    for (var parsedItem in rawParsedItems) {
      String uniqueKey = "${parsedItem["day"]}_${parsedItem["title"]}_${parsedItem["time"]}";
      
      if (!uniqueBookingMap.containsKey(uniqueKey)) {
        uniqueBookingMap[uniqueKey] = parsedItem;
      } else {
        if (parsedItem["status"] == "Canceled") {
          uniqueBookingMap[uniqueKey] = parsedItem;
        }
      }
    }

    uniqueBookingMap.forEach((key, value) {
      contextFilteredBookings.add(value);
      if (value["status"] != "Canceled") {
        activeHighlightedDays.add(value["day"] as int);
      }
    });

    contextFilteredBookings.sort((a, b) => (a["day"] as int).compareTo(b["day"] as int));

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12, width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "WEEKLY TARGET",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: _moveToPreviousMonth,
                                  child: const Icon(Icons.arrow_left, color: Colors.black, size: 32),
                                ),
                                Text(
                                  "${_monthsIndoNames[_focusedDateTime.month - 1]} ${_focusedDateTime.year}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _moveToNextMonth,
                                  child: const Icon(Icons.arrow_right, color: Colors.black, size: 32),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _weekDaysHeader.map((day) {
                                return SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: totalDays + startOffset,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemBuilder: (context, index) {
                                if (index < startOffset) {
                                  return const SizedBox.shrink();
                                }

                                int currentGridDay = index - startOffset + 1;
                                bool hasBookingOnDay = activeHighlightedDays.contains(currentGridDay);

                                DateTime cellDate = DateTime(_focusedDateTime.year, _focusedDateTime.month, currentGridDay);
                                DateTime realTodayDate = DateTime(_currentLiveDateTime.year, _currentLiveDateTime.month, _currentLiveDateTime.day);

                                bool isPastDay = cellDate.isBefore(realTodayDate);
                                bool isCurrentToday = cellDate.isAtSameMomentAs(realTodayDate);

                                Color dayTextColor = Colors.black;
                                Color circleBackgroundColor = Colors.transparent;

                                if (isPastDay) {
                                  dayTextColor = Colors.black38;
                                }

                                if (hasBookingOnDay) {
                                  circleBackgroundColor = const Color(0xFF0D47A1);
                                  dayTextColor = Colors.white;
                                } else if (isCurrentToday) {
                                  circleBackgroundColor = Colors.black12;
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: circleBackgroundColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "$currentGridDay",
                                      style: TextStyle(
                                        fontWeight: hasBookingOnDay || isCurrentToday ? FontWeight.bold : FontWeight.normal,
                                        color: dayTextColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "WEEKLY SUMMARY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (contextFilteredBookings.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "No activities or sessions booked in this month.",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: contextFilteredBookings.length,
                          itemBuilder: (context, index) {
                            final currentItem = contextFilteredBookings[index];
                            final Map<String, String> rawMetadata = currentItem["data"] as Map<String, String>;
                            
                            String elementTitle = currentItem["title"] as String;
                            String dynamicStatus = currentItem["status"] as String;

                            String customDate = rawMetadata["date"] ?? "";
                            String customMonth = rawMetadata["month"] ?? "";
                            String customTime = rawMetadata["time"] ?? "";

                            String resolvedAsset = "assets/gymuntar.jpg";
                            String lowercaseTitle = elementTitle.toLowerCase();
                            if (lowercaseTitle.contains("yoga")) {
                              resolvedAsset = "assets/yoga.JPG";
                            } else if (lowercaseTitle.contains("hiit")) {
                              resolvedAsset = "assets/hiit.JPG";
                            } else if (lowercaseTitle.contains("pilates")) {
                              resolvedAsset = "assets/pilates.JPG";
                            } else if (lowercaseTitle.contains("massage")) {
                              resolvedAsset = "assets/massage.JPG";
                            } else if (lowercaseTitle.contains("spa")) {
                              resolvedAsset = "assets/spa.JPG";
                            }

                            Color edgeBorderColor = const Color(0xFFFFB300);
                            Color textFillColor = const Color(0xFFFFB300);

                            if (dynamicStatus == "Completed") {
                              edgeBorderColor = const Color(0xFF4CAF50);
                              textFillColor = const Color(0xFF4CAF50);
                            } else if (dynamicStatus == "Canceled") {
                              edgeBorderColor = Colors.redAccent;
                              textFillColor = Colors.redAccent;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: Image.asset(
                                        resolvedAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "$customDate $customMonth, $customTime",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          elementTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Row(
                                          children: [
                                            Icon(Icons.location_on, size: 12, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              "Jakarta",
                                              style: TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 14),
                                          SizedBox(width: 2),
                                          Text(
                                            "4,9",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: edgeBorderColor, width: 1.2),
                                        ),
                                        child: Text(
                                          dynamicStatus,
                                          style: TextStyle(
                                            color: textFillColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 30),
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