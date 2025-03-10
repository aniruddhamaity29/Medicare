import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:medicare/pages/confirmcategory.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/url.dart';
import 'package:toastification/toastification.dart';

class CategoryScreen extends StatefulWidget {
  final dynamic doctor;

  const CategoryScreen({super.key, required this.doctor});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    List<int> availableDays = _parseDayRange(widget.doctor['days']);

    DateTime? picked;
    do {
      picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: initialDate,
        lastDate: DateTime(initialDate.year + 1),
      );

      if (picked == null) return; // User canceled

      if (!availableDays.contains(picked.weekday)) {
        _showToast("Please select a date between ${widget.doctor['days']}");
        return; // Exit function to prevent further execution
      }
    } while (!availableDays.contains(picked.weekday));

    setState(() {
      selectedDate = picked;
    });
  }

  List<int> _parseDayRange(String range) {
    Map<String, int> dayMap = {
      "Sun": 7,
      "Mon": 1,
      "Tue": 2,
      "Wed": 3,
      "Thu": 4,
      "Fri": 5,
      "Sat": 6
    };

    List<String> parts = range.split('-');
    if (parts.length == 2) {
      int start = dayMap[parts[0].trim()] ?? 1;
      int end = dayMap[parts[1].trim()] ?? 7;
      return List.generate((end - start) + 1, (index) => start + index);
    }
    return []; // Invalid format
  }

  Future<void> _pickTime(BuildContext context) async {
    if (selectedDate == null) {
      _showToast("Please select a valid date first.");
      return;
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    List<int> availableTimeRange = _parseTimeRange(
        widget.doctor['time']); // Convert "1:00-4:00" to [60, 240]

    if (availableTimeRange.length == 2) {
      int pickedMinutes = picked.hour * 60 + picked.minute;

      if (pickedMinutes >= availableTimeRange[0] &&
          pickedMinutes <= availableTimeRange[1]) {
        setState(() {
          selectedTime = picked;
        });
      } else {
        _showToast("Please pick a time between ${widget.doctor['time']}");
      }
    }
  }

  List<int> _parseTimeRange(String range) {
    List<String> parts = range.split('-');
    if (parts.length == 2) {
      return [
        _convertToMinutes(parts[0].trim()),
        _convertToMinutes(parts[1].trim())
      ];
    }
    return [];
  }

  int _convertToMinutes(String timeStr) {
    List<String> parts = timeStr.split(':');
    if (parts.length == 2) {
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      return hour * 60 + minute;
    }
    return 0;
  }

  void _showToast(String message) {
    toastification.show(
      context: context,
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E4EE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.1,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "$image_url${widget.doctor['image'].toString()}",
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      pColor.withOpacity(0.9),
                      pColor.withOpacity(0),
                      // pColor.withOpacity(0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: Dimensions.height30,
                        left: Dimensions.width10,
                        right: Dimensions.width10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              height: Dimensions.height45,
                              width: Dimensions.width45,
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
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Patients',
                                style: TextStyle(
                                  fontSize: Dimensions.font20,
                                  fontWeight: FontWeight.bold,
                                  color: wColor,
                                ),
                              ),
                              SizedBox(
                                height: Dimensions.height8,
                              ),
                              Text(
                                widget.doctor['patients'] ?? '',
                                style: TextStyle(
                                  fontSize: Dimensions.font18,
                                  fontWeight: FontWeight.w500,
                                  color: wColor,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Experience',
                                style: TextStyle(
                                  fontSize: Dimensions.font20,
                                  fontWeight: FontWeight.bold,
                                  color: wColor,
                                ),
                              ),
                              SizedBox(
                                height: Dimensions.height8,
                              ),
                              Text(
                                widget.doctor['experience'] ?? '',
                                style: TextStyle(
                                  fontSize: Dimensions.font18,
                                  fontWeight: FontWeight.w500,
                                  color: wColor,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rating',
                                style: TextStyle(
                                  fontSize: Dimensions.font20,
                                  fontWeight: FontWeight.bold,
                                  color: wColor,
                                ),
                              ),
                              SizedBox(
                                height: Dimensions.height8,
                              ),
                              Text(
                                widget.doctor['rating'].toString(),
                                style: TextStyle(
                                  fontSize: Dimensions.font18,
                                  fontWeight: FontWeight.w500,
                                  color: wColor,
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
            SizedBox(height: Dimensions.height10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor['name'] ?? '',
                    style: TextStyle(
                      fontSize: Dimensions.font24,
                      fontWeight: FontWeight.w500,
                      color: pColor,
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Row(
                    children: [
                      Icon(
                        MdiIcons.heartPulse,
                        color: Colors.red,
                        size: Dimensions.icon24,
                      ),
                      SizedBox(width: Dimensions.width6),
                      Text(
                        widget.doctor['specialization'] ?? '',
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          color: bColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height15),
                  Text(
                    widget.doctor['about'] ?? '',
                    style: TextStyle(
                      fontSize: Dimensions.font12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    "Available Days & Time",
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      color: bColor.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    "${widget.doctor['days'] ?? ''} & ${widget.doctor['time'] ?? ''}",
                    style: TextStyle(
                      fontSize: Dimensions.font12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: Dimensions.height10),
                  Text(
                    "Book Date",
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      color: bColor.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(Dimensions.width280, Dimensions.height40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                            : "Pick a Date",
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    "Book Time",
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      color: bColor.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Center(
                    child: ElevatedButton(
                        onPressed: () => _pickTime(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              Size(Dimensions.width280, Dimensions.height40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          selectedTime != null
                              ? selectedTime!.format(context)
                              : "Pick a Time",
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        height: Dimensions.height100 * 1,
        decoration: BoxDecoration(
          color: const Color(0xFFD9E4EE).withOpacity(0.9),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Consultation Fee',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '₹${widget.doctor['fee']}',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    color: Colors.redAccent.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height5),
            Material(
              color: pColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  if (selectedDate == null && selectedTime == null) {
                    toastification.show(
                      context: context,
                      title: const Text("Please select date and time!"),
                      autoCloseDuration: const Duration(seconds: 3),
                      style: ToastificationStyle.flatColored,
                      applyBlurEffect: true,
                      icon: const Icon(
                        Ionicons.close_circle,
                        color: rColor,
                      ),
                      type: ToastificationType.error,
                      pauseOnHover: true,
                    );
                  } else if (selectedDate == null) {
                    toastification.show(
                      context: context,
                      title: const Text("Please select date!"),
                      autoCloseDuration: const Duration(seconds: 3),
                      style: ToastificationStyle.flatColored,
                      applyBlurEffect: true,
                      icon: const Icon(
                        Ionicons.close_circle,
                        color: rColor,
                      ),
                      type: ToastificationType.error,
                      pauseOnHover: true,
                    );
                  } else if (selectedTime == null) {
                    toastification.show(
                      context: context,
                      title: const Text("Please select time!"),
                      autoCloseDuration: const Duration(seconds: 3),
                      style: ToastificationStyle.flatColored,
                      applyBlurEffect: true,
                      icon: const Icon(
                        Ionicons.close_circle,
                        color: rColor,
                      ),
                      type: ToastificationType.error,
                      pauseOnHover: true,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Confirmcategory(
                          doctorName: widget.doctor['name'],
                          specialization: widget.doctor['specialization'],
                          image:
                              "$image_url${widget.doctor['image'].toString()}",
                          date: selectedDate != null
                              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                              : '',
                          time: selectedTime != null
                              ? selectedTime!.format(context)
                              : '',
                          fee: widget.doctor['fee'],
                        ),
                      ),
                    ).then((_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    });
                  }
                },
                child: SizedBox(
                  height: Dimensions.height50 * 0.9,
                  width: Dimensions.width350,
                  child: Center(
                    child: Text(
                      "Book Appointment",
                      style: TextStyle(
                        color: wColor,
                        fontSize: Dimensions.font20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
