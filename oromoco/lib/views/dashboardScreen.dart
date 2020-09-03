import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FeatureTile> featureList = [];

  @override
  Widget build(BuildContext context) {
    for(var i = 0; i < 100; i++){
      featureList.add(new FeatureTile(i.toString(), key: UniqueKey()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Icon(
                Icons.menu,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Expanded(
              child: Container(
                child: Text(
                  "OROMOCO",
                  style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).accentColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                Fluttertoast.showToast(msg: "pressed");
              },
              child: Container(
                child: Icon(
                  Icons.menu,
                  color: Theme.of(context).accentColor
                ),
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
        ),
      ),
    );
  }
}