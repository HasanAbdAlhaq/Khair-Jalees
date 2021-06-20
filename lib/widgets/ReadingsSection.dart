import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/SingleBookScreen.dart';
import '../database/book_actions.dart';

class ReadingsSection extends StatefulWidget {
  @override
  _ReadingsSectionState createState() => _ReadingsSectionState();
}

class _ReadingsSectionState extends State<ReadingsSection> {
  List<Map<String, dynamic>> books = [];
  String _username = '';

  initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    BookActions.getReadBooks(_username).then((value) {
      setState(() {
        books = value;
      });
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 1.2 / 2,
            crossAxisSpacing: 15,
            maxCrossAxisExtent: 180),
        itemCount: books.length,
        itemBuilder: (_, index) {
          Map<String, dynamic> book = books[index];
          return _buildFilterCard(book['id'], book['title'], book['coverLink']);
        },
      ),
    );
  }
}
