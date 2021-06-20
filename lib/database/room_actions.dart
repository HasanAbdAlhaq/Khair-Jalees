import 'dart:async';

import 'package:grad_project/database/database_helper.dart';

class RoomActions {
  static DatabaseHelper dbConnection = new DatabaseHelper();

  static Future<Map<String, dynamic>> getSingleRoom(int roomId) async {
    var dbClient = await dbConnection.db;
    final roomsFound = await dbClient.rawQuery('''
    Select 
    Rooms.id, Rooms.roomname, Rooms.startdate, Rooms.enddate, Rooms.isopen, Rooms.creatorId,
    Books.id as bookId, Books.title, Books.author, Books.coverLink,
    Users.fullname AS creatorName,
    RoomMembers.isNotificationOn
    FROM Books 
    JOIN Rooms 
    ON Books.id = Rooms.bookId
    JOIN RoomMembers 
    ON RoomMembers.roomId = Rooms.id
    Join Users 
    On Users.username = RoomMembers.userId
    WHERE RoomMembers.roomId = ?;
      ''', [roomId]);
    return roomsFound.first;
  }

  static Future<List<Map<String, dynamic>>> getAllRooms(String username) async {
    var dbClient = await dbConnection.db;
    final allRooms = await dbClient.rawQuery('''
      select Rooms.id,Rooms.roomName ,Rooms.enddate , Books.title, Books.coverlink,
      COUNT(RoomMembers.userId) as usersCount
      FROM Books 
      JOIN Rooms 
      ON Books.id = Rooms.bookId
      JOIN RoomMembers 
      ON RoomMembers.roomId = Rooms.id
      WHERE RoomMembers.userId = ?
      GROUP BY RoomMembers.roomId;
      ''', [username]);
    return allRooms;
  }

  static Future<bool> isRoomFound(String roomName) async {
    var dbClient = await dbConnection.db;
    final usersFound = await dbClient.query(
      'Rooms',
      where: 'roomName = ?',
      whereArgs: [roomName],
    );
    return usersFound.length > 0;
  }

  static Future<bool> isMemberFound(String username, int gid) async {
    var dbClient = await dbConnection.db;
    final userFound = await dbClient.query(
      'RoomMembers',
      where: 'userId = ? And roomId = ?',
      whereArgs: [username, gid],
    );
    if (userFound.length == 1) {
      return true;
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> getRoomMembers(int roomId) async {
    var dbClient = await dbConnection.db;
    final roomMembers = await dbClient.rawQuery(
      '''
      SELECT Users.userAvatar, Users.username, Users.fullName, Users.showDetails,
      RoomMembers.readPages, Books.numberOfPages
      FROM Books JOIN Rooms on Books.id = Rooms.bookId
      join RoomMembers on RoomMembers.roomId = Rooms.id
      JOIN Users on RoomMembers.userid = Users.username
      where RoomMembers.roomId = ?;
      ''',
      [roomId],
    );

    return roomMembers;
  }

  static Future<List<Map<String, dynamic>>> getGroupMembersTokens(
      int roomId) async {
    var dbClient = await dbConnection.db;
    final roomMembers = await dbClient.rawQuery(
      '''
      SELECT Users.usertoken
      FROM Users JOIN RoomMembers on RoomMembers.userId = Users.username
      where RoomMembers.roomId = ?;
      ''',
      [roomId],
    );

    return roomMembers;
  }

  static Future<List<Map<String, dynamic>>> GetSubscribedRooms(
      String username) async {
    var dbClient = await dbConnection.db;
    final roomMembers = await dbClient.rawQuery(
      '''
      SELECT RoomMembers.roomid FROM RoomMembers where RoomMembers.userid = ?;
      ''',
      [username],
    );

    return roomMembers;
  }

  static Future<int> addNewRoom(Map<String, dynamic> map) async {
    var dbClient = await dbConnection.db;
    return await dbClient.insert('Rooms', map);
  }

  static Future<void> addRoomMember(Map<String, dynamic> map) async {
    var dbClient = await dbConnection.db;
    await dbClient.insert('RoomMembers', map);
  }

  static Future<void> setNotification(
      String username, int roomId, bool newValue) async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery(
      '''
    UPDATE RoomMembers SET isnotificationon = ? WHERE RoomMembers.roomId = ? AND RoomMembers.userId = ?;
    ''',
      [newValue ? 1 : 0, roomId, username],
    );
  }

  static Future<void> deleteRoom(int roomId) async {
    var dbClient = await dbConnection.db;
    return await dbClient.delete('Rooms', where: 'id = ?', whereArgs: [roomId]);
  }

  static Future<void> saveBookPageNumber(
      String username, int roomId, int newPageNumber) async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery(
      '''
    UPDATE RoomMembers SET readPages = ? WHERE RoomMembers.roomId = ? AND RoomMembers.userId = ? AND RoomMembers.readPages < ?;
    ''',
      [newPageNumber, roomId, username, newPageNumber],
    );
  }

  static Future<void> closeRooms() async {
    var dbClient = await dbConnection.db;
    await dbClient.rawQuery(
        '''UPDATE Rooms SET isOpen = 0 WHERE endDate <= ?;''',
        [DateTime.now().toString()]);
  }
}
