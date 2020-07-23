//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diariopoo/services/Crud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage(
      {@required this.descricaoCurta, @required this.descricaoLonga, @required this.dataDeCriacao, @required this.idDaPagina,
      @required this.idDoUsuario, this.olhar, this.deletar})
      : assert(descricaoCurta != null);

  final String descricaoCurta;
  final String descricaoLonga;
  final Timestamp dataDeCriacao;
  final String idDaPagina;
  final String idDoUsuario;
  final Function olhar;
  final Function deletar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            _Informacoes(descricaoCurta: descricaoCurta, descricaoLonga: descricaoLonga, olhar: olhar),
            _Butoes(idDoUsuario: idDoUsuario, idDaPagina: idDaPagina, deletar: deletar),
          ],
        ),
      ),
    );
  }
}

class _Informacoes extends StatelessWidget{
  _Informacoes(
      {@required this.descricaoCurta, @required this.descricaoLonga, this.olhar})
      : assert(descricaoCurta != null);

  final String descricaoCurta;
  final String descricaoLonga;
  final Function olhar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(descricaoCurta),
            subtitle: Text(descricaoLonga),
            onTap: olhar,
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

    void edita(){
      print('Edita');
    }

    return Row(
      children: <Widget>[
        IconButton(
          onPressed: edita,
          icon: Icon(
            Icons.edit,
            color: corDosIcones,
          ),
        ),
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