import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:oromoco/bluetooth/utils/utils.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  int currentCommand = -1;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  Widget _horizontalButtonList(List<DefaultCommand> _defaultCommand) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 26,
        right: 26,
        top: 10
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              children: <Widget>[
                Text(
                  "Câu lệnh chuẩn",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Color(0xFF707070), fontWeight: FontWeight.normal
                  )
                )
              ],
            ),
          ),
          Stack(
            children: <Widget>[
              Container(
                height: 50,
                child: _defaultCommand.length != 0
                  ? ListView.builder(
                      itemCount: _defaultCommand.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) => Container(
                        width: 200,
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: ButtonTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          buttonColor: Color(0xFFF0F0F0),
                          child: RaisedButton(
                            child: Text(
                              _defaultCommand[i].function,
                              style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.normal
                              ),
                            ),
                            onPressed: (){
                              _sendMessage(_defaultCommand[i].command, defaultCommand: true);
                              // if(currentCommand == i){
                              //   setState(() {
                              //     currentCommand = -1;
                              //   });
                              // } else{
                              //   setState(() {
                              //     currentCommand = i;
                              //   });
                              // }
                              setState(() {
                                currentCommand = i;
                              });
                            },
                          ),
                        ),
                      ),
                    )
                  : Container(),
              ),
              _defaultCommand.length > 1 ? Positioned(
                right: 0,
                child: Container(
                  width: 30,
                  height: 316,
                  child: Icon(
                    Icons.arrow_right,
                    color: Colors.black.withOpacity(0.4),
                    size: 40
                  ),
                ),
              ) : Container()
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Kết nối với ' + widget.server.name + '...',
                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white))
              : isConnected
                  ? Text('Gỡ lỗi ' + widget.server.name,
                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white))
                  : Text('Lịch sử tương tác với ' + widget.server.name,
                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)))),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                children: list
              ),
            ),
            _horizontalButtonList(BluetoothDefaultCommand.defaultCommandList),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: isConnecting
                            ? 'Đợi kết nối...'
                            : isConnected
                                ? 'Gửi tin nhắn...'
                                : 'Trò chuyện bị hoãn',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: isConnected
                          ? () => _sendMessage(textEditingController.text)
                          : null),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        
        // String data = backspacesCounter > 0
        //         ? _messageBuffer.substring(
        //             0, _messageBuffer.length - backspacesCounter)
        //         : _messageBuffer + dataString.substring(0, index);

        // for(int i = 0; i < data.length; i++){
        //   print(int.parse(data[i]));
        // }

        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    Future.delayed(Duration(milliseconds: 100)).then((_) {
      listScrollController.animateTo(
          listScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut);
    });
  }

  void _sendMessage(String text, {bool defaultCommand = false}) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        if(!defaultCommand){
          setState(() {
            messages.add(_Message(clientID, text));
          });
        }

        Future.delayed(Duration(milliseconds: 100)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 100),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
