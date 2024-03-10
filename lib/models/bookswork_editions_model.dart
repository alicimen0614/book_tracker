class BookWorkEditionsModelEntriesWorks {
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

class BookWorkEditionsModelTranslatedFrom {
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
  String? key;
  String? value;

  BookWorkEditionsModelLanguages({this.key, this.value});
  BookWorkEditionsModelLanguages.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    value = json['value']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;

    return data;
  }
}

class BookWorkEditionsModelEntries {
  String? title;
  List<BookWorkEditionsModelEntriesAuthors?>? authors;
  String? publish_date;
  int? number_of_pages;
  String? translationOf;
  List<BookWorkEditionsModelLanguages?>? languages;
  List<BookWorkEditionsModelTranslatedFrom?>? translatedFrom;
  List<String?>? publishers;
  List<String?>? isbn_10;
  List<String?>? isbn_13;
  String? physical_format;
  List<int?>? covers;
  List<BookWorkEditionsModelEntriesWorks?>? works;
  String? key;
  String? bookStatus;
  String? imageAsByte;
  String? description;
  List<String?>? authorsNames;

  BookWorkEditionsModelEntries(
      {this.title,
      this.authors,
      this.publish_date,
      this.number_of_pages,
      this.publishers,
      this.translationOf,
      this.languages,
      this.translatedFrom,
      this.isbn_10,
      this.isbn_13,
      this.physical_format,
      this.covers,
      this.works,
      this.key,
      this.bookStatus,
      this.imageAsByte,
      this.description,
      this.authorsNames});
  BookWorkEditionsModelEntries.fromJson(Map<String, dynamic> json) {
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
      final arr0 = <BookWorkEditionsModelLanguages>[];
      if (json['languages'].runtimeType == String) {
        arr0.add(BookWorkEditionsModelLanguages.fromJson(
            {"key": json['languages']?.toString()}));
        languages = arr0;
      } else {
        final v = json['languages'];

        v.forEach((v) {
          arr0.add(BookWorkEditionsModelLanguages.fromJson(v));
        });
        languages = arr0;
      }
    }
    if (json['translated_from'] != null) {
      final v = json['translated_from'];
      final arr0 = <BookWorkEditionsModelTranslatedFrom>[];
      v.forEach((v) {
        arr0.add(BookWorkEditionsModelTranslatedFrom.fromJson(v));
      });
      translatedFrom = arr0;
    }
    publish_date = json['publish_date']?.toString();

    number_of_pages = json['number_of_pages']?.toInt();
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
    if (json['authorsNames'] != null) {
      final v = json['authorsNames'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      authorsNames = arr0;
    }
    if (json['isbn_13'] != null) {
      final v = json['isbn_13'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      isbn_13 = arr0;
    }
    physical_format = json['physical_format']?.toString();
    bookStatus = json['bookStatus']?.toString();
    imageAsByte = json['imageAsByte']?.toString();
    description = json['description']?.toString();

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
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['title'] = title;
    if (authors != null) {
      final v = authors;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['authors'] = arr0;
    }
    data['publish_date'] = publish_date;

    data['number_of_pages'] = number_of_pages;
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
    if (authorsNames != null) {
      final v = authorsNames;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['authorsNames'] = arr0;
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
    data['imageAsByte'] = imageAsByte;
    data['description'] = description;

    data['physical_format'] = physical_format;
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

    return data;
  }
}

class BookWorkEditionsModelLinks {
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
