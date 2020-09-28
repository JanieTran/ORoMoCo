import 'package:flutter/material.dart';
import 'package:oromoco/bluetooth/MainPage.dart';
import 'package:oromoco/helper/authenticate.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/helper/helperFunctions.dart';
import 'package:oromoco/services/auth.dart';
import 'package:oromoco/views/controlPanelScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List featureList = [];

  Widget featureTile (String name){
    return GestureDetector(
      onTap: (){
        onFeatureTap(name);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).accentColor
        ),
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6
        ),
      ),
    );
  }

  void onFeatureTap(name) async {
    if(name == "Vulcan's Control Panel"){
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ControlPanelScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    featureList.clear();
    featureList.add(featureTile("Vulcan's Control Panel"));

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Constants.username,
                    style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).accentColor)
                  ),
                  SizedBox(height: 10),
                  Text(
                    Constants.email,
                    style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)
                  ),
                ]
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              title: Text(
                'Devices',
                style: Theme.of(context).textTheme.headline6
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
              },
            ),
            ListTile(
              title: Text(
                'Sign Out',
                style: Theme.of(context).textTheme.headline6
              ),
              onTap: () {
                HelperFunctions.resetUserLoggedInSharedPreferencs();
                AuthMethod().signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: new IconThemeData(
          color: Theme.of(context).accentColor
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                child: Text(
                  "OROMOCO",
                  style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).accentColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              child: Icon(
                Icons.menu,
                color: Theme.of(context).primaryColor
              ),
            )
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20
        ),
        child: Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: featureList.length,
            itemBuilder: (context, index){
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 5
                 ),
                child: featureList[index]
              );
            }
          ),
        ),
      ),
    );
  }
}