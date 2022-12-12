import 'package:first_firebase_project/util/my_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onPost;
  VoidCallback onCancel;
  DialogBox(
      {required this.onPost,
      required this.onCancel,
      required this.controller,
      super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue.shade700,
      content: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //notes
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add a new note',
              ),
            ),
            //buttons = save & cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //save
                MyButton(onPressed: onPost, text: 'Post'),
                //cancel
                const SizedBox(width: 8),
                MyButton(onPressed: onCancel, text: 'Cancel'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
