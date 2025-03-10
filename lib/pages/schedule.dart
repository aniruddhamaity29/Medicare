// import 'package:flutter/material.dart';
// import 'package:medicare/pages/bottomnav.dart';
// import 'package:medicare/pages/upcomingschedule.dart';
// import 'package:medicare/utils/colors.dart';
// import 'package:medicare/utils/dimensions.dart';
// import 'package:medicare/utils/name.dart';

// class Schedule extends StatefulWidget {
//   final String doctor;
//   final String date;
//   final String time;

//   const Schedule({
//     super.key,
//     required this.doctor,
//     required this.date,
//     required this.time,
//   });
//   @override
//   State<Schedule> createState() => _ScheduleState();
// }

// class _ScheduleState extends State<Schedule> {
//   int buttonIndex = 0;
//   final scheduleWidgets = [
//     //upcoming widget
//     Upcomingschedule(),

//     //canceled widget
//     Container(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: WillPopScope(
//         onWillPop: () async {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Nav()),
//           );
//           return false; // Preventing pop
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             title: schedule,
//             backgroundColor: pColor,
//           ),
//           body: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.only(top: Dimensions.height20),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(5),
//                     margin:
//                         EdgeInsets.symmetric(horizontal: Dimensions.width60),
//                     decoration: BoxDecoration(
//                       color: Color(0xFFF4F6FA),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               buttonIndex = 0;
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               vertical: Dimensions.height10,
//                               horizontal: Dimensions.width15,
//                             ),
//                             decoration: BoxDecoration(
//                               color: buttonIndex == 0
//                                   ? Color(0xFF7165D6)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               'Upcoming',
//                               style: TextStyle(
//                                 fontSize: Dimensions.font16,
//                                 fontWeight: FontWeight.w500,
//                                 color: buttonIndex == 0
//                                     ? Colors.white
//                                     : Colors.black26,
//                               ),
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               buttonIndex = 1;
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               vertical: Dimensions.height10,
//                               horizontal: Dimensions.width20,
//                             ),
//                             decoration: BoxDecoration(
//                               color: buttonIndex == 1
//                                   ? Color(0xFF7165D6)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               'Canceled',
//                               style: TextStyle(
//                                 fontSize: Dimensions.font16,
//                                 fontWeight: FontWeight.w500,
//                                 color: buttonIndex == 1
//                                     ? Colors.white
//                                     : Colors.black26,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: Dimensions.height30),
//                   scheduleWidgets[buttonIndex],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
