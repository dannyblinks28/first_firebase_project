import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_firebase_project/constants/routes.dart';
import 'package:first_firebase_project/myhomepage.dart';
import 'package:first_firebase_project/views/loginViews.dart';
import 'package:first_firebase_project/views/privateNoteView.dart';
import 'package:first_firebase_project/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const MyHomePage(),
        mynotesRoute: (context) => PrivateNoteView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  return const MyHomePage();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
