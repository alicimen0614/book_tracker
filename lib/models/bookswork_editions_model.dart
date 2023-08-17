import 'dart:typed_data';

///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class BookWorkEditionsModelEntriesLastModified {
/*
{
  "type": "/type/datetime",
  "value": "2023-08-02T15:52:44.823339"
} 
*/

  String? type;
  String? value;

  BookWorkEditionsModelEntriesLastModified({
    this.type,
    this.value,
  });
  BookWorkEditionsModelEntriesLastModified.fromJson(Map<String, dynamic> json) {
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

class BookWorkEditionsModelEntriesCreated {
/*
{
  "type": "/type/datetime",
  "value": "2023-04-14T07:24:57.839426"
} 
*/

  String? type;
  String? value;

  BookWorkEditionsModelEntriesCreated({
    this.type,
    this.value,
  });
  BookWorkEditionsModelEntriesCreated.fromJson(Map<String, dynamic> json) {
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

class BookWorkEditionsModelEntriesWorks {
/*
{
  "key": "/works/OL17930368W"
} 
*/

  String? key;

  BookWorkEditionsModelEntriesWorks({
    this.key,
  });
  BookWorkEditionsModelEntriesWorks.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkEditionsModelEntriesAuthors {
/*
{
  "key": "/authors/OL7422948A"
} 
*/

  String? key;

  BookWorkEditionsModelEntriesAuthors({
    this.key,
  });
  BookWorkEditionsModelEntriesAuthors.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkEditionsModelEntriesType {
/*
{
  "key": "/type/edition"
} 
*/

  String? key;

  BookWorkEditionsModelEntriesType({
    this.key,
  });
  BookWorkEditionsModelEntriesType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkEditionsModelTranslatedFrom {
/*
{
  "key": "/languages/eng"
} 
*/

  String? key;

  BookWorkEditionsModelTranslatedFrom({
    this.key,
  });
  BookWorkEditionsModelTranslatedFrom.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkEditionsModelLanguages {
/*
{
  "key": "/languages/fre"
} 
*/

  String? key;

  BookWorkEditionsModelLanguages({
    this.key,
  });
  BookWorkEditionsModelLanguages.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkEditionsModelEntries {
/*
{
  "type": {
    "key": "/type/edition"
  },
  "title": "Hàbits atòmics",
  "authors": [
    {
      "key": "/authors/OL7422948A"
    }
  ],
  "publish_date": "Oct 03, 2022",
  "source_records": [
    "amazon:8418928719"
  ],
  "number_of_pages": 320,
  "publishers": [
    "Ara Llibres"
  ],
  "isbn_10": [
    "8418928719"
  ],
  "isbn_13": [
    "9788418928710"
  ],
  "physical_format": "paperback",
  "covers": [
    13966601
  ],
  "works": [
    {
      "key": "/works/OL17930368W"
    }
  ],
  "key": "/books/OL47372259M",
  "latest_revision": 4,
  "revision": 4,
  "created": {
    "type": "/type/datetime",
    "value": "2023-04-14T07:24:57.839426"
  },
  "last_modified": {
    "type": "/type/datetime",
    "value": "2023-08-02T15:52:44.823339"
  }
} 
*/

  BookWorkEditionsModelEntriesType? type;

  String? title;
  List<BookWorkEditionsModelEntriesAuthors?>? authors;
  String? publishDate;
  List<String?>? sourceRecords;
  int? numberOfPages;
  String? translationOf;
  List<BookWorkEditionsModelLanguages?>? languages;
  List<BookWorkEditionsModelTranslatedFrom?>? translatedFrom;
  List<String?>? publishers;
  List<String?>? isbn_10;
  List<String?>? isbn_13;
  String? physicalFormat;
  List<int?>? covers;
  List<BookWorkEditionsModelEntriesWorks?>? works;
  String? key;
  int? latestRevision;
  int? revision;
  BookWorkEditionsModelEntriesCreated? created;
  BookWorkEditionsModelEntriesLastModified? lastModified;
  String? bookStatus;
  Uint8List? imageAsByte;

  BookWorkEditionsModelEntries(
      {this.type,
      this.title,
      this.authors,
      this.publishDate,
      this.sourceRecords,
      this.numberOfPages,
      this.publishers,
      this.translationOf,
      this.languages,
      this.translatedFrom,
      this.isbn_10,
      this.isbn_13,
      this.physicalFormat,
      this.covers,
      this.works,
      this.key,
      this.latestRevision,
      this.revision,
      this.created,
      this.lastModified,
      this.bookStatus,
      this.imageAsByte});
  BookWorkEditionsModelEntries.fromJson(Map<String, dynamic> json) {
    type = (json['type'] != null)
        ? BookWorkEditionsModelEntriesType.fromJson(json['type'])
        : null;
    title = json['title']?.toString();
    if (json['authors'] != null) {
      final v = json['authors'];
      final arr0 = <BookWorkEditionsModelEntriesAuthors>[];
      v.forEach((v) {
        arr0.add(BookWorkEditionsModelEntriesAuthors.fromJson(v));
      });
      authors = arr0;
    }
    translationOf = json['translation_of']?.toString();
    if (json['languages'] != null) {
      final v = json['languages'];
      final arr0 = <BookWorkEditionsModelLanguages>[];
      v.forEach((v) {
        arr0.add(BookWorkEditionsModelLanguages.fromJson(v));
      });
      languages = arr0;
    }
    if (json['translated_from'] != null) {
      final v = json['translated_from'];
      final arr0 = <BookWorkEditionsModelTranslatedFrom>[];
      v.forEach((v) {
        arr0.add(BookWorkEditionsModelTranslatedFrom.fromJson(v));
      });
      translatedFrom = arr0;
    }
    publishDate = json['publish_date']?.toString();
    if (json['source_records'] != null) {
      final v = json['source_records'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      sourceRecords = arr0;
    }
    numberOfPages = json['number_of_pages']?.toInt();
    if (json['publishers'] != null) {
      final v = json['publishers'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      publishers = arr0;
    }
    if (json['isbn_10'] != null) {
      final v = json['isbn_10'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      isbn_10 = arr0;
    }
    if (json['isbn_13'] != null) {
      final v = json['isbn_13'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      isbn_13 = arr0;
    }
    physicalFormat = json['physical_format']?.toString();
    bookStatus = json['bookStatus']?.toString();

    if (json['covers'] != null) {
      final v = json['covers'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      covers = arr0;
    }
    if (json['works'] != null) {
      final v = json['works'];
      final arr0 = <BookWorkEditionsModelEntriesWorks>[];
      v.forEach((v) {
        arr0.add(BookWorkEditionsModelEntriesWorks.fromJson(v));
      });
      works = arr0;
    }
    key = json['key']?.toString();
    latestRevision = json['latest_revision']?.toInt();
    revision = json['revision']?.toInt();
    created = (json['created'] != null)
        ? BookWorkEditionsModelEntriesCreated.fromJson(json['created'])
        : null;
    lastModified = (json['last_modified'] != null)
        ? BookWorkEditionsModelEntriesLastModified.fromJson(
            json['last_modified'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['title'] = title;
    if (authors != null) {
      final v = authors;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['authors'] = arr0;
    }
    data['publish_date'] = publishDate;
    if (sourceRecords != null) {
      final v = sourceRecords;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['source_records'] = arr0;
    }
    data['number_of_pages'] = numberOfPages;
    if (publishers != null) {
      final v = publishers;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['publishers'] = arr0;
    }
    if (isbn_10 != null) {
      final v = isbn_10;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['isbn_10'] = arr0;
    }
    if (isbn_13 != null) {
      final v = isbn_13;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['isbn_13'] = arr0;
    }
    data['bookStatus'] = bookStatus;

    data['physical_format'] = physicalFormat;
    if (covers != null) {
      final v = covers;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['covers'] = arr0;
    }
    if (works != null) {
      final v = works;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['works'] = arr0;
    }
    data['key'] = key;
    data['latest_revision'] = latestRevision;
    data['revision'] = revision;
    if (created != null) {
      data['created'] = created!.toJson();
    }
    if (lastModified != null) {
      data['last_modified'] = lastModified!.toJson();
    }
    return data;
  }
}

class BookWorkEditionsModelLinks {
/*
{
  "self": "/works/OL17930368W/editions.json",
  "work": "/works/OL17930368W"
} 
*/

  String? self;
  String? work;

  BookWorkEditionsModelLinks({
    this.self,
    this.work,
  });
  BookWorkEditionsModelLinks.fromJson(Map<String, dynamic> json) {
    self = json['self']?.toString();
    work = json['work']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['self'] = self;
    data['work'] = work;
    return data;
  }
}

class BookWorkEditionsModel {
/*
{
  "links": {
    "self": "/works/OL17930368W/editions.json",
    "work": "/works/OL17930368W"
  },
  "size": 34,
  "entries": [
    {
      "type": {
        "key": "/type/edition"
      },
      "title": "Hàbits atòmics",
      "authors": [
        {
          "key": "/authors/OL7422948A"
        }
      ],
      "publish_date": "Oct 03, 2022",
      "source_records": [
        "amazon:8418928719"
      ],
      "number_of_pages": 320,
      "publishers": [
        "Ara Llibres"
      ],
      "isbn_10": [
        "8418928719"
      ],
      "isbn_13": [
        "9788418928710"
      ],
      "physical_format": "paperback",
      "covers": [
        13966601
      ],
      "works": [
        {
          "key": "/works/OL17930368W"
        }
      ],
      "key": "/books/OL47372259M",
      "latest_revision": 4,
      "revision": 4,
      "created": {
        "type": "/type/datetime",
        "value": "2023-04-14T07:24:57.839426"
      },
      "last_modified": {
        "type": "/type/datetime",
        "value": "2023-08-02T15:52:44.823339"
      }
    }
  ]
} 
*/

  BookWorkEditionsModelLinks? links;
  int? size;
  List<BookWorkEditionsModelEntries?>? entries;

  BookWorkEditionsModel({
    this.links,
    this.size,
    this.entries,
  });
  BookWorkEditionsModel.fromJson(Map<String, dynamic> json) {
    links = (json['links'] != null)
        ? BookWorkEditionsModelLinks.fromJson(json['links'])
        : null;
    size = json['size']?.toInt();
    if (json['entries'] != null) {
      final v = json['entries'];
      final arr0 = <BookWorkEditionsModelEntries>[];
      v.forEach((v) {
        arr0.add(BookWorkEditionsModelEntries.fromJson(v));
      });
      entries = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (links != null) {
      data['links'] = links!.toJson();
    }
    data['size'] = size;
    if (entries != null) {
      final v = entries;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['entries'] = arr0;
    }
    return data;
  }
}
