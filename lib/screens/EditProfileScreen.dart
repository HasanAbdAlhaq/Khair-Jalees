import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/models/User.dart';
import 'package:grad_project/widgets/CustomButton.dart';
import 'package:grad_project/widgets/CustomInputTextField.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/Edit-Profile-Screen';
  final Map profileOwnerMap;
  EditProfileScreen({this.profileOwnerMap});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _defaultAvatarURL = 'https://via.placeholder.com/150/4c064d?text= ';
  bool isImageChanged = false;
  User profileOwner = User(
    email: '',
    username: '',
    password: '',
    fullName: '',
    creationDate: DateTime.now(),
  );

  String _newName = '';
  String _newEmail = '';
  String _newCountry = '';
  String _newGender = '';

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image Selected');
      }
    });
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  Future<String> _uploadImage() async {
    String uploadurl = "http://10.0.2.2/Sandbox/image_upload.php";
    List<int> imageBytes = _image.readAsBytesSync();
    String baseimage = base64Encode(imageBytes);
    String uniqueImageID = Uuid().v4();
    var response = await http.post(uploadurl, body: {
      'image': baseimage,
      'name': '${this.profileOwner.username}_$uniqueImageID',
    });
    print(json.decode(response.body));
    _clearImage();
    this.isImageChanged = true;
    return uniqueImageID;
  }

  int _radioValue = 0;
  void _setUp() {
    setState(() {
      profileOwner = User.fromMap(widget.profileOwnerMap);
      _radioValue = profileOwner.gender == 'M' ? 0 : 1;
      _newCountry = profileOwner.country;
      _newGender = profileOwner.gender;
    });
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          _newGender = 'M';
          break;
        case 1:
          _newGender = 'F';
          break;
      }
    });
  }

  Widget _buildNameTextField() {
    return CustomInputTextField(
      label: 'الإسم بالكامل',
      onSaved: (value) => _newName = value,
      validator: (_) {},
      initialValue: profileOwner.fullName,
    );
  }

  Widget _buildEmailTextField() {
    return CustomInputTextField(
      label: 'البريد الإلكتروني',
      onSaved: (value) => _newEmail = value,
      validator: (value) {
        if (!isEmail(value)) return 'البريد الإلكتروني غير صحيح';
        return null;
      },
      initialValue: profileOwner.email,
      keyboardType: TextInputType.emailAddress,
    );
  }

  bool checkForInfoChange() {
    bool isFullNameChanged = profileOwner.fullName == profileOwner.username &&
        _newName != profileOwner.username;
    bool isEmailChanged = _newEmail != profileOwner.email;
    bool isCountryChanged = _newCountry != profileOwner.country;

    return isFullNameChanged ||
        isEmailChanged ||
        isCountryChanged ||
        this.isImageChanged;
  }

  void _updatePoints() async {
    if (!checkForInfoChange()) return;
    // Update Points
    int points = await UserActions.getUserPoints(profileOwner.username);
    points += 100;
    UserActions.updatePoints(profileOwner.username, points);
    /////////////////////////////////////////////////////////////////////////
    this.isImageChanged = false;
  }

  void _formSubmitted() async {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      _updatePoints();

      profileOwner.country = _newCountry;
      profileOwner.gender = _newGender;
      profileOwner.fullName = _newName;
      profileOwner.email = _newEmail;
      if (_image != null) {
        String uniqueImageID = await _uploadImage();
        setState(() {
          profileOwner.userAvatar =
              'http://10.0.2.2/Sandbox/uploads/${profileOwner.username}_$uniqueImageID.jpg';
        });
      }

      UserActions.updateUser(profileOwner);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
              Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: theme.primaryColor,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _image == null
                              ? NetworkImage(
                                  profileOwner.userAvatar ?? _defaultAvatarURL)
                              : FileImage(_image),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: GestureDetector(
                          onTap: _image == null ? getImage : _clearImage,
                          child: CircleAvatar(
                            radius: 20,
                            child: Icon(
                              _image == null ? Icons.camera_alt : Icons.close,
                              color: Theme.of(context).primaryColor,
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildNameTextField(),
                    SizedBox(height: 20),
                    _buildEmailTextField(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CountryCodePicker(
                        favorite: ['+970', 'PS'],
                        initialSelection: profileOwner.country,
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: true,
                        barrierColor: theme.primaryColor.withOpacity(0.3),
                        flagWidth: 40,
                        textStyle: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 20,
                        ),
                        onChanged: (CountryCode code) {
                          setState(() {
                            _newCountry = code.code;
                          });
                        },
                      ),
                      Text(
                        ' : الدولة',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 1,
                            groupValue: _radioValue,
                            onChanged: _handleRadioValueChange,
                            activeColor: theme.primaryColor,
                          ),
                          Text(
                            'أنثى',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 0,
                            groupValue: _radioValue,
                            onChanged: _handleRadioValueChange,
                            activeColor: theme.primaryColor,
                          ),
                          Text(
                            'ذكر',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'الجنس',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              CustomButton(
                text: 'حفظ',
                onPressed: _formSubmitted,
                width: 130,
              )
            ],
          ),
        ),
      ),
    );
  }
}
