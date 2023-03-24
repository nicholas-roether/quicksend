import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dialog_icon_button.dart';

class ImageSourceDialog extends StatelessWidget {
  const ImageSourceDialog({Key? key, required this.iconButtonCallback})
      : super(key: key);
  final void Function(ImageSource) iconButtonCallback;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 110,
        width: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DialogIconButton(
              title: "Camera",
              onPressedCallback: () => iconButtonCallback(ImageSource.camera),
              icon: Icons.camera,
              tooltip: "Take a picture",
            ),
            DialogIconButton(
              icon: Icons.image,
              onPressedCallback: () => iconButtonCallback(ImageSource.gallery),
              title: "Gallery",
              tooltip: "Pick an image",
            ),
          ],
        ),
      ),
    );
  }
}
