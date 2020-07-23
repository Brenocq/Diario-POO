import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diariopoo/services/Crud.dart';
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
  var _paginasDoDiario;

  Future<void> _signOut() async {
    try {
      await widget.auth.signOut();
    } catch (e) {
      print('Erro na função _signOut: ' + e.toString());
    }
  }

  Future<void> setUserId() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    _userId = user.uid;
  }

  @override
  void initState(){
    var dados = Crud.obterDados(_userId);
    setState(() {
      _paginasDoDiario = dados;
    });
    super.initState();
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
              return _Opcoes.escolhas.map((String opcao){
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

    Stream<List<dynamic>> _paginas = Stream.fromFuture(getDiaryPages());

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder<List<dynamic>>(
        stream: _paginas,
        builder:
          (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
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
      case _Opcoes.sair:
        _signOut();
        print(opcao);
        break;

      case _Opcoes.editar:
        print(opcao);
        break;

      case _Opcoes.atualizar:
        var _dados = Crud.obterSnap(_userId);
        setState(() {
          _paginasDoDiario = _dados;
        });
    }
  }

  Future<bool> olharNota(BuildContext context, DocumentSnapshot documento) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(documento['descricaoCurta'], style: TextStyle(fontSize: 20.0)),
          content: SingleChildScrollView(
              child: Text(documento['descricaoLonga'])),
          actions: <Widget>[
            FlatButton(
              child: Text('Voltar'),
              textColor: Colors.blue,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  void deletarNota(BuildContext context, querySnap, document){
    Crud.deletaPagina(_userId, document.documentID);
  }

  Future<List<dynamic>> getDiaryPages() async {

    var firestore = Firestore.instance;

    await setUserId();

    var querySnap = await firestore
        .collection(_userId).orderBy('dataDeCriacao', descending: true).getDocuments();

    var list = querySnap.documents
        .map((DocumentSnapshot document){
          return DiaryPage(
            descricaoCurta: document['descricaoCurta'],
            descricaoLonga: document['descricaoLonga'],
            dataDeCriacao: document['dataDeCriacao'],
            idDoUsuario: _userId,
            idDaPagina: document.documentID,
            olhar: () {
              return olharNota(context, document);
            },
            deletar: () {
              setState(() {
                deletarNota(context, querySnap, document);
              });
            }
          );
        }
    ).toList();

    return list;
  }
}

class _Opcoes{
  static const String editar = 'Editar';
  static const String sair = 'Sair';
  static const String atualizar = 'Atualizar';
  
  static const List<String> escolhas = <String>[
    editar,
    atualizar,
    sair,
  ];
}
