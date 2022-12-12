import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_firebase_project/constants/routes.dart';
import 'package:first_firebase_project/myhomepage.dart';
import 'package:first_firebase_project/views/loginViews.dart';
import 'package:first_firebase_project/views/privateNoteView.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const MyHomePage(),
        mynotesRoute: (context) => PrivateNoteView(),
      },
    );
  }
}
