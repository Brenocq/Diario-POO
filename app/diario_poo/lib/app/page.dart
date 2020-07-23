import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage(
      {@required this.descricaoCurta, @required this.descricaoLonga, @required this.dataDeCriacao})
      : assert(descricaoCurta != null);
  final String descricaoCurta;
  final String descricaoLonga;
  final Timestamp dataDeCriacao;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            _Informacoes(descricaoCurta: descricaoCurta, descricaoLonga: descricaoLonga),
            _Butoes(),
          ],
        ),
      ),
    );
  }
}

class _Informacoes extends StatelessWidget{
  _Informacoes(
      {@required this.descricaoCurta, @required this.descricaoLonga})
      : assert(descricaoCurta != null);

  final String descricaoCurta;
  final String descricaoLonga;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              title: Text(descricaoCurta),
              subtitle: Text(descricaoLonga),
          )
        ],
      ),
    );
  }
}

class _Butoes extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Icon(Icons.edit);
  }
}