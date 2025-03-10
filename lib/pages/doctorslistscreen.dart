import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medicare/pages/category_screen.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/loading.dart';
import 'package:medicare/utils/url.dart';
import 'package:http/http.dart' as http;

class DoctorsList extends StatefulWidget {
  final String category;

  DoctorsList({required this.category});

  @override
  State<DoctorsList> createState() => _DoctorsListState();
}

class _DoctorsListState extends State<DoctorsList> {
  List doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  Future<void> fetchCategories() async {
    try {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      final response =
          await http.get(Uri.parse("${mainurl}category_doctors.php"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['doctors'] != null) {
          setState(() {
            doctors = data['doctors'];

            isLoading = false; // Hide loading indicator
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

  // Reusable info row (icon + text)
  Widget _infoRow(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 6),
        Text(text ?? "", style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  // Reusable button widget
  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Display message when no doctors are available for the selected category
  Widget _noDoctorsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: Dimensions.icon50, color: Colors.redAccent),
          SizedBox(height: Dimensions.height10),
          Text(
            "No doctors available for this category.",
            style: TextStyle(
                fontSize: Dimensions.font18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildDoctorCard(dynamic doctor) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height5),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // Adjusted width
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      doctor['name'] ?? '',
                      style: TextStyle(
                        fontSize: Dimensions.font18, // Increased font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      doctor['specialization'] ?? '',
                      style: TextStyle(
                        fontSize: Dimensions.font14,
                        color: Colors.black45,
                      ),
                    ),
                    trailing: CircleAvatar(
                      radius: 30, // Increased avatar size
                      backgroundImage: NetworkImage(
                        "$image_url${doctor['image'].toString()}",
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Dimensions.width20),
                    child: Divider(
                      thickness: 1.2,
                      height: Dimensions.height20,
                      color: Colors.black12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      doctor['about'] ?? '',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: Dimensions.font12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  // SizedBox(height: Dimensions.height10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Fee: ',
                            style: TextStyle(
                                fontSize: Dimensions.font16,
                                color: Colors.black54),
                          ),
                          Text(
                            '₹${doctor['fee']}',
                            style: TextStyle(
                              fontSize:
                                  Dimensions.font20, // Increased font size
                              color: Colors.redAccent.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoryScreen(doctor: doctor),
                            ),
                          ).then((_) {
                            FocusScope.of(context).unfocus();
                          });
                        },
                        child: Container(
                          width: Dimensions.width200, // Increased button width
                          padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'See Details',
                              style: TextStyle(
                                fontSize: Dimensions.font18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  Corrected Filtering Logic
    List filteredDoctors = doctors
        .where((doctor) =>
            doctor["specialization"]!.toLowerCase() ==
            widget.category.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
          backgroundColor: pColor,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              height: Dimensions.height5,
              width: Dimensions.width6,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F8FF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: gColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back,
                  color: pColor,
                  size: Dimensions.icon30,
                ),
              ),
            ),
          ),
          title: Text(
            "Available ${widget.category} Doctors",
            style: TextStyle(color: Colors.white),
          )),
      body: isLoading
          ? const Center(child: LoadingDialog())
          : filteredDoctors.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      return buildDoctorCard(doctor);
                    },
                  ),
                )
              : _noDoctorsFound(),
    );
  }
}
