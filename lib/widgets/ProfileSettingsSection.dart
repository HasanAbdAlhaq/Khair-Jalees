import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/models/Themes.dart';
import 'package:grad_project/providers/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_actions.dart';
import '../models/User.dart';
import '../screens/ThemeStoreScreen.dart';

class ProfileSettingsSection extends StatefulWidget {
  final User profileOwner;
  final Function showChangePasswordModalFunction;

  ProfileSettingsSection(
      {this.profileOwner, this.showChangePasswordModalFunction});
  @override
  _ProfileSettingsSectionState createState() => _ProfileSettingsSectionState();
}

class _ProfileSettingsSectionState extends State<ProfileSettingsSection> {
  List<Map<String, Object>> themesCollection = [
    Themes.defaultTheme,
    Themes.secondTheme,
    Themes.thirdTheme,
  ];
  List<int> myCollection = [2];

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUsername = prefs.getString('username');
    List<Map<String, dynamic>> listOfThemes =
        await UserActions.getUserThemes(currentUsername);
    setState(() {
      myCollection = listOfThemes.map((e) => e['themeId'] as int).toList();
    });
  }

  void _setTheme(int themeId) {
    widget.profileOwner.themeId = themeId;
    UserActions.updateUser(widget.profileOwner);
  }

  Container _buildSingleColorPreview(Color color) {
    return Container(
      height: 30,
      width: 30,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    );
  }

  List get themesChoices {
    List choices = themesCollection
        .where((theme) =>
            myCollection.indexWhere((id) => id == theme['themeId']) != -1)
        .map(_buildDropdownMenuItem)
        .toList();
    choices.add(_buildThemeStoreChoice());
    return choices;
  }

  void _chosingTheme(dynamic theme, ThemeNotifier notifier) {
    if (theme == 'ThemeStore')
      Navigator.of(context).pushNamed(ThemeStoreScreen.routeName);
    else {
      notifier.setTheme(theme['themeData']);
      _setTheme(theme['themeId']);
    }
  }

  DropdownMenuItem _buildThemeStoreChoice() {
    return DropdownMenuItem(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: Text(
                  'الذهاب إلى متجر السمات',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      value: 'ThemeStore',
    );
  }

  DropdownMenuItem _buildDropdownMenuItem(Map<String, Object> themeMap) {
    ThemeData mainTheme = themeMap['themeData'];
    return DropdownMenuItem(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildSingleColorPreview(mainTheme.primaryColor),
                  _buildSingleColorPreview(mainTheme.primaryColorLight),
                  _buildSingleColorPreview(mainTheme.accentColor),
                ],
              ),
              Text(
                themeMap['themeName'],
                style: TextStyle(
                  color: mainTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Divider(
            color: mainTheme.primaryColor,
            thickness: 1,
          ),
        ],
      ),
      value: themeMap,
    );
  }

  Widget _buildSettingsListTile({
    ThemeData theme,
    String text,
    IconData icon,
    bool switchValue,
    Function switchHandler,
  }) {
    return ListTile(
      trailing: Icon(
        icon,
        color: theme.primaryColorLight,
      ),
      leading: Transform.scale(
        scale: 1.125,
        child: Switch(
          activeColor: theme.primaryColor,
          value: switchValue,
          onChanged: switchHandler,
        ),
      ),
      title: Container(
        padding: EdgeInsets.only(right: 10),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 20,
            color: theme.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final spaceavaialable = mediaQuery.size.height - 110;
    return Container(
      color: theme.scaffoldBackgroundColor,
      height: spaceavaialable * 0.6,
      width: mediaQuery.size.width * 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Consumer<ThemeNotifier>(builder: (context, notifier, child) {
            return SizedBox(
              width: 310,
              child: DropdownButton(
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(
                  FontAwesomeIcons.palette,
                  color: theme.primaryColorLight,
                ),
                hint: SizedBox(
                  width: 260,
                  child: Text(
                    'السمة',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                items: themesChoices,
                onChanged: (theme) {
                  _chosingTheme(theme, notifier);
                },
              ),
            );
          }),
          _buildSettingsListTile(
              theme: theme,
              text: 'تشغيل الإشعارات',
              icon: FontAwesomeIcons.solidBell,
              switchValue: widget.profileOwner.notificationOn,
              switchHandler: (value) {
                setState(() {
                  widget.profileOwner.notificationOn = value;
                  UserActions.setNotificationStatus(
                      widget.profileOwner.username, value);
                });
              }),
          _buildSettingsListTile(
              theme: theme,
              text: 'إظهار الدولة',
              icon: FontAwesomeIcons.solidFlag,
              switchValue: widget.profileOwner.showCountry,
              switchHandler: (value) {
                setState(() {
                  widget.profileOwner.showCountry = value;
                  UserActions.setShowCountryStatus(
                      widget.profileOwner.username, value);
                });
              }),
          _buildSettingsListTile(
              theme: theme,
              text: 'إظهار الإحصائيات',
              icon: FontAwesomeIcons.flipboard,
              switchValue: widget.profileOwner.showDetails,
              switchHandler: (value) {
                setState(() {
                  widget.profileOwner.showDetails = value;
                  UserActions.setShowDetails(
                      widget.profileOwner.username, value);
                });
              }),
          GestureDetector(
            onTap: widget.showChangePasswordModalFunction,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'تغيير كلمة المرور',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 15),
                Icon(
                  FontAwesomeIcons.lock,
                  color: theme.primaryColorLight,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
