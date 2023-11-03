class BookWorkModelFirstSentence {
  String? type;
  String? value;

  BookWorkModelFirstSentence({
    this.type,
    this.value,
  });
  BookWorkModelFirstSentence.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    value = json['value']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['value'] = value;
    return data;
  }
}

class BookWorkModelAuthorsType {
  String? key;

  BookWorkModelAuthorsType({
    this.key,
  });
  BookWorkModelAuthorsType.fromJson(dynamic authorType) {
    if (authorType.runtimeType == Map<String, dynamic>) {
      key = authorType['key']?.toString();
    } else {
      key = authorType.toString();
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkModelAuthorsAuthor {
  String? key;

  BookWorkModelAuthorsAuthor({
    this.key,
  });
  BookWorkModelAuthorsAuthor.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkModelAuthors {
  BookWorkModelAuthorsAuthor? author;
  BookWorkModelAuthorsType? type;

  BookWorkModelAuthors({
    this.author,
    this.type,
  });
  BookWorkModelAuthors.fromJson(Map<String, dynamic> json) {
    author = (json['author'] != null)
        ? BookWorkModelAuthorsAuthor.fromJson(json['author'])
        : null;
    type = (json['type'] != null)
        ? BookWorkModelAuthorsType.fromJson(json['type'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (type != null) {
      data['type'] = type!.toJson();
    }
    return data;
  }
}

class BookWorkModel {
  String? description;
  String? title;
  List<int?>? covers;
  List<String?>? subjectPlaces;
  String? firstPublishDate;
  List<String?>? subjectPeople;
  String? key;
  List<BookWorkModelAuthors?>? authors;
  List<String?>? subjects;
  BookWorkModelFirstSentence? firstSentence;

  BookWorkModel({
    this.description,
    this.title,
    this.covers,
    this.subjectPlaces,
    this.firstPublishDate,
    this.subjectPeople,
    this.key,
    this.authors,
    this.subjects,
    this.firstSentence,
  });
  BookWorkModel.fromJson(Map<String, dynamic> json) {
    description = json['description']?.toString();

    title = json['title']?.toString();
    if (json['covers'] != null) {
      final v = json['covers'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      covers = arr0;
    }
    if (json['subject_places'] != null) {
      final v = json['subject_places'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subjectPlaces = arr0;
    }
    firstPublishDate = json['first_publish_date']?.toString();
    if (json['subject_people'] != null) {
      final v = json['subject_people'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subjectPeople = arr0;
    }
    key = json['key']?.toString();
    if (json['authors'] != null) {
      final v = json['authors'];
      final arr0 = <BookWorkModelAuthors>[];
      v.forEach((v) {
        arr0.add(BookWorkModelAuthors.fromJson(v));
      });
      authors = arr0;
    }

    if (json['subjects'] != null) {
      final v = json['subjects'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subjects = arr0;
    }
    firstSentence = (json['first_sentence'] != null)
        ? BookWorkModelFirstSentence.fromJson(json['first_sentence'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;

    data['title'] = title;
    if (covers != null) {
      final v = covers;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['covers'] = arr0;
    }
    if (subjectPlaces != null) {
      final v = subjectPlaces;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subject_places'] = arr0;
    }
    data['first_publish_date'] = firstPublishDate;
    if (subjectPeople != null) {
      final v = subjectPeople;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subject_people'] = arr0;
    }
    data['key'] = key;
    if (authors != null) {
      final v = authors;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['authors'] = arr0;
    }

    if (subjects != null) {
      final v = subjects;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subjects'] = arr0;
    }
    if (firstSentence != null) {
      data['first_sentence'] = firstSentence!.toJson();
    }

    return data;
  }
}
