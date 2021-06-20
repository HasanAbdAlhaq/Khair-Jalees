import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/models/Book.dart';
import 'package:grad_project/screens/CategoryScreen.dart';

class BookInfoSection extends StatelessWidget {
  final Book currentBook;
  final String currentUser;
  final bool isBookFavourite;
  final bool isBookRated;
  final bool isBookCommented;
  final double oldRating;
  final Function showCommentModal;
  final Function refreshStateFunction;
  final Function showRoomModal;

  BookInfoSection(
      {this.currentBook,
      this.currentUser,
      this.isBookFavourite,
      this.isBookRated,
      this.isBookCommented,
      this.oldRating,
      this.showCommentModal,
      this.refreshStateFunction,
      this.showRoomModal});
  void _toggleFavouriteBook() async {
    if (isBookFavourite) {
      await BookActions.deleteFavouriteBook(currentUser, currentBook.id);
    } else {
      int points = await UserActions.getUserPoints(this.currentUser);
      int numOfFav = await UserActions.getNumberOfavourites(this.currentUser);
      if ((numOfFav + 1) % 10 == 0)
        points += 8;
      else
        points += 3;
      UserActions.updatePoints(this.currentUser, points);
      await BookActions.addFavouriteBook(this.currentUser, this.currentBook.id);
    }
    this.refreshStateFunction();
  }

  void _saveBookRating(double newRating) async {
    if (isBookRated)
      await BookActions.updateBookRating(
          currentUser, currentBook.id, newRating);
    else {
      // Update Points
      int points = await UserActions.getUserPoints(this.currentUser);
      int numOfRatings = await UserActions.getNumberOfRatings(this.currentUser);
      if ((numOfRatings + 1) % 10 == 0)
        points += 8;
      else
        points += 3;
      UserActions.updatePoints(this.currentUser, points);

      await BookActions.addBookRating(currentUser, currentBook.id, newRating);
    }
    this.refreshStateFunction();
  }

  Widget _buildButton(
    BuildContext context, {
    double width,
    String text,
    IconData icon,
    double sizingWidth,
    Function handler,
    MainAxisAlignment rowAlign = MainAxisAlignment.start,
  }) {
    return GestureDetector(
      onTap: handler,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            width: 1,
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: rowAlign,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: sizingWidth),
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    double newRating = 0.0;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'تقييم كتاب ${currentBook.title}',
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
                    _saveBookRating(newRating);
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
              initialRating: oldRating,
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

  Widget _buildInfoRow(BuildContext context, String infoText, IconData infoIcon,
      {Color iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(infoText,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 18,
            )),
        SizedBox(
          width: 10,
        ),
        Icon(
          infoIcon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 20,
        ),
        SizedBox(width: 10)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.only(top: 10),
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: 2,
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              Text(
                currentBook.title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 5),
              Divider(
                thickness: 2,
                color: Theme.of(context).primaryColor,
                height: 2,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoRow(
                                  context,
                                  currentBook.author,
                                  Icons.edit,
                                ),
                                _buildInfoRow(
                                  context,
                                  '${currentBook.publishYear}',
                                  FontAwesomeIcons.solidCalendarAlt,
                                ),
                                _buildInfoRow(
                                  context,
                                  '${currentBook.numberOfPages}',
                                  FontAwesomeIcons.solidFileAlt,
                                ),
                                _buildInfoRow(
                                  context,
                                  '${currentBook.numberOfFavourites}',
                                  FontAwesomeIcons.solidHeart,
                                  iconColor: Colors.red,
                                ),
                                _buildInfoRow(
                                  context,
                                  '${currentBook.avgRating.toStringAsFixed(1)}',
                                  FontAwesomeIcons.solidStar,
                                  iconColor: Theme.of(context).accentColor,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(
                                CategoryScreen.routeName,
                                arguments: currentBook.category,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Text(
                                currentBook.category,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                    Container(
                      width: 180,
                      decoration: BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15),
                        ),
                        child: Image.network(
                          currentBook.coverLink,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width,
          height: 45,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: _buildButton(
                  context,
                  handler: showCommentModal,
                  width: 180,
                  text: isBookCommented ? 'عدّل المراجعة' : 'أضف مراجعة',
                  icon: isBookCommented
                      ? FontAwesomeIcons.solidCommentAlt
                      : FontAwesomeIcons.commentAlt,
                  sizingWidth: 15,
                ),
              ),
              Positioned(
                right: 60,
                child: _buildButton(
                  context,
                  handler: () {
                    _showRatingDialog(context);
                  },
                  width: 170,
                  text: !isBookRated ? 'قيم الكتاب' : 'عدّل التقييم',
                  icon: isBookRated
                      ? FontAwesomeIcons.solidStar
                      : FontAwesomeIcons.star,
                  sizingWidth: 10,
                ),
              ),
              Positioned(
                right: 0,
                child: _buildButton(
                  context,
                  handler: _toggleFavouriteBook,
                  width: 110,
                  text: 'المفضلة',
                  icon: isBookFavourite
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  rowAlign: MainAxisAlignment.end,
                  sizingWidth: 5,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showRoomModal();
          },
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              'أنشئ غرفة لقراءة الكتاب',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 150,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 2,
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Text(
                currentBook.description,
                textAlign: TextAlign.right,
                softWrap: true,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
