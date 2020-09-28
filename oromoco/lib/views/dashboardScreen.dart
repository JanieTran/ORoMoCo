import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/helper/helperFunctions.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FeatureTile> featureList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    featureList.add(new FeatureTile("Vulcan's Control Panel", key: UniqueKey()));
  }

  @override
  Widget build(BuildContext context) {
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
              },
            ),
            ListTile(
              title: Text(
                'Sign Out',
                style: Theme.of(context).textTheme.headline6
              ),
              onTap: () {
                Navigator.pop(context);
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
        child: FeatureList(featureList)
      ),
    );
  }
}

class FeatureList extends StatelessWidget {
  List<FeatureTile> featureList = [];
  FeatureList(this.featureList);
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class FeatureTile extends StatefulWidget {
  final String name;
  FeatureTile(this.name, {Key key}):super(key: key);
  @override
  _FeatureTileState createState() => _FeatureTileState();
}

class _FeatureTileState extends State<FeatureTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print(widget.name);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).accentColor
        ),
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          widget.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6
        ),
      ),
    );
  }
}