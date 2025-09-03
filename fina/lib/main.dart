import 'package:flutter/material.dart';
import 'screens/welcome/welcome_screen.dart';

void main() => runApp(const TaxiResumeApp());

class TaxiResumeApp extends StatelessWidget {
  const TaxiResumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
