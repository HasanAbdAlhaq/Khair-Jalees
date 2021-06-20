import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/models/User.dart';
import 'package:grad_project/widgets/CustomSnackbar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';

// Database
import '../database/user_actions.dart';

class MemberDetailsModal extends StatefulWidget {
  final String wantedUsername;

  MemberDetailsModal({this.wantedUsername});

  @override
  _MemberDetailsModalState createState() => _MemberDetailsModalState();
}

class _MemberDetailsModalState extends State<MemberDetailsModal> {
  final _defaultAvatarURL = 'https://via.placeholder.com/150/4c064d?text= ';
  User _wantedUser = User(
    email: '',
    fullName: '',
    username: '',
    password: '',
    country: 'PS',
    creationDate: DateTime.now(),
  );
  String _currentUsername = '';
  Map<String, dynamic> detailsMap = {
    'numberOfComments': 0,
    'numberOfFavourites': 0,
    'numberOfRatings': 0,
    'numberOfRooms': 0,
  };
  int numberOfBooksRead = 0;

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUsername = prefs.getString('username');

    UserActions.getUsers(
        where: 'username = ?',
        whereArgs: [widget.wantedUsername]).then((value) {
      setState(() {
        _wantedUser = User.fromMap(value.first);
      });
    });
    UserActions.getUserDatails(widget.wantedUsername).then((value) {
      setState(() {
        this.detailsMap = value;
      });
    });

    UserActions.getNumberOfReadBooks(_currentUsername).then((value) {
      setState(() {
        this.numberOfBooksRead = value;
      });
    });
  }

  void _addUserContact(BuildContext ctx) async {
    final scaffold = ScaffoldMessenger.of(ctx);
    String message = '';
    UserActions.checkContactExist(_currentUsername, _wantedUser.username)
        .then((value) async {
      if (value) {
        message = 'هذا المستخدم موجود في المعارف مسبقاً';
      } else {
        // Update Points
        int points = await UserActions.getUserPoints(_currentUsername);
        int numOfComments =
            await UserActions.getNumberOfContacts(_currentUsername);
        if ((numOfComments + 1) % 5 == 0)
          points += 40;
        else
          points += 15;
        UserActions.updatePoints(_currentUsername, points);
        /////////////////////////////////////////////////////////////////////////
        UserActions.addContact(_currentUsername, _wantedUser.username);
        message = 'تم إضافة هذا المستخدم إلى المعارف';
      }
      scaffold.showSnackBar(CustomSnackBar(message).build(ctx));
    });
  }

  Widget _buildDetailsItem({IconData icon, int value}) {
    return LayoutBuilder(
      builder: (ctx, constraints) => Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              size: 30,
              color: Theme.of(ctx).primaryColorLight,
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Theme.of(ctx).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.primaryColor,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      NetworkImage(_wantedUser.userAvatar ?? _defaultAvatarURL),
                ),
              ),
              if (_wantedUser.username != _currentUsername)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accentColor,
                    ),
                    child: IconButton(
                      color: theme.primaryColor,
                      icon: Icon(FontAwesomeIcons.userPlus),
                      iconSize: 16,
                      onPressed: () => _addUserContact(context),
                    ),
                  ),
                )
            ],
          ),
          left: MediaQuery.of(context).size.width * 0.5 - 60,
          top: -60,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    DateFormat.yMMMd('ar_SA').format(_wantedUser.creationDate),
                    style: TextStyle(fontSize: 18, color: theme.primaryColor),
                  ),
                  SizedBox(),
                  Row(
                    children: [
                      if (_wantedUser.showCountry)
                        Container(
                          width: 30,
                          child: Image.asset(
                            'assets/images/${CountryCode.fromCode(_wantedUser.country).flagUri}',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      SizedBox(width: 15),
                      Text(
                        _wantedUser.gender == 'M' ? 'ذكر' : 'أنثى',
                        style:
                            TextStyle(fontSize: 20, color: theme.primaryColor),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(),
            Column(
              children: <Widget>[
                Text(
                  _wantedUser.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _wantedUser.username,
                  style: TextStyle(fontSize: 20, color: theme.primaryColor),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              height: _wantedUser.showDetails ? 240 : 0,
              child: _wantedUser.showDetails
                  ? GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 50,
                      ),
                      children: <Widget>[
                        _buildDetailsItem(
                            icon: FontAwesomeIcons.users,
                            value: detailsMap['numberOfRooms']),
                        _buildDetailsItem(
                            icon: FontAwesomeIcons.medal, value: 12),
                        _buildDetailsItem(
                            icon: FontAwesomeIcons.book,
                            value: numberOfBooksRead),
                        _buildDetailsItem(
                            icon: FontAwesomeIcons.solidStar,
                            value: detailsMap['numberOfRatings']),
                        _buildDetailsItem(
                            icon: FontAwesomeIcons.solidCommentAlt,
                            value: detailsMap['numberOfComments']),
                        _buildDetailsItem(
                            icon: FontAwesomeIcons.solidHeart,
                            value: detailsMap['numberOfFavourites']),
                      ],
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ],
    );
  }
}
