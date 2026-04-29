import 'package:flutter/material.dart';
import 'dart:ui';

import 'register_page.dart';
import 'real_login_page.dart';

class SignPage extends StatefulWidget {
  const SignPage({super.key});

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sliderWidth = screenWidth * 0.55; 
    double thumbWidth = 100.0; 

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/sign.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[900],
                child: const Center(child: Text("Image not found", style: TextStyle(color: Colors.white))),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.45,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3), 
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome To\nActiveLab",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Book, train, and recover seamlessly. Your integrated fitness and wellness portal.",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const Spacer(),

                        Row(
                          children: [
                            Container(
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
                                      padding: EdgeInsets.only(right: 15),
                                      child: Icon(
                                        Icons.keyboard_double_arrow_right, 
                                        color: Colors.white, 
                                        size: 24
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: _dragPosition * (sliderWidth - thumbWidth - 10) + 5,
                                    top: 5,
                                    child: GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        setState(() {
                                          _dragPosition += details.delta.dx / (sliderWidth - thumbWidth);
                                          _dragPosition = _dragPosition.clamp(0.0, 1.0);
                                        });
                                      },
                                      onHorizontalDragEnd: (details) {
                                        if (_dragPosition > 0.8) {
                                          setState(() => _dragPosition = 1.0);
                                          
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                                          );
                                        } else {
                                          setState(() => _dragPosition = 0.0);
                                        }
                                      },
                                      child: Container(
                                        width: thumbWidth,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Join Now",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 10),

                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RealLoginPage()),
                                  );
                                },
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Log in",
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}