import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageBoxWidget extends StatelessWidget {
  const ImageBoxWidget({Key? key, required this.byteImage}) : super(key: key);
  final Uint8List byteImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Image.memory(
        byteImage,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          return const Text("Couldn't load Image!");
        },
      ),
    );
  }
}
