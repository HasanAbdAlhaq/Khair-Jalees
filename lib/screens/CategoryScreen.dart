import 'package:flutter/material.dart';
import 'package:grad_project/widgets/CustomPageLabel.dart';

import '../database/book_actions.dart';
import '../models/Book.dart';

import '../widgets/CustomAppBar.dart';
import '../widgets/CustomDrawer.dart';
import '../widgets/DetailedBookCard.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/Category-Screen';
  final String categoryName;
  CategoryScreen({this.categoryName});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Book> listOfBooks = [];

  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void _setUp() async {
    var list = await BookActions.getAllCategoryBooks(widget.categoryName);
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
      body: Stack(
        children: [
          Column(
            children: [
              CustomPageLabel(widget.categoryName),
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
        ],
      ),
    );
  }
}
