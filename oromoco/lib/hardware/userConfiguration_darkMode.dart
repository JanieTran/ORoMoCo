import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:oromoco/bluetooth/utils/utils.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/hardware/hardwareWidget.dart';
import 'package:oromoco/hardware/signalWidget.dart';
import 'package:oromoco/utils/theme/theme.dart';

class UserConfigurationDarkModeScreen extends StatefulWidget {
  final PerHardware perHardware;
  final BluetoothDevice server;
  
  UserConfigurationDarkModeScreen({
    @required this.perHardware,
    @required this.server
  });

  @override
  _UserConfigurationDarkModeScreenState createState() => _UserConfigurationDarkModeScreenState();
}

class _UserConfigurationDarkModeScreenState extends State<UserConfigurationDarkModeScreen> {
  PerPackage currentMessageInBuffer = new PerPackage();

  bool isConnecting = true;
  bool get isConnected => widget.perHardware.connection != null && widget.perHardware.connection.isConnected;

  bool isDisconnecting = false;
  bool isConfigured = false;
  Timer periodicBluetooth;
  Timer fakeData;
  
  NumericComboLinePointChart numericComboLinePointChart;
  HorizontalBarLabelCustomChart horizontalBarLabelCustomChart;
  DonutPieChart batteryDonut;
  DonutPieChart angleDonut;

  GlobalKey<NumericComboLinePointChartState> _keyLineChart = new GlobalKey();
  GlobalKey<HorizontalBarLabelCustomChartState> _keyHorizontalBar = new GlobalKey();
  GlobalKey<DonutPieChartState> _keyBatteryDonut = new GlobalKey();
  GlobalKey<DonutPieChartState> _keyAngleDonut = new GlobalKey();

  /*
  FAKE DATA
  */
  int rfSignalPercentage;
  int bluetoothSignalPercentage;
  final _random = new Random();

  @override
  void initState() {
    super.initState();

    _keyBatteryDonut.currentState.setData(
      used: 100 - (double.parse(widget.perHardware.perBattery.percentage) * 100).round(), 
      left: (double.parse(widget.perHardware.perBattery.percentage) * 100).round()
    );   

    numericComboLinePointChart = new NumericComboLinePointChart(key: _keyLineChart);
    horizontalBarLabelCustomChart = new HorizontalBarLabelCustomChart(key: _keyHorizontalBar);
    angleDonut = new DonutPieChart(key: _keyAngleDonut);
    batteryDonut = new DonutPieChart(key: _keyBatteryDonut);

    rfSignalPercentage = 85;
    bluetoothSignalPercentage = 85;

    if(!widget.perHardware.isConnectedTo()){
      BluetoothConnection.toAddress(widget.server.address).then((_connection) {
        print('Connected to the device');
        widget.perHardware.connection = _connection;
        // setState(() {
        //   isConnecting = false;
        //   isDisconnecting = false;
        // });

        widget.perHardware.connection.input.listen(widget.perHardware.onDataReceived).onDone(() {
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

    widget.perHardware.messages.clear();

    Future.delayed(Duration(milliseconds: 500)).then((value){
      widget.perHardware.sendMessage("default command - set mode - 1001");
      Future.delayed(Duration(milliseconds: 500)).then((value){
        widget.perHardware.sendMessage("default command - set mode - 7");
        Future.delayed(Duration(milliseconds: 500)).then((value){
          setState(() {
            periodicBluetooth = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
              try{
                PerPackage oldPackage = currentMessageInBuffer; 
                currentMessageInBuffer = widget.perHardware.messageBuffer();
                if(currentMessageInBuffer.initialized && oldPackage.angle != currentMessageInBuffer.angle){
                  _keyAngleDonut.currentState.setData(
                    used: currentMessageInBuffer.getAngle(), 
                    left: 180 - currentMessageInBuffer.getAngle()
                  ); 
                }
              } catch(e){
                periodicBluetooth.cancel();
              }
            });

            fakeData = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
              try{
                /*
                FAKE DATA
                */

                int randomValue = _random.nextInt(10);
                rfSignalPercentage = 85 + randomValue;
                randomValue = _random.nextInt(10);
                bluetoothSignalPercentage = 85 + randomValue;
                _keyLineChart.currentState.setData(
                  rfPercentage: rfSignalPercentage, 
                  bluetoothPercentage: bluetoothSignalPercentage
                );

                _keyHorizontalBar.currentState.setData(
                  rfPercentage: rfSignalPercentage,
                  bluetoothPercentage: bluetoothSignalPercentage
                );

                //----------------------------
              } catch(e){
                fakeData.cancel();
              }
            });

            isConfigured = true;
            isConnecting = false;
            isDisconnecting = false;
          });
        });
      });
    });
  }

  Widget textBuilder(
    String side, String name, String text, {Color color, Color backgroundColor}) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26),
      width: side != "full" ? MediaQuery.of(context).size.width*0.4 : MediaQuery.of(context).size.width,
      color: backgroundColor != null ? backgroundColor: Colors.white.withOpacity(0.2),
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
                          .copyWith(fontWeight: FontWeight.normal, color: Colors.white),
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
                      .copyWith(fontWeight: FontWeight.bold, color: color != null ? color : Colors.white)
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget doubleTextBuilder(
    String side, String name1, String text1, String name2, String text2, String title, {Color color, Color backgroundColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26),
      width: side != "full" ? MediaQuery.of(context).size.width*0.4 : MediaQuery.of(context).size.width,
      color: backgroundColor != null ? backgroundColor : Colors.white.withOpacity(0.2),
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
                          .copyWith(fontWeight: FontWeight.normal, color: Colors.white),
            ),
          )
        ),
        SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width,
          color: backgroundColor != null ? backgroundColor : Colors.transparent,
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
                              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
                          .copyWith(fontWeight: FontWeight.bold, color: color != null ? color : Colors.white)
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: backgroundColor != null ? backgroundColor : Colors.transparent,
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
                              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
                          .copyWith(fontWeight: FontWeight.bold, color: color != null ? color : Colors.white)
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

  Future<void> onChooseColor(){
    // create some values
    Color pickerColor = Color(0xff443a49);
    Color currentColor = Color(0xff443a49);

    // ValueChanged<Color> callback
    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    // raise the [showDialog] widget
    return showDialog(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        title: Text('Chọn màu bạn thích', style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: null,
            // onColorChanged: changeColor,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Chọn', style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black)),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { 
    periodicBluetooth.cancel();
    fakeData.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isConfigured && currentMessageInBuffer.initialized ? Container(
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            AppColors.blue,
            Color(0xFF5C5CFF)
          ],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp
        )
      ),
      child: Scaffold(
        // backgroundColor: Color(0xFFF5F5F5),
        backgroundColor: Colors.transparent, 
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
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Icon(Icons.arrow_back,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        (isConnecting
                          ? Text(
                            'Kết nối với ' + widget.server.name + '...',
                            style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(
                                color: Colors.black)
                          )
                          : isConnected
                              ? Text('Điều chỉnh hệ thống',
                            style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(
                                color: Colors.black))
                              : Text('Lịch sử tương tác với ' + widget.server.name,
                            style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(
                                color: Colors.black))),
                        Container()
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  color: widget.perHardware.isConnectedTo() ? Color(0xFF09764C) : Colors.red.withOpacity(0.8),
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
                                  widget.perHardware.isConnectedTo() ? "Bật" : "Tắt",
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  child: Text(
                    "THÔNG SỐ HỆ THỐNG",
                    style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFFF58C14)),
                    textAlign: TextAlign.left,
                  )
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    "THÔNG TIN SẢN PHẨM",
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF58C14)),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  child: textBuilder("full", "Tên sản phẩm", widget.perHardware.name, color: Colors.grey)
                ),
                SizedBox(height: 12),
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: 12),
                      textBuilder("full", "Mã sản phẩm", widget.perHardware.hadrwareID, color: Colors.grey),
                      SizedBox(height: 2),
                      textBuilder("full", "Phiên bản", widget.perHardware.version, color: Colors.grey),
                      SizedBox(height: 2),
                      textBuilder("full", "Địa chỉ RF", widget.perHardware.address, color: Colors.grey),
                      SizedBox(height: 2),
                      textBuilder("full", "Hỗ trợ Bluetooth", widget.perHardware.bluetoothSupport ? "Có" : "Không", color: Colors.grey),
                      widget.perHardware.bluetoothSupport ? SizedBox(height: 2):Container(),
                      widget.perHardware.bluetoothSupport ? doubleTextBuilder("full", "Mã Bluetooth", widget.perHardware.bluetoothID, "Trạng thái", widget.perHardware.isConnectedTo() ? "Kết nối" : "Ngắt kết nối", "Thông tin Bluetooth", color: Colors.grey):Container(),
                      SizedBox(height: 24),
                    ]
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    "HIỆU CHỈNH HỆ THỐNG",
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF58C14)),
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: 12),
                      textBuilder("full", "Tốc độ mô tơ", currentMessageInBuffer.motorSpeed.toString()),
                      SizedBox(height: 2),
                      textBuilder("full", "Chiều nút nhấn", currentMessageInBuffer.buttonDirection.toString()),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => onChooseColor(),
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              textBuilder("full", "Sắc đỏ", currentMessageInBuffer.red.toString()),
                              SizedBox(height: 2),
                              textBuilder("full", "Sắc xanh lá", currentMessageInBuffer.green.toString()),
                              SizedBox(height: 2),
                              textBuilder("full", "Sắc xanh dương", currentMessageInBuffer.blue.toString()),
                            ],
                          ),
                        )
                      ),
                      SizedBox(height: 24),
                      doubleTextBuilder("full", "Ngưỡng trên", currentMessageInBuffer.upperLimit.toString(), "Ngưỡng dưới", currentMessageInBuffer.lowerLimit.toString(), "Ngưỡng góc di chuyển"),
                      SizedBox(height: 24),
                    ]
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  child: Text(
                    "GÓC HIỆN TẠI",
                    style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFFF58C14)),
                    textAlign: TextAlign.left,
                  )
                ),
                Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Colors.white.withOpacity(0.2), 
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                          horizontal: 100
                        ),
                        child: angleDonut,
                      ),
                      Positioned(
                        top: 85,
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                            horizontal: 74
                          ),
                          child: Text(
                            currentMessageInBuffer.getAngle().toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).primaryColor)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    "BIỂU ĐỒ PIN",
                    style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFFF58C14)),
                    textAlign: TextAlign.left,
                  )
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "PIN HIỆN TẠI",
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF58C14)),                    
                      textAlign: TextAlign.left,
                    ),
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  color: Colors.white.withOpacity(0.2), 
                  height: 200,
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Stack(
                          children: [
                            batteryDonut,
                            Positioned(
                              top: 85,
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.66 - 52*0.66,
                                child: Text(
                                  (double.parse(widget.perHardware.perBattery.percentage) * 100).round().toString() + "%",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).primaryColor)
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
                                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                              ),
                              Text(
                                widget.perHardware.perBattery.capacity + "mAh",
                                textAlign: TextAlign.right,                           
                                style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).primaryColor)
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Chủng pin: ",
                                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                              ),
                              Text(
                                widget.perHardware.perBattery.type,
                                textAlign: TextAlign.right,                           
                                style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).primaryColor)
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "DUNG LƯỢNG PIN",
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF58C14)),
                      textAlign: TextAlign.left,
                    ),
                  )
                ),
                Container(
                  color: Colors.white.withOpacity(0.2),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  child: Stack(
                    children: <Widget>[
                      StackedAreaLineChart.idealDataPlot(),
                      StackedAreaLineChart.sampleActualDataPlot(),
                      Positioned(
                        top: 75, 
                        left: 75,
                        child: Container(
                          child: Text(
                            "90%",
                            style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).primaryColor)
                          ),
                        ),
                      )
                    ],
                  )
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    "BIỂU ĐỒ VÔ TUYẾN",
                    style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xFFF58C14)),
                    textAlign: TextAlign.left,
                  )
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "KẾT NỐI",
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF58C14)),                    
                      textAlign: TextAlign.left,
                    ),
                  )
                ),
                Container(
                  color: Colors.white.withOpacity(0.2),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  child: Stack(
                    children: <Widget>[
                      horizontalBarLabelCustomChart
                    ],
                  )
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "LỊCH SỬ KẾT NỐI",
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF58C14)),                    
                      textAlign: TextAlign.left,
                    ),
                  )
                ),
                Container(
                  color: Colors.white.withOpacity(0.2),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  child: Stack(
                    children: <Widget>[
                      numericComboLinePointChart
                    ],
                  )
                ),
                SizedBox(height: 100)
              ]
            )
          )
        ),
      ),
    ) : Container(
      color: Colors.white,
      child: FittedBox(
        child: Container(
          margin: new EdgeInsets.all(100.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
          ),
        ),
      ),
    );
  }
}
