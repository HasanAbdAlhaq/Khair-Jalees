import 'package:flutter/material.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/models/Book.dart';
import 'package:grad_project/widgets/CustomAppBar.dart';
import 'package:grad_project/widgets/CustomDrawer.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/DetailedBookCard.dart';

class FavouritesScreen extends StatefulWidget {
  static const routeName = '/Favourites-Screen';
  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Book> listOfBooks = [];
  String username = '';
  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    var list = await BookActions.getAllFavouriteBooks(username);
    setState(() {
      listOfBooks = list.map((e) => Book.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Column(
        children: [
          CustomPageLabel('المفضلة'),
          Expanded(
            child: Container(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.8,
                ),
                itemCount: listOfBooks.length,
                itemBuilder: (_, index) {
                  Book book = listOfBooks[index];
                  return DetailedBookCard(book);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
