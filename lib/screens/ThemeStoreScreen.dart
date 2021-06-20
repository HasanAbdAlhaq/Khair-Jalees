import 'package:flutter/material.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/models/Themes.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';
import 'package:grad_project/widgets/CustomSnackbar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStoreScreen extends StatefulWidget {
  static const routeName = '/Theme-Store-Screen';

  @override
  _ThemeStoreScreenState createState() => _ThemeStoreScreenState();
}

class _ThemeStoreScreenState extends State<ThemeStoreScreen> {
  List<Map<String, Object>> themesCollection = [
    Themes.defaultTheme,
    Themes.secondTheme,
    Themes.thirdTheme,
  ];
  List<int> myCollection = [2];

  String _username = '';
  int userPoints = 0;
  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    int points = await UserActions.getUserPoints(_username);
    List<Map<String, dynamic>> listOfThemes =
        await UserActions.getUserThemes(_username);
    setState(() {
      userPoints = points;
      myCollection = listOfThemes.map((e) => e['themeId'] as int).toList();
    });
  }

  List get themesChoices {
    List choices = themesCollection
        .where((theme) =>
            myCollection.indexWhere((id) => id == theme['themeId']) == -1)
        .toList();
    return choices;
  }

  void _buyTheme(int themeId, int themePrice) async {
    if (userPoints >= themePrice) {
      int newPoints = userPoints - themePrice;
      await UserActions.updatePoints(_username, newPoints);
      await UserActions.buyUserTheme(_username, themeId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar('النقاط غير كافية لشراء هذه السمة').build(context));
    }
    _setUp();
  }

  void checkUserChoice(BuildContext ctx, Map<String, dynamic> themeMap) {
    String themeName = themeMap['themeName'];
    int themePrice = themeMap['themePrice'];
    int themeId = themeMap['themeId'];
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: Text(
                themeName,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'سيتم خصم ' +
                    '$themePrice' +
                    ' نقطة من حسابك لشراء هذه السمة ، هل انت متأكد من رغبتك بشراءها ؟',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('لا'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'شراء',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )).then((value) {
      if (value) _buyTheme(themeId, themePrice);
    });
  }

  Container _buildSingleColorPreview(Color color) {
    return Container(
      height: 40,
      width: 40,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    );
  }

  Widget _buildThemeItem(Map<String, dynamic> themeMap) {
    ThemeData themeData = themeMap['themeData'];
    int themePrice = themeMap['themePrice'];
    return GestureDetector(
      onTap: () => checkUserChoice(context, themeMap),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 2, color: Theme.of(context).primaryColor),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: double.infinity),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSingleColorPreview(themeData.primaryColor),
                      _buildSingleColorPreview(themeData.primaryColorLight),
                      _buildSingleColorPreview(themeData.accentColor),
                    ],
                  ),
                ],
              ),
            ),
            Divider(thickness: 2, color: Theme.of(context).primaryColor),
            Text(
              'النقاط $themePrice',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Column(
        children: [
          CustomPageLabel('متجر السمات'),
          Text(
            'عدد النقاط $userPoints',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 550,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: GridView.builder(
              itemCount: themesChoices.length,
              itemBuilder: (ctx, index) =>
                  _buildThemeItem(themesChoices[index]),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 1 / 0.6,
              ),
            ),
          )
        ],
      ),
    );
  }
}
