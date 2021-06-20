import 'package:flutter/material.dart';
import 'package:grad_project/database/user_actions.dart';
import '../widgets/CustomLabel.dart';
import '../widgets/CustomInputTextField.dart';
import '../widgets/CustomButton.dart';
import '../database/book_actions.dart';

class AddNewCommentModal extends StatefulWidget {
  final int commentId;
  final int bookId;
  final String username;
  final String commentContent;
  final Function refreshSatateBackFunction;
  AddNewCommentModal({
    this.commentId,
    this.bookId,
    this.username,
    this.commentContent,
    this.refreshSatateBackFunction,
  });

  @override
  _AddNewCommentModalState createState() => _AddNewCommentModalState();
}

class _AddNewCommentModalState extends State<AddNewCommentModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String newCommentContent;

  @override
  void initState() {
    super.initState();
  }

  void _editComment() async {
    final form = _formKey.currentState;
    form.save();
    await BookActions.updateUserReview(widget.commentId, newCommentContent);
    this.widget.refreshSatateBackFunction();
  }

  void _addComment() async {
    final form = _formKey.currentState;
    form.save();

    // Update Points
    int points = await UserActions.getUserPoints(this.widget.username);
    int numOfComments =
        await UserActions.getNumberOfComments(this.widget.username);
    if ((numOfComments + 1) % 10 == 0)
      points += 16;
    else
      points += 6;
    UserActions.updatePoints(this.widget.username, points);
    /////////////////////////////////////////////////////////////////////////

    await BookActions.addNewComment(
        widget.username, widget.bookId, this.newCommentContent);
    this.widget.refreshSatateBackFunction();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 140,
            child: CustomLabel('أضف مراجعة'),
          ),
          SizedBox(),
          Form(
            key: _formKey,
            child: CustomInputTextField(
              label: '',
              onSaved: (value) {
                newCommentContent = value;
              },
              validator: (_) {},
              maxLines: 8,
              maxLength: 300,
              initialValue: this.widget.commentContent,
            ),
          ),
          CustomButton(
            onPressed: widget.commentId == null ? _addComment : _editComment,
            text: 'أضف',
            width: 150,
          ),
        ],
      ),
    );
  }
}
