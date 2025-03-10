import 'package:flutter/material.dart';

class AppointScreen extends StatefulWidget {
  final dynamic doctor;

  const AppointScreen({super.key, required this.doctor});

  @override
  State<AppointScreen> createState() => _AppointScreenState();
}

class _AppointScreenState extends State<AppointScreen> {
  int selectedDateIndex = 0;
  String? selectedSlot;

  // List of available dates with dynamic slot numbers
  List<Map<String, dynamic>> dates = [
    {'date': 'Today, 6 Mar', 'slots': 2},
    {'date': 'Tomorrow, 7 Mar', 'slots': 4},
    {'date': 'Sat, 8 Mar', 'slots': 6},
    {'date': 'Sun, 9 Mar', 'slots': 3},
    {'date': 'Mon, 10 Mar', 'slots': 8},
  ];

  // Determine the current period
  String getCurrentPeriod() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      return 'Morning';
    } else if (hour < 16) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  // Function to generate slots dynamically based on the current period
  List<String> generateSlots(int count) {
    List<String> slots = [];
    String period = getCurrentPeriod();

    DateTime startTime;
    if (period == 'Morning') {
      startTime = DateTime(2024, 1, 1, 9, 0); // 9:00 AM
    } else if (period == 'Afternoon') {
      startTime = DateTime(2024, 1, 1, 12, 0); // 12:00 PM
    } else {
      startTime = DateTime(2024, 1, 1, 16, 0); // 4:00 PM
    }

    for (int i = 0; i < count; i++) {
      String slotTime =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour < 12 ? 'AM' : 'PM'}';
      slots.add(slotTime);
      startTime = startTime.add(Duration(minutes: 30)); // Increase by 30 mins
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    int availableSlots = dates[selectedDateIndex]['slots'];
    List<String> dynamicSlots = generateSlots(availableSlots);
    String currentPeriod = getCurrentPeriod(); // Get current period

    return Scaffold(
      backgroundColor: const Color(0xFFD9E4EE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: Colors.blue),
                SizedBox(width: 5),
                Text("Clinic visit slots"),
              ],
            ),
            SizedBox(height: 10),

            // Date Selection Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(dates.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDateIndex = index;
                        selectedSlot = null; // Reset selected slot
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

            // Selected Date Display
            Text(
              dates[selectedDateIndex]['date'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            SizedBox(height: 10),

            // Slots Section with dynamic period
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 5),
                Text(
                  '$currentPeriod $availableSlots slots',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Dynamic Slots Display
            Wrap(
              spacing: 10,
              runSpacing: 5,
              children: dynamicSlots.map((slot) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSlot = slot;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                      color: selectedSlot == slot
                          ? Colors.blue[100]
                          : Colors.white,
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
