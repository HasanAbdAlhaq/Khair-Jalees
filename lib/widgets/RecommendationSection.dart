import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grad_project/database/book_actions.dart';
import 'package:grad_project/models/Book.dart';
import 'package:grad_project/widgets/DetailedBookCard.dart';
import 'package:http/http.dart' as http;

class RecommendationSection extends StatefulWidget {
  final int bookId;
  RecommendationSection({this.bookId});
  @override
  _RecommendationSectionState createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  List<Book> recommendedBooks = [];
  bool _isLoading = true;
  @override
  void initState() {
    _setUp();
    super.initState();
  }

  void addBookById(bookId) async {
    var map = await BookActions.getSingleBook(bookId);
    this.recommendedBooks.add(Book.fromMap(map));
  }

  void _setUp() async {
    final String recommendationSystemURL =
        'http://10.0.2.2/Sandbox/test_py.php?bookId=${widget.bookId}';
    var response = await http.get(recommendationSystemURL);
    var x = jsonDecode(response.body)['recommendedBooks'];
    // var listOfBookIDs = [3 - widget.bookId];
    setState(() {
      x.forEach(addBookById); // Should Be X
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.8,
              ),
              itemCount: recommendedBooks.length,
              itemBuilder: (_, index) {
                Book book = recommendedBooks[index];
                return DetailedBookCard(book);
              },
            ),
          );
  }
}
