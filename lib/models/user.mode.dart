import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  String name;
  final String identifier;
  String img;
  String fcmToken;
  final Timestamp created;
  Timestamp? updated;

  UserModel({
    required this.uid,
    required this.name,
    required this.identifier,
    required this.img,
    required this.fcmToken,
    required this.created,
    this.updated,
  });

  // copywith function
  UserModel copyWith({
    String? uid,
    String? name,
    String? identifier,
    String? phone,
    String? qId,
    String? img,
    String? role,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      identifier: identifier ?? this.identifier,
      img: img ?? this.img,
      fcmToken: fcmToken,
      created: created,
      updated: updated,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'uid': uid,
      'name': name,
      'identifier': identifier,
      'img': img,
      'fcmToken': fcmToken,
      'created': created,
      'updated': updated,
    };
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      uid: doc['uid'],
      name: doc['name'],
      identifier: doc['identifier'],
      img: doc['img'],
      fcmToken: doc['fcmToken'],
      created: doc['created'],
      updated: doc['updated'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'identifier': identifier,
        'img': img,
        'fcmToken': fcmToken,
        'created': created,
        'updated': updated,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'],
        name: json['name'],
        identifier: json['identifier'],
        img: json['img'],
        fcmToken: json['fcmToken'],
        created: json['created'],
        updated: json['updated'],
      );

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, identifier: $identifier, img: $img, fcmToken: $fcmToken, created: $created, updated: $updated)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
