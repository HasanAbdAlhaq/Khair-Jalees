//Flutter Packages
import 'package:flutter/material.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/screens/SingleBookScreen.dart';
import 'package:grad_project/widgets/CustomInputTextField.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';
import 'package:smart_select/smart_select.dart';
import '../screens/FiltersScreen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // available configuration

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => new Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  List<Map<String, dynamic>> Books = [];
  var _textFieldController;

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    var listofBooks = await BookActions.getAllBooks();
    setState(() {
      Books = listofBooks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          return showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "MaterialLocalizations.of(context).dialogLabel",
            barrierColor: theme.primaryColorLight.withOpacity(0.3),
            pageBuilder: (context, _, __) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    AppBar(
                      title: Text(
                        "خير جليس",
                        style: TextStyle(color: theme.accentColor),
                      ),
                      centerTitle: true,
                      iconTheme: IconThemeData(color: theme.accentColor),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Card(
                          elevation: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "البحث باستخدام الإسم",
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    RawAutocomplete(
                                      optionsBuilder:
                                          (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text == null ||
                                            textEditingValue.text == '') {
                                          return const Iterable<
                                              Map<String, dynamic>>.empty();
                                        }
                                        return Books.where((option) {
                                          return option['title']
                                              .contains(textEditingValue.text);
                                        });
                                      },
                                      onSelected: (option) {
                                        print(option);
                                      },
                                      fieldViewBuilder: (BuildContext context,
                                          TextEditingController
                                              textEditingController,
                                          FocusNode focusNode,
                                          VoidCallback onFieldSubmitted) {
                                        _textFieldController =
                                            textEditingController;
                                        return CustomInputTextField(
                                          width: 500,
                                          label: "اسم الكتاب",
                                          onSaved: (_) {},
                                          validator: (_) {},
                                          controller: _textFieldController,
                                          focusNode: focusNode,
                                        );
                                      },
                                      optionsViewBuilder: (BuildContext context,
                                          AutocompleteOnSelected<dynamic>
                                              onSelected,
                                          Iterable<dynamic> options) {
                                        return Align(
                                          alignment: Alignment.topLeft,
                                          child: Material(
                                            elevation: 4.0,
                                            child: Container(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              child: SizedBox(
                                                height: 270.0,
                                                width: 360,
                                                child: ListView(
                                                  padding: EdgeInsets.all(5.0),
                                                  children: options
                                                      .map(
                                                          (option) =>
                                                              GestureDetector(
                                                                onTap: () {
                                                                  var tmp = {
                                                                    "": option[
                                                                        'id']
                                                                  }.toString();
                                                                  var bookid = tmp.replaceAllMapped(
                                                                      new RegExp(
                                                                          r'[{}:]'),
                                                                      (match) {
                                                                    return "";
                                                                  }).trim();
                                                                  var id =
                                                                      int.parse(
                                                                          bookid);

                                                                  Navigator.of(
                                                                          context)
                                                                      .pushNamed(
                                                                          SingleBookScreen
                                                                              .routeName,
                                                                          arguments:
                                                                              id);
                                                                },
                                                                child:
                                                                    Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  child:
                                                                      ListTile(
                                                                    leading:
                                                                        CircleAvatar(
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                              option['coverLink']),
                                                                    ),
                                                                    title: Text(
                                                                      option['title'] +
                                                                          " (${option['publishYear']})",
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                    subtitle: Text(
                                                                        option[
                                                                            'author']),
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
                                    // CustomInputTextField(
                                    //     width: 500,
                                    //     label: "اسم الكتاب",
                                    //     onSaved: (_) {},
                                    //     validator: (_) {})
                                  ],
                                ),
                              ),
                              CustomPageLabel("أو"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              FiltersScreen.routeName);
                                    },
                                    child: Text(
                                      "هنا",
                                      style: TextStyle(
                                        color: Colors.cyan,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "البحث باستخدام المرشحات من ",
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 20,
                                    ),
                                  )
                                ],
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              );
            },
          );
        },
        color: theme.accentColor,
      ),
      title: Text(
        "خير جليس",
        style: TextStyle(color: theme.accentColor),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: theme.accentColor),
    );
  }
}
