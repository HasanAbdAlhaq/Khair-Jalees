import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/models/User.dart';
import 'package:grad_project/widgets/CustomButton.dart';
import 'package:grad_project/widgets/CustomInputTextField.dart';
import 'package:grad_project/widgets/CustomLabel.dart';
import 'package:grad_project/widgets/CustomSnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountModal extends StatefulWidget {
  @override
  _DeleteAccountModalState createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _providedPassword = '';
  String _currentUser = '';
  User profileOwner = User(
    email: '',
    username: '',
    password: '',
    fullName: '',
    creationDate: DateTime.now(),
  );

  @override
  void initState() {
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

  void _formSubmitted(BuildContext ctx) async {
    final form = _formKey.currentState;
    final scaffold = ScaffoldMessenger.of(ctx);
    form.save();

    String _hashedPassword =
        sha512.convert(utf8.encode(_providedPassword)).toString();
    if (_hashedPassword == profileOwner.password) {
      // Delete The Account
      // UserActions.deleteUser(profileOwner);

      // Log Out
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setBool('loggedIn', false);

      // Go Out Of The Application
      // Navigator.of(ctx).pushReplacementNamed(LogInSignUpScreen.routeName);
    } else {
      form.reset();
      scaffold.showSnackBar(CustomSnackBar('كلمة المرور غير صحيحة').build(ctx));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: 135,
          child: CustomLabel('حذف الحساب'),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'إن كنت متأكداً من أنك تريد حذف حسابك ، الرجاء كتابة كلمة المرور الخاصة بك هنا',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        Form(
            key: _formKey,
            child: Column(
              children: [
                CustomInputTextField(
                  label: 'كلمة المرور',
                  onSaved: (value) {
                    _providedPassword = value;
                  },
                  validator: (_) {},
                  obscureText: true,
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: 'حذف',
                  onPressed: () {
                    _formSubmitted(context);
                  },
                  width: 120,
                ),
              ],
            )),
      ],
    );
  }
}
