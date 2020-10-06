import 'package:flutter/material.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/hardware/hardwareWidget.dart';
import 'package:oromoco/helper/constants.dart';

class ToolDetailScreen extends StatefulWidget {
  @override
  _ToolDetailScreenState createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  //   List<PerHardware> _hardwareList = [
  //   new PerHardware(
  //     "Vulcan's Mk10",
  //     new PerBattery(
  //       id: "1001",
  //       type: "LiPo",
  //       capacity: "2400mAh"
  //     ),
  //   ),
  //    new PerHardware(
  //     "Vulcan's sensor",
  //     new PerBattery(
  //       id: "1002",
  //       type: "LiPo",
  //       capacity: "2400mAh"
  //     ),
  //   ),
  //    new PerHardware(
  //     "Insole",
  //     new PerBattery(
  //       id: "1003",
  //       type: "LiPo",
  //       capacity: "2400mAh"
  //     ),
  //   )
  // ];

  List<PerHardware> _hardwareList = Constants.hardwareList;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 10
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Icon(
                    Icons.filter_list,
                    color: Color(0xFF707070)
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    "Lọc",
                    style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070)),
                  )
                ),
                Flexible(
                  flex: 4,
                  child: TextField(
                    enabled: false,
                    style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070)),
                    controller: null,
                    decoration: InputDecoration.collapsed(
                      hintText: "Tất cả sản phẩm",
                      hintStyle: Theme.of(context).textTheme.headline6.copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
                    ),
                    
                  ),
                ),
                Container(
                  width: 50,
                  child: ButtonTheme(
                    buttonColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: RaisedButton(
                      onPressed: () {  },
                      child: Container(
                        child: Text(
                          "+",
                          style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070)),
                          textAlign: TextAlign.center
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
          Expanded(
            child: _buildContractCardList(_hardwareList)
          )
        ]
      )
    );
  }
}

Widget _buildContractCardList(List<PerHardware> _hardwareList) {
  return ListView(
      children: _hardwareList
        .map((hardware) => Container(
          child: new HardwareCardTile(
            hardware,
            homePage: false,
            key: UniqueKey()),
        ))
        .toList(),
  );
}