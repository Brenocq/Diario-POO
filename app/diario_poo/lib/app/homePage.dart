import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diariopoo/app/newDiaryPage.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'page.dart';

class HomePage extends StatefulWidget {
  HomePage({
    @required this.auth
  });
  final AuthBase auth;

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  String _userId;

  Future<void> _signOut() async {
    try {
      await widget.auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> setUserId() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    _userId = user.uid;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Página inicial'),
        actions: <Widget>[
          PopupMenuButton<String>(
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: opcoesDeAcao,
            itemBuilder: (BuildContext context){
              return Opcoes.escolhas.map((String opcao){
                return PopupMenuItem<String>(
                  value: opcao,
                  child: Text(opcao),
                );
              }).toList();
            },
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: getPaginas(),
      floatingActionButton: FloatingActionButton(
        onPressed: telaNovaPagina,
        tooltip: 'Escrever',
        child: Icon(Icons.add),
      ),
    );
  }

  Container getPaginas(){
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder<List<dynamic>>(
        future: getDiaryPages(),
        builder:
          (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return CircularProgressIndicator(); // TODO: colocar círculo no meio da tela
              default:
                return ListView(
                  children:
                    snapshot.data.toList(),
                );
            }
          },
        ),
    );
  }

  void telaNovaPagina(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewDiaryPage()),
    ).then((value) {
      setState(() {});
    });
  }

  void opcoesDeAcao(String opcao){
    switch(opcao){
      case Opcoes.sair:
        _signOut();
        print(opcao);
        break;

      case Opcoes.editar:
        print(opcao);
        break;
    }
  }


  Future<List<dynamic>> getDiaryPages() async {
    var firestore = Firestore.instance;

    await setUserId();

    var querySnap = await firestore
        .collection(_userId).orderBy('creationDate', descending: true).getDocuments();

    return (querySnap.documents
        .map((DocumentSnapshot document) =>
          DiaryPage(
            title: document['title'],
            description: document['description'],
            day: "Hoje",
          )
    ).toList());
  }
}

class Opcoes{
  static const String editar = 'Editar';
  static const String sair = 'Sair';  
  
  static const List<String> escolhas = <String>[
    editar,
    sair,
  ];
}
