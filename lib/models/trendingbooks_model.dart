class TrendingBooksWorks {
  String? key;
  String? title;
  int? editionCount;
  int? firstPublishYear;
  String? coverEditionKey;
  int? coverI;
  List<String?>? language;
  List<String?>? authorKey;
  List<String?>? authorName;

  TrendingBooksWorks({
    this.key,
    this.title,
    this.editionCount,
    this.firstPublishYear,
    this.coverEditionKey,
    this.coverI,
    this.language,
    this.authorKey,
    this.authorName,
  });
  TrendingBooksWorks.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    title = json['title']?.toString();
    editionCount = json['edition_count']?.toInt();
    firstPublishYear = json['first_publish_year']?.toInt();

    coverEditionKey = json['cover_edition_key']?.toString();
    coverI = json['cover_i']?.toInt();
    if (json['language'] != null) {
      final v = json['language'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      language = arr0;
    }
    if (json['author_key'] != null) {
      final v = json['author_key'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      authorKey = arr0;
    }
    if (json['author_name'] != null) {
      final v = json['author_name'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      authorName = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['title'] = title;
    data['edition_count'] = editionCount;
    data['first_publish_year'] = firstPublishYear;
    data['cover_edition_key'] = coverEditionKey;
    data['cover_i'] = coverI;
    if (language != null) {
      final v = language;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['language'] = arr0;
    }
    if (authorKey != null) {
      final v = authorKey;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['author_key'] = arr0;
    }
    if (authorName != null) {
      final v = authorName;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['author_name'] = arr0;
    }

    return data;
  }
}

class TrendingBooks {
  String? query;
  List<TrendingBooksWorks?>? works;
  int? days;
  int? hours;

  TrendingBooks({
    this.query,
    this.works,
    this.days,
    this.hours,
  });
  TrendingBooks.fromJson(Map<String, dynamic> json) {
    query = json['query']?.toString();
    if (json['works'] != null) {
      final v = json['works'];
      final arr0 = <TrendingBooksWorks>[];
      v.forEach((v) {
        arr0.add(TrendingBooksWorks.fromJson(v));
      });
      works = arr0;
    }
    days = json['days']?.toInt();
    hours = json['hours']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['query'] = query;
    if (works != null) {
      final v = works;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['works'] = arr0;
    }
    data['days'] = days;
    data['hours'] = hours;
    return data;
  }
}
