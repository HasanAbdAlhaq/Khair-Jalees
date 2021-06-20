import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';
import 'package:grad_project/widgets/ReadingsSection.dart';
import '../models/Enums.dart';
import '../widgets/StatisticsSection.dart';

class ReadingsStatisticsScreen extends StatefulWidget {
  static const routeName = '/Reading-Statistics-Screen';

  @override
  _ReadingsStatisticsScreenState createState() =>
      _ReadingsStatisticsScreenState();
}

class _ReadingsStatisticsScreenState extends State<ReadingsStatisticsScreen> {
  ReadingsStatisticsSelectedSection _selectedSection =
      ReadingsStatisticsSelectedSection.readingsSection;

  Widget _buildBottomBarButton(
      {IconData icon, Color buttonColor, Function pressHandler, String text}) {
    return GestureDetector(
      onTap: pressHandler,
      child: Column(
        children: [
          Icon(
            icon,
            color: buttonColor,
            size: 24,
          ),
          Text(
            text,
            style: TextStyle(
              color: buttonColor,
              fontSize: 20,
            ),
          ),
        ],
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
          _selectedSection == ReadingsStatisticsSelectedSection.readingsSection
              ? CustomPageLabel('قراءاتي')
              : CustomPageLabel('احصائيات القراءة'),
          Expanded(
            child: _selectedSection ==
                    ReadingsStatisticsSelectedSection.readingsSection
                ? ReadingsSection()
                : StatisticsSection(),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomBarButton(
                    text: 'إحصائيات القراءة',
                    icon: FontAwesomeIcons.chartPie,
                    buttonColor: _selectedSection ==
                            ReadingsStatisticsSelectedSection.statisticsSection
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColorLight,
                    pressHandler: () {
                      setState(() {
                        _selectedSection =
                            ReadingsStatisticsSelectedSection.statisticsSection;
                      });
                    }),
                _buildBottomBarButton(
                    text: 'الكتب المقروءة',
                    icon: FontAwesomeIcons.bookReader,
                    buttonColor: _selectedSection ==
                            ReadingsStatisticsSelectedSection.readingsSection
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColorLight,
                    pressHandler: () {
                      setState(() {
                        _selectedSection =
                            ReadingsStatisticsSelectedSection.readingsSection;
                      });
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
