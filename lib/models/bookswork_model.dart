///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class BookWorkModelLastModified {
/*
{
  "type": "/type/datetime",
  "value": "2023-03-25T16:40:13.820692"
} 
*/

  String? type;
  String? value;

  BookWorkModelLastModified({
    this.type,
    this.value,
  });
  BookWorkModelLastModified.fromJson(Map<String, dynamic> json) {
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

class BookWorkModelCreated {
/*
{
  "type": "/type/datetime",
  "value": "2009-10-24T07:26:31.097043"
} 
*/

  String? type;
  String? value;

  BookWorkModelCreated({
    this.type,
    this.value,
  });
  BookWorkModelCreated.fromJson(Map<String, dynamic> json) {
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

class BookWorkModelFirstSentence {
/*
{
  "type": "/type/text",
  "value": "\"I AM afraid, Watson, that I shall have to go,\" said Holmes, as we sat down together to our breakfast one morning."
} 
*/

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

class BookWorkModelType {
/*
{
  "key": "/type/work"
} 
*/

  String? key;

  BookWorkModelType({
    this.key,
  });
  BookWorkModelType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkModelExcerptsAuthor {
/*
{
  "key": "/people/seabelis"
} 
*/

  String? key;

  BookWorkModelExcerptsAuthor({
    this.key,
  });
  BookWorkModelExcerptsAuthor.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkModelExcerpts {
/*
{
  "author": {
    "key": "/people/seabelis"
  },
  "comment": "first sentence",
  "excerpt": "I am afraid, Watson, that I shall have to go,” said Holmes, as we sat down together to our breakfast one morning."
} 
*/

  BookWorkModelExcerptsAuthor? author;
  String? comment;
  String? excerpt;

  BookWorkModelExcerpts({
    this.author,
    this.comment,
    this.excerpt,
  });
  BookWorkModelExcerpts.fromJson(Map<String, dynamic> json) {
    author = (json['author'] != null)
        ? BookWorkModelExcerptsAuthor.fromJson(json['author'])
        : null;
    comment = json['comment']?.toString();
    excerpt = json['excerpt']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['comment'] = comment;
    data['excerpt'] = excerpt;
    return data;
  }
}

class BookWorkModelAuthorsType {
/*
{
  "key": "/type/author_role"
} 
*/

  String? key;

  BookWorkModelAuthorsType({
    this.key,
  });
  BookWorkModelAuthorsType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkModelAuthorsAuthor {
/*
{
  "key": "/authors/OL161167A"
} 
*/

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
/*
{
  "author": {
    "key": "/authors/OL161167A"
  },
  "type": {
    "key": "/type/author_role"
  }
} 
*/

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

class BookWorkModelLinksType {
/*
{
  "key": "/type/link"
} 
*/

  String? key;

  BookWorkModelLinksType({
    this.key,
  });
  BookWorkModelLinksType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class BookWorkModelLinks {
/*
{
  "url": "http://viaf.org/viaf/7282151051794333530000",
  "title": "VIAF ID: 7282151051794333530000 (Work)",
  "type": {
    "key": "/type/link"
  }
} 
*/

  String? url;
  String? title;
  BookWorkModelLinksType? type;

  BookWorkModelLinks({
    this.url,
    this.title,
    this.type,
  });
  BookWorkModelLinks.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    title = json['title']?.toString();
    type = (json['type'] != null)
        ? BookWorkModelLinksType.fromJson(json['type'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['url'] = url;
    data['title'] = title;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    return data;
  }
}

class BookWorkModel {
/*
{
  "description": "Contains:\r\n\r\n[Silver Blaze](https://openlibrary.org/works/OL1518358W/Silver_Blaze)\r\n[Adventure of the Yellow Face](https://openlibrary.org/works/OL20571966W/Adventure_of_the_Yellow_Face)\r\n[Stock-Broker's Clerk](https://openlibrary.org/works/OL20619319W/Adventure_of_the_Stockbroker's_Clerk)\r\n[Adventure of the Gloria Scott](https://openlibrary.org/works/OL20619337W/Adventure_of_the_Gloria_Scott)\r\n[Adventure of the Musgrave Ritual](https://openlibrary.org/works/OL20619374W/Adventure_of_the_Musgrave_Ritual)\r\nAdventure of the Reigate Squire\r\nCrooked Man\r\n[Adventure of the Resident Patient](https://openlibrary.org/works/OL16090759W)\r\nAdventure of the Greek interpreter\r\n[Naval Treaty](https://openlibrary.org/works/OL14930289W/The_Naval_Treaty)\r\nFinal Problem\r\n\r\n\r\n----------\r\nAlso contained in:\r\n\r\n - [Adventures and Memoirs of Sherlock Holmes](https://openlibrary.org/works/OL1518128W)\r\n - [Celebrated Cases of Sherlock Holmes](https://openlibrary.org/works/OL16076930W)\r\n - [Complete Sherlock Holmes: Volume I](https://openlibrary.org/works/OL18188824W)\r\n - [Complete Sherlock Holmes, Volume I](https://openlibrary.org/works/OL14929975W)\r\n - [Short Stories](https://openlibrary.org/works/OL14929977W)\r\n - [Works](https://openlibrary.org/works/OL16173818W)",
  "links": [
    {
      "url": "http://viaf.org/viaf/7282151051794333530000",
      "title": "VIAF ID: 7282151051794333530000 (Work)",
      "type": {
        "key": "/type/link"
      }
    }
  ],
  "title": "Memoirs of Sherlock Holmes [11 stories]",
  "covers": [
    9246429
  ],
  "subject_places": [
    "Brook Street"
  ],
  "first_publish_date": "August 12, 1979",
  "subject_people": [
    "Sherlock Holmes"
  ],
  "key": "/works/OL262463W",
  "authors": [
    {
      "author": {
        "key": "/authors/OL161167A"
      },
      "type": {
        "key": "/type/author_role"
      }
    }
  ],
  "excerpts": [
    {
      "author": {
        "key": "/people/seabelis"
      },
      "comment": "first sentence",
      "excerpt": "I am afraid, Watson, that I shall have to go,” said Holmes, as we sat down together to our breakfast one morning."
    }
  ],
  "type": {
    "key": "/type/work"
  },
  "subjects": [
    "Crime & Mystery"
  ],
  "first_sentence": {
    "type": "/type/text",
    "value": "\"I AM afraid, Watson, that I shall have to go,\" said Holmes, as we sat down together to our breakfast one morning."
  },
  "latest_revision": 52,
  "revision": 52,
  "created": {
    "type": "/type/datetime",
    "value": "2009-10-24T07:26:31.097043"
  },
  "last_modified": {
    "type": "/type/datetime",
    "value": "2023-03-25T16:40:13.820692"
  }
} 
*/

  String? description;
  List<BookWorkModelLinks?>? links;
  String? title;
  List<int?>? covers;
  List<String?>? subjectPlaces;
  String? firstPublishDate;
  List<String?>? subjectPeople;
  String? key;
  List<BookWorkModelAuthors?>? authors;
  List<BookWorkModelExcerpts?>? excerpts;
  BookWorkModelType? type;
  List<String?>? subjects;
  BookWorkModelFirstSentence? firstSentence;
  int? latestRevision;
  int? revision;
  BookWorkModelCreated? created;
  BookWorkModelLastModified? lastModified;

  BookWorkModel({
    this.description,
    this.links,
    this.title,
    this.covers,
    this.subjectPlaces,
    this.firstPublishDate,
    this.subjectPeople,
    this.key,
    this.authors,
    this.excerpts,
    this.type,
    this.subjects,
    this.firstSentence,
    this.latestRevision,
    this.revision,
    this.created,
    this.lastModified,
  });
  BookWorkModel.fromJson(Map<String, dynamic> json) {
    description = json['description']?.toString();
    if (json['links'] != null) {
      final v = json['links'];
      final arr0 = <BookWorkModelLinks>[];
      v.forEach((v) {
        arr0.add(BookWorkModelLinks.fromJson(v));
      });
      links = arr0;
    }
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
    if (json['excerpts'] != null) {
      final v = json['excerpts'];
      final arr0 = <BookWorkModelExcerpts>[];
      v.forEach((v) {
        arr0.add(BookWorkModelExcerpts.fromJson(v));
      });
      excerpts = arr0;
    }
    type = (json['type'] != null)
        ? BookWorkModelType.fromJson(json['type'])
        : null;
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
    latestRevision = json['latest_revision']?.toInt();
    revision = json['revision']?.toInt();
    created = (json['created'] != null)
        ? BookWorkModelCreated.fromJson(json['created'])
        : null;
    lastModified = (json['last_modified'] != null)
        ? BookWorkModelLastModified.fromJson(json['last_modified'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;
    if (links != null) {
      final v = links;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['links'] = arr0;
    }
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
    if (excerpts != null) {
      final v = excerpts;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['excerpts'] = arr0;
    }
    if (type != null) {
      data['type'] = type!.toJson();
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
