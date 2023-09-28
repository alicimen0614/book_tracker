class BooksModelDocsEditionsDocs {
/*
{
  "key": "/books/OL35366895M",
  "title": "Bizimle başladı bizimle bitti"
} 
*/

  String? key;
  String? title;

  BooksModelDocsEditionsDocs({
    this.key,
    this.title,
  });
  BooksModelDocsEditionsDocs.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    title = json['title']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['title'] = title;
    return data;
  }
}

class BooksModelDocsEditions {
/*
{
  "numFound": 2,
  "start": 0,
  "numFoundExact": true,
  "docs": [
    {
      "key": "/books/OL35366895M",
      "title": "Bizimle başladı bizimle bitti"
    }
  ]
} 
*/

  int? numFound;
  int? start;
  bool? numFoundExact;
  List<BooksModelDocsEditionsDocs?>? docs;

  BooksModelDocsEditions({
    this.numFound,
    this.start,
    this.numFoundExact,
    this.docs,
  });
  BooksModelDocsEditions.fromJson(Map<String, dynamic> json) {
    numFound = json['numFound']?.toInt();
    start = json['start']?.toInt();
    numFoundExact = json['numFoundExact'];
    if (json['docs'] != null) {
      final v = json['docs'];
      final arr0 = <BooksModelDocsEditionsDocs>[];
      v.forEach((v) {
        arr0.add(BooksModelDocsEditionsDocs.fromJson(v));
      });
      docs = arr0;
    }
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
    return data;
  }
}

class BooksModelDocs {
  BooksModelDocsEditions? editions;
  String? key;
  String? title;
  int? editionCount;

  int? firstPublishYear;

  int? coverI;
  List<String?>? language;
  List<String?>? authorKey;
  List<String?>? authorName;
  List<String?>? subject;
  List<String?>? firstSentence;

  BooksModelDocs(
      {this.key,
      this.title,
      this.editionCount,
      this.firstPublishYear,
      this.coverI,
      this.language,
      this.authorKey,
      this.authorName,
      this.subject,
      this.firstSentence,
      this.editions});
  BooksModelDocs.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();

    title = json['title']?.toString();

    editionCount = json['edition_count']?.toInt();

    editions = (json['editions'] != null)
        ? BooksModelDocsEditions.fromJson(json['editions'])
        : null;

    firstPublishYear = json['first_publish_year']?.toInt();

    ;
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

    if (json['subject'] != null) {
      final v = json['subject'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subject = arr0;
    }
    if (json['first_sentence'] != null) {
      final v = json['first_sentence'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      firstSentence = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    if (editions != null) {
      data['editions'] = editions!.toJson();
    }

    data['title'] = title;
    data['edition_count'] = editionCount;

    data['first_publish_year'] = firstPublishYear;

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

    if (subject != null) {
      final v = subject;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subject'] = arr0;
    }
    if (firstSentence != null) {
      final v = firstSentence;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['first_sentence'] = arr0;
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
