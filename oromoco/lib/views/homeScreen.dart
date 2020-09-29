import 'package:flutter/material.dart';
import 'package:oromoco/helper/constants.dart';
import 'package:oromoco/views/dashboardScreen.dart';
import 'package:oromoco/widgets/components.dart';
import 'package:oromoco/widgets/user_main_info_card.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Widget _horizontalListView(String title, List _list, String iconItem, {Color color, bool isMyLine, String type}) {
      return Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 26, bottom: 20),
              child: Row(
                children: <Widget>[
                  SVGItem(
                    iconItem: iconItem,
                    dimension: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$title (${_list.length})',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 20),
                  )
                ],
              ),
            ),
            Stack(
              children: <Widget>[
                Container(
                  height: 316,
                  margin: EdgeInsets.only(bottom: 20),
                  child: _list.length != 0
                      ? ListView.builder(
                          itemCount: _list.length,
                          scrollDirection: Axis.horizontal,
                          // itemBuilder: (_, i) => _buildBox(label, i),
                          itemBuilder: (_, i) => Container(
                            width: MediaQuery.of(context).size.width < 400 ? 400 : MediaQuery.of(context).size.width,
                            child: Container()
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Không có sản phẩm khả dụng",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(color: Colors.grey[500]),
                              )
                            ],
                          ),
                        ),
                ),
                _list.length > 1 ? Positioned(
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 316,
                    child: Icon(
                      Icons.arrow_right,
                      color: Colors.black.withOpacity(0.4),
                      size: 40
                    ),
                  ),
                ) : Container()
              ],
            )
          ],
        ),
      );
    }

    final lineItems = [
      UserMainInfoCard(),
      _horizontalListView("Sản phẩm của tôi", [], "tool-list-on-board.svg", isMyLine: true, type: "line"),
      GestureDetector(
        onTap: (){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DashboardScreen(Constants.bottomBar["detail"], 0, 0)));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Xem tất cả",
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.black45, fontWeight: FontWeight.bold
                )
              ),
              SizedBox(width: 5),
              Icon(
                Icons.arrow_forward,
                color: Colors.black45,
                size: 20
              )
            ]
          )
        ),
      ),
      SizedBox(height: 40)
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView.builder(
          itemCount: lineItems.length,
          itemBuilder: (_, i) {
            return lineItems[i];
          },
        )
      )
    );
  }
}