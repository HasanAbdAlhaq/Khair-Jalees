import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../database/book_actions.dart';

class ReviewsSection extends StatelessWidget {
  final List<Map<String, dynamic>> userComments;
  final String currentUser;
  final Function refreshStateFunction;
  final Function showEditModalFunction;

  ReviewsSection({
    this.userComments,
    this.currentUser,
    this.refreshStateFunction,
    this.showEditModalFunction,
  });

  String formatCommentDate(String date) {
    return intl.DateFormat.yMMMd('ar_SA').format(DateTime.parse(date));
  }

  void deleteSingleComment(BuildContext ctx, int commentId) async {
    showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
              title: Text(
                'تأكيد الحذف',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'هل أنت متأكد من رغبتك في حذف هذه المراجعة ؟',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    'حذف',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )).then((value) async {
      if (value) {
        await BookActions.deleteComment(commentId);
        this.refreshStateFunction();
      }
    });
  }

  Widget buildCommentInfoListTile(
      BuildContext ctx, Map<String, dynamic> commentMap) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        title: Text(
          commentMap['title'],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(ctx).primaryColor,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          formatCommentDate(commentMap['commentDate']),
          style: TextStyle(
            color: Theme.of(ctx).primaryColorLight,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(commentMap['coverLink']),
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  this.showEditModalFunction(
                    commentMap['id'],
                    commentMap['commentContent'],
                  );
                },
                icon: Icon(
                  FontAwesomeIcons.solidEdit,
                  color: Theme.of(ctx).primaryColorLight,
                  size: 18,
                ),
              ),
              IconButton(
                onPressed: () {
                  deleteSingleComment(ctx, commentMap['id']);
                },
                icon: Icon(
                  FontAwesomeIcons.solidTrashAlt,
                  color: Colors.red,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSingleComment(BuildContext ctx, Map<String, dynamic> commentMap) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(ctx).scaffoldBackgroundColor,
        border: Border.all(
          width: 2,
          color: Theme.of(ctx).primaryColor,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      height: 125 + (commentMap['commentContent'].length * 0.35),
      child: Column(
        children: [
          buildCommentInfoListTile(ctx, commentMap),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Text(
                  commentMap['commentContent'],
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Theme.of(ctx).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: userComments.length,
        itemBuilder: (ctx, index) {
          return buildSingleComment(ctx, userComments[index]);
        },
      ),
    );
  }
}
