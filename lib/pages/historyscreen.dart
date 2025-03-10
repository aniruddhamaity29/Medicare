import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/loading.dart';
import 'package:medicare/utils/url.dart';
import 'package:toastification/toastification.dart';

class Historyscreen extends StatefulWidget {
  const Historyscreen({super.key});

  @override
  State<Historyscreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<Historyscreen> {
  bool isLoading = true;
  List doctors = [];
  List categories = [];

  @override
  void initState() {
    fetchCategoriesDetails();
    fetchDetails();
    super.initState();
  }

  Future<void> fetchCategoriesDetails() async {
    try {
      setState(() => isLoading = true);
      final response =
          await http.get(Uri.parse("${mainurl}get_categories_details.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['categories'] != null) {
          setState(() {
            categories = data['categories'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (error) {
      setState(() => isLoading = false);
      print("Error fetching doctors: $error");
    }
  }

  Future<void> fetchDetails() async {
    try {
      setState(() => isLoading = true);
      final response =
          await http.get(Uri.parse("${mainurl}get_appointment_details.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['doctors'] != null) {
          setState(() {
            doctors = data['doctors'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (error) {
      setState(() => isLoading = false);
      print("Error fetching doctors: $error");
    }
  }

  Widget buildCategoryCard(dynamic category) {
    // DateTime currentTime = DateTime.now();
    // DateTime? appointmentTime;

    // try {
    //   String date = doctor['date'] ?? "";
    //   String time = doctor['time'] ?? "";
    //   if (date.isNotEmpty && time.isNotEmpty) {
    //     appointmentTime =
    //         DateFormat("yyyy-MM-dd HH:mm:ss").parse("$date $time");
    //   }
    // } catch (e) {
    //   print("Error parsing appointment time: $e");
    // }

    // // Ensure appointmentTime is not null
    // int timeDiff = appointmentTime != null
    //     ? currentTime.difference(appointmentTime).inMinutes
    //     : -1; // Use -1 as a default value if parsing fails

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height5),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            const BoxShadow(
                color: Colors.black12, blurRadius: 6, spreadRadius: 3)
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(category['name'] ?? '',
                  style: TextStyle(
                      fontSize: Dimensions.font18,
                      fontWeight: FontWeight.bold)),
              subtitle: Text(category['specialization'] ?? '',
                  style: TextStyle(
                      fontSize: Dimensions.font14, color: Colors.black45)),
              trailing: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage("$image_url${category['image']}")),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Divider(
                  thickness: 1.2,
                  height: Dimensions.height20,
                  color: Colors.black12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoRow(Icons.calendar_month_rounded, category['date'] ?? ''),
                _infoRow(Icons.access_time, category['time'] ?? ''),
                _infoRow(Ionicons.cash, category['fee'] ?? ''),
              ],
            ),
            SizedBox(height: Dimensions.height15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: Dimensions.width2),
                    Text(
                      category['status'] == 'Cancelled'
                          ? "Cancelled"
                          : "Confirmed",
                      style: TextStyle(
                        color: category['status'] == 'Cancelled'
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () =>
                      showConfirmationCategory(category['categoryid']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Cancel Appointment",
                    style: TextStyle(color: wColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDoctorCard(dynamic doctor) {
    // DateTime currentTime = DateTime.now();
    // DateTime? appointmentTime;

    // try {
    //   String date = doctor['date'] ?? "";
    //   String time = doctor['time'] ?? "";

    //   if (date.isNotEmpty && time.isNotEmpty) {
    //     appointmentTime =
    //         DateFormat("yyyy-MM-dd HH:mm:ss").parse("$date $time");
    //     print(appointmentTime);
    //   }
    // } catch (e) {
    //   print("Error parsing appointment time: $e");
    // }

    // int timeDiff = appointmentTime != null
    //     ? currentTime.difference(appointmentTime).inMinutes
    //     : -1; // Default value if parsing fails

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height5),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            const BoxShadow(
                color: Colors.black12, blurRadius: 6, spreadRadius: 3)
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(doctor['name'] ?? '',
                  style: TextStyle(
                      fontSize: Dimensions.font18,
                      fontWeight: FontWeight.bold)),
              subtitle: Text(doctor['specialization'] ?? '',
                  style: TextStyle(
                      fontSize: Dimensions.font14, color: Colors.black45)),
              trailing: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage("$image_url${doctor['image']}")),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Divider(
                  thickness: 1.2,
                  height: Dimensions.height20,
                  color: Colors.black12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoRow(Icons.calendar_month_rounded, doctor['date'] ?? ''),
                _infoRow(Icons.access_time, doctor['time'] ?? ''),
                _infoRow(Ionicons.cash, doctor['fee'] ?? ''),
              ],
            ),
            SizedBox(height: Dimensions.height15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: Dimensions.width2),
                    Text(
                      doctor['status'] == 'Cancelled'
                          ? "Cancelled"
                          : "Confirmed",
                      style: TextStyle(
                        color: doctor['status'] == 'Cancelled'
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => showConfirmationAppoint(doctor['appointid']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Cancel Appointment",
                    style: TextStyle(color: wColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Future<void> cancelCategories(String categoryid) async {
    final response = await http.post(
      Uri.parse("${mainurl}cancel_categories.php"),
      body: {"categoryid": categoryid},
    );
    if (response.statusCode == 200) {
      toastification.show(
        context: context,
        title: const Text('Appointment cancelled successfully!'),
        autoCloseDuration: const Duration(seconds: 2),
        style: ToastificationStyle.flatColored,
        applyBlurEffect: true,
        icon: const Icon(
          Ionicons.checkmark_circle,
          color: Colors.green,
        ),
        type: ToastificationType.success,
        pauseOnHover: true,
      );
      fetchCategoriesDetails();
    } else {
      Fluttertoast.showToast(
          msg: "Failed to appointment cancelletion. Try again.");
    }
  }

  void showConfirmationCategory(String categoryid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Ionicons.trash_outline,
              size: Dimensions.icon50,
              color: rAccent,
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'C A N C E L',
              style: TextStyle(
                fontSize: Dimensions.font24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to cancel appointment?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Dimensions.font16,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: EdgeInsets.symmetric(vertical: Dimensions.height15),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(Dimensions.width100, Dimensions.height40),
              elevation: 3,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: bColor,
                fontSize: Dimensions.font14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cancelCategories(categoryid).then((_) {
                Navigator.pop(context);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: rAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(Dimensions.width100, Dimensions.height40),
              elevation: 3,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                color: wColor,
                fontSize: Dimensions.font14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showConfirmationAppoint(String appointid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Ionicons.trash_outline,
              size: Dimensions.icon50,
              color: rAccent,
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'C A N C E L',
              style: TextStyle(
                fontSize: Dimensions.font24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to cancel appointment?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Dimensions.font16,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: EdgeInsets.symmetric(vertical: Dimensions.height15),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(Dimensions.width100, Dimensions.height40),
              elevation: 3,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: bColor,
                fontSize: Dimensions.font14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cancelAppointment(appointid).then((_) {
                Navigator.pop(context);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: rAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(Dimensions.width100, Dimensions.height40),
              elevation: 3,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                color: wColor,
                fontSize: Dimensions.font14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> cancelAppointment(String appointid) async {
    final response = await http.post(
      Uri.parse("${mainurl}cancel_appointment.php"),
      body: {"appointid": appointid},
    );
    if (response.statusCode == 200) {
      toastification.show(
        context: context,
        title: const Text('Appointment cancelled successfully!'),
        autoCloseDuration: const Duration(seconds: 2),
        style: ToastificationStyle.flatColored,
        applyBlurEffect: true,
        icon: const Icon(
          Ionicons.checkmark_circle,
          color: Colors.green,
        ),
        type: ToastificationType.success,
        pauseOnHover: true,
      );
      fetchDetails();
    } else {
      Fluttertoast.showToast(
          msg: "Failed to appointment cancelletion. Try again.");
    }
  }

  Widget noAppointmentsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: Dimensions.icon50,
            color: Colors.redAccent,
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            "No appointment history available.",
            style: TextStyle(
              fontSize: Dimensions.font18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            "Appointment History",
            style: TextStyle(color: Colors.white),
          )),
      body: isLoading
          ? const Center(child: LoadingDialog())
          : categories.isEmpty && doctors.isEmpty
              ? noAppointmentsFound()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (categories.isNotEmpty)
                        Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return buildCategoryCard(categories[index]);
                              },
                            ),
                          ],
                        ),
                      if (doctors.isNotEmpty)
                        Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: doctors.length,
                              itemBuilder: (context, index) {
                                return buildDoctorCard(doctors[index]);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}
