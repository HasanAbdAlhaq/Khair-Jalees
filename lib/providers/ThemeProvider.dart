import 'package:flutter/material.dart';
import 'package:grad_project/models/Themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_actions.dart';

class ThemeNotifier with ChangeNotifier {
  static final ThemeNotifier _instance = new ThemeNotifier.internal();
  factory ThemeNotifier() => _instance;
  ThemeData _themeData;

  ThemeNotifier.internal() {
    loadThemeByDB();
  }

  void loadThemeByDB() {
    SharedPreferences.getInstance().then((prefs) async {
      bool isLoggedId = prefs.getBool('loggedIn');
      String username = prefs.getString('username');
      var userAsMap = await UserActions.getUser(username);
      int themeId = userAsMap['themeId'];
      if (isLoggedId) {
        setTheme(loadTheme(themeId));
      } else
        setTheme(loadTheme(0));
    });
  }

  static ThemeData loadTheme(int themeId) {
    switch (themeId) {
      case 1:
        return Themes.defaultTheme['themeData'];
        break;
      case 2:
        return Themes.secondTheme['themeData'];
        break;
      case 3:
        return Themes.thirdTheme['themeData'];
        break;
      default:
        return Themes.defaultTheme['themeData'];
    }
  }

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}
