import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "dart:math";

import 'package:flutter_firebase_auth/user_details.dart';

class MyNextPage extends StatefulWidget {
  MyNextPage({Key key, this.title, this.uid}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String uid;

  @override
  _MyNextPageState createState() => _MyNextPageState();
}

// https://cpp.zoom.us/j/3335103143

class _MyNextPageState extends State<MyNextPage> {
  final List userIcons = [
    "https://img.icons8.com/bubbles/2x/user.png",
    "https://img.icons8.com/plasticine/2x/user.png",
    "https://img.icons8.com/clouds/2x/user.png"
  ];

  final _random = new Random();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.reference();

  var nameEditController = TextEditingController();
  var ageEditController = TextEditingController();
  var majorEditController = TextEditingController();

  var currentUser = "Unknown";
  var studentList = [];

  _MyNextPageState() {
    print("started!");
    _auth.currentUser().then((user) {
      setState(() {
        currentUser = user.uid;
      });

      print(currentUser);

      ref.child(currentUser + "/students").onChildChanged.listen((event) {
        print("Some data has been changed!");
        _updateStudentList();
      });
      ref.child(currentUser + "/students").onChildAdded.listen((event) {
        print("Some data has been added!");
        _updateStudentList();
      });
      ref.child(currentUser + "/students").onChildRemoved.listen((event) {
        print("Some data has been removed!");
        _updateStudentList();
      });

    }).catchError((e) {
      print("Failed to get the current user!" + e.toString());
    });


  }

  void _updateStudentList() {
    ref.child(currentUser + "/students").once().then((ds) {
      print(ds.value);

      var tempList = [];
      ds.value.forEach((k, v) {
        tempList.add(v);
      });

      studentList.clear();
      setState(() {
        studentList = tempList;
      });
    }).catchError((e) {
      print("Failed to get the students. " + e.toString());
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
              Text(
                'Welcome ${currentUser}',
              ),
              TextField(
                controller: nameEditController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: ageEditController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Age',
                ),
              ),
              TextField(
                controller: majorEditController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Major',
                ),
              ),
              RaisedButton(
                child: Text("Add Student"),
                onPressed: () {
                  print(nameEditController.text.toString());
                  print(ageEditController.text.toString());
                  print(majorEditController.text.toString());

                  // write a data: key, value
                  ref.child(currentUser +
                          "/students/" +
                          new DateTime.now().millisecondsSinceEpoch.toString())
                      .set({
                    "name": nameEditController.text.toString(),
                    "age": ageEditController.text.toString(),
                    "major": majorEditController.text.toString(),
                    "image": userIcons[_random.nextInt(userIcons.length)]
                  }).then((res) {
                    print("Student is added ");
                  }).catchError((e) {
                    print("Failed to add the student. " + e.toString());
                  });
                },
              ),
              RaisedButton(
                child: Text("List Students"),
                onPressed: _updateStudentList,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: studentList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserDetailsPage(title : "User Details", student: studentList[index])),
                          );
                        },
                        title: Container(
                            height: 50,
                            child: Center(
                                child: Row(
                              children: <Widget>[
                                Image.network(studentList[index]['image']),
                                Text('Name: ${studentList[index]['name']}'),
                                Text('Age: ${studentList[index]['age']}'),
                                Text('Major: ${studentList[index]['major']}'),
                              ],
                            ))),
                      );
                    }),
              )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
