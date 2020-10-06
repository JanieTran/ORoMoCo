import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:oromoco/bluetooth/ChatPage.dart';
import 'package:oromoco/bluetooth/SelectBondedDevicePage.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/hardware/hardwareWidget.dart';
import 'package:intl/intl.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/services/database.dart';

class HardwareDetailScreen extends StatefulWidget {
  PerHardware perHardware;
  HardwareDetailScreen({
    @required this.perHardware
  });

  @override
  _HardwareDetailScreenState createState() => _HardwareDetailScreenState();
}

class _HardwareDetailScreenState extends State<HardwareDetailScreen> {
  Stream hardwareLogStream;
  int messageLimit = 20;
  ScrollController _scrollController = new ScrollController();

  Widget logTerminal(){
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white
      ),
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
      child: StreamBuilder(
        stream: hardwareLogStream,
        builder: (context, snapshot){
          return snapshot.hasData
            ? ListView.builder(
              reverse: false,
              itemCount: snapshot.data.documents.length,
              controller: _scrollController,
              itemBuilder: (context, index){
                String time = DateFormat("dd/MM - kk:mm").format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data["time"]).toLocal()).toString();
                return LogTile(
                  time,
                  snapshot.data.documents[index].data["data"]
                );
              },
            )
          : Container();
        }
      )
    );
  }

  @override
  void initState() {
    super.initState();
    DatabaseMethods().getHardwareLog(Constants.firebaseUID, widget.perHardware.logDocumentID, messageLimit).then((value) {
      setState(() {
        hardwareLogStream = value;
      });
    });
  }

  Widget textBuilder(
    String side, String name, String text, {Color color}) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26),
      width: side != "full" ? MediaQuery.of(context).size.width*0.4 : MediaQuery.of(context).size.width,
      color: Colors.white,
      height: 42,
      child: Row(
        children: [
          Container(
            width: 150,
            child: Text(
              name, 
              style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.normal, color: Colors.black),
            ),
          ),
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: Text(
                  text,
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold, color: color != null ? color : Colors.black)
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget textBuilderVertical(
    String side, String name, String text, {Color color}) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
      width: side != "full" ? MediaQuery.of(context).size.width*0.4 : MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 42,
            width: MediaQuery.of(context).size.width,
            child: Text(
              name,
              textAlign: TextAlign.left,
              style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.normal, color: Colors.black),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              child: Text(
                text,
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.bold, color: color != null ? color : Colors.black)
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget doubleTextBuilder(
      String side, String name1, String text1, String name2, String text2, String title, {Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26),
      width: side != "full" ? MediaQuery.of(context).size.width*0.4 : MediaQuery.of(context).size.width,
      color: Colors.white,
      height: 100,
      child: Column(children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            width: MediaQuery.of(context).size.width ,
            child: Text(
              title, 
              textAlign: TextAlign.left,
              style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.normal, color: Colors.black),
            ),
          )
        ),
        SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name1, 
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    child: Text(
                      text1,
                      textAlign: TextAlign.right,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold, color: color != null ? color : Colors.black)
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name2, 
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    child: Text(
                      text2,
                      textAlign: TextAlign.right,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold, color: color != null ? color : Colors.black)
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
        SizedBox(height: 5),
      ],)
    );
  }

  Widget datasheet(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 36),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: Text(
            "Thông tin sản phẩm",
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        SizedBox(height: 12),
        Container(
          child: textBuilder("full", "Tên sản phẩm", widget.perHardware.name)
        ),
        SizedBox(height: 12),
        Container(
            child: Column(children: [
              SizedBox(height: 12),
              textBuilder("full", "Mã sản phẩm", widget.perHardware.hadrwareID),
              SizedBox(height: 2),
              textBuilder("full", "Phiên bản", widget.perHardware.version),
              SizedBox(height: 2),
              textBuilder("full", "Địa chỉ RF", widget.perHardware.address),
              SizedBox(height: 2),
              textBuilder("full", "Hỗ trợ Bluetooth", widget.perHardware.bluetoothSupport ? "Có" : "Không"),
              widget.perHardware.bluetoothSupport ? SizedBox(height: 2):Container(),
              widget.perHardware.bluetoothSupport ? doubleTextBuilder("full", "Mã Bluetooth", widget.perHardware.bluetoothID, "Trạng thái", "Ngắt kết nối", "Thông tin Bluetooth"):Container(),
              SizedBox(height: 24),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 26),
                child: Text(
                  "Thông số pin",
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Container(
                height: 200,
                padding: EdgeInsets.symmetric(horizontal: 26),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: Stack(
                        children: [
                          DonutPieChart.setData(used: 100 - (double.parse(widget.perHardware.perBattery.percentage) * 100).round(), left: (double.parse(widget.perHardware.perBattery.percentage) * 100).round(), doubleLayer: false),
                          Positioned(
                            top: 85,
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.66 - 52*0.66,
                              child: Text(
                                (double.parse(widget.perHardware.perBattery.percentage) * 100).round().toString() + "%",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFF1A9156))
                              ),
                            ),
                          )
                        ]
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Định mức pin: ",
                              style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070), fontWeight: FontWeight.normal),
                            ),
                            Text(
                              widget.perHardware.perBattery.capacity + "mAh",
                              textAlign: TextAlign.right,                           
                              style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFF1A9156))
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Chủng pin: ",
                              style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070), fontWeight: FontWeight.normal),
                            ),
                            Text(
                              widget.perHardware.perBattery.type,
                              textAlign: TextAlign.right,                           
                              style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFF1A9156))
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ),
              SizedBox(height: 24),
            ]
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pushReplacementNamed(
        //     context, TkcRoutes.dashboard,
        //     arguments: 0);
        Navigator.pop(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFF5F5F5),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0) + Offset(
              0.0, 
              50.0
            ),
            // preferredSize: Size.fromHeight(60.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      elevation: 5,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigator.pushReplacementNamed(
                              //     context, TkcRoutes.dashboard,
                              //     arguments: 1);
                              // Navigator.pushReplacementNamed(
                              //     context, TkcRoutes.dashboard,
                              //     arguments: 0);
                              Navigator.pop(context);
                            },
                            child: Container(
                              child: Icon(Icons.arrow_back,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          Text(
                            widget.perHardware.name,
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          Container()
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    color: Color(0xFF09764C),
                    width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 26),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  flex: 3,
                                  child: Text(
                                    "Trạng thái: ",
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.normal)
                                  )
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    widget.perHardware.status,
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)
                                  )
                                )
                              ],
                            )
                          ),
                          SizedBox(width: 40),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    "Phiên bản: ",
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.normal)
                                  )
                                ),
                                Flexible(child: Text(
                                    widget.perHardware.version,
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)
                                  ))
                              ],
                            )
                          ),
                        ],
                      ),
                  )
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height),
                child: Container(
                  child: Column(
                    children: [
                      datasheet(),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 26),
                        child: Text(
                          "Nhật ký sự kiện",
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10),
                      logTerminal(),
                      SizedBox(height: 50)
                    ]
                  )
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5), 
              // boxShadow: [
              //   BoxShadow(color: Colors.black38, blurRadius: 5)
              // ]
            ),
            padding: EdgeInsets.symmetric(vertical: 2),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(
                  child: ButtonTheme(
                    height: 50,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                      elevation: 1,
                      color: Colors.white,
                      child: Text(
                        'Kết nối',
                        style: Theme.of(context)
                            .textTheme
                            .headline6.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF09764C)),
                      ),
                      onPressed: () async {
                        final BluetoothDevice selectedDevice =
                            await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SelectBondedDevicePage(checkAvailability: false, address: widget.perHardware.bluetoothID);
                            },
                          ),
                        );

                        if (selectedDevice != null) {
                          print('Connect -> selected ' + selectedDevice.address);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(server: selectedDevice);
                              },
                            ),
                          );
                        } else {
                          print('Connect -> no device selected');
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ButtonTheme(
                    height: 50,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                      elevation: 1,
                      color: Colors.white,
                      child: Text(
                        'Cài đặt',
                        style: Theme.of(context)
                            .textTheme
                            .headline6.copyWith(fontWeight: FontWeight.bold, 
                            color: Color(0xFF09764C)),
                      ),
                      onPressed: (){
                         print("configure");
                      }),
                  ),
                ),
                SizedBox(width: 10),
              ],
            )
          ),
        ),
      ),
    );
  }
}

class LogTile extends StatelessWidget {
  final String time;
  final String data;

  LogTile(this.time, this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Text(
              time,
              style: Theme.of(context).textTheme.bodyText1.copyWith(color: Color(0xFF707070))
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            flex: 2,
            child: Text(
              data,
              style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black)
            ),
          )
        ],
      )
    );
  }
}