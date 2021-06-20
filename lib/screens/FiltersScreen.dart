import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/screens/DetailedFitersScreen.dart';
import 'package:grad_project/screens/SingleBookScreen.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomButton.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:custom_sheet/custom_sheet.dart';
import './SuggestBookScreen.dart';

class FiltersScreen extends StatefulWidget {
  // Constants
  static const routeName = '/Filters-Page';

  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  List<Map<String, dynamic>> books = [];
  bool _isOrderDescending = true;

  void _toogleOrderingMethod() {
    setState(() {
      _isOrderDescending = !_isOrderDescending;
      print(_isOrderDescending);
    });
  }

  void _getFilteredBooks(Map<String, dynamic> filtersMap) async {
    List<Map<String, dynamic>> filteredBooks =
        await BookActions.getFilteredBooks(
      minPage: filtersMap['minPage'],
      maxPage: filtersMap['maxPage'],
      minYear: filtersMap['minYear'],
      maxYear: filtersMap['maxYear'],
      minAvgRating: filtersMap['minRating'],
      maxAvgRating: filtersMap['maxRating'],
      author: filtersMap['author'],
      categories: filtersMap['categories'] as List<String>,
    );
    setState(() {
      books = filteredBooks
          .where((element) =>
              element['avgRating'] == null ||
              element['avgRating'] >= filtersMap['minRating'] &&
                  element['avgRating'] <= filtersMap['maxRating'])
          .toList();
    });
  }

  Widget _buildFilterCard(int bookId, String booktitle, String bookCover) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(
          SingleBookScreen.routeName,
          arguments: bookId,
        );
      },
      borderRadius: BorderRadius.circular(30),
      splashColor: Theme.of(context).primaryColor,
      child: Container(
        child: Card(
          elevation: 0,
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      bookCover,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  booktitle,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext ctx) {
    CustomSheet(ctx,
            textColor: Theme.of(ctx).primaryColor,
            subTextColor: Theme.of(ctx).primaryColor,
            secondColor: Theme.of(ctx).scaffoldBackgroundColor,
            sheetColor: Theme.of(ctx).scaffoldBackgroundColor)
        .showBS(
            blockBackButton: false,
            top: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: _toogleOrderingMethod,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'ترتيب حسب (${_isOrderDescending ? 'تنازلياً' : 'تصاعدياً'})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(ctx).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            options: <OptionButton>[
          OptionButton("سنة النشر", () {
            setState(() {
              BookActions.orderBooksByYear(_isOrderDescending)
                  .then((value) => this.books = value);
            });
          }),
          OptionButton("عدد الصفحات", () {
            setState(() {
              BookActions.orderBooksByPages(_isOrderDescending)
                  .then((value) => this.books = value);
            });
          }),
          OptionButton("التقييم العام", () {
            setState(() {
              BookActions.orderBooksByRating(_isOrderDescending)
                  .then((value) => this.books = value);
            });
          }),
          OptionButton("عدد التفضيلات", () {
            setState(() {
              BookActions.orderBooksByFavourites(_isOrderDescending)
                  .then((value) => this.books = value);
            });
          }),
        ]);
  }

  Widget _buildFiltersButton({String title, bool isMain, buttonhandler}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.39,
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isMain
                ? Icon(
                    Icons.filter_list,
                    size: 25,
                  )
                : InkWell(
                    onTap: _toogleOrderingMethod,
                    child: Icon(
                      _isOrderDescending
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                    ),
                  ),
            Text(title, style: TextStyle(fontSize: 18)),
          ],
        ),
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(8)),
            foregroundColor: MaterialStateProperty.all<Color>(isMain
                ? Theme.of(context).primaryColor
                : Theme.of(context).accentColor),
            backgroundColor: MaterialStateProperty.all<Color>(isMain
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(
                        color: isMain
                            ? Theme.of(context).accentColor
                            : Theme.of(context).primaryColor)))),
        onPressed: buttonhandler,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: CustomAppBar(),
        endDrawer: CustomDrawer(),
        body: Container(
          padding: EdgeInsets.all(25),
          color: theme.scaffoldBackgroundColor,
          height: MediaQuery.of(context).size.height * 0.88,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFiltersButton(
                        title: "مرشحات",
                        isMain: true,
                        buttonhandler: () {
                          Navigator.of(context)
                              .pushNamed(DetailedFiltersScreen.routeName)
                              .then((value) {
                            _getFilteredBooks(value);
                          });
                        },
                      ),
                      _buildFiltersButton(
                        title: "ترتيب حسب",
                        isMain: false,
                        buttonhandler: () {
                          _showBottomSheet(context);
                        },
                      ),
                    ]),
              ),
              SizedBox(
                height: 22,
              ),
              Expanded(
                child: books.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'إن لم تجد الكتاب الذي تبحث عنه قم بإقتراحه علينا لإضافته في أقرب وقت ممكن',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Column(
                            children: [
                              CustomButton(
                                text: 'أقترح كتاب جديد',
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(SuggestBookScreen.routeName);
                                },
                                width: 225,
                                fontsize: 20,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'أقتراح كتاب سيخصم 100 نقطة من مجموع نقاطك',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            childAspectRatio: 1.2 / 2,
                            crossAxisSpacing: 15,
                            maxCrossAxisExtent: 180),
                        itemCount: books.length,
                        itemBuilder: (_, index) {
                          Map<String, dynamic> book = books[index];
                          return _buildFilterCard(
                              book['id'], book['title'], book['coverLink']);
                        },
                      ),
              ),
            ],
          ),
        ));
  }
}
