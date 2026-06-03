import 'package:flutter/material.dart';

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allPlaces = [
    {
      "name": "CoreFit Gym",
      "category": "gym",
      "location": "Jakarta Selatan",
      "rating": "4.9",
      "quota": "12/50",
      "image": "assets/gymuntar.jpg"
    },
    {
      "name": "ActiveFit Gym",
      "category": "gym",
      "location": "Jakarta Utara",
      "rating": "4.7",
      "quota": "18/50",
      "image": "assets/gymuntar.jpg"
    },
    {
      "name": "FlexFit Gym",
      "category": "gym",
      "location": "Jakarta Pusat",
      "rating": "4.6",
      "quota": "25/50",
      "image": "assets/gymuntar.jpg"
    },
    {
      "name": "MoveFit Gym",
      "category": "gym",
      "location": "Jakarta Barat",
      "rating": "4.8",
      "quota": "15/50",
      "image": "assets/gymuntar.jpg"
    },
    {
      "name": "MoveFit Pilates",
      "category": "pilates",
      "location": "Jakarta Barat",
      "rating": "4.8",
      "quota": "5/50",
      "image": "assets/pilates.JPG"
    },
    {
      "name": "CoreFit Pilates",
      "category": "pilates",
      "location": "Jakarta Selatan",
      "rating": "4.7",
      "quota": "8/50",
      "image": "assets/pilates.JPG"
    },
    {
      "name": "ActiveFit Pilates",
      "category": "pilates",
      "location": "Jakarta Utara",
      "rating": "4.5",
      "quota": "12/50",
      "image": "assets/pilates.JPG"
    },
    {
      "name": "FlexFit Pilates",
      "category": "pilates",
      "location": "Jakarta Pusat",
      "rating": "4.6",
      "quota": "10/50",
      "image": "assets/pilates.JPG"
    },
    {
      "name": "CoreFit HIIT",
      "category": "hiit",
      "location": "Jakarta Selatan",
      "rating": "4.9",
      "quota": "8/50",
      "image": "assets/hiit.JPG"
    },
    {
      "name": "ActiveFit HIIT",
      "category": "hiit",
      "location": "Jakarta Utara",
      "rating": "4.7",
      "quota": "14/50",
      "image": "assets/hiit.JPG"
    },
    {
      "name": "FlexFit HIIT",
      "category": "hiit",
      "location": "Jakarta Pusat",
      "rating": "4.6",
      "quota": "20/50",
      "image": "assets/hiit.JPG"
    },
    {
      "name": "MoveFit HIIT",
      "category": "hiit",
      "location": "Jakarta Barat",
      "rating": "4.8",
      "quota": "11/50",
      "image": "assets/hiit.JPG"
    },
    {
      "name": "CoreFit Spa",
      "category": "spa",
      "location": "Jakarta Selatan",
      "rating": "3.8",
      "quota": "42/50",
      "image": "assets/spa.JPG"
    },
    {
      "name": "ActiveFit Spa",
      "category": "spa",
      "location": "Jakarta Utara",
      "rating": "4.2",
      "quota": "30/50",
      "image": "assets/spa.JPG"
    },
    {
      "name": "FlexFit Spa",
      "category": "spa",
      "location": "Jakarta Pusat",
      "rating": "4.0",
      "quota": "15/50",
      "image": "assets/spa.JPG"
    },
    {
      "name": "MoveFit Spa",
      "category": "spa",
      "location": "Jakarta Barat",
      "rating": "4.4",
      "quota": "22/50",
      "image": "assets/spa.JPG"
    },
    {
      "name": "CoreFit Massage",
      "category": "massage",
      "location": "Jakarta Selatan",
      "rating": "3.7",
      "quota": "34/50",
      "image": "assets/massage.JPG"
    },
    {
      "name": "ActiveFit Massage",
      "category": "massage",
      "location": "Jakarta Utara",
      "rating": "4.1",
      "quota": "28/50",
      "image": "assets/massage.JPG"
    },
    {
      "name": "FlexFit Massage",
      "category": "massage",
      "location": "Jakarta Pusat",
      "rating": "4.3",
      "quota": "19/50",
      "image": "assets/massage.JPG"
    },
    {
      "name": "MoveFit Massage",
      "category": "massage",
      "location": "Jakarta Barat",
      "rating": "4.0",
      "quota": "31/50",
      "image": "assets/massage.JPG"
    },
    {
      "name": "ActiveFit Physiotherapy",
      "category": "physiotherapy",
      "location": "Jakarta Utara",
      "rating": "4.9",
      "quota": "20/50",
      "image": "assets/fisioterapi.JPG"
    },
    {
      "name": "CoreFit Physiotherapy",
      "category": "physiotherapy",
      "location": "Jakarta Selatan",
      "rating": "4.8",
      "quota": "14/50",
      "image": "assets/fisioterapi.JPG"
    },
    {
      "name": "FlexFit Physiotherapy",
      "category": "physiotherapy",
      "location": "Jakarta Pusat",
      "rating": "4.7",
      "quota": "22/50",
      "image": "assets/fisioterapi.JPG"
    },
    {
      "name": "MoveFit Physiotherapy",
      "category": "physiotherapy",
      "location": "Jakarta Barat",
      "rating": "4.8",
      "quota": "11/50",
      "image": "assets/fisioterapi.JPG"
    },
    {
      "name": "FlexFit Yoga",
      "category": "yoga",
      "location": "Jakarta Pusat",
      "rating": "4.7",
      "quota": "8/50",
      "image": "assets/yoga.JPG"
    },
    {
      "name": "CoreFit Yoga",
      "category": "yoga",
      "location": "Jakarta Selatan",
      "rating": "4.6",
      "quota": "15/50",
      "image": "assets/yoga.JPG"
    },
    {
      "name": "ActiveFit Yoga",
      "category": "yoga",
      "location": "Jakarta Utara",
      "rating": "4.5",
      "quota": "19/50",
      "image": "assets/yoga.JPG"
    },
    {
      "name": "MoveFit Yoga",
      "category": "yoga",
      "location": "Jakarta Barat",
      "rating": "4.8",
      "quota": "12/50",
      "image": "assets/yoga.JPG"
    }
  ];

  List<Map<String, String>> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _allPlaces.shuffle();
    _filteredPlaces = List.from(_allPlaces);
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlaces = List.from(_allPlaces);
      } else {
        _filteredPlaces = _allPlaces.where((place) {
          final nameLower = place["name"]!.toLowerCase();
          final categoryLower = place["category"]!.toLowerCase();
          final searchLower = query.toLowerCase();
          return nameLower.contains(searchLower) || categoryLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: _filterSearch,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintText: "Search gym, pilates, hiit, spa...",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _filteredPlaces.isEmpty
                    ? const Center(
                        child: Text(
                          "No places found.",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _filteredPlaces[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    place["image"]!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place["name"]!,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            place["location"]!,
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        place["quota"]!,
                                        style: const TextStyle(
                                          color: Color(0xFF42A5F5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          place["rating"]!,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
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