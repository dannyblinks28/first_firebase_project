import 'package:first_firebase_project/constants/routes.dart';
import 'package:first_firebase_project/myhomepage.dart';
import 'package:first_firebase_project/services/auth/auth_service.dart';
import 'package:first_firebase_project/views/loginViews.dart';
import 'package:first_firebase_project/views/privateNoteView.dart';
import 'package:first_firebase_project/views/verify_email_view.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
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
