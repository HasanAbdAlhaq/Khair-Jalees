import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/User.dart';

import 'package:country_code_picker/country_code_picker.dart';

class ProfileInfoSection extends StatelessWidget {
  final User profileOwner;

  ProfileInfoSection({this.profileOwner});

  Widget _buildinfo({BuildContext context, String title, IconData icondata}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: FaIcon(
            icondata,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final spaceavaialable = mediaQuery.size.height - 110;

    return Container(
      height: spaceavaialable * 0.6,
      width: mediaQuery.size.width * 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildinfo(
            context: context,
            title: profileOwner.fullName,
            icondata: FontAwesomeIcons.solidUser,
          ),
          _buildinfo(
              context: context,
              title: profileOwner.email,
              icondata: Icons.email),
          _buildinfo(
            context: context,
            title: "**************",
            icondata: FontAwesomeIcons.lock,
          ),
          _buildinfo(
              context: context,
              title: CountryCode.fromCode(profileOwner.country).name,
              icondata: FontAwesomeIcons.solidFlag),
          _buildinfo(
            context: context,
            title: profileOwner.gender == 'M' ? 'ذكر' : 'أنثى',
            icondata: profileOwner.gender == 'M'
                ? FontAwesomeIcons.male
                : FontAwesomeIcons.female,
          ),
        ],
      ),
    );
  }
}
