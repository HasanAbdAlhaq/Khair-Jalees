import 'package:flutter/material.dart';
import '../database/user_actions.dart';

class ProfileContactsSection extends StatefulWidget {
  final String currentUser;
  List<Map<String, dynamic>> contacts;
  ProfileContactsSection({this.currentUser, this.contacts});
  @override
  _ProfileContactsSectionState createState() => _ProfileContactsSectionState();
}

class _ProfileContactsSectionState extends State<ProfileContactsSection> {
  final _defaultAvatarURL = 'https://via.placeholder.com/150/4c064d?text= ';

  void _deleteSingleContact(String contactId) async {
    await UserActions.deleteContact(widget.currentUser, contactId);
    setState(() {
      widget.contacts
          .removeWhere((element) => element['contactId'] == contactId);
    });
  }

  Future<bool> _confirmContactDeletion(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف من قائمة المعارف',
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'هل تريد حذف هذا المستخدم من قائمة معارفك ؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final spaceavaialable = mediaQuery.size.height - 110;
    return Container(
      color: theme.scaffoldBackgroundColor,
      height: spaceavaialable * 0.6,
      width: mediaQuery.size.width * 0.85,
      child: widget.contacts.length > 0
          ? ListView.builder(
              itemCount: widget.contacts.length,
              itemBuilder: (ctx, index) {
                Map<String, dynamic> singleContact = widget.contacts[index];
                return Dismissible(
                  direction: DismissDirection.startToEnd,
                  onDismissed: (_) {
                    _deleteSingleContact(singleContact['contactId']);
                  },
                  confirmDismiss: (_) => _confirmContactDeletion(context),
                  key: UniqueKey(),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 2,
                        color: theme.primaryColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: ListTile(
                      title: Text(
                        singleContact['fullName'],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                      trailing: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            singleContact['userAvatar'] ?? _defaultAvatarURL),
                      ),
                      subtitle: Text(
                        singleContact['contactId'],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: theme.primaryColorLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'ليس لديك أي معارف حتى الآن',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
