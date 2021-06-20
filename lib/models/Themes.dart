//Flutter Packages
import 'package:flutter/material.dart';
//Models
import 'HexColors.dart';

class Themes {
  static final defaultTheme = {
    'themeId': 1,
    'themeName': 'السمة الافتراضية',
    'themeData': ThemeData(
      primaryColor: HexColor("4d064d"), //بنفسجي
      accentColor: HexColor("ffad05"), // اصفر
      primaryColorLight: HexColor("7E4D7F"), // بنفسجي خفيف
      scaffoldBackgroundColor: HexColor("f5f5f5"), //f5
      primaryColorDark: HexColor("7acafa"), // الازرق
      fontFamily: 'Tajawal',
    ),
    'themePrice': 150,
  };

  static final secondTheme = {
    'themeId': 2,
    'themeName': 'السمة الثانية',
    'themeData': ThemeData(
      primaryColor: HexColor("#080255"), // كحلي
      accentColor: HexColor("ffad05"), // اصفر
      primaryColorLight: HexColor("4D627F"), // كحلي خفيف
      scaffoldBackgroundColor: HexColor("f5f5f5"), //f5
      primaryColorDark: HexColor("7acafa"), // بديل الازرق
      fontFamily: 'Tajawal',
    ),
    'themePrice': 100,
  };

  static final thirdTheme = {
    'themeId': 3,
    'themeName': 'السمة الثالثة',
    'themeData': ThemeData(
      primaryColor: HexColor("#3e403f"), // أسود
      accentColor: HexColor("ffad05"), // اصفر
      primaryColorLight: HexColor("#919191"), // رمادي خفيف
      scaffoldBackgroundColor: HexColor("f5f5f5"), //f5
      primaryColorDark: HexColor("7acafa"), // بديل الازرق
      fontFamily: 'Tajawal',
    ),
    'themePrice': 200,
  };
}
