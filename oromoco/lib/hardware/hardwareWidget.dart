import 'package:flutter/material.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/hardware/hardwareDetailScreen.dart';
import 'package:oromoco/widgets/components.dart';

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
  String status = "tắt";

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

  String getLastSyncDate(){
    return DateTime.now().toLocal().difference(DateTime.fromMillisecondsSinceEpoch(int.parse(lastSyncDate)).toLocal()).inDays.toString();
  }

  String getStatus(){
    return status;
  }
}

class HardwareCardTile extends StatelessWidget {
  @required final PerHardware perHardware;
  bool homePage;

  HardwareCardTile(this.perHardware, {this.homePage = false, Key key}):super(key: key);

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
                    HardwareDetailScreen(perHardware: perHardware)));
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
                      color: Color(0xFF1A9156)
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
                                perHardware.name,
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
                                color: Color(0xFF1A9156)
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
                                color: Color(0xFF1A9156)
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)
                              ),
                              color: Colors.white
                            ),
                            child: Text(
                              perHardware.getLastSyncDate(),
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
                    width: (MediaQuery.of(context).size.width - 52)*double.parse(perHardware.perBattery.percentage),
                    color: Color(0xFFFEC84D)
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
                    color: homePage ? Color(0xFFF5F5F5) : Colors.white
                  ),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070), fontWeight: FontWeight.normal),
                          children: [
                            TextSpan(
                              text: "Trạng thái: "
                            ),
                            TextSpan(
                              text: perHardware.getStatus(),
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
                            flex: 3,
                            child: Stack(
                              children: [
                                DonutPieChart.setData(used: 100 - (double.parse(perHardware.perBattery.percentage) * 100).round(), left: (double.parse(perHardware.perBattery.percentage) * 100).round(), doubleLayer: false),
                                // DonutPieChart.setData(paid: int.parse(perContract.getTotalPaid().replaceAll(",", "")), debt: int.parse(perContract.getTotalDebt().replaceAll(",", "")), payment: true)
                              ]
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InfoItem(
                                    color: Color(0xFF707070),
                                    iconItem: "battery.svg",
                                    dimension: 20,
                                    title: "Pin",
                                    amount: (double.parse(perHardware.perBattery.percentage) * 100.0).toString() + "%"
                                  ),
                                  InfoItem(
                                    color: Color(0xFF707070),
                                    iconItem: "wifi.svg",
                                    dimension: 20,
                                    title: "Kết nối",
                                    amount: "Off"
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
              )
            ],
          )
        ),
      ),
    );
  }
}