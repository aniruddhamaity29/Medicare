import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/url.dart';

class AppointScreen extends StatefulWidget {
  final dynamic doctor;

  const AppointScreen({super.key, required this.doctor});

  @override
  State<AppointScreen> createState() => _AppointScreenState();
}

class _AppointScreenState extends State<AppointScreen> {
  int selectedDateIndex = 0;
  String? selectedSlot;

  List<Map<String, dynamic>> dates = [
    {'date': 'Today, 6 Mar', 'slots': 5},
    {'date': 'Tomorrow, 7 Mar', 'slots': 6},
    {'date': 'Sat, 8 Mar', 'slots': 8},
    {'date': 'Sun, 9 Mar', 'slots': 4},
    {'date': 'Mon, 10 Mar', 'slots': 7},
  ];

  List<Map<String, dynamic>> generateSlots(int count) {
    List<Map<String, dynamic>> slots = [];
    DateTime startTime = DateTime(2024, 1, 1, 9, 0); // Start at 9:00 AM

    for (int i = 0; i < count; i++) {
      String period;
      if (startTime.hour < 12) {
        period = "Morning";
      } else if (startTime.hour < 17) {
        period = "Afternoon";
      } else {
        period = "Evening";
      }

      String slotTime =
          '${startTime.hour % 12 == 0 ? 12 : startTime.hour % 12}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour < 12 ? 'AM' : 'PM'}';

      slots.add({'time': slotTime, 'period': period});
      startTime = startTime.add(Duration(minutes: 30)); // Increase by 30 mins
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    int availableSlots = dates[selectedDateIndex]['slots'];
    List<Map<String, dynamic>> dynamicSlots = generateSlots(availableSlots);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.blue,
                      ),
                      Text("Clinic visit slots"),
                    ],
                  ),
                  SizedBox(height: Dimensions.height2),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(dates.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;
                              selectedSlot = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: selectedDateIndex == index
                                  ? Colors.lightBlue[100]
                                  : Colors.white,
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dates[index]['date'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${dates[index]['slots']} slots available',
                                  style: TextStyle(color: Colors.green),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${dates[selectedDateIndex]['date']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 10),
                  // Group slots by Morning, Afternoon, and Evening
                  ...['Morning', 'Afternoon', 'Evening'].map((period) {
                    List<Map<String, dynamic>> periodSlots = dynamicSlots
                        .where((slot) => slot['period'] == period)
                        .toList();

                    if (periodSlots.isEmpty)
                      return SizedBox(); // Hide empty categories

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              period == 'Morning'
                                  ? Icons.wb_sunny
                                  : period == 'Afternoon'
                                      ? Icons.wb_cloudy
                                      : Icons.nights_stay,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '$period (${periodSlots.length} slots)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          children: periodSlots.map((slot) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSlot = slot['time'];
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(8),
                                  color: selectedSlot == slot['time']
                                      ? Colors.blue[100]
                                      : Colors.white,
                                ),
                                child: Text(
                                  slot['time'],
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
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
                onTap: () {},
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
