class RoomMember {
  String username;
  String fullName;
  String userAvatar;
  bool showDetails;
  int readPages;
  int numberOfPages;

  RoomMember({
    this.username,
    this.fullName,
    this.userAvatar =
        'https://st4.depositphotos.com/4329009/19956/v/600/depositphotos_199564354-stock-illustration-creative-vector-illustration-default-avatar.jpg',
    this.readPages,
    this.showDetails = false,
    this.numberOfPages,
  });

  RoomMember.formMap(Map<String, dynamic> map) {
    this.fullName = map['fullName'];
    this.username = map['username'];
    this.userAvatar = map['userAvatar'];
    this.showDetails = map['showDetails'] == 1;
    this.readPages = map['readPages'];
    this.numberOfPages = map['numberOfPages'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'fullName': this.fullName,
      'username': this.username,
      'userAvatar': this.userAvatar,
      'showDetails': this.showDetails ? 1 : 0,
      'readPages': this.readPages,
      'numberOfPages': this.numberOfPages,
    };

    return map;
  }
}
