// import 'package:cv_quick/utils/appconstants/app_constants.dart';
import 'package:flutter/material.dart';

class ThemeChangeProvider with ChangeNotifier {
  var _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  // void toogleTheme() {
  //   if(_themeMode == lightTheme){
  //     themeMode = lightTheme;
  //   }else{

  //   }
  // }
}
