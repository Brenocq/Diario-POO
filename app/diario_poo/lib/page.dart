import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage(
      {@required this.title, @required this.description, @required this.day})
      : assert(title != null);
  final String title;
  final String description;
  final String day;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              //leading: Icon(Icons.album),
              title: Text(title),
              subtitle: Text(description),
            ),
          ],
        ),
      ),
    );
  }
}
