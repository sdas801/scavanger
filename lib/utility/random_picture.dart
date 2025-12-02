import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

Widget getPicture(double height, double width) {
  Widget svgWidget = RandomAvatar(
    DateTime.now().toIso8601String(),
    height: height,
    width: width,
  );
  return svgWidget;
}
