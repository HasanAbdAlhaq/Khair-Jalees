// Flutter Packages
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/screens/GroupChatScreen.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import './BookPdfScreen.dart';
import './GroupMembersScreen.dart';
import './UserGroupsScreen.dart';

// Widgets
import '../widgets/CustomDrawer.dart';
import '../widgets/CustomPageLabel.dart';
import '../widgets/CustomAppBar.dart';

// Models
import '../models/SingleRoom.dart';

// Database
import '../database/room_actions.dart';

class SingleRoomScreen extends StatefulWidget {
  static const routeName = '/Single-Room-Screen';
  final int roomId;

  SingleRoomScreen({this.roomId});

  @override
  _SingleRoomScreenState createState() => _SingleRoomScreenState();
}

class _SingleRoomScreenState extends State<SingleRoomScreen> {
  String _username = '';
  SingleRoom currentRoom = new SingleRoom(
    startDate: DateTime.now(),
    endDate: DateTime.now(),
  );

  String formatDateWithTime(DateTime date) {
    String actualDay = 'اليوم  ${DateFormat.yMd('ar_SA').format(date)}';
    String actualTime = 'الساعة  ${DateFormat.jm('ar_SA').format(date)}';
    return '$actualDay    $actualTime';
  }

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  Future _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    await initializeDateFormatting("ar_SA", null);
    var map = await RoomActions.getSingleRoom(widget.roomId);
    setState(() {
      currentRoom = SingleRoom.fromMap(map);
    });
  }

  void _deleteSingleRoom(BuildContext ctx) async {
    if (_username == currentRoom.creatorId) {
      showDialog(
          context: ctx,
          builder: (_) => AlertDialog(
                title: Text(
                  'حذف مجموعة',
                  textAlign: TextAlign.right,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                content: Text(
                  'عند حذف مجموعة قراءة لا يمكن استرجاعها مجددا .' +
                      'هل تود الاستمرار في حذف المجموعة ؟',
                  textAlign: TextAlign.right,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'حذف',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              )).then((value) {
        if (value) {
          RoomActions.deleteRoom(currentRoom.id);
          Navigator.of(context)
              .pushReplacementNamed(UserGroupsScreen.routeName);
        }
      });
    } else {
      showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          title: Text(
            'ليس لك الحق في حذف هذه المجموعة',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('حسناً',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                  )),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDataRow(ThemeData theme, String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(width: 20),
          Icon(
            icon,
            color: theme.primaryColorLight,
            size: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialButton({Function onPressed, IconData icon}) {
    return MaterialButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Virables
    final theme = Theme.of(context);
    // Actual Build Method
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: CustomDrawer(),
      appBar: CustomAppBar(),
      body: Column(
        children: [
          CustomPageLabel(currentRoom.roomName),
          Padding(
            padding: const EdgeInsets.only(right: 40, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildDataRow(theme, currentRoom.title, FontAwesomeIcons.book),
                _buildDataRow(theme, currentRoom.author, FontAwesomeIcons.pen),
                _buildDataRow(
                    theme, currentRoom.creatorId, FontAwesomeIcons.userShield),
                _buildDataRow(theme, formatDateWithTime(currentRoom.startDate),
                    FontAwesomeIcons.hourglassStart),
                _buildDataRow(theme, formatDateWithTime(currentRoom.endDate),
                    FontAwesomeIcons.hourglassEnd),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        SizedBox(width: 40),
                        Transform.scale(
                          scale: 1.25,
                          child: Switch(
                            value: currentRoom.isNotificationOn,
                            onChanged: (value) {
                              setState(() {
                                currentRoom.isNotificationOn = value;
                                RoomActions.setNotification(
                                    _username, currentRoom.id, value);
                              });
                            },
                            activeColor: theme.primaryColor,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'الإشعارات',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 40),
                        Icon(
                          FontAwesomeIcons.solidBell,
                          size: 30,
                          color: theme.primaryColorLight,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (!currentRoom.isOpen)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'هذه الغرفة مغلقة الآن، لا يمكن قراءة الكتاب أو الدخول للمحادثة الخاصة بالغرفة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!currentRoom.isOpen) return;
          Navigator.of(context)
              .pushNamed(GroupChatScreen.routeName, arguments: {
            'roomId': currentRoom.id,
            'roomName': currentRoom.roomName,
            'title': currentRoom.title,
            'coverLink': currentRoom.coverLink,
          });
        },
        child: Icon(
          FontAwesomeIcons.solidComments,
          color: theme.accentColor,
          size: 25,
        ),
        backgroundColor: theme.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: theme.primaryColor,
        notchMargin: 5,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _buildMaterialButton(
                    onPressed: () => _deleteSingleRoom(context),
                    icon: FontAwesomeIcons.solidTrashAlt,
                  ),
                  _buildMaterialButton(
                      onPressed: () {
                        if (!currentRoom.isOpen) return;
                        Navigator.of(context).pushNamed(
                          GroupMembersScreen.routeName,
                          arguments: {
                            'roomId': currentRoom.id,
                            'roomName': currentRoom.roomName,
                            'title': currentRoom.title,
                            'coverLink': currentRoom.coverLink,
                          },
                        );
                      },
                      icon: FontAwesomeIcons.users),
                ],
              ),
              Row(
                children: <Widget>[
                  _buildMaterialButton(
                    onPressed: () {
                      if (!currentRoom.isOpen) return;
                      Navigator.of(context).pushNamed(
                        BookPdfScreen.routeName,
                        arguments: {
                          'bookId': currentRoom.bookId,
                          'roomId': currentRoom.id,
                          'roomName': currentRoom.roomName,
                          'title': currentRoom.title,
                          'coverLink': currentRoom.coverLink,
                        },
                      );
                    },
                    icon: FontAwesomeIcons.solidFilePdf,
                  ),
                  _buildMaterialButton(
                    onPressed: () {},
                    icon: FontAwesomeIcons.infoCircle,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
