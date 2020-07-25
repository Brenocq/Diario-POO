//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage(
      {@required this.descricaoCurta,
      @required this.descricaoLonga,
      @required this.emoji,
      @required this.dataDeCriacao,
      @required this.idDaPagina,
      @required this.idDoUsuario,
      @required this.olhar,
      @required this.aoSegurar})
      : assert(descricaoCurta != null);

  final String descricaoCurta;
  final String descricaoLonga;
  final String emoji;
  final Timestamp dataDeCriacao;
  final String idDaPagina;
  final String idDoUsuario;

  final Function olhar;
  final Function aoSegurar;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xfffff0d3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Informacoes(
              descricaoCurta: descricaoCurta,
              descricaoLonga: descricaoLonga,
              emoji: emoji,
              olhar: olhar,
              aoSegurar: aoSegurar,
            ),
          ],
        ),
      ),
    );
  }
}

class _Informacoes extends StatelessWidget {
  _Informacoes(
      {@required this.descricaoCurta,
      @required this.descricaoLonga,
      @required this.emoji,
      @required this.olhar,
      @required this.aoSegurar})
      : assert(descricaoCurta != null);

  final String descricaoCurta;
  final String descricaoLonga;
  final String emoji;

  final Function olhar;
  final Function aoSegurar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: emoji != null && emoji.isEmpty
                ? null
                : Text(
                    emoji != null ? emoji : "",
                    style: TextStyle(fontSize: 40),
                  ),
            title: Text(descricaoCurta),
            subtitle: Text(
              descricaoLonga,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: olhar,
            onLongPress: aoSegurar,
          )
        ],
      ),
    );
  }
}
