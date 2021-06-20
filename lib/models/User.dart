import 'package:flutter/foundation.dart';

class User {
  String username;
  String fullName;
  String email;
  String password;
  String gender;
  int themeId;
  int points;
  String country;
  bool showCountry;
  bool showDetails;
  bool notificationOn;
  DateTime creationDate;
  String userAvatar;
  String userToken;

  User(
      {@required this.username,
      @required this.fullName,
      @required this.email,
      @required this.password,
      this.gender = 'M',
      this.themeId = 0,
      this.points = 0,
      this.country = 'Palestine',
      this.showCountry = true,
      this.showDetails = false,
      this.notificationOn = true,
      this.creationDate,
      userAvatar = 'https://via.placeholder.com/150/4c064d?text= ',
      this.userToken = ""});

  User.fromMap(Map<String, dynamic> map) {
    this.username = map['username'];
    this.fullName = map['fullName'];
    this.email = map['email'];
    this.password = map['password'];
    this.gender = map['gender'];
    this.themeId = map['themeId'];
    this.points = map['points'];
    this.country = map['country'];
    this.showCountry = map['showCountry'] == 1;
    this.showDetails = map['showDetails'] == 1;
    this.notificationOn = map['notificationOn'] == 1;
    this.creationDate = DateTime.parse(map['creationDate']);
    this.userAvatar = map['userAvatar'];
    this.userToken = map['userToken'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['username'] = this.username;
    map['fullName'] = this.fullName;
    map['email'] = this.email;
    map['password'] = this.password;
    map['gender'] = this.gender;
    map['themeId'] = this.themeId;
    map['points'] = this.points;
    map['country'] = this.country;
    map['showCountry'] = this.showCountry ? 1 : 0;
    map['showDetails'] = this.showDetails ? 1 : 0;
    map['notificationOn'] = this.notificationOn ? 1 : 0;
    map['creationDate'] = this.creationDate.toString();
    map['userAvatar'] = this.userAvatar;
    map['userToken'] = this.userToken;
    return map;
  }
}
