import 'package:flutter/material.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class ChartData {
  final String x;
  num y;
  ChartData({this.x, this.y = 0});
}

class StatisticsSection extends StatefulWidget {
  @override
  _StatisticsSectionState createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<StatisticsSection> {
  Map<String, dynamic> statistics = {};
  Map<String, dynamic> ReadBooksStat = {};

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  String _currentUser = '';
  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('username');
    var usercounts = await UserActions.getUserDatails(_currentUser);
    var readbookscount = await UserActions.getNumberOfReadBooks2(_currentUser);
    setState(() {
      statistics = usercounts;
      ReadBooksStat = readbookscount;
      print(statistics);
      data[0].y = statistics['numberOfRooms'];
      data[1].y = ReadBooksStat['readBooks'];
      data[2].y = statistics['numberOfFavourites'];
      data[3].y = statistics['numberOfRatings'];
      data[4].y = statistics['numberOfComments'];
    });
    GetReadBooksByCategory();
  }

  Future<void> GetReadBooksByCategory() async {
    final categoryNames = [
      'الروايات العربية',
      'الروايات المترجمة',
      'علم النفس',
      'التاريخ',
      'العلوم الإجتماعية',
      'المسرح العربي',
      'المسرح المترجم',
      'العلوم الإسلامية',
      'العلوم السياسية والاستراتيجية',
      'القصص القصيرة',
      'قصص أطفال',
      'السيرة الذاتية',
      'الأدب العربي',
      'الأدب المترجم',
      'الأدب الساخر',
      'التنمية البشرية',
      'الشعر العربي',
      'القسم العام',
    ];

    Map<String, dynamic> readbooksbycategory = {};
    List categoriescount = [];

    for (int i = 0; i < categoryNames.length; i++) {
      readbooksbycategory = await UserActions.getNumberOfReadBooksbyCategory(
          _currentUser, categoryNames[i]);
      categoriescount.add(readbooksbycategory['readBooks']);
      setState(() {
        data2[i].y = categoriescount[i];
      });
    }
  }

  List<ChartData> data = [
    ChartData(x: "عدد الغرف المنضم إليها", y: 0),
    ChartData(x: "عدد الكنب المقروءة", y: 0),
    ChartData(x: "عدد الكتب المفضلة", y: 0),
    ChartData(x: "عدد التقييمات", y: 0),
    ChartData(x: "عدد المراجعات", y: 0)
  ];

  List<ChartData> data2 = [
    ChartData(x: "الروايات العربية", y: 0),
    ChartData(x: "علم النفس", y: 0),
    ChartData(x: "التاريخ", y: 0),
    ChartData(x: "العلوم الإجتماعية", y: 0),
    ChartData(x: "المسرح العربي", y: 0),
    ChartData(x: "المسرح المترجم", y: 0),
    ChartData(x: "العلوم الإسلامية", y: 0),
    ChartData(x: "العلوم السياسية والاستر,اتيجية", y: 0),
    ChartData(x: "القصص القصيرة", y: 0),
    ChartData(x: "قصص أطفال", y: 0),
    ChartData(x: "السيرة الذاتية", y: 0),
    ChartData(x: "الأدب العربي", y: 0),
    ChartData(x: "الأدب العربي", y: 0),
    ChartData(x: "الأدب المترجم", y: 0),
    ChartData(x: "الأدب الساخر", y: 0),
    ChartData(x: "التنمية البشرية", y: 0),
    ChartData(x: "الشعر العربي", y: 0),
    ChartData(x: "القسم العام", y: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SfCircularChart(
                  legend: Legend(
                    isVisible: true,
                    alignment: ChartAlignment.center,
                    position: LegendPosition.left,
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CircularSeries>[
                    RadialBarSeries<ChartData, String>(
                      dataSource: data,
                      xValueMapper: (datum, index) => datum.x,
                      yValueMapper: (datum, index) => datum.y,
                      dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          margin: EdgeInsets.all(5),
                          textStyle: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 15,
                          )),
                      //enableSmartLabels: true,
                      gap: "0.1%",
                      cornerStyle: CornerStyle.endCurve,
                      innerRadius: "35%",
                      radius: "100",
                      legendIconType: LegendIconType.diamond,
                      // pointColorMapper: (datum, _) => theme.primaryColor,
                      //pointRadiusMapper: (datum, _) => datum.Category,
                    )
                  ]),
              SfCircularChart(
                  legend: Legend(
                    isVisible: true,
                    alignment: ChartAlignment.center,
                    position: LegendPosition.left,
                  ),
                  series: <CircularSeries>[
                    // Render pie chart
                    DoughnutSeries<ChartData, String>(
                        dataSource: data2,
                        //pointColorMapper:(ChartData data,  _) => data.color,
                        xValueMapper: (datum, index) => datum.x,
                        yValueMapper: (datum, index) => datum.y,
                        dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            margin: EdgeInsets.all(5),
                            textStyle: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 15,
                            )),
                        radius: "100",
                        innerRadius: "35%")
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
