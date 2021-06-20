// Flutter Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

// Custom Widgets
import '../widgets/CustomInputTextField.dart';
import '../widgets/CustomButton.dart';
import '../widgets/CustomSnackbar.dart';

// Models
import '../models/User.dart';

// Database Related
import '../database/user_actions.dart';

class SignUpScreen extends StatefulWidget {
  // Constants
  static const routeName = '/SignUp-Page';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Properties
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _repeatedPasswordfocusNode = FocusNode();

  // Form Variables
  String _email = '';
  String _username = '';
  String _password = '';

  // To Fix The Height Of The Form After Validation Fail
  double _sizedBoxHeight = 70;

  Widget _buildEmail() {
    return CustomInputTextField(
      focusNode: _emailFocusNode,
      nextTextField: _usernameFocusNode,
      label: 'البريد الإلكتروني',
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        this._email = value;
      },
      validator: (value) {
        if (value.toString().trim().isEmpty) return 'يرجى إدخال بريد إلكتروني';
        if (!isEmail(value.toString().trim()))
          return 'يرجى إدخال بريد إلكتروني صحيح';
      },
    );
  }

  Widget _buildUsername() {
    return CustomInputTextField(
      focusNode: _usernameFocusNode,
      nextTextField: _passwordFocusNode,
      label: 'إسم المستخدم',
      onSaved: (value) {
        this._username = value;
      },
      validator: (value) {
        if (value.toString().trim().isEmpty) return 'يرجى إدخال إسم مستخدم';
        if (value
            .toString()
            .contains(new RegExp(r'[,/~!#$%^&*<>(){}+?=\[\]\\ ]')))
          return 'بعض الخانات غير مسموحة';
      },
    );
  }

  Widget _buildPassword() {
    return CustomInputTextField(
      focusNode: _passwordFocusNode,
      nextTextField: _repeatedPasswordfocusNode,
      label: 'كلمة المرور',
      obscureText: true,
      onSaved: (value) {
        this._password = value;
      },
      validator: (value) {
        if (value.toString().trim().isEmpty) return 'يرجى إدخال كلمة مرور';
        if (value.toString().length < 8)
          return 'كلمة المرور يجب أن تكون أكثر من 8 خانات';
      },
    );
  }

  Widget _buildRepeatedPassword() {
    return CustomInputTextField(
      focusNode: _repeatedPasswordfocusNode,
      label: 'تأكيد كلمة المرور',
      obscureText: true,
      onSaved: (_) {},
      validator: (value) {
        if (value.toString() != this._password)
          return 'كلمة المرور المكررة غير مطابقة';
      },
    );
  }

  void _formSubmitted(BuildContext ctx) async {
    // Final Variables (Form and Scaffold)
    final form = _formKey.currentState;
    form.save();
    if (!form.validate()) {
      setState(() => _sizedBoxHeight = 40);
      return;
    } else {
      FirebaseFirestore.instance
          .collection("AllNotificationsNumber")
          .doc(this._username)
          .set({"number": 0});
      UserActions.signUpUser(new User(
        username: this._username,
        password: this._password,
        email: this._email,
        fullName: this._username,
        creationDate: DateTime.now(),
      )).then((resultString) {
        if (resultString == null) {
          form.reset();
          ScaffoldMessenger.of(context)
              .showSnackBar(CustomSnackBar('تم إنشاء حساب بنجاح').build(ctx));
        } else
          ScaffoldMessenger.of(context)
              .showSnackBar(CustomSnackBar(resultString).build(ctx));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: mediaQuery.size.width,
              height: mediaQuery.size.height * 0.25,
              color: theme.primaryColor,
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/logo_light.png',
                      width: 150,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(
                      "إنشاء حساب جديد",
                      style: TextStyle(
                        color: theme.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: mediaQuery.size.width,
              height: mediaQuery.size.height * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(150)),
                color: theme.scaffoldBackgroundColor,
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 70),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _buildEmail(),
                          _buildUsername(),
                          _buildPassword(),
                          _buildRepeatedPassword(),
                          SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                            text: 'إنشاء حساب',
                            width: 180,
                            fontsize: 22,
                            onPressed: () => _formSubmitted(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: _sizedBoxHeight,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: theme.scaffoldBackgroundColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed("/LogIn-Page");
                          },
                          child: Text(
                            "تسجيل الدخول",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          "لديك حساب بالفعل؟",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 22,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
