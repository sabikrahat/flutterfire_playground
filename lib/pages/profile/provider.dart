import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_playground/firebase/constant.dart';
import 'package:flutterfire_playground/models/user.mode.dart';

typedef ProfileNotifier
    = AutoDisposeAsyncNotifierProviderFamily<ProfileProvider, UserModel?, bool>;

final profileProvider = ProfileNotifier(ProfileProvider.new);

class ProfileProvider extends AutoDisposeFamilyAsyncNotifier<UserModel?, bool> {
  late TextEditingController nameCntrlr;
  late GlobalKey<FormState> formKey;
  late bool isEditable;
  dynamic image;
  bool isLoading = false;
  UserModel? user;

  @override
  FutureOr<UserModel?> build(bool arg) async {
    isEditable = arg;
    formKey = GlobalKey<FormState>();
    user = await FirebaseFirestore.instance
        .collection(users)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((doc) {
      if (!doc.exists) return null;
      return UserModel.fromDocument(doc);
    });
    nameCntrlr = TextEditingController(text: user?.name);
    return user;
  }

  void toggleEditable() {
    isEditable = !isEditable;
    ref.notifyListeners();
  }

  void setImage(var img) {
    image = img;
    ref.notifyListeners();
  }

  void removeImage() {
    image = null;
    ref.notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (user == null && image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    final url = await uploadImage(image);
    isLoading = true;
    ref.notifyListeners();
    final usr = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection(users)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(
          UserModel(
            uid: user?.uid ??
                usr?.uid ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            name: nameCntrlr.text,
            identifier:
                user?.identifier ?? usr?.email ?? usr?.phoneNumber ?? '',
            img: user?.img ?? url ?? 'https://via.placeholder.com/150',
            fcmToken: user?.fcmToken ?? '',
            created: user?.created ?? Timestamp.now(),
            updated: Timestamp.now(),
          ).toJson(),
        );
    isLoading = false;
    ref.notifyListeners();
  }
}

Future<String?> uploadImage(dynamic file) {
  if (kIsWeb) return uploadImageWeb(file);
  return uploadImageMobile(file);
}

Future<String?> uploadImageMobile(File? file) async {
  if (file == null) return null;
  try {
    final ref = FirebaseStorage.instance.ref().child(
        'images/${FirebaseAuth.instance.currentUser!.uid}.${file.path.split('.').last}');
    UploadTask? uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});

    final downloadUrl = await snapshot.ref.getDownloadURL();
    debugPrint('Photo uploaded. Url: $downloadUrl');
    return downloadUrl;
  } catch (e) {
    debugPrint('error in uploading image for : ${e.toString()}');
    return null;
  }
}

Future<String?> uploadImageWeb(PlatformFile file) async {
  debugPrint('executing...');

  try {
    TaskSnapshot upload = await FirebaseStorage.instance
        .ref(
            'images/${FirebaseAuth.instance.currentUser!.uid}.${file.extension}')
        .putData(
          file.bytes!,
          SettableMetadata(contentType: 'image/${file.extension}'),
        );

    String downloadUrl = await upload.ref.getDownloadURL();
    debugPrint('Photo uploaded. Url: $downloadUrl');
    return downloadUrl;
  } catch (e) {
    debugPrint('error in uploading image for : ${e.toString()}');
    return null;
  }
}
