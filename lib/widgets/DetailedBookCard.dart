import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/database/user_actions.dart';
import 'package:grad_project/models/Book.dart';
import 'package:grad_project/screens/SingleBookScreen.dart';
import 'package:grad_project/widgets/CustomSnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailedBookCard extends StatefulWidget {
  final Book book;
  DetailedBookCard(this.book);

  @override
  _DetailedBookCardState createState() => _DetailedBookCardState();
}

class _DetailedBookCardState extends State<DetailedBookCard> {
  bool isBookFavourite = false;
  bool isBookRated = false;
  double newRating = 0.0;
  double oldRating = 0.0;
  String username = '';
  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    int bookId = this.widget.book.id;
    username = (await SharedPreferences.getInstance()).getString('username');
    bool isFavourite = await BookActions.isBookFavourite(username, bookId);
    bool isRated = await BookActions.isBookRated(username, bookId);
    if (isRated) oldRating = await BookActions.getBookRating(username, bookId);
    setState(() {
      isBookFavourite = isFavourite;
      isBookRated = isRated;
    });
  }

  void addBookAsFavourite(BuildContext ctx) async {
    int bookId = widget.book.id;

    int points = await UserActions.getUserPoints(username);
    int numOfFav = await UserActions.getNumberOfavourites(username);
    if ((numOfFav + 1) % 10 == 0)
      points += 8;
    else
      points += 3;
    UserActions.updatePoints(username, points);
    BookActions.addFavouriteBook(username, bookId);

    String snackbarMsg = 'تم إضافة الكتاب إلى المفضلة';
    setState(() {
      isBookFavourite = true;
      widget.book.numberOfFavourites += 1;
    });
    ScaffoldMessenger.of(ctx)
        .showSnackBar(CustomSnackBar(snackbarMsg).build(ctx));
  }

  void deleteBookFromFavourites(BuildContext ctx) async {
    int bookId = widget.book.id;
    BookActions.deleteFavouriteBook(username, bookId);
    String snackbarMsg = 'تم أزالة الكتاب من المفضلة';
    setState(() {
      isBookFavourite = false;
      widget.book.numberOfFavourites -= 1;
    });
    ScaffoldMessenger.of(ctx)
        .showSnackBar(CustomSnackBar(snackbarMsg).build(ctx));
  }

  void _updateBookRating() async {
    await BookActions.updateBookRating(username, widget.book.id, newRating);
    setState(() {
      widget.book.avgRating = _calcNewAvgRating();
      this.oldRating = this.newRating;
    });
  }

  void _addBookRating() async {
    // Update Points
    int points = await UserActions.getUserPoints(username);
    int numOfRatings = await UserActions.getNumberOfRatings(username);
    if ((numOfRatings + 1) % 10 == 0)
      points += 8;
    else
      points += 3;
    UserActions.updatePoints(username, points);

    await BookActions.addBookRating(username, widget.book.id, newRating);
    setState(() {
      widget.book.avgRating = _calcNewAvgRating();
      widget.book.numberOfRatings += 1;
      this.oldRating = this.newRating;
      isBookRated = true;
    });
  }

  double _calcNewAvgRating() {
    double originalRating = widget.book.numberOfRatings * widget.book.avgRating;
    if (isBookRated) {
      originalRating = originalRating - oldRating + newRating;
      originalRating = originalRating / widget.book.numberOfRatings;
    } else {
      originalRating =
          (originalRating + newRating) / (widget.book.numberOfRatings + 1);
    }
    return originalRating;
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'تقييم كتاب ${widget.book.title}',
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
                    if (isBookRated)
                      _updateBookRating();
                    else
                      _addBookRating();
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
              initialRating: isBookRated ? oldRating : 0.5,
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

  Widget _buildDetailsRow(BuildContext context, Book book) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                isBookFavourite
                    ? FontAwesomeIcons.solidHeart
                    : FontAwesomeIcons.heart,
                color: Colors.red,
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                '${book.numberOfFavourites}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                isBookRated
                    ? FontAwesomeIcons.solidStar
                    : FontAwesomeIcons.star,
                color: Colors.amber,
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                '${book.avgRating.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(FontAwesomeIcons.book, color: Colors.cyan, size: 16),
              SizedBox(width: 5),
              Text(
                '${book.numberOfPages}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover(BuildContext context, Book book) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed(
              SingleBookScreen.routeName,
              arguments: book.id,
            );
          },
          child: Container(
            width: constraints.maxWidth,
            height: 240,
            child: Image.network(
              book.coverLink,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  PopupMenuEntry _buildPopUpMenuItem(
    BuildContext ctx, {
    String choiceText,
    IconData choiceIcon,
    String choiceValue,
  }) {
    return PopupMenuItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(choiceText),
          SizedBox(width: 10),
          Icon(
            choiceIcon,
            color: Theme.of(ctx).primaryColorLight,
            size: 16,
          ),
        ],
      ),
      textStyle: TextStyle(
        color: Theme.of(ctx).primaryColor,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      value: choiceValue,
    );
  }

  Widget _buildPopUpMenu(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (ctx) => [
        _buildPopUpMenuItem(
          ctx,
          choiceText:
              isBookFavourite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
          choiceIcon: FontAwesomeIcons.solidHeart,
          choiceValue: isBookFavourite ? 'disFav' : 'Fav',
        ),
        _buildPopUpMenuItem(
          ctx,
          choiceText: isBookRated ? 'تعديل التقييم' : 'إضافة تقييم',
          choiceIcon: FontAwesomeIcons.solidStar,
          choiceValue: 'Rate',
        ),
      ],
      onSelected: (choice) {
        if (choice == 'Fav') addBookAsFavourite(context);
        if (choice == 'disFav') deleteBookFromFavourites(context);
        if (choice == 'Rate') _showRatingDialog(context);
      },
    );
  }

  Widget _buildBookInfoColumn(BuildContext context, Book book) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPopUpMenu(context),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${book.title}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${book.author}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(width: 2, color: Theme.of(context).primaryColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 10),
          _buildDetailsRow(context, widget.book),
          _buildBookCover(context, widget.book),
          Expanded(
            child: _buildBookInfoColumn(context, widget.book),
          )
        ],
      ),
    );
  }
}
