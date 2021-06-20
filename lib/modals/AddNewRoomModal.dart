//Flutter Packages
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/screens/SingleBookScreen.dart';
import 'package:intl/intl.dart' as DF;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Custom Widgets
import '../widgets/CustomLabel.dart';
import '../widgets/CustomInputTextField.dart';
import '../widgets/CustomButton.dart';
import '../widgets/CustomSnackbar.dart';

// Database
import '../database/room_actions.dart';

class AddNewRoomModal extends StatefulWidget {
  final String booktitle;
  final bool isInBookScreen;
  AddNewRoomModal({this.booktitle, this.isInBookScreen = false});
  @override
  _AddNewRoomModalState createState() => _AddNewRoomModalState();
}

class _AddNewRoomModalState extends State<AddNewRoomModal> {
  // Properties
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _username = '';
  List<Map<String, dynamic>> Books = [];
  var _textFieldController;

  String _hour;
  String _minute;
  String _time;
  var _dateController = '';
  var _timeController = '';

  // Room Information
  String _roomName = '';
  String _booktitle = '';
  var _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(hour: 00, minute: 00);

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  Future<void> _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var listofBooks = await BookActions.getAllBooks();
    setState(() {
      Books = listofBooks;
    });
    _username = prefs.getString('username');
  }

  Widget _buildGroupName() {
    return CustomInputTextField(
      label: 'اسم المجموعة',
      onSaved: (value) {
        _roomName = value;
      },
      validator: (value) {
        if (value.toString().trim().isEmpty)
          return 'يرجى إدخال إسم للمجموعة المراد إنشائها';
      },
      width: 300,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildBookChosen() {
    return RawAutocomplete(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == null || textEditingValue.text == '') {
          return const Iterable<Map<String, dynamic>>.empty();
        }
        return Books.where((option) {
          return option['title'].contains(textEditingValue.text);
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
          width: 300,
          label: "الكتاب المراد قراءته",
          onSaved: (value) {
            _booktitle = value;
          },
          validator: (value) {
            if (value.toString().trim().isEmpty)
              return 'يرجى إدخال إسم كتاب للمجموعة';
          },
          controller: this.widget.isInBookScreen
              ? TextEditingController(text: this.widget.booktitle)
              : _textFieldController,
          focusNode: focusNode,
          enabled: !this.widget.isInBookScreen,
          // initialValue: this.widget.bookId.toString(),
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
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: SizedBox(
                height: options.length.toDouble() * 80,
                width: 300,
                child: ListView(
                  padding: EdgeInsets.all(5.0),
                  children: options
                      .map((option) => GestureDetector(
                            onTap: () {
                              var tmp = {"": option['title']}.toString();
                              var bookid = tmp.replaceAllMapped(
                                  new RegExp(r'[{}:]'), (match) {
                                return "";
                              }).trim();
                              onSelected(bookid);
                            },
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(option['coverLink']),
                                ),
                                title: Text(
                                  option['title'] +
                                      " (${option['publishYear']})",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(option['author']),
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
    );

    // return CustomInputTextField(
    //   label: 'الكتاب المُراد قراءته',
    //   onSaved: (value) {
    //     _bookId = value;
    //   },
    //   validator: (value) {
    //     if (value.toString().trim().isEmpty)
    //       return 'يرجى إدخال إسم كتاب للمجموعة';
    //   },
    //   width: 300,
    //   keyboardType: TextInputType.text,
    // );
  }

  //Add roomId to firebase
  void addRoomToFireBase(int roomid) {
    FirebaseFirestore.instance
        .collection("ChatGroups")
        .doc("$roomid") //roomId
        .set(new HashMap<String, Object>());
    FirebaseFirestore.instance
        .collection("ChatGroups/$roomid/messages")
        .doc("Must be added to initiate documents")
        .set(new HashMap<String, Object>());

    FirebaseFirestore.instance.collection("ChatGroups").doc("$roomid") //roomId
        .set({"notifications_number": 0});
  }

  // When The Form Is Sumbitted
  void _formSubmitted(BuildContext ctx) async {
    final form = _formKey.currentState;
    final scaffold = ScaffoldMessenger.of(ctx);
    form.save();
    if (!form.validate()) {
      return;
    } else {
      // Add room
      var id = await BookActions.getBookTitle(_booktitle);
      Map<String, dynamic> roomMap = {
        'roomName': _roomName,
        'bookId': id,
        'creatorId': _username,
        'startDate': DateTime.now().toString(),
        'endDate': _selectedDate
            .add(Duration(
              hours: _selectedTime.hour,
              minutes: _selectedTime.minute,
            ))
            .toString(),
        'isOpen': 1,
      };

      // Update Points
      int points = await UserActions.getUserPoints(_username);
      int numOfBooks = await UserActions.getNumberOfOpenedRooms(_username);
      if ((numOfBooks + 1) % 4 == 0)
        points += 40;
      else
        points += 20;
      UserActions.updatePoints(_username, points);
      /////////////////////////////////////////////////////////////////////////

      await RoomActions.addNewRoom(roomMap).then((roomId) {
        form.reset();
        // Add User as Member
        RoomActions.addRoomMember({
          'roomId': roomId,
          'userId': _username,
          'isNotificationOn': 1,
          'readPages': 0,
        });
        addRoomToFireBase(roomId); ///////////////////////
      }).then((_) {
        scaffold.showSnackBar(CustomSnackBar('تم إنشاء المجموعة').build(ctx));
      });
    }
  }

  //Date Picker
  void _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null)
      setState(() {
        _selectedDate = picked;
        _dateController = DF.DateFormat.yMd('ar_SA').format(_selectedDate);
      });
  }

  //Time Picker
  void _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null)
      setState(() {
        _selectedTime = picked;
        _hour = _selectedTime.hour.toString();
        _minute = _selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController = _time;
        _timeController = formatDate(
            DateTime(2021, 03, 4, _selectedTime.hour, _selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        CustomLabel('إنشاء غرفة جديدة'),
        Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildGroupName(),
                _buildBookChosen(),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: theme.primaryColor,
                        icon: Icon(Icons.date_range),
                        onPressed: () => _selectDate(context),
                      ),
                      Text(
                        _dateController,
                        style:
                            TextStyle(fontSize: 18, color: theme.primaryColor),
                      ),
                      IconButton(
                        onPressed: () => _selectTime(context),
                        icon: Icon(FontAwesomeIcons.clock),
                        color: theme.primaryColor,
                      ),
                      Text(
                        _timeController,
                        style:
                            TextStyle(fontSize: 18, color: theme.primaryColor),
                      ),
                      Text(
                        "موعد إغلاق الغرفة",
                        style: TextStyle(
                            color: theme.primaryColorDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: 'أنشئ',
                  onPressed: () {
                    _formSubmitted(context);
                  },
                  width: 150,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
