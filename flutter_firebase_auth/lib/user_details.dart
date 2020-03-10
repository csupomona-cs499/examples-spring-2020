import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "dart:math";

class UserDetailsPage extends StatefulWidget {
  UserDetailsPage({Key key, this.title, this.student}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final Map student;

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

// https://cpp.zoom.us/j/3335103143

class _UserDetailsState extends State<UserDetailsPage> {

  final DatabaseReference ref = FirebaseDatabase.instance.reference();

  var currentUser = "Unknown";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                  Image.network(widget.student['image']),
                  Text('Name: ${widget.student['name']}'),
                  Text('Age: ${widget.student['age']}'),
                  Text('Major: ${widget.student['major']}'),
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
