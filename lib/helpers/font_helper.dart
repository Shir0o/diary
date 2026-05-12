import 'package:flutter/material.dart';

TextStyle safeGoogleFont(
  String fontName, {
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
  double? height,
  FontStyle? fontStyle,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: fontName,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
  );
}
