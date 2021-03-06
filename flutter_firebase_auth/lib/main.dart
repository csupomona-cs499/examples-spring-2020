import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/home.dart';
import 'package:firebase_database/firebase_database.dart';

import 'freind_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'CPP CS4990'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.reference();

  var emailEditingController = TextEditingController();
  var nameEditingController = TextEditingController();
  var passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Logo',
            ),
            TextField(
              controller: emailEditingController,
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: nameEditingController,
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: passwordEditingController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            FlatButton(
              child: Text("Login"),
              onPressed: () {
                print("login");
                _auth.signInWithEmailAndPassword(
                    email: emailEditingController.text.toString(),
                    password: passwordEditingController.text.toString())
                    .then((value) {
                      print("Successfully login! " + value.user.uid);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FriendListPage(title : "Friend List", currentUid: value.user.uid)),
                      );
                }).catchError((e) {
                  print("Failed to login! " + e.toString());
                });
              },
            ),
            FlatButton(
              child: Text("Sign Up"),
              onPressed: () {
                print(emailEditingController.text.toString());
                print(nameEditingController.text.toString());
                print(passwordEditingController.text.toString());

                _auth.createUserWithEmailAndPassword(
                    email: emailEditingController.text.toString(),
                    password: passwordEditingController.text.toString())
                  .then((value) {

                    print("Successfully signed up! " + value.user.uid);
                    ref.child("users/" + value.user.uid).set({
                      "name" : nameEditingController.text.toString()
                    }).then((res){
                      print("Successfully created a user in the database.");
                    }).catchError((e) {
                      print("Failed to create a user in the database.");
                    });

                  }).catchError((e) {
                    print("Failed to sign up! " + e.toString());
                  });

              },
            ),
          ],
        ),
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
