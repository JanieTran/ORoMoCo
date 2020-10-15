import 'package:flutter/material.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/views/dashboard/dashboardScreen.dart';
import 'package:oromoco/widgets/components.dart';
import 'package:oromoco/widgets/user_main_info_card.dart';
import 'package:oromoco/hardware/hardwareWidget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PerHardware> _hardwareList = Constants.hardwareList;

  @override
  Widget build(BuildContext context) {
    Widget _horizontalListView(String title, List _list, String iconItem, {Color color, String type}) {
      return Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 26, bottom: 20),
              child: Row(
                children: <Widget>[
                  SVGItem(
                    iconItem: iconItem,
                    dimension: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$title (${_list.length})',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 20),
                  )
                ],
              ),
            ),
            Stack(
              children: <Widget>[
                Container(
                  height: 316,
                  margin: EdgeInsets.only(bottom: 20),
                  child: _list.length != 0
                      ? ListView.builder(
                          itemCount: _list.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, i) => Container(
                            width: MediaQuery.of(context).size.width < 400 ? 400 : MediaQuery.of(context).size.width,
                            child: type == "product" ? HardwareCardTile(_list[i], homePage: true, key: UniqueKey()) : AccessoryCardTile(_list[i], homePage: true)
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Không có sản phẩm khả dụng",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(color: Colors.grey[500]),
                              )
                            ],
                          ),
                        ),
                ),
                _list.length > 1 ? Positioned(
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

    final hardwareItems = [
      UserMainInfoCard(),
      _horizontalListView(
        "Sản phẩm của tôi",
        _hardwareList,
        "tool-list-on-board.svg", 
        type: "product"),
      GestureDetector(
        onTap: (){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DashboardScreen(Constants.bottomBar["detail"], 0, 0)));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Xem tất cả",
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.black45, fontWeight: FontWeight.bold
                )
              ),
              SizedBox(width: 5),
              Icon(
                Icons.arrow_forward,
                color: Colors.black45,
                size: 20
              )
            ]
          )
        ),
      ),
      SizedBox(height: 40),
      _horizontalListView(
        "Phụ kiện của tôi",
        [
          new PerHardware(name: "Đế sạc thông minh", perBattery: new PerBattery(), hadrwareID: "A001", bluetoothID: "", lastSyncDate: DateTime.now().millisecondsSinceEpoch.toString(), address: "", bluetoothSupport: false, version: "Mk2.5", logDocumentID: ""),
          new PerHardware(name: "Dụng cụ hỗ trợ", perBattery: new PerBattery(), hadrwareID: "A001", bluetoothID: "", lastSyncDate: DateTime.now().millisecondsSinceEpoch.toString(), address: "", bluetoothSupport: false, version: "Mk2.5", logDocumentID: ""),
          new PerHardware(name: "Dụng cụ hỗ trợ", perBattery: new PerBattery(), hadrwareID: "A001", bluetoothID: "", lastSyncDate: DateTime.now().millisecondsSinceEpoch.toString(), address: "", bluetoothSupport: false, version: "Mk2.5", logDocumentID: ""),
          new PerHardware(name: "Dụng cụ hỗ trợ", perBattery: new PerBattery(), hadrwareID: "A001", bluetoothID: "", lastSyncDate: DateTime.now().millisecondsSinceEpoch.toString(), address: "", bluetoothSupport: false, version: "Mk2.5", logDocumentID: "")
        ],
        "tool-list-on-board.svg", 
        type: "accessory"),
      SizedBox(height: 40),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView.builder(
          itemCount: hardwareItems.length,
          itemBuilder: (_, i) {
            return hardwareItems[i];
          },
        )
      )
    );
  }
}