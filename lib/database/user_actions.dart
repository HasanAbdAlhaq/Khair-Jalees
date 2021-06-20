// Dart Packages
import 'dart:async';
import 'dart:convert';

// Flutter Packages
import 'package:crypto/crypto.dart';

// Models
import '../models/User.dart';

// Database
import './database_helper.dart';

class UserActions {
  // Database Connection
  static DatabaseHelper dbConnection = new DatabaseHelper();

  static Future<bool> isEmailFound(String email) async {
    var dbClient = await dbConnection.db;
    final usersFound = await dbClient.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    // If Length Of Result = 0 then Emai is NOT Found
    return usersFound.length > 0;
  }

  static Future<bool> isUsernameFound(String username) async {
    var dbClient = await dbConnection.db;
    final usersFound = await dbClient
        .query('users', where: 'username = ?', whereArgs: [username]);
    return usersFound.length > 0;
  }

  static Future<Map<String, Object>> logIn({
    String username,
    String email,
    String password,
    bool isEmailUsed,
    String token,
  }) async {
    // Prepera The Returned Map
    Map<String, Object> resultedMap = {
      'userObject': null,
      'resultString': '',
    };
    // Hash The Provided Password
    String hashedPassword = sha512.convert(utf8.encode(password)).toString();

    var dbClient = await dbConnection.db;
    // Check For Logging In Method

    if (isEmailUsed) {
      var emailFound = await isEmailFound(email);
      if (!emailFound) {
        resultedMap['resultString'] = 'البريد الإلكتروني غير صحيح';
        return resultedMap;
      }
    } else {
      var usernameFound = await isUsernameFound(username);
      if (!usernameFound) {
        resultedMap['resultString'] = 'اسم المستخدم غير صحيح ';
        return resultedMap;
      }
    }
    // Check The Password To Be Right
    var res = await dbClient.rawQuery(
        "SELECT * FROM users WHERE (email = '$email' or username = '$username') and password = '$hashedPassword'");
    if (res.length > 0) {
      // Return The Map Coming From DB
      resultedMap['userObject'] = new User.fromMap(res.first);
      UpdateUserToken(username: res.first['username'], token: token);
    } else {
      resultedMap['resultString'] = 'كلمة المرور غير صحيحة';
    }
    return resultedMap;
  }

  static Future<void> UpdateUserToken({String username, String token}) async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery(
        "UPDATE Users set userToken = '$token' WHERE username = '$username'");
  }

  static Future<Map<String, Object>> getUserToken(String username) async {
    var dbClient = await dbConnection.db;
    var token = await dbClient
        .rawQuery("SELECT userToken from Users WHERE username = '$username'");
    return token.first;
  }

  static Future<String> signUpUser(User user) async {
    var dbClient = await dbConnection.db;
    // Check Email Correctness
    var emailFound = await isEmailFound(user.email);
    if (emailFound) return 'البريد الإلكتروني مستخدم سابقاً';
    // Check Username Correctness
    var usernameFound = await isUsernameFound(user.username);
    if (usernameFound) return 'اسم المستخدم موجود مسبقاً';
    // Hash The Password
    user.password = sha512.convert(utf8.encode(user.password)).toString();
    // Sign Up User
    await dbClient.insert("users", user.toMap());
    return null;
  }

  static Future<int> deleteUser(User user) async {
    var dbClient = await dbConnection.db;
    int res = await dbClient.delete(
      "users",
      where: 'username = ?',
      whereArgs: [user.username],
    );
    // Return Numbers Of Affected Rows
    return res;
  }

  static Future<int> updateUser(User user) async {
    var dbClient = await dbConnection.db;
    // Return The Number Of Updated Rows
    return await dbClient.update(
      "users",
      user.toMap(),
      where: 'username = ?',
      whereArgs: [user.username],
    );
  }

  static Future<List<Map<String, dynamic>>> getUsers({
    String where,
    List<dynamic> whereArgs,
  }) async {
    var dbClient = await dbConnection.db;
    // Return The List Of Found Users As Maps
    return await dbClient.query(
      "Users",
      where: where,
      whereArgs: whereArgs,
    );
  }

  static Future<void> addContact(
      String adderUsername, String addedContact) async {
    var dbClient = await dbConnection.db;
    await dbClient.insert('contacts', {
      'userId': adderUsername,
      'contactId': addedContact,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllContacts(
      String username) async {
    var dbClient = await dbConnection.db;
    var listOfContacts = await dbClient.rawQuery('''
      SELECT Users.username as contactId, Users.fullName, Users.userAvatar 
      FROM contacts JOIN Users 
      ON Users.username = contacts.contactId
      WHERE contacts.userId = ?;
      ''', [username]);
    return listOfContacts;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    var dbClient = await dbConnection.db;
    var listOfUsers = await dbClient
        .rawQuery("SELECT username,fullname,useravatar FROM Users;");
    return listOfUsers;
  }

  static Future<bool> checkContactExist(
      String username, String checkedUsername) async {
    var resultContacts = await getAllContacts(username);
    return resultContacts
        .any((element) => element['contactId'] == checkedUsername);
  }

  static Future<void> deleteContact(
      String username, String deletedContact) async {
    var dbClient = await dbConnection.db;
    dbClient.delete('contacts',
        where: 'userId = ? AND contactId = ?',
        whereArgs: [username, deletedContact]);
  }

  static Future<Map<String, dynamic>> getUser(String username) async {
    var res = await getUsers(where: 'username = ?', whereArgs: [username]);
    return res.first;
  }

  static Future<void> setNotificationStatus(
      String username, bool newValue) async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery(
      '''
      UPDATE Users SET notificationOn = ? WHERE username = ?;
      ''',
      [newValue ? 1 : 0, username],
    );
  }

  static Future<int> isNotificationsOnGeneral(String username) async {
    var dbClient = await dbConnection.db;
    var isnotificationon = await dbClient.rawQuery(
      '''
      SELECT notificationon FROM Users where username = ?;
      ''',
      [username],
    );
    return isnotificationon.first['notificationOn'];
  }

  static Future<void> setShowCountryStatus(
      String username, bool newValue) async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery(
      '''
      UPDATE Users SET showCountry = ? WHERE username = ?;
      ''',
      [newValue ? 1 : 0, username],
    );
  }

  static Future<void> setShowDetails(String username, bool newValue) async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery(
      '''
      UPDATE Users SET showDetails = ? WHERE username = ?;
      ''',
      [newValue ? 1 : 0, username],
    );
  }

  static Future<Map<String, dynamic>> getUserDatails(String username) async {
    var dbClient = await dbConnection.db;
    var detailsMap = await dbClient.rawQuery('''
    select Count(DISTINCT UserRatings.id) as numberOfRatings, Count(DISTINCT UserFavourites.id) as numberOfFavourites,
    Count(DISTINCT Comments.id) as numberOfComments,
    count(DISTINCT RoomMembers.roomid) as numberOfRooms
    From Users 
    left JOIN RoomMembers ON RoomMembers.userid = Users.username
    left JOIN UserFavourites on UserFavourites.userId = Users.username
    left JOIN UserRatings ON UserRatings.userid = Users.username
    left JOIN Comments ON Comments.userid = Users.username
    where Users.username = ?;
    ''', [username]);
    return detailsMap.first;
  }

  static Future<int> getNumberOfReadBooks(String username) async {
    var dbClient = await dbConnection.db;
    var detailsMap = await dbClient.rawQuery('''
    SELECT COUNT( DISTINCT Rooms.bookid) AS readBooks
    FROM Books
    JOIN Rooms 
    ON Books.id = Rooms.bookId
    LEFT JOIN RoomMembers 
    On Rooms.id = RoomMembers.roomid
    WHERE Rooms.isOpen = 0 AND Books.numberofpages = RoomMembers.readPages AND RoomMembers.userid = ?
    ''', [username]);
    return detailsMap.first['readBooks'];
  }

  static Future<Map<String, dynamic>> getNumberOfReadBooks2(
      String username) async {
    var dbClient = await dbConnection.db;
    var detailsMap = await dbClient.rawQuery('''
    SELECT COUNT(DISTINCT Rooms.bookid) AS readBooks
    FROM Rooms 
    JOIN Books
    ON Books.id = Rooms.bookId
    LEFT JOIN RoomMembers 
    On Rooms.id = RoomMembers.roomid
    WHERE Rooms.isOpen = 0 AND Books.numberofpages = RoomMembers.readPages AND RoomMembers.userid = ?;
    ''', [username]);
    return detailsMap.first;
  }

  static Future<Map<String, dynamic>> getNumberOfReadBooksbyCategory(
      String username, String category) async {
    var dbClient = await dbConnection.db;
    var detailsMap = await dbClient.rawQuery('''
    SELECT COUNT(DISTINCT Rooms.bookid) AS readBooks
    FROM Rooms 
    JOIN Books
    ON Books.id = Rooms.bookId
    LEFT JOIN RoomMembers 
    On Rooms.id = RoomMembers.roomid
    WHERE Rooms.isOpen = 0 AND Books.numberofpages = RoomMembers.readPages AND Books.category = ? AND RoomMembers.userid = ?;
    ''', [category, username]);
    return detailsMap.first;
  }

  static Future<List<Map<String, dynamic>>> getLeaderBoardUsers() async {
    var dbClient = await dbConnection.db;
    var listOfUsers = await dbClient.rawQuery('''
        SELECT Users.fullName, Users.useravatar, COUNT(DISTINCT Rooms.bookid) as numberOfBooks
        From Users
        Join RoomMembers on RoomMembers.userid = Users.username
        Join Rooms ON RoomMembers.roomid = Rooms.id
        JOIn Books on Books.id = Rooms.bookid
        WHERE Rooms.isopen = 0 AND RoomMembers.readPages = Books.numberofpages
        GROUP BY Users.username
        Order BY numberOfBooks DESC; ''');
    return listOfUsers;
  }

  static Future<int> getUserPoints(String username) async {
    var dbClient = await dbConnection.db;
    var pointsAsMap = await dbClient
        .rawQuery("SELECT points FROM Users WHERE username = ?;", [username]);

    return pointsAsMap.first['points'];
  }

  static Future<int> getNumberOfavourites(String username) async {
    var dbClient = await dbConnection.db;
    var numberOfFavouritesList = await dbClient.rawQuery('''
        SELECT COUNT (id) AS numberOfFavourites FROM UserFavourites WHERE userid = ?;
        ''', [username]);

    return numberOfFavouritesList.first['numberOfFavourites'];
  }

  static Future<int> getNumberOfRatings(String username) async {
    var dbClient = await dbConnection.db;
    var numberOfRatingsList = await dbClient.rawQuery('''
        SELECT COUNT (id) AS numberOfRatings FROM UserRatings WHERE userid = ?;
        ''', [username]);

    return numberOfRatingsList.first['numberOfRatings'];
  }

  static Future<int> getNumberOfComments(String username) async {
    var dbClient = await dbConnection.db;
    var numberOfCommentsList = await dbClient.rawQuery('''
        SELECT COUNT (id) AS numberOfComments FROM Comments WHERE userid = ?;
        ''', [username]);

    return numberOfCommentsList.first['numberOfComments'];
  }

  static Future<int> getNumberOfContacts(String username) async {
    var dbClient = await dbConnection.db;
    var numberOfContactsList = await dbClient.rawQuery('''
        SELECT COUNT (*) AS numberOfContacts FROM contacts WHERE userid = ?;
        ''', [username]);

    return numberOfContactsList.first['numberOfContacts'];
  }

  static Future<int> getNumberOfOpenedRooms(String username) async {
    var dbClient = await dbConnection.db;
    var numberOfRoomsList = await dbClient.rawQuery('''
        SELECT COUNT(id) AS numberOfOpenedRooms FROM Rooms WHERE Rooms.creatorId = ?;
        ''', [username]);

    return numberOfRoomsList.first['numberOfOpenedRooms'];
  }

  static Future<void> updatePoints(String username, int newPoints) async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery('''
    update Users set points = ? where username = ?;
        ''', [newPoints, username]);
  }

  static Future<List<Map<String, dynamic>>> getUserThemes(
      String username) async {
    var dbClient = await dbConnection.db;
    var listOfUsers = await dbClient.rawQuery('''
        SELECT themeId FROM UserThemes WHERE userId = ?;''', [username]);
    return listOfUsers;
  }

  static Future<void> buyUserTheme(String username, int themeId) async {
    var dbClient = await dbConnection.db;
    await dbClient.insert('UserThemes', {
      'userId': username,
      'themeId': themeId,
    });
  }
}
