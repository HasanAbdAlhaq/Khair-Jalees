import 'package:flutter/material.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/models/User.dart';
import 'package:grad_project/widgets/CustomButton.dart';
import 'package:grad_project/widgets/CustomInputTextField.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';
import 'package:grad_project/widgets/CustomSnackbar.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

class SuggestBookScreen extends StatefulWidget {
  static const routeName = '/Suggest_Book-Screen';
  @override
  _SuggestBookScreenState createState() => _SuggestBookScreenState();
}

class _SuggestBookScreenState extends State<SuggestBookScreen> {
  // Email And Password Of The Application
  final String _applicationEmailAddress = 'khair.jalees.app@gmail.com';
  final String _applicationPassword = '123456ah.';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User currentUser;
  String bookName = '';
  String authorName = '';
  int numberOfPages = 0;
  int publishYear = 0;

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _formSubmitted() {
    var form = this._formKey.currentState;
    form.save();
    form.validate();
    _suggest();
    form.reset();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _username = prefs.getString('username');
    Map<String, dynamic> userMap = await UserActions.getUser(_username);
    this.currentUser = User.fromMap(userMap);
  }

  void _suggest() async {
    String snackBarMsg = '';
    if (this.currentUser.points >= 100) {
      int newPoints = currentUser.points - 100;
      await UserActions.updatePoints(currentUser.username, newPoints);
      _prepareAndSend();
      snackBarMsg = 'تم أرسال أقتراحك';
    } else {
      snackBarMsg = 'النقاط غير كافية لإستخدام هذه الميزة';
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar(snackBarMsg).build(context));
    _setUp();
  }

  void _prepareAndSend() async {
    String fullName = currentUser.fullName;
    String username = currentUser.username;

    String emailBody = 'يقترح عليك المستخدم "$fullName" ' +
        'إضافة كتاب جديد إلى مجموعة كتب خير جليس.' +
        '\n' +
        'معلومات الكتاب : \n' +
        '\n. إسم الكتاب : ${this.bookName}' +
        '\n. إسم الكاتب : ${this.authorName}' +
        '\n. عدد الصفحات : ${this.numberOfPages} صفحة' +
        '\n. سنة النشر : ${this.publishYear}';

    _sendEmail('إقتراح كتاب غير متوفّر', emailBody);
  }

  _sendEmail(String subject, String text) async {
    // smtp gmail
    final smtpServer = gmail(_applicationEmailAddress, _applicationPassword);

    // Create our message.
    final message = Message()
      ..from = Address('amin.nassar.ce@gmail.com')
      ..recipients.add('amin.nassar.ce@gmail.com')
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 10),
              CustomPageLabel('أقتراح كتاب غير متوفّر'),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomInputTextField(
                      label: 'إسم الكتاب',
                      onSaved: (str) {
                        this.bookName = str;
                      },
                      validator: (str) {},
                    ),
                    CustomInputTextField(
                      label: 'إسم الكاتب',
                      onSaved: (str) {
                        this.authorName = str;
                      },
                      validator: (str) {},
                    ),
                    CustomInputTextField(
                      label: 'عدد الصفحات',
                      onSaved: (str) {
                        this.numberOfPages = int.tryParse(str);
                      },
                      validator: (String str) {
                        if (!isInt(str) && str.isNotEmpty)
                          return 'عدد الصفحات يجب أن تكون رقم صحيح';
                      },
                      keyboardType: TextInputType.number,
                    ),
                    CustomInputTextField(
                      label: 'سنة النشر',
                      onSaved: (str) {
                        this.publishYear = int.tryParse(str);
                      },
                      validator: (String str) {
                        if (!isInt(str) && str.isNotEmpty)
                          return 'سنة النشر يجب أن تكون رقم صحيح';
                      },
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 50),
                    CustomButton(
                      text: 'أرسال',
                      onPressed: _formSubmitted,
                      width: 140,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'أقتراح كتاب سيخصم 100 نقطة من مجموع نقاطك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'رجوع',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
