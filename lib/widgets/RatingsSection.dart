import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/book_actions.dart';

class RatingsSection extends StatelessWidget {
  final List<Map<String, dynamic>> ratedBooks;
  final String currentUser;
  final Function refreshStateFunction;

  RatingsSection(
      {this.ratedBooks, this.currentUser, this.refreshStateFunction});

  void _saveBookRating(int bookId, double newRating) async {
    await BookActions.updateBookRating(currentUser, bookId, newRating);
    refreshStateFunction();
  }

  void _deleteRating(Map<String, dynamic> map) async {
    int bookId = map['id'];
    await BookActions.deleteRatedBook(currentUser, bookId);
    refreshStateFunction();
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> bookMap) {
    double newRating = 0.0;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'تقييم كتاب ${bookMap['title']}',
              textAlign: TextAlign.right,
            ),
            titleTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _saveBookRating(bookMap['id'], newRating);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'حفظ التقييم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ))
            ],
            content: RatingBar.builder(
              textDirection: TextDirection.rtl,
              initialRating: bookMap['ratingValue'],
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              unratedColor:
                  Theme.of(context).primaryColorLight.withOpacity(0.6),
              itemCount: 5,
              itemSize: 40.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Theme.of(context).primaryColor,
              ),
              onRatingUpdate: (rating) {
                newRating = rating;
              },
              updateOnDrag: true,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1 / 1.55,
          crossAxisSpacing: 5,
        ),
        itemCount: ratedBooks.length,
        itemBuilder: (ctx, index) {
          Map<String, dynamic> ratedBookMap = ratedBooks[index];
          return Container(
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LayoutBuilder(
                  builder: (_, constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      height: 240,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Image.network(
                          ratedBookMap['coverLink'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Theme.of(ctx).primaryColor,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          GestureDetector(
                            child: Icon(
                              FontAwesomeIcons.solidTrashAlt,
                              color: Colors.red,
                              size: 20,
                            ),
                            onTap: () {
                              _deleteRating(ratedBookMap);
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              _showRatingDialog(ctx, ratedBookMap);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${ratedBookMap['ratingValue']}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  FontAwesomeIcons.solidStar,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
