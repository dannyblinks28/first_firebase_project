import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_firebase_project/views/loginViews.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:developer' as devtools show log;

import '../constants/routes.dart';
import '../enums/menu_actions.dart';
import '../services/auth/auth_service.dart';
import '../util/myNotes.dart';
import 'dialogBox.dart';

class PrivateNoteView extends StatefulWidget {
  PrivateNoteView({super.key});

  @override
  State<PrivateNoteView> createState() => _PrivateNoteViewState();
}

//text controller
final _controller = TextEditingController();

class _PrivateNoteViewState extends State<PrivateNoteView> {
  CollectionReference post = FirebaseFirestore.instance.collection('post');
  final Stream<QuerySnapshot> _postStream =
      FirebaseFirestore.instance.collection('post').snapshots();

  void postNewComment() {
    setState(() {
      createAPost(_controller.text);
      notes.add([_controller.text]);
      _controller.clear();
    });
    Navigator.of(context).pop();
  }

  void enterNote() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onPost: postNewComment,
            onCancel: (() => Navigator.of(context).pop()),
          );
        });
  }

  List notes = [
    [
      'flutter is used for making web, desktop and mobile applications',
    ]
  ];

  Future<void> createAPost(String text) {
    final postDoc = post.doc();
    return postDoc
        .set({
          "post": text,
          "postId": postDoc.id,
        })
        .then((value) => devtools.log("post"))
        .catchError((error) => devtools.log("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: enterNote,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Private Note'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('sign out'),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _postStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map(
              (DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return MyNotes(
                  text: data['post'],
                  postId: data["postId"],
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Logout')),
        ],
      );
    },
  ).then((value) => value ?? false);
}
