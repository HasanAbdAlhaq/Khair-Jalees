//Flutter Packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

//Widgets
import '../widgets/CustomPageLabel.dart';
import '../widgets/CustomSnackbar.dart';

// Modals
import '../modals/AddRoomMemberModal.dart';
import '../modals/GenericModal.dart';
import '../modals/MemberDetailsModal.dart';

// Models
import '../models/RoomMember.dart';

// Database
import '../database/room_actions.dart';

class GroupMembersScreen extends StatefulWidget {
  static const routeName = '/Room-Members-Page';

  final Object arguments;
  int roomId;
  String roomName;
  String title;
  String coverLink;

  GroupMembersScreen({this.arguments}) {
    this.roomId = (arguments as Map<String, dynamic>)['roomId'];
    this.roomName = (arguments as Map<String, dynamic>)['roomName'];
    this.title = (arguments as Map<String, dynamic>)['title'];
    this.coverLink = (arguments as Map<String, dynamic>)['coverLink'];
  }

  @override
  _GroupMembersScreenState createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> members = [];

  bool _isAddNewMemberModalShown = false;
  bool _isMemberDetailsModalShown = false;
  bool _isMemberDetailsShown = false;

  String _memberDetailsModalUsername = '';

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    var listOfMembers = await RoomActions.getRoomMembers(widget.roomId);
    setState(() {
      members = listOfMembers;
    });
  }

  void _showAddNewMemberModal() {
    setState(() {
      _isAddNewMemberModalShown = true;
    });
  }

  void _hideAddNewMemberModal() {
    setState(() {
      _isAddNewMemberModalShown = false;
    });
  }

  void _showMemberDetailsModal(String targetUserame, bool showDetails) {
    setState(() {
      _memberDetailsModalUsername = targetUserame;
      _isMemberDetailsShown = showDetails;
      _isMemberDetailsModalShown = true;
    });
  }

  void _hideMemberDetailsModal() {
    setState(() {
      _isMemberDetailsModalShown = false;
    });
  }

  void _addRoomMember() {
    final context = _scaffoldKey.currentContext;
    if (members.length < 6)
      _showAddNewMemberModal();
    else
      ScaffoldMessenger.of(context)
          .showSnackBar(CustomSnackBar('هذه المجموعة مكتملة').build(context));
  }

  Widget _buildCompletionStar() {
    return Positioned(
      top: 15,
      right: 0,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 15,
        child: Icon(
          FontAwesomeIcons.solidStar,
          color: Theme.of(context).accentColor,
          size: 15,
        ),
      ),
    );
  }

  Widget buildRoomItem(BuildContext ctx) {
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
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                              color: Theme.of(ctx).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.roomName,
                          style: TextStyle(
                              fontSize: 18, color: Theme.of(ctx).accentColor),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(widget.coverLink),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build MemberItem
  Widget _buildMemberItem(RoomMember roomMember) {
    double pagePercentage =
        (roomMember.readPages / roomMember.numberOfPages).floorToDouble();
    print(pagePercentage);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              GestureDetector(
                onTap: () {
                  _showMemberDetailsModal(
                      roomMember.username, roomMember.showDetails);
                },
                child: CircularPercentIndicator(
                  radius: 110.0,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  progressColor: Theme.of(context).primaryColor,
                  lineWidth: 12.5,
                  percent: pagePercentage,
                  center: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage(roomMember.userAvatar),
                    ),
                  ),
                ),
              ),
              pagePercentage == 1 ? _buildCompletionStar() : SizedBox(),
            ],
          ),
          SizedBox(height: 10),
          Column(
            children: [
              Container(
                width: 150,
                height: 30,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    roomMember.fullName,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '%${(pagePercentage * 100).toInt()} :التقدم',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //theme
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          iconTheme: IconThemeData(
            color: theme.accentColor, //change your color here
          ),
          title: buildRoomItem(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                CustomPageLabel('(${members.length}/6) الأعضاء'),
                Container(
                  height: 585,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    children: members
                        .map((e) => _buildMemberItem(RoomMember.formMap(e)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_isAddNewMemberModalShown)
            GenericModal(
              height: 425,
              hideModalFunction: _hideAddNewMemberModal,
              childWidget: AddRoomMemberModal(
                groupid: this.widget.roomId,
                groupname: this.widget.roomName,
              ),
            ),
          if (_isMemberDetailsModalShown)
            GenericModal(
              alignment: Alignment.bottomCenter,
              height: _isMemberDetailsShown ? 400 : 200,
              hideModalFunction: _hideMemberDetailsModal,
              childWidget: MemberDetailsModal(
                  wantedUsername: _memberDetailsModalUsername),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton:
          !(_isAddNewMemberModalShown || _isMemberDetailsModalShown)
              ? FloatingActionButton(
                  onPressed: _addRoomMember,
                  backgroundColor:
                      members.length < 6 ? theme.accentColor : Colors.grey,
                  child: Icon(FontAwesomeIcons.userPlus),
                )
              : null,
    );
  }
}
