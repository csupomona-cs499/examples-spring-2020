import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "dart:math";

class UserDetailsPage extends StatefulWidget {
  UserDetailsPage({Key key, this.title, this.student}) : super(key: key);

  final String title;
  final Map student;

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

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
