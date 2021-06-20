class SingleRoom {
  int id;
  String roomName;
  int bookId;
  String title;
  String author;
  String coverLink;
  String creatorId;
  String creatorName;
  DateTime startDate;
  DateTime endDate;
  bool isOpen;
  bool isNotificationOn;
  SingleRoom({
    this.id = 1,
    this.roomName = '',
    this.bookId = 1,
    this.title = '',
    this.author = '',
    this.coverLink = '',
    this.creatorId = '',
    this.creatorName = '',
    this.startDate,
    this.endDate,
    this.isOpen = true,
    this.isNotificationOn = true,
  });

  SingleRoom.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.roomName = map['roomName'];
    this.bookId = map['bookId'];
    this.title = map['title'];
    this.author = map['author'];
    this.coverLink = map['coverLink'];
    this.creatorId = map['creatorId'];
    this.creatorName = map['creatorName'];
    this.startDate = DateTime.parse(map['startDate']);
    this.endDate = DateTime.parse(map['endDate']);
    this.isOpen = map['isOpen'] == 1;
    this.isNotificationOn = map['isNotificationOn'] == 1;
  }
}
