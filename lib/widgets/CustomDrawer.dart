// Flutter Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/room_actions.dart';
import 'package:grad_project/models/Themes.dart';
import 'package:grad_project/providers/ThemeProvider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import '../screens/LogInSignUpScreen.dart';
import '../screens/FavouritesScreen.dart';
import '../screens/UserInvitesScreen.dart';
import '../screens/UserGroupsScreen.dart';
import '../screens/HomeScreen.dart';
import '../screens/FAQScreen.dart';
import '../screens/UserProfileScreen.dart';
import '../screens/CommentsRatingsScreen.dart';
import '../screens/LeaderboardScreen.dart';
import '../screens/FiltersScreen.dart';
import '../screens/ReadingStatisticsScreen.dart';
import '../screens/UserRewardsScreen.dart';
// Wigets
import './CustomIcon.dart';

// Models
import '../models/User.dart';
import '../models/Enums.dart';

// Database
import '../database/user_actions.dart';

class CustomDrawer extends StatefulWidget {
  //Navigation Menu
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final _defaultAvatarURL = 'https://via.placeholder.com/150/4c064d?text= ';
  bool _isActivityDropDownDropped = false;
  bool _isProfileDropDownDropped = false;
  bool _isRoomsDropDownDropped = false;
  List<Map<String, dynamic>> subscribedrooms = [];

  String _username = 'aa';
  User currentUser = User(email: '', fullName: '', username: '', password: '');
  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    UserActions.getUsers(where: 'username = ?', whereArgs: [_username])
        .then((value) {
      setState(() {
        currentUser = User.fromMap(value.first);
      });
    });
    var listofrooms = await RoomActions.GetSubscribedRooms(_username);
    setState(() {
      subscribedrooms = listofrooms;
    });
    _resetNotifications();
    _OverallNumberOfNotifications();
  }

  void _toogleActivityDropDown() {
    setState(() {
      _isProfileDropDownDropped = false;
      _isRoomsDropDownDropped = false;
      _isActivityDropDownDropped = !_isActivityDropDownDropped;
    });
  }

  void _toogleProfileDropDown() {
    setState(() {
      _isActivityDropDownDropped = false;
      _isRoomsDropDownDropped = false;
      _isProfileDropDownDropped = !_isProfileDropDownDropped;
    });
  }

  void _toogleRoomsDropDown() {
    setState(() {
      _isActivityDropDownDropped = false;
      _isProfileDropDownDropped = false;

      _isRoomsDropDownDropped = !_isRoomsDropDownDropped;
    });
  }

  bool get isAnyDropDownDropped {
    return _isActivityDropDownDropped || _isProfileDropDownDropped;
  }

  Widget buildListTile(
      String title, IconData icon, Function tapHandler, Color textColor,
      {Widget leading}) {
    return ListTile(
      trailing: FaIcon(
        icon,
        size: 24,
        color: textColor,
      ),
      title: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          title,
          style: TextStyle(fontSize: 17, color: textColor),
        ),
      ),
      leading: leading,
      onTap: tapHandler,
    );
  }

  _resetNotifications() {
    FirebaseFirestore.instance
        .collection("AllNotificationsNumber")
        .doc(_username)
        .update({"number": 0});
  }

  _OverallNumberOfNotifications() {
    int tmp = 0;

    FirebaseFirestore.instance
        .collection("AllNotificationsNumber")
        .doc(_username)
        .get()
        .then((value) {
      tmp = value['number'];
    });

    subscribedrooms.forEach((element) {
      int id = element['roomId'];
      //print(element['roomId']);
      FirebaseFirestore.instance
          .collection("ChatGroups")
          .doc('$id')
          .get()
          .then((value) {
        setState(() {
          //print(value.docs[i]['notifications_number']);
          String t = value['notifications_number'].toString();
          int tt = int.parse(t);
          tmp = tmp + tt;
          FirebaseFirestore.instance
              .collection("AllNotificationsNumber")
              .doc(_username)
              .update({"number": tmp});
        });
      });
    });

    //return tmp.toString();
    //print(tmp);
  }

  @override
  Widget build(BuildContext context) {
    //theme
    final theme = Theme.of(context);
    //MediaQuery
    final mediaQuery = MediaQuery.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(35),
        bottomLeft: Radius.circular(170),
      ),
      child: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: mediaQuery.size.height * 0.12,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerRight,
              color: theme.accentColor,
              child: Container(
                padding: EdgeInsets.all(3),
                child: Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Container(
                            child: Column(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.fullName,
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  _username,
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(
                                  UserProfileScreen.routeName);
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                  currentUser.userAvatar ?? _defaultAvatarURL),
                            ),
                          )
                        ],
                      ),
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("AllNotificationsNumber")
                          .doc(_username)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Text(""),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text(""),
                          );
                        } else
                          return InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(UserGroupsScreen.routeName);

                              FirebaseFirestore.instance
                                  .collection("AllNotificationsNumber")
                                  .doc(_username)
                                  .update({"number": 0});
                            },
                            child: CustomIcon(
                              child: Icon(
                                Icons.message_sharp,
                                color: theme.primaryColor,
                              ),
                              value: snapshot.data['number'].toString(),
                            ),
                          );
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            buildListTile(
              'الرئيسية',
              FontAwesomeIcons.home,
              () {
                Navigator.of(context)
                    .pushReplacementNamed(HomeScreen.routeName);
              },
              theme.primaryColor,
            ),
            buildListTile(
              'الملف الشخصي',
              FontAwesomeIcons.userAlt,
              _toogleProfileDropDown,
              theme.primaryColor,
              leading: Icon(
                _isProfileDropDownDropped
                    ? FontAwesomeIcons.chevronDown
                    : FontAwesomeIcons.chevronLeft,
                size: 18,
                color: theme.primaryColor,
              ),
            ),
            if (_isProfileDropDownDropped)
              Transform.scale(
                scale: 0.9,
                child: SizedBox(
                  width: 225,
                  child: Column(
                    children: [
                      buildListTile(
                          'قائمة المعارف', FontAwesomeIcons.userFriends, () {
                        Navigator.of(context).pushReplacementNamed(
                          UserProfileScreen.routeName,
                          arguments: ProfileSelectedSection.contactsSection,
                        );
                      }, theme.primaryColorLight),
                      buildListTile('الإعدادات', Icons.settings, () {
                        Navigator.of(context).pushReplacementNamed(
                          UserProfileScreen.routeName,
                          arguments: ProfileSelectedSection.settingsSecion,
                        );
                      }, theme.primaryColorLight),
                    ],
                  ),
                ),
              ),
            buildListTile(
              'النشاط',
              FontAwesomeIcons.feather,
              _toogleActivityDropDown,
              theme.primaryColor,
              leading: Icon(
                _isActivityDropDownDropped
                    ? FontAwesomeIcons.chevronDown
                    : FontAwesomeIcons.chevronLeft,
                size: 18,
                color: theme.primaryColor,
              ),
            ),
            if (_isActivityDropDownDropped)
              Transform.scale(
                scale: 0.9,
                child: SizedBox(
                  width: 225,
                  child: Column(
                    children: [
                      buildListTile('احصائيات القراءة', FontAwesomeIcons.book,
                          () {
                        Navigator.of(context).pushReplacementNamed(
                            ReadingsStatisticsScreen.routeName);
                      }, theme.primaryColorLight),
                      buildListTile('المفضلة', FontAwesomeIcons.solidHeart, () {
                        Navigator.of(context)
                            .pushReplacementNamed(FavouritesScreen.routeName);
                      }, theme.primaryColorLight),
                      buildListTile('المراجعات والتقييم', Icons.rate_review,
                          () {
                        Navigator.of(context).pushReplacementNamed(
                            CommentsRatingsScreen.routeName);
                      }, theme.primaryColorLight),
                    ],
                  ),
                ),
              ),
            buildListTile(
              'غرف القراءة',
              FontAwesomeIcons.bookReader,
              _toogleRoomsDropDown,
              theme.primaryColor,
              leading: Icon(
                _isRoomsDropDownDropped
                    ? FontAwesomeIcons.chevronDown
                    : FontAwesomeIcons.chevronLeft,
                size: 18,
                color: theme.primaryColor,
              ),
            ),
            if (_isRoomsDropDownDropped)
              Transform.scale(
                scale: 0.9,
                child: SizedBox(
                  width: 225,
                  child: Column(
                    children: [
                      buildListTile(
                          'مجموعات القراءة', FontAwesomeIcons.bookOpen, () {
                        Navigator.of(context)
                            .pushReplacementNamed(UserGroupsScreen.routeName);
                      }, theme.primaryColorLight),
                      buildListTile('دعوات الإنضمام', FontAwesomeIcons.envelope,
                          () {
                        Navigator.of(context)
                            .pushReplacementNamed(UserInvitesScreen.routeName);
                      }, theme.primaryColorLight),
                    ],
                  ),
                ),
              ),
            buildListTile('قائمة المتصدرين', FontAwesomeIcons.flipboard, () {
              // Navigator.of(context)
              //     .pushReplacementNamed(UserInvitesScreen.routeName);
              Navigator.of(context)
                  .pushReplacementNamed(LeaderboardScreen.routeName);
            }, theme.primaryColor),
            buildListTile('قائمة المكافئات', FontAwesomeIcons.gift, () {
              Navigator.of(context)
                  .pushReplacementNamed(UserRewardsScreen.routeName);
            }, theme.primaryColor),
            buildListTile('الأسئلة الشائعة', FontAwesomeIcons.questionCircle,
                () {
              Navigator.of(context).pushReplacementNamed(FAQScreen.routeName);
            }, theme.primaryColor),
            Expanded(child: SizedBox()),
            Consumer<ThemeNotifier>(
              builder: (ctx, notifier, child) {
                return buildListTile(
                  'تسجيل الخروج',
                  Icons.logout,
                  () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('loggedIn', false);
                    notifier.setTheme(Themes.defaultTheme['themeData']);
                    Navigator.of(context)
                        .pushReplacementNamed(LogInSignUpScreen.routeName);
                  },
                  theme.primaryColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
