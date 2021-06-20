//Flutter
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/modals/DeleteAccountModal.dart';
import 'package:grad_project/modals/GenericModal.dart';
import 'package:grad_project/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modals/ChangePasswordModal.dart';
import 'EditProfileScreen.dart';
import '../widgets/CustomProfileHeader.dart';
import '../widgets/ProfileSettingsSection.dart';
import '../widgets/ProfileContactsSection.dart';
import '../widgets/ProfileInfoSection.dart';
import '../widgets/ProfileBottomBar.dart';

//Widgets
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomDrawer.dart';
import '../models/Enums.dart';

class UserProfileScreen extends StatefulWidget {
  //Constants
  static const routeName = '/User-Profile-Screen';
  final ProfileSelectedSection initiallySelectedSection;
  UserProfileScreen({this.initiallySelectedSection});
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _currentUser = '';
  ProfileSelectedSection _selectedSection;

  User profileOwner = User(
    email: '',
    username: '',
    password: '',
    fullName: '',
    country: 'PS',
    creationDate: DateTime.now(),
  );
  List<Map<String, dynamic>> contacts = [];

  bool _isDeleteAccountModalShown = false;
  bool _isChangePasswordModalShown = false;

  void _showChangePasswordModal() {
    setState(() {
      _isChangePasswordModalShown = true;
    });
  }

  void _hideChangePasswordModal() {
    setState(() {
      _isChangePasswordModalShown = false;
    });
  }

  void _showDeleteAccountModal() {
    setState(() {
      _isDeleteAccountModalShown = true;
    });
  }

  void _hideDeleteAccountModal() {
    setState(() {
      _isDeleteAccountModalShown = false;
    });
  }

  void _selectSection(ProfileSelectedSection value) {
    setState(() {
      _selectedSection = value;
    });
  }

  @override
  void initState() {
    _selectedSection =
        widget.initiallySelectedSection ?? ProfileSelectedSection.infoSection;
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('username');
    var resultUser = await UserActions.getUser(_currentUser);
    var contactsList = await UserActions.getAllContacts(_currentUser);
    setState(() {
      contacts = contactsList.map((e) => Map.of(e)).toList();
      profileOwner = User.fromMap(resultUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: Column(
                  children: [
                    CustomProfileHeader(profileOwner: profileOwner),
                    SizedBox(height: 65),
                    if (_selectedSection ==
                        ProfileSelectedSection.settingsSecion)
                      ProfileSettingsSection(
                        profileOwner: profileOwner,
                        showChangePasswordModalFunction:
                            _showChangePasswordModal,
                      ),
                    if (_selectedSection ==
                        ProfileSelectedSection.contactsSection)
                      ProfileContactsSection(
                        currentUser: _currentUser,
                        contacts: this.contacts,
                      ),
                    if (_selectedSection == ProfileSelectedSection.infoSection)
                      ProfileInfoSection(profileOwner: profileOwner),
                  ],
                ),
              ),
            ),
          ),
          if (_isDeleteAccountModalShown)
            GenericModal(
              hideModalFunction: _hideDeleteAccountModal,
              childWidget: DeleteAccountModal(),
              height: 425,
            ),
          if (_isChangePasswordModalShown)
            GenericModal(
              hideModalFunction: _hideChangePasswordModal,
              childWidget: ChangePasswordModal(),
              height: 475,
            ),
        ],
      ),
      floatingActionButton:
          !(_isDeleteAccountModalShown || _isChangePasswordModalShown)
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(
                          EditProfileScreen.routeName,
                          arguments: profileOwner.toMap(),
                        )
                        .then((_) => _setUp());
                  },
                  child: Icon(
                    FontAwesomeIcons.solidEdit,
                    color: theme.accentColor,
                    size: 22,
                  ),
                  backgroundColor: theme.primaryColor,
                )
              : SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:
          !(_isDeleteAccountModalShown || _isChangePasswordModalShown)
              ? ProfileBottomBar(
                  showDeleteAccountModalFunction: _showDeleteAccountModal,
                  selectProfileSectionFunction: _selectSection,
                )
              : SizedBox(),
    );
  }
}
