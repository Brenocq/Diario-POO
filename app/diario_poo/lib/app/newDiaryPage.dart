import 'package:diariopoo/services/Crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class NewDiaryPage extends StatefulWidget {
  NewDiaryPage(this.descricaoCurta, this.descricaoLonga, this.emoji, this.docId);

  final String descricaoCurta;
  final String descricaoLonga;
  final String emoji;
  final String docId;

  @override
  _NewDiaryPageState createState() => _NewDiaryPageState(descricaoCurta, descricaoLonga, emoji, docId);
}

class _NewDiaryPageState extends State<NewDiaryPage> {
  _NewDiaryPageState(this.descricaoCurta, this.descricaoLonga, this.emoji, this.docId);

  final String descricaoCurta;
  final String descricaoLonga;
  final String emoji;
  final String docId;


  final descricaoCurtaController = TextEditingController();
  final descricaoLongaController = TextEditingController();
  final emojiController = TextEditingController();

  @override
  void dispose() {
    descricaoCurtaController.dispose();
    descricaoLongaController.dispose();
    emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    descricaoCurtaController.text = descricaoCurta;
    descricaoLongaController.text = descricaoLonga;
    emojiController.text = emoji;

    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar página'),
        elevation: 2.0,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              children: <Widget>[
                Text(
                  "Seu dia em 5 palavras!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: descricaoCurtaController,
                  decoration: InputDecoration(hintText: 'Uma sensação? Um lugar?'),
                  maxLength: 30,
                ),
                SizedBox(height: 10),
                Text(
                  "Descricao",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: descricaoLongaController,
                  decoration: InputDecoration(hintText: 'O que aconteceu hoje?'),
                  maxLength: 256,
                  maxLines: null,
                ),
                TextField(
                  controller: emojiController,
                  decoration: InputDecoration(hintText: 'Manda um emoji aí'),
                  maxLength: 1,
                ),
                SizedBox(height: 10),
                RaisedButton(
                  onPressed: () {
                    _sendPageToFirebase(context, descricaoCurtaController.text, descricaoLongaController.text,
                        emojiController.text, docId);
                  },
                  child: Text("Salvar"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendPageToFirebase(BuildContext context, String descricaoCurta, String descricaoLonga,
      String emoji, String docId) async {

    print('descricaoCurta:${descricaoCurta}\ndescricaoLonga:${descricaoLonga}\nemoji:${emoji}');

    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final userId = user.uid;

    if (descricaoCurta.isNotEmpty && descricaoLonga.isNotEmpty && (isEmoji(emoji) || emoji.isEmpty)) {
      if(docId != null) {
        Firestore.instance.collection(userId).document(docId).updateData({
          'descricaoCurta': descricaoCurta,
          'descricaoLonga': descricaoLonga,
          'emoji': emoji.isNotEmpty ? emoji : '',
        }).then((result) => {
          Navigator.pop(context),
        }).catchError((err) =>  {print("[ERROR]: $err")});
      }
      else {
        Firestore.instance
            .collection(userId)
            .add({
          'descricaoCurta': descricaoCurta,
          'descricaoLonga': descricaoLonga,
          'emoji': emoji.isNotEmpty ? emoji : '',
          'dataDeCriacao': DateTime.now(),
        })
            .then((result) =>
        {
          Navigator.pop(context),
        })
            .catchError((err) => {print("[ERROR]: $err")});
      }
    } else {
      // TODO: implementar uma tela que diz qual campo deveria mudar
      print("These fields should not be empty");
    }
  }

  bool isEmoji(String text){
    if(text.isEmpty) return false;

    final runes = text.runes;
    bool isTextEmoji = true;

    for (int i = 0; i < runes.length; i++) {
      int current = runes.elementAt(i);
      final isEmoji = current > 255;
      isTextEmoji = isTextEmoji && isEmoji;
    }

    return isTextEmoji;
  }

}



class EmojiText extends StatelessWidget {

  const EmojiText({
    Key key,
    @required this.text,
  }) : assert(text != null),
        super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildText(this.text),
    );
  }

  TextSpan _buildText(String text) {
    final children = <TextSpan>[];
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */ ) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...

      final isEmoji = current > 255;
      final shouldBreak = isEmoji
          ? (x) => x <= 255
          : (x) => x > 255;

      final chunk = <int>[];
      while (! shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }

      children.add(
        TextSpan(
          text: String.fromCharCodes(chunk),
          style: TextStyle(
            fontFamily: isEmoji ? 'EmojiOne' : null,
          ),
        ),
      );
    }

    return TextSpan(children: children);
  }
}