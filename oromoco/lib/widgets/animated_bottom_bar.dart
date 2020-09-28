import 'package:flutter/material.dart';
import 'package:oromoco/widgets/components.dart';

class AnimatedBottomBar extends StatefulWidget {
  final List<BarItem> barItems;
  final Duration animationDuration;
  final Function onBarTap;
  final BarStyle barStyle;
  final int currentIndex;

  AnimatedBottomBar({
    this.barItems,
    this.animationDuration = const Duration(milliseconds: 500),
    this.onBarTap,
    this.barStyle,
    this.currentIndex,
    Key key
  }) : super(key: key);

  @override
  AnimatedBottomBarState createState() => AnimatedBottomBarState();
}

class AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  int selectedBarIndex = 1;

  @override
  void initState() {
    selectedBarIndex = widget.currentIndex;
    super.initState();
  }

  void setIndex(int index){
    print("hello");
    setState(() {
      selectedBarIndex = index;
      widget.onBarTap(selectedBarIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Material(
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 5)]
        ),
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildBarItems(context, width),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems(BuildContext contex, double large) {
    List<Widget> _barItems = List();
    for (int i = 0; i < widget.barItems.length; i++) {
      BarItem item = widget.barItems[i];
      bool isSelected = selectedBarIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectedBarIndex = i;
            widget.onBarTap(selectedBarIndex);
          });
        },
        child: AnimatedContainer(
          padding: EdgeInsets.symmetric(
            horizontal: large * 0.001,
            vertical: large * 0.008,
          ),
          duration: widget.animationDuration,
          // decoration: BoxDecoration(
          //     color: isSelected
          //         ? Theme.of(context).primaryColor
          //         : Colors.transparent,
          //     borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: 40,
                    child: Column(
                      children: <Widget>[
                        SVGItem(
                          iconItem: item.iconDataClicked != null ? (isSelected ? item.iconDataClicked : item.iconDataNone) : (isSelected ? item.iconDataNone : item.iconDataNone),
                          dimension: 20,
                          color: item.iconDataClicked == null ? (isSelected ? Colors.black : Theme.of(context).primaryColor): null
                        ),
                        SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            item.iconText,
                            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 8, fontWeight: FontWeight.normal)
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(  // draw a red marble
                    top: -1.0,
                    right: -1.0,
                    child: item.isNotified ? Icon(Icons.brightness_1, size: 12.0, 
                      color: Colors.redAccent) : Container(),
                  )
                ]
              ),
              SizedBox(
                width: large * 0.01,
              ),
              AnimatedSize(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                vsync: this,
                child: Text(
                  isSelected ? item.text : "",
                  style: TextStyle(
                    color: item.color,
                    fontSize: widget.barStyle.fontSize,
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    }
    return _barItems;
  }
}

class BarStyle {
  final double fontSize, iconSize;

  BarStyle({
    this.fontSize = 16.0,
    this.iconSize = 15,
  });
}

class BarItem {
  String text;
  String iconDataNone;
  String iconDataClicked;
  Color color;
  bool isNotified;
  String iconText;

  BarItem({this.iconText, this.text, this.iconDataNone, this.iconDataClicked, this.color, this.isNotified});
}