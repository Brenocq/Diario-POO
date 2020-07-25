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
    setState(() {
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Página inicial'),
        backgroundColor: Colors.orange[400],
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
      backgroundColor: Color(0xffffe4c7),
      floatingActionButton: FloatingActionButton(
        onPressed: telaNovaPagina,
        tooltip: 'Escrever',
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange[400],
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
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    return snapshot.data.elementAt(index);
                  }
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
        setState(() {
        });
    }
  }

  Future<bool> olharNota(BuildContext context, DocumentSnapshot documento) async {
    final String _emoji = documento['emoji'];

    DateTime _tempo = _extraiData(documento);
    final String _horario = _horasEMinutos(_tempo);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.orange[50],
          title: Text(
            _horario + '\n\n' + (_emoji != null ? _emoji + ' ' : '') + documento['descricaoCurta'] + ' ' +
                (_emoji != null ? _emoji + ' ' : ''),
            style: TextStyle(fontSize: 20.0)),
          content: SingleChildScrollView(
              child: Text(documento['descricaoLonga'])),
          actions: <Widget>[
            FlatButton(
              child: Text('Voltar'),
              textColor: Colors.deepOrange,
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
            backgroundColor: Colors.orange[50],
            title: Text('Editar nota', style: TextStyle(fontSize: 20.0)),
            content: SingleChildScrollView(
                child: Text('Deseja editar essa nota?')),
            actions: <Widget>[
              FlatButton(
                child: Text('Sim'),
                textColor: Colors.amber[600],
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
          backgroundColor: Colors.orange[50],
          title: Text('Tem certeza que deseja excluir?', style: TextStyle(fontSize: 20.0)),
          content: SingleChildScrollView(
              child: Text('Essa nota será excluída permanentemente.')),
          actions: <Widget>[
            FlatButton(
              child: Text('Sim'),
              textColor: Colors.amber[600],
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

  Future<bool> editarOuDeletarNota(BuildContext context, querySnap, documento){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.orange[50],
            title: Text('O que deseja fazer?', style: TextStyle(fontSize: 20.0)),
            content: SingleChildScrollView(
                child: Text('Deseja excluir a nota ou editá-la?')),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('Editar'),
                    textColor: Colors.amberAccent[700],
                    onPressed: () {
                      Navigator.of(context).pop();
                      return editarNota(context, documento);
                    },
                  ),
                  FlatButton(
                    child: Text('Excluir'),
                    textColor: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                      return deletarNota(context, querySnap, documento);
                    },
                  ),
                ]
              )
            ]
          );
        }
    );
  }

  Future<List<dynamic>> getDiaryPages() async {

    var firestore = Firestore.instance;

    await setUserId();

    String _diaEMesDaPaginaAnterior;
    String _horarioDaPaginaAnterior;

    var querySnap = await firestore
        .collection(_userId).orderBy('dataDeCriacao', descending: true).getDocuments();

    List<Widget> _lista = new List();
    querySnap.documents.forEach((DocumentSnapshot documento){
      String _diaEMesString = _diaEMes(_extraiData(documento));
      Row _diaEMesRow = _linhaComData(_diaEMesString);

      String _horarioString = _horario(_extraiData(documento));
      Row _horarioRow = _linhaComHorario(_horarioString);

      if(_diaEMesDaPaginaAnterior != _diaEMesString){
        _lista.add(_diaEMesRow);
        _lista.add(_horarioRow);

      } else if(_horarioDaPaginaAnterior != _horarioString){
        _lista.add(_horarioRow);
      }

      DiaryPage _pagina = _diaryPage(documento, querySnap);
      _lista.add(_pagina);

      _diaEMesDaPaginaAnterior = _diaEMesString;
      _horarioDaPaginaAnterior = _horarioString;
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
      aoSegurar: () {
        return editarOuDeletarNota(context, snapshot, documento);
      }
    );

    return _pagina;
  }

  Row _linhaComData(String data){
    Text _texto = Text(
      ' ' + data + ' ',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xffc89d62),
      ),
    );

    Expanded _linha = Expanded(
      child: Divider(),
    );

    return Row(
      children: <Widget>[
        _linha,
        _texto,
        _linha,
      ],
    );
  }

  Row _linhaComHorario(String horario){
    Text _texto = Text(
      horario,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xffe2a86b),
      ),
    );

    return Row(
      children: [
        _texto,
      ],
    );
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

  String _horario(DateTime data){
    if(data == null) return null;
    return data.hour.toString() + 'h';
  }

  String _minutos(DateTime data){
    if(data == null) return null;
    return data.minute.toString() + 'min';
  }

  String _horasEMinutos(DateTime data){
    if(data == null) return null;
    return _horario(data) + _minutos(data);
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
