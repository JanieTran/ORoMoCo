import 'package:flutter/material.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/hardware/hardwareWidget.dart';

class ToolDetailScreen extends StatefulWidget {
  @override
  _ToolDetailScreenState createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
    List<PerHardware> _hardwareList = [
    new PerHardware(
      "Vulcan's Mk10",
      new PerBattery(
        id: "1001",
        type: "LiPo",
        capacity: "2400mAh"
      ),
    ),
     new PerHardware(
      "Vulcan's sensor",
      new PerBattery(
        id: "1002",
        type: "LiPo",
        capacity: "2400mAh"
      ),
    ),
     new PerHardware(
      "Insole",
      new PerBattery(
        id: "1003",
        type: "LiPo",
        capacity: "2400mAh"
      ),
    )
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
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