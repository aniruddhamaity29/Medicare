import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicare/pages/home.dart';
import 'package:medicare/pages/settings.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int selectedIndex = 0;
  Uint8List? profileImage;
  String showImage = "";
  late SharedPreferences sp;
  String email = "";
  String userId = '';

  @override
  void initState() {
    super.initState();
    getData().whenComplete(() {
      getUserImage(email);
    });
  }

  Future<void> getData() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      email = sp.getString('email') ?? '';
      userId = sp.getString('user_id') ?? '';
    });
  }

  Future<void> getUserImage(String email) async {
    Map data = {'email': email};

    try {
      var response = await http.post(
        Uri.parse("${mainurl}get_user_image.php"),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        setState(() {
          showImage = jsondata['image'].toString();
        });
      } else {
        setState(() {
          showImage = "";
        });
        Fluttertoast.showToast(msg: jsondata['msg']);
      }
    } catch (e) {
      print(e);
    }
  }

  final screens = [
    HomeScreen(),
    Settings(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: wColor,
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: wColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: pColor,
        unselectedItemColor: b26,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: Dimensions.font15,
        ),
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
