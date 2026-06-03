import 'package:flutter/material.dart';
import 'training_timer_page.dart';

class DayTrainingPage extends StatelessWidget {
  const DayTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> exercises = [
      {
        "title": "Knee push up",
        "duration": "00:30",
        "image": "assets/kneepushup.jpeg"
      },
      {
        "title": "Push up",
        "duration": "00:30",
        "image": "assets/pushup.png"
      },
      {
        "title": "Wide Push Up",
        "duration": "00:30",
        "image": "assets/widepushup.jpeg"
      },
      {
        "title": "Triangle Push Up",
        "duration": "00:30",
        "image": "assets/trianglepushup.png"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/otot.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
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
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  transform: Matrix4.translationValues(0, -30, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DAY 4",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildInfoCard("2 Minute", "Training"),
                            const SizedBox(width: 15),
                            _buildInfoCard("4", "Training"),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildExerciseTile(exercises[0]["title"]!, exercises[0]["duration"]!, exercises[0]["image"]!),
                        const Divider(height: 30),
                        _buildExerciseTile(exercises[1]["title"]!, exercises[1]["duration"]!, exercises[1]["image"]!),
                        const Divider(height: 30),
                        _buildExerciseTile(exercises[2]["title"]!, exercises[2]["duration"]!, exercises[2]["image"]!),
                        const Divider(height: 30),
                        _buildExerciseTile(exercises[3]["title"]!, exercises[3]["duration"]!, exercises[3]["image"]!),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainingTimerPage(exercises: exercises),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "START",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(String title, String duration, String imagePath) {
    return Row(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              duration,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}