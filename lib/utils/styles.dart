import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color primary = const Color.fromARGB(255, 34, 34, 34);

class Styles {
  static Color blackColor = primary;
  static Color blueColor = const Color.fromARGB(255, 50, 64, 255);
  static Color whiteColor = const Color.fromARGB(255, 255, 255, 255);
  static Color greyColor = const Color.fromARGB(255, 202, 202, 202);
  static Color textColor = primary;
  static Color subtextColor = const Color.fromARGB(255, 82, 82, 82);
  static TextStyle headlineStyle1 = GoogleFonts.poppins(
      color: textColor,
      fontWeight: FontWeight.w600,
      fontSize: 35,
      letterSpacing: -0.5);
  static TextStyle headlineStyle2 = GoogleFonts.poppins(
      color: subtextColor,
      fontWeight: FontWeight.w500,
      fontSize: 25,
      letterSpacing: -0.5);
  static TextStyle headlineStyle3 = GoogleFonts.poppins(
      color: subtextColor,
      fontWeight: FontWeight.w400,
      fontSize: 18,
      letterSpacing: -0.5);
  static TextStyle tabBarStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    letterSpacing: -0.5,
  );
  static TextStyle transactionTitle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500, color: Styles.blackColor);
  static TextStyle transactionAmount = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static TextStyle transactionDate = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
