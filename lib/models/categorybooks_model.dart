class CategoryBooksWorksAuthors {
  String? key;
  String? name;

  CategoryBooksWorksAuthors({
    this.key,
    this.name,
  });
  CategoryBooksWorksAuthors.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    name = json['name']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['name'] = name;
    return data;
  }
}

class CategoryBooksWorks {
  String? key;
  String? title;
  int? editionCount;
  int? coverId;
  String? coverEditionKey;
  List<String?>? subject;
  List<CategoryBooksWorksAuthors?>? authors;
  int? firstPublishYear;

  CategoryBooksWorks({
    this.key,
    this.title,
    this.editionCount,
    this.coverId,
    this.coverEditionKey,
    this.subject,
    this.authors,
    this.firstPublishYear,
  });
  CategoryBooksWorks.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    title = json['title']?.toString();
    editionCount = json['edition_count']?.toInt();
    coverId = json['cover_id']?.toInt();
    coverEditionKey = json['cover_edition_key']?.toString();
    if (json['subject'] != null) {
      final v = json['subject'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subject = arr0;
    }

    if (json['authors'] != null) {
      final v = json['authors'];
      final arr0 = <CategoryBooksWorksAuthors>[];
      v.forEach((v) {
        arr0.add(CategoryBooksWorksAuthors.fromJson(v));
      });
      authors = arr0;
    }
    firstPublishYear = json['first_publish_year']?.toInt();
    ;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['title'] = title;
    data['edition_count'] = editionCount;
    data['cover_id'] = coverId;
    data['cover_edition_key'] = coverEditionKey;
    if (subject != null) {
      final v = subject;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subject'] = arr0;
    }

    if (authors != null) {
      final v = authors;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['authors'] = arr0;
    }
    data['first_publish_year'] = firstPublishYear;

    return data;
  }
}

class CategoryBooks {
  String? key;
  String? name;
  String? subjectType;
  int? workCount;
  List<CategoryBooksWorks?>? works;

  CategoryBooks({
    this.key,
    this.name,
    this.subjectType,
    this.workCount,
    this.works,
  });
  CategoryBooks.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    name = json['name']?.toString();
    subjectType = json['subject_type']?.toString();
    workCount = json['work_count']?.toInt();
    if (json['works'] != null) {
      final v = json['works'];
      final arr0 = <CategoryBooksWorks>[];
      v.forEach((v) {
        arr0.add(CategoryBooksWorks.fromJson(v));
      });
      works = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['name'] = name;
    data['subject_type'] = subjectType;
    data['work_count'] = workCount;
    if (works != null) {
      final v = works;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['works'] = arr0;
    }
    return data;
  }
}
