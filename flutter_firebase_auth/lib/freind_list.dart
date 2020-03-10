import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "dart:math";

import 'package:flutter_firebase_auth/chat_view.dart';

class FriendListPage extends StatefulWidget {
  FriendListPage({Key key, this.title, this.currentUid}) : super(key: key);

  final String title;
  var currentUid;

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendListPage> {
  var usersList = [];

  final DatabaseReference ref = FirebaseDatabase.instance.reference();

  _FriendListState() {
    ref.child("users").once().then((ds) {
      ds.value.forEach((k, v) {
        print(v['name']);
        setState(() {
          print(k);
          usersList.add({"name": v['name'], "uid": k});
        });
      });
    }).catchError((e) {
      print("Failed to load all the users.");
    });
  }

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
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: usersList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () {
                          print(usersList[index]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatViewPage(title: "Chat", currentUid: widget.currentUid, targetUid: usersList[index]['uid'],)),
                          );
                        },
                        title: Container(
                          height: 50,
                          child: Row(
                            children: <Widget>[
                              Image.network(
                                  "https://img.icons8.com/bubbles/2x/user.png"),
                              Text('${usersList[index]['name']}'),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
