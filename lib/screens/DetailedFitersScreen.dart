//Flutter
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/database/user_actions.dart';

//Widgets
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:grad_project/widgets/CustomInputTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';
import 'package:chips_choice/chips_choice.dart';

class DetailedFiltersScreen extends StatefulWidget {
  //Constants
  static const routeName = '/DetailedFilters-Screen';

  @override
  _DetailedFiltersScreenState createState() => _DetailedFiltersScreenState();
}

class _DetailedFiltersScreenState extends State<DetailedFiltersScreen> {
  String authorName = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RangeValues ratingRangeValues = const RangeValues(1, 5);
  RangeValues publishYearRangeValues = const RangeValues(184, 2020);
  RangeValues pageNumbersRangeValues = const RangeValues(12, 1607);

  List<Map<String, dynamic>> authors = [];
  var _textFieldController;

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    var listofauthors = await BookActions.getAllauthors();
    setState(() {
      authors = listofauthors;
    });
  }

  List<String> tags = [];
  List<String> options = [
    'التاريخ',
    'الشعر العربي',
    'المسرح العربي',
    'المسرح المترجم',
    'الأدب الساخر',
    'الادب العربي',
    'الروايات العربية',
    'علم النفس',
    'العلوم الإسلامية',
    'العلوم السياسية',
    'قصص أطفال',
    'العلوم الإجتماعية',
    'الروايات المترجمة',
    'القصص القصيرة',
    'القسم العام',
    'الادب المترجم',
    'التنمية البشرية',
    'السيرة الذاتية',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _formKey.currentState.save();
              Navigator.of(context).pop({
                'minPage': pageNumbersRangeValues.start.floor(),
                'maxPage': pageNumbersRangeValues.end.floor(),
                'minYear': publishYearRangeValues.start.floor(),
                'maxYear': publishYearRangeValues.end.floor(),
                'minRating': ratingRangeValues.start,
                'maxRating': ratingRangeValues.end,
                'author': authorName,
                'categories': tags.isEmpty ? options : tags,
              });
            },
          ),
          title: Text(
            "خير جليس",
            style: TextStyle(color: theme.accentColor),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: theme.accentColor),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Container(
                    child: ExpansionTileCard(
                      elevation: 0,
                      initiallyExpanded: true,
                      expandedTextColor: theme.primaryColor,
                      expandedColor: theme.scaffoldBackgroundColor,
                      baseColor: theme.scaffoldBackgroundColor,
                      title: Text(
                        "التصنيف",
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      children: <Widget>[
                        ChipsChoice<String>.multiple(
                          choiceStyle: C2ChoiceStyle(
                            borderColor: theme.primaryColorLight,
                            color: theme.primaryColorLight,
                            labelStyle: TextStyle(fontSize: 15),
                          ),
                          choiceActiveStyle: C2ChoiceStyle(
                            borderColor: theme.primaryColor,
                            color: theme.primaryColor,
                            labelStyle: TextStyle(fontSize: 18),
                          ),
                          wrapped: true,
                          value: tags,
                          onChanged: (val) => setState(() => tags = val),
                          choiceItems: options.map((e) {
                            return C2Choice(label: e, value: e);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الكاتب",
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Form(
                          key: _formKey,
                          child: RawAutocomplete(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == null ||
                                  textEditingValue.text == '') {
                                return const Iterable<
                                    Map<String, dynamic>>.empty();
                              }
                              return authors.where((option) {
                                return option['author']
                                    .contains(textEditingValue.text);
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
                                width: 500,
                                label: "اسم الكاتب",
                                onSaved: (value) => this.authorName = value,
                                validator: (_) {},
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
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: SizedBox(
                                      height: 210.0,
                                      width: 360,
                                      child: ListView(
                                        padding: EdgeInsets.all(5.0),
                                        children: options
                                            .map((option) => GestureDetector(
                                                  onTap: () {
                                                    var tmp = {
                                                      "": option['author']
                                                    }.toString();
                                                    var user = tmp
                                                        .replaceAllMapped(
                                                            new RegExp(
                                                                r'[{}:]'),
                                                            (match) {
                                                      return "";
                                                    }).trim();
                                                    onSelected(user);
                                                  },
                                                  child: Directionality(
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    child: ListTile(
                                                      title: Text(
                                                        option['author'],
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
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
                          // child: CustomInputTextField(
                          //   width: 500,
                          //   label: "اسم الكاتب",
                          //   onSaved: (value) => this.authorName = value,
                          //   validator: (_) {},
                          // ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "التقيم العام",
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                ratingRangeValues.start.toInt().toString(),
                                style: TextStyle(
                                    color: theme.primaryColor, fontSize: 18),
                              ),
                              Expanded(
                                  child: RangeSlider(
                                activeColor: theme.primaryColor,
                                inactiveColor:
                                    theme.primaryColorLight.withOpacity(0.5),
                                values: ratingRangeValues,
                                min: 0,
                                max: 5,
                                divisions: 10,
                                labels: RangeLabels(
                                  ratingRangeValues.start.round().toString(),
                                  ratingRangeValues.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    ratingRangeValues = values;
                                  });
                                },
                              )),
                              Text(
                                ratingRangeValues.end.toInt().toString(),
                                style: TextStyle(
                                    color: theme.primaryColor, fontSize: 18),
                              )
                            ])
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "عدد الصفحات",
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                pageNumbersRangeValues.start.toInt().toString(),
                                style: TextStyle(
                                    color: theme.primaryColor, fontSize: 18),
                              ),
                              Expanded(
                                  child: RangeSlider(
                                activeColor: theme.primaryColor,
                                inactiveColor:
                                    theme.primaryColorLight.withOpacity(0.5),
                                values: pageNumbersRangeValues,
                                min: 12,
                                max: 1607,
                                divisions: 500,
                                labels: RangeLabels(
                                  pageNumbersRangeValues.start
                                      .round()
                                      .toString(),
                                  pageNumbersRangeValues.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    pageNumbersRangeValues = values;
                                  });
                                },
                              )),
                              Text(
                                pageNumbersRangeValues.end.toInt().toString(),
                                style: TextStyle(
                                    color: theme.primaryColor, fontSize: 18),
                              )
                            ])
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "سنة النشر",
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                publishYearRangeValues.start.toInt().toString(),
                                style: TextStyle(
                                    color: theme.primaryColor, fontSize: 18),
                              ),
                              Expanded(
                                  child: RangeSlider(
                                activeColor: theme.primaryColor,
                                inactiveColor:
                                    theme.primaryColorLight.withOpacity(0.5),
                                values: publishYearRangeValues,
                                min: 184,
                                max: 2020,
                                divisions: 100,
                                labels: RangeLabels(
                                  publishYearRangeValues.start
                                      .round()
                                      .toString(),
                                  publishYearRangeValues.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    publishYearRangeValues = values;
                                  });
                                },
                              )),
                              Text(
                                publishYearRangeValues.end.toInt().toString(),
                                style: TextStyle(
                                    color: theme.primaryColor, fontSize: 18),
                              )
                            ])
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
