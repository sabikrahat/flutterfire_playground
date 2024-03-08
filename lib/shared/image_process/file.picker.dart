import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Future<PlatformFile?> filePickFromDevice() async {
  try {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: 'Select an Image',
    );
    if (file == null) return null;
    return file.files.single;
  } on PlatformException catch (e) {
    debugPrint('No Image found. Error: $e');
    return null;
  }
}
