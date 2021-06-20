import 'package:flutter/material.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../database/room_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookPdfScreen extends StatefulWidget {
  static const routeName = '/book-Page';

  final Object arguments;
  int bookId;
  int roomId;
  String roomName;
  String title;
  String coverLink;

  BookPdfScreen({this.arguments}) {
    this.bookId = (arguments as Map<String, dynamic>)['bookId'];
    this.roomId = (arguments as Map<String, dynamic>)['roomId'];
    this.roomName = (arguments as Map<String, dynamic>)['roomName'];
    this.title = (arguments as Map<String, dynamic>)['title'];
    this.coverLink = (arguments as Map<String, dynamic>)['coverLink'];
  }

  @override
  _BookPdfScreenState createState() => _BookPdfScreenState();
}

class _BookPdfScreenState extends State<BookPdfScreen> {
  //to controll pages
  PdfViewerController _pdfViewerController;

  bool isExpand = false;
  String userName = '';
  int userReadPages = 1;

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void checkUserChoice(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: Text(
                'استكمال القراءة',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'لقد قرأت' +
                    ' ${this.userReadPages} ' +
                    'صفحة من هذا الكتاب ، هل تود استكمال القراءة من حيث بدأت ؟ ',
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
                    'استكمال القراءة',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )).then((value) {
      if (value) {
        _pdfViewerController.jumpToPage(this.userReadPages);
      }
    });
  }

  void _setUp() async {
    _pdfViewerController = PdfViewerController();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username');
    RoomActions.getRoomMembers(widget.roomId).then((value) {
      Map member =
          value.firstWhere((element) => element['username'] == userName);
      this.userReadPages = member['readPages'];
    });
  }

  void pdf(int choice) {
    if (choice == 0) {
      _pdfViewerController.jumpToPage(userReadPages);
    } else if (choice == 1)
      _pdfViewerController.nextPage();
    else if (choice == 2)
      _pdfViewerController.previousPage();
    else if (choice == 3)
      expandPDf();
    else if (choice == 4) stopExpand();
  }

  int count = 1;
  void pagecount(int d) {
    setState(() {
      count = d;
    });
  }

  void expandPDf() {
    setState(() {
      isExpand = true;
    });
  }

  void stopExpand() {
    setState(() {
      isExpand = false;
    });
  }

  void _savePageToDB() async {
    if (_pdfViewerController.pageCount == this.count) {
      // Update Points
      int points = await UserActions.getUserPoints(userName);
      int numOfBooks = await UserActions.getNumberOfReadBooks(userName);
      if ((numOfBooks + 1) % 5 == 0)
        points += 80;
      else
        points += 55;
      UserActions.updatePoints(userName, points);
      /////////////////////////////////////////////////////////////////////////
    }
    RoomActions.saveBookPageNumber(userName, widget.roomId, this.count);
  }

  //for header(appbar)
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

  //buttons
  Widget _buildBottomButtons({
    BuildContext context,
    childIcon,
    int choiceAction,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => pdf(choiceAction),
      child: Container(
        margin: EdgeInsets.all(8),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            radius: 24,
            child: childIcon,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!isExpand)
      return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
              iconTheme: IconThemeData(
                color: theme.accentColor, //change your color here
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _savePageToDB();
                  Navigator.of(context).pop();
                },
              ),
              title: buildRoomItem(context),
            ),
          ),
          body: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: SfPdfViewer.asset(
                      "assets/غسيل الدماغ.pdf", //قائمة المعارف
                      controller: _pdfViewerController,
                      onPageChanged: (details) {
                        pagecount(details.newPageNumber);
                      },
                      onDocumentLoaded: (_) {
                        checkUserChoice(context);
                      },
                    ),
                  ),
                  _buildBottomButtons(
                      context: context,
                      childIcon: Icon(
                        Icons.fullscreen,
                        color: theme.primaryColor,
                        size: 27,
                      ),
                      choiceAction: 3)
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomButtons(
                      context: context,
                      childIcon: Icon(
                        Icons.remove,
                        color: theme.primaryColor,
                        size: 27,
                      ),
                      choiceAction: 2,
                    ),
                    Text(
                      count.toString(),
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    _buildBottomButtons(
                      context: context,
                      childIcon: Icon(
                        Icons.add,
                        color: theme.primaryColor,
                        size: 27,
                      ),
                      choiceAction: 1,
                    )
                  ],
                ),
              )
            ],
          ));
    else
      return Scaffold(
        body: Stack(
          children: [
            Container(
              child: SfPdfViewer.asset(
                "assets/غسيل الدماغ.pdf", //قائمة المعارف
              ),
            ),
            Positioned(
              top: -20.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                title: Text(''),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: theme.primaryColor),
                  onPressed: () => pdf(4),
                ),
                backgroundColor: theme.accentColor.withOpacity(0.2),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
  }
}
