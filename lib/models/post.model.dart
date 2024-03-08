import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String uid;
  String title;
  String description;
  final Timestamp created;
  final String creator;
  String? updator;
  Timestamp? updated;

  PostModel({
    required this.uid,
    required this.title,
    required this.description,
    required this.created,
    required this.creator,
    this.updator,
    this.updated,
  });

  // copywith function
  PostModel copyWith({
    String? uid,
    String? title,
    String? description,
    String? creator,
    String? updator,
    Timestamp? created,
    Timestamp? updated,
  }) {
    return PostModel(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      creator: creator ?? this.creator,
      updator: updator ?? this.updator,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'uid': uid,
      'title': title,
      'description': description,
      'creator': creator,
      'updator': updator,
      'created': created,
      'updated': updated,
    };
  }

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    return PostModel(
      uid: doc['uid'],
      title: doc['title'],
      description: doc['description'],
      creator: doc['creator'],
      updator: doc['updator'],
      created: doc['created'],
      updated: doc['updated'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'description': description,
        'creator': creator,
        'updator': updator,
        'created': created,
        'updated': updated,
      };

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        uid: json['uid'],
        title: json['title'],
        description: json['description'],
        creator: json['creator'],
        updator: json['updator'],
        created: json['created'],
        updated: json['updated'],
      );

  @override
  String toString() =>
      'PostModel(uid: $uid, title: $title, description: $description, creator: $creator, updator: $updator, created: $created, updated: $updated)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
