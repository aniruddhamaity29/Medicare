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
                        selectedSlot = null;
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

            Text(
              dates[selectedDateIndex]['date'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }
}
