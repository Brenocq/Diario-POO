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
    setUserId();
    var dados = Crud.obterDados(_userId); // TODO: consertar exceção: o id não está sendo atualizado a tempo.
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
      child:  StreamBuilder<List<dynamic>>(
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

  void telaPaginaDeEdicao(documento){
    String descricaoCurta = documento['descricaoCurta'];
    String descricaoLonga = documento['descricaoLonga'];
    String emoji = documento['emoji'];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewDiaryPage(descricaoCurta, descricaoLonga, emoji, documento.documentID)),
    ).then((value) {
      try {
        setState(() {});
      } catch (e){
        print('Ia bugar mas esse código salvou!');
        initState();
      }
    });
  }

  void telaNovaPagina(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewDiaryPage(null, null, null, null)),
    ).then((value) {
      try {
        setState(() {});
      } catch (e){
        print('Ia bugar mas esse código salvou!');
        initState();
      }
    });
  }

  void opcoesDeAcao(String opcao){
    switch(opcao){
      case _Opcoes.sair:
        _signOut();
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
    final String _emoji = documento['emoji'];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            (_emoji != null ? _emoji + ' ' : '') + documento['descricaoCurta'] + ' ' + (_emoji != null ? _emoji + ' ' : ''),
            style: TextStyle(fontSize: 20.0)),
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

  Future<bool> editarNota(BuildContext context, documento) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Editar nota', style: TextStyle(fontSize: 20.0)),
            content: SingleChildScrollView(
                child: Text('Deseja editar essa nota?')),
            actions: <Widget>[
              FlatButton(
                child: Text('Sim'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                  return telaPaginaDeEdicao(documento);
                },
              ),
              FlatButton(
                child: Text('Não'),
                textColor: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  Future<bool> deletarNota(BuildContext context, querySnap, documento){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tem certeza que deseja excluir?', style: TextStyle(fontSize: 20.0)),
          content: SingleChildScrollView(
              child: Text('Essa nota será excluída permanentemente.')),
          actions: <Widget>[
            FlatButton(
              child: Text('Sim'),
              textColor: Colors.blue,
              onPressed: () {
                Crud.deletaPagina(_userId, documento.documentID);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            FlatButton(
              child: Text('Não'),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  Future<List<dynamic>> getDiaryPages() async {

    var firestore = Firestore.instance;

    await setUserId();

    String _diaEMesDaPaginaAnterior = null;

    var querySnap = await firestore
        .collection(_userId).orderBy('dataDeCriacao', descending: true).getDocuments();

    List<Widget> _lista = new List();
    querySnap.documents.forEach((DocumentSnapshot documento){
      Text _texto = _data(documento);
      DiaryPage _pagina = _diaryPage(documento, querySnap);

      if(_diaEMesDaPaginaAnterior != _texto.data){
        _lista.add(_texto);
      }
      _lista.add(_pagina);

      _diaEMesDaPaginaAnterior = _diaEMes(_extraiData(documento)); // TODO: otimizar isso aqui pra que o _texto não seja produzido o tempo todo
    });

    return _lista;
  }

  DiaryPage _diaryPage(DocumentSnapshot documento, QuerySnapshot snapshot){
    DiaryPage _pagina = DiaryPage(
      descricaoCurta: documento['descricaoCurta'],
      descricaoLonga: documento['descricaoLonga'],
      emoji: documento['emoji'],
      dataDeCriacao: documento['dataDeCriacao'],
      idDoUsuario: _userId,
      idDaPagina: documento.documentID,
      olhar: () {
        return olharNota(context, documento);
      },
      deletar: () {
        return deletarNota(context, snapshot, documento);
      },
      editar: (){
        return editarNota(context, documento);
      },
    );

    return _pagina;
  }

  Text _data(DocumentSnapshot documento){
    DateTime _data = _extraiData(documento);
    return Text(_diaEMes(_data));
  }

  DateTime _extraiData(DocumentSnapshot documento){
    Timestamp _timeStamp = documento['dataDeCriacao'];
    DateTime _dataDeCriacao = DateTime.fromMillisecondsSinceEpoch(_timeStamp.millisecondsSinceEpoch);

    return _dataDeCriacao;
  }

  String _diaEMes(DateTime data){
    if(data == null) return null;
    return data.day.toString() + '/' + data.month.toString();
  }
}

class _Opcoes{
  static const String sair = 'Sair';
  static const String atualizar = 'Atualizar';
  
  static const List<String> escolhas = <String>[
    atualizar,
    sair,
  ];
}
