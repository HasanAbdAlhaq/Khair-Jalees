// Futter Packages

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grad_project/database/user_actions.dart';
import 'package:smart_select/smart_select.dart';
import '../database/room_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/CustomSnackbar.dart';

// Widgets
import '../widgets/CustomButton.dart';
import '../widgets/CustomInputTextField.dart';
import '../widgets/CustomLabel.dart';
import '../widgets/CustomPageLabel.dart';
import 'package:http/http.dart' as http;

class AddRoomMemberModal extends StatefulWidget {
  final int groupid;
  final String groupname;

  AddRoomMemberModal({@required this.groupid, @required this.groupname});
  @override
  _AddRoomMemberModalState createState() => _AddRoomMemberModalState();
}

class _AddRoomMemberModalState extends State<AddRoomMemberModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _textFieldController;

  String newMemberId;
  String _currentUser = '';
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> users = [];
  List<String> usernames = [];
  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('username');
    var listOfContacts = await UserActions.getAllContacts(_currentUser);
    var listofUsers = await UserActions.getAllUsers();
    setState(() {
      contacts = listOfContacts;
      users = listofUsers;
    });
    users.forEach((element) {
      usernames.add(element['username']);
    });
  }

  void _formSubmitted(BuildContext ctx) {
    // sendNotification();
    final form = _formKey.currentState;

    if (!form.validate()) {
      return;
    } else {
      form.save();
      sendInvite(ctx, newMemberId, this.widget.groupid);
    }
    form.reset();
  }

  Future<void> gettoken(String username) async {
    await UserActions.isNotificationsOnGeneral(username).then((value) {
      if (value == 1) {
        print(value);
        UserActions.getUserToken(username).then((value) {
          sendInviteNotification(value['userToken']);
        });
      } else
        print("no");
    });
  }

  String formatNotificationBody() {
    var sender = _currentUser;
    var groupname = this.widget.groupname;
    var body = 'قام $sender بدعوتك لمجموعة "$groupname"';
    return body;
  }

  void sendInviteNotification(token) async {
    http.Response response = await http.post('http://10.0.2.2:81/actual.php',
        body: {
          "token": token,
          "title": "دعوة إنضمام لمجموعة",
          "body": formatNotificationBody()
        });
    var datauser = response.body;
    print(datauser);
  }

  void sendInvite(BuildContext ctx, String memberid, int groupid) async {
    var usersSearch =
        await RoomActions.isMemberFound(newMemberId, this.widget.groupid);
    String snackBarMsg = '';
    if (!usersSearch) {
      Map<String, dynamic> data = {
        'senderId': _currentUser,
        'groupId': this.widget.groupid,
        'groupName': this.widget.groupname,
        'inviteTime': Timestamp.now(),
      };
      FirebaseFirestore.instance
          .collection("Invitation_Info/$newMemberId/invites")
          .doc('${this.widget.groupid}')
          .set(
            data,
          );
      gettoken(newMemberId);
      snackBarMsg = 'تم إرسال دعوة إنضمام إلى هذا المستخدم';
    } else {
      snackBarMsg = 'هذا الحساب موجود بالفعل في المجموعة';
    }
    ScaffoldMessenger.of(ctx)
        .showSnackBar(CustomSnackBar(snackBarMsg).build(ctx));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomLabel('إضافة عضو جديد'),
        Form(
          key: _formKey,
          child: Column(
            children: [
              RawAutocomplete(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == null ||
                      textEditingValue.text == '') {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return users.where((option) {
                    return option['username'].contains(textEditingValue.text) ||
                        option['fullname'].contains(textEditingValue.text);
                  });
                },
                onSelected: (option) {
                  print(option);
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  _textFieldController = textEditingController;
                  return CustomInputTextField(
                    label: "اسم المستخدم",
                    onSaved: (value) {
                      newMemberId = value;
                    },
                    validator: (value) {
                      if (value.toString().trim().isEmpty) {
                        return 'الرجاء إدخال اسم مستخدم ';
                      }
                    },
                    controller: _textFieldController,
                    focusNode: focusNode,
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<dynamic> onSelected,
                    Iterable<dynamic> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: SizedBox(
                          height: 240.0,
                          width: 280,
                          child: ListView(
                            padding: EdgeInsets.all(5.0),
                            children: options
                                .map((option) => GestureDetector(
                                      onTap: () {
                                        var tmp =
                                            {"": option['username']}.toString();
                                        var user = tmp.replaceAllMapped(
                                            new RegExp(r'[{}:]'), (match) {
                                          return "";
                                        }).trim();
                                        onSelected(user);
                                        setState(() {
                                          newMemberId = user;
                                        });
                                      },
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                option['userAvatar']),
                                          ),
                                          title: Text(
                                            option['fullName'],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(option['username']),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              CustomPageLabel('أو'),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SmartSelect.single(
                  placeholder: '',
                  title: 'الإختيار من قائمة المعارف',
                  choiceDivider: true,
                  choiceDividerBuilder: (_, __) => Divider(
                      thickness: 1, color: Theme.of(context).primaryColor),
                  modalTitle: 'قائمة المعارف',
                  modalHeaderStyle: S2ModalHeaderStyle(
                    centerTitle: true,
                    iconTheme: IconThemeData(
                      color: Theme.of(context).accentColor,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  builder: S2SingleBuilder<Map<String, dynamic>>(),
                  choiceItems: contacts.map((e) {
                    return S2Choice(
                      value: e,
                      title: e['fullName'],
                    );
                  }).toList(),
                  choiceTitleBuilder: (_, s2Choice, __) {
                    return ListTile(
                      title: Text(
                        s2Choice.title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      trailing: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage(s2Choice.value['userAvatar']),
                      ),
                    );
                  },
                  onChange: (val) {
                    setState(() {
                      newMemberId = val.value;
                    });
                  },
                  value: '',
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'أضف',
                onPressed: () {
                  _formSubmitted(context);
                },
                width: 120,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
