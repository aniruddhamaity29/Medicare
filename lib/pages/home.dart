import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:medicare/pages/appoint_screen.dart';
import 'package:medicare/pages/doctorslistscreen.dart';
import 'package:medicare/pages/historyscreen.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/loading.dart';
import 'package:medicare/utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String username = "";
  String email = "";
  late SharedPreferences sp;
  Future getData() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      username = sp.getString('username') ?? '';
      email = sp.getString('email') ?? '';
    });
  }

  List doctors = [];
  List filteredDoctors = [];
  bool isLoading = true;
  String showImage = "";

  @override
  void initState() {
    getData().whenComplete(() => getUserImage(email));
    fetchDoctors();
    searchController.addListener(filterDoctors);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDoctors() async {
    try {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      final response = await http.get(Uri.parse("${mainurl}get_doctors.php"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['doctors'] != null) {
          setState(() {
            doctors = data['doctors'] ?? [];
            filteredDoctors = doctors;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print("No doctors found or invalid response format.");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to fetch doctors. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching doctors: $error");
    }
  }

  Future filterDoctors() async {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        final doctorName = doctor['name'].toString().toLowerCase();
        final doctorSpecialization =
            doctor['specialization'].toString().toLowerCase();
        return doctorName.contains(query) ||
            doctorSpecialization.contains(query);
      }).toList();
    });
  }

  Widget buildDoctorCard(dynamic doctor) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.width10, vertical: Dimensions.width10),
      width: Dimensions.width150,
      decoration: BoxDecoration(
        color: wColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointScreen(
                doctor: doctor,
              ),
            ),
          ).then((_) {
            FocusScope.of(context).unfocus();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                "$image_url${doctor['image'].toString()}",
                height: Dimensions.height120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width10,
                vertical: Dimensions.height10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? '',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.bold,
                      color: bColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    doctor['specialization'] ?? '',
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: bColor.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Row(
                    children: [
                      // Render stars dynamically
                      Row(
                        children: List.generate(
                          doctor['rating']?.toInt() ?? 0, // Number of stars
                          (index) => Icon(
                            Icons.star,
                            color: Colors.orangeAccent,
                            size: Dimensions.icon18,
                          ),
                        ),
                      ),
                      if (doctor['rating'] != null &&
                          doctor['rating'] - doctor['rating'].toInt() > 0)
                        Icon(
                          Icons.star_half,
                          color: Colors.orangeAccent,
                          size: Dimensions.icon18,
                        ),
                      SizedBox(width: Dimensions.width6),
                      Text(
                        doctor['rating'].toString(),
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.bold,
                          color: bColor.withOpacity(0.8),
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
    );
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
        print(jsondata['msg']);
      }
    } catch (e) {
      print(e);
    }
  }

  List catNames = [
    "Dental",
    "Heart",
    "Eye",
    "Ear",
    "Brain",
  ];
  List<Icon> catIcons = [
    Icon(MdiIcons.toothOutline, color: pColor, size: Dimensions.icon30),
    Icon(MdiIcons.heartPlus, color: pColor, size: Dimensions.icon30),
    Icon(MdiIcons.eye, color: pColor, size: Dimensions.icon30),
    Icon(MdiIcons.earHearing, color: pColor, size: Dimensions.icon30),
    Icon(MdiIcons.brain, color: pColor, size: Dimensions.icon30),
  ];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    pColor.withOpacity(0.8),
                    pColor,
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Skeletonizer(
                enabled: isLoading,
                child: Padding(
                  padding: EdgeInsets.only(top: Dimensions.height30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: showImage.isNotEmpty
                                      ? NetworkImage(showImage)
                                      : const AssetImage(
                                              'assets/images/profile.png')
                                          as ImageProvider,
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Navigate to Upcomingschedule without appointment details
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Historyscreen())).then((_) {
                                      // Unfocus all fields after coming back
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    });
                                  },
                                  icon: Icon(Icons.history_rounded),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.height15),
                            Text(
                              "Hi, $username",
                              style: TextStyle(
                                color: wColor,
                                fontWeight: FontWeight.normal,
                                fontSize: Dimensions.font16,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              'Your Health is Our\nFirst Priority',
                              style: TextStyle(
                                color: wColor,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.font20,
                                fontFamily: 'Courier New',
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: Dimensions.height15,
                                  bottom: Dimensions.height20),
                              width: MediaQuery.of(context).size.width,
                              height: Dimensions.height50,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    spreadRadius: 3,
                                  )
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search here...',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      filterDoctors().then((_) {
                                        FocusScope.of(context).unfocus();
                                      });
                                    },
                                    style: ButtonStyle(
                                      alignment: Alignment.centerLeft,
                                      iconSize: WidgetStatePropertyAll(
                                          Dimensions.icon35),
                                    ),
                                    icon: const Icon(Icons.search),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  // fillColor: Colors.red,
                                  filled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: Dimensions.width15),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: Dimensions.font20,
                            fontWeight: FontWeight.w500,
                            // color: bColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.height15),
                      SizedBox(
                        height: Dimensions.height100,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: catNames.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: Dimensions.height5,
                                    horizontal: Dimensions.width15,
                                  ),
                                  height: Dimensions.height60,
                                  width: Dimensions.width60,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF2f8ff),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      // Navigate to DoctorsListScreen with selected category
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DoctorsList(
                                            category: catNames[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Center(
                                      child: catIcons[index],
                                    ),
                                  ),
                                ),
                                SizedBox(height: Dimensions.height5),
                                Text(
                                  catNames[index],
                                  style: TextStyle(
                                    fontSize: Dimensions.font16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: Dimensions.height30),
                      Padding(
                        padding: EdgeInsets.only(left: Dimensions.width15),
                        child: Text(
                          "Recommended Doctors",
                          style: TextStyle(
                            fontSize: Dimensions.font20,
                            fontWeight: FontWeight.w500,
                            // color: bColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.height5),
                      isLoading
                          ? const Center(child: LoadingDialog())
                          : SizedBox(
                              height: Dimensions.height230 * 1.05,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.width10),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = filteredDoctors[index];
                                  return buildDoctorCard(doctor);
                                },
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
}
