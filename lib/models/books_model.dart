class BooksModelDocs {
  String? key;
  String? type;
  String? title;
  int? editionCount;
  List<String?>? editionKey;
  List<String?>? publishDate;
  List<int?>? publishYear;
  int? firstPublishYear;
  List<String?>? isbn;
  String? coverEditionKey;
  int? coverI;
  List<String?>? publisher;
  List<String?>? language;
  List<String?>? authorKey;
  List<String?>? authorName;
  List<String?>? authorAlternativeName;
  List<String?>? subject;
  List<String?>? subjectKey;

  BooksModelDocs({
    this.key,
    this.type,
    this.title,
    this.editionCount,
    this.editionKey,
    this.publishDate,
    this.publishYear,
    this.firstPublishYear,
    this.isbn,
    this.coverEditionKey,
    this.coverI,
    this.publisher,
    this.language,
    this.authorKey,
    this.authorName,
    this.authorAlternativeName,
    this.subject,
    this.subjectKey,
  });
  BooksModelDocs.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    type = json['type']?.toString();

    title = json['title']?.toString();

    editionCount = json['edition_count']?.toInt();
    if (json['edition_key'] != null) {
      final v = json['edition_key'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      editionKey = arr0;
    }
    if (json['publish_date'] != null) {
      final v = json['publish_date'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      publishDate = arr0;
    }
    if (json['publish_year'] != null) {
      final v = json['publish_year'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      publishYear = arr0;
    }
    firstPublishYear = json['first_publish_year']?.toInt();

    if (json['isbn'] != null) {
      final v = json['isbn'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      isbn = arr0;
    }

    coverEditionKey = json['cover_edition_key']?.toString();
    coverI = json['cover_i']?.toInt();
    if (json['publisher'] != null) {
      final v = json['publisher'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      publisher = arr0;
    }
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
    if (json['author_alternative_name'] != null) {
      final v = json['author_alternative_name'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      authorAlternativeName = arr0;
    }
    if (json['subject'] != null) {
      final v = json['subject'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subject = arr0;
    }

    if (json['subject_key'] != null) {
      final v = json['subject_key'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subjectKey = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['type'] = type;

    data['title'] = title;
    data['edition_count'] = editionCount;
    if (editionKey != null) {
      final v = editionKey;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['edition_key'] = arr0;
    }
    if (publishDate != null) {
      final v = publishDate;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['publish_date'] = arr0;
    }
    if (publishYear != null) {
      final v = publishYear;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['publish_year'] = arr0;
    }
    data['first_publish_year'] = firstPublishYear;

    if (isbn != null) {
      final v = isbn;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['isbn'] = arr0;
    }

    data['cover_edition_key'] = coverEditionKey;
    data['cover_i'] = coverI;
    if (publisher != null) {
      final v = publisher;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['publisher'] = arr0;
    }
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
    if (authorAlternativeName != null) {
      final v = authorAlternativeName;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['author_alternative_name'] = arr0;
    }
    if (subject != null) {
      final v = subject;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subject'] = arr0;
    }

    if (subjectKey != null) {
      final v = subjectKey;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subject_key'] = arr0;
    }
    return data;
  }
}

class BooksModel {
  int? numFound;
  int? start;
  bool? numFoundExact;
  List<BooksModelDocs?>? docs;

  String? q;
  String? offset;

  BooksModel({
    this.numFound,
    this.start,
    this.numFoundExact,
    this.docs,
    this.q,
    this.offset,
  });
  BooksModel.fromJson(Map<String, dynamic> json) {
    numFound = json['numFound']?.toInt();
    start = json['start']?.toInt();
    numFoundExact = json['numFoundExact'];
    if (json['docs'] != null) {
      final v = json['docs'];
      final arr0 = <BooksModelDocs>[];
      v.forEach((v) {
        arr0.add(BooksModelDocs.fromJson(v));
      });
      docs = arr0;
    }
    numFound = json['num_found']?.toInt();
    q = json['q']?.toString();
    offset = json['offset']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['numFound'] = numFound;
    data['start'] = start;
    data['numFoundExact'] = numFoundExact;
    if (docs != null) {
      final v = docs;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['docs'] = arr0;
    }
    data['num_found'] = numFound;
    data['q'] = q;
    data['offset'] = offset;
    return data;
  }
}
