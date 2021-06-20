// Flutter Packages
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import '../screens/HomeScreen.dart';

// Custom Widgets
import '../widgets/CustomButton.dart';
import '../widgets/CustomInputTextField.dart';
import '../widgets/CustomSnackbar.dart';

// Modals
import '../modals/GenericModal.dart';
import '../modals/PasswordRecoveryModal.dart';

// Database
import '../database/user_actions.dart';

// Provider
import 'package:grad_project/providers/ThemeProvider.dart';

class LogInScreen extends StatefulWidget {
  // Constants
  static const routeName = '/LogIn-Page';

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  // Properties
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _email = '';
  String _password = '';
  String _username = '';
  bool _isModalShown = false;
  bool _isEmailUsed = false;
  FirebaseMessaging f;

  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    f = FirebaseMessaging.instance;
    super.initState();
  }

  // do something
  // Builder Methods
  Widget _buildEmail() {
    return CustomInputTextField(
      focusNode: _emailFocusNode,
      nextTextField: _passwordFocusNode,
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
      },
    );
  }

  Widget _buildPassword() {
    return CustomInputTextField(
      focusNode: _passwordFocusNode,
      label: 'كلمة المرور',
      obscureText: true,
      onSaved: (value) {
        this._password = value;
      },
      validator: (value) {
        if (value.toString().trim().isEmpty) return 'يرجى إدخال كلمة مرور';
      },
    );
  }

  // Choose Log In With Email Or Username
  void _setLoggingMethod() {
    setState(() {
      this._isEmailUsed = !this._isEmailUsed;
    });
  }

  // When The Form Is Sumbitted
  void _formSubmitted(BuildContext ctx) {
    final form = _formKey.currentState;
    final scaffold = _scaffoldKey.currentState;
    form.save();
    if (!form.validate()) {
      return;
    } else {
      f.getToken().then((value) {
        print(value);
        UserActions.logIn(
                username: _username,
                email: _email,
                password: _password,
                isEmailUsed: _isEmailUsed,
                token: value)
            .then((value) async {
          if (value['userObject'] == null) {
            // Email OR Password Are Wrong (Snack Bar)
            ScaffoldMessenger.of(ctx).showSnackBar(
              CustomSnackBar(value['resultString'] as String).build(ctx),
            );
          } else {
            // Update Shared Preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('loggedIn', true);
            prefs.setString('username', _username);
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            ThemeNotifier().loadThemeByDB();
          }
        });
      });
    }
  }

  // Modal Control Methods
  void _showModal() {
    setState(() {
      this._isModalShown = true;
    });
  }

  void _hideModal() {
    setState(() {
      this._isModalShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Main Variables
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Actual Build Method
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              color: theme.primaryColor,
              child: Column(
                children: [
                  Container(
                    width: mediaQuery.size.width,
                    height: mediaQuery.size.height * 0.25,
                    color: theme.primaryColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/logo_light.png',
                            width: 150,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 60),
                          child: Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              color: theme.accentColor,
                              fontWeight: FontWeight.bold,
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
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(150)),
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(top: 70),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                _isEmailUsed ? _buildEmail() : _buildUsername(),
                                SizedBox(
                                  width: 250,
                                  child: GestureDetector(
                                    onTap: _setLoggingMethod,
                                    child: Text(
                                      _isEmailUsed
                                          ? 'إستخدام إسم المستخدم'
                                          : 'أستخدام البريد الإلكتروني',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                _buildPassword(),
                                SizedBox(
                                  width: 250,
                                  child: GestureDetector(
                                    onTap: _showModal,
                                    child: Text(
                                      'نسيت كلمة المرور ؟',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 50),
                                CustomButton(
                                  text: "تسجيل الدخول",
                                  width: 185,
                                  fontsize: 22,
                                  onPressed: () => _formSubmitted(context),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 70,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      theme.scaffoldBackgroundColor,
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed("/SignUp-Page");
                                },
                                child: Text(
                                  "إنشاء حساب",
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                " ليس لديك حساب؟",
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
                  ),
                ],
              ),
            ),
            if (_isModalShown)
              GenericModal(
                hideModalFunction: this._hideModal,
                childWidget: PasswordRecoveryModal(),
              ),
          ],
        ),
      ),
    );
  }
}
