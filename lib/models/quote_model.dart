class Quote {
  String? quoteText;
  String? userName;
  String? userPicture;
  String? userId;
  List<String?>? likes;
  String? bookCover;
  String? bookName;
  String? bookAuthorName;
  String? date;
  List<String?>? comments;
  int? likeCount;
  String? imageAsByte;

  Quote(
      {this.quoteText,
      this.userName,
      this.userPicture,
      this.likes,
      this.bookCover,
      this.bookName,
      this.bookAuthorName,
      this.comments,
      this.userId,
      this.date,
      this.likeCount,
      this.imageAsByte});
  Quote.fromJson(Map<String, dynamic> json) {
    quoteText = json['quoteText']?.toString();
    userName = json['userName']?.toString();
    userPicture = json['userPicture']?.toString();
    bookCover = json['bookCover']?.toString();
    bookName = json['bookName']?.toString();
    bookAuthorName = json['bookAuthorName']?.toString();
    userId = json['userId']?.toString();
    date = json['date']?.toString();
    imageAsByte = json['imageAsByte']?.toString();

    likeCount = int.tryParse(json['likeCount'].toString());

    if (json['comments'] != null) {
      final v = json['comments'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      comments = arr0;
    }
    if (json['likes'] != null) {
      final v = json['likes'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      likes = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['quoteText'] = quoteText;
    data['userName'] = userName;
    data['userPicture'] = userPicture;
    data['bookCover'] = bookCover;
    data['bookName'] = bookName;
    data['bookAuthorName'] = bookAuthorName;
    data['userId'] = userId;
    data['date'] = date;
    data['imageAsByte'] = imageAsByte;
    data['likeCount'] = likeCount;

    if (comments != null) {
      final v = comments;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['comments'] = arr0;
    }
    if (likes != null) {
      final v = likes;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['likes'] = arr0;
    }

    return data;
  }
}
