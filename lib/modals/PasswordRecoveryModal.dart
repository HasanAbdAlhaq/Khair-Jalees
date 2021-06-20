// Dart Packages
import 'dart:convert';

// Flutter Packages
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:validators/validators.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

// Custom Widgets
import '../widgets/CustomButton.dart';
import '../widgets/CustomInputTextField.dart';
import '../widgets/CustomLabel.dart';
import '../widgets/CustomSnackbar.dart';

// model
import '../models/User.dart';

// Database
import '../database/user_actions.dart';

class PasswordRecoveryModal extends StatefulWidget {
  @override
  _PasswordRecoveryModalState createState() => _PasswordRecoveryModalState();
}

class _PasswordRecoveryModalState extends State<PasswordRecoveryModal> {
  // Properties
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userEmail = "";

  // Email And Password Of The Application
  final String _applicationEmailAddress = 'khair.jalees.app@gmail.com';
  final String _applicationPassword = '123456ah.';

  // Builder Method
  Widget _buildEmailTextField() {
    return CustomInputTextField(
      label: 'بريدك الإلكتروني',
      onSaved: (value) {
        this._userEmail = value;
      },
      validator: (value) {
        if (value.toString().trim().isEmpty) return 'يرجى إدخال بريد إلكتروني';
        if (!isEmail(value.toString().trim()))
          return 'يرجى إدخال بريد إلكتروني صحيح';
      },
      width: 300,
      keyboardType: TextInputType.emailAddress,
    );
  }

  void _formSubmitted(BuildContext ctx) {
    final form = _formKey.currentState;
    final scaffold = ScaffoldMessenger.of(ctx);
    form.save();
    if (!form.validate()) {
      return;
    } else {
      UserActions.isEmailFound(_userEmail).then((value) {
        if (value) {
          _recoverPassword(_userEmail);
          form.reset();
        } else
          scaffold.showSnackBar(
              CustomSnackBar('البريد الإلكتروني غير صحيح').build(ctx));
      });
    }
  }

  void _recoverPassword(String email) async {
    // Generate New Password
    String newPassword = Uuid().v4();
    // Get The User From Email
    var usersSearch =
        await UserActions.getUsers(where: 'email = ?', whereArgs: [email]);
    User wantedUser = User.fromMap(usersSearch.first);
    // Update User With Password (Hashed)
    wantedUser.password = sha512.convert(utf8.encode(newPassword)).toString();
    UserActions.updateUser(wantedUser);
    // Send The Password to User
    String emailBody = '،${wantedUser.fullName} المشترك العزيز ' +
        '\n' +
        'تم إعادة ضبط كلمة المرور الخاصة بك بسبب فقدانك لها ' +
        '\n' +
        '$newPassword : كلمة المرور الجديدة الخاصية بك هي' +
        '\n' +
        'يمكنك استخدامها لتسجيل الدخول ثم إعادة ضبط كلمة المرور الخاصة بك';

    _sendEmail(email, 'إسترجاع كلمة المرور', emailBody);
  }

  //send email for password recovery ((we call it when user click إرسال))
  _sendEmail(String email, String subject, String text) async {
    // smtp gmail
    final smtpServer = gmail(_applicationEmailAddress, _applicationPassword);

    // Create our message.
    final message = Message()
      ..from = Address(_userEmail)
      ..recipients.add(email)
      ..subject = subject
      ..text = text;

    try {
      // Send Email
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) print(p.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          width: 160,
          child: CustomLabel('نسيت كلمة المرور'),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Image.asset(
                'assets/images/password_recovery.png',
                height: 125,
              ),
              SizedBox(
                width: 200,
                child: Text(
                  'سيتم إرسال كلمة مرور مؤقتة لك على شكل بريد إلكتروني',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildEmailTextField(),
                SizedBox(height: 30),
                CustomButton(
                  text: 'أرسال',
                  onPressed: () => _formSubmitted(context),
                  width: 175,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
