import 'package:flutter/material.dart';
//import 'package:lite_rolling_switch/lite_rolling_switch.dart';
//import 'dart:async';
//import 'dart:io';
//import 'package:flutter/services.dart' show rootBundle;
//import 'package:flutter/material.dart';
//import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

//import 'AffichagePeremption.dart';
import 'HomePage.dart';
import 'AppState.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
