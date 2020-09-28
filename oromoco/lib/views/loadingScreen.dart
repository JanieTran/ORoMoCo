import 'package:flutter/material.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/helper/helperFunctions.dart';
import 'package:oromoco/views/dashboardScreen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String message;
  double percentage;
  final double loadingCurrentUser = 1.0;
  bool currentUserLoaded = false;

  getUserInformation() async {
    Constants.username = await HelperFunctions.getUserNameSharedPreferences();
    Constants.email = await HelperFunctions.getUserEmailSharedPreferences();
  }

  Future<void> dataLoading() async{
    setState(() {
      message = "Tải thông tin của bạn";
    });

    await getUserInformation();

    setState(() {
      currentUserLoaded = true;
      message = "Hoàn tất";
    });

    if(currentUserLoaded){
      Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
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
                      (currentUserLoaded ? loadingCurrentUser : 0.0)
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

