import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase_auth/camera_view.dart';
import "dart:math";
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:camera/camera.dart';

class ChatViewPage extends StatefulWidget {
  ChatViewPage({Key key, this.title, this.currentUid, this.targetUid}) : super(key: key);

  final String title;
  var currentUid;
  var targetUid;

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatViewPage> {
  final DatabaseReference ref = FirebaseDatabase.instance.reference();

  var currentUser = "Unknown";
  
  var msgController = TextEditingController();
  var chatHistoryList = [];

  @override
  void initState() {
    super.initState();
    print("chat between " + widget.currentUid + " and " + widget.targetUid);
    _loadChatMessage();

    ref.child("messages/" + _getChatUids()).onChildAdded.listen((e){
      print("messages are added.");
      _loadChatMessage();
    });
  }

  String _getChatUids() {
    return widget.currentUid.compareTo(widget.targetUid) > 0 ?
        widget.targetUid + "-" + widget.currentUid : widget.currentUid+ "-" + widget.targetUid;
  }

  void _loadChatMessage() {
    ref.child("messages/" + _getChatUids()).once().then((ds){
      var tempList = [];
      ds.value.forEach((k,v){
        print(v);
        tempList.add(v);
      });
      tempList.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      chatHistoryList.clear();
      setState(() {
        chatHistoryList = tempList;
      });
    }).catchError((e){

    });
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat("MM-dd-yyyy HH:mm").format(now);
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
                    itemCount: chatHistoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 5),
                        alignment: widget.currentUid == chatHistoryList[index]['sender'] ? Alignment.centerRight: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: widget.currentUid == chatHistoryList[index]['sender'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    color: Colors.grey,
                                    child:
                                    chatHistoryList[index]['msg'].startsWith('https') ?
                                    Image.network(chatHistoryList[index]['msg']) :
                                    Text('${chatHistoryList[index]['msg']}')
                                )
                            ),
                            Text(
                              '${readTimestamp(chatHistoryList[index]['timestamp'])}',
                              style: TextStyle(fontSize: 10.0),
                            ),
                          ],
                        )
                      );
                    }
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Message',
                      ),
                    ),
                  ),
                  FlatButton(
                    child: Text("Send"),
                    onPressed: () {
                      var timestamp = new DateTime.now().millisecondsSinceEpoch;

                      ref.child("messages/" + _getChatUids() + "/" + timestamp.toString()).set({
                        "msg" : msgController.text.toString(),
                        "sender" : widget.currentUid,
                        "timestamp" : timestamp
                      }).then((res){
                        print("Send a message successfully!");
                      }).catchError((e){
                        print("Failed to send!");
                      });
                    },
                  ),
                  FlatButton(
                    child: Text("Photo"),
                    onPressed: () {
                      print("photo");
                      WidgetsFlutterBinding.ensureInitialized();

                      // Obtain a list of the available cameras on the device.
                      availableCameras().then((cameras) async {
                        // Get a specific camera from the list of available cameras.
                        final firstCamera = cameras.first;
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TakePictureScreen(camera: firstCamera)),
                        );
                        print("Result URL: " + result);
                        var timestamp = new DateTime.now().millisecondsSinceEpoch;
                        ref.child("messages/" + _getChatUids() + "/" + timestamp.toString()).set({
                          "msg" : result,
                          "type" : "image",
                          "sender" : widget.currentUid,
                          "timestamp" : timestamp
                        }).then((res){
                          print("Send a message successfully!");
                        }).catchError((e){
                          print("Failed to send!");
                        });

                      });



                    },
                  )
                ],
              )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
