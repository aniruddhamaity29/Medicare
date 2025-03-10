import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:medicare/pages/approvedscreen.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/url.dart';
import 'package:toastification/toastification.dart';
import 'package:http/http.dart' as http;

class Confirmappointscreen extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final String image;
  final String date;
  final String time;
  final String fee;

  const Confirmappointscreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.image,
    required this.date,
    required this.time,
    required this.fee,
  });

  @override
  State<Confirmappointscreen> createState() => _ConfirmappointscreenState();
}

class _ConfirmappointscreenState extends State<Confirmappointscreen> {
  bool isLoading = false;
  late String selectedDate;
  late String selectedTime;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
    selectedTime = widget.time;
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = "${picked.hour}:${picked.minute}";
      });
    }
  }

  Future<void> addDetails() async {
    Map data = {
      "name": widget.doctorName,
      "specialization": widget.specialization,
      "fee": widget.fee,
      "date": selectedDate,
      "time": selectedTime,
      'status': 'Confirmed',
    };

    try {
      var response = await http.post(
        Uri.parse("${mainurl}add_appointment_details.php"),
        body: data,
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Approvedscreen()),
          );
        } else {
          toastification.show(
            context: context,
            title: const Text('Failed to add details'),
            autoCloseDuration: const Duration(seconds: 2),
            style: ToastificationStyle.flatColored,
            applyBlurEffect: true,
            icon: const Icon(Ionicons.close_circle, color: Colors.red),
            type: ToastificationType.error,
            pauseOnHover: true,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Server error, please try again later',
          textColor: Colors.black,
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Network error, please try again later',
        textColor: Colors.black,
        backgroundColor: Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Confirm Doctor Appointment",
          style: TextStyle(color: Colors.white, fontFamily: 'courier new'),
        ),
        backgroundColor: pColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(widget.doctorName),
                    subtitle: Text(widget.specialization,
                        style: const TextStyle(color: Colors.black38)),
                    trailing: CircleAvatar(
                      radius: 25,
                      backgroundImage: widget.image.startsWith('http')
                          ? NetworkImage(widget.image)
                          : const AssetImage("assets/images/doctor1.jpg")
                              as ImageProvider,
                    ),
                  ),
                  Divider(
                      thickness: 1,
                      height: Dimensions.height20,
                      color: Colors.black12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: pickDate,
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: Colors.black54),
                            SizedBox(width: Dimensions.width6),
                            Text(selectedDate,
                                style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: pickTime,
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_filled,
                                color: Colors.black54),
                            SizedBox(width: Dimensions.width6),
                            Text(selectedTime,
                                style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Ionicons.cash, color: Colors.black54),
                          SizedBox(width: Dimensions.width6),
                          Text(widget.fee,
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: addDetails,
                        child: const Text('Confirm'),
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
}
