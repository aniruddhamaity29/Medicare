import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicare/pages/splash_screen.dart';
import 'package:medicare/utils/app_theme.dart';
import 'package:medicare/utils/dependency_injection.dart';
import 'package:medicare/utils/theme_change_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(milliseconds: 200));
  runApp(MyApp());
  DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeChangeProvider()),
      ],
      child: Builder(builder: (context) {
        final changeTheme = Provider.of<ThemeChangeProvider>(context);
        return GetMaterialApp(
          title: 'Medicare',
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: changeTheme.themeMode,
        );
      }),
    );
  }
}
