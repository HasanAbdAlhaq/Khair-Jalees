// Flutter Packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/providers/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import './services/services.dart';

// Router
import './Router.dart';

// Screens
import './screens/LogInSignUpScreen.dart';
import './screens/HomeScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    checkIfLoggedIn();
    super.initState();
  }

  void checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('loggedIn');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, notifier, child) {
          return MaterialApp(
            navigatorKey: NavigationService.instance.navigationKey,
            debugShowCheckedModeBanner: false,
            locale: Locale('ar', 'SA'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ar', 'SA'),
            ],
            theme: notifier.getTheme(),
            home: child,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/',
          );
        },
        child: Center(
          child: SplashScreen(
            seconds: 4,
            navigateAfterSeconds:
                isLoggedIn ? HomeScreen() : LogInSignUpScreen(),
            loaderColor: Color(0xFF4C064D),
            image: Image.asset('assets/images/logo.png'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            useLoader: true,
            photoSize: 125.0,
          ),
        ),
      ),
    );
  }
}
