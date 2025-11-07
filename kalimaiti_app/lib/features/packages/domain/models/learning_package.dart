import 'dart:convert';

/// Represents a complete learning package as an aggregate root
/// that can be serialized/deserialized as a single JSON document
class LearningPackage {
  final int? id;
  final String author;
  final String category;
  final String description;
  final String iconUrl;
  final String language;
  final String lastUpdatedDate;
  final String level;
  final String title;
  final int version;
  final List<Word> words;

  LearningPackage({
    this.id,
    required this.author,
    required this.category,
    required this.description,
    required this.iconUrl,
    required this.language,
    required this.lastUpdatedDate,
    required this.level,
    required this.title,
    required this.version,
    required this.words,
  });

  /// Creates a LearningPackage from JSON
  factory LearningPackage.fromJson(Map<String, dynamic> json) {
    return LearningPackage(
      id: json['id'] as int?,
      author: json['author'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      language: json['language'] as String,
      lastUpdatedDate: json['lastUpdatedDate'] as String,
      level: json['level'] as String,
      title: json['title'] as String,
      version: json['version'] as int,
      words: (json['words'] as List<dynamic>)
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts the LearningPackage to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'author': author,
      'category': category,
      'description': description,
      'iconUrl': iconUrl,
      'language': language,
      'lastUpdatedDate': lastUpdatedDate,
      'level': level,
      'title': title,
      'version': version,
      'words': words.map((w) => w.toJson()).toList(),
    };
  }

  /// Creates a LearningPackage from a JSON string
  factory LearningPackage.fromJsonString(String jsonString) {
    return LearningPackage.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Converts the LearningPackage to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  LearningPackage copyWith({
    int? id,
    String? author,
    String? category,
    String? description,
    String? iconUrl,
    String? language,
    String? lastUpdatedDate,
    String? level,
    String? title,
    int? version,
    List<Word>? words,
  }) {
    return LearningPackage(
      id: id ?? this.id,
      author: author ?? this.author,
      category: category ?? this.category,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      language: language ?? this.language,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      level: level ?? this.level,
      title: title ?? this.title,
      version: version ?? this.version,
      words: words ?? this.words,
    );
  }
}

class Word {
  final int? id;
  final String text;
  final List<Definition> definitions;
  final List<Sentence> sentences;

  Word({
    this.id,
    required this.text,
    required this.definitions,
    required this.sentences,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int?,
      text: json['text'] as String,
      definitions: (json['definitions'] as List<dynamic>)
          .map((d) => Definition.fromJson(d as Map<String, dynamic>))
          .toList(),
      sentences: (json['sentences'] as List<dynamic>)
          .map((s) => Sentence.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'text': text,
      'definitions': definitions.map((d) => d.toJson()).toList(),
      'sentences': sentences.map((s) => s.toJson()).toList(),
    };
  }

  Word copyWith({
    int? id,
    String? text,
    List<Definition>? definitions,
    List<Sentence>? sentences,
  }) {
    return Word(
      id: id ?? this.id,
      text: text ?? this.text,
      definitions: definitions ?? this.definitions,
      sentences: sentences ?? this.sentences,
    );
  }
}

class Definition {
  final int? id;
  final String text;
  final String source;

  Definition({this.id, required this.text, required this.source});

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      id: json['id'] as int?,
      text: json['text'] as String,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'text': text, 'source': source};
  }

  Definition copyWith({int? id, String? text, String? source}) {
    return Definition(
      id: id ?? this.id,
      text: text ?? this.text,
      source: source ?? this.source,
    );
  }
}

class Sentence {
  final int? id;
  final String text;
  final List<Resource> resources;

  Sentence({this.id, required this.text, required this.resources});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'] as int?,
      text: json['text'] as String,
      resources: (json['resources'] as List<dynamic>)
          .map((r) => Resource.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'text': text,
      'resources': resources.map((r) => r.toJson()).toList(),
    };
  }

  Sentence copyWith({int? id, String? text, List<Resource>? resources}) {
    return Sentence(
      id: id ?? this.id,
      text: text ?? this.text,
      resources: resources ?? this.resources,
    );
  }
}

class Resource {
  final int? id;
  final String title;
  final String url;
  final String type;

  Resource({
    this.id,
    required this.title,
    required this.url,
    required this.type,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int?,
      title: json['title'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'title': title, 'url': url, 'type': type};
  }

  Resource copyWith({int? id, String? title, String? url, String? type}) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }
}
