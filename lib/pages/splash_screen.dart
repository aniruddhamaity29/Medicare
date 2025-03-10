import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medicare/pages/bottomnav.dart';
import 'package:medicare/pages/onboarding_screen.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/theme_change_provider.dart';
import 'package:medicare/utils/values.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences sp;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    navigateToLogin();
  }

  navigateToLogin() async {
    sp = await SharedPreferences.getInstance();
    String email = sp.getString('email') ?? '';
    bool night = sp.getBool("night") ?? false;
    final ThemeChangeProvider _changetheme =
        Provider.of<ThemeChangeProvider>(context, listen: false);
    if (night) {
      _changetheme.setThemeMode(ThemeMode.dark);
    } else {
      _changetheme.setThemeMode(ThemeMode.light);
    }
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (x == 1) {
        timer.cancel();
        await Future.delayed(Duration(seconds: 1), () {
          if (email.isEmpty) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OnboardingScreen()),
            );
          } else {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Nav()),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [pColor.withOpacity(0.8), pColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Image.asset('assets/images/doctors.png'),
            ),
            SizedBox(height: 10),
            Text(
              'Medicare',
              style: TextStyle(
                color: wColor,
                fontSize: 35,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                wordSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
