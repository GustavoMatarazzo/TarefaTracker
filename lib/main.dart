import 'package:flutter/material.dart';
import 'package:projeto/login_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(TarefaTrackerApp());
}

class TarefaTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TarefaTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
