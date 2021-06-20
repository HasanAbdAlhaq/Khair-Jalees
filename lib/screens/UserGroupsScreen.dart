//Flutter Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/screens/GroupChatScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as d; //for date format
import 'package:intl/date_symbol_data_local.dart';

// Screens
import '../screens/SingleRoomScreen.dart';

//Custom Widgets
import '../widgets/CustomDrawer.dart';
import '../widgets/CustomPageLabel.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomIcon.dart';

//Modals
import 'package:grad_project/modals/GenericModal.dart';
import 'package:grad_project/modals/AddNewRoomModal.dart';

// Database
import '../database/room_actions.dart';

//bool notification_checker = false;

class UserGroupsScreen extends StatefulWidget {
  //Constants
  static const routeName = '/UserGroups-Page';

  @override
  _UserGroupsScreenState createState() => _UserGroupsScreenState();
}

class _UserGroupsScreenState extends State<UserGroupsScreen> {
  bool _isModalShown = false;
  String _username = '';
  List<Map<String, dynamic>> listOfRooms = [];
  int roomid;

  @override
  void initState() {
    _setUp();
    super.initState();
    //print(roomid);
  }

  Future _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    await initializeDateFormatting("ar_SA", null);
    var list = await RoomActions.getAllRooms(_username);
    setState(() {
      listOfRooms = list;
    });

    // Close Rooms
    await RoomActions.closeRooms();
  }

  // Modal Control Methods
  void _showModal() {
    setState(() {
      this._isModalShown = true;
    });
  }

  void _hideModal() {
    setState(() {
      this._isModalShown = false;
    });
  }

  Widget buildRoomItem(
      {BuildContext ctx,
      int roomId,
      String name,
      String book,
      DateTime date,
      String bookCover,
      int numberOfUsers,
      String roomNotifications}) {
    return InkWell(
      onTap: () {
        Navigator.of(ctx).pushReplacementNamed(SingleRoomScreen.routeName,
            arguments: roomId);

        FirebaseFirestore.instance
            .collection('ChatGroups')
            .doc('$roomId')
            .update({'notifications_number': 0});
        //notification_checker = true;
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: Theme.of(ctx).primaryColor,
            width: 1.3,
          ),
        ),
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                  color: Theme.of(ctx).primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              book,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(ctx).primaryColor),
                            ),
                            Text(
                              "حتى: ${d.DateFormat.yMd('ar_SA').add_jm().format(date)}",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(ctx).primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(bookCover),
                    )
                  ],
                ),
              ),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$numberOfUsers',
                      style: TextStyle(
                        color: Theme.of(ctx).primaryColor,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    CustomIcon(
                        child: FaIcon(
                          FontAwesomeIcons.solidUser,
                          color: Theme.of(ctx).primaryColor.withOpacity(0.7),
                        ),
                        value: roomNotifications)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: CustomDrawer(),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                CustomPageLabel("غرف القراءة الخاصة بي"),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    height: mediaQuery.size.height * 0.75,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("ChatGroups")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: Text('الرجاء الانتظار'));
                          } else
                            return ListView(
                              children: [
                                ...listOfRooms.map((room) {
                                  return buildRoomItem(
                                      ctx: context,
                                      roomId: room['id'],
                                      book: room['title'],
                                      name: room['roomName'],
                                      date: DateTime.parse(room['endDate']),
                                      numberOfUsers: room['usersCount'],
                                      bookCover: room['coverLink'],
                                      roomNotifications: snapshot
                                          .data
                                          .docs[room['id'] - 1]
                                              ['notifications_number']
                                          .toString());
                                }),
                              ],
                            );
                        }),
                  ),
                ),
              ],
            ),
            if (_isModalShown)
              GenericModal(
                height: 450.0,
                hideModalFunction: this._hideModal,
                childWidget: AddNewRoomModal(),
              ),
          ],
        ),
      ),
      floatingActionButton: !_isModalShown
          ? FloatingActionButton.extended(
              onPressed: _showModal,
              icon: Icon(
                Icons.add,
                color: theme.primaryColor,
                size: 25,
              ),
              label: Text(
                "إنشاء غرفة",
                style: TextStyle(color: theme.primaryColor, fontSize: 18),
              ),
            )
          : null,
    );
  }
}
