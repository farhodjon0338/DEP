import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText(
                      'Orenda',
                      textStyle: GoogleFonts.alata(
                        textStyle: TextStyle(
                          color: Color.fromARGB(255, 0, 2, 137),
                          letterSpacing: 2,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  isRepeatingAnimation: true,
                  totalRepeatCount: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
