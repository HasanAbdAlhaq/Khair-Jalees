import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/Enums.dart';

class ProfileBottomBar extends StatelessWidget {
  final Function showDeleteAccountModalFunction;
  final Function selectProfileSectionFunction;

  ProfileBottomBar(
      {this.showDeleteAccountModalFunction, this.selectProfileSectionFunction});

  Widget _buildMaterialButton(
      {Function onPressed, IconData icon, Color iconColor}) {
    return MaterialButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: iconColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
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
                  onPressed: showDeleteAccountModalFunction,
                  icon: FontAwesomeIcons.solidTrashAlt,
                  iconColor: theme.accentColor,
                ),
                _buildMaterialButton(
                  onPressed: () {
                    selectProfileSectionFunction(
                        ProfileSelectedSection.settingsSecion);
                  },
                  icon: Icons.settings,
                  iconColor: theme.accentColor,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                _buildMaterialButton(
                  onPressed: () {
                    selectProfileSectionFunction(
                        ProfileSelectedSection.contactsSection);
                  },
                  icon: Icons.contacts,
                  iconColor: theme.accentColor,
                ),
                _buildMaterialButton(
                  onPressed: () {
                    selectProfileSectionFunction(
                        ProfileSelectedSection.infoSection);
                  },
                  icon: FontAwesomeIcons.infoCircle,
                  iconColor: theme.accentColor,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
