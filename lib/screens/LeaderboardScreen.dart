//Flutter
import 'package:flutter/material.dart';
import 'package:grad_project/database/user_actions.dart';

//Screens

//Widgets
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomDrawer.dart';
import '../widgets/CustomPageLabel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/RoomMember.dart';

class LeaderboardScreen extends StatefulWidget {
  //Constants
  static const routeName = '/LeaderBoard-Screen';
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String defaultAvatar =
      'https://pickaface.net/gallery/avatar/unr_random_180410_1905_z1exb.png';
  List<Map<String, dynamic>> leaderBoardUsers = [];

  initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    UserActions.getLeaderBoardUsers().then((value) {
      setState(() {
        leaderBoardUsers = value;
      });
      print(leaderBoardUsers);
    });
  }

  Widget _buildCompletionStar() {
    return Positioned(
      top: 103,
      right: 45,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 15,
        child: Icon(
          FontAwesomeIcons.crown,
          color: Theme.of(context).accentColor,
          size: 15,
        ),
      ),
    );
  }

  Widget _buildOrder(int pos, bool isfirst) {
    return Positioned(
      top: -10,
      right: isfirst ? 47 : 37,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 13,
        child: Text(
          pos.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Build MemberItem
  Widget _buildMemberItem(
      Map<String, dynamic> member, int position, bool isfirst) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: isfirst ? 60 : 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: CircleAvatar(
                    radius: isfirst ? 55 : 47,
                    backgroundColor: Theme.of(context).primaryColorLight,
                    backgroundImage:
                        NetworkImage(member['userAvatar'] ?? defaultAvatar),
                  ),
                ),
              ),
              isfirst ? _buildCompletionStar() : SizedBox(),
              _buildOrder(position, isfirst)
            ],
          ),
          SizedBox(height: 15),
          Column(
            children: [
              Container(
                //color: Colors.white,
                width: 104,
                height: 30,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${member['numberOfBooks']} ' + 'كتب مقروءة',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  //build othermembers
  Widget _buildMembers(Map<String, dynamic> member) {
    return Container(
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
                          member['fullName'],
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' ${member['numberOfBooks']} كتاب مقروء',
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: CircleAvatar(
                    radius: 27,
                    backgroundImage:
                        NetworkImage(member['userAvatar'] ?? defaultAvatar),
                  ),
                )
              ],
            ),
          ),
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
      body: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        CustomPageLabel("قائمة المتصدرين"),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height * 0.30,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // This Line Should Be Index = 2 (When We Have Third User)
                    _buildMemberItem(leaderBoardUsers[1], 3, false),
                    _buildMemberItem(leaderBoardUsers[0], 1, true),
                    _buildMemberItem(leaderBoardUsers[1], 2, false)
                  ],
                ),
              ],
            )),
        Container(
          height: MediaQuery.of(context).size.height * 0.47,
          child: ListView.builder(
            itemCount:
                leaderBoardUsers.length > 3 ? leaderBoardUsers.length - 3 : 0,
            itemBuilder: (context, index) {
              return Container(
                child: Container(
                  padding: EdgeInsets.only(right: 45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildMembers(leaderBoardUsers[index]),
                      SizedBox(width: 12),
                      Text(
                        '${index + 4}',
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ])),
    );
  }
}
