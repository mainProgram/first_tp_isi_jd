import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tp2/screens/list_tache.dart';
import 'package:tp2/screens/list_todo.dart';
import 'firebase_options.dart';
import 'interfaces/homepage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: const TodolistPage(),
    );
  }
}