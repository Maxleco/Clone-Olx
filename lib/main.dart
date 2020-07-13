import 'package:flutter/material.dart';
import 'package:olx/RouteGenerator.dart';
import 'package:olx/views/Anuncios.dart';

void main() {
  runApp(MyApp());
}

  final ThemeData defaultTheme = ThemeData(
    primaryColor: Color(0xff9c27b0),
    accentColor: Color(0xff7b1fa2),
  );

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OLX',
      theme: defaultTheme,
      home: Anuncios(),
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}