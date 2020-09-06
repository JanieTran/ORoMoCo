import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'console.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FeatureTile> featureList = [];
  List<String> featureName = ['Console'];

  @override
  void initState() {
    super.initState();
    // List of features to appear in tiles
    for (var name in featureName) {
      featureList.add(new FeatureTile(name, key: UniqueKey()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold (
      appBar: AppBar (
        centerTitle: true,
        title: Text(
          "OROMOCO",
          style: theme.textTheme.headline5.copyWith(color: theme.accentColor),
        ),
        actions: <Widget>[
          IconButton (
          icon: Icon(Icons.menu, color: Theme.of(context).accentColor),
          onPressed: () {
            Fluttertoast.showToast(msg: 'Menu pressed');
          })
        ],
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
          itemBuilder: (context, index) {
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
  FeatureTile(this.name, {Key key}) : super(key: key);

  @override
  _FeatureTileState createState() => _FeatureTileState();
}

class _FeatureTileState extends State<FeatureTile> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: (){
        print(widget.name);
        _navigateFeature(context, widget.name);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: theme.accentColor
        ),
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
              child: Icon(Icons.videogame_asset, color: theme.primaryColor),
            ),
            Text(
              widget.name,
              style: theme.textTheme.headline5,
            ),
          ],
        )
      ),
    );
  }

  void _navigateFeature(BuildContext context, String featureName) {
    switch (featureName) {
      case 'Console':
        Navigator.push(context, MaterialPageRoute(builder: (context) => Console()));
        break;
      default:
        Fluttertoast.showToast(msg: 'Feature under construction');
        break;
    }
  }
}