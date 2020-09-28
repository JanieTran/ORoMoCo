import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoItem extends StatelessWidget {
  const InfoItem({Key key, this.iconItem, this.title, this.amount, this.dimension, this.color, this.titleColor, this.bodyColor})
      : super(key: key);

  final String iconItem;
  final String title;
  final String amount;
  final double dimension;
  final Color color;
  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    Color titleColorCasted;
    Color bodyColorCasted;

    if(titleColor == null){
      titleColorCasted = color;
    } else{
      titleColorCasted = titleColor;
    }

    if(bodyColor == null){
      bodyColorCasted = color;
    } else{
      bodyColorCasted = bodyColor;
    }

    return Container(
      child: Row(
        children: <Widget>[
          new Container(
            child: SvgPicture.asset(
              'assets/images/icon/${iconItem}',
              color: color,
              height: dimension,
              width: dimension,
            ),
          ),
          new Container(
            padding: new EdgeInsets.only(left: 9.75),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: titleColorCasted,
                      ),
                ),
                new Text(amount,
                    style: Theme.of(context).textTheme.headline5.copyWith(
                          color: bodyColorCasted,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SVGItem extends StatelessWidget {
  const SVGItem({Key key, this.iconItem, this.dimension, this.color})
      : super(key: key);

  final String iconItem;
  final double dimension;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SvgPicture.asset(
        'assets/images/icon/${iconItem}',
        color: color,
        height: dimension,
        width: dimension,
      ),
    );
  }
}