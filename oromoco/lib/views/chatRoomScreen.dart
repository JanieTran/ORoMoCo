import 'package:flutter/material.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/services/auth.dart';
import 'package:oromoco/services/database.dart';
import 'package:oromoco/views/chatScreen.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethod authMethod = new AuthMethod();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  Stream chatRoomStream;

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    String chatRoomID =
                        snapshot.data.documents[index].data()['chatRoomID'];
                    String chattedPersonEmail =
                        Constants.email.contains(Constants.adminAlias)
                            ? chatRoomID
                                .toString()
                                .replaceAll("-", "")
                                .replaceAll(Constants.adminAlias, "")
                            : Constants.adminAlias;
                    return ChatRoomsTile(chatRoomID, chattedPersonEmail, "");
                  })
              : Container();
        });
  }

  @override
  void initState() {
    getUserInfo();
    databaseMethods.updateUserChattingWith(null);
    super.initState();
  }

  getUserInfo() async {
    databaseMethods.getChatRooms(Constants.adminAlias).then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: AppBar(
                    iconTheme: IconThemeData(color: Colors.black),
                    backgroundColor: Colors.white,
                    elevation: 5,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        Text(
                          "Tin nhắn",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Colors.black),
                        ),
                        // TkcPopupMenuButton(2)
                        SizedBox(width: 50)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // actions: [
          //   GestureDetector(
          //     onTap: (){
          //       HelperFunctions.resetUserLoggedInSharedPreferencs();
          //       authMethod.signOut();
          //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
          //     },
          //     child: Container(
          //       padding: EdgeInsets.symmetric(horizontal: 16),
          //       child: Icon(Icons.exit_to_app)
          //     )
          //   )
          // ],
        ),
        body: chatRoomList(),
      ),
    );
  }
}

class ChatRoomsTile extends StatefulWidget {
  final String userName;
  final String chatRoomID;
  final String latestMessage;
  ChatRoomsTile(this.chatRoomID, this.userName, this.latestMessage);

  @override
  _ChatRoomsTileState createState() => _ChatRoomsTileState();
}

class _ChatRoomsTileState extends State<ChatRoomsTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(widget.chatRoomID)));
      },
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(children: <Widget>[
            Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(50)),
                child: Icon(Icons.person_outline, color: Colors.white)),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.userName,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold)),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 120),
                child: Text(widget.latestMessage,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.normal)),
              )
            ])
          ])),
    );
  }
}
