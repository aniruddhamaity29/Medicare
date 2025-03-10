import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare/pages/historyscreen.dart';

class Approvedscreen extends StatefulWidget {
  const Approvedscreen({
    super.key,
  });

  @override
  State<Approvedscreen> createState() => _ApprovedscreenState();
}

class _ApprovedscreenState extends State<Approvedscreen> {
  @override
  void initState() {
    super.initState();

    // Wait 2 seconds and navigate to History Screen with updated ride history
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Historyscreen(),
        ),
      ).then((_) {
        FocusManager.instance.primaryFocus?.unfocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animation/confirm1.json'),
            SizedBox(height: 10),
            Text(
              'Your Appointment is Booked!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
