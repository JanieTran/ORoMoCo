import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oromoco/views/dashboard/dashboardScreen.dart';
import '../../helper/constants.dart';
import '../../services/database.dart';

import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;

class ChatScreen extends StatefulWidget {
  final String chatRoomID;

  ChatScreen(this.chatRoomID);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  StreamSubscription<HardwareButtons.HomeButtonEvent> _homeButtonSubscription;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageTextEditingController =
      new TextEditingController();
  Stream chatMessageStream;
  ScrollController _controller = new ScrollController();
  int messageLimit = 20;
  bool isShowSticker;
  bool isShowImage;
  String _path = null;
  final _picker = ImagePicker();

  Widget chatMessageList() {
    return Flexible(
      child: StreamBuilder(
          stream: chatMessageStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data.documents.length,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      String time = DateFormat("dd/MM - kk:mm").format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]).toLocal()).toString();
                      bool isFirst;
                      bool showTimeHeader;

                      try{
                        if(snapshot.data.documents[index].data["time"] - snapshot.data.documents[index + 1].data["time"] > 900000){
                          // time = DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]).toLocal().toString();
                          showTimeHeader = true;
                        } else{
                          showTimeHeader = false;
                        }
                      } catch (e){
                        // time = snapshot.data.documents.length < 20 ? DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]).toLocal().toString() : '';
                        showTimeHeader = snapshot.data.documents.length < 20 ? true : false;
                      }

                      try{
                        isFirst = snapshot.data.documents[index].data["sendBy"] != snapshot.data.documents[index + 1].data["sendBy"];
                        // String message = snapshot.data.documents[index].data["message"];
                        // print("isFirst: $isFirst, index: $index, message: $message");
                      } catch (e){
                        isFirst = snapshot.data.documents.length < 20;
                      }

                      String message;
                      bool isImage;

                      if(snapshot.data.documents[index].data["message"].contains("image64")){
                        message = snapshot.data.documents[index].data["message"].replaceAll("{image64:", "").replaceAll(" ", "").replaceAll("}", "");
                        isImage = true;
                        showTimeHeader = true;
                      } else{
                        message = snapshot.data.documents[index].data["message"];
                        isImage = false;
                      }

                      // print(utf8.encode(message).length);

                      return MessageTile(
                          message,
                          snapshot.data.documents[index].data["sendBy"] ==
                              Constants.email,
                          time,
                          isFirst,
                          showTimeHeader,
                          isImage: isImage,
                      );
                    })
                : Container();
          }),
    );
  }

  void _showPhotoLibrary() async {
    final file = await _picker.getImage(source: ImageSource.gallery);
    if(file == null){
      setState(() {
        isShowImage = false;
      });
    } else{
      setState(() {
        isShowImage = false;
        _path = file.path;
        getNewImageBase64();
      });
    }
  }

  void getNewImageBase64() async {
    // final newCapturedImage = await File(_path).readAsBytesSync();
    img.Image image_temp = await img.decodeImage(File(_path).readAsBytesSync());
    img.Image resized_img = img.copyResize(image_temp,  width: (image_temp.width*0.1).round());
    
    Map<String, dynamic> imageStorage = {
      "image64": base64Encode(img.encodeJpg(resized_img)).toString(),
    };

    String sendTo = "";
    if (Constants.email.contains(Constants.adminAlias)) {
      sendTo = widget.chatRoomID
          .replaceAll(Constants.adminAlias, "")
          .replaceAll("-", "");
    } else {
      sendTo = Constants.adminAlias;
    }

    Map<String, dynamic> messageMap = {
      "message": imageStorage.toString(),
      "sendBy": Constants.email,
      "sendTo": sendTo,
      "time": DateTime.now().millisecondsSinceEpoch
    };

    databaseMethods.addConversationMessage(widget.chatRoomID, messageMap);
    messageTextEditingController.text = "";
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 2,
      columns: 10,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["happy"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        setState(() {
          messageTextEditingController.text = messageTextEditingController.text + emoji.emoji;
          messageTextEditingController.selection = TextSelection.fromPosition(TextPosition(offset: messageTextEditingController.text.length));
        });
      },
    );
  }

  Widget chatMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end, 
          children: [
            GestureDetector(
              onTap: (){
                setState(() {
                  isShowImage = !isShowImage;
                  if(isShowImage){
                    _showPhotoLibrary(); 
                  }
                });
              },
              child: Container(
                margin: new EdgeInsets.symmetric(horizontal: 1.0),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 1,
                  bottom: 10,
                  top: 10
                ),
                child: Icon(
                  Icons.image,
                  color: isShowImage ? Colors.amber :  Colors.grey
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  isShowSticker = !isShowSticker;
                });
              },
              child: Container(
                margin: new EdgeInsets.symmetric(horizontal: 1.0),
                padding: EdgeInsets.only(
                  left: 1,
                  right: 10,
                  bottom: 10,
                  top: 10
                ),
                child: Icon(
                  Icons.tag_faces,
                  color: isShowSticker ? Colors.amber :  Colors.grey
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF707070), width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: messageTextEditingController,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.normal, color: Colors.black),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(color: Color(0xFF707070)),
                  ),
                  maxLines: 5,
                  minLines: 1,
                ),
              )
            ),
            SizedBox(width: 10),
            Container(
              padding: EdgeInsets.only(
                bottom: 2
              ),
              child: ButtonTheme(
                minWidth: 40,
                height: 40,
                child: RaisedButton(
                  padding: EdgeInsets.all(0),
                  color: Color(0xFFD8D8D8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  elevation: 2,
                  onPressed: () {
                    sendMessage();
                  },
                  child: Icon(
                    Icons.send, 
                    color: Color(0xFF707070)
                  )
                ),
              ),
            ),
            SizedBox(width: 10)
          ]
        ),
      ),
    );
  }

  sendMessage() {
    String sendTo = "";
    if (Constants.email.contains(Constants.adminAlias)) {
      sendTo = widget.chatRoomID
          .replaceAll(Constants.adminAlias, "")
          .replaceAll("-", "");
    } else {
      sendTo = Constants.adminAlias;
    }
    if (messageTextEditingController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTextEditingController.text,
        "sendBy": Constants.email,
        "sendTo": sendTo,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addConversationMessage(widget.chatRoomID, messageMap);
      messageTextEditingController.text = "";
    }
  }

  @override
  void initState() {
    super.initState();
    _homeButtonSubscription = HardwareButtons.homeButtonEvents.listen((event){
      databaseMethods.updateUserChattingWith(null);
    });

    if (!Constants.email.contains("@wearevulcan.com")) {
      String chatRoomID = widget.chatRoomID;
      List<String> users = [Constants.email, "@wearevulcan.com"];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomID": chatRoomID
      };

      databaseMethods.createChatRoom(chatRoomID, chatRoomMap);
    }

    databaseMethods
        .getConversationMessages(widget.chatRoomID, messageLimit)
        .then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });

    String sendTo = "";
    if (Constants.email.contains(Constants.adminAlias)) {
      sendTo = widget.chatRoomID
          .replaceAll(Constants.adminAlias, "")
          .replaceAll("-", "");
    } else {
      sendTo = Constants.adminAlias;
    }

    databaseMethods.updateUserChattingWith(sendTo);

    _controller.addListener(() {
      if(_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange){
        messageLimit += 20;
        databaseMethods.getConversationMessages(widget.chatRoomID, messageLimit).then((value) {
          setState(() {
            chatMessageStream = value;
          });
        });
      }
    });
    isShowSticker = false;
    isShowImage = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    databaseMethods.updateUserChattingWith(null);
    _homeButtonSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        databaseMethods.updateUserChattingWith(null);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DashboardScreen(Constants.bottomBar["chat"], 0, 0)));
          return false;
      },
      child: SafeArea(
        child: Scaffold(
            body: Container(
                color: Colors.white,
                child: Stack(children: [
                  Column(
                    children: <Widget>[
                      chatMessageList(), 
                      (isShowSticker ? buildSticker() : Container()),
                      chatMessageInput()
                    ],
                  )
                ]
              )
            )
          ),
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final String message;
  final bool isSentBySelf;
  final String time;
  final bool isFirst;
  final bool showTimeHeader;
  final bool isImage;
  MessageTile(this.message, this.isSentBySelf, this.time, this.isFirst, this.showTimeHeader, {this.isImage});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool toggleTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      toggleTime = widget.showTimeHeader;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.isImage ? null : EdgeInsets.only(
          left: widget.isSentBySelf ? 0 : 24, right: widget.isSentBySelf ? 24 : 0),
      margin: widget.isFirst ? EdgeInsets.only(top: 20) : EdgeInsets.symmetric(vertical: 1),
      width: MediaQuery.of(context).size.width,
      alignment: widget.isSentBySelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: !widget.isSentBySelf ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: !widget.isSentBySelf ? CrossAxisAlignment.start: CrossAxisAlignment.end,
        children: [
          toggleTime ? Container(
            padding: EdgeInsets.only(
              left: widget.isSentBySelf ? 24 : 0, right: widget.isSentBySelf ? 0 : 24, top: 10, bottom: 10),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Text(
              // widget.time.substring(0, widget.time.length - 7)
              widget.time,
              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 12, color: Color(0xFF707070)),
            ),
          ) : Container(),
          ButtonTheme(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(0),
            buttonColor: Colors.grey,
            child: RaisedButton(
              elevation: 0,
              highlightElevation: 1,
              color: widget.isImage ? Colors.white : widget.isSentBySelf
                        ? Theme.of(context).primaryColor
                        : Color(0xFFF5F5F5),
              padding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: widget.isSentBySelf
                  ? BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: widget.showTimeHeader || widget.isFirst ? Radius.circular(23) : Radius.circular(5),
                        bottomLeft: Radius.circular(23),
                        bottomRight: Radius.circular(5)
                ) : BorderRadius.only(
                        topLeft: widget.showTimeHeader || widget.isFirst ? Radius.circular(23) : Radius.circular(5),
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23),
                        bottomLeft: Radius.circular(5)
                )
              ),
              onLongPress: (){
                // setState(() {
                //   toggleTime = widget.showTimeHeader ? true : !toggleTime;
                // });
                if(widget.isImage){
                  return;
                }
                Clipboard.setData(new ClipboardData(text: widget.message));
                Fluttertoast.showToast(msg: "Copied to clipboard");
              },
              onPressed: (){
                if(widget.isImage){
                  return;
                }
                setState(() {
                  toggleTime = widget.showTimeHeader ? true : !toggleTime;
                });
              },
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                    // border: widget.isSentBySelf
                    //     ? Border()
                    //     : Border.all(
                    //         color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.0),
                    // color: widget.isSentBySelf
                    //     ? Theme.of(context).primaryColor
                    //     : Color(0xFFF5F5F5),
                    borderRadius: widget.isSentBySelf
                      ? BorderRadius.only(
                            topLeft: Radius.circular(23),
                            topRight: widget.showTimeHeader || widget.isFirst ? Radius.circular(23) : Radius.circular(5),
                            bottomLeft: Radius.circular(23),
                            bottomRight: Radius.circular(5)
                    ) : BorderRadius.only(
                            topLeft: widget.showTimeHeader || widget.isFirst ? Radius.circular(23) : Radius.circular(5),
                            topRight: Radius.circular(23),
                            bottomRight: Radius.circular(23),
                            bottomLeft: Radius.circular(5)
                    )
                ),
                child: widget.isImage ? ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Image.memory(
                    base64Decode(widget.message),
                    scale: 0.2
                  ),
                ) : Text(
                  widget.message,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: widget.isSentBySelf
                          ? Colors.white
                          : Colors.black,
                      fontSize: 15
                  )
                )
              ),
            ),
          ),
        ]
      )
    );
  }
}