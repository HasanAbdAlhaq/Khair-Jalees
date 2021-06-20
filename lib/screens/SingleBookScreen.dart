import 'package:flutter/material.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/database/database_helper.dart';
import 'package:grad_project/modals/AddNewCommentModal.dart';
import 'package:grad_project/modals/AddNewRoomModal.dart';
import 'package:grad_project/modals/GenericModal.dart';
import 'package:grad_project/models/Book.dart';
import 'package:grad_project/widgets/BookCommentsSection.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/BookInfoSection.dart';
import '../models/Enums.dart';
import '../widgets/RecommendationSection.dart';

class SingleBookScreen extends StatefulWidget {
  static const routeName = '/Single-Book-Screen';
  final int bookId;
  SingleBookScreen({this.bookId});
  @override
  _SingleBookScreenState createState() => _SingleBookScreenState();
}

class _SingleBookScreenState extends State<SingleBookScreen> {
  BookScreenSelectedSection _selectedSection =
      BookScreenSelectedSection.bookSection;
  String _currentUser = '';
  bool _isBookFavourite = false;
  bool _isBookRated = false;
  double _oldRating = 0.5;
  bool _isBookCommented = false;
  Book _currentBook = Book();
  bool _isCommentModalShown = false;

  Map<String, dynamic> _commentMap;
  List<Map<String, dynamic>> listOfComments = [];
  bool _keyboardVisible = false;
  bool _isModalShown = false;

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('username');
    var singleBook = await BookActions.getSingleBook(widget.bookId);
    var isFavourite =
        await BookActions.isBookFavourite(_currentUser, widget.bookId);
    bool isRated = await BookActions.isBookRated(_currentUser, widget.bookId);
    if (isRated)
      _oldRating = await BookActions.getBookRating(_currentUser, widget.bookId);
    var singleComment =
        await BookActions.getSingleComment(_currentUser, widget.bookId);
    var comments = await BookActions.getAllCommentsFromBook(widget.bookId);

    setState(() {
      _currentBook = Book.fromMap(singleBook);
      _isBookFavourite = isFavourite;
      _isBookRated = isRated;
      _commentMap = singleComment;
      _isBookCommented = singleComment != null;
      listOfComments = comments;
    });
  }

  void _showCommentModal() async {
    setState(() {
      this._isCommentModalShown = true;
    });
  }

  void _hideCommentModal() async {
    setState(() {
      this._isCommentModalShown = false;
    });
  }

  void _showModal() {
    setState(() {
      this._isModalShown = true;
    });
  }

  void _hideModal() {
    setState(() {
      this._isModalShown = false;
    });
  }

  Widget _buildBottomBarButton(
      {IconData icon, Color buttonColor, Function pressHandler, String text}) {
    return GestureDetector(
      onTap: pressHandler,
      child: Column(
        children: [
          Icon(icon, color: buttonColor, size: 24),
          Text(text, style: TextStyle(color: buttonColor, fontSize: 20)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              if (this._selectedSection ==
                  BookScreenSelectedSection.bookSection)
                Expanded(
                  child: BookInfoSection(
                    currentBook: this._currentBook,
                    currentUser: this._currentUser,
                    isBookCommented: this._isBookCommented,
                    isBookFavourite: this._isBookFavourite,
                    isBookRated: this._isBookRated,
                    oldRating: this._oldRating,
                    showCommentModal: this._showCommentModal,
                    refreshStateFunction: this._setUp,
                    showRoomModal: this._showModal,
                  ),
                ),
              if (this._selectedSection ==
                  BookScreenSelectedSection.commentsSection)
                Expanded(
                  child: BookCommentsSection(
                    comments: this.listOfComments,
                    currentUser: this._currentUser,
                    showModalFunction: _showCommentModal,
                    refreshStateFunction: this._setUp,
                  ),
                ),
              if (this._selectedSection ==
                  BookScreenSelectedSection.recommendedSection)
                Expanded(
                  child: RecommendationSection(
                    bookId: this._currentBook.id,
                  ),
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
                        text: 'كتب مشابهة',
                        icon: Icons.library_books,
                        buttonColor: _selectedSection ==
                                BookScreenSelectedSection.recommendedSection
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColorLight,
                        pressHandler: () {
                          setState(() {
                            _selectedSection =
                                BookScreenSelectedSection.recommendedSection;
                          });
                        }),
                    _buildBottomBarButton(
                        text: 'المراجعات',
                        icon: Icons.comment,
                        buttonColor: _selectedSection ==
                                BookScreenSelectedSection.commentsSection
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColorLight,
                        pressHandler: () {
                          setState(() {
                            _selectedSection =
                                BookScreenSelectedSection.commentsSection;
                          });
                        }),
                    _buildBottomBarButton(
                        text: 'صفحة الكتاب',
                        icon: Icons.menu_book,
                        buttonColor: _selectedSection ==
                                BookScreenSelectedSection.bookSection
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColorLight,
                        pressHandler: () {
                          setState(() {
                            _selectedSection =
                                BookScreenSelectedSection.bookSection;
                          });
                        }),
                  ],
                ),
              ),
            ],
          ),
          if (_isCommentModalShown)
            GenericModal(
              hideModalFunction: _hideCommentModal,
              alignment: Alignment.topCenter,
              childWidget: AddNewCommentModal(
                commentId: _isBookCommented ? _commentMap['id'] : null,
                commentContent:
                    _isBookCommented ? _commentMap['commentContent'] : '',
                bookId: widget.bookId,
                username: _currentUser,
                refreshSatateBackFunction: this._setUp,
              ),
            ),
          if (_isModalShown)
            GenericModal(
              height: 450.0,
              hideModalFunction: this._hideModal,
              childWidget: AddNewRoomModal(
                booktitle: _currentBook.title,
                isInBookScreen: true,
              ),
            )
        ],
      ),
    );
  }
}
