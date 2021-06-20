import 'package:flutter/material.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Enums.dart';
import '../widgets/RatingsSection.dart';
import '../widgets/ReviewsSection.dart';
import '../modals/GenericModal.dart';
import '../modals/AddNewCommentModal.dart';

class CommentsRatingsScreen extends StatefulWidget {
  static const routeName = '/Comments-Ratings-Screen';
  @override
  _CommentsRatingsScreenState createState() => _CommentsRatingsScreenState();
}

class _CommentsRatingsScreenState extends State<CommentsRatingsScreen> {
  String username = '';
  CommentsRatingsSelectedSection _selectedSection =
      CommentsRatingsSelectedSection.ratingsSection;
  List<Map<String, dynamic>> ratedBooks = [];
  List<Map<String, dynamic>> userComments = [];

  bool _isEditCommentModalShown = false;
  int _editCommentWithId = 0;
  String _editCommentWithContent = '';

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _showEditCommentModal(int commentId, String commentContent) {
    setState(() {
      _editCommentWithId = commentId;
      _editCommentWithContent = commentContent;
      _isEditCommentModalShown = true;
    });
  }

  void _hideEditCommentModal() {
    setState(() {
      _isEditCommentModalShown = false;
    });
  }

  void _setUp() async {
    username = (await SharedPreferences.getInstance()).getString('username');
    var foundBooks = await BookActions.getAllRatedBooks(username);
    var foundComments = await BookActions.getAllCommentsFromUser(username);
    setState(() {
      ratedBooks = foundBooks;
      userComments = foundComments;
    });
  }

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
      backgroundColor: Colors.white,
      endDrawer: CustomDrawer(),
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _selectedSection == CommentsRatingsSelectedSection.ratingsSection
                  ? CustomPageLabel('التقييمات')
                  : CustomPageLabel('المراجعات'),
              _selectedSection == CommentsRatingsSelectedSection.ratingsSection
                  ? RatingsSection(
                      currentUser: this.username,
                      ratedBooks: this.ratedBooks,
                      refreshStateFunction: this._setUp,
                    )
                  : ReviewsSection(
                      currentUser: this.username,
                      userComments: this.userComments,
                      refreshStateFunction: this._setUp,
                      showEditModalFunction: this._showEditCommentModal,
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
                        text: 'المراجعات',
                        icon: Icons.comment,
                        buttonColor: _selectedSection ==
                                CommentsRatingsSelectedSection.commentsSection
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColorLight,
                        pressHandler: () {
                          setState(() {
                            _selectedSection =
                                CommentsRatingsSelectedSection.commentsSection;
                          });
                        }),
                    _buildBottomBarButton(
                        text: 'التقييمات',
                        icon: Icons.star,
                        buttonColor: _selectedSection ==
                                CommentsRatingsSelectedSection.ratingsSection
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColorLight,
                        pressHandler: () {
                          setState(() {
                            _selectedSection =
                                CommentsRatingsSelectedSection.ratingsSection;
                          });
                        }),
                  ],
                ),
              ),
            ],
          ),
          if (_isEditCommentModalShown)
            GenericModal(
              hideModalFunction: _hideEditCommentModal,
              childWidget: AddNewCommentModal(
                commentId: this._editCommentWithId,
                commentContent: this._editCommentWithContent,
                refreshSatateBackFunction: this._setUp,
              ),
              alignment: Alignment.bottomCenter,
            ),
        ],
      ),
    );
  }
}
