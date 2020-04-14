import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "dart:math";
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


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

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
    
    // READ
//    SharedPreferences.getInstance().then((prefs) {
//      var totalUsers = prefs.getInt("user_total");
//      print("Decode from the int : " + totalUsers.toString());
//      var usersListStr = prefs.getString("users_list");
//      usersList = jsonDecode(usersListStr);
//      print("Decode from the JSON string : " + usersList.toString());
//    });

//    // try to load the list from the local storage first
//    SharedPreferences.getInstance().then((prefs) {
//      var friendListStr = prefs.getString("friend_list");
//      if (friendListStr != null) {
//        setState(() {
//          usersList = jsonDecode(friendListStr);
//        });
//      }
//    });
//
//    // fetch the updated data from the server
//    http.get("http://63d93d26.ngrok.io/friends").then((response){
//      print(response.statusCode);
//      setState(() {
//        usersList = jsonDecode(response.body);
//      });
//
//      SharedPreferences.getInstance().then((prefs){
//        print("Persisting the friend list locally " + usersList.toString());
//        prefs.setString("friend_list", jsonEncode(usersList));
//      });
//    });


  }

  void _refreshList() {
    ref.child("users").once().then((ds) {
      usersList.clear();
      ds.value.forEach((k, v) {
        print(v['name']);
        setState(() {
          print(k);
          usersList.add({"name": v['name'], "uid": k});
        });
        print(usersList.length);

        // WRITE
//        SharedPreferences.getInstance().then((prefs) {
//          prefs.setInt("user_total", usersList.length);
//          // save the usersList as a JSON string
//          var usersListStr = jsonEncode(usersList);
//          prefs.setString("users_list", usersListStr);
//        });

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
              FlatButton(
                child: Text("Refresh"),
                onPressed: () {
                  _refreshList();
                },
              ),
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
