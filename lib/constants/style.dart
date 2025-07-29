import 'package:flutter/material.dart';

Color light = const Color(0xFFF7F8FC);
Color lightGrey = const Color(0xFFA4A6B3);
Color dark = const Color(0xFF363740);
Color active = const Color(0xFF00BF6D);

class AppStyles {
  static const Color mainColor = Color(0xFF00BF6D);
  static const Color mainLightColor = Color(0xFFF5FCF9);
  static const Color mainDarkColor = Color(0xFF1A1F24);
  static const Color mainGreyColor = Color(0xFF9E9E9E);
  
  static TextStyle get headerStyle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: mainDarkColor,
  );
  
  static TextStyle get subHeaderStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: mainDarkColor,
  );

  static TextStyle get cardTitleStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: mainDarkColor,
  );

  // Styles pour les indicateurs de performance
  static TextStyle get indicatorTitleStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: mainDarkColor,
  );

  static TextStyle get indicatorValueStyle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: mainColor,
  );

  static TextStyle get indicatorLabelStyle => const TextStyle(
    fontSize: 14,
    color: mainGreyColor,
  );

  static BoxDecoration get indicatorCardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 2,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Palettes de couleurs pour les graphiques
  static List<Color> get chartColors => const [
    Color(0xFF00BF6D),
    Color(0xFF366CF6),
    Color(0xFFFFA113),
    Color(0xFFFF5959),
    Color(0xFF8B75D7),
  ];
}
