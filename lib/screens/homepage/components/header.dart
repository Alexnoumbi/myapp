import 'package:flutter/material.dart';

//Header Widget of Mobile Web
Widget mobileHeader() {
  return Image.asset(
    'assets/images/logo.png',
    height: 40,
  );
}

//Header Widget of Tablet Web
Widget tabletHeader() {
  return Image.asset(
    'assets/images/logo.png',
    height: 40,
  );
}

//Header Widget of Desktop Web
Widget desktopHeader() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    alignment: Alignment.centerLeft,
    child: Image.asset(
      'assets/images/logo.png',
      height: 40,
    ),
  );
}
