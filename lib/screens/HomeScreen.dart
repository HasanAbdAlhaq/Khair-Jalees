//Flutter Packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grad_project/main.dart';
import 'package:grad_project/screens/LeaderboardScreen.dart';
import 'package:grad_project/screens/UserGroupsScreen.dart';
import 'package:grad_project/screens/UserInvitesScreen.dart';
import '../services/services.dart';

//Custom Widgets
import '../widgets/CustomDrawer.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomPageLabel.dart';

// Screens
import '../screens/CategoryScreen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  //_showNotification(message.notification.title, message.notification.body);
}

setupfirebase(BuildContext context) {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  var android = AndroidInitializationSettings('ic_stat_onesignal_default');
  var ios = IOSInitializationSettings();
  var platform = new InitializationSettings(android: android, iOS: ios);
  flutterLocalNotificationsPlugin.initialize(
    platform,
    onSelectNotification: (payload) async {
      print(payload);
      if (payload.contains("دعوة"))
        NavigationService.instance.navigateTo(UserInvitesScreen.routeName);
      else
        NavigationService.instance.navigateTo(UserGroupsScreen.routeName);
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showNotification(message.notification.title, message.notification.body);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification.title.contains("دعوة")) {
      Navigator.of(context).pushNamed(UserInvitesScreen.routeName);
    } else {
      Navigator.of(context).pushNamed(UserGroupsScreen.routeName);
    }
  });
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, title, body, platformChannelSpecifics, payload: title);
}

class HomeScreen extends StatefulWidget {
// Constants
  static const routeName = '/Home-Page';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    setupfirebase(context);
    FirebaseMessaging.instance.getInitialMessage();
  }

  final categoryNames = [
    'الروايات العربية',
    'قصص أطفال',
    'الروايات المترجمة',
    'علم النفس',
    'التاريخ',
    'العلوم الإجتماعية',
    'المسرح العربي',
    'المسرح المترجم',
    'العلوم الإسلامية',
    'العلوم السياسية والاستراتيجية',
    'القصص القصيرة',
    'السيرة الذاتية',
    'الأدب العربي',
    'الأدب المترجم',
    'الأدب الساخر',
    'التنمية البشرية',
    'الشعر العربي',
    'القسم العام',
  ];

  Widget buildCategoryGridItem(BuildContext ctx, {String categoryName}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(ctx).pushReplacementNamed(CategoryScreen.routeName,
            arguments: categoryName);
      },
      child: Container(
        height: 120,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Theme.of(ctx).primaryColor,
        ),
        child: Center(
          child: Text(
            categoryName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(ctx).accentColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBooksCard(
      BuildContext context, String typeofdate, String bookCover) {
    return Container(
      padding: EdgeInsets.all(5),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width / 3.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            typeofdate,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            height: MediaQuery.of(context).size.height * 0.22,
            child: Image.network(
              bookCover,
              fit: BoxFit.fitHeight,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        endDrawer: CustomDrawer(),
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            children: [
              Column(
                children: [
                  CustomPageLabel("الأكثر قراءة"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTopBooksCard(
                        context,
                        "هذه السنة",
                        'https://www.4read.net/uploads/images/1566293416.jpg',
                      ),
                      _buildTopBooksCard(
                        context,
                        "هذا الشهر",
                        'https://www.4read.net/uploads/images/1566293416.jpg',
                      ),
                      _buildTopBooksCard(
                        context,
                        "هذا الأسبوع",
                        'https://www.4read.net/uploads/images/1584865035.jpg',
                      )
                    ],
                  )
                ],
              ),
              CustomPageLabel('التصنيفات'),
              Container(
                height: 350,
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: GridView.builder(
                  itemCount: categoryNames.length,
                  itemBuilder: (ctx, index) => buildCategoryGridItem(ctx,
                      categoryName: categoryNames[index]),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 25,
                  ),
                ),
              )
            ],
          )),
        ));
  }
}
