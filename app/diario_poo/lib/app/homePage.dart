import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'page.dart';

class HomePage extends StatelessWidget {
  HomePage({@required this.auth});
  final AuthBase auth;

  Future<void> _signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          DiaryPage(
            title: "Dia incrível!",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ",
            day: "Hoje",
          ),
          DiaryPage(
            title: "Ana finalmente falou comigo",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ",
            day: "Hoje",
          ),
          DiaryPage(
            title: "Amanha tem prova! Socorro",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ",
            day: "Hoje",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Escrever',
        child: Icon(Icons.add),
      ),
    );
  }
}
