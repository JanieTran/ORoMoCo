import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oromoco/hardware/batteryWidget.dart';
import 'package:oromoco/hardware/hardwareWidget.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/helper/helperFunctions.dart';
import 'package:oromoco/services/database.dart';
import 'package:oromoco/views/dashboard/dashboardScreen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String message;
  double percentage;
  final double loadingCurrentUser = 0.2;
  final double loadingCurrentHardware = 0.8;
  bool currentUserLoaded = false;
  bool currentHardwareLoaded = false;

  getUserInformation() async {
    Constants.username = await HelperFunctions.getUserNameSharedPreferences();
    Constants.email = await HelperFunctions.getUserEmailSharedPreferences();
    DatabaseMethods().getUserByUserEmail(Constants.email).then((value) async {
      final List<DocumentSnapshot> documents = value.documents;
      Constants.userID = documents[0]["userID"];
    });
  }

  getHardwareInformation() async {
    List<PerHardware> _hardwareList = [];
    DatabaseMethods().getUserHardware(Constants.firebaseUID).then((value) async {
      final List<DocumentSnapshot> documents = value.documents;
      for(int i = 0 ; i < documents.length;i++){
        await DatabaseMethods().getHardwareDatasheet(documents[i]["hardwareID"]).then((val){
          String hardwareName = "";
          bool bluetoothSupport = false;
          String batteryCapacity = "";
          String batteryType = "";
          String version = "";
          
          final List<DocumentSnapshot> hardware = val.documents;
          if(hardware.length == 1){
            hardwareName = hardware[0]["name"];
            bluetoothSupport = hardware[0]["bluetoothSupport"];
            batteryCapacity = hardware[0]["batteryCapacity"];
            batteryType = hardware[0]["batteryType"];
            version = hardware[0]["version"];
          }
          _hardwareList.add(new PerHardware(
            version: version,
            bluetoothID: documents[i]["bluetoothID"], 
            address: documents[i]["address"], 
            bluetoothSupport: bluetoothSupport,
            perBattery: new PerBattery(
              type: batteryType,
              capacity: batteryCapacity
            ),
            name: hardwareName, 
            hadrwareID: documents[i]["hardwareID"], 
            lastSyncDate: documents[i]["lastSyncDate"].toString()
          ));
        });
      }
      Constants.hardwareList = _hardwareList;
    });
  }

  Future<void> dataLoading() async{
    setState(() {
      message = "Tải thông tin của bạn";
    });

    await getUserInformation();

    setState(() {
      currentUserLoaded = true;
      message = "Tải phần cứng của bạn";
    });

    await getHardwareInformation();

    setState(() {
      currentHardwareLoaded = true;
      message = "Hoàn tất";
    });

    if(currentUserLoaded && currentHardwareLoaded){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(Constants.bottomBar["home"], 0, 0)));
    }
  }

  @override
  void initState(){ 
    super.initState();
    message = "Tải thông tin của bạn";
    percentage = 0.0;
    dataLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            Container(
              child: Text(
                // message,
                "Đang tải thông tin",
                style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070))
              )
            ),
            SizedBox(height: 10),
            Stack(
              children: <Widget>[
                Container(        
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFF707070)
                  ),
                  height: 10,
                  width: MediaQuery.of(context).size.width - 26 * 2,
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).accentColor
                    ),
                    height: 10,
                    width: (MediaQuery.of(context).size.width - (26 * 2))*(
                      (currentUserLoaded ? loadingCurrentUser : 0.0) +
                      (currentHardwareLoaded ? loadingCurrentHardware : 0.0)
                    )
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                // message,
                "Xin vui lòng chờ trong giây lát...",
                style: Theme.of(context).textTheme.headline6.copyWith(color: Color(0xFF707070))
              )
            ),
            SizedBox(height: 20),
            CircularProgressIndicator()
          ],
        ),
      )
    );
  }
}

