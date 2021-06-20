class Book {
  int id;
  String title;
  int publishYear;
  int numberOfPages;
  String category;
  String description;
  String author;
  String coverLink;
  int numberOfFavourites;
  int numberOfRatings;
  double avgRating;

  Book({
    this.id = 0,
    this.title = '',
    this.publishYear = 0,
    this.numberOfPages = 0,
    this.category = '',
    this.description = '',
    this.author = '',
    this.coverLink = '',
    this.numberOfFavourites = 0,
    this.numberOfRatings = 0,
    this.avgRating = 0.0,
  });

  Book.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.publishYear = map['publishYear'];
    this.numberOfPages = map['numberOfPages'];
    this.category = map['category'];
    this.description = map['description'];
    this.author = map['author'];
    this.coverLink = map['coverLink'];
    this.numberOfFavourites = map['numberOfFavourites'];
    this.numberOfRatings = map['numberOfRatings'];
    this.avgRating = map['avgRating'] ?? 0.0;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': this.id,
      'title': this.title,
      'publishYear': this.publishYear,
      'numberOfPages': this.numberOfPages,
      'category': this.category,
      'description': this.description,
      'author': this.author,
      'coverLink': this.coverLink,
      'numberOfFavourites': this.numberOfFavourites,
      'numberOfRatings': this.numberOfRatings,
      'avgRating': this.avgRating,
    };
    return map;
  }
}
