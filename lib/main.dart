import 'package:enhanzer_login_project/screens/app_login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enhanzer Login Project',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AppLoginScreen(),
    );
  }
}