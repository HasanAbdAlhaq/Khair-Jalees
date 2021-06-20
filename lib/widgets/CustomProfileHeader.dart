import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../models/User.dart';

class CustomProfileHeader extends StatelessWidget {
  final User profileOwner;
  final _defaultAvatarURL = 'https://via.placeholder.com/150/4c064d?text= ';

  CustomProfileHeader({this.profileOwner});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final spaceavaialable = mediaQuery.size.height - 110;
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                ),
                color: theme.primaryColor),
            height: spaceavaialable * 0.20,
            width: mediaQuery.size.width,
          ),
          Positioned(
            right: 22.0,
            top: 88.0,
            child: Container(
              width: mediaQuery.size.width * 0.55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'منذ  ${intl.DateFormat.yMMMd('ar_SA').format(profileOwner.creationDate)}',
                        style: TextStyle(
                            color: theme.scaffoldBackgroundColor, fontSize: 18),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "نقاط ${profileOwner.points}",
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                        profileOwner.userAvatar ?? _defaultAvatarURL),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 35,
            height: mediaQuery.size.height * 0.1,
            width: mediaQuery.size.width * 0.8,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      profileOwner.fullName,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Text(
                    profileOwner.username,
                    style: TextStyle(
                      color: theme.scaffoldBackgroundColor,
                      fontSize: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]);
  }
}
