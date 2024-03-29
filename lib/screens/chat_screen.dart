import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;

class ChatScreen extends StatefulWidget {

  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseUser loggedInUser;
  final messageTextController = TextEditingController();

  final _auth=FirebaseAuth.instance;

  String messageText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser()async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch (e) {
      print(e);
    }
  }

//    void getMessages()async{
//    final messages=await _firestore.collection('messages').getDocuments();
//    for(var message in messages.documents){
//      print(message.data);
//    }
//  }

  void messageStream()async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('messages').snapshots(),
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return Center(
                  child: Text('wait')
                  //CircularProgressIndicator();
                );
              }

                  final messages = snapshot.data.documents.reversed;
                  List<MessageBubble> messageBubbles=[];
                  for (var message in messages)
                    {
                      final messageText = message.data['text'];
                      final messageSender = message.data['sender'];
                      final currentUser =loggedInUser.email;

                      final messageBubble = MessageBubble(
                        sender: messageSender,
                        text: messageText,
                        isMe: currentUser==messageSender   ,
                      );

                      messageBubbles.add(messageBubble);

                    }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                      children:messageBubbles,
                    ),
                  );


            },
        ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

MessageBubble({this.sender,this.text,this.isMe});
  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
         Text(sender,style: TextStyle(
           fontSize: 12.0,
           color:Colors.grey
         ),),
          Material(
            borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0))
            : BorderRadius.only(topLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal:15.0),
              child: Text(text,
              style: TextStyle(
                color: isMe ? Colors.white :Colors.black,
                fontSize: 15.0,
              ),),
            ),
          ),
        ],
      ),
    );
  }
}
