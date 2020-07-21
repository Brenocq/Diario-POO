import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class NewDiaryPage extends StatefulWidget {
  @override
  _NewDiaryPageState createState() => _NewDiaryPageState();
}

class _NewDiaryPageState extends State<NewDiaryPage> {
  // Stores the title data
  final titleController = TextEditingController();
  // Stores the description data
  final descController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar página'),
        elevation: 2.0,
      ),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            children: <Widget>[
              Text(
                "Seu dia em 5 palavras!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Uma sensação? Um lugar?'),
              ),
              SizedBox(height: 10),
              Text(
                "Descricao",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(hintText: 'O que aconteceu hoje?'),
              ),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {
                  sendPageToFirebase(context, titleController, descController);
                },
                child: Text("Salvar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> sendPageToFirebase(BuildContext context,
    TextEditingController title, TextEditingController desc) async {
  print('title:${title.text}\ndesc:${desc.text}');

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseUser user = await auth.currentUser();
  final userid = user.uid;

  // Get firebase user
  if (title.text.isNotEmpty && desc.text.isNotEmpty) {
    Firestore.instance
        .collection(userid)
        .add({
          'title': title.text,
          'description': desc.text,
          'creationDate': FieldValue.serverTimestamp(),
        })
        .then((result) => {
              Navigator.pop(context),
            })
        .catchError((err) => {print("[ERROR]: $err")});
  } else {
    print("These fields should not be empty");
  }
}
