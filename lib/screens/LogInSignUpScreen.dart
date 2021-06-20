// Flutter Packages
import 'package:flutter/material.dart';
// Screens
import './LoginScreen.dart';
import './signupScreen.dart';

// Custome Widgets
import '../widgets/CustomButton.dart';

class LogInSignUpScreen extends StatelessWidget {
  static const routeName = '/LogIn-SignUp-Screen';
  @override
  Widget build(BuildContext context) {
    // Virables
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    // Actual Build Projects
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(),
          Container(
            width: mediaQuery.size.width,
            height: 225,
            child: Image.asset('assets/images/main_screen_image.png'),
          ),
          Column(
            children: [
              Text(
                'خير جليس',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 40,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: mediaQuery.size.width * 0.8,
                child: Text(
                  'لتسهيل إنشاء مجموعات للقراءة مع الأصدقاء والأقارب',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              CustomButton(
                text: 'تسجيل الدخول',
                onPressed: () {
                  Navigator.of(context).pushNamed(LogInScreen.routeName);
                },
                width: 300,
              ),
              SizedBox(
                height: 5,
              ),
              CustomButton(
                text: 'إنشاء حساب',
                onPressed: () {
                  Navigator.of(context).pushNamed(SignUpScreen.routeName);
                },
                width: 300,
              ),
            ],
          )
        ],
      ),
    );
  }
}
