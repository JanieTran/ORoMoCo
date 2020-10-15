import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:oromoco/bluetooth/utils/utils.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/hardware/hardwareDetailScreen.dart';
import 'package:oromoco/utils/theme/theme.dart';
import 'package:oromoco/widgets/components.dart';

class _Message {
  int whom;
  String text;
  int timestamp;

  _Message(this.whom, this.text, this.timestamp);
}
class PerHardware{
  final PerBattery perBattery;
  final String hadrwareID;
  final String bluetoothID;
  final String lastSyncDate;
  final String address;
  final bool bluetoothSupport;
  final String name;
  final String version;
  final String logDocumentID;
  BluetoothConnection connection;
  bool isConnected;
  String status = "Tắt";
  List<_Message> messages = [];
  static final clientID = 0;
  String _messageBuffer = '';

  PerHardware(
    {
      @required this.name, 
      @required this.perBattery,
      @required this.hadrwareID,
      @required this.bluetoothID,
      @required this.lastSyncDate,
      @required this.address,
      @required this.bluetoothSupport,
      @required this.version,
      @required this.logDocumentID
    }
  );

  void onDataReceived(Uint8List data) {
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
      while(messages.length >= 5){
        messages.removeAt(0);
      }
      messages.add(
        _Message(
          1,
          backspacesCounter > 0
              ? _messageBuffer.substring(
                  0, _messageBuffer.length - backspacesCounter)
              : _messageBuffer + dataString.substring(0, index),
          DateTime.now().millisecondsSinceEpoch
        ),
      );
      _messageBuffer = dataString.substring(index);

    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void sendMessage(String text, {bool defaultCommand = false}) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        if(!defaultCommand){
          messages.add(_Message(clientID, text, DateTime.now().millisecondsSinceEpoch));
        }
        
      } catch (e) {
        // Ignore error, but notify state
      }
    }
  }

  // String messageBuffer(){
  //   if(messages.length > 0){
  //     // String value = messages[messages.length - 1].text.trim();
  //     // messages.removeAt(messages.length - 1);
  //     String value = messages.removeLast().text.trim();
  //     try{
  //       int.parse(value);
  //       return value;
  //     } catch(e){
  //       return messageBuffer();
  //     }
  //   }
  //   return "-1";
  // }

  PerPackage messageBuffer(){
    if(messages.length > 0){
      // String value = messages[messages.length - 1].text.trim();
      // messages.removeAt(messages.length - 1);
      _Message perMessage = messages.removeAt(0);
      String value = perMessage.text.trim();
      
      if(DateTime.now().millisecondsSinceEpoch - perMessage.timestamp < 100){
        try{
          // int.parse(value);
          // int.parse(value.split(',')[1]);
          PerPackage perPackage = new PerPackage();
          perPackage.setValue(value.split(','));
          return perPackage;
        } catch(e){
          return messageBuffer();
        }
      } else{
        return messageBuffer();
      }
    }
    return new PerPackage();
  }

  String getLastSyncDate(){
    return DateTime.now().toLocal().difference(DateTime.fromMillisecondsSinceEpoch(int.parse(lastSyncDate)).toLocal()).inDays.toString();
  }

  String getStatus(){
    return status;
  }

  bool isConnectedTo(){
    return connection != null && connection.isConnected;
  }

  void disconnect(){
    connection.dispose();
    connection = null;
  }

  bool isDisconnected(){
    return connection == null;
  }
}

class HardwareCardTile extends StatefulWidget {
  @required final PerHardware perHardware;
  bool homePage;
  String imagePath;

  HardwareCardTile(this.perHardware, {this.imagePath, this.homePage = false, Key key}):super(key: key);

  @override
  _HardwareCardTileState createState() => _HardwareCardTileState();
}

class _HardwareCardTileState extends State<HardwareCardTile> {
  DonutPieChart donutPieChart;
  final _keyBatteryChart = GlobalKey<DonutPieChartState>();
  Timer childInit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    donutPieChart = new DonutPieChart(key: _keyBatteryChart);
    childInit = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      try{
        if(_keyBatteryChart.currentState != null){
          _keyBatteryChart.currentState.setData(used: 100 - (double.parse(widget.perHardware.perBattery.percentage) * 100).round(), left: (double.parse(widget.perHardware.perBattery.percentage) * 100).round());
          childInit.cancel();
        } else{
          setState(() {});
        }
      } catch(e){
        childInit.cancel();
      }
    });

    if(widget.perHardware.hadrwareID.contains("HM")){
      widget.imagePath = "assets/images/layout/hand_module.png";
    } else if(widget.perHardware.hadrwareID.contains("S")){
      widget.imagePath = "assets/images/layout/sensor_box.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width < 400 ? 400 : MediaQuery.of(context).size.width,
      height: 296,
      margin: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      child: RaisedButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        padding: EdgeInsets.all(0),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HardwareDetailScreen(perHardware: widget.perHardware)));
          setState(() {});
        },
        child: Container(
          width: MediaQuery.of(context).size.width < 400 ? 400 : MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)
                      ),
                      // color: Color(0xFF1A9156)
                      color: AppColors.blue
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Thiết bị",
                                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.normal)
                              )
                            ),
                            Container(
                              child: Text(
                                widget.perHardware.name,
                                // perContract.getContractPaymentPerPeriod() + "đ",
                                style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white)
                              )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8, 
                    right: 18,
                    child: Container(
                      width: 85,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 85,
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 4
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.blue
                              ),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10)
                              ),
                              // color: Color(0xFFE15E5D)
                              color: Color(0xFF707070)
                            ),
                            child: Text(
                              "Ngày cần tải",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)
                            )
                          ),
                          Container(
                            width: 85,
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 15
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.blue
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)
                              ),
                              color: Colors.white
                            ),
                            child: Text(
                              widget.perHardware.getLastSyncDate(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070))
                            )
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Stack(
                children: [
                  Container(
                    height: 10,
                    color: Color(0xFF707070)
                  ),
                  Container(
                    height: 10,
                    width: (MediaQuery.of(context).size.width - 52)*double.parse(widget.perHardware.perBattery.percentage),
                    color: Theme.of(context).primaryColor
                  ),
                ]
              ),
              Container(
                height: 217,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color: widget.homePage ? Color(0xFFF5F5F5) : Colors.white
                  ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover, image: AssetImage(widget.imagePath != null && widget.imagePath != "" ? widget.imagePath : "assets/images/layout/random_background.png")),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white.withOpacity(0.8)
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            left: 18,
                            right: 18, 
                            top: 20
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070), fontWeight: FontWeight.normal),
                              children: [
                                TextSpan(
                                  text: "Trạng thái: "
                                ),
                                TextSpan(
                                  text: widget.perHardware.isConnectedTo() ? "Bật" : "Tắt",
                                  style: Theme.of(context).textTheme.headline5.copyWith(color: widget.perHardware.isConnectedTo() ? Color(0xFF1A9156) : Colors.red.withOpacity(0.8))
                                )
                              ]
                            )
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 18,
                                    bottom: 20
                                  ),
                                  child: donutPieChart
                                )
                              ),
                              Flexible(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    right: 18,
                                    bottom: 20
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InfoItem(
                                        color: Color(0xFF707070),
                                        iconItem: "battery.svg",
                                        dimension: 20,
                                        title: "Pin",
                                        bodyColor: Theme.of(context).primaryColor,
                                        amount: (double.parse(widget.perHardware.perBattery.percentage) * 100.0).toString() + "%",
                                      ),
                                      InfoItem(
                                        color: Color(0xFF707070),
                                        iconItem: "wifi.svg",
                                        dimension: 20,
                                        title: "Kết nối",
                                        amount: "Off",
                                        bodyColor: Theme.of(context).primaryColor,
                                      )
                                    ]
                                  ), 
                                )
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                )
              )
            ],
          )
        ),
      ),
    );
  }
}

class AccessoryCardTile extends StatefulWidget {
  @required final PerHardware perHardware;
  bool homePage;
  String imagePath;

  AccessoryCardTile(this.perHardware, {this.homePage = false, Key key, this.imagePath}):super(key: key);

  @override
  _AccessoryCardTileState createState() => _AccessoryCardTileState();
}

class _AccessoryCardTileState extends State<AccessoryCardTile> {
  @override
  void initState() {
    super.initState();
    if(widget.perHardware.hadrwareID.contains("CD")){
      widget.imagePath = "assets/images/layout/charging_dock.png";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width < 400 ? 400 : MediaQuery.of(context).size.width,
      height: 296,
      margin: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      child: RaisedButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        padding: EdgeInsets.all(0),
        onPressed: () {
        },
        child: Container(
          width: MediaQuery.of(context).size.width < 400 ? 400 : MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)
                      ),
                      // color: Color(0xFF1A9156)
                      color: AppColors.blue
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Thiết bị",
                                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.normal)
                              )
                            ),
                            Container(
                              child: Text(
                                widget.perHardware.name,
                                // perContract.getContractPaymentPerPeriod() + "đ",
                                style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white)
                              )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    height: 10,
                    color: Color(0xFF707070)
                  ),
                  Container(
                    height: 10,
                    width: (MediaQuery.of(context).size.width - 52)*1.0,
                    color: Theme.of(context).primaryColor
                  ),
                ]
              ),
              Container(
                height: 217,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: widget.homePage ? Color(0xFFF5F5F5) : Colors.white
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover, image: AssetImage(widget.imagePath != null && widget.imagePath != "" ? widget.imagePath : "assets/images/layout/random_background.png")),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white.withOpacity(0.8)
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070), fontWeight: FontWeight.normal),
                              children: [
                                TextSpan(
                                  text: "Tình trạng: "
                                ),
                                TextSpan(
                                  text: "Mới",
                                  style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFF1A9156))
                                )
                              ]
                            )
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 26),
                                  child: Text(
                                    "Đế sạc thông minh hỗ trợ bạn sạc điện cho các thiết bị của Vulcan, và giúp bạn kiểm tra chất lượng của sản phẩm khi không sử dụng.",
                                    softWrap: true,
                                    maxLines: 5,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070), fontWeight: FontWeight.normal)
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ]
                )
              )
            ],
          )
        ),
      ),
    );
  }
}