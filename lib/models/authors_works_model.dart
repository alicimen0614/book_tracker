class AuthorsWorksModelEntriesLastModified {
  String? type;
  String? value;

  AuthorsWorksModelEntriesLastModified({
    this.type,
    this.value,
  });
  AuthorsWorksModelEntriesLastModified.fromJson(Map<String, dynamic> json) {
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

class AuthorsWorksModelEntriesCreated {
  String? type;
  String? value;

  AuthorsWorksModelEntriesCreated({
    this.type,
    this.value,
  });
  AuthorsWorksModelEntriesCreated.fromJson(Map<String, dynamic> json) {
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

class AuthorsWorksModelEntriesType {
  String? key;

  AuthorsWorksModelEntriesType({
    this.key,
  });
  AuthorsWorksModelEntriesType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class AuthorsWorksModelEntriesAuthorsAuthor {
  String? key;

  AuthorsWorksModelEntriesAuthorsAuthor({
    this.key,
  });
  AuthorsWorksModelEntriesAuthorsAuthor.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class AuthorsWorksModelEntriesAuthors {
  AuthorsWorksModelEntriesAuthorsAuthor? author;

  AuthorsWorksModelEntriesAuthors({
    this.author,
  });
  AuthorsWorksModelEntriesAuthors.fromJson(Map<String, dynamic> json) {
    author = (json['author'] != null)
        ? AuthorsWorksModelEntriesAuthorsAuthor.fromJson(json['author'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (author != null) {
      data['author'] = author!.toJson();
    }
    return data;
  }
}

class AuthorsWorksModelEntriesLinksType {
  String? key;

  AuthorsWorksModelEntriesLinksType({
    this.key,
  });
  AuthorsWorksModelEntriesLinksType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class AuthorsWorksModelEntriesLinks {
  String? url;
  AuthorsWorksModelEntriesLinksType? type;
  String? title;

  AuthorsWorksModelEntriesLinks({
    this.url,
    this.type,
    this.title,
  });
  AuthorsWorksModelEntriesLinks.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    type = (json['type'] != null)
        ? AuthorsWorksModelEntriesLinksType.fromJson(json['type'])
        : null;
    title = json['title']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['url'] = url;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['title'] = title;
    return data;
  }
}

class AuthorsWorksModelEntries {
  String? description;
  List<AuthorsWorksModelEntriesLinks?>? links;
  String? title;
  List<int?>? covers;
  List<String?>? subjectPlaces;
  List<String?>? subjects;
  String? key;
  List<AuthorsWorksModelEntriesAuthors?>? authors;
  AuthorsWorksModelEntriesType? type;
  int? latestRevision;
  int? revision;
  AuthorsWorksModelEntriesCreated? created;
  AuthorsWorksModelEntriesLastModified? lastModified;

  AuthorsWorksModelEntries({
    this.description,
    this.links,
    this.title,
    this.covers,
    this.subjectPlaces,
    this.subjects,
    this.key,
    this.authors,
    this.type,
    this.latestRevision,
    this.revision,
    this.created,
    this.lastModified,
  });
  AuthorsWorksModelEntries.fromJson(Map<String, dynamic> json) {
    description = json['description']?.toString();

    if (json['links'] != null) {
      final v = json['links'];
      final arr0 = <AuthorsWorksModelEntriesLinks>[];
      v.forEach((v) {
        arr0.add(AuthorsWorksModelEntriesLinks.fromJson(v));
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
    if (json['subjects'] != null) {
      final v = json['subjects'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      subjects = arr0;
    }
    key = json['key']?.toString();
    if (json['authors'] != null) {
      final v = json['authors'];
      final arr0 = <AuthorsWorksModelEntriesAuthors>[];
      v.forEach((v) {
        arr0.add(AuthorsWorksModelEntriesAuthors.fromJson(v));
      });
      authors = arr0;
    }
    type = (json['type'] != null)
        ? AuthorsWorksModelEntriesType.fromJson(json['type'])
        : null;
    latestRevision = json['latest_revision']?.toInt();
    revision = json['revision']?.toInt();
    created = (json['created'] != null)
        ? AuthorsWorksModelEntriesCreated.fromJson(json['created'])
        : null;
    lastModified = (json['last_modified'] != null)
        ? AuthorsWorksModelEntriesLastModified.fromJson(json['last_modified'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (links != null) {
      final v = links;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['links'] = arr0;
    }
    data['title'] = title;
    data['description'] = description;
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
    if (subjects != null) {
      final v = subjects;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['subjects'] = arr0;
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
    if (type != null) {
      data['type'] = type!.toJson();
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

class AuthorsWorksModelLinks {
/*
{
  "self": "/authors/OL1394244A/works.json?limit=100",
  "author": "/authors/OL1394244A"
} 
*/

  String? self;
  String? author;

  AuthorsWorksModelLinks({
    this.self,
    this.author,
  });
  AuthorsWorksModelLinks.fromJson(Map<String, dynamic> json) {
    self = json['self']?.toString();
    author = json['author']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['self'] = self;
    data['author'] = author;
    return data;
  }
}

class AuthorsWorksModel {
  AuthorsWorksModelLinks? links;
  int? size;
  List<AuthorsWorksModelEntries?>? entries;

  AuthorsWorksModel({
    this.links,
    this.size,
    this.entries,
  });
  AuthorsWorksModel.fromJson(Map<String, dynamic> json) {
    links = (json['links'] != null)
        ? AuthorsWorksModelLinks.fromJson(json['links'])
        : null;
    size = json['size']?.toInt();
    if (json['entries'] != null) {
      final v = json['entries'];
      final arr0 = <AuthorsWorksModelEntries>[];
      v.forEach((v) {
        arr0.add(AuthorsWorksModelEntries.fromJson(v));
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
