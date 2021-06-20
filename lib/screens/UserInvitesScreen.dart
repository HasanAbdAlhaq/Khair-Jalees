//Flutter
import 'package:flutter/material.dart';
import '../models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_actions.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomDrawer.dart';
import '../widgets/CustomPageLabel.dart';
import '../database/room_actions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class UserInvitesScreen extends StatefulWidget {
  //Constants
  static const routeName = '/UserInvites-Page';
  @override
  _UserInvitesScreenState createState() => _UserInvitesScreenState();
}

class _UserInvitesScreenState extends State<UserInvitesScreen> {
  String _currentUser = '';
  User currUser = User(
    email: '',
    username: '',
    password: '',
    fullName: '',
    country: 'PS',
    creationDate: DateTime.now(),
  );

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('username');
    var resultUser = await UserActions.getUser(_currentUser);
    setState(() {
      currUser = User.fromMap(resultUser);
    });
  }

  void _updatePoints(String username) async {
    int points = await UserActions.getUserPoints(username);
    points += 20;
    UserActions.updatePoints(username, points);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final spaceavaialable = mediaQuery.size.height - 60;
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Center(
          child: Column(
        children: [
          CustomPageLabel("طلبات الانضام لديك"),
          Container(
              color: theme.scaffoldBackgroundColor,
              height: spaceavaialable * 0.85,
              width: mediaQuery.size.width * 0.85,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Invitation_Info/${currUser.username}/invites")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularPercentIndicator(
                        radius: 50,
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        "......لا يوجد طلبات حتى الآن",
                        style:
                            TextStyle(color: theme.primaryColor, fontSize: 30),
                      ),
                    );
                  }
                  final document = snapshot.data.docs;
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: theme.primaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 70,
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    FirebaseFirestore.instance
                                        .collection(
                                            "Invitation_Info/${currUser.username}/invites")
                                        .where("groupId",
                                            isEqualTo: document[index]
                                                ['groupId'])
                                        .get()
                                        .then((value) {
                                      value.docs.forEach((element) {
                                        FirebaseFirestore.instance
                                            .collection(
                                                "Invitation_Info/${currUser.username}/invites")
                                            .doc(element.id)
                                            .delete();
                                      });
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                                InkWell(
                                    onTap: () {
                                      Map<String, dynamic> map = {
                                        "roomId": document[index]['groupId'],
                                        "userId": currUser.username,
                                        "isNotificationOn": 1,
                                        "readPages": 0
                                      };
                                      print(document[index]['groupId']);
                                      print(map);
                                      RoomActions.addRoomMember(map);

                                      // Update Points
                                      _updatePoints(
                                          document[index]['senderId']);
                                      /////////////////

                                      FirebaseFirestore.instance
                                          .collection(
                                              "Invitation_Info/${currUser.username}/invites")
                                          .where("groupId",
                                              isEqualTo: document[index]
                                                  ['groupId'])
                                          .get()
                                          .then((value) {
                                        value.docs.forEach((element) {
                                          FirebaseFirestore.instance
                                              .collection(
                                                  "Invitation_Info/${currUser.username}/invites")
                                              .doc(element.id)
                                              .delete();
                                        });
                                      });
                                    },
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 30,
                                    )),
                              ],
                            ),
                          ),
                          title: Text(
                            // getroomname(int.parse(document[index]['groupId'])),
                            document[index]['groupName'],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            "${document[index]['senderId']} :بواسطة",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: theme.primaryColorLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )),
        ],
      )),
    );
  }
}
