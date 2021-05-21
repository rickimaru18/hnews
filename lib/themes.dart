import 'package:flutter/material.dart';

final ThemeData themes = ThemeData(
  primarySwatch: Colors.grey,
  accentColor: Colors.amber,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[800],
  ),
  brightness: Brightness.dark,
  canvasColor: Colors.transparent,
  tabBarTheme: const TabBarTheme(
    labelColor: Colors.amber,
    unselectedLabelColor: Colors.white,
  ),
  cardColor: Colors.black,
);
