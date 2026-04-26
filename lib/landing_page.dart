import 'package:flutter/material.dart';
import 'login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sliderWidth = screenWidth * 0.85; 
    double buttonWidth = 110.0;

    Color topColor = Color.lerp(const Color(0xFF2E5BCC), const Color(0xFF63B8FF), _dragPosition)!;
    Color bottomColor = Color.lerp(const Color(0xFF4285F4), const Color(0xFF90CAF9), _dragPosition)!;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 5),
              
              _buildLargeText("Seamless", isOutline: false),
              _buildLargeText("access to", isOutline: true),
              _buildLargeText("your", isOutline: false),
              _buildLargeText("wellness", isOutline: true),
              
              const Spacer(flex: 2),

              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 60),
                  width: sliderWidth,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: Icon(Icons.double_arrow_rounded, color: Colors.white, size: 24),
                        ),
                      ),

                      Positioned(
                        left: _dragPosition * (sliderWidth - buttonWidth),
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _dragPosition += details.delta.dx / (sliderWidth - buttonWidth);
                              _dragPosition = _dragPosition.clamp(0.0, 1.0);
                            });
                          },
                          onHorizontalDragEnd: (details) {
                            if (_dragPosition > 0.8) {
                              setState(() => _dragPosition = 1.0);
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            } else {
                              setState(() => _dragPosition = 0.0);
                            }
                          },
                          child: Container(
                            width: buttonWidth,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "Let's Go",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildLargeText(String text, {required bool isOutline}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 65,
        fontWeight: FontWeight.bold,
        height: 1.05,
        letterSpacing: 1.2,
        color: isOutline ? null : Colors.white,
        foreground: isOutline 
          ? (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = Colors.white.withValues(alpha: 0.9))
          : null,
      ),
    );
  }
}