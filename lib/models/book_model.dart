class BookModel {
  final int? id;
  final String title;
  final String author;
  final String genre;
  final String coverImage;
  final bool isRead;
  final String userEmail;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.coverImage,
    required this.isRead,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'coverImage': coverImage,
      'isRead': isRead ? 1 : 0,
      'userEmail': userEmail,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      genre: map['genre'],
      coverImage: map['coverImage'],
      isRead: map['isRead'] == 1,
      userEmail: map['userEmail'],
    );
  }


  BookModel copyWith({
    int? id,
    String? title,
    String? author,
    String? genre,
    String? coverImage,
    bool? isRead,
    String? userEmail,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      coverImage: coverImage ?? this.coverImage,
      isRead: isRead ?? this.isRead,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
