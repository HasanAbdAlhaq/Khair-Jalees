import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:intl/intl.dart' as intl;

class BookCommentsSection extends StatelessWidget {
  final String currentUser;
  final List<Map<String, dynamic>> comments;
  final Function showModalFunction;
  final Function refreshStateFunction;

  BookCommentsSection({
    this.showModalFunction,
    this.comments,
    this.currentUser,
    this.refreshStateFunction,
  });

  void deleteSingleComment(BuildContext ctx, int commentId) async {
    showDialog(
        context: ctx,
        barrierColor: Theme.of(ctx).primaryColorLight.withOpacity(0.3),
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

  String formatCommentDate(String date) {
    return intl.DateFormat.yMMMd('ar_SA').format(DateTime.parse(date));
  }

  Widget buildCommentInfoListTile(
      BuildContext ctx, Map<String, dynamic> commentMap) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        title: Text(
          commentMap['fullName'],
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
          backgroundImage: NetworkImage(commentMap['userAvatar']),
        ),
        trailing: currentUser == commentMap['username']
            ? SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        showModalFunction();
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
              )
            : null,
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
    return ListView.builder(
        itemCount: comments.length,
        itemBuilder: (_, index) {
          return buildSingleComment(context, comments[index]);
        });
  }
}
