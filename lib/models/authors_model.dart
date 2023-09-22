class AuthorsModelLastModified {
  String? type;
  String? value;

  AuthorsModelLastModified({
    this.type,
    this.value,
  });
  AuthorsModelLastModified.fromJson(Map<String, dynamic> json) {
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

class AuthorsModelCreated {
  String? type;
  String? value;

  AuthorsModelCreated({
    this.type,
    this.value,
  });
  AuthorsModelCreated.fromJson(Map<String, dynamic> json) {
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

class AuthorsModelLinksType {
  String? key;

  AuthorsModelLinksType({
    this.key,
  });
  AuthorsModelLinksType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class AuthorsModelLinks {
  String? url;
  String? title;
  AuthorsModelLinksType? type;

  AuthorsModelLinks({
    this.url,
    this.title,
    this.type,
  });
  AuthorsModelLinks.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    title = json['title']?.toString();
    type = (json['type'] != null)
        ? AuthorsModelLinksType.fromJson(json['type'])
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

class AuthorsModelType {
  String? key;

  AuthorsModelType({
    this.key,
  });
  AuthorsModelType.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    return data;
  }
}

class AuthorsModelRemoteIds {
  String? viaf;
  String? goodreads;
  String? isni;
  String? projectGutenberg;
  String? librarything;
  String? amazon;
  String? storygraph;
  String? librivox;
  String? wikidata;

  AuthorsModelRemoteIds({
    this.viaf,
    this.goodreads,
    this.isni,
    this.projectGutenberg,
    this.librarything,
    this.amazon,
    this.storygraph,
    this.librivox,
    this.wikidata,
  });
  AuthorsModelRemoteIds.fromJson(Map<String, dynamic> json) {
    viaf = json['viaf']?.toString();
    goodreads = json['goodreads']?.toString();
    isni = json['isni']?.toString();
    projectGutenberg = json['project_gutenberg']?.toString();
    librarything = json['librarything']?.toString();
    amazon = json['amazon']?.toString();
    storygraph = json['storygraph']?.toString();
    librivox = json['librivox']?.toString();
    wikidata = json['wikidata']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['viaf'] = viaf;
    data['goodreads'] = goodreads;
    data['isni'] = isni;
    data['project_gutenberg'] = projectGutenberg;
    data['librarything'] = librarything;
    data['amazon'] = amazon;
    data['storygraph'] = storygraph;
    data['librivox'] = librivox;
    data['wikidata'] = wikidata;
    return data;
  }
}

class AuthorsModel {
  String? name;
  String? deathDate;
  String? personalName;
  String? bio;
  List<String?>? alternateNames;
  AuthorsModelRemoteIds? remoteIds;
  String? key;
  String? title;
  AuthorsModelType? type;
  List<int?>? photos;
  List<AuthorsModelLinks?>? links;
  List<String?>? sourceRecords;
  String? birthDate;
  int? latestRevision;
  int? revision;
  AuthorsModelCreated? created;
  AuthorsModelLastModified? lastModified;

  AuthorsModel({
    this.name,
    this.deathDate,
    this.personalName,
    this.bio,
    this.alternateNames,
    this.remoteIds,
    this.key,
    this.title,
    this.type,
    this.photos,
    this.links,
    this.sourceRecords,
    this.birthDate,
    this.latestRevision,
    this.revision,
    this.created,
    this.lastModified,
  });
  AuthorsModel.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    deathDate = json['death_date']?.toString();
    personalName = json['personal_name']?.toString();
    bio = json['bio']?.toString();
    if (json['alternate_names'] != null) {
      final v = json['alternate_names'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      alternateNames = arr0;
    }
    remoteIds = (json['remote_ids'] != null)
        ? AuthorsModelRemoteIds.fromJson(json['remote_ids'])
        : null;
    key = json['key']?.toString();
    title = json['title']?.toString();
    type =
        (json['type'] != null) ? AuthorsModelType.fromJson(json['type']) : null;
    if (json['photos'] != null) {
      final v = json['photos'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      photos = arr0;
    }
    if (json['links'] != null) {
      final v = json['links'];
      final arr0 = <AuthorsModelLinks>[];
      v.forEach((v) {
        arr0.add(AuthorsModelLinks.fromJson(v));
      });
      links = arr0;
    }
    if (json['source_records'] != null) {
      final v = json['source_records'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      sourceRecords = arr0;
    }
    birthDate = json['birth_date']?.toString();
    latestRevision = json['latest_revision']?.toInt();
    revision = json['revision']?.toInt();
    created = (json['created'] != null)
        ? AuthorsModelCreated.fromJson(json['created'])
        : null;
    lastModified = (json['last_modified'] != null)
        ? AuthorsModelLastModified.fromJson(json['last_modified'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['death_date'] = deathDate;
    data['personal_name'] = personalName;
    data['bio'] = bio;
    if (alternateNames != null) {
      final v = alternateNames;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['alternate_names'] = arr0;
    }
    if (remoteIds != null) {
      data['remote_ids'] = remoteIds!.toJson();
    }
    data['key'] = key;
    data['title'] = title;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    if (photos != null) {
      final v = photos;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['photos'] = arr0;
    }
    if (links != null) {
      final v = links;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['links'] = arr0;
    }
    if (sourceRecords != null) {
      final v = sourceRecords;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['source_records'] = arr0;
    }
    data['birth_date'] = birthDate;
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
