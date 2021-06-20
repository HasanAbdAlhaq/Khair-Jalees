import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grad_project/database/database_helper.dart';

class BookActions {
  static DatabaseHelper dbConnection = new DatabaseHelper();
  static Future<Map<String, dynamic>> getSingleBook(int bookId) async {
    var dbClient = await dbConnection.db;
    final singleBook = await dbClient.rawQuery('''
    select Books.* , 
    count(DISTINCT UserFavourites.id) as numberOfFavourites,
    COUNT(DISTINCT UserRatings.id) as numberOfRatings,
    avg(UserRatings.ratingValue) as avgRating
    FROM Books 
    LEFT join UserFavourites 
    on UserFavourites.bookid = Books.id
    LEFT JOIN Comments
    on Comments.bookid = Books.id
    LEFT join UserRatings
    on UserRatings.bookId = Books.id
    where Books.id = ?;
    ''', [bookId]);
    return singleBook.first;
  }

  static Future<List<Map<String, dynamic>>> getAllCategoryBooks(
      String categoryName) async {
    var dbClient = await dbConnection.db;
    final booksFound = await dbClient.rawQuery('''
    select Books.* , 
    count(DISTINCT UserFavourites.id) as numberOfFavourites,
    COUNT(DISTINCT UserRatings.id) as numberOfRatings,
    avg(UserRatings.ratingValue) as avgRating
    FROM Books 
    LEFT join UserFavourites 
    on UserFavourites.bookid = Books.id
    LEFT JOIN Comments
    on Comments.bookid = Books.id
    LEFT join UserRatings
    on UserRatings.bookId = Books.id
    where Books.category = ?
    GROUP by Books.id;
    ''', [categoryName]);
    return booksFound;
  }

  static Future<List<Map<String, dynamic>>> getAllFavouriteBooks(
      String userName) async {
    var dbClient = await dbConnection.db;
    final booksFound = await dbClient.rawQuery('''
    select Books.* , 
    count(DISTINCT UserFavourites.id) as numberOfFavourites,
    COUNT(DISTINCT UserRatings.id) as numberOfRatings,
    avg(UserRatings.ratingValue) as avgRating
    FROM Books 
    LEFT join UserFavourites 
    on UserFavourites.bookid = Books.id
    LEFT JOIN Comments
    on Comments.bookid = Books.id
    LEFT join UserRatings
    on UserRatings.bookId = Books.id
    where UserFavourites.userId = ?
    GROUP by Books.id;
    ''', [userName]);
    return booksFound;
  }

  static Future<bool> isBookFavourite(String username, int bookId) async {
    var dbClient = await dbConnection.db;
    var recordFound = await dbClient.query('UserFavourites',
        where: 'userId = ? AND bookId = ?', whereArgs: [username, bookId]);
    return recordFound.length > 0;
  }

  static Future<void> addFavouriteBook(String username, int bookId) async {
    var dbClient = await dbConnection.db;
    await dbClient.insert('UserFavourites', {
      'userId': username,
      'bookId': bookId,
    });
  }

  static Future<void> deleteFavouriteBook(String username, int bookId) async {
    var dbClient = await dbConnection.db;
    await dbClient.delete(
      'UserFavourites',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [
        username,
        bookId,
      ],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllRatedBooks(
      String userName) async {
    var dbClient = await dbConnection.db;
    final booksFound = await dbClient.rawQuery('''
    select Books.id , Books.title , Books.coverLink, UserRatings.ratingvalue
    From BOOKS JOIN UserRatings ON Books.id = UserRatings.bookId
    where UserRatings.userId = ?;
    ''', [userName]);
    return booksFound;
  }

  static Future<bool> isBookRated(String username, int bookId) async {
    var dbClient = await dbConnection.db;
    var recordFound = await dbClient.query('UserRatings',
        where: 'userId = ? AND bookId = ?', whereArgs: [username, bookId]);
    return recordFound.length > 0;
  }

  static Future<double> getBookRating(String username, bookId) async {
    var dbClient = await dbConnection.db;
    var recordFound = await dbClient.query('UserRatings',
        where: 'userId = ? AND bookId = ?', whereArgs: [username, bookId]);
    return recordFound.first['ratingValue'];
  }

  static Future<void> addBookRating(
      String username, int bookId, double value) async {
    var dbClient = await dbConnection.db;
    await dbClient.insert('UserRatings', {
      'userId': username,
      'bookId': bookId,
      'ratingValue': value,
    });
  }

  static Future<void> updateBookRating(
      String username, int bookId, double newValue) async {
    var dbClient = await dbConnection.db;
    await dbClient.update(
      'UserRatings',
      {
        'ratingValue': newValue,
      },
      where: 'userId = ? AND bookId = ?',
      whereArgs: [username, bookId],
    );
  }

  static Future<void> deleteRatedBook(String username, int bookId) async {
    var dbClient = await dbConnection.db;
    await dbClient.delete(
      'UserRatings',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [username, bookId],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllCommentsFromUser(
      String userName) async {
    var dbClient = await dbConnection.db;
    final booksFound = await dbClient.rawQuery('''
    select Books.title, Books.coverlink, Comments.id , Comments.commentcontent, Comments.commentDate
    FROM Books
    Join Comments 
    On Books.id = Comments.bookId 
    where Comments.userid = ?; 
    ''', [userName]);
    return booksFound;
  }

  static Future<void> deleteComment(int commentId) async {
    var dbClient = await dbConnection.db;
    await dbClient.delete(
      'Comments',
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  static Future<void> updateUserReview(
      int commentId, String commentContent) async {
    var dbClient = await dbConnection.db;
    var commentDate = DateTime.now().toString();
    await dbClient.update(
      'Comments',
      {
        'commentContent': commentContent,
        'commentDate': commentDate,
      },
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  static Future<void> addNewComment(
      String username, int bookId, String commentContent) async {
    var dbClient = await dbConnection.db;
    await dbClient.insert('Comments', {
      'userId': username,
      'bookId': bookId,
      'commentContent': commentContent,
      'commentDate': DateTime.now().toString(),
    });
  }

  static Future<Map<String, dynamic>> getSingleComment(
      String username, int bookId) async {
    var dbClient = await dbConnection.db;
    var books = await dbClient.query(
      'Comments',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [username, bookId],
    );
    return books.length > 0 ? books.first : null;
  }

  static Future<List<Map<String, dynamic>>> getAllCommentsFromBook(
      int bookId) async {
    var dbClient = await dbConnection.db;
    final commentsFound = await dbClient.rawQuery('''
    select Users.fullName, Users.username, Users.userAvatar,
    Comments.id , Comments.commentcontent, Comments.commentDate
    FROM Users
    Join Comments 
    On Users.username = Comments.userId 
    where Comments.bookId = ?; 
    ''', [bookId]);
    return commentsFound;
  }

  static Future<List<Map<String, dynamic>>> getFilteredBooks({
    int minYear,
    int maxYear,
    int minPage,
    int maxPage,
    List<String> categories,
    String author,
    double minAvgRating,
    double maxAvgRating,
  }) async {
    var dbClient = await dbConnection.db;
    String categoriesString = categories
        .map((e) => "'$e'")
        .toList()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');

    final booksFound = await dbClient.rawQuery('''
    select Books.id, Books.coverLink, Books.title, AVG(UserRatings.ratingValue) as avgRating 
    From Books left Join UserRatings ON UserRatings.bookId = Books.id 
    where publishYear between ? and ? 
    and numberOfPages between ? and ? 
    and author like '%$author%' 
    and category IN ($categoriesString)
    group by Books.id ;
    ''', [minYear, maxYear, minPage, maxPage]);
    return booksFound;
  }

  static Future<List<Map<String, dynamic>>> getAllBooks() async {
    var dbClient = await dbConnection.db;
    var listOfBooks = await dbClient
        .rawQuery("SELECT id,title,author,coverlink,publishyear FROM books;");
    return listOfBooks;
  }

  static Future<List<Map<String, dynamic>>> getAllauthors() async {
    var dbClient = await dbConnection.db;
    var listOfauthors =
        await dbClient.rawQuery("SELECT DISTINCT author FROM books;");
    return listOfauthors;
  }

  static Future<String> getBookTitle(String title) async {
    var dbClient = await dbConnection.db;
    var listOfBooks =
        await dbClient.rawQuery("SELECT id FROM books where title='$title';");
    return listOfBooks.first['id'].toString();
  }

  static Future<List<Map<String, dynamic>>> orderBooksByYear(
      bool descendingOrder) async {
    var dbClient = await dbConnection.db;
    String query = '''
        select id, title, coverlink FROM Books ORDER BY publishyear ${descendingOrder ? 'DESC' : 'ASC'}
        ''';
    final booksFound = await dbClient.rawQuery(query);
    return booksFound;
  }

  static Future<List<Map<String, dynamic>>> orderBooksByPages(
      bool descendingOrder) async {
    var dbClient = await dbConnection.db;

    String query = '''
        select id, title, coverlink FROM Books ORDER BY numberOfPages ${descendingOrder ? 'DESC' : 'ASC'}
        ''';
    final booksFound = await dbClient.rawQuery(query);
    return booksFound;
  }

  static Future<List<Map<String, dynamic>>> orderBooksByRating(
      bool descendingOrder) async {
    var dbClient = await dbConnection.db;

    final booksFound = await dbClient.rawQuery('''
    select Books.id, title, coverlink, AVG(UserRatings.ratingValue) as avgRating 
    FROM Books 
    JOIN UserRatings 
    ON UserRatings.bookId = Books.id 
    GROUP By Books.id 
    ORDER BY avgRating ${descendingOrder ? 'DESC' : 'ASC'};
    ''');
    return booksFound;
  }

  static Future<List<Map<String, dynamic>>> orderBooksByFavourites(
      bool descendingOrder) async {
    var dbClient = await dbConnection.db;

    final booksFound = await dbClient.rawQuery('''
    select Books.id, title, coverlink, Count(UserFavourites.id) as numberOfFavourites 
    FROM Books 
    LEFT JOIN UserFavourites 
    ON UserFavourites.bookId = Books.id 
    GROUP By Books.id 
    ORDER BY numberOfFavourites ${descendingOrder ? 'DESC' : 'ASC'};
    ''');
    return booksFound;
  }

  static Future<List<Map<String, dynamic>>> getReadBooks(
      String username) async {
    var dbClient = await dbConnection.db;
    final booksFound = await dbClient.rawQuery('''
    SELECT Books.id, Books.title, Books.coverLink
    FROM Rooms 
    JOIN Books
    ON Books.id = Rooms.bookId
    LEFT JOIN RoomMembers 
    On Rooms.id = RoomMembers.roomid
    WHERE Rooms.isOpen = 0 AND Books.numberofpages = RoomMembers.readPages AND RoomMembers.userid = ?
    ''', [username]);
    return booksFound;
  }
}
