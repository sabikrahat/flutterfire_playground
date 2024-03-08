import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'file.picker.dart';
import 'modal.bottom.sheet.menu.dart';

Future<Object?> pickPhoto(BuildContext context, {bool isCircle = false}) async {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    return await modalBottomSheetMenu(context, isCircle: isCircle);
  }
  return await filePickFromDevice();
}
