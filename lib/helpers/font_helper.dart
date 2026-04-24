import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle safeGoogleFont(
  String fontName, {
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
  double? height,
  FontStyle? fontStyle,
}) {
  final bool isTest = RegExp(r'_test.dart$').hasMatch(Platform.script.path) || Platform.environment.containsKey('FLUTTER_TEST');

  if (isTest) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
    );
  }

  try {
    return GoogleFonts.getFont(
      fontName,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
    );
  } catch (e) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
    );
  }
}
