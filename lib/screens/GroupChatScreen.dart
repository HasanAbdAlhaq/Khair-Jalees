//Flutter
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/database/room_actions.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/models/User.dart';
import 'package:grad_project/screens/UserGroupsScreen.dart';
import 'package:grad_project/widgets/CustomSnackbar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GroupChatScreen extends StatefulWidget {
  static const routeName = './GroupChat-Screen';

  final Object arguments;
  int roomId;
  String roomName;
  String title;
  String coverLink;

  GroupChatScreen({this.arguments}) {
    this.roomId = (arguments as Map<String, dynamic>)['roomId'];
    this.roomName = (arguments as Map<String, dynamic>)['roomName'];
    this.title = (arguments as Map<String, dynamic>)['title'];
    this.coverLink = (arguments as Map<String, dynamic>)['coverLink'];
  }

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List<String> badWords = [
    'كلب',
    'حقير',
    'حيوان',
    'زبالة',
    'شرموط',
    'منيك',
  ];

  bool get containsBadWords {
    for (int i = 0; i < this.badWords.length; i++) {
      String badWord = badWords[i];
      if (this._enteredMessage.contains(badWord)) return true;
    }
    return false;
  }

  int messagesCounter = 0;
  List<Map<String, dynamic>> tokens = [];
  var _enteredMessage = '';
  TextEditingController messageEditingController = new TextEditingController();
  String _currentUser = '';
  User senderUser = User(
    email: '',
    username: '',
    password: '',
    fullName: '',
    country: 'PS',
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
    var listOfTokens = await RoomActions.getGroupMembersTokens(widget.roomId);
    setState(() {
      senderUser = User.fromMap(resultUser);
      tokens = listOfTokens;
    });
  }

  void _tryToSend() {
    if (this.containsBadWords)
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar('تحتوي الرسائلة كلمات غير مسموح بها').build(context));
    else if (this._enteredMessage.isEmpty)
      return;
    else
      _sendMessage();
  }

  _sendMessage() {
    FocusScope.of(context).unfocus();
    FirebaseFirestore.instance
        .collection("ChatGroups/${widget.roomId}/messages")
        .add({
      "messageText": _enteredMessage,
      "senderId": _currentUser,
      "messageTime": Timestamp.now(),
      "userAvatar": senderUser.userAvatar,
    });
    messageEditingController.text = "";

    tokens.map((e) {
      if (e['userToken'] != senderUser.userToken)
        sendMessageNotification(e['userToken']);
    }).toList();

    FirebaseFirestore.instance
        .collection("ChatGroups")
        .doc('${widget.roomId}')
        .get()
        .then((value) {
      setState(() {
        messagesCounter = value['notifications_number'];
      });
    });

    FirebaseFirestore.instance
        .collection('ChatGroups')
        .doc('${widget.roomId}')
        .update(
            {'notifications_number': messagesCounter = messagesCounter + 1});

    //if (notification_checker) messagesCounter = 0;

    print(messagesCounter);
  }

  String formatMessageNotificationBody() {
    var sender = senderUser.fullName;
    var message = _enteredMessage;
    var body = sender + " :" + message;
    return body;
  }

  void sendMessageNotification(String token) async {
    // http.Response response =
    //     await http.post('http://10.0.2.2:81/actual.php', body: {
    //   "token": token,
    //   "title": this.widget.roomName,
    //   "body": formatMessageNotificationBody()
    // });
    // var datauser = response.body;
    // print(datauser);
  }

//for header
  Widget buildRoomItem(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                              color: Theme.of(ctx).accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.roomName,
                          style: TextStyle(
                              fontSize: 18, color: Theme.of(ctx).accentColor),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(widget.coverLink),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDateWithTime(DateTime date, bool isCurrentUser) {
    String actualDay = '${intl.DateFormat.yMd('ar_SA').format(date)}';
    String actualTime = '${intl.DateFormat.jm('ar_SA').format(date)}';
    if (!isCurrentUser) return '$actualDay   $actualTime';

    return '$actualTime   $actualDay';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          iconTheme: IconThemeData(
            color: theme.accentColor, //change your color here
          ),
          title: buildRoomItem(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("ChatGroups/${widget.roomId}/messages")
                        .orderBy("messageTime", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return Center(
                      //     child: CircularPercentIndicator(
                      //       radius: 50,
                      //     ),
                      //   );
                      // }
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text(
                            "......يتم تحميل الرسائل",
                            style: TextStyle(
                                color: theme.primaryColor, fontSize: 30),
                          ),
                        );
                      }

                      final documents = snapshot.data.docs;
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        reverse: true,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            subtitle: Transform.translate(
                              offset:
                                  documents[index]['senderId'] != _currentUser
                                      ? Offset(-28, 0)
                                      : Offset(28, 0),
                              child: Text(
                                formatDateWithTime(
                                    documents[index]['messageTime'].toDate(),
                                    documents[index]['senderId'] !=
                                        _currentUser),
                                textDirection:
                                    documents[index]['senderId'] != _currentUser
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                style: TextStyle(color: theme.primaryColor),
                              ),
                            ),
                            leading:
                                documents[index]['senderId'] != _currentUser
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            documents[index]['userAvatar']),
                                      )
                                    : CircleAvatar(
                                        backgroundColor:
                                            theme.scaffoldBackgroundColor,
                                      ),
                            title: Transform.translate(
                              offset:
                                  documents[index]['senderId'] != _currentUser
                                      ? Offset(-15, 0)
                                      : Offset(14, 0),
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 14, right: 14, top: 10, bottom: 3),
                                child: Align(
                                  alignment: (documents[index]['senderId'] !=
                                          _currentUser
                                      ? Alignment.topLeft
                                      : Alignment.topRight),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: (documents[index]
                                                      ['senderId'] !=
                                                  _currentUser
                                              ? Colors.white
                                              : theme.primaryColor)),
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        documents[index]['messageText'],
                                        textDirection: (documents[index]
                                                    ['senderId'] !=
                                                _currentUser)
                                            ? TextDirection.ltr
                                            : TextDirection.rtl,
                                        style: (documents[index]['senderId'] !=
                                                _currentUser)
                                            ? TextStyle(
                                                fontSize: 18,
                                                color: theme.primaryColor)
                                            : TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                      )),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ),
              SizedBox(
                height: 55,
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(-8, 0),
                    child: FloatingActionButton(
                      onPressed: _tryToSend,
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      backgroundColor: theme.primaryColor,
                      elevation: 0,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageEditingController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                          hintText: "....اكتب رسالتك هنا",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      onChanged: (value) {
                        setState(() {
                          _enteredMessage = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // body: StreamBuilder(
      //   stream: FirebaseFirestore.instance
      //       .collection("ChatGroups/LKzUxwiLbLUhPJd7DwEk/messages")
      //       .snapshots(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(
      //         child: CircularPercentIndicator(),
      //       );
      //     }
      //     final documents = snapshot.data.docs;
      //     return ListView.builder(
      //       itemBuilder: (context, index) => Container(
      //         child: Text(documents[index]['text']),
      //       ),
      //       itemCount: snapshot.data.docs.length,
      //     );
      //   },
      // ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     FirebaseFirestore.instance
      //         .collection("ChatGroups/LKzUxwiLbLUhPJd7DwEk/messages")
      //         .add({'text': "this is me"});
      //   },
      // ),
    );
  }
}
