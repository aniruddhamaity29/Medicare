import 'package:flutter/material.dart';
import 'package:medicare/utils/colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
      primary: pColor, secondary: wColor, background: Colors.white),
  // textTheme: TextTheme(
  //   displayMedium: TextStyle(
  //     color: Colors.redAccent.shade400,
  //     fontSize: 18,
  //     fontWeight: FontWeight.bold,
  //   ),
  //   displaySmall: TextStyle(
  //     color: Colors.blue,
  //     fontWeight: FontWeight.bold,
  //     fontSize: 14,
  //   ),
  // ),
  // iconTheme: IconThemeData(
  //   color: Colors.redAccent.shade400,
  // ),
  // listTileTheme: ListTileThemeData(),
  // cardTheme: CardTheme(color: Colors.red.shade100),
  // splashColor: Colors.black,
  // elevatedButtonTheme: ElevatedButtonThemeData(
  //   style: ElevatedButton.styleFrom(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     minimumSize: const Size(350, 50),
  //     backgroundColor: Colors.blue,
  //   ),
  // ),
  // textButtonTheme: TextButtonThemeData(
  //     style: ButtonStyle(
  //         textStyle: WidgetStatePropertyAll(
  //   TextStyle(
  //       color: Colors.red.shade200, fontSize: 16, fontWeight: FontWeight.bold),
  // ))),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      primary: pColor, secondary: Colors.black, background: Colors.black),
  // textTheme: TextTheme(
  //   displayMedium: TextStyle(
  //     color: Colors.white60,
  //     fontSize: 18,
  //     fontWeight: FontWeight.bold,
  //   ),
  //   displaySmall: TextStyle(
  //     color: Colors.blue,
  //     fontWeight: FontWeight.bold,
  //     fontSize: 14,
  //   ),
  // ),
  // iconTheme: const IconThemeData(
  //   color: Colors.white60,
  // ),
  // cardTheme: CardTheme(color: Colors.black87),
  // splashColor: Colors.white,
  // textButtonTheme: TextButtonThemeData(
  //     style: ButtonStyle(
  //         textStyle: WidgetStatePropertyAll(
  //   TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  // ))),
  // elevatedButtonTheme: ElevatedButtonThemeData(
  //   style: ElevatedButton.styleFrom(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     minimumSize: const Size(350, 50),
  //     backgroundColor: Colors.blue,
  //   ),
  // ),
);
