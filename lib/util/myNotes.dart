import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyNotes extends StatelessWidget {
  String text;
  String postId;
  Function(BuildContext)? deleteFunction;

  MyNotes({required this.text, this.deleteFunction,required this.postId, super.key});

  Future<void> deleteNote(String postId) async {
    CollectionReference post = FirebaseFirestore.instance.collection('post');
    await post.doc(postId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(12),
              onPressed: (context) {
                deleteNote( postId);
              },
              icon: Icons.delete,
              backgroundColor: Colors.red.shade400,
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          decoration: BoxDecoration(
              color: Colors.blue.shade500,
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
