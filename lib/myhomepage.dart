import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_firebase_project/constants/routes.dart';
import 'package:first_firebase_project/views/loginViews.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Input Name'),
            ),
            TextField(
              enableSuggestions: false,
              autocorrect: false,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'Input email'),
            ),
            TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: _password,
              decoration: InputDecoration(hintText: 'Input password'),
            ),
            TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      devtools.log('weak password');
                    } else if (e.code == 'email-already-in-use') {
                      devtools.log('email already in use');
                    } else if (e.code == 'invalid-email') {
                      devtools.log('invalied email entered');
                    }
                  }
                },
                child: Text('Register')),
            Container(
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.red),
            ),
            SizedBox(height: 20),
            Text('Already registered? '),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                child: Text('Login')),
          ],
        ),
      ),
    );
  }
}