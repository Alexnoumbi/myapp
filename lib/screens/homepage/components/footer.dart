import 'package:flutter/material.dart';

Widget desktopFooter() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(20),
    alignment: Alignment.center,
    child: Image.asset(
      'assets/images/logo.png',
      height: 40,
    ),
  );
}
