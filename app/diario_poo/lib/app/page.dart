//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diariopoo/services/Crud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage(
      {@required this.descricaoCurta, @required this.descricaoLonga, @required this.emoji, @required this.dataDeCriacao,
        @required this.idDaPagina, @required this.idDoUsuario, @required this.olhar, @required this.deletar, @required this.editar})
      : assert(descricaoCurta != null);

  final String descricaoCurta;
  final String descricaoLonga;
  final String emoji;
  final Timestamp dataDeCriacao;
  final String idDaPagina;
  final String idDoUsuario;

  final Function olhar;
  final Function deletar;
  final Function editar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Informacoes(descricaoCurta: descricaoCurta, descricaoLonga: descricaoLonga, emoji: emoji, olhar: olhar, editar: editar,),
            _Butoes(idDoUsuario: idDoUsuario, idDaPagina: idDaPagina, deletar: deletar),
          ],
        ),
      ),
    );
  }
}

class _Informacoes extends StatelessWidget{
  _Informacoes(
      {@required this.descricaoCurta, @required this.descricaoLonga, @required this.emoji, @required this.olhar,
        @required this.editar})
      : assert(descricaoCurta != null);

  final String descricaoCurta;
  final String descricaoLonga;
  final String emoji;

  final Function olhar;
  final Function editar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: emoji.isNotEmpty ? Text(
              emoji,
              style: TextStyle(fontSize: 40),
            ) : null,
            title: Text(descricaoCurta),
            subtitle: Text(
              descricaoLonga,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: olhar,
            onLongPress: editar,
          )
        ],
      ),
    );
  }
}

class _Butoes extends StatelessWidget{
  _Butoes(
  {@required this.idDoUsuario, @required this.idDaPagina, this.deletar}
      );

  final String idDoUsuario;
  final String idDaPagina;

  final Function deletar;

  @override
  Widget build(BuildContext context) {

    Color corDosIcones = Colors.pinkAccent;

    return Row(
      children: <Widget>[
        IconButton(
          onPressed: deletar,
          icon: Icon(
            Icons.delete,
            color: corDosIcones,
          ),

        )
      ]
    );
  }
}