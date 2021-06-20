import 'package:flutter/material.dart';
import 'package:grad_project/widgets/CustomInputTextField.dart';
import '../widgets/CustomLabel.dart';
import '../widgets/CustomButton.dart';
import '../database/user_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import '../widgets/CustomSnackbar.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

class ChangePasswordModal extends StatefulWidget {
  @override
  _ChangePasswordModalState createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _currentUser = '';
  String _oldPassword = '';
  String _newPassword = '';
  bool _isFromValid = true;

  User profileOwner = User(
    email: '',
    username: '',
    password: '',
    fullName: '',
    creationDate: DateTime.now(),
  );

  @override
  initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('username');
    var resultUser = await UserActions.getUser(_currentUser);
    setState(() {
      profileOwner = User.fromMap(resultUser);
    });
  }

  Widget _buildOldPassowrdTextField() {
    return CustomInputTextField(
      label: 'كلمة المرور الحالية',
      onSaved: (value) => _oldPassword = value,
      validator: (String value) {
        if (value.isEmpty) return 'هذا الحقل فارغ';
      },
      obscureText: true,
    );
  }

  Widget _buildNewPassowrdTextField() {
    return CustomInputTextField(
      label: 'كلمة المرور الجديدة',
      onSaved: (value) => _newPassword = value,
      validator: (String value) {
        if (value.isEmpty) return 'هذا الحقل فارغ';
        if (value.length < 8) return 'كلمة المرور يجب أن تكون أكثر من 8 خانات';
      },
      obscureText: true,
    );
  }

  Widget _buildConfirmedPassowrdTextField() {
    return CustomInputTextField(
      label: 'تأكيد كلمة المرور الجديدة',
      onSaved: (_) {},
      validator: (String value) {
        if (value.isEmpty) return 'هذا الحقل فارغ';
        if (value != _newPassword) return 'كلمة المرور غير متطابقة';
      },
      obscureText: true,
    );
  }

  void _formSubmitted(BuildContext context) {
    final form = _formKey.currentState;
    final scaffold = ScaffoldMessenger.of(context);
    form.save();
    setState(() {
      _isFromValid = form.validate();
    });
    if (_isFromValid) {
      String hashedPassword =
          sha512.convert(utf8.encode(_oldPassword)).toString();
      String snackBarMessage = '';
      if (hashedPassword == profileOwner.password) {
        hashedPassword = sha512.convert(utf8.encode(_newPassword)).toString();
        profileOwner.password = hashedPassword;
        UserActions.updateUser(profileOwner);
        snackBarMessage = 'تم تغيير كلمة المرور بنجاح';
      } else {
        snackBarMessage = 'كلمة المرور الحالية غير صحيحة';
      }
      scaffold.showSnackBar(CustomSnackBar(snackBarMessage).build(context));
      form.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 160,
          child: CustomLabel('تغيير كلمة المرور'),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: _isFromValid ? 40 : 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildOldPassowrdTextField(),
                SizedBox(height: _isFromValid ? 10 : 0),
                _buildNewPassowrdTextField(),
                SizedBox(height: _isFromValid ? 10 : 0),
                _buildConfirmedPassowrdTextField(),
                SizedBox(height: 20),
                CustomButton(
                  text: 'حفظ',
                  width: 150,
                  onPressed: () {
                    _formSubmitted(context);
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
