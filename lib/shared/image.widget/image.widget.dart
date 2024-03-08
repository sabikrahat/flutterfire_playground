import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'components/android.ios.image.dart';
import 'components/linux.windows.macos.image.dart';
import 'components/web.image.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget(this.image, {super.key});

  final dynamic image;

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? WebImage(image.bytes!)
        : defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS
            ? AndroidIOSImage(image)
            : LinuxWindowsMacOsImage(image);
  }
}
